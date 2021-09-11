starttime=$(date +%s)
. setenv.sh
echo '-------Deleting an AKS Cluster (typically in less than 10 mins)'

az group delete -g $MY_GROUP --yes
kubectl config delete-context $(kubectl config get-contexts | grep $MY_CLUSTER | awk '{print $2}')

echo '-------Deleting objects from the bucket'
az storage account delete -n MY_PREFIX-$AZURE_STORAGE_ACCOUNT_ID -g $MY_GROUP

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"