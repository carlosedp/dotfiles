# Kubernetes functions and aliases

## Aliases
alias ksvc='kubectl get services -o wide --all-namespaces --sort-by="{.metadata.namespace}"'
alias kpod='kubectl get pods -o wide --all-namespaces --sort-by="{.metadata.namespace}" |awk {'"'"'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $8'"'"'} | column -t'
alias kedp='kubectl get endpoints -o wide --all-namespaces --sort-by="{.metadata.namespace}"'
alias king='kubectl get ingress -o wide --all-namespaces --sort-by="{.metadata.namespace}"'
alias kns='kubens'
alias kctx='kubectx'
alias kaf='kubectl apply -f'

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

## Functions
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
    PODS=$(kubectl get pods --all-namespaces|grep ${POD} |head -${INDEX} |tail -1)
    PODNAME=$(echo ${PODS} |awk '{print $2}')
    echo "Pod: ${PODNAME}"
    echo
    NS=$(echo ${PODS} |awk '{print $1}')
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
    PODS=$(kubectl get pods --all-namespaces|grep ${POD} |head -${INDEX} |tail -1)
    PODNAME=$(echo ${PODS} |awk '{print $2}')
    echo "Pod: ${PODNAME}"
    echo
    NS=$(echo ${PODS} |awk '{print $1}')
    kubectl exec -it --namespace=${NS} ${PODNAME} /bin/sh
}

kdesc() {
    POD=$1
    INPUT_INDEX=$2
    INDEX="${INPUT_INDEX:-1}"
    PODS=$(kubectl get pods --all-namespaces|grep ${POD} |head -${INDEX} |tail -1)
    PODNAME=$(echo ${PODS} |awk '{print $2}')
    echo "Pod: ${PODNAME}"
    echo
    NS=$(echo ${PODS} |awk '{print $1}')
    kubectl describe pod --namespace=${NS} ${PODNAME}
}

# Kubectl command for all namespaces
ka() {
    kubectl $@ --all-namespaces
}

# Get not running pods
knr() {
    kubectl get pods -A -o wide| grep -v Running |grep -v Completed |awk {'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $8'} | column -t
}

# Watch not running pods
wnr() {
    watch 'kubectl get pods -A -o wide| grep -v Running |grep -v Completed |awk {'"'"'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $8'"'"'} | column -t'
}

# Get nodes
kn() {
    kubectl get nodes -o wide| awk {'print substr($1,1,30)" " $2" " $3" " $4" " $5" " $7'} | column -t
}

# Watch nodes
wn() {
    watch 'kubectl get nodes -o wide | awk {'"'"'print substr($1,1,30)" " $2" " $3" " $4" " $5" " $7'"'"'} | column -t'
}