#!/usr/bin/expect
set host [lindex $argv 0]
set user [lindex $argv 1]
set password [lindex $argv 2]
set directory_name [lindex $argv 3]
set days [lindex $argv 4]
set log_type [ lindex $argv 5]
set prompt ":|#|\\\$"

spawn ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -q $user@$host
expect "password:" { send "$password\r" }
expect "$ " { send "sudo su\r" }
expect "password " { send "$password\r" }
expect "# " { send "rm -rf /tmp/$directory_name\r" } 
expect "# " { send "mkdir -p /tmp/$directory_name\r" }
expect "# " { send "find /var/log/contrail/* -mtime -$days -type f \\( -iname \"$log_type*\" ! -iname \"*analytics*\" ! -iname \"*webui*\" ! -iname \"*discover*\" ! -iname \"*nodemgr*\" ! -iname \"*collector*\" \\) -exec cp {} /tmp/$directory_name \\;\r"}
#expect "# " { send "find /var/log/contrail/* -mtime $days -exec cp {} /tmp/$directory_name \\;\r" }
expect "# " { send "cd /tmp\r" }
expect "# " { send "tar -zcvf ${directory_name}.tar.gz ${directory_name}\r" }
expect "# " { send "exit\r" }

 

