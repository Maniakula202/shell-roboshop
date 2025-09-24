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
        echo -e "$1..... $R FAILED $N" &>> LOG_FILE
    else
        echo -e "$2..... $G SUCCESS $N" &>> LOG_FILE
    fi 
}


cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Setting up the Mongod file"


dnf install mongodb-org -y 
VALIDATE $? "Installing MonogoDB"

systemctl enable mongod 
VALIDATE $? "Enabling MonogoDB"

systemctl start mongod 
VALIDATE $? "Starting MonogoDB"

sed -i '/127.0.0.1/ 0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing the Ports"

systemctl restart mongod
VALIDATE $? "Restarting the MongoDB"