define k8sapps (
  String $gitUrl = '',
  String $directory = ''
  ) 
  {
  exec{ "git$directory":   
     command => "git clone $gitUrl",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     cwd => '/root',
     user => 'root',
     environment => [ 'HOME=/root' ],
     creates => "/root/$directory"
  }
  exec{ "pull$directory":
     command => "git pull",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     user => 'root',
     environment => [ 'HOME=/root' ],
     cwd => "/root/$directory",
     require => Exec["git$directory"]
  }
  exec{ "kubectl$directory":
     command => "kubectl apply -f /root/$directory",
     path     => '/usr/bin:/usr/sbin:/bin',
     provider => shell,
     user => 'root',
     environment => [ 'HOME=/root' ],
     require => Exec["pull$directory"]
  }
}
