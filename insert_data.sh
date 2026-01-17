#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --quiet --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

DB_USER="freecodecamp"
DB_NAME="worldcup"
GAMES_CSV_FILE="games.csv"
TEAMS_TABLE_NAME="teams"

# Step 1: Read the CSV file and insert data into teams and games
cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals; do
    # Skip header
    if [[ $year == "year" ]]; then
        continue
    fi

    # Insert teams (winner and opponent) if they are not already in the database
    for team in "$winner" "$opponent"; do
        $PSQL "INSERT INTO $TEAMS_TABLE_NAME (name) VALUES ('$team') ON CONFLICT (name) DO NOTHING;"
    done

    # Insert game data
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    SELECT
        $year,
        '$round',
        (SELECT team_id FROM $TEAMS_TABLE_NAME WHERE name = '$winner'),
        (SELECT team_id FROM $TEAMS_TABLE_NAME WHERE name = '$opponent'),
        $winner_goals,
        $opponent_goals;"

done # < <(tail -n +2 "$GAMES_CSV_FILE")  # Skip the header line

