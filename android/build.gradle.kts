allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    project.plugins.withId("com.android.library") {
        project.extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            if (namespace == null) {
                val manifest = file("src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val text = manifest.readText()
                    Regex("""package="(.+?)"""").find(text)?.let {
                        namespace = it.groupValues[1]
                    }
                }
            }
            compileSdk = 34
        }
    }
}
