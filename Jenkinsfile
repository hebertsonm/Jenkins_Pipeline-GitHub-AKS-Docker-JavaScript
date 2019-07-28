#!groovy
node {
    def docker_image='hebertsonm/node-bbycasre' // image name
    def AZURE_AKS_NAME='k8s' // kubernetes cluste name
    def AZURE_RG='k8s' // azure resource group
    def AZURE_DNS // root DNS for applications
    
    // Build and Push Docker image into DockerHub
    stage('Build/Push Docker image') {
        // checkout this repository
        checkout scm

        //def app = docker.build("${docker_image}") //crashes after building
        
        // build Docker image
        sh "docker build -t ${docker_image} ."
        
        // run validation tests within the container
        docker.image("${docker_image}").inside {
            sh 'node -v'
        }
        
        //push the image into DockerHub
        docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
            //docker.image("${docker_image}").push()
        }
    }
    
    // Get AKS credentials
    stage("Get AKS credentials") {
        withCredentials([azureServicePrincipal('azure-credential')]) {
          sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
        }

        sh "az AKS get-credentials -g ${AZURE_RG} -n ${AZURE_AKS_NAME} --overwrite-existing"
    }
    
    stage("Get public DNS") {
        sh "az aks show --resource-group k8s --name k8s --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table | tail -n 1 > result"
        AZURE_DNS=readFile('result').trim()
        sh "echo ${AZURE_DNS}"
    }
    
    // DEV Deployment
    stage('AKS Deployment') {
        def NAMESPACE='dev'
        
        //withCredentials([string(credentialsId: 'hebertsonm', variable: 'DockerHubpassword')]) {
        //  sh 'docker login -u hebertsonm -p $DockerHubpassword'
        //}
        
        sh "if !(kubectl create namespace ${NAMESPACE}); then echo 'namespace already exists'; fi;"
        
        sh "sed -i -e 's/__AZURE_DNS__/${AZURE_DNS}/' ingress/dev.yaml"
          
        sh "kubectl apply --namespace ${NAMESPACE} -f env/dev.yaml"

        sh "kubectl apply --namespace ${NAMESPACE} -f bbycasre.yaml"

        sh "kubectl apply --namespace ${NAMESPACE} -f ingress/dev.yaml"
    
    }
}

stage('Deploy approval'){
    timeout(time:5, unit:'DAYS') {
        input message:'Approve Test deployment?', submitter: 'it-ops'
    }    
}

node{

stage("TEST Deployment") {
          
    withCredentials([azureServicePrincipal('azure-credential')]) {
        sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
    }

    sh 'az AKS get-credentials -g bestbuy -n bestbuy --overwrite-existing'
/*
    sshagent (credentials: ['deploy-dev']) {
      sh 'ssh -o StrictHostKeyChecking=no -l cloudbees 192.168.1.106 uname -a'
    }
*/
    withCredentials([string(credentialsId: 'hebertsonm', variable: 'DockerHubpassword')]) {
      sh 'docker login -u hebertsonm -p $DockerHubpassword'
    }
    
    sh 'kubectl apply --namespace test -f env/test.yaml'

    sh 'kubectl apply --namespace test -f bbycasre.yaml'

    sh 'kubectl apply --namespace test -f ingress/test.yaml'
}
}

stage('Deploy approval'){
    input "Deploy to DR?"
}
node{
    
  stage("DR Deployment") {
    withCredentials([azureServicePrincipal('azure-credential')]) {
        sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
    }

    sh 'az AKS get-credentials -g bestbuy -n bestbuy --overwrite-existing'
/*
    sshagent (credentials: ['deploy-dev']) {
      sh 'ssh -o StrictHostKeyChecking=no -l cloudbees 192.168.1.106 uname -a'
    }
*/
    withCredentials([string(credentialsId: 'hebertsonm', variable: 'DockerHubpassword')]) {
      sh 'docker login -u hebertsonm -p $DockerHubpassword'
    }
          
    sh 'kubectl apply --namespace dr -f env/dr.yaml'

    sh 'kubectl apply --namespace dr -f bbycasre.yaml'

    sh 'kubectl apply --namespace dr -f ingress/dr.yaml'

  }
}
stage('Deploy approval'){
    input "Deploy to PRODUCTION?"
}

node{

stage("PROD Deployment") {
          
    withCredentials([azureServicePrincipal('azure-credential')]) {
        sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'
    }

    sh 'az AKS get-credentials -g bestbuy -n bestbuy --overwrite-existing'
/*
    sshagent (credentials: ['deploy-dev']) {
      sh 'ssh -o StrictHostKeyChecking=no -l cloudbees 192.168.1.106 uname -a'
    }
*/
    withCredentials([string(credentialsId: 'hebertsonm', variable: 'DockerHubpassword')]) {
      sh 'docker login -u hebertsonm -p $DockerHubpassword'
    }
    
    sh 'kubectl apply --namespace prod -f env/prod.yaml'

    sh 'kubectl apply --namespace prod -f bbycasre.yaml'

    sh 'kubectl apply --namespace prod -f ingress/prod.yaml'
}
}
