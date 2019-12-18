class profile::kubemaster {
   class {'docker':
   }
   class {'k8sbase':
      require => Class['docker']
   }
   class {'k8smaster':
      require => Class['k8sbase']
   }
}
