class role::k8sworker {
   class {'profile::kubeworker':
   }
   class {'profile::unisonbase':
     require => Class['profile::kubeworker']
   }
   class {'profile::unisonsource':
     require => Class['profile::unisonbase']
   }
}

