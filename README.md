# Baskpipe (Basketball Data Pipeline)
Data pipeline for basketball data.

## What does it do?

....

## Prerequisites

### Python
Intall python requirements.
```
pip install -r requirements.txt
```

### Docker
Make sure you have a docker installation on your environment.

### Setup Airflow
```
# if on a unix machine run below
# echo -e "AIRFLOW_UID=$(id -u)" > .env

mkdir -p ./dags ./logs ./plugins 
docker-compose up airflow-init
docker-compose up
# to run commands in the container
# docker exec <process id> airflow version 

# shutdown airflow
docker-compose down
```
Access Airflow here: http://localhost:8080/

#### Airflow Connections
To run this project you will need to create a connection in Airflow UI.
The connection to the DW (data warehouse - postgres db).
- conn id: postgresdw
- conn type: postgres
- schema: dw
- username: postgres
- password: postgres
- host: postgres-dw (if running via the included docker-compose.yaml)
- port 5432 (becuase both airflow and the dw are on docker, else you need 5431)

## How to Run?

This section describes how to get use this repositrory.

## Project Structure
```
\dags --> holds airflow DAGS
\plugins --> holds Airflow plugins (custom operators, etc.)
\notebooks --> experimental code and data exploration
\scripts --> scripts to help with dev and setup
```





