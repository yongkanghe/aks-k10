# This is a draft, to be completed. 

I just want to build an AKS Kubernetes Cluster to play with the various Data Management capabilities e.g. Backup/Restore, Disaster Recovery and Application Mobility. It is challenging to create it from Azure Cloud if you are not familiar to it. After the AKS Cluster is up running, we still need to install Kasten, create a sample database, create location profile, backup policies etc.. The whole process is not that simple.

![image](https://blog.kasten.io/hs-fs/hubfs/Kasten_January2020/Images/microsoft-azure-with-kasten-k10-intro-blog.png?width=1226&name=microsoft-azure-with-kasten-k10-intro-blog.png)


This script based automation allows you to build a ready-to-use Kasten K10 demo environment running on AKS in about 10 minutes. For simplicity and cost optimization, the AKS cluster will have only one worker node in the newly created vnet and subnet. This is bash shell based scripts which might only work on Linux and MacOS terminal or Cloud Shell. 

# Here're the prerequisities. 
## Step 1 to 3 required for MacOS and Linux, skip for Cloud Shell.
1. Install the Azure CLI https://docs.microsoft.com/en-us/cli/azure/install-azure-cli 
2. Signin with Azure CLI, run below command 
````
az login
````
3. Install git if not installed, https://www.linode.com/docs/guides/how-to-install-git-on-linux-mac-and-windows/
4. Clone the github repo to your local host, run below command
````
git clone https://github.com/yongkanghe/aks-k10.git
````
5. Create Azure App Registration first
````
cd aks-k10;./createapp.sh
````
6. Optionally, you can customize the clustername, vm size, zone, region, containername
````
vi setenv.sh
````
 
# To build the labs, run 
````
./deploy.sh
````
1. Create a GKE Cluster from CLI
2. Install Kasten K10
3. Deploy a Postgres database
4. Create a location profile
5. Create a backup policy
6. Kick off an on-demand backup job

# To delete the labs, run 
````
./destroy.sh
````
1. Remove GKE Kubernetes Cluster
2. Remove all the relevant disks
3. Remove all the relevant snapshots
4. Remove all the objects from the bucket

# How to use it, watch the Youtube video.
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/6vDEk_9cNaI/0.jpg)](https://www.youtube.com/watch?v=6vDEk_9cNaI)

# For more details about GKE Backup and Restore
https://blog.kasten.io/posts/postgresql-backup-and-restore-on-google-cloud-using-kasten-k10


# Kasten - No. 1 Kubernetes Backup
https://kasten.io 

# Kasten - DevOps tool of the month July 2021
http://k10.yongkang.cloud
