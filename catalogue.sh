#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
USER_ID=$(id -u)

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "."  -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
PRESENT_DIRECTORY=$PWD
DOMAIN_NAME=catalogue.manidevops.fun

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

dnf module disable nodejs -y
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y
VALIDATE $? "Installing nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating root user"

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Download code to the temp file"

cd /app 

unzip /tmp/catalogue.zip
VALIDATE $? "Unzinpping the code"

npm install 
VALIDATE $? "Installing dependencies"

cp $PRESENT_DIRECTORY/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying the catalogue service"

systemctl daemon-reload
VALIDATE $? "Deamon reloading"

systemctl enable catalogue 
VALIDATE $? "Enabling the catalogue services"

systemctl start catalogue
VALIDATE $? "Startting the catalogue"

cp $PRESENT_DIRECTORY/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying the monogo repo"

dnf install mongodb-mongosh -y
VALIDATE $? "Installing the monogoDB client package"

mongosh --host $DOMAIN_NAME </app/db/master-data.js
VALIDATE $? "Loading the monogoDB"





