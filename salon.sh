#!/bin/bash
PSQL=$(echo "psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c")

echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU(){
  echo -e "Welcome to My Salon, how can I help you?"
  SERVICES="$($PSQL "SELECT * FROM services;")"
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done
  echo -e "\n"
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[1-4]$ ]]
    then
    #ask for number
    echo -e "What's your phone number?"
      read CUSTOMER_PHONE
      #read phone and query from customers
      CHECK_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      #check if already exists
      if [[ -z $CHECK_CUSTOMER_ID ]]
        then
          #condition if empty
          echo -e "\nI don't have a record for that phone number, what's your name?"
          #get name and insert customer
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME');")
            echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
            #get time
            read SERVICE_TIME
            #insert and message
            NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
            INSERT_APPOINT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($NEW_CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

            QUERY_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
            QUERY_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
            QUERY_APPOINT=$($PSQL "SELECT time FROM appointments WHERE customer_id=$NEW_CUSTOMER_ID AND service_id=$SERVICE_ID_SELECTED;")
            echo -e "I have put you down for a $QUERY_SERVICE at $SERVICE_TIME, $QUERY_CUSTOMER."
        else
        #condition if already exists
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CHECK_CUSTOMER_ID")
        echo -e "\nWhat time would you like your color, $CUSTOMER_NAME?"
        read SERVICE_TIME
        INSERT_APPOINT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CHECK_CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
        QUERY_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
        QUERY_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE customer_id=$CHECK_CUSTOMER_ID")
        QUERY_APPOINT=$($PSQL "SELECT time FROM appointments WHERE customer_id=$CHECK_CUSTOMER_ID AND service_id=$SERVICE_ID_SELECTED")
        echo -e "\nI have put you down for a $QUERY_SERVICE at $SERVICE_TIME, $QUERY_CUSTOMER."
      fi
    else
    #return to menu
    MAIN_MENU "I could not find that service."
  fi
}

MAIN_MENU