# Identity, Similarity and the OCP: A model of co-occurrence in 107 languages
### Amanda Doucette, Morgan Sonderegger, Timothy J. O'Donnell, and Heather Goad

Presented at LabPhon18, June 25, 2022.


### Requirements

- Python 3.10.0
- R 4.0.3
  - brms 2.16.3
  - tidybayes 3.0.1
  - bayestestR 0.11.0
  - tidyverse 1.3.1
  - cowplot 1.1.1


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
make run_fam_nc_model
make run_fam_feat_model
```


#### To generate plots

```
make figures
```


#### To run hypothesis tests

```
make hypothesis
```
