pipeline {
  agent any
  environment {
    PACKER_HOME=tool(name: 'packer-1.1.3', type: 'biz.neustar.jenkins.plugins.packer.PackerInstallation')

    PACKER_SUBSCRIPTION_ID="fcc1ad01-b8a5-471c-812d-4a42ff3d6074"
    PACKER_CLIENT_ID="7d68a4b4-e3f1-4bf7-80ee-50a821728ce5"
    PACKER_LOCATION="westeurope"
    PACKER_TENANT_ID="787717a7-1bf4-4466-8e52-8ef7780c6c42"
    PACKER_OBJECT_ID="56e89fa0-e748-49f4-9ff0-0d8b9e3d4057"

    PACKER_CLIENT_SECRET=credentials('PACKER_CLIENT_SECRET_CSCHAFFE')
    WORKSPACE=pwd()
    GIT_COMMIT="${env.GIT_COMMIT}"
    BUILD_ID="${env.BUILD_ID}"
  }
  stages {
    stage('build jar') {
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
    stage('packer') {
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', 'colormapName': 'xterm']){


          echo 'validating packer file'
          sh '${PACKER_HOME}/packer validate ${WORKSPACE}/packer/azure.json'

          echo 'building packer file'
          echo '$GIT_COMMIT'
          echo '$BUILD_ID'
          //sh '${PACKER_HOME}/packer build ${WORKSPACE}/packer/azure.json'

        }
      }

    }
  }
}
