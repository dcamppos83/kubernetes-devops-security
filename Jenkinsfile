pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Unit Tests - JUnit and Jacoco') {
            steps {
              sh "mvn test"
            }
            post {
              always {
                junit 'target/surefire-reports/*.xml'
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }
      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
              always {
                pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
            }
       }
      stage('SonarQube - SAST') {
            steps {
              withSonarQubeEnv('SonarQube') {
                sh "mvn clean verify sonar:sonar \
                    -Dsonar.projectKey=numeric-application \
                    -Dsonar.host.url=http://devsecops-demo39.eastus.cloudapp.azure.com:9000"
              }
              timeout(time: 2, unit: 'MINUTES') {
                script {
                  waitForQualityGate abortPipeline: true
                }
              }
            }
       }
      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t dcamppos83/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push dcamppos83/numeric-app:""$GIT_COMMIT""'
              }
            }
       }
      stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: "kubeconfig"]) {
                sh "sed -i 's#replace#dcamppos83/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
              }
            }
       }
    }
}
