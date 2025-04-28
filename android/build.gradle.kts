buildscript {
    val objectboxVersion by extra("4.2.0")
    val kotlin_version by extra("1.9.22")

    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        google()
        mavenCentral()
    }

    dependencies {
//        classpath( "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        classpath("io.objectbox:objectbox-gradle-plugin:$objectboxVersion")
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
