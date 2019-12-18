class role::k8smasterleader {
   class {'profile::kubemasterleader':
   }
   class {'profile::kubeapps':
     require => Class['profile::kubemasterleader']
   }
}

