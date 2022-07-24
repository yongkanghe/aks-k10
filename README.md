#### Follow [@YongkangHe](https://twitter.com/yongkanghe) on Twitter, Subscribe [K8s Data Management](https://www.youtube.com/channel/UCm-sw1b23K-scoVSCDo30YQ?sub_confirmation=1) Youtube Channel

I just want to build an AKS Cluster to play with the various Data Management capabilities e.g. Container's Backup/Restore, Disaster Recovery and Application Mobility. 

It is challenging to create AKS Cluster from Azure Cloud if you are not familiar to it. After the AKS Cluster is up running, we still need to install Kasten, create a sample database, create location profile, backup policies etc.. The whole process is not that simple.

![image](https://blog.kasten.io/hs-fs/hubfs/Kasten_January2020/Images/microsoft-azure-with-kasten-k10-intro-blog.png?width=1226&name=microsoft-azure-with-kasten-k10-intro-blog.png)


This script based automation allows you to build a ready-to-use Kasten K10 demo environment running on AKS in about 10 minutes. For simplicity and cost optimization, the AKS cluster will have only one worker node in the newly created vnet and subnet. This is bash shell based scripts which has been tested on Cloud Shell. Linux or MacOS terminal has not been tested though it might work as well. If you don't have an Azure account, please watch the video by Louisa below to sign up a free trial account in 5 minutes. 

# Sign up an Azure trial account
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/FN0ARvEdrjg/0.jpg)](https://www.youtube.com/watch?v=FN0ARvEdrjg)
#### Subscribe [K8s Data Management](https://www.youtube.com/channel/UCm-sw1b23K-scoVSCDo30YQ?sub_confirmation=1) Youtube Channel

# Here're the prerequisities. 
1. Go to open Azure Cloud Shell
2. Clone the github repo to your local host, run below command
````
git clone https://github.com/yongkanghe/aks-k10.git
````
3. Create Azure App Registration first
````
cd aks-k10;./createapp.sh
````
4. Optionally, you can customize the clustername, vm size, location, region, containername, etc.
````
vi setenv.sh
````

# Deploy based on your needs

| Don't have an AKS cluster | Already have an AKS cluster     | Have nothing                    |
|---------------------------|---------------------------------|---------------------------------|
| Deploy AKS only           | Deploy K10 only                 | Deploy AKS and K10              |
| ``` ./aks-deploy.sh ```   | ``` ./k10-deploy.sh ```         | ``` ./deploy.sh ```             |
| 1.Create an AKS Cluster   |                                 | 1.Create an AKS Cluster         |
|                           | 1.Install Kasten K10            | 2.Install Kasten K10            |
|                           | 2.Deploy a MySQL database       | 3.Deploy a MySQL database       |
|                           | 3.Create an Azure Blob location | 4.Create an Azure Blob location |
|                           | 4.Create a backup policy        | 5.Create a backup policy        |
|                           | 5.Kick off on-demand backup job | 6.Kick off on-demand backup job |

# Destroy based on your needs

| Destroy AKS only          | Destroy K10 only                    | Destroy AKS and K10                 |
|---------------------------|-------------------------------------|-------------------------------------|
| ``` ./eks-destroy.sh ```  | ``` ./k10-destroy.sh ```            | ``` ./destroy.sh ```                |
| 1.Remove the AKS Cluster  |                                     | 1.Remove the Resource Group         |
|                           | 1.Remove MySQL database             | + Remove AKS Kubernetes Cluster     |
|                           | 2.Remove Kasten K10                 | + Remove the disks and snapshots    |
|                           | 3.Remove Azure Blob storage bucket  | + Remove the storage account etc.   |

# To kickoff a backup job manually, run 
````
./runonce.sh
````
+ Take a snapshot of Application Components
+ Take a snapshot of Application Configurations
+ Take a snapshot of Workload MySQL
+ Export the snapshot to Azure Blob Storage

# Automate AKS creation & protection
[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/308ZOMRaRDk/0.jpg)](https://www.youtube.com/watch?v=308ZOMRaRDk)
#### Subscribe [K8s Data Management](https://www.youtube.com/channel/UCm-sw1b23K-scoVSCDo30YQ?sub_confirmation=1) Youtube Channel

# AKS Backup and Restore
https://blog.kasten.io/posts/backup-and-recovery-in-microsoft-azure-with-kasten-k10/

# Kasten - No. 1 Kubernetes Backup
https://kasten.io 

# Kasten - DevOps tool of the month July 2021
http://k10.yongkang.cloud

# Contributors

#### Follow [Yongkang He](http://yongkang.cloud) on LinkedIn, Join [Kubernetes Data Management](https://www.linkedin.com/groups/13983251) LinkedIn Group

#### Follow [Louisa He](https://www.linkedin.com/in/louisahe/) on LinkedIn, Join [Kubernetes Data Management](https://lnkd.in/gZbwVMg5) Slack Channel
