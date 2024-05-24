# Investigating the universality of consonant and vowel co-occurrence restrictions


### Requirements

- Python 3.10.14
  - numpy 1.26.4
  - pylint 3.1.0
  - nose2 0.14.1
- CmdStan 2.33.1
- R 4.3.1
  - brms 2.16.3
  - cmdstanr 0.6.1
  - bayestestR 0.13.1
  - tidyverse 2.0.0
  - tidybayes 3.0.6
  - cowplot 1.1.3
  - latex2exp 0.9.6
  - ggridges 0.5.6
  - mgcv 1.9-1
  

#### To download the data

```
make download_panphon

make download_northeuralex
```


#### To generate the count and similarity data

```
make run
```


#### To run the models

```
make run_nc_model

make run_feat_model
```


#### To generate plots

```
make figures
```
