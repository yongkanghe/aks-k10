echo '-------Deploying Kasten K10 and MySQL'
starttime=$(date +%s)
. ./setenv.sh

echo '-------Exporting the Azure Tenant, Client, Secret'
AZURE_TENANT_ID=$(cat aks4yong1app | grep tenant | awk '{print $2}' | sed -e 's/\"//g')
AZURE_CLIENT_ID=$(cat aks4yong1app | grep appId | awk '{print $2}' | sed -e 's/\"//g' | sed -e 's/\,//g')
AZURE_CLIENT_SECRET=$(cat aks4yong1app | grep password | awk '{print $2}' | sed -e 's/\"//g' | sed -e 's/\,//g')

echo '-------Install K10'
kubectl create ns kasten-io
helm repo add kasten https://charts.kasten.io/
helm repo update 

#For Production, remove the lines ending with =1Gi from helm install
#For Production, remove the lines ending with airgap from helm install
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

echo '-------Set the default ns to k10'
kubectl config set-context --current --namespace kasten-io

echo '-------Creating an azure disk vsc'
cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
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

echo '-------Waiting for the Cluster ID, Web UI IP and token in about 2 mins'
clusterid=$(kubectl get namespace default -ojsonpath="{.metadata.uid}{'\n'}")
echo "" | awk '{print $1}' > aks_token
echo My Cluster ID is $clusterid >> aks_token
kubectl wait --for=condition=ready --timeout=180s -n kasten-io pod -l component=jobs
k10ui=http://$(kubectl get svc gateway-ext | awk '{print $4}'|grep -v EXTERNAL)/k10/#
echo -e "\nHere is the URL to log into K10 Web UI" >> aks_token
echo -e "\n$k10ui" >> aks_token
echo "" | awk '{print $1}' >> aks_token

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: k10-k10-yong
  annotations:
    kubernetes.io/service-account.name: "k10-k10"
EOF

#sa_secret=$(kubectl get serviceaccount k10-k10 -o jsonpath="{.secrets[0].name}" --namespace kasten-io)
echo "Here is the token to login K10 Web UI" >> aks_token
echo "" | awk '{print $1}' >> aks_token
kubectl get secret k10-k10-yong --namespace kasten-io -ojsonpath="{.data.token}{'\n'}" | base64 --decode | awk '{print $1}' >> aks_token
echo "" | awk '{print $1}' >> aks_token

echo '-------Waiting for K10 services are up running in about 3 mins more or less'
kubectl wait --for=condition=ready --timeout=300s -n kasten-io pod -l component=catalog

./az-location.sh

./mysql-policy.sh

echo '-------Accessing K10 UI'
cat aks_token

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time for K10 deployment is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
echo "" | awk '{print $1}'
