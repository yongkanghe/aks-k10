starttime=$(date +%s)
. setenv.sh
echo '-------Deleting an AKS Cluster (typically in less than 10 mins)'
MY_PREFIX=$(echo $(whoami) | sed -e 's/\_//g' | sed -e 's/\.//g' | awk '{print tolower($0)}')
az group delete -g $MY_PREFIX-$MY_GROUP --yes
kubectl config delete-context $(kubectl config get-contexts | grep $MY_CLUSTER | awk '{print $2}')

echo '-------Deleting the app registration created by AKS'
#az storage account delete -n MY_PREFIX-$AZURE_STORAGE_ACCOUNT_ID -g $MY_PREFIX-$MY_GROUP --yes
MYID=$(az ad sp list --show-mine --query [].servicePrincipalNames -o table | grep $MY_PREFIX-$MY_GROUP | awk '{print $2}')
az ad app delete --id $MYID

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
