# README

Introduction to using the OSDF.

Example usage for analyzing climate data using R.

Expects the data to come from the [NOAA Global Historical Climatology Network](https://www.ncei.noaa.gov/metadata/geoportal/rest/metadata/item/gov.noaa.ncdc:C00861/html).

## Accessing the data via the OSDF

The GHCN data set is available via Amazon AWS S3, at 

```
https://noaa-ghcn-pds.s3.amazonaws.com/
```

To access this data in this bucket via the OSDF, we need to know the "namespace prefix" of this dataset within the OSDF.

The OSDF is already connected to AWS under the `/aws-opendata` prefix. 
The GHCN website shows the data is in the "US East 1" part of AWS, so we'll extend the OSDF namespace prefix to
`/aws-opendata/us-east-1`.
From the above link, we see that the GHCN dataset is linked in the AWS under `noaa-ghcn-pds`, so the full prefix to the
dataset in the OSDF is `/aws-opendata/us-east-1/noaa-ghcn-pds/`.

We can't (currently) list the objects in this location, but you can browse the AWS index link 
([https://noaa-ghcn-pds.s3.amazonaws.com/](https://noaa-ghcn-pds.s3.amazonaws.com/)) to see the files available.

In the top "level" of the dataset are several readme files.
Let's get the list of stations that are contained in the dataset, so we can identify what files we want to download.

The file `ghcnd-stations.txt` contains the desired list. 
This is the "object name" that we want to fetch using the OSDF.
We combine the "namespace prefix" and the "object name" together to get the desired OSDF link:
`/aws-opendata/us-east-1/noaa-ghcn-pds/ghcnd-stations.txt`.


To download the file, we use the Pelican client with the OSDF URL:

```
pelican object get osdf:///aws-opendata/us-east-1/noaa-ghcn-pds/ghcnd-stations.txt ./
```

## Identify station

There are a lot of stations listed (over 120,000!!).
Search for the one that you are interested in.

For this example, we will look at the data for the airport in Madison, WI, which shows up in the list as

```
USW00014837  43.1406  -89.3453  261.8 WI MADISON DANE CO RGNL AP                72641
```

Here, the station ID is `USW00014837`.

## Download station data

The per-station data is collected under `csv/by_station` and the filenames use the syntax `<STATION ID>.csv`. 

To download the station data, we can use the following command:

```
pelican object get osdf:///aws-opendata/us-east-1/noaa-ghcn-pds/csv/by_station/USW00014837.csv
```

