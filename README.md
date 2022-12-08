# DOMETL (Python ETL Tool)
Dometl is a Python ETL package.

# Process

1. Init - Initializes the database
```
dometl -t init
```
2. Stage - Moves files into staging tables
```
dometl -t stage
```
3. Live - Runs transformations to move data from staging to live tables
```
dometl -t live
```
4. Test - Runs very simple tests on the data
```
dometl -t test
```

# How to Install & Run the Package?

Run the initialization step
```
dometl -t init -cp dometl_config
# if you don't install the package
# python -c "from dometl import run_dometl; run_dometl()" -t init -cp dometl_config
```

Run the staging step
```
dometl -t stage -ep datasets\\game_data\\daily\\20221105_g.csv -tb ST_GAME -cp dometl_config
# if you don't install the package
# python -c "from dometl import run_dometl; run_dometl()" -t stage -ep datasets\\game_data\\daily\\20221105_g.csv -tb st_game -cp dometl_config
# python -c "from dometl import run_dometl; run_dometl()" -t stage -ep datasets\\game_data\\seasons -tb st_game -cp dometl_config
```

Run the live step
```
dometl -t live -tb game -cp dometl_config
# if you don't install the package
# python -c "from dometl import run_dometl; run_dometl()" -t live -tb game -cp dometl_config
```

Run the test step
```
dometl -t test -tb game -cp dometl_config
# if you don't install the package
# python -c "from dometl import run_dometl; run_dometl()" -t test -tb game -cp dometl_config
```
The simple testing is made up of testing queries which are placed into the
config.yaml folder like below
```
tests:
  table_name: ["some_test.sql", "other_test.sql"]
```
Each table can have a set of test queries.
The queries need to be written in a way that they return 0 rows when the
test passes. If the query returns more than 0 rows the test will fail.
As a suggestion the rows that are returned should help find the root
cause of the failure.


## Configuration Folder

```
\folder
    config.yaml     # structure defined below
    db_create.sql   # custom file which creates and initializes the db
    file1.sql       # custom SQL file
    file2.sql       # custom SQL file
    file3.sql       # custom SQL file
    file4.sql       # custom SQL file
    file5.sql       # custom SQL file
```

Structure for config.yaml
```
db_credentials:
  username: ""
  password: ""
  hostname: ""
  port: ""
  db_name: ""

init_order: [
  "db_create.sql",
  "file1.sql",
  "file2.sql",
]

etl:
  table_name_1: "file3.sql"  
  table_name_2: "file4.sql"  
  table_name_3: "file5.sql"  
```

## Bonus

Run a script with psql
```
psql -U postgres -h 127.0.0.1 -d DBNAME -f path\path\file_name.sql
```

Copy CSV into a table
```
psql -U postgres -h 127.0.0.1 -d DBNAME -c "COPY table_name FROM '/path/to/csv/20221105_g.csv' WITH (FORMAT csv)"
```