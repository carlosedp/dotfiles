#!/bin/bash

# This script will create client certificates, a kubeconfig file and a roles yaml file
# The yaml file needs to be applied to the cluster for the user to be able to access the cluster.
# You must have the cluster `ca.crt` and `ca.key` to be able to sign the client certificate(s)
# Please define CAPATH according to your setup and adjust the paths to ca.crt and ca.key. Usually
# these files are in CAPATH dir.
# The script creates role and rolebinding for all or selected namespaces. Please check the role/rolebinding yaml file
# before you apply it to the cluster. It has a (sane) set of permissions which can be altered later.

# Author Sebastian Sasu <sebi@nologin.ro>

# set -o xtrace
set -o errexit
set -o nounset
set -o pipefail

bold=$(tput bold)
normal=$(tput sgr0)

# Choose the kubernetes cluster you want to use
echo -e "${bold}Choose the k8s cluster from below:${normal}"
CLUSTER=$(kubectl config get-clusters | egrep -v NAME)
context=$(kubectl config current-context)

echo -e $CLUSTER | tr " " "\n"
echo ""
read -r cluster

# Set an use the specific context, to be able to extract the namespaces
kubectl config set-context $context > /dev/null
kubectl config use-context $context > /dev/null

# Get the relevant namespaces. Here you can exclude namespaces
NAMESPACES=$(kubectl get namespaces | egrep -v '(NAME|^kube)'|cut -d " " -f1)

# Define the user name
echo ""
echo -e "${bold}Type the name of the user you want to create:${normal}"
read -r user

CA_LOCATION=/etc/kubernetes/pki
WORKDIR="$HOME/certificates/users"
mkdir -p ${WORKDIR} || true

# Let's put everything into one place
if [[ ! -d "$WORKDIR/$user" ]]; then
  echo "${bold}User directory doesn't exist, creating it...${normal}"
  echo ""
  mkdir "${WORKDIR}/${user}"
else echo -e "${bold}Directory 'users' exists, proceeding with key and csr creation...${normal}\n"
  echo ""
fi

echo ""
echo -e "${bold}Generating user certificate and signing it...${normal}\n"

openssl genrsa -out $WORKDIR/${user}/${user}.key 2048
openssl req -new -key $WORKDIR/${user}/${user}.key -out $WORKDIR/${user}/${user}.csr -subj "/CN=$user/O=ORG"
sudo openssl x509 -req -in $WORKDIR/${user}/${user}.csr -CA $CA_LOCATION/ca.crt -CAkey $CA_LOCATION/ca.key -CAcreateserial -out $WORKDIR/${user}/${user}.crt -days 365

echo ""
echo -e "${bold}Please specify which namespaces will be accessible to the user, separated by space. If empty, all namespaces found will be used: ${normal}"
echo $NAMESPACES | tr " " "\n"| sort
echo ""

read -r USERNAMESPACES

if [[ -z $USERNAMESPACES ]]; then
  NAMESPACES=$(echo ${NAMESPACES})
else NAMESPACES=$(echo ${USERNAMESPACES})
fi

SERVER=$(kubectl cluster-info |grep "Kubernetes master"|cut -d " " -f6|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g")


###
echo ""
echo -e "${bold}Generating the config file for kubectl... ${normal}\n"

cat <<EOF > $WORKDIR/${user}/${user}.config
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat $CA_LOCATION/ca.crt | base64) # the ca.crt. Paths can be used (/path/to/cert.crt)
    server: ${SERVER}
  name: ${cluster}
# Add as many clusters as needed

contexts:
- context:
    cluster: ${cluster}
    namespace: $(echo "${NAMESPACES}" | head -n 1)
    user: ${user}
  name: ${context}
# Add as many contexts as needed
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${user}
  user:
    as-user-extra: {}
    client-certificate-data: $(cat $WORKDIR/${user}/${user}.crt | base64) # Paths can be used (/path/to/cert.crt)
    client-key-data: $(cat $WORKDIR/${user}/${user}.key | base64) # Paths can be used (/path/to/cert.key)
# Add as many users as needed

EOF


echo -e "${bold}Generating the Role & RoleBinding...${normal}\n"

for i in ${NAMESPACES}; do
cat <<EOF > $WORKDIR/${user}/${user}-${i}.yaml
# Permission to save sealed secrets certificate: kubeseal --fetch-cert > cert.pem
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: kube-system
  name: $user-role # needs to be unique
rules:
- apiGroups: [""]
  resources: ["services/proxy"]
  verbs: ["get"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $user-rolebinding # needs to be unique
  namespace: kube-system
subjects:
- kind: User
  name: $user
  apiGroup: ""
roleRef:
  kind: Role
  name: $user-role # needs to be unique
  apiGroup: ""
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: ${i}
  name: $user-role # needs to be unique
rules:
- apiGroups: ["", "extensions", "apps", "batch"]
  resources: ["deployments", "deployments/scale", "replicasets", "pods", "pods/log", "pods/exec", "jobs", "secrets"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $user-rolebinding # needs to be unique
  namespace: ${i}
subjects:
- kind: User
  name: $user
  apiGroup: ""
roleRef:
  kind: Role
  name: $user-role # needs to be unique
  apiGroup: ""
---
EOF
done

cat $WORKDIR/${user}/${user}-*.yaml > $WORKDIR/${user}/${user}.yaml
rm -rf $WORKDIR/${user}/${user}-*.yaml

echo -e "${bold}Adding ClusterRole & ClusterRoleBinding...${normal}\n"

cat <<EOF >> $WORKDIR/${user}/${user}.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $user-clusterrole # needs to be unique
rules:
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["list"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $user-clusterrolebinding # needs to be unique
subjects:
- kind: User
  name: $user
  apiGroup: ""
roleRef:
  kind: ClusterRole
  name: $user-clusterrole # needs to be unique
  apiGroup: ""
---
EOF

echo -e "${bold}Files generated in $WORKDIR/${user}! ${normal}\n"
echo -e "Apply the generated yaml files to the cluster with ${bold}kubectl apply -f $WORKDIR/${user}/${user}.yaml${normal}"
echo -e "Copy $WORKDIR/${user}/${user}.config to the user's ~/.kube/config"
#
#Merging multiple user config files into one (i.e. dev and prod .config files)
#
#export KUBECONFIG=/path/to/config-dev.config:/path/to/config-prod.config
#kubectl config view --raw > /path/to/dev-prod-merged.config



