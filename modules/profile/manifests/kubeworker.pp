class profile::kubeworker {
   class {'docker':
   }
   class {'k8sbase':
      require => Class['docker']
   }
   class {'k8sworker':
      require => Class['k8sbase']
   }
}
