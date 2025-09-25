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


cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>>$LOG_FILE
VALIDATE $? "Copying the code from rabbitmq repo"

dnf install rabbitmq-server -y  &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq"

systemctl enable rabbitmq-server  &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq"

systemctl start rabbitmq-server  &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq"

rabbitmqctl add_user roboshop roboshop123  &>>$LOG_FILE
VALIDATE $? "Adding the user "

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>$LOG_FILE
VALIDATE $? "Setting up the permissions"