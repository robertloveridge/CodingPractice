#!/bin/bash

: <<=cut
=pod

=head1 Name

   csv_splitter.sh

=head1 Synopsis

   ./csv_splitter <original_file.csv> <new_filename> <line_count>

=head1 Description

A script that allows you to split your original CSV file into new files
based off of line count. For example, if you wanted to only have files with
10 rows in but your CSV had 50, you could run:

  ./csv_splitter my_file_with50.csv my_smaller_file 10

The above would produce 5 files with the names and retain column headers.

  my_smaller_file1.csv
  my_smaller_file2.csv
  my_smaller_file3.csv
  my_smaller_file4.csv
  my_smaller_file5.csv

=head1 Author

Robert Loveridge

=cut

FILENAME=$1                # CSV filename from args
HDR=$(head -1 $FILENAME)   # Pick up CSV header line to apply to each file
split -l $3 $FILENAME xyz  # Split the file into chunks of xlines each
n=1
for f in xyz*              # Go through all newly created chunks
do
   echo $HDR > $2${n}.csv  # Write out header to new file called "X(n).csv"
   cat $f >> $2${n}.csv    # Add in the Xnumber lines from the "split" command
   rm $f                   # Remove temporary file
   ((n++))                 # Increment name of output part
done
