class profile::base::redhat {
   include motd
   create_resources('service', hiera_hash('service', {}))
   create_resources('package', hiera_hash('package', {}))
   create_resources('file', hiera_hash('file', {}))
   create_resources('user', hiera_hash('user', {}))
}
