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
DOMAIN_NAME=mongodb.manidevops.fun

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

dnf module disable nodejs -y  &>>$LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling nodejs20"

dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "Installing nodejs"


id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating root cart"
else
    echo -e "User already existing.... $Y SKIPPING $N" | tee -a $LOG_FILE
fi



mkdir -p /app  &>>$LOG_FILE
VALIDATE $? "Creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Download code to the temp file"

cd /app 
rm -rf /app/*  &>>$LOG_FILE
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzinpping the code"

npm install  &>>$LOG_FILE
VALIDATE $? "Installing dependencies"

cp $PRESENT_DIRECTORY/cart.service /etc/systemd/system/cart.service  &>>$LOG_FILE
VALIDATE $? "Copying the cart services"

systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "Reloading the nodejs"

systemctl enable cart   &>>$LOG_FILE
VALIDATE $? "Enabling the nodejs"

systemctl start cart  &>>$LOG_FILE
VALIDATE $? "Starting the nodejs"

