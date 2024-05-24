from nose2.tools import such
from src.feats import Features

with such.A("Features") as it:

    @it.has_setup
    def setup():
        it.feats = Features('tests/testfeats.csv')

    @it.should("parse the feature names")
    def test_featnames():
        it.assertEqual(it.feats.feat_names, ['lab', 'cor', 'velar', 'voi'])

    @it.should("parse the feature values")
    def test_feats():
        it.assertEqual(it.feats.feats, {
            'p': {'lab': 1, 'cor': -1, 'velar': -1, 'voi': -1},
            't': {'lab': -1, 'cor': 1, 'velar': -1, 'voi': -1},
            'k': {'lab': -1, 'cor': -1, 'velar': 1, 'voi': -1},
            'b': {'lab': 1, 'cor': -1, 'velar': -1, 'voi': 1},
            'd': {'lab': -1, 'cor': 1, 'velar': -1, 'voi': 1},
            'g': {'lab': -1, 'cor': -1, 'velar': 1, 'voi': 1},
        })

    @it.should("get the features for a segment")
    def test_get_feats():
        it.assertEqual(it.feats.get_feats('b'), {'lab': 1, 'cor': -1, 'velar': -1, 'voi': 1})

    @it.should("throw an error if a segment isn't in the feature file")
    def test_feats_err():
        with it.assertRaises(ValueError):
            it.feats.get_feats('r')

    @it.should("get the segments matching a feature")
    def test_get_segs():
        it.assertEqual(it.feats.get_segments('cor', 1), ['t', 'd'])

    @it.should("throw an error if a feature isn't defined")
    def test_no_feat():
        with it.assertRaises(ValueError):
            it.feats.get_segments('aldskfj', 1)

    @it.should("throw an error if a feature value is not 1, -1, or 0")
    def test_feat_val():
        with it.assertRaises(ValueError):
            it.feats.get_segments('cor', 3)

it.createTests(globals())
