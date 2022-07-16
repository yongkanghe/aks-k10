. ./setenv.sh

echo '-------Create a Azure Blob Storage profile secret'
kubectl create secret generic k10-aro-azure-secret \
      --namespace kasten-io \
      --from-literal=azure_storage_account_id=$MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID \
      --from-literal=azure_storage_key=$AZURE_STORAGE_KEY 

echo '-------Creating a Azure Blob Storage profile'
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Profile
metadata:
  name: $MY_OBJECT_STORAGE_PROFILE
  namespace: kasten-io
spec:
  type: Location
  locationSpec:
    credential:
      secretType: AzStorageAccount
      secret:
        apiVersion: v1
        kind: Secret
        name: k10-aro-azure-secret
        namespace: kasten-io
    type: ObjectStore
    objectStore:
      name: $MY_PREFIX-$MY_CONTAINER
      objectStoreType: AZ
      region: $MY_REGION
EOF
