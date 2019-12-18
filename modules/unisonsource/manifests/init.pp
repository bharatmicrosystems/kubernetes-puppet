class unisonsource (
  String $basenode = ''
)
{
  file{'/root/.unison':
     ensure => directory,
  }
  file{'/root/.unison/default.prf':
     ensure => file,
     require => File['/root/.unison'],
     source => 'puppet:///modules/unisonsource/default.prf'
  }
  exec{'sed':
     command => "sed -i 's/node01/$basenode/g' /root/.unison/default.prf",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     require => File['/root/.unison/default.prf'],
     unless => "kubectl get ns 'kubernetes-dashboard'",
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  file{'/etc/systemd/system/unison.service':
     ensure => file,
     source => 'puppet:///modules/unisonsource/unison.service',
     require => Exec['sed']
  }
  service{'unison':
     ensure => running,
     enable => true,
     require => File['/etc/systemd/system/unison.service']
  }
}
