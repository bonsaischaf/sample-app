pipeline {
  agent any
  stages {
    stage('build') {
        steps {
        withMaven(
          maven: '3.5.2',
          jdk: '1.8'
          ) {
            echo 'building with maven ..'
            sh 'mvn package'
          }
        }
    }
  }
}
