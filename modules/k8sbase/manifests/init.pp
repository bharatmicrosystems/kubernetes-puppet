class k8sbase {
  file{ '/tmp/kube':
    ensure => directory
  }
  file{ '/etc/yum.repos.d/kubernetes.repo':
    ensure => file,
    source => 'puppet:///modules/k8sbase/kubernetes.repo',
    require => File['/tmp/kube']
  }
  package{ 'kubelet-1.16.3':
    ensure => installed,
    require => File['/etc/yum.repos.d/kubernetes.repo']
  }
  package{ 'kubeadm-1.16.3':
    ensure => installed,
    require => Package['kubelet-1.16.3']
  }
  package{ 'kubectl-1.16.3':
    ensure => installed,
    require => Package['kubeadm-1.16.3']
  }
  service{ 'kubelet':
    ensure => running,
    enable => true,
    require => Package['kubectl-1.16.3']
  }
  exec{ 'setenforce':
     command => 'setenforce 0',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/setenforce',
     require => Service['kubelet']
  }
  file{ '/tmp/kube/setenforce':
    ensure => file,
    content => '',
    require => Exec['setenforce']
  }
  exec{ 'selinuxdisable':
     command => "sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/selinuxdisable',
     require => Exec['setenforce']
  }
  file{ '/tmp/kube/selinuxdisable':
    ensure => file,
    content => '',
    require => Exec['selinuxdisable']
  }
  service{ 'firewalld':
     ensure => stopped,
     enable => false,
     require => Exec['selinuxdisable']
  }
  exec{ 'swapdisable':
     command => "sed -i '/swap/d' /etc/fstab & swapoff -a",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     onlyif => 'test `swapon --show| wc -m` -gt 0',
     require => Service['firewalld']
  }
  file{ '/etc/sysctl.d/k8s.conf':
    ensure => file,
    source => 'puppet:///modules/k8sbase/k8s.conf',
    require => Exec['swapdisable']
  }
  exec{'sysctl':
     command => "sysctl --system",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/sysctl',
     require => File['/etc/sysctl.d/k8s.conf']
  }
  file{ '/tmp/kube/sysctl':
    ensure => file,
    content => '',
    require => Exec['sysctl']
  }
  exec{'echo1':
     command => "echo 1 > /proc/sys/net/ipv4/ip_forward",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/echo1',
     require => Exec['sysctl']
  }
  file{ '/tmp/kube/echo1':
    ensure => file,
    content => '',
    require => Exec['echo1']
  } 
}
