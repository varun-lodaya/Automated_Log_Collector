#!/bin/bash

######################################################################
# Template to collect selective logs from required servers
######################################################################

#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`

#Initialize variables to default values.
days=1
destination=/data2
log_type=""
date=`date +"%m-%d-%Y"`
#controllers=('pocsdnash20011.prod.symcpe.net', 'pocsdnash20012.prod.symcpe.net', 'pocsdnash20013.prod.symcpe.net', 'pocsdnash20014.prod.symcpe.net', 'pocsdnash20015.prod.symcpe.net')
controllers=('pocsdnash20012.prod.symcpe.net' 'pocsdnash20013.prod.symcpe.net' 'pocsdnash20014.prod.symcpe.net')

#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`

#Help function
function HELP {
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}.${NORM}"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "${REV}-t${NORM}  --Time in days you wanna collect logs for. Default is ${BOLD}${days}${NORM}."
  echo "${REV}-l${NORM}  --Type of logs you want to collect. Default is ${BOLD}All${NORM}."
  echo "${REV}-d${NORM}  --Destination directory where you want to copy the log. Default is ${BOLD}${destination}${NORM}."
  echo "${REV}-u${NORM}  --Username for doing all the operations."
  echo "${REV}-p${NORM}  --User's password."
  echo "${REV}-k${NORM}  --User's private key. Currently non-functional, for future use."
  echo -e "${REV}-h${NORM}  --Displays this help message. No further functions are performed."\\n
  echo -e "Example 1: ${BOLD}$SCRIPT -t 2 -l contrail-api -u foo -p bar${NORM}"
  echo -e "Example 2: ${BOLD}$SCRIPT -t 1 -l ifmap${NORM}"\\n
  exit 1
}

### Start getopts code ###

#Parse command line flags
#If an option should be followed by an argument, it should be followed by a ":".
#Notice there is no ":" after "h". The leading ":" suppresses error messages from
#getopts. This is required to get my unrecognized option code to work.

while getopts :t:l:d:u:p:k:h FLAG; do
  case $FLAG in
    t)  #set option "d"
      days=$OPTARG
      ;;
    l)  #set option "l"
      log_type=$OPTARG
      ;;
    d)  #set option "d"
      destination=$OPTARG
      ;;
    u)  #set option "u"
      user=$OPTARG
      ;;
    p)  #set option "p"
      password=$OPTARG
      ;;
    k)  #set option "k"
      private_key=$(cat $OPTARG)     
      ;;
    h)  #show help
      HELP
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      HELP
      #If you just want to display a simple error message instead of the full
      #help, remove the 2 lines above and uncomment the 2 lines below.
      #echo -e "Use ${BOLD}$SCRIPT -h${NORM} to see the help documentation."\\n
      #exit 2
      ;;
  esac
done

shift $((OPTIND-1))  #This tells getopts to move on to the next argument.

if [ -z $user ]; then
    echo "Please provide your user_name."
    read user;
fi

if [ -z $password ]; then
    echo "Please provide your password."
    stty -echo
    read password;
    stty echo
fi

### End getopts code ###
echo "Collecting $log_type logs for last $days days with username $user and saving them in $destination directory" 

### Main loop to process files ###

#This is where your main file processing will take place
for controller in ${controllers[@]};
do
    controller_name=$(echo $controller | cut -d'.' -f1)
    directory_name=$controller_name-$date
    if [ -d $destination/$directory_name ]; then
        sudo rm -rf $destination/$directory_name
    fi
    /home/varun_lodaya/ssh_helper.sh $controller $user $password $directory_name $days $log_type

    # Now copy over the folder locally
    sshpass -p $password scp -r $user@$controller:/tmp/${directory_name}.tar.gz $destination
    #scp -i /home/$user/.ssh/id_rsa -r $user@$controller:/tmp/${directory_name}.tar.gz $destination
    echo "Done copying $controller_name log"    

done
### End main loop ###

exit 0
