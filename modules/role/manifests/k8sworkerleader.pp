class role::k8sworkerleader {
   class {'profile::kubeworker':
   }
   class {'profile::unisonbase':
     require => Class['profile::kubeworker']
   }

}

