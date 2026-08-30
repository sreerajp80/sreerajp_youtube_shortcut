import java.io.File
import java.io.FileInputStream
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.util.Date
import java.util.Properties
import java.util.TimeZone

data class PubspecVersion(
    val name: String,
    val code: Int,
)

fun readPubspecVersion(): PubspecVersion {
    val pubspecFile = rootProject.file("../pubspec.yaml")
    val versionLine =
        pubspecFile.useLines { lines ->
            lines.firstOrNull { line -> line.trimStart().startsWith("version:") }
        } ?: throw GradleException("Could not find version in pubspec.yaml")

    val rawVersion = versionLine.substringAfter("version:").trim()
    if (rawVersion.isEmpty()) {
        throw GradleException("pubspec.yaml version is empty")
    }

    val parts = rawVersion.split("+", limit = 2)
    val versionName = parts[0].trim()
    if (versionName.isEmpty()) {
        throw GradleException("pubspec.yaml version name is empty")
    }

    val versionCode =
        if (parts.size > 1) {
            parts[1].trim().toIntOrNull()
                ?: throw GradleException("pubspec.yaml build number must be an integer")
        } else {
            1
        }

    return PubspecVersion(name = versionName, code = versionCode)
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    FileInputStream(localPropertiesFile).use(localProperties::load)
}

val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw GradleException(
        "Flutter SDK path not found. Set flutter.sdk in android\\local.properties or FLUTTER_ROOT."
    )

val isWindowsHost = System.getProperty("os.name").startsWith("Windows", ignoreCase = true)
val dartExecutable = File(
    flutterSdkPath,
    if (isWindowsHost) "bin\\dart.bat" else "bin/dart",
)
val projectRootDir = rootProject.projectDir.parentFile

val generateBuildMetadata = tasks.register("generateBuildMetadata") {
    group = "build setup"
    description = "Generates About-screen build metadata before Android builds."

    inputs.file(projectRootDir.resolve("pubspec.yaml"))
    inputs.file(projectRootDir.resolve("tool/generate_app_version.dart"))
    inputs.file(projectRootDir.resolve("tool/generate_build_date.dart"))
    inputs.property("metadataBuildDate", LocalDate.now().toString())
    outputs.file(projectRootDir.resolve("lib/core/constants/app_version.g.dart"))
    outputs.file(projectRootDir.resolve("lib/core/constants/build_date.g.dart"))

    doLast {
        if (!dartExecutable.exists()) {
            throw GradleException(
                "Could not find Dart executable at ${dartExecutable.absolutePath}. " +
                    "Check android\\local.properties flutter.sdk or FLUTTER_ROOT."
            )
        }

        project.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_app_version.dart")
        }
        project.exec {
            workingDir = projectRootDir
            commandLine(dartExecutable.absolutePath, "run", "tool/generate_build_date.dart")
        }
    }
}

tasks.named("preBuild") {
    dependsOn(generateBuildMetadata)
}

tasks.matching { task ->
    task.name.startsWith("compileFlutterBuild")
}.configureEach {
    dependsOn(generateBuildMetadata)
}

// ─── Signing ──────────────────────────────────────────────────────────────────
val keyPropertiesFile = rootProject.file("key.properties")
val pubspecVersion = readPubspecVersion()
val buildDateFormatter = SimpleDateFormat("yyyy-MM-dd").apply { timeZone = TimeZone.getTimeZone("UTC") }
val buildDate = buildDateFormatter.format(Date())

android {
    namespace = "in.sreerajp.sreerajp_youtube_shortcut"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        applicationId = "in.sreerajp.sreerajp_youtube_shortcut"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = pubspecVersion.code
        versionName = pubspecVersion.name
        buildConfigField("String", "PUBSPEC_BUILD_NUMBER", "\"${pubspecVersion.code}\"")
        buildConfigField("String", "APP_BUILD_DATE", "\"$buildDate\"")
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                val props = Properties()
                props.load(keyPropertiesFile.inputStream())
                keyAlias      = props.getProperty("keyAlias")
                keyPassword   = props.getProperty("keyPassword")
                storeFile     = file(props.getProperty("storeFile"))
                storePassword = props.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            if (keyPropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
        debug {
            // Android applies the SDK debug keystore automatically.
        }
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "SreerajP YouTube Shortcuts Dev")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "SreerajP YouTube Shortcuts")
        }
    }
}

// ─── Signing enforcement ──────────────────────────────────────────────────────
// Blocks prod --release tasks at execution time when key.properties is absent.
// Uses tasks.matching so lazily registered AGP tasks are covered.
// Debug builds are never blocked — they use the SDK debug keystore automatically.
afterEvaluate {
    tasks.matching { it.name == "assembleProdRelease" || it.name == "bundleProdRelease" }
        .configureEach {
            doFirst {
                if (!keyPropertiesFile.exists()) {
                    throw GradleException(
                        "\n" +
                        "══════════════════════════════════════════════════════════\n" +
                        "  SIGNING REQUIRED — prod --release build blocked         \n" +
                        "══════════════════════════════════════════════════════════\n" +
                        "  android/key.properties not found.                       \n" +
                        "  Create the file with your release keystore credentials. \n" +
                        "  See docs/flutter_build_flavors_guide.md                 \n" +
                        "  Section: Android Signing Configuration                  \n" +
                        "══════════════════════════════════════════════════════════\n"
                    )
                }
            }
        }
}

flutter {
    source = "../.."
}




