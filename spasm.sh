#!/bin/bash
PBS_SCRIPT=$HOME/assembly_submission
#.sh

#Check arguments
if [ $# -ne 5  ]
then
        echo "$0 <reads_dir> <output_dir> <nb_cpu> <email> <queue>"
        exit
fi

header="""#!/bin/bash
#$ -S /bin/bash
#$ -M $4
#$ -m bea
#$ -q $5
#$ -pe thread $3
#$ -l mem_total=50G
### LIBRARY
source /local/gensoft2/adm/etc/profile.d/modules.sh
module purge
module add blast+/2.2.31 Python/2.7.8 fastqc/0.11.5 bowtie2/2.2.3 AlienTrimmer/0.4.0 SPAdes/3.7.0 hmmer/3.1b1 samtools/1.2 KronaTools/2.4 hmmer/3.1b1 barrnap/0.7
"""
a=1
for file in $(ls $1/*R1*.fastq)
do
   samplename=$(basename $file |sed "s:_R1:@:g"|cut -f 1 -d"@")
   input1=$(readlink -e $file)
   input2=$(readlink -e $(echo $file|sed "s:R1:R2:g"))
   echo $samplename
   outputdir="$(readlink -e $2)/$samplename"
   mkdir -p $outputdir
   echo """$header
#$ -N "assembly_${samplename}"
/bin/bash $HOME/assembly_illumina/assembly_illumina.sh  -1 $input1 -2 $input2 -o $outputdir -s $samplename --metagenemark -n $3 &> $outputdir/log_assembly_illumina.txt 
   """ >"${PBS_SCRIPT}_${a}.sh"
   PBSID=`qsub ${PBS_SCRIPT}_${a}.sh`
   let "a=a+1"
   #exit
   echo "! Soumission PBS :> JOBID = $PBSID"
done