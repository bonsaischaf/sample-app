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

    //TF_VAR_IMAGE_NAME="cschaffe-${env.GIT_COMMIT}-${env.BUILD_ID}"
    TF_VAR_IMAGE_NAME="cschaffe"
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
      when {
        expression {
          "${env.BRANCH_NAME}" == "packer" ||
          //"${env.BRANCH_NAME}" == "test" ||
          "${env.BRANCH_NAME}" == "release"
        }
      }
      steps {
        wrap([$class: 'AnsiColorBuildWrapper', 'colormapName': 'xterm']){

          echo 'validating packer file'
          sh '${PACKER_HOME}/packer validate ${WORKSPACE}/packer/azure.json'

          echo 'building packer file'
          sh '${PACKER_HOME}/packer build ${WORKSPACE}/packer/azure.json'
          }
        }
    }

    stage('terraform'){
      when {
        expression {
          "${env.BRANCH_NAME}" == "test" ||
          "${env.BRANCH_NAME}" == "release"
        }
      }
      environment {
          TERRAFORM_HOME = tool name: 'terraform-0.11.3'
          ARM_SUBSCRIPTION_ID = "${PACKER_SUBSCRIPTION_ID}"
          ARM_CLIENT_ID = "${PACKER_CLIENT_ID}"
          ARM_CLIENT_SECRET = credentials('PACKER_CLIENT_SECRET_CSCHAFFE')
          ARM_TENANT_ID = "${PACKER_TENANT_ID}"
          ARM_ENVIRONMENT = "public"
          TF_VAR_user = "cschaffe"
          TF_VAR_password = credentials('PACKER_CLIENT_SECRET_CSCHAFFE')
          TF_VAR_build_id = "${env.BUILD_ID}"
        }
        steps {
          wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']) {
            dir('terraform') {
                sh "${TERRAFORM_HOME}/terraform init -input=false -backend-config=\"key=${TF_VAR_user}.terraform.tfstate\""
                echo 'terraform plan'
                sh "${TERRAFORM_HOME}/terraform plan -out=tfplan"
                echo 'terraform apply'
                sh "${TERRAFORM_HOME}/terraform apply \"tfplan\""
                echo 'done'
            }
          }
        }
    }
  }
  post {
    always {
      // clean up workspace
      echo 'Cleaning up directory'
      deleteDir()
    }
  }
}
