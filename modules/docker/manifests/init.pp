class docker {
  file{ '/etc/yum.repos.d/centos.repo':
    ensure => file,
    source => 'puppet:///modules/docker/centos.repo',
  }
  package{ 'docker':
    ensure => installed,
    require => File['/etc/yum.repos.d/centos.repo']
  }
  service{ 'docker':
    ensure => running,
    enable => true,
    require => Package['docker']
  }
  package{ 'git':
    ensure => installed,
    require => Service['docker']
  }
  exec{ 'config':
     command => "git config --global http.sslVerify false",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     user => 'root',
     environment => [ 'HOME=/root' ],
     require => Package['git']
  }
}
