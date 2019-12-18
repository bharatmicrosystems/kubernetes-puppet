out=$(sudo ssh -o StrictHostKeyChecking=no root@master01 '( kubeadm token create --print-join-command )' && echo '--control-plane --certificate-key ')
sudo ssh -o StrictHostKeyChecking=no root@master01 '( kubeadm init phase upload-certs --upload-certs )' | tail -1> /tmp/out.txt
b=$(cat /tmp/out.txt)
echo $out$b|tr '\n' ' '
