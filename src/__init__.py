import csv
from .similarity.nat_class import NatClassSim
from .similarity.feat import FeatSim
from .lexicon import Lexicon
from .feats import Features

DATA_SOURCE = 'northeuralex'

LANG_DATA = {}
with open("data/northeuralex/northeuralex-0.9-language-data.tsv", encoding="utf-8") as lang_f:
    lang_f.readline()
    for line in lang_f:
        line = line.strip('\n').split('\t')
        language = line[0].lower()
        family = line[3].lower()
        subfamily = line[4].lower()
        lat = float(line[5])
        long = float(line[6])
        LANG_DATA[language] = {
            "family": family,
            "subfamily": subfamily,
            "latitude": lat,
            "longitude": long
        }

def get_csv_data(data, features, non_adj=False):
    lex = Lexicon(data)
    feats = Features(features)
    nc_sim = NatClassSim(feats)
    feat_sim = FeatSim(feats)
    languages = lex.data.keys()
    data = []
    for lang in languages:
        print(lang)
        c_pairs = lex.get_cons_pairs(lang, DATA_SOURCE)
        v_pairs = lex.get_vowel_pairs(lang, DATA_SOURCE)
        v_inv = lex.get_vowel_inventory(lang, DATA_SOURCE)
        c_inv = lex.get_cons_inventory(lang, DATA_SOURCE)
        avg_c_count = lex.get_avg_cons_count(lang, DATA_SOURCE)
        avg_v_count = lex.get_avg_vowel_count(lang, DATA_SOURCE)
        v_inv_size = len(v_inv)
        c_inv_size = len(c_inv)

        for pair in c_pairs:
            s1 = pair[0]
            s2 = pair[1]
            data += [{
                'type': 'cons',
                'language': lang,
                'family': LANG_DATA[lang]['family'],
                'subfamily': LANG_DATA[lang]['subfamily'],
                'avg_c_count': avg_c_count,
                'avg_v_count': avg_v_count,
                'latitude': LANG_DATA[lang]['latitude'],
                'longitude': LANG_DATA[lang]['longitude'],
                'source': DATA_SOURCE,
                'v_inv_size': v_inv_size,
                'c_inv_size': c_inv_size,
                's1': s1,
                's2': s2,
                'pair_count': lex.get_all_cons_paircount(lang, DATA_SOURCE, s1, s2, non_adj),
                's1_count': lex.get_seg_count(lang, DATA_SOURCE, s1),
                's2_count': lex.get_seg_count(lang, DATA_SOURCE, s2),
                'pair_freq': lex.get_all_cons_pairfreq(lang, DATA_SOURCE, s1, s2, non_adj),
                's1_freq': lex.get_seg_freq(lang, DATA_SOURCE, s1),
                's2_freq': lex.get_seg_freq(lang, DATA_SOURCE, s2),
                'identity': 1 if s1 == s2 else 0,
                'nat_class_sim': nc_sim.similarity(c_inv, s1, s2),
                'sim': feat_sim.similarity(c_inv, s1, s2),
            } | {
                ft: 1 if feats.get_feats(s1)[ft] == feats.get_feats(s2)[ft]
                else 0 for ft in feats.feat_names
            }]

        for pair in v_pairs:
            s1 = pair[0]
            s2 = pair[1]
            data += [{
                'type': 'vowels',
                'language': lang,
                'family': LANG_DATA[lang]['family'],
                'subfamily': LANG_DATA[lang]['subfamily'],
                'avg_c_count': avg_c_count,
                'avg_v_count': avg_v_count,
                'latitude': LANG_DATA[lang]['latitude'],
                'longitude': LANG_DATA[lang]['longitude'],
                'source': DATA_SOURCE,
                'v_inv_size': v_inv_size,
                'c_inv_size': c_inv_size,
                's1': s1,
                's2': s2,
                'pair_count': lex.get_all_vowel_paircount(lang, DATA_SOURCE, s1, s2, non_adj),
                's1_count': lex.get_seg_count(lang, DATA_SOURCE, s1),
                's2_count': lex.get_seg_count(lang, DATA_SOURCE, s2),
                'pair_freq': lex.get_all_vowel_pairfreq(lang, DATA_SOURCE, s1, s2, non_adj),
                's1_freq': lex.get_seg_freq(lang, DATA_SOURCE, s1),
                's2_freq': lex.get_seg_freq(lang, DATA_SOURCE, s2),
                'identity': 1 if s1 == s2 else 0,
                'nat_class_sim': nc_sim.similarity(v_inv, s1, s2),
                'sim': feat_sim.similarity(v_inv, s1, s2),
            } | {
                ft: 1 if feats.get_feats(s1)[ft] == feats.get_feats(s2)[ft]
                else 0 for ft in feats.feat_names
            }]

    return data
