echo '-------Creating an AKS Cluster + K10 (typically < 10 mins)'
starttime=$(date +%s)

#Create an AKS cluster
./aks-deploy.sh

#Deploy K10 + sample DB + backup policy 
./k10-deploy.sh

endtime=$(date +%s)
duration=$(( $endtime - $starttime ))
echo "-------Total time for AKS+K10 deployment is $(($duration / 60)) minutes $(($duration % 60)) seconds."
echo "" | awk '{print $1}'
