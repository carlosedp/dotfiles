#!/usr/bin/env bash

# Kubernetes functions and aliases

## Aliases
alias k=kubectl
alias kctx='kubectl ctx'
alias kns='kubectl ns'

alias kpod='kubectl get pods -o wide --all-namespaces --sort-by="{.metadata.namespace}" |awk {'"'"'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $8'"'"'} | column -t'
alias kp='kubectl get pods -o wide --sort-by=.metadata.name|awk {'"'"'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $7'"'"'} | column -t'
alias ksvc='kubectl get services -o wide --all-namespaces --sort-by="{.metadata.namespace}"'
alias ks='kubectl get services -o wide --sort-by=.metadata.name'
alias kedp='kubectl get endpoints -o wide --all-namespaces --sort-by="{.metadata.namespace}"'
alias ke='kubectl get endpoints -o wide --sort-by=.metadata.name'
alias king='kubectl get ingress -o wide --all-namespaces --sort-by="{.metadata.namespace}"'

alias kc='kubectl create'
alias kaf='kubectl apply -f'
alias kd='kubectl delete'
alias kg='kubectl get all'
alias kt='stern --all-namespaces'
alias krew='kubectl krew'

# Approve OCP CSRs
alias csrapprove="oc get csr -oname | xargs oc adm certificate approve"

# Watch Pods
wpod() {
    NS=$*
    NAMESPACE=${NS:-"--all-namespaces"}
    if [ "$NAMESPACE" != "--all-namespaces" ]
      then
      NAMESPACE="-n ${NS}"
    fi
    watch -n 1 "kubectl get pods $NAMESPACE -o wide --sort-by={.metadata.namespace} |awk {'print substr(\$1,1,40)\" \" substr(\$2,1,45)\" \" \$3\" \" \$4\" \" \$5\" \" \$6\" \" \$8'} | column -t"
}
wp() {
    watch -n 1 "kubectl get pods -o wide --sort-by=.metadata.name|awk {'print substr(\$1,1,40)\" \" substr(\$2,1,45)\" \" \$3\" \" \$4\" \" \$5\" \" \$6\" \" \$7'} | column -t"
}

# Use multiple kubeconfig config files
kubeloadenv() {
    export KUBECONFIG=""
    if test -f "$HOME/.kube/config"; then
        export KUBECONFIG="$HOME/.kube/config"
        return
    fi
    if test -d "$HOME/.kube/"; then
        for kubeconfigFile in $(find "$HOME/.kube" -type f -name "config-*")
        do
            export KUBECONFIG="$KUBECONFIG:$kubeconfigFile"
        done
    fi
}
kubeloadenv

# Add and rename kubeconfig context for a cluster
kubeconfigadd() {
    if [ "$#" -ne 2 ]; then
        echo "Illegal number of parameters. Call function with config file and new cluster name."
        echo "E.g. kubeconfigadd newconfig prodcluster"
        return
    fi
    kubefile=$1
    clustername=$2
    if [ ! -f "$1" ]; then
        echo "File \"$1\" does not exist."
        return
    fi

    echo "Current server IP/URL is: " $(grep "server: http" "$kubefile")
    echo -n "Do you want to change it? [y/n]: "
    read -r
    if [[ $REPLY = "y" || $REPLY = "Y" ]]
    then
        echo -n "Type new server IP/URL in the format https://[IP/URL]:PORT: "
        read -r
        IP=${REPLY}
        echo -n "Is this correct: ${REPLY}? [y/n]: "
        read -r
        if [[ $REPLY = "y" || $REPLY = "Y" ]]; then
            sed "s;\(\s*server:\s\)http.*\(.*\);\1${IP}\2;g" -i "$(realpath $kubefile)"
            cp "$kubefile" "$HOME/.kube/config-$clustername"
        fi
    elif [[ $REPLY = "n" || $REPLY = "N" ]]; then
        cp "$kubefile" "$HOME/.kube/config-$clustername"
    fi
    # Rename user, cluster and context names
    sed "s;\(^.*name:\s\).*;\1${clustername};g" -i "$(realpath $HOME/.kube/config-$clustername)"
    sed "s;\(^.*cluster:\s\).*;\1${clustername};g" -i "$(realpath $HOME/.kube/config-$clustername)"
    sed "s;\(^.*user:\s\).*;\1${clustername};g" -i "$(realpath $HOME/.kube/config-$clustername)"
    kubeloadenv
}

## Functions
klog() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function pod name and optional container name."
        echo "E.g. klog mypod [containerinpod]"
        return
    fi
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
    PODS=$(kubectl get pods --all-namespaces|grep "${POD}" |head -"${INDEX}" |tail -1)
    PODNAME=$(echo "${PODS}" |awk '{print $2}')
    echo "Pod: ${PODNAME}"
    echo
    NS=$(echo "${PODS}" |awk '{print $1}')
    kubectl logs -f --namespace="${NS}" "${PODNAME}" "${CONTAINER_NAME}"
}

kexec() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function pod name and optional container name."
        echo "E.g. kexec mypod [containerinpod]"
        return
    fi
    POD=$1
    INPUT_INDEX=$2
    INDEX="${INPUT_INDEX:-1}"
    PODS=$(kubectl get pods --all-namespaces|grep "${POD}" |head -"${INDEX}" |tail -1)
    PODNAME=$(echo "${PODS}" |awk '{print $2}')
    echo "Pod: ${PODNAME}"
    echo
    NS=$(echo "${PODS}" |awk '{print $1}')
    kubectl exec -it --namespace="${NS}" "${PODNAME}" /bin/sh
}

kdesc() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function pod name and optional container name."
        echo "E.g. kdesc mypod [containerinpod]"
        return
    fi
    POD=$1
    INPUT_INDEX=$2
    INDEX="${INPUT_INDEX:-1}"
    PODS=$(kubectl get pods --all-namespaces|grep "${POD}" |head -"${INDEX}" |tail -1)
    PODNAME=$(echo "${PODS}" |awk '{print $2}')
    echo "Pod: ${PODNAME}"
    echo
    NS=$(echo "${PODS}" |awk '{print $1}')
    kubectl describe pod --namespace="${NS}" "${PODNAME}"
}

# Kubectl command for all namespaces
ka() {
    kubectl "$@" --all-namespaces
}

# Get not running pods
knr() {
    kubectl get pods -A -o wide| grep -v "Running\|Completed" |awk {'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $8'} | column -t
}

# Watch not running pods
wnr() {
    watch 'kubectl get pods -A -o wide| grep -v "Running\|Completed" |awk {'"'"'print substr($1,1,40)" " substr($2,1,45)" " $3" " $4" " $5" " $6" " $8'"'"'} | column -t'
}

# Get nodes
kn() {
    kubectl get nodes -o wide| awk {'print substr($1,1,30)" " $2" " $3" " $4" " $5" " $7'} | column -t
}

# Watch nodes
wn() {
    watch 'kubectl get nodes -o wide | awk {'"'"'print substr($1,1,30)" " $2" " $3" " $4" " $5" " $7'"'"'} | column -t'
}

# Open shell in pod
kshell() {
    if [ "$#" -lt 1 ]; then
        echo "Illegal number of parameters. Call function pod name and optional container name."
        echo "E.g. kshell mypod"
        return
    fi
  kubectl exec -ti "$@" -- /bin/sh -c 'command -v bash &> /dev/null && bash || sh'
  #kubectl exec -ti $1 -- command -v bash &> /dev/null && kubectl exec -ti $1 -- bash || kubectl exec -ti $1 -- sh
}

# Delete pod
kdp() {
    (
    kubectl delete pod "$@" > /dev/null 2>&1 &
    ) > /dev/null 2>&1
}

# Force delete pod
kdpf() {
    (
    kubectl delete --grace-period=0 --force pod "$@" &
    ) > /dev/null 2>&1
}

# Initialize and add custom completions
_kubectl_startup () {
    _kubectl
    complete -o default -o nospace -F __kubectl_get_resource_pod stern kt klog kdesc kexec kdp kdp! kshell
}

if [ -n "${BASH}" ]; then
    complete -o default -o nospace -F _kubectl_startup stern kt klog kdesc kexec kdp kdp! kshell
elif [ -n "${ZSH_NAME}" ]; then
    compdef _kubectl_startup stern kt klog kdesc kexec kdp kdp! kshell
fi
