#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment ~~~~~\n"

MAIN_MENU() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id") 
  echo "Choose a service:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME BAR
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SERVICE_MENU "1" ;;
    2) SERVICE_MENU "2" ;;
    3) SERVICE_MENU "3" ;;
    4) EXIT ;;
    *) MAIN_MENU "Please enter a valid option." ;;
  esac 
}

SERVICE_MENU() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE 
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME

    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  # get customer id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  #get service id
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$1")

  #get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
 
  # get appointment time
  echo -e "\nWhen would you like to schedule your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') appointment?"
  read SERVICE_TIME

  #insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
 
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
  EXIT    
}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

MAIN_MENU
