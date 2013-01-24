#!/bin/bash

##Function name: initial_menu
##Inputs: NONE
##Called from: get_option() call_case()
##Calls: get_option()
##Comments: This function will print the user interacting screen.

initial_menu() {
  
	echo -e "\n"
	echo "MAIN MENU"
	echo "Select an option between 1 to 8"
	echo "1. Change Password"
	echo "2. See the disk space"
	echo "3. Login to other box using ssh"
	echo "4. Show all Service running"
	echo "5. Show all ports opened"
	echo "6. Show all java apps running"
	echo "7. Facility to kill a app"
	echo "8. Exit"
	get_option 
}

##Function name: get_option
##Inputs: option
##Called from: initial_menu () call_case ()
##Calls: initial_menu ()
##Comments: This function will get option from user
##Will not accept any values other than between 1 to 8

get_option() {
	echo -e "\n"
	echo -n "Enter an option: "
	read option
	if [ x"$option" != x ] ; then
		if (( $option < 1 || $option > 8 )) ; then
			echo -e "\nEntered value out of Range..Try again!"
			initial_menu
		else 
			call_case $option
		fi
	else
		echo -e "\nYou have entered a wrong choice"
		initial_menu
	fi
}
		
##Function name:change_passwd
##Inputs:Username, Password
##Called from: call_case ()
##Calls: initial_menu ()
##Comments: Gets username and password as input.
##Validates the input value and change the password if userID exists

change_passwd() {

	echo -n "Enter the Username : "
	read username
	echo -n "Enter the Password : "
	read -s pass
	if [[ -z $username || -z $pass ]] ; then
		echo -e "\nUsername or Password should not be Blank..Try again"
		initial_menu
	else
		id -a $username &> /dev/null
		if [ $? -eq 0 ]; then
			echo $pass | passwd --stdin $username &> /dev/null
				if [ $? -eq 0 ]; then
					echo -e "\nPassword has been changed for user $username"
				else
					echo -e "\nUnable to change password. Please try manually"
				fi
		else
			echo -e "\nUser: $username not exising on the server"
		fi
	fi
	sleep 2
}

##Function name:kill_app
##Inputs: Application Process Name
##Called from: call_case ()
##Calls: Nil
##Comments: Gets the application process name and validates the variable is non empty.
##Perform the kill operation and validates

kill_app () {	
	echo -e "\n"
	echo -n "Enter the Application Process Name:"
        read app
	if [ -z $app ]; then
		echo -e "\nApplication Name should not be blank"
	   else
           	ps -ef | grep -i $app | grep -v grep &> /dev/null
           if [ $? -ne 0 ]; then
           	echo -e "\nUnable to locate any of $app processes."
	   	else
	   	echo -e "\nKilling the application processes..."
	   	sleep 1
           	pkill $app
	   	ps -ef | grep -i $app | grep -v grep &> /dev/null
	   	if [ $? -ne 0 ]; then
			echo -e "\nKilled the Application Successfully."
        	else
			echo -e "\nUnable to kill the application. Manual intervention required"
			sleep 1
		fi
 	    fi
	fi
}

##Function name:remote_ssh
##Inputs: Hostname /IP and Username
##Called from: call_case ()
##Calls: Nil
##Comments: Gets the hostname/IP and usernames and validates if any of the input is blank
##Performs ssh connection if both the inputs are not blank

remote_ssh () {
	echo -n "Enter hostname or IP address of remote server: "
	read hostip
	echo -n "Enter the Username: "
	read remoteuser
	if [[ -z $hostip  || -z $remoteuser ]]; then
		echo -e "\nHostname/IP (or) Username should not be blank"
		else
			ssh $remoteuser@$hostip
	fi
}

##Function name:show_java
##Inputs: Nil
##Called from: call_case ()
##Calls: Nil
##Comments: Checks java processes using ps command and displays the output

show_java () {
	ps -ef | grep -i java | grep -v grep &> /dev/null
	if [ $? -eq 0 ]; then
		echo -e "\nJAVA Application Running and the processes are:"
		ps -ef | grep -i java
	else
		echo -e "\nNo JAVA processes running on the server."
	fi
}
		
##Function name:call_case
##Inputs: Nil
##Called from: get_option
##Calls:change_passwd () initial_menu () remote_ssh () show_java () kill_app ()
##Comments: Using case invokes each function for each option choosed in initial menu

call_case(){
case "$option" in 
	1) change_passwd 
	;;

	2) echo -e "\nDisk Space Usage:"
           df -h
	   initial_menu
        ;;

	3) remote_ssh
	;;

	4) echo -e "\nServices Currently Running on the server:"
           ps -ef
        ;;

	5) netstat -plant
        ;;
	
	6) show_java
	;;

	7) kill_app
	;;

	8) echo -e "\nExiting.....Bye"
		exit 0
	;;

esac
initial_menu
}

clear
initial_menu
