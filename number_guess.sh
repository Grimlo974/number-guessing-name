#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SAVE_GAME(){
  if [ $NUMBER_OF_GUESSES -lt $BEST_GAME ]
  then
    SAVE_RESULT=$($PSQL "update users set games_played=(games_played+1), best_game = $NUMBER_OF_GUESSES where user_id = $USER_ID;")
  else
    SAVE_RESULT=$($PSQL "update users set games_played=(games_played+1) where user_id = $USER_ID;")
  fi
}

GAME(){
  GAMES_PLAYED=$1
  NUMBER_TO_GUESS=$((1 + $RANDOM % 1000))
  echo $NUMBER_TO_GUESS
  echo -e "\nGuess the secret number between 1 and 1000:"
  NUMBER_OF_GUESSES=0
  
  while true;
  do
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
    read USER_NUMBER
    #if is not a number
    if [[ ! $USER_NUMBER =~ ^[0-9]+$ ]]
    then 
      echo -e "\nThat is not an integer, guess again:"
      continue
    else
      if [ $USER_NUMBER -eq $NUMBER_TO_GUESS ]
      then
        echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
        break
      else
        if [ $USER_NUMBER -lt $NUMBER_TO_GUESS ]
        then
          echo -e "\nIt's higher than that, guess again:"
          continue
        else
          echo -e "\nIt's lower than that, guess again:"
          continue
        fi
      fi
    fi
  done

  #Save result in database
  SAVE_GAME
}

#enter username
echo "Enter your username:"
read USERNAME

if [ ${#USERNAME} -le 22 ]
then
  USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")

  if [[ -z $USER_ID ]]
  then
    #New player welcome
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    CREATE_NEW_USER=$($PSQL "insert into users (username, best_game) values ('$USERNAME', 1000)")
    USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
    GAMES_PLAYED=0
    BEST_GAME=1000
  else
    #Player welcome
    GAMES_PLAYED=$($PSQL "select games_played from users where user_id = $USER_ID;")
    BEST_GAME=$($PSQL "select best_game from users where user_id = $USER_ID;")
    
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  #Play the game
  GAME
else
  echo -e "\nYour username can't be greater than 22."
fi

