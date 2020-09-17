pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('Jenkins-Access-Key')
        AWS_SECRET_ACCESS_KEY = credentials('Jenkins-IAM-Secret')
        GIT_PROJECT = "//GIT_ORIGIN"
        IMAGE_NAME = "//DOCKER_IMAGE_NAME"
        // Used for conveinent slack pinging
        SERVICE_NAME = "${IMAGE_NAME}"
    }
    stages {
        // stage('Functional Tests') {
        // }
        stage('Deploy Code') {
            when {
                branch 'master'
            }
            steps {
                script {
                    def image = docker.build("${IMAGE_NAME}")

                    image.inside() {
                        withEnv([
                        'HOME=.',
                        ]) {
                            // You have to have npm install because permissions in the docker src directory are root and not the 1000:1000
                            sh "npm install && serverless deploy --verbose"
                        }
                    }
                }
                
                echo "Tagging master with version ${env.BUILD_ID}"
                sh 'ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts'
                sshagent(['bitbucket-ssh-key']) {
                    sh "git tag -a ${env.BUILD_ID} -m 'Jenkins managed build tag'"
                    sh "git push $GIT_PROJECT --tags"
                }
            }
            post {
                always {
                    // make sure that the Docker image is removed
                    dockerCleanup "$IMAGE_NAME"
                }
                success {
                    pingSlackWithSuccessAndServiceName "${env.IMAGE_NAME}: Sucessfully deployed", [ping_user: true]
                }
                failure {
                    pingSlackWithFailAndServiceName "${env.IMAGE_NAME}: Failed to deploy"
                }
            }
        }
    }
}