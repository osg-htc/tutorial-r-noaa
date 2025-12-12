#!/bin/bash

OSDF_PREFIX=osdf:///aws-opendata/us-east-1/noaa-ghcn-pds/csv/by_station

while read id
do
  pelican object get ${OSDF_PREFIX}/${id}.csv data/
done < station_list.txt
