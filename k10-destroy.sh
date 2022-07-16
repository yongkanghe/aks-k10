starttime=$(date +%s)
. ./setenv.sh

echo '-------Deleting MySQL and Kasten K10'
helm uninstall mysql -n yong-mysql
helm uninstall k10 -n kasten-io
kubectl delete ns yong-mysql
kubectl delete ns kasten-io

echo '-------Deleting objects from Azure Blob Storage Bucket'
az storage blob delete-batch --account-name $MY_PREFIX$AZURE_STORAGE_ACCOUNT_ID -s $MY_PREFIX-$MY_CONTAINER --account-key $(cat az_storage_key)

echo "" | awk '{print $1}'
endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
