#!/bin/bash

IP=$1
USER="wid"
PASSWD=$(sudo grep -c "^$USER:" /etc/passwd)
OS=`sudo uname -s`
IP1="10.1.1.1"
IP2="10.1.1.2"
IP3="10.1.1.3"
ALLOW1=$(sudo cat /etc/hosts.allow | grep -i $IP1 | wc -l)
ALLOW2=$(sudo cat /etc/hosts.allow | grep -i $IP2 | wc -l)
ALLOW3=$(sudo cat /etc/hosts.allow | grep -i $IP3 | wc -l)
SUDOERS=$(sudo cat /etc/sudoers | grep -i $USER | wc -l)
ALLOWCHK=$(sudo cat /etc/hosts.allow | grep -w $IP1)
SUDOERSCHK=$(sudo cat /etc/sudoers | grep -w $USER)
NOW=$(sudo date +"%d%m%Y")

user_check()
{
 USERCHK=$(sudo cat /etc/passwd | grep -w $USER)
 echo "$IP $USERCHK"
}

password_expires_check()
{
 PASSWORDCHK=$(sudo chage -l $USER | grep -w 'Password expires')
 echo "$IP $PASSWORDCHK"
}

user_create()
{
 sudo cp /etc/group /etc/group.$USER$NOW
 sudo cp /etc/passwd /etc/passwd.$USER$NOW 
 sudo /usr/sbin/useradd $USER
 sudo mkdir /home/$USER/.ssh/
 sudo chmod -R 700 /home/$USER/.ssh/
 sudo chown -R $USER:$USER /home/$USER/.ssh/
 retval=$?
 if [ $retval -eq 0 ]; then
  echo "$IP user $USER added successfully!"
  user_check
 else
  echo "$IP add user $USER Failed"
  sudo /usr/sbin/userdel -r $USER
  echo "$IP Successfully Rollback"
  exit 0
 fi
}

user_change_password()
{
 sudo echo $USER:"P@ssw0rd!" |sudo /usr/sbin/chpasswd
 retvalpass=$?
 if [ $retvalpass -eq 0 ]; then
  echo "$IP password $USER successfully! changed"
  sudo chage -m 0 -M -1 -I -1 -E -1 $USER
  retvalnever=$?
  if [ $retvalpass -eq 0 ]; then
   echo "$IP password set never expired successfully"
   password_expires_check
  else
   echo "$IP password set never expired failed"
  fi
 else
  echo "$IP change password $USER Failed"
  sudo /usr/sbin/userdel -r $USER
  echo "$IP Successfully Rollback"
  exit 0
 fi
}

sudoers_add()
{
if [ $SUDOERS -eq 0 ]; then
 echo -e "\e[1m\e[31m$IP sudoers $USER not exist\e[0m"
 sudo cp /etc/sudoers /etc/sudoers.$USER$NOW
 sudo echo $USER 'ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
 echo "sudoers successfully added"
 echo "$IP $SUDOERSCHK"
else
 echo -e "\e[1m\e[32m$IP sudoers $USER exist\e[0m"
 echo "$IP $SUDOERSCHK"
fi
}

authkey_add()
{
 sudo echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDTIv6ziCUfRwMfGGVwZoKtWLf51+OLzDwwQYXyrf8vmnY7tZB7GLWAWCmto2nsNfwBQiXBXWZ7rUfTM2og/xfTerrDexyBg1Polm0FAK9zNwDE77WqSeirCQFAQ0Q+GaJaERitrF5h+SfDBHIgoMEuWJMzCQvzaI/3WU2YB//LzcM3NckfxolxQbjMzPNweVZ6BpEOGB7a9BQh370+EFj8h9suOVPYmqV5L5M0gMrYiQ7qA2Zzf442g5AElJqU7p8EFUI4ttLnP8AlkxQvRQOWRcf11iQDAbJNF7UDh0iqYOe0cynnMUZQp1nmQD5t65L8tHp0k94P3bdN7FHvbjBL wid@widyaunix">>/home/$USER/.ssh/authorized_keys
 retvalauth=$?
 if [ $retvalauth -eq 0 ]; then
  PUBKEYCHK=$(grep $USER /home/$USER/.ssh/authorized_keys)
  PERMISSIONCHK=$(ls -lah /home/$USER/.ssh/authorized_keys | grep $USER)
  sudo chown $USER:$USER /home/$USER/.ssh/authorized_keys
  sudo chmod 600 /home/$USER/.ssh/authorized_keys
  sudo echo "$IP Authorized_keys added successfully"
  sudo echo "$IP $PUBKEYCHK"
  sudo echo "$IP $PERMISSIONCHK"
 else
  echo "$IP authorized_keys failed added"
  exit 0
 fi
}

allow_add()
{
if [ $ALLOW1 -eq 0 ] && [ $ALLOW2 -eq 0 ] && [ $ALLOW3 -eq 0 ]; then
 echo -e "\e[1m\e[31m$IP at hosts.allow not exist\e[0m"
 sudo cp /etc/hosts.allow /etc/hosts.allow.$USER$NOW
 sudo echo  "sshd : $IP1, $IP2, $IP3" >> /etc/hosts.allow
 echo "$IP host.allow added successfully"
 echo "$IP $ALLOWCHK"
else
 echo -e "\e[1m\e[32m$IP at hosts.allow exist\e[0m"
 echo "$IP $ALLOWCHK"
fi
}

#######################################################################################

if [ "${OS}" = "Linux" ] ; then
 if [ $PASSWD -eq 0 ]; then
  echo -e "\e[1m\e[31m$IP user $USER not exist\e[0m"
  user_create
  user_change_password
  sudoers_add
  authkey_add
  allow_add
 else
  echo -e "\e[1m\e[32m$IP user $USER exist\e[0m"
  user_check
  PUBKEY=$(sudo grep $USER /home/$USER/.ssh/authorized_keys | wc -l)	
  if [ $PUBKEY -eq 0 ]; then
   echo -e "\e[1m\e[31m$IP authorized_key not exist\e[0m"
   authkey_add
  else
   echo -e "\e[1m\e[32m$IP authorized_key exist\e[0m"
   PUBKEYCHK=$(grep $USER /home/$USER/.ssh/authorized_keys)
   PERMISSIONCHK=$(ls -lah /home/$USER/.ssh/authorized_keys | grep $USER)
   echo "$IP $PUBKEYCHK"
   echo "$IP $PERMISSIONCHK"
   password_expires_check
  fi
  sudoers_add
  allow_add
 fi
fi
