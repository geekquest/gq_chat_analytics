# Analytics on chats in various GQ forums

## Setting up environment

1. Install [duckdb](https://duckdb.org/docs/installation/?version=stable&environment=cli&platform=linux&download_method=package_manager)
2. Ensure you have [python](https://python.org) installed
3. Install [poetry](https://python-poetry.org) (python dependency manager)
    ```sh
    $ pip install poetry
    ```
4. Install project dependencies
    ```sh
    $ poetry install
    ```
## Chats extract/load

1. Export chats from the whatsapp group (only need the .txt file containing messages)
2. Seed chat data
    ```sh
    poetry shell # Activates virtualenv
    python load_seed_data.py < /path/to/chats-export.csv
    cd gq_transformations
    dbt seed
    ```
3. Run data transformations
    ```sh
    poetry shell # If you are not already in a virtualenv
    cd gq_transformations
    dbt run
    dbt test # Optional: execute to check if the data is okay
    ```

## Explore the data

- Open database file with duckdb
    ```sh
    cd gq_transformations
    duckdb gq_analytics.db
    ```
- Browse available datasets
    ```sh
    .tables # Lists all tables in current schema
    .schema # Browse DDL
    SELECT DISTINCT schema_name FROM information_schema.schemata; # Lists all schemas
    ```
- There are two schemas `main_landing` and `main` of interest.
  `main_landing` contains the seeded raw data and `main` contains
  the processed data. In `main` there are three kinds of datasets.
  fact, dimension, and reporting datasets. The first two provide
  the main building blocks for the reporting datasets. The reporting
  datasets are the primary entry points for consumers of reports.

  ```sql
  -- Get the daily top 5 topics
  select * from report_topic_rankings where rank <= 5 order by date desc, rank limit 40;

  -- Get the all time topic rankings
  select topic, sum(total_mentions) from report_topic_rankings order by sum(total_mentions) desc;

  -- Get the daily top member
  select date, rank, sender, total_messages from report_member_rankings where rank = 1 order by date asc, rank limit 40;

  -- There is more you can do, explore!!!
  ```
- If you want to modify or add more reports see
  [this directory](./gq_transformations/models/whatsapp).

