#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"
NUM=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "insert into users (username) values ('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'" | sed "s/ //g")
else
  GAMES_PLAYED=$($PSQL "select count(*) from games full join users using(user_id) where user_id = $USER_ID" | sed "s/ //g")
  LOWEST_GUESSES=$($PSQL "select min(number_of_guesses) from games full join users using(user_id) where user_id = $USER_ID" | sed "s/ //g")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $LOWEST_GUESSES guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
GUESSES_NUM=1
while [[ $GUESS != $NUM ]] || [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUM ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUM ]]
  then
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  let "GUESSES_NUM+=1"
done

  echo "You guessed it in $GUESSES_NUM tries. The secret number was $NUM. Nice job!"
  INSERT_GAME_RESULT=$($PSQL "insert into games (user_id, number_of_guesses) values ($USER_ID, $GUESSES_NUM)")
