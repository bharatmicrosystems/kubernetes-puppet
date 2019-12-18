class profile::unisonsource
(
   $basenode = lookup('profile::unisonsource::basenode', {value_type => String})
) 
{
   class {'unisonsource':
     basenode => $basenode
   }
}
