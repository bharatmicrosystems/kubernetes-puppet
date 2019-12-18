class profile::kubeapps (
  String $gitUrl = '',
  String $directory = ''
  ) {
   $apps = lookup('profile::kubeapps', Hash, 'deep', undef)
   $apps.each | $app | {
    # Get the app attributes.
    $gitUrl = $app[1][gitUrl]
    $directory = $app[1][directory]
    k8sapps {"$directory":
       gitUrl => $gitUrl,
       directory => $directory
    }
  }
}
