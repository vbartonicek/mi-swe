#!/usr/bin/env bash

# PREREQUSITIES - MySQL server has to run

# Settings
# ---------

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT=${DIR}/../output
SOURCE=${DIR}/../../source


# D2RQ tool path
D2RQ_PATH=/usr/local/d2rq-0.8.1

# DB server address
DB_SERVER=mysql://127.0.0.1

# DB name
DB_NAME=mi-swe

# DB username
DB_USER=root

# DB password
DB_PASSWORD=

# TODO: http://d2rq.org commands path
D2RQ_SERVER=http://localhost:2020/


# Municipalities
# ---------

echo "Step 1 of 3 - Processing municipalities data started"

cd ${D2RQ_PATH}

# Generate a mapping file for your database schema using the generate-mapping tool. Change into the D2R Server directory and run
if [[ -z "$DB_PASSWORD" ]]; then
  ./generate-mapping -o ${DIR}/municipalities-mapping.ttl -u ${DB_USER} jdbc:${DB_SERVER}/${DB_NAME}
else
  ./generate-mapping -o ${DIR}/municipalities-mapping.ttl -u ${DB_USER} -p ${DB_PASSWORD} jdbc:${DB_SERVER}/${DB_NAME}
fi

# Start D2R Server in background
./d2r-server ${DIR}/municipalities-mapping.ttl &

# Generate an RDF dump using the dump-rdf tool and a mapping file
${D2RQ_PATH}/dump-rdf -f TURTLE -b ${D2RQ_SERVER} ${DIR}/municipalities-mapping.ttl > ${OUTPUT}/municipalities.ttl
${D2RQ_PATH}/dump-rdf -f N-TRIPLE -b ${D2RQ_SERVER} ${DIR}/municipalities-mapping.ttl > ${OUTPUT}/municipalities.nt

# TODO: kill the D2r-server

echo "Step 1 of 3 - Dwellings municipalities processed"

# Dwellings
# ---------

echo "Step 2 of 3 - Processing dwellings data started"

tarql ${DIR}/dwellings.sparql ${SOURCE}/dwellings.csv > ${OUTPUT}/dwellings.ttl
tarql --ntriples ${DIR}/dwellings.sparql ${SOURCE}/dwellings.csv > ${OUTPUT}/dwellings.nt

echo "Step 2 of 3 - Dwellings data processed"


# Population
# ---------

echo "Step 3 of 3 - Processing population data started"

# Transform .xlsx into .csv
xlsx2csv ${SOURCE}/1300721803.xlsx > ${SOURCE}/population.csv

tarql ${DIR}/population.sparql ${SOURCE}/population.csv > ${OUTPUT}/population.ttl
tarql --ntriples ${DIR}/population.sparql ${SOURCE}/population.csv > ${OUTPUT}/population.nt

echo "Step 3 of 3 - Population data processed"
