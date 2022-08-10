echo '-------Creating a S3 profile secret'
. ./setenv.sh

if [ ! -f ociaccess ]; then
  echo -n "Enter your Object Storage Access Key ID and press [ENTER]: "
  read AWS_ACCESS_KEY_ID
  echo "" | awk '{print $1}'
  echo $AWS_ACCESS_KEY_ID > ociaccess
  echo -n "Enter your Object Storage Secret Access Key and press [ENTER]: "
  read AWS_SECRET_ACCESS_KEY
  echo $AWS_SECRET_ACCESS_KEY >> ociaccess
fi

export OCI_MY_REGION=ap-mumbai-1
export OCI_MY_OBJECT_STORAGE_PROFILE=oci-migration
export AWS_ACCESS_KEY_ID=$(cat ociaccess | head -1)
export AWS_SECRET_ACCESS_KEY=$(cat ociaccess | tail -1)
echo oci-k10migration4yong1 | awk '{print tolower($0)}' > k10_migration_bucketname

#echo '-------Creating a S3 profile secret'
kubectl create secret generic k10-oci-s3-secret \
      --namespace kasten-io \
      --type secrets.kanister.io/aws \
      --from-literal=aws_access_key_id=$AWS_ACCESS_KEY_ID \
      --from-literal=aws_secret_access_key=$AWS_SECRET_ACCESS_KEY

echo '-------Creating an OCI OS S3 profile'
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Profile
metadata:
  name: $OCI_MY_OBJECT_STORAGE_PROFILE
  namespace: kasten-io
spec:
  type: Location
  locationSpec:
    credential:
      secretType: AwsAccessKey
      secret:
        apiVersion: v1
        kind: Secret
        name: k10-oci-s3-secret
        namespace: kasten-io
    type: ObjectStore
    objectStore:
      name: $(cat k10_migration_bucketname)
      objectStoreType: S3
      region: $OCI_MY_REGION
      endpoint: bmeup4b3jwcz.compat.objectstorage.ap-mumbai-1.oraclecloud.com
EOF
