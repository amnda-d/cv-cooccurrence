import numpy as np
from nose2.tools import such
from src import get_csv_data

with such.A("Data writer") as it:

    @it.should("produce the correct output")
    def test_output():
        output = get_csv_data('tests/testwritedata.csv', 'tests/testfeats.csv')
        expected = {
                'type': 'cons',
                'language': 'finnish',
                'family': 'uralic',
                'subfamily': 'finnic',
                'avg_c_count': 3,
                'avg_v_count': 0,
                'latitude': 61,
                'longitude': 24.45,
                'source': 'northeuralex',
                'v_inv_size': 0,
                'c_inv_size': 5,
                's1': 'p',
                's2': 'k',
                'pair_count': 1,
                's1_count': 2,
                's2_count': 1,
                'pair_freq': np.log(1/6),
                's1_freq': 2/6,
                's2_freq': 1/6,
                'identity': 0,
                'nat_class_sim': 1/3,
                'sim': 1/2,
                'lab': 0,
                'cor': 1,
                'velar': 0,
                'voi': 1
            }
        it.assertIn(expected, output)

    @it.should("produce the correct output for non-adjacent pairs")
    def test_output2():
        output = get_csv_data('tests/testwritedata.csv', 'tests/testfeats.csv', non_adj=True)
        expected = {
                'type': 'cons',
                'language': 'finnish',
                'family': 'uralic',
                'subfamily': 'finnic',
                'avg_c_count': 3,
                'avg_v_count': 0,
                'latitude': 61,
                'longitude': 24.45,
                'source': 'northeuralex',
                'v_inv_size': 0,
                'c_inv_size': 5,
                's1': 'p',
                's2': 'k',
                'pair_count': 0,
                's1_count': 0,
                's2_count': 0,
                'pair_freq': -np.inf,
                's1_freq': 0,
                's2_freq': 0,
                'identity': 0,
                'nat_class_sim': 1/3,
                'sim': 1/2,
                'lab': 0,
                'cor': 1,
                'velar': 0,
                'voi': 1
            }
        it.assertIn(expected, output)

it.createTests(globals())
