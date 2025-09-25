#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER_ID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "."  -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ]; then
    echo "Error:: Please use the root previlege to run this script" | tee -a $LOG_FILE
    exit 1
fi 


VALIDATE(){
    if [ $? -ne 0 ]; then 
        echo -e "$1..... $R FAILED $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2..... $G SUCCESS $N" | tee -a $LOG_FILE
    fi 
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld
VALIDATE $? "Enabling mysql"

systemctl start mysqld  
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up root password"

