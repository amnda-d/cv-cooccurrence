import numpy as np
from nose2.tools import such
from src.lexicon import Lexicon

with such.A("Lexicon") as it:

    @it.has_setup
    def setup():
        it.lex = Lexicon('tests/testlex.csv')

    @it.should("parses the lexicon, removing geminates and long vowels")
    def test_lex():
        it.assertEqual(it.lex.data, {
            'finnish': {
                'northeuralex': [
                    ['s', 'i', 'l', 'm', 'æ'],
                    ['k', 'ɔ', 'r', 'ʋ', 'ɑ'],
                    ['h', 'ɑ', 'm', 'ɑ', 's']
                ]
            },
            'evenki': {
                'northeuralex': [
                    ['x', 'a', 'w', 'a', 'l', 'm', 'i'],
                    ['o', 'd͡ʒ', 'a', 'm', 'i']
                ]
            },
            'test': {
                'northeuralex': [
                    ['t', 'h', 'a', 'i', 'l', 'a', 'n', 'd'],
                    ['t', 'a', 'h', 'a']
                ]
            }
        })

    @it.should("get the vowel inventory of a language")
    def test_v_inv():
        it.assertEqual(it.lex.get_vowel_inventory('finnish', 'northeuralex'), {'i', 'æ', 'ɔ', 'ɑ'})
        it.assertEqual(it.lex.get_vowel_inventory('evenki', 'northeuralex'), {'a', 'i', 'o'})

    @it.should("throw an error if a language or source doesn't exist")
    def test_v_err():
        with it.assertRaises(ValueError):
            it.lex.get_vowel_inventory('spanish', 'northeuralex')
        with it.assertRaises(ValueError):
            it.lex.get_vowel_inventory('finnish', 'dictionary')

    @it.should("get the consonant inventory of a language")
    def test_c_inv():
        it.assertEqual(
            it.lex.get_cons_inventory('finnish', 'northeuralex'),
            {'s', 'l', 'm', 'k', 'r', 'ʋ', 'h'}
        )
        it.assertEqual(
            it.lex.get_cons_inventory('evenki', 'northeuralex'),
            {'x', 'w', 'l', 'm', 'd͡ʒ'}
        )

    @it.should("throw an error if a language or source doesn't exist")
    def test_c_err():
        with it.assertRaises(ValueError):
            it.lex.get_cons_inventory('spanish', 'northeuralex')
        with it.assertRaises(ValueError):
            it.lex.get_cons_inventory('finnish', 'dictionary')

    @it.should("count the number of occurrences of a segment")
    def test_count_seg():
        it.assertEqual(it.lex.get_seg_count('finnish', 'northeuralex', 'm'), 2)
        it.assertEqual(it.lex.get_seg_count('evenki', 'northeuralex', 'a'), 3)

    @it.should("calculate the frequency of a segment")
    def test_seg_freq():
        it.assertEqual(it.lex.get_seg_freq('finnish', 'northeuralex', 'i'), np.log(1/15))
        it.assertEqual(it.lex.get_seg_freq('evenki', 'northeuralex', 'm'), np.log(2/12))

    @it.should("get all possible vowel pairs")
    def test_get_v_pairs():
        it.assertEqual(
            it.lex.get_vowel_pairs('evenki', 'northeuralex'),
                {('i', 'a'), ('o', 'a'), ('o', 'i'), ('a', 'a'),
                ('i', 'i'), ('o', 'o'), ('a', 'i'), ('a', 'o'), ('i', 'o')}
            )

    @it.should("get all possible consonant pairs")
    def test_get_c_pairs():
        it.assertEqual(it.lex.get_cons_pairs('evenki', 'northeuralex'), {
        ('x', 'x'), ('x', 'w'), ('x', 'l'), ('x', 'm'), ('x', 'd͡ʒ'),
        ('w', 'w'), ('w', 'x'), ('w', 'l'), ('w', 'm'), ('w', 'd͡ʒ'),
        ('l', 'l'), ('l', 'x'), ('l', 'w'), ('l', 'm'), ('l', 'd͡ʒ'),
        ('m', 'm'), ('m', 'x'), ('m', 'w'), ('m', 'l'), ('m', 'd͡ʒ'),
        ('d͡ʒ', 'd͡ʒ'), ('d͡ʒ', 'x'), ('d͡ʒ', 'w'), ('d͡ʒ', 'l'), ('d͡ʒ', 'm')
        })

    @it.should("get pair counts for all vowel pairs")
    def test_get_all_v_paircount():
        it.assertEqual(it.lex.get_all_vowel_paircount('evenki', 'northeuralex', 'a', 'i'), 2)

    @it.should("get pair counts for non-adjacent vowel pairs")
    def test_non_adj_v_count():
        it.assertEqual(
            it.lex.get_all_vowel_paircount('test', 'northeuralex', 'a', 'i', non_adj=True), 0
        )
        it.assertEqual(
            it.lex.get_all_vowel_paircount('test', 'northeuralex', 'i', 'a', non_adj=True), 1
        )
        it.assertEqual(
            it.lex.get_all_vowel_paircount('test', 'northeuralex', 'a', 'a', non_adj=True), 1
        )

    @it.should("get pair frequencies for all vowel pairs")
    def test_get_all_v_pairfreq():
        it.assertEqual(
            it.lex.get_all_vowel_pairfreq('evenki', 'northeuralex', 'a', 'i'),
            np.log(2/4)
        )

    @it.should("get pair frequencies for non-adjacent vowel pairs")
    def test_get_non_adj_v_pairfreq():
        it.assertEqual(
            it.lex.get_all_vowel_pairfreq('test', 'northeuralex', 'a', 'a', non_adj=True),
            np.log(1/2)
        )

    @it.should("get pair counts for all consonant pairs")
    def test_get_all_c_paircount():
        it.assertEqual(it.lex.get_all_cons_paircount('evenki', 'northeuralex', 'l', 'm'), 1)

    @it.should("get pair counts for non-adjacent consonant pairs")
    def test_non_adj_c_count():
        it.assertEqual(
            it.lex.get_all_cons_paircount('test', 'northeuralex', 't', 'h', non_adj=True), 1
        )
        it.assertEqual(
            it.lex.get_all_cons_paircount('test', 'northeuralex', 'l', 'n', non_adj=True), 1
        )
        it.assertEqual(
            it.lex.get_all_cons_paircount('test', 'northeuralex', 'n', 'd', non_adj=True), 0
        )

    @it.should("get pair frequencies for all consonant pairs")
    def test_get_all_c_pairfreq():
        it.assertEqual(
            it.lex.get_all_cons_pairfreq('evenki', 'northeuralex', 'l', 'm'),
            np.log(1/4)
        )

    @it.should("get pair frequencies for non adjacent consonant pairs")
    def test_get_all_c_pairfreq_2():
        it.assertEqual(
            it.lex.get_all_cons_pairfreq('test', 'northeuralex', 't', 'h', non_adj=True),
            np.log(1/3)
        )

    @it.should("get the average number of vowels per word in a language")
    def test_num_v():
        it.assertEqual(it.lex.get_avg_vowel_count('evenki', 'northeuralex'), 3)

    @it.should("get the average number of consonants per word in a language")
    def test_num_c():
        it.assertEqual(it.lex.get_avg_cons_count('evenki', 'northeuralex'), 3)

it.createTests(globals())
