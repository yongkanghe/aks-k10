#-------Set the environment variables"
export MY_GROUP=rg4yong1            #Customize your resource group name
export MY_CLUSTER=aks4yong1         #Customize your cluster name
# export MY_VMSIZE=Standard_D4as_v4   #Customize your VM size
export MY_VMSIZE=Standard_D2as_v4   #Customize your VM size
export MY_LOCATION=southeastasia     #Customize your location
export MY_REGION="Southeast Asia"    #Customize region for Blob Storage
# export MY_LOCATION=centralindia     #Customize your location
# export MY_REGION="Central India"    #Customize region for Blob Storage
export MY_CONTAINER=k10container4yong1      #Customize your container
export MY_OBJECT_STORAGE_PROFILE=myazblob1  #Customize your profile name
export AZURE_STORAGE_ACCOUNT_ID=azsa4yong1  #Customize your Storage Account
export K8S_VERSION=1.23                     #Customize your Kubernetes Version
export MY_PREFIX=$(echo $(whoami) | sed -e 's/\_//g' | sed -e 's/\.//g' | awk '{print tolower($0)}')

