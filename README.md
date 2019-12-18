# kubernetes-puppet
This is a Puppet Repository for Setting up a multi master multi worker node kubernetes cluster from scratch. This would setup a 3 node, 3 master cluster with a kubernetes dashboard, ingress controller, metrics server, and an nginx load balancer.
## Setup the infrastructure
### Specifications
1. 1 puppet master node puppet-master
2. 3 master nodes master01 master02 and master03 on 3 DCs for HA
3. 3 worker nodes node01 and node02 and node03 on 3 DCs for HA. You may need to add multiple nodes in that case just follow the steps as mentioned.
4. 1 Nginx load balancer to load balance the master API servers and also the Nginx ingress controllers running on worker nodes

To set up VMs using Terraform on GCP refer to https://github.com/bharatmicrosystems/gcp-terraform/tree/master/dev/kubernetes

Ensure the following:

1. All nodes can talk to each other on all ports,
2. User root from node02 and node03 can ssh into node01 passwordless
3. User root from puppet-master can ssh passwordless into master01.

In order to set that up passwordless ssh follow the below steps
```
# On source node
ssh-keygen -t rsa
cat /root/.ssh/id_rsa.pub
# On target node
vim /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config;
systemctl restart sshd
```
## Setup Puppet Master
SSH into the Puppet Master
```
sudo su -
yum install -y git
git clone https://github.com/bharatmicrosystems/kubernetes.git
cd kubernetes/puppet
sh -x master_setup.sh
```
This will setup the puppet master on the master node. You can then go to /etc/puppetlabs/code/environments/production/data/roles/k8smasterleader.yaml and setup the correct dashboard domain on the following section of the file instead of the default kubedashboard.example.com domain
```
profile::kubemasterleader::dashboardDomain: 'kubedashboard.example.com'
```
You can also modify the apps section of the yaml file to include additonal apps that you might want to run in the kubernetes cluster. This will ensure that Puppet manages the kubernetes manifests for the application and any update required because of any change in the source code. The manifest currently points to the github repository hosted by this project but you are free to modify it to include apps from any git repository. Please note that the yaml in the individual repository point to the example.com domain. You can fork the repo into another one and make changes to add your custom domain on which the apps need to run.
```
profile::kubeapps:
  ingress:
    gitUrl: 'https://github.com/bharatmicrosystems/kubernetes.git'
    directory: 'kubernetes/ingress'
```
## Setup Load Balancer
SSH into the masterlb node
```
sudo su -
yum install -y git
git clone https://github.com/bharatmicrosystems/kubernetes.git
cd kubernetes/puppet
sh -x agent_setup.sh loadbalancer
puppet agent -t
```
On the puppet master sign the masterlb certificate by running 
```
puppetserver ca sign --certname masterlb
```
Then go back to the masterlb node and run the following
```
puppet agent -t
```
## Setup Kubernetes Master node
SSH into the master01 node
```
sudo su -
yum install -y git
git clone https://github.com/bharatmicrosystems/kubernetes.git
cd kubernetes/puppet
sh -x agent_setup.sh k8smasterleader
puppet agent -t
```
On the puppet master sign the master01 certificate by running 
```
puppetserver ca sign --all
```
Then go back to the master01 node and run the following
```
puppet agent -t
```
SSH into the master02 and master03 nodes
```
sudo su -
yum install -y git
git clone https://github.com/bharatmicrosystems/kubernetes.git
cd kubernetes/puppet
sh -x agent_setup.sh k8smaster
puppet agent -t
```
On the puppet master sign the certificate by running 
```
puppetserver ca sign --all
```
Then go back to the master02 and master03 nodes and run the following
```
puppet agent -t
```
SSH into the worker nodes
```
sudo su -
yum install -y git
git clone https://github.com/bharatmicrosystems/kubernetes.git
cd kubernetes/puppet
sh -x agent_setup.sh k8sworker
puppet agent -t
```
Go to puppet-master and sign the certificate
```
puppetserver ca sign --all
```
Go to node again
```
puppet agent -t
```
On the master01 node
```
kubectl get nodes
```
It should list all the master and agent nodes.
