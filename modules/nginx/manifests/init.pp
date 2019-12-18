class nginx {
  package{ 'telnet':
    ensure => installed,
  }
  package{ 'nginx':
    ensure => installed,
    require => Package['telnet']
  }
  file{ '/etc/nginx/nginx.conf':
    ensure => file,
    mode => '755',
    content => generate('/usr/bin/updateconf.sh'),
    require => Package['nginx']
  }
  exec{ 'setenforce0':
     command => "setenforce 0",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     user => 'root',
     environment => [ 'HOME=/root' ],
     creates => '/tmp/nginx/setenforce0',
     require => File['/etc/nginx/nginx.conf']
  }
  exec{ 'selinuxpermissive':
     command => "sed -i 's/enforcing/permissive/g' /etc/selinux/config",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     user => 'root',
     creates => '/tmp/nginx/setenforce0',
     environment => [ 'HOME=/root' ],
     require => Exec['setenforce0']
  }
  file { '/tmp/nginx':
    ensure => directory,
    mode => '777',
    require => Exec['selinuxpermissive']
  }
  file { '/tmp/nginx/setenforce0':
    ensure => file,
    mode => '755',
    require => File['/tmp/nginx']
  }
  service{ 'nginx':
    ensure => running,
    enable => true,
    require => File['/tmp/nginx/setenforce0']
  }
}
