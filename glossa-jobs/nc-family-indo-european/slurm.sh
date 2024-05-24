#!/bin/bash

#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=nc-family-indo-european
#SBATCH --output=r/glossa-jobs/nc-family-indo-european/%x-%j.out
#SBATCH --mail-user=amanda.doucette@mail.mcgill.ca
#SBATCH --mail-type=ALL

module load gcc/9.3.0 r-bundle-bioconductor/3.14 r/4.1.2
Rscript /home/amnda/projects/def-timod/amnda/consHarmony/r/glossa-jobs/nc-family-indo-european/script.R
