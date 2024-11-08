#!/bin/bash

# Connect to the salon database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~ Welcome to My Salon ~~\n"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "\nHere are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Prompt for service selection
SERVICE_ID_SELECTED=""
while [[ -z $SERVICE_ID_SELECTED ]]; do
  DISPLAY_SERVICES
  echo -e "\nPlease enter the service ID you would like:"
  read SERVICE_ID_SELECTED

  # Validate service ID
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service ID. Please try again."
    SERVICE_ID_SELECTED=""
  fi
done

# Prompt for customer phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If customer doesn't exist, prompt for name and add to database
if [[ -z $CUSTOMER_ID ]]; then
  echo -e "\nIt seems you're a new customer. Please enter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
fi

# Prompt for appointment time
echo -e "\nPlease enter the time you'd like to schedule (e.g., 10:30):"
read SERVICE_TIME

# Insert appointment into appointments table
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Confirm appointment
if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
  echo -e "\nSorry, there was an error scheduling your appointment."
fi
