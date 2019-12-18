class unisonbase {
  file{'/kubevolumes':
     ensure => directory,
     mode => '777'
  }
  exec{'sshkeygen':
     command => 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/root/.ssh/id_rsa.pub',
     cwd => '/tmp/kube',
     require => File['/kubevolumes'],
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  exec{'unisonget':
     command => 'wget https://www.seas.upenn.edu/~bcpierce/unison/download/releases/stable/unison-2.48.4.tar.gz',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/unison-2.48.4.tar.gz',
     cwd => '/tmp/kube',
     require => Exec['sshkeygen'],
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  exec{'unisonuntar':
     command => 'tar xvfz unison-2.48.4.tar.gz',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/src',
     cwd => '/tmp/kube',
     require => Exec['unisonget'],
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  package{'ocaml':
     ensure => installed,
     require => Exec['unisonuntar']
  }
  package{'ocaml-camlp4-devel':
     ensure => installed,
     require => Package['ocaml']
  }
  package{'ctags':
     ensure => installed,
     require => Package['ocaml-camlp4-devel']
  }
  package{'ctags-etags':
     ensure => installed,
     require => Package['ctags']
  }
  exec{'make':
     command => 'make',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/src/unison',
     cwd => '/tmp/kube/src',
     require => Package['ctags-etags'],
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  exec{'cp1':
     command => 'cp -v unison /usr/local/sbin/',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/usr/local/sbin/unison',
     cwd => '/tmp/kube/src',
     require => Exec['make'],
     user => 'root',
     environment => [ 'HOME=/root' ]
   }
  exec{'cp2':
     command => 'cp -v unison /usr/bin/',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/usr/bin/unison',
     cwd => '/tmp/kube/src',
     require => Exec['cp1'],
     user => 'root',
     environment => [ 'HOME=/root' ]
   }
  exec{'unison-fsmonitor':
     command => 'curl -L -o unison-fsmonitor https://github.com/TentativeConvert/Syndicator/raw/master/unison-binaries/unison-fsmonitor',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/tmp/kube/unison-fsmonitor',
     cwd => '/tmp/kube',
     require => Exec['cp2'],
     user => 'root',
     environment => [ 'HOME=/root' ]
  }
  file{'/tmp/kube/unison-fsmonitor':
     ensure => file,
     mode => '755',
     require => Exec['unison-fsmonitor']
  }
  exec{'cp3':
     command => 'cp -v unison-fsmonitor /usr/local/sbin/',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/usr/local/sbin/unison-fsmonitor',
     cwd => '/tmp/kube/src',
     require => File['/tmp/kube/unison-fsmonitor'],
     user => 'root',
     environment => [ 'HOME=/root' ]
   }
  exec{'cp4':
     command => 'cp -v unison-fsmonitor /usr/bin/',
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     creates => '/usr/bin/unison-fsmonitor',
     cwd => '/tmp/kube/src',
     require => Exec['cp3'],
     user => 'root',
     environment => [ 'HOME=/root' ]
   }
}

