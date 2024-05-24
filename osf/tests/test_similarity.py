from nose2.tools import such
from src.similarity.nat_class import NatClassSim
from src.similarity.feat import FeatSim
from src.feats import Features

with such.A("Natural Class Similarity") as it:

    @it.has_setup
    def setup():
        it.feats = Features('tests/testfeats.csv')
        it.nc_sim = NatClassSim(it.feats)

    @it.should("get all natural classes for an inventory")
    def test_get_nat_class():
        it.assertEqual(it.nc_sim.get_nat_classes(['p', 't', 'k', 'b', 'd', 'g']),
        [
            {'k', 'b', 'p', 'g', 't', 'd'},
            {'p', 'b'},
            {'d', 'g', 'k', 't'},
            {'d', 't'},
            {'g', 'p', 'k', 'b'},
            {'g', 'k'},
            {'b', 'd', 'p', 't'},
            {'d', 'g', 'b'},
            {'p', 'k', 't'},
            {'b'}, {'p'}, {'d', 'g'}, {'k', 't'},
            {'d'}, {'t'}, {'g', 'b'}, {'p', 'k'},
            {'g'}, {'k'}, {'d', 'b'}, {'p', 't'}
        ])

    @it.should("throw an error when a segment isn't in the inventory")
    def test_error_inv():
        with it.assertRaises(ValueError):
            it.nc_sim.similarity(['p', 't', 'k', 'b', 'd', 'g'], 'r', 'y')

    @it.should("calculate natural class similarity")
    def test_nat_class_sim():
        it.assertEqual(it.nc_sim.similarity(['p', 't', 'k', 'b', 'd', 'g'], 'p', 'k'), 4/(4+8))

with such.A("Feature Similarity") as it:

    @it.has_setup
    def setup2():
        it.feats = Features('tests/testfeats.csv')
        it.feat_sim = FeatSim(it.feats)

    @it.should("get contrastive features in an inventory")
    def test_contrast():
        it.assertEqual(it.feat_sim.contrastive_feats(['p', 't', 'k']), ['lab', 'cor', 'velar'])

    @it.should("throw an error when a segment isn't in the inventory")
    def test_error_inv2():
        with it.assertRaises(ValueError):
            it.feat_sim.similarity(['p', 't', 'k', 'b', 'd', 'g'], 'r', 'y')

    @it.should("calculate contrastive feature similarity")
    def test_feat_sim():
        it.assertEqual(it.feat_sim.similarity(['p', 't', 'k'], 'p', 'k'), 1/3)

it.createTests(globals())
