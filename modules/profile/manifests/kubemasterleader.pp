class profile::kubemasterleader (
   $dashboardDomain = lookup('profile::kubemasterleader::dashboardDomain', {value_type => String})
)
{
   class {'docker':
   }
   class {'k8sbase':
      require => Class['docker']
   }
   class {'k8smasterleader':
      dashboardDomain => $dashboardDomain,
      require => Class['k8sbase']
   }
}
