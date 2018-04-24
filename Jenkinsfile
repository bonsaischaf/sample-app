pipeline {
  agent any
  environment {
    PACKER_HOME=tool(name: 'packer-1.1.3', type: 'biz.neustar.jenkins.plugins.packer.PackerInstallation')
    PACKER_SUBSCRIPTION_ID="fcc1ad01-b8a5-471c-812d-4a42ff3d6074"
    PACKER_CLIENT_ID="262d2df5-a043-458a-9d0d-27a734962cd9"
    PACKER_CLIENT_SECRET=credentials('PACKER_CLIENT_SECRET_CSCHAFFE')
    PACKER_LOCATION="westeurope"
    PACKER_TENANT_ID="787717a7-1bf4-4466-8e52-8ef7780c6c42"
    PACKER_OBJECT_ID="56e89fa0-e748-49f4-9ff0-0d8b9e3d4057"
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

          echo 'currently in $(pwd)'

          echo 'validating packer file'
          sh '${PACKER_HOME}/packer validate packer/azure.json'

          echo 'building packer file'
          echo 'skipping: ${PACKER_HOME}/packer validate packer/azure.json'

        }
      }

    }
  }
}
