# Kubernetes functions and aliases

klog() {
    POD=$1
    CONTAINER_NAME=""
    shift
    while [[ $# -gt 0 ]]
    do
    key="$1"
    case $key in
      -i|--index)
      INPUT_INDEX="$2"
      shift # past argument
      shift # past value
      ;;
      *)
      CONTAINER_NAME="$1"
      shift
      ;;
    esac
    done
    INDEX="${INPUT_INDEX:-1}"
    PODS=`kubectl get pods --all-namespaces|grep ${POD} |head -${INDEX} |tail -1`
    PODNAME=`echo ${PODS} |awk '{print $2}'`
    echo "Pod: ${PODNAME}"
    echo
    NS=`echo ${PODS} |awk '{print $1}'`
    kubectl logs -f --namespace=${NS} ${PODNAME} ${CONTAINER_NAME}
}

wpod() {
    NS=$@
    NAMESPACE=${NS:-"--all-namespaces"}
    if [ "$NAMESPACE" != "--all-namespaces" ]
      then
      NAMESPACE="-n ${NS}"
    fi

    watch -n 1 kubectl get pods $NAMESPACE -o wide
}

kexec() {
    POD=$1
    INPUT_INDEX=$2
    INDEX="${INPUT_INDEX:-1}"
    PODS=`kubectl get pods --all-namespaces|grep ${POD} |head -${INDEX} |tail -1`
    PODNAME=`echo ${PODS} |awk '{print $2}'`
    echo "Pod: ${PODNAME}"
    echo
    NS=`echo ${PODS} |awk '{print $1}'`
    kubectl exec -it --namespace=${NS} ${PODNAME} /bin/sh
}

kdesc() {
    POD=$1
    INPUT_INDEX=$2
    INDEX="${INPUT_INDEX:-1}"
    PODS=`kubectl get pods --all-namespaces|grep ${POD} |head -${INDEX} |tail -1`
    PODNAME=`echo ${PODS} |awk '{print $2}'`
    echo "Pod: ${PODNAME}"
    echo
    NS=`echo ${PODS} |awk '{print $1}'`
    kubectl describe pod --namespace=${NS} ${PODNAME}
}

# Kubectl command for all namespaces
ka() {
    kubectl $@ --all-namespaces
}

# Kubectl command for specific namespace
kn() {
    namespace=$1
    shift
    kubectl -n $namespace $@
}

#export -f kdesc

# Load kubectl completion
source <(kubectl completion $(ps -p $$ -oargs= |tr -d "-"))

# Load openshift oc completion
# Disable due to load time
#if [ -x "$(command -v oc)" ] > /dev/null 2>&1; then
#    source <(oc completion $(ps -p $$ -oargs= |tr -d "-"))
#fi

alias ksvc='kubectl get services -o wide --all-namespaces'
alias kpod='kubectl get pods -o wide --all-namespaces'
alias kedp='kubectl get endpoints -o wide --all-namespaces'
alias king='kubectl get ingress -o wide --all-namespaces'
alias kns='kubens'
alias kctx='kubectx'

alias k=kubectl
alias kd='kubectl delete'
alias kdf='kubectl delete --grace-period=0 --force'
alias kc='kubectl create'
alias kg='kubectl get all'
alias kp='kubectl get pods -o wide'
alias ks='kubectl get services'
alias ke='kubectl get endpoints'

alias wp='watch -n 1 kubectl get pods -o wide'
alias kt='stern --all-namespaces'


