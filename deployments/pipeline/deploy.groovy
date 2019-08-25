/*
    Create the kubernetes namespace
 */
def createNamespace (namespace) {
    echo "Creating namespace ${namespace} if needed"

    sh "[ ! -z \"\$(kubectl get ns ${namespace} -o name 2>/dev/null)\" ] || kubectl create ns ${namespace}"
}

node {


  ////////// Step 1 //////////
  stage('Prepartion') {

    // Validate kubectl
    sh 'kubectl version'

    // helm init
    sh 'helm init --client-only'

    // Validate helm
    sh 'helm version'

  }


  ////////// Step 2 //////////
  stage('Git clone') {

    // Clean workspace
    deleteDir()

    // Download the guestbook chart
    sh 'git clone https://github.com/lanesky/kubernetes-walk-through.git'
  
  }

  ////////// Step 3 //////////
  stage('Deploy to dev') {

    namespace = 'development'

    // Create namespace if necessary
    createNamespace (namespace)

    // Install guestbook
    sh 'helm install --name guestbook --namespace development ./kubernetes-walk-through/deployments/charts/guestbook/'

  }

}
