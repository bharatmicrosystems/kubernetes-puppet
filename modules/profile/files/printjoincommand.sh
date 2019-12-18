sudo ssh -o StrictHostKeyChecking=no root@master01 '( kubeadm token create --print-join-command )'
