#---- download the necessary files for run KrakenTools
#git clone https://github.com/jenniferlu717/KrakenTools.git

module avail python
module load python-3.9.18
#--------------------------------------------------------------
#https://github.com/jenniferlu717/KrakenTools/tree/master
#make lsf file as a bash script to run KrakenTools filter_bracken.out.py for filter Homo Sapiens (--exclude 9606)
#-----------------------------------------------------------------------------------------------
#!/bin/bash
#BSUB -G team216f
#BSUB -q normal
#BSUB -M 8000
#BSUB -R "select[mem=8000] rusage[mem=8000]"
#BSUB -J filter_bracken
#BSUB -o filter_bracken.%J.out
#BSUB -e filter_bracken.%J.err

module load python-3.9.18

IN_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/bracken_output"
OUT_DIR="/data/pam/team216/ma32/scratch/metagenome/caz/filtered_bracken"

mkdir -p "$OUT_DIR"

for f in "$IN_DIR"/*.bracken; do
  base=$(basename "$f" .bracken)

  python3 /data/pam/team216/ma32/scratch/metagenome/caz/krakentools_output/KrakenTools/filter_bracken.out.py \
    -i "$f" \
    -o "$OUT_DIR/${base}.filtered.bracken" \
    --exclude 9606
done
#-----------------------------------------------------------------------------------------------------------------------------
#---------------------- make the below script as filter_braken.lsf then upload in HPC , and then run as bsub < filter_bracken.lsf
#check the job status by running : bjobs, the you will be shown the status whether pending or completion
#if you waana kill a job just type bkill jobID


#--------------------------------------------------------------
