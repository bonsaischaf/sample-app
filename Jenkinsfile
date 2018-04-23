pipeline {
  agent {
    any
    }
  stages {
    stage('build') {
        steps {
        withMaven(
          maven: '3.5.2',
          JDK: '1.8'
          )
          sh 'mvn package'
        }
    }
  }
}
