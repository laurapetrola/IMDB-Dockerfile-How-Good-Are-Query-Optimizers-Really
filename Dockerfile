FROM postgres:15

# Install HypoPG
RUN apt-get update && apt-get install -y postgresql-15-hypopg && rm -rf /var/lib/apt/lists/*

# Database settings
ENV POSTGRES_DB=imdb
ENV POSTGRES_PASSWORD=postgres

# 1. Prepare the data directory and copy the CSVs
RUN mkdir -p /data
COPY data/*.csv /data/

# 2. Initialization scripts (numbered to guarantee logical order)
# Step 00: Enable the HypoPG and pg_trgm extensions
RUN printf 'CREATE EXTENSION IF NOT EXISTS hypopg;\nCREATE EXTENSION IF NOT EXISTS pg_trgm;\n' > /docker-entrypoint-initdb.d/00_extensions.sql

# Step 01: Create the table structure (from the subfolder)
COPY join-order-benchmark/schema.sql /docker-entrypoint-initdb.d/01_schema.sql

# Step 02: Populate the tables (from the root)
COPY import_data.sql /docker-entrypoint-initdb.d/02_import.sql

# Step 03: Create foreign keys and indexes (from the subfolder)
COPY join-order-benchmark/fkindexes.sql /docker-entrypoint-initdb.d/03_indexes.sql

# Make sure Postgres can read the CSV files
RUN chmod -R 755 /data