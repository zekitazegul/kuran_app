allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep APK/AAB outputs where Flutter's build commands expect them.
val sharedBuildDirectory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(sharedBuildDirectory)
subprojects {
    layout.buildDirectory.value(sharedBuildDirectory.dir(name))
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
