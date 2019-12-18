class k8sworker {
  file{ '/tmp/join.sh':
    ensure => file,
    mode => '755',
    content => generate('/usr/bin/printjoincommand.sh')
  }
  exec{'join':
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

