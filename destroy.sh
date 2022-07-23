starttime=$(date +%s)
. ./setenv.sh

echo '-------Deleting an AKS Cluster (typically in less than 10 mins)'
az group delete -g $MY_PREFIX-$MY_GROUP --yes
kubectl config delete-context $(kubectl config get-contexts | grep $MY_CLUSTER | awk '{print $2}')
echo "" | awk '{print $1}'

# echo '-------Deleting the app registration created by AKS'
# MYID=$(az ad sp list --show-mine --query [].servicePrincipalNames -o table | grep $MY_PREFIX-$MY_GROUP | awk '{print $2}')
# az ad app delete --id $MYID

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
echo "-------Created by Yongkang"
echo "-------Email me if any suggestions or issues he@yongkang.cloud"
echo "" | awk '{print $1}'