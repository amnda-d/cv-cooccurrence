from collections import Counter
import numpy as np

VOWELS = {
    'a', 'ã', 'ɐ', 'ɐ̃', 'ɑ', 'ɑ̃', 'æ', 'ɐʲ', 'ã',
    'aˤ', 'aʲ', 'ɐˀ', 'ɑʰ', 'æˀ', 'æʲ', 'ɒ', 'ɒˀ', 'ɑˀ',
    'e', 'ẽ', 'ɛ', 'ɛ̃', 'ɝ', 'ə', 'ɛʲ', 'ɜ', 'əʲ', 'eʲ',
    'ɛˀ', 'ə̃', 'eʰ', 'ɛʰ', 'ɘ', 'ẽ',
    'i', 'ĩ', 'ɪ', 'ɪ̃', 'i̯', 'y', 'ɨ', 'ɨʰ',
    'iˤ', 'ɪʲ', 'ĩ', 'iˀ', 'ɨˤ', 'ɨˀ', 'ɪʰ', 'iʲ',
    'o', 'õ', 'ɔ', 'ɔ̃', 'œ', 'ø', 'œʲ', 'œ̃', 'oˤ',
    'ɔʲ', 'oʲ', 'ø̃', 'oˀ', 'õ', 'œʰ', 'ɔʰ',
    'u', 'ũ', 'u̯', 'ʊ', 'ʌ', 'ʉ', 'ɯ', 'ʊʲ', 'uˀ',
    'ʌʲ', 'ʊ̃', 'ũ', 'uˀ', 'ʊˀ', 'ɯ̃', 'uʰ', 'ʊʲ'
}

def filter_geminates_long_vowels(ipa_word):
    out = [None]
    for i in ipa_word:
        if i == out[-1]:
            continue
        out += [i]
    return out[1:]

class Lexicon():
    def __init__(self, lexicon_file):
        self.data = {}
        with open(lexicon_file, encoding="utf-8") as lex_f:
            lex_f.readline()
            for line in lex_f:
                line = line.strip('\n').split('\t')
                language = line[0].lower()
                source = line[1].lower()
                ipa = line[2].split(' ')
                ipa = filter_geminates_long_vowels(ipa)
                ipa = [x for x in ipa if x != '']
                if language not in self.data:
                    self.data[language] = {}
                if source not in self.data[language]:
                    self.data[language][source] = [ipa]
                else:
                    self.data[language][source] += [ipa]
        self.seg_counters = {}
        self.all_v_paircounts = {}
        self.non_adj_v_paircounts = {}
        self.all_c_paircounts = {}
        self.non_adj_c_paircounts = {}

    def check_data(self, language, source):
        if language not in self.data:
            raise ValueError(f'No data for language: {language}')
        if source not in self.data[language]:
            raise ValueError(f'No data for source: {source}')

    def get_vowel_inventory(self, language, source):
        self.check_data(language, source)
        lex = self.data[language][source]
        return {c for word in lex for c in word if c in VOWELS}

    def get_cons_inventory(self, language, source):
        self.check_data(language, source)
        lex = self.data[language][source]
        return {c for word in lex for c in word if c not in VOWELS}

    def get_seg_count(self, language, source, segment):
        self.check_data(language, source)
        if (language, source) not in self.seg_counters:
            segments = [char for word in self.data[language][source] for char in word]
            self.seg_counters[(language, source)] = Counter(segments)
        return self.seg_counters[(language, source)][segment]

    def get_seg_freq(self, language, source, segment):
        self.check_data(language, source)
        seg_count = self.get_seg_count(language, source, segment)
        total = self.seg_counters[(language, source)].total()
        return np.log(seg_count/total)

    def get_vowel_pairs(self, language, source):
        self.check_data(language, source)
        vowels = self.get_vowel_inventory(language, source)
        return {(i, j) for i in vowels for j in vowels}

    def get_cons_pairs(self, language, source):
        self.check_data(language, source)
        cons = self.get_cons_inventory(language, source)
        return {(i, j) for i in cons for j in cons}

    def get_all_vowel_paircount(self, language, source, v1, v2, non_adj=False):
        self.check_data(language, source)
        if non_adj:
            if (language, source) not in self.non_adj_v_paircounts:
                words = self.data[language][source]
                pairs = []
                for word in words:
                    vs = [(x, c) for (x, c) in enumerate(word) if c in VOWELS]
                    for i in range(len(vs) - 1):
                        if vs[i][0] + 1 != vs[i+1][0]:
                            pairs += [(vs[i][1], vs[i+1][1])]
                self.non_adj_v_paircounts[(language, source)] = Counter(pairs)
            return self.non_adj_v_paircounts[(language, source)][(v1, v2)]

        if (language, source) not in self.all_v_paircounts:
            words = self.data[language][source]
            pairs = []
            for word in words:
                vs = [c for c in word if c in VOWELS]
                for i in range(len(vs) - 1):
                    pairs += [(vs[i], vs[i+1])]
            self.all_v_paircounts[(language, source)] = Counter(pairs)
        return self.all_v_paircounts[(language, source)][(v1, v2)]

    def get_all_vowel_pairfreq(self, language, source, v1, v2, non_adj=False):
        self.check_data(language, source)
        if non_adj:
            count = self.get_all_vowel_paircount(language, source, v1, v2, non_adj)
            total = self.non_adj_v_paircounts[(language, source)].total()
        else:
            count = self.get_all_vowel_paircount(language, source, v1, v2)
            total = self.all_v_paircounts[(language, source)].total()
        if count == 0:
            return -np.inf
        return np.log(count/total)

    def get_all_cons_paircount(self, language, source, c1, c2, non_adj=False):
        self.check_data(language, source)
        if non_adj:
            if (language, source) not in self.non_adj_c_paircounts:
                words = self.data[language][source]
                pairs = []
                for word in words:
                    cs = [(x, c) for (x, c) in enumerate(word) if c not in VOWELS]
                    for i in range(len(cs) - 1):
                        if (cs[i][0] + 1) != cs[i+1][0]:
                            pairs += [(cs[i][1], cs[i+1][1])]
                self.non_adj_c_paircounts[(language, source)] = Counter(pairs)
            return self.non_adj_c_paircounts[(language, source)][(c1, c2)]

        if (language, source) not in self.all_c_paircounts:
            words = self.data[language][source]
            pairs = []
            for word in words:
                cs = [c for c in word if c not in VOWELS]
                for i in range(len(cs) - 1):
                    pairs += [(cs[i], cs[i+1])]
            self.all_c_paircounts[(language, source)] = Counter(pairs)
        return self.all_c_paircounts[(language, source)][(c1, c2)]

    def get_all_cons_pairfreq(self, language, source, c1, c2, non_adj=False):
        self.check_data(language, source)
        if non_adj:
            count = self.get_all_cons_paircount(language, source, c1, c2, non_adj)
            total = self.non_adj_c_paircounts[(language, source)].total()
        else:
            count = self.get_all_cons_paircount(language, source, c1, c2)
            total = self.all_c_paircounts[(language, source)].total()
        if count == 0:
            return -np.inf
        return np.log(count/total)

    def get_avg_vowel_count(self, language, source):
        self.check_data(language, source)
        lex = self.data[language][source]
        return np.mean([len([c for c in word if c in VOWELS]) for word in lex])

    def get_avg_cons_count(self, language, source):
        self.check_data(language, source)
        lex = self.data[language][source]
        return np.mean([len([c for c in word if c not in VOWELS]) for word in lex])
