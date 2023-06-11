#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo -e "\n~~~ Number Guessing Game ~~~"

echo -e "\nEnter your username:"
read USERNAME

# if username doesn't exist
if [[ -z $($PSQL "SELECT username FROM players WHERE username='$USERNAME'") ]]
then
INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
echo "Welcome, $USERNAME! It looks like this is your first time here."

# if username does exist
else
GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")

PLAYER_INFO=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$USERNAME'")

echo "$PLAYER_INFO" | while read NAME BAR GAMES BAR BEST
  do
    echo "Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses."
  done

fi

# generate random number
SECRET_NUMBER=$(( RANDOM % 1001 ))

# prompt player to guess a number
echo -e "\nGuess the secret number between 1 and 1000:"
read NUMBER_GUESS
NUMBER_OF_GUESSES=0

# check to see if number is less than, equal, or more than secret number
NUMBER_CHECK(){
  NUMBER_OF_GUESSES=$(( $NUMBER_OF_GUESSES + 1 ))
  if [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read NUMBER_GUESS
    NUMBER_CHECK

  elif [[ $NUMBER_GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read NUMBER_GUESS
    NUMBER_CHECK

  elif [[ $NUMBER_GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read NUMBER_GUESS
    NUMBER_CHECK

  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
}

NUMBER_CHECK

# update games_played
GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")

# update best_game
if [[ -z $BEST_GAME ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")

elif [[ $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi
