import csv, sys
from . import get_csv_data
from .lexicon.clean import clean_data

dataFile, features, language = sys.argv[1:]
print(dataFile, features, language)

data = get_csv_data(dataFile, features, language, non_adj=True)

with open('data/r_data/' + language + '.csv', 'w', encoding='utf-8') as output_file:
    dict_writer = csv.DictWriter(output_file, data[0].keys())
    dict_writer.writeheader()
    dict_writer.writerows(data)
