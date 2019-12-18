class profile::base{
  case $::osfamily {
   'debian': {
     include profile::base::debain
   }
   'redhat': {
     include profile::base::redhat
   }
   'windows': {
     include profile::base::windows
   }
   default: {
     fail("This profile is not compaitable with your platform")
   }
  }
}
