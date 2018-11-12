#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

OUTPUT=${DIR}/../output
SOURCE=${DIR}/../../source

# DB server address
DB_SERVER = mysql://127.0.0.1

# DB name
DB_NAME = mi-swe

# DB username
DB_USER = root

# DB password
DB_PASSWORD = ''

# TODO: http://d2rq.org commands path
D2RQ_SERVER = http://localhost:2020/


# Municipalities
# ---------

# Generate a mapping file for your database schema using the generate-mapping tool. Change into the D2R Server directory and run
sudo ./generate-mapping -o municipalities-mapping.ttl -u ${DB_USER} -p ${DB_PASSWORD} jdbc:${DB_SERVER}{}${DB_NAME}

# Start D2R Server
d2r-server mapping.ttl

# Generate an RDF dump using the dump-rdf tool and a mapping file
sudo ./dump-rdf -f N-TRIPLE -b ${D2RQ_SERVER} municipalities-mapping.ttl > ${OUTPUT}/municipalities.nt


# Dwellings
# ---------

tarql -d ";" ${DIR}/dwellings.sparql ${SOURCE}/dwellings.csv > ${OUTPUT}/dwellings.ttl
tarql -d ";" --ntriples ${DIR}/dwellings.sparql ${SOURCE}/dwellings.csv > ${OUTPUT}/dwellings.nt


# Population
# ---------

# TODO: Add transformation from .xlxs to .csv

tarql -d ";" ${DIR}/population.sparql ${SOURCE}/population.csv > ${OUTPUT}/population.ttl
tarql -d ";" --ntriples ${DIR}/population.sparql ${SOURCE}/population.csv > ${OUTPUT}/population.nt
