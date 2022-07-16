echo '-------Creating a Resource Group and AKS Cluster (typically in less than 10 mins)'
starttime=$(date +%s)
. ./setenv.sh
MY_PREFIX=$(echo $(whoami) | sed -e 's/\_//g' | sed -e 's/\.//g' | awk '{print tolower($0)}')
az group create --name $MY_PREFIX-$MY_GROUP --location $MY_LOCATION
AKS_K8S_VERSION=$(az aks get-versions --location $MY_LOCATION --output table | awk '{print $1}' | grep 1.21 | head -1)
az aks create \
  --resource-group $MY_PREFIX-$MY_GROUP \
  --name $MY_PREFIX-$MY_CLUSTER-$(date +%s) \
  --location $MY_LOCATION \
  --generate-ssh-keys \
  --kubernetes-version $AKS_K8S_VERSION \
  --node-count 1 \
  --node-vm-size $MY_VMSIZE \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 3 \
  --network-plugin azure

echo '-------Exporting the Azure Tenant, Client, Secret'
AZURE_TENANT_ID=$(cat aks4yong1app | grep tenant | awk '{print $2}' | sed -e 's/\"//g')
AZURE_CLIENT_ID=$(cat aks4yong1app | grep appId | awk '{print $2}' | sed -e 's/\"//g' | sed -e 's/\,//g')
AZURE_CLIENT_SECRET=$(cat aks4yong1app | grep password | awk '{print $2}' | sed -e 's/\"//g' | sed -e 's/\,//g')

az aks get-credentials -g $MY_PREFIX-$MY_GROUP -n $(az aks list -o table | grep $MY_PREFIX-$MY_CLUSTER | awk '{print $1}')

echo '-------Install K10'
kubectl create ns kasten-io
helm repo add kasten https://charts.kasten.io/
helm repo update 

#For Production, remove the lines ending with =1Gi from helm install
helm install k10 kasten/k10 --namespace=kasten-io \
  --set secrets.azureTenantId=$AZURE_TENANT_ID \
  --set secrets.azureClientId=$AZURE_CLIENT_ID \
  --set secrets.azureClientSecret=$AZURE_CLIENT_SECRET \
  --set global.persistence.metering.size=1Gi \
  --set prometheus.server.persistentVolume.size=1Gi \
  --set global.persistence.catalog.size=1Gi \
  --set global.persistence.jobs.size=1Gi \
  --set global.persistence.logging.size=1Gi \
  --set global.persistence.grafana.size=1Gi \
  --set auth.tokenAuth.enabled=true \
  --set externalGateway.create=true \
  --set metering.mode=airgap 

# echo '-------Installing CSI Driver and enable snapshot support'
# curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/install-driver.sh | bash -s master snapshot --

echo '-------Set the default ns to k10'
kubectl config set-context --current --namespace kasten-io

echo '-------Creating a azure disk vsc'
cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1beta1
kind: VolumeSnapshotClass
metadata:
  annotations:
    k10.kasten.io/is-snapshot-class: "true"
  name: csi-azuredisk-vsc
driver: disk.csi.azure.com
deletionPolicy: Delete
parameters:
  incremental: "true"
EOF

echo '-------Deploy a MySQL database'
kubectl create namespace yong-mysql
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install mysql bitnami/mysql --namespace=yong-mysql \
  --set primary.persistence.size=1Gi,secondary.persistence.size=1Gi	

echo '-------Create a Azure Storage account'
AKS_RG=$(az group list -o table | grep $MY_PREFIX-$MY_GROUP | grep MC | awk '{print $1}')
az storage account create -n $MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID -g $AKS_RG -l $MY_LOCATION --sku Standard_LRS
export AZURE_STORAGE_KEY=$(az storage account keys list -g $AKS_RG -n $MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID --query [].value -o tsv | head -1)

echo '-------Waiting for the Cluster ID, Web UI IP and token in about 2 mins'
clusterid=$(kubectl get namespace default -ojsonpath="{.metadata.uid}{'\n'}")
echo "" | awk '{print $1}' > aks-token
echo My Cluster ID is $clusterid >> aks-token
kubectl wait --for=condition=ready --timeout=180s -n kasten-io pod -l component=jobs
k10ui=http://$(kubectl get svc gateway-ext | awk '{print $4}'|grep -v EXTERNAL)/k10/#
echo -e "\nHere is the URL to log into K10 Web UI" >> aks-token
echo -e "\n$k10ui" >> aks-token
echo "" | awk '{print $1}' >> aks-token
sa_secret=$(kubectl get serviceaccount k10-k10 -o jsonpath="{.secrets[0].name}" --namespace kasten-io)
echo "Here is the token to login K10 Web UI" >> aks-token
echo "" | awk '{print $1}' >> aks-token
kubectl get secret $sa_secret --namespace kasten-io -ojsonpath="{.data.token}{'\n'}" | base64 --decode | awk '{print $1}' >> aks-token
echo "" | awk '{print $1}' >> aks-token

echo '-------Waiting for K10 services are up running in about 3 mins more or less'
kubectl wait --for=condition=ready --timeout=300s -n kasten-io pod -l component=catalog

# echo '-------Create a Azure Blob Storage profile secret'
# kubectl create secret generic k10-azure-secret \
#       --namespace kasten-io \
#       --from-literal=azure_storage_account_id=$MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID \
#       --from-literal=azure_storage_key=$AZURE_STORAGE_KEY 

# echo '-------Creating a Azure Blob Storage profile'
# cat <<EOF | kubectl apply -f -
# apiVersion: config.kio.kasten.io/v1alpha1
# kind: Profile
# metadata:
#   name: $MY_OBJECT_STORAGE_PROFILE
#   namespace: kasten-io
# spec:
#   type: Location
#   locationSpec:
#     credential:
#       secretType: AzStorageAccount
#       secret:
#         apiVersion: v1
#         kind: Secret
#         name: k10-azure-secret
#         namespace: kasten-io
#     type: ObjectStore
#     objectStore:
#       name: $MY_PREFIX-$MY_CONTAINER
#       objectStoreType: AZ
#       region: $MY_REGION
# EOF

./az-location.sh

./mysql-policy.sh

# echo '------Create backup policies'
# cat <<EOF | kubectl apply -f -
# apiVersion: config.kio.kasten.io/v1alpha1
# kind: Policy
# metadata:
#   name: yong-mysql-backup
#   namespace: kasten-io
# spec:
#   comment: ""
#   frequency: "@hourly"
#   actions:
#     - action: backup
#       backupParameters:
#         profile:
#           namespace: kasten-io
#           name: $MY_OBJECT_STORAGE_PROFILE
#     - action: export
#       exportParameters:
#         frequency: "@hourly"
#         migrationToken:
#           name: ""
#           namespace: ""
#         profile:
#           name: $MY_OBJECT_STORAGE_PROFILE
#           namespace: kasten-io
#         receiveString: ""
#         exportData:
#           enabled: true
#       retention:
#         hourly: 0
#         daily: 0
#         weekly: 0
#         monthly: 0
#         yearly: 0
#   retention:
#     hourly: 4
#     daily: 1
#     weekly: 1
#     monthly: 0
#     yearly: 0
#   selector:
#     matchExpressions:
#       - key: k10.kasten.io/appNamespace
#         operator: In
#         values:
#           - yong-mysql
# EOF

# sleep 5

# echo '-------Kickoff the on-demand backup job'
# sleep 5
# cat <<EOF | kubectl create -f -
# apiVersion: actions.kio.kasten.io/v1alpha1
# kind: RunAction
# metadata:
#   generateName: run-backup-
# spec:
#   subject:
#     kind: Policy
#     name: yong-mysql-backup
#     namespace: kasten-io
# EOF

echo '-------Accessing K10 UI'
cat aks-token

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"

