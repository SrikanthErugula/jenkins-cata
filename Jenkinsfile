

pipeline {
    agent {
        node {
            label 'AGENT-1'
        }
    }

    environment {
        COURSE = "Jenkins with DEVOPS"
        appVersion = ""
        ACC_ID = "655355946253"
        PROJECT = "roboshop"
        COMPONENT = "catalogue"
    }

    options {
        timeout(time: 10, unit: 'MINUTES')
        disableConcurrentBuilds()
    }

    // stages must be inside pipeline
    stages {
        stage('Read Version') {
            steps {
                script {
                    def packageJSON = readJSON file: 'package.json'
                    appVersion = packageJSON.version
                    echo "app version: ${appVersion}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    sh """
                        npm install
                    """
                }
            }
        }

        stage('Unit Test') {
            steps {
                script {
                    sh """
                        npm test
                    """
                }
            }
        }
        //Here you need to select scanner tool and send the analysis to server bcz we have many tools inside sonar-server
        stage('Sonar Scan') {
            environment {
                def scannerHome = tool 'sonar-8.0'
            }    
            steps {
                script {
                    withSonarQubeEnv('sonar-server'){
                        sh  "${scannerHome}/bin/sonar-scanner"   // see notes 
                    
                    }

                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Wait for the quality gate status
                    // abortPipeline: true will fail the Jenkins job if the quality gate is 'FAILED'
                    waitForQualityGate abortPipeline: true 
                }
            }
        } 
        

        stage('Build Image') {
            steps {
                script {
                    withAWS(region: 'us-east-1', credentials: 'aws-creds') {
                        sh """
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com
                        docker build -t ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com/${PROJECT}/${COMPONENT}:${appVersion} .
                        docker push ${ACC_ID}.dkr.ecr.us-east-1.amazonaws.com/${PROJECT}/${COMPONENT}:${appVersion}
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'I will always say Hello again!'
            cleanWs()
        }
        success {
            echo 'I will run if success'
        }
        failure {
            echo 'I will run if failure'
        }
        aborted {
            echo 'pipeline is aborted'
        }
    }
}