#!/bin/bash
SLURM_SCRIPT=$HOME/assembly_submission.sh

#Check arguments
if [ $# -ne 5  ]
then
        echo "$0 <reads_dir> <output_dir> <nb_cpu> <email> <queue>"
        exit
fi

SCRIPTPATH=$(dirname "${BASH_SOURCE[0]}")
header="""#!/bin/bash
#SBATCH --mail-user=$4
#SBATCH --mail-type=ALL
#SBATCH --qos=$5
#SBATCH --cpus-per-task=$3
#SBATCH --mem=50000"""

mod="""### LIBRARY
source /local/gensoft2/adm/etc/profile.d/modules.sh
module purge
module add blast+/2.2.31 Python/2.7.8 fastqc/0.11.5 bowtie2/2.2.3 AlienTrimmer/0.4.0 SPAdes/3.9.0 hmmer/3.1b1 samtools/1.2 KronaTools/2.4 hmmer/3.1b1 barrnap/0.7 khmer/2.0
"""

for file in $(ls $1/*R1*.fastq)
do
   samplename=$(basename $file |sed "s:_R1:@:g"|cut -f 1 -d"@")
   input1=$(readlink -e $file)
   input2=$(readlink -e $(echo $file|sed "s:R1:R2:g"))
   if [ "$input1" == "" ]
   then
       input1=$(readlink $file)
       input2=$(readlink $(echo $file|sed "s:R1:R2:g"))
   fi
   echo $samplename
   mkdir -p $2
   outputdir="$(readlink -e $2)/$samplename"
   mkdir -p $outputdir
   echo """$header
#SBATCH --job-name=\"assembly_${samplename}\"
$mod
/bin/bash $SCRIPTPATH/assembly_illumina.sh  -1 $input1 -2 $input2 -o $outputdir -s $samplename --metagenemark -n $3 &> $outputdir/log_assembly_illumina.txt || exit 1
exit 0
   """ >$SLURM_SCRIPT
   SLURMID=`sbatch $SLURM_SCRIPT`
   echo "! Soumission SLURM :> JOBID = $SLURMID"
done
