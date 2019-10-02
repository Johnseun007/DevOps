node {

    def mvnHome = tool 'Maven3'
    stage ("checkout") {
        scm checkout code
    }

    stage ('build') {
    sh "${mvnHome}/bin/mvn clean install -f delivery-app/pom.xml"
    }

    stage ('Code Quality scan') {
       withSonarQubeEnv('SonarQube') {
       sh "${mvnHome}/bin/mvn -f delivery-app/pom.xml sonar:sonar"
        }
   }
   
   stage ('Code coverage') {
       jacoco()
   }

   stage ('Nexus upload') 
    {
        nexusArtifactUploader(
        nexusVersion: 'nexus3',
        protocol: 'http',
        nexusUrl: 'nexus_url:8081',
        groupId: 'myGroupId',
        version: '1.0-SNAPSHOT',
        repository: 'maven-snapshots',
        credentialsId: '2c293828-9509-49b4-a6e7-77f3ceae7b39',
        artifacts: [
            [artifactId: 'delivery-app',
             classifier: '',
             file: 'MyWebApp/target/delivery-app.war',
             type: 'war']
        ]
     )
    }

    
   stage ('DEV Deploy')
    {
      echo "deploying to DEV Env "
      sh 'sudo cp /var/lib/jenkins/workspace/$JOB_NAME/MyWebApp/target/delivery-app.war /var/lib/tomcat8/webapps'
    }
    

   stage ('DEV Approve')
      {
            echo "Taking approval from DEV Manager"
               
            timeout(time: 7, unit: 'DAYS') {
            input message: 'Do you want to deploy?', submitter: 'admin'
            }
     }
  stage ('Slack notification') 

  {
    slackSend(channel:'channel-name', message: "Job is successful, here is the info -  Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
 
   }

 

stage ('QA Deploy')
{
echo "deploying to QA Env "
sh 'sudo cp /var/lib/jenkins/workspace/$JOB_NAME/MyWebApp/target/MyWebApp.war /var/lib/tomcat8/webapps'

}
stage ('QA Approve')
{
echo "Taking approval from QA manager"

timeout(time: 7, unit: 'DAYS') {
input message: 'Do you want to proceed to PROD?', submitter: 'admin,manager_userid'
}
}
}
