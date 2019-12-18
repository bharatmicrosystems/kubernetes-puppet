class k8smaster {
  file{ '/tmp/join':
    ensure => file,
    mode => '755',
    content => generate('/usr/bin/printcpjoincommand.sh')
  }
  file{ '/tmp/join.sh':
    ensure => file,
    mode => '755',
    source => 'puppet:///modules/k8smaster/join.sh',
    require => File['/tmp/join'] 
  }
  exec{ 'join':
     command => "/tmp/join.sh",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/join',
     require => File['/tmp/join.sh']
  }
  file{ '/tmp/kube/join':
    ensure => file,
    content => '',
    require => Exec['join']
  }
}
