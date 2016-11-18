#!/bin/bash

cd /usr/local/bin

#download test data
mkdir runBATMAN
mkdir runBATMAN/BatmanInput
mkdir runBATMAN/BatmanInput/PureSpectraTemplate
mkdir runBATMAN/BatmanOnput
mkdir results
mkdir runResults

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/NMRdata.txt -O /usr/local/bin/NMRdata.txt

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/batmanOptions.txt -O /usr/local/bin/batmanOptions.txt

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/metabolitesList.csv -O /usr/local/bin/metabolitesList.csv

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/multi_data_user.csv -O /usr/local/bin/multi_data_user.csv

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/PureSpectraTemplate/L-Glutamic%20acid.txt -O "/usr/local/bin/runBATMAN/BatmanInput/PureSpectraTemplate/L-Glutamic acid.txt"

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/PureSpectraTemplate/L-Glutamine.txt -O /usr/local/bin/runBATMAN/BatmanInput/PureSpectraTemplate/L-Glutamine.txt

#cp ./NMRdata.txt runBATMAN/BatmanInput
#cp ./batmanOptions.txt runBATMAN/BatmanInput
#cp ./multi_data_user.csv runBATMAN/BatmanInput
#cp ./metabolitesList.csv runBATMAN/BatmanInput
# run BATMAN


Rscript runBATMAN.R -i ./NMRdata.txt -o ./runResults -p ./batmanOptions.txt -u ./multi_data_user.csv -l ./metabolitesList.csv

#download results for comparison

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/results/RelCon.txt -O /usr/local/bin/results/RelCon.txt

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/results/RelConCreInt.txt -O /usr/local/bin/results/RelConCreInt.txt

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/results/beta_1_rr_0.txt -O /usr/local/bin/results/beta_1_rr_0.txt

wget https://raw.githubusercontent.com/jianlianggao/batman/develop/test_data/results/beta_2_rr_0.txt -O /usr/local/bin/results/beta_2_rr_0.txt

#copy output files to specified folder for comparison
# find BATMAN output folder
found_subfolders=($(/bin/ls -1 -R | grep '^[0-9]\{2\}_[A-Z,a-z]\{3\}_.*$'))
output_path="runBATMAN/BatmanOutput/$found_subfolders"


#run comparison

temp="$(diff "$output_path/RelCon.txt" "results/RelCon.txt")"

if [ ! -z "$temp" ]; then 
   echo "RelCon.txt are not equal"
   exit 1
else
   echo "RelCon.txt are equal"
fi

temp="$(diff "$output_path/RelConCreInt.txt" "results/RelConCreInt.txt")"

if [ ! -z "$temp" ]; then 
   echo "RelConCreInt.txt are not equal"
   exit 1
else
   echo "RelConCreInt.txt are equal"
fi

temp="$(diff "$output_path/beta_1_rr_0.txt" "results/beta_1_rr_0.txt")"

if [ ! -z "$temp" ]; then 
   echo "beta_1_rr_0.txt are not equal"
   exit 1
else
   echo "beta_1_rr_0.txt are equal"
fi

temp="$(diff "$output_path/beta_2_rr_0.txt" "results/beta_2_rr_0.txt")"

if [ ! -z "$temp" ]; then 
   echo "beta_2_rr_0.txt are not equal"
   exit 1
else
   echo "beta_2_rr_0.txt are equal"
fi
echo "All files created successfully"

