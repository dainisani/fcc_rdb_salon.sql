#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU() {
  # If MAIN_MENU is called with an argument
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to My Salon, how can I help you?" 

  SERVICES=$($PSQL "SELECT * FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  echo "Please select one of the above services."
  read SERVICE_ID_SELECTED

  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"

  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_PHONE_EXIST=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_PHONE_EXIST ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME

      ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE'")

      BOOK_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      echo -e "\nWhat time would you like your $SERVICE, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name = '$SERVICE'")

      BOOK_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

    fi

  fi

}

MAIN_MENU
