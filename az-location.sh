. ./setenv.sh

echo '-------Create a Azure Blob Storage Container'
az storage container create -n $MY_PREFIX-$MY_CONTAINER --account-key $(cat az_storage_key) --account-name $MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID

echo '-------Create a Azure Blob Storage profile secret'
kubectl create secret generic k10-azure-secret \
      --namespace kasten-io \
      --from-literal=azure_storage_account_id=$MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID \
      --from-literal=azure_storage_key=$(cat az_storage_key)

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
        name: k10-azure-secret
        namespace: kasten-io
    type: ObjectStore
    objectStore:
      name: $MY_PREFIX-$MY_CONTAINER
      objectStoreType: AZ
      region: $MY_REGION
EOF
