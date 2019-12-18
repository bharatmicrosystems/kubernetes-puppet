class motd ($welcomeMessage){
  file {'/etc/motd':
         content => "$welcomeMessage
My OS family: $osfamily
My Hostname: ${hostname}
"
       }
}
