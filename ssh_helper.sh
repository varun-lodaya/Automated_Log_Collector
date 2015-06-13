#!/usr/bin/expect

set user [lindex $argv 0]
set password [lindex $argv 1]
set host [lindex $argv 2]
set directory_name [lindex $argv 3]
set days [lindex $argv 4]
set prompt ":|#|\\\$"

spawn ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -q $user@$host
expect "password:" { send "$password\r" }
expect "$prompt " { send "sudo su\r" }
expect "password: " { send "$password\r" }
expect "$prompt " { send "rm -rf /home/$user/$directory_name\r" }
expect "$prompt " { send "mkdir -p /home/$user/$directory_name\r" }
expect "$prompt " { send "find /var/log/contrail/* -mtime $days -exec cp {} /home/$user/$directory_name \\;\r" }
expect "$prompt " { send "cd ..\r" }
expect "$prompt " { send "tar -zcvf /home/$user/${directory_name}.tar.gz /home/$user/$directory_name\r" }
expect "$prompt " { send "exit\r" }

