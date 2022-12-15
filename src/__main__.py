import csv
from . import get_csv_data
from .lexicon.clean import clean_data

# clean_data()

# data = get_csv_data('data/BermanHeb.csv', 'hebrew', 'src/feats/feature.csv')
#
# with open('data/r_data/BermanHeb.csv', 'w', encoding='utf-8') as output_file:
#     dict_writer = csv.DictWriter(output_file, data[0].keys())
#     dict_writer.writeheader()
#     dict_writer.writerows(data)

data = get_csv_data('data/BermanHeb.csv', 'src/feats/feature.csv', 'hebrew', non_adj=True)

with open('data/r_data/BermanHeb_non_adj.csv', 'w', encoding='utf-8') as output_file:
    dict_writer = csv.DictWriter(output_file, data[0].keys())
    dict_writer.writeheader()
    dict_writer.writerows(data)

data = get_csv_data('data/SalamaArb.csv', 'src/feats/feature.csv', 'arabic', non_adj=True)

with open('data/r_data/SalamaArb_non_adj.csv', 'w', encoding='utf-8') as output_file:
    dict_writer = csv.DictWriter(output_file, data[0].keys())
    dict_writer.writeheader()
    dict_writer.writerows(data)
