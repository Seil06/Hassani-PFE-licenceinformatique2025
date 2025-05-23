pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")

/* include(":app")

// Set up Flutter plugin loading
val flutterProjectRoot = rootProject.projectDir.parentFile.toPath()
val plugins = mutableMapOf<String, String>()
val pluginsFile = flutterProjectRoot.resolve(".flutter-plugins").toFile()

if (pluginsFile.exists()) {
    pluginsFile.forEachLine { line ->
        val plugin = line.split("=")
        if (plugin.size == 2) {
            plugins[plugin[0]] = plugin[1]
        }
    }
}

plugins.forEach { (name, path) ->
    val pluginDirectory = flutterProjectRoot.resolve(path).resolve("android").toFile()
    include(":$name")
    project(":$name").projectDir = pluginDirectory
}

// Apply the app_plugin_loader.gradle script
apply(mapOf("from" to "${flutterProjectRoot}\\packages\\flutter_tools\\gradle\\app_plugin_loader.gradle"))

// Configure repositories
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}*/