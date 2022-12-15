import csv
from . import get_csv_data
from .lexicon.clean import clean_data

clean_data()

data = get_csv_data('data/lex_data/northeuralex.csv', 'src/feats/panphon.csv')

with open('data/r_data/northeuralex.csv', 'w', encoding='utf-8') as output_file:
    dict_writer = csv.DictWriter(output_file, data[0].keys())
    dict_writer.writeheader()
    dict_writer.writerows(data)

data_non_adj = get_csv_data('data/lex_data/northeuralex.csv', 'src/feats/panphon.csv', non_adj=True)

with open('data/r_data/northeuralex_non_adj.csv', 'w', encoding='utf-8') as output_file:
    dict_writer = csv.DictWriter(output_file, data[0].keys())
    dict_writer.writeheader()
    dict_writer.writerows(data)
