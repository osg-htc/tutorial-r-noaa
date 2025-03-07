# Analyazing Datasets with R

In this tutorial, we will be running an R script that analyzes
historical weather data files from the [National Oceanic and Atmospheric
Administration
(NOAA)](https://www.ncei.noaa.gov/products/land-based-station/global-historical-climatology-network-daily).
The script is designed to take in the data for a single weather station
and output a figure that summarizes temperature patterns based on the
season.

Suppose we wanted to run the analysis on multiple stations of data. One
option to tackle this problem would be a for-loop. However, a simple
for-loop has two potential issues:

-   if the analysis script gets longer, then the overall runtime will
    increase
-   if we want to analyze a large number of stations, it will take
    longer

This is where a high throughput computing approach could be beneficial.
If we can scale out and send the analysis of each weather station to a
different computer, using many at once, we can get the whole set of
stations analyzed as quickly as possible. So our list of jobs will
correspond to the list of weather stations to analyze.

## Workload Components

Before thinking about how to run a list of jobs, let\'s assemble the
components of our workload (data and software) and how they are going to
be accessed.

### Data

The data we are using is hosted on Amazon Open Data and can be accessed
using the Open Science Data Federation - a data delivery platform that
runs alongside the OSPool to help move data to and from jobs. The OSDF
URL that can be used to access the data for a particular weather station
is:

    osdf:///aws-opendata/us-east-1/noaa-ghcn-pds/csv/by_station/<weather_station_id>.csv

We have two options for accessing this data:

-   Download it in advance to this server
-   Download it as part of the job

For this example, we will download it as part of the job, so we don\'t
need to download it now.

### Script

Another part of our job will be the R script, `example.R` and related
functions (`my_functions.R`).

Note that the R script has a header at the top that will allow it to be
run directly in the job.

``` bash
head -n 1 example.R
```

It also takes in the name of the weather station as an argument:

    ./example.R USW00014837

### Software Environment

Finally, our job will need to bring along an R environment with the
packages we need. We usually recommend using containers to do this, and
there is one created for this tutorial using apptainer and the `renv` R
package. The URL to the container is provided in the submit file below.

## Building Our List of Jobs

Now we are ready to start building a list of jobs. Remember that our
list of jobs will correspond to the list of weather stations to analyze
and we want to run our R script for each weather station.

To do this, we need to make two things:

-   a list of weather stations
-   a \"template\" for the jobs we want to run.

### Creating the List

The first thing we will do, is actually make the list! That is simple,
as we already have a file with a list of all the weather stations:

``` bash
head ghcnd-stations.txt
```

We could use the whole ghcnd-stations.txt file as our list, but for
simplicity, we\'ll cut the full list down to about 10 stations.

``` bash
head -n 126040 ghcnd-stations.txt | tail -n 10 | cut -d " " -f 1 > station_list.txt 
```

``` bash
head station_list.txt
```

## Job Template

To describe the actual job we want to run, we will create an HTCondor
job submit file that will serve as a template for our list of jobs. This
file needs to include the following information:

-   **Software environment**
    -   The job needs to bring along a software environment with needed
        dependencies (R and libraries)
    -   in our example, we will use an existing container with these
        tools installed.
-   **What the job should run**
    -   The command to be executed is listed in the `executable` and
        `arguments` lines of the submit file.
    -   For our example, the executable is the `example.R` script and
        the argument is the station ID.
-   **Inputs (both scripts and data)**
    -   All the inputs needed by the executable must also be transferred
        with the jobs.
    -   We need to include both the R helper script for the code and the
        weather station data file.
-   **Outputs**
    -   HTCondor will return the output figure by default, but it will
        end up in the main directory. The `transfer_output_remaps`
        option will move the image to a `results` folder.
-   **Recording information about the job**
    -   As with many other schedulers, HTCondor provides options for
        recording the standard output and error of a running job. Note
        below that these files are organized into their own directory,
        called `logs`.
-   **Resource needs**
    -   Default resources that should be set for every HTCondor job list
        include cores, memory (RAM) and local disk on the execution
        point.
    -   For this example, we will request 1 core, 2GB of RAM and 2GB of
        disk.

Each of these items is reflected in the example submit file. Every line
of the submit file (except the last one) should be thought of as the
template for one job. At any point in this template where there is data
that will be different for each job, we\'ve placed a variable as a
placeholder \-- the variable format is `$(variable_name)`.

``` bash
cat example.sub
```

## Submitting a Test

The example above submits a list of one, defined in the queue statement
at the end of the submit file:

    queue station_id from (
        USW00014837
    )

To submit this job as a test, run:

``` bash
condor_submit example.sub
```

We can check on the status of our job in HTCondor\'s queue using:

``` bash
condor_q
```

Once completed, our images will appear in the `results` folder.

``` bash
ls -lh results
```

### Submitting a Full Job List

If our test ran, submitting the whole list of jobs is easy!! The only
thing we need to change is the last line of the submit file, from:

    queue station_id from (
        USW00014837
    )

which describes a list of one, to:

    queue station_id from station_list.txt

Which will submit a job for every item in the `station_list.txt` file we
made earlier.

**Open the `example.sub` file and make that change!**

The submission step is then the same as before:

``` bash
condor_submit example.sub
```

And we can monitor with:

``` bash
condor_q
```

Once the jobs finish running, we should be able to view any of the
images in the results directory!

``` bash
ls -lh results/
```