class k8smasterleader (
  String $dashboardDomain = ''
)
{
  exec{ 'kubeadminit':
     command => "kubeadm init --control-plane-endpoint masterlb:6443 --upload-certs --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/kubeadminit',
  }
  file{ '/tmp/kube/kubeadminit':
    ensure => file,
    content => '',
    require => Exec['kubeadminit']
  }
  file{ '/root/.kube':
    ensure => directory,
    owner => root,
    group => root,
    require => File['/tmp/kube/kubeadminit']
  }
  file{ '/root/.kube/config':
    ensure => present,
    owner => root,
    group => root,
    require => File['/root/.kube']
  }
  exec{ 'copy':
     command => "cp /etc/kubernetes/admin.conf /root/.kube/config",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/copy',
     require => File['/root/.kube/config']
  }
  file{ '/tmp/kube/copy':
    ensure => file,
    content => '',
    require => Exec['copy']
  }
  exec{ 'weave':
     command => 'kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d \'\n\')"',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/weave',
     require => File['/root/.kube/config']
  }
  file{ '/tmp/kube/weave':
    ensure => file,
    content => '',
    require => Exec['weave']
  }
  file{ '/root/certs':
    ensure => directory,
    require => File['/tmp/kube/weave']
  }
  exec{ 'genrsa':
     command => "openssl genrsa -out /root/certs/dashboardrsa.key 2048",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/root/certs/dashboardrsa.key',
     require => File['/root/.kube/config']
  }
  exec{ 'rsa':
     command => "openssl rsa -in /root/certs/dashboardrsa.key -out /root/certs/dashboard.key",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/root/certs/dashboard.key',
     require => Exec['genrsa']
  }
  exec{ 'req':
     command => "openssl req -sha256 -new -key /root/certs/dashboard.key -out /root/certs/dashboard.csr -subj \"/CN=$dashboardDomain\"",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/root/certs/dashboard.csr',
     require => Exec['rsa']
  }
  exec{ 'x509':
     command => "openssl x509 -req -sha256 -days 365 -in /root/certs/dashboard.csr -signkey /root/certs/dashboard.key -out /root/certs/dashboard.crt",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/root/certs/dashboard.crt',
     require => Exec['req']
  }
  exec{ 'ns':
     command => "kubectl create ns 'kubernetes-dashboard'",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     require => Exec['x509'],
     unless => "kubectl get ns 'kubernetes-dashboard'",
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  exec{ 'kubecerts':
     command => "kubectl -n kubernetes-dashboard create secret generic kubernetes-dashboard-certs --from-file=/root/certs",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     require => Exec['ns'],
     unless => "kubectl -n 'kubernetes-dashboard' get secret kubernetes-dashboard-certs",
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
}
