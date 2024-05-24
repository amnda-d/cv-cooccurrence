import csv

def clean_data():

    languages = {}

    with open('data/northeuralex/northeuralex-0.9-language-data.tsv', encoding='utf8') as lang_file:
        lang_file.readline()
        for line in lang_file:
            row = line.split('\t')
            languages[row[2]] = row[0]

    def clean(ipa_array):
        # remove stress marking
        ipa_array = [x.strip('ˈ').strip('ˌ') for x in ipa_array]

        # remove syllable marking
        ipa_array = [x for x in ipa_array if x != '.']

        # remove '_' char
        ipa_array = [x for x in ipa_array if '_' not in x]

        # remove 'ʲ'
        ipa_array = [x for x in ipa_array if x != 'ʲ']
        ipa_array = [x for x in ipa_array if x != 'ˀ']
        ipa_array = [x for x in ipa_array if x != 'ʰ']
        ipa_array = [x for x in ipa_array if x != 'ʷ']
        ipa_array = [x for x in ipa_array if x != '̃']
        ipa_array = [x for x in ipa_array if x != 'ʼ']
        ipa_array = [x for x in ipa_array if x != 'ʰʲ']
        ipa_array = [x for x in ipa_array if x != 'ʷʰ']
        ipa_array = [x for x in ipa_array if x != 'ʼʷ']
        ipa_array = [x for x in ipa_array if x != 'ˤ']
        ipa_array = [x for x in ipa_array if x != 'ˤ']
        ipa_array = [x for x in ipa_array if x != 'ʼˤ']

        ipa_array = ['tʲ' if x == 'tʲʲ' else x for x in ipa_array]
        ipa_array = ['ʃʲ' if x == 'ʃʲʲ' else x for x in ipa_array]
        ipa_array = ['rʲ' if x == 'rʲʲ' else x for x in ipa_array]
        ipa_array = ['nʲ' if x == 'nʲʲ' else x for x in ipa_array]
        ipa_array = ['mʲ' if x == 'mʲʲ' else x for x in ipa_array]
        ipa_array = ['j' if x == 'jʲ' else x for x in ipa_array]
        ipa_array = ['y' if x == 'yʲ' else x for x in ipa_array]
        ipa_array = ['kʲʷ' if x == 'kʷʲ' else x for x in ipa_array]

        # different unicode chars?
        ipa_array = ['ç' if x == 'ç' else x for x in ipa_array]
        ipa_array = ['c͡ç' if x == 'c͡ç' else x for x in ipa_array]

        # for some reason this doesn't work
        ipa_array = ['ɽ' if x == 'ɽʰ' else x for x in ipa_array]
        ipa_array = ['ɡʷ' if x == 'ɡʷ̃' else x for x in ipa_array]
        ipa_array = ['ʔ' if x == 'ʡ' else x for x in ipa_array]
        ipa_array = ['hʲ' if x == 'ʜʲ' else x for x in ipa_array]
        ipa_array = ['h' if x == 'ʜ' else x for x in ipa_array]

        # for some reason belarussian has these
        ipa_array = ['z' if x == 'zʼ' else x for x in ipa_array]
        ipa_array = ['r' if x == 'rʼ' else x for x in ipa_array]
        ipa_array = ['d' if x == 'dʼ' else x for x in ipa_array]
        ipa_array = ['m' if x == 'mʼ' else x for x in ipa_array]
        ipa_array = ['b' if x == 'bʼ' else x for x in ipa_array]
        ipa_array = ['pʼ' if x == 'pʼˤ' else x for x in ipa_array]
        ipa_array = ['tʼ' if x == 'tʼˤ' else x for x in ipa_array]
        ipa_array = ['qʼ' if x == 'qʼˤ' else x for x in ipa_array]

        # remove aspirated vowel??
        ipa_array = ['e' if x == 'eʰ' else x for x in ipa_array]
        ipa_array = ['u' if x == 'uʰ' else x for x in ipa_array]
        ipa_array = ['ɨ' if x == 'ɨʰ' else x for x in ipa_array]
        ipa_array = ['ɑ' if x == 'ɑʰ' else x for x in ipa_array]
        ipa_array = ['ɔ' if x == 'ɔʰ' else x for x in ipa_array]
        ipa_array = ['ɪ' if x == 'ɪʰ' else x for x in ipa_array]
        ipa_array = ['ɛ' if x == 'ɛʰ' else x for x in ipa_array]
        ipa_array = ['œ' if x == 'œʰ' else x for x in ipa_array]
        ipa_array = ['y' if x == 'ỹ' else x for x in ipa_array]

        ipa_array = [['ə', 'j'] if x == 'əʲ' else x for x in ipa_array]
        ipa_array = [['a', 'j'] if x == 'aʲ' else x for x in ipa_array]
        ipa_array = [['ɪ', 'j'] if x == 'ɪʲ' else x for x in ipa_array]
        ipa_array = [['e', 'j'] if x == 'eʲ' else x for x in ipa_array]
        ipa_array = [['o', 'j'] if x == 'oʲ' else x for x in ipa_array]
        ipa_array = [['ɐ', 'j'] if x == 'ɐʲ' else x for x in ipa_array]
        ipa_array = [['i', 'j'] if x == 'iʲ' else x for x in ipa_array]
        ipa_array = [['ʊ', 'j'] if x == 'ʊʲ' else x for x in ipa_array]
        ipa_array = [['æ', 'j'] if x == 'æʲ' else x for x in ipa_array]
        ipa_array = [['ɛ', 'j'] if x == 'ɛʲ' else x for x in ipa_array]
        ipa_array = [['ɔ', 'j'] if x == 'ɔʲ' else x for x in ipa_array]
        ipa_array = [['œ', 'j'] if x == 'œʲ' else x for x in ipa_array]
        ipa_array = [['ʌ', 'j'] if x == 'ʌʲ' else x for x in ipa_array]


        if any(isinstance(el, list) for el in ipa_array):
            l = []
            for el in ipa_array:
                if isinstance(el, list):
                    l += list(el)
                else:
                    l += [el]
            return l
        return ipa_array

    data = []

    with open('data/northeuralex/northeuralex-0.9-forms.tsv', encoding='utf8') as lex_file:
        lex_file.readline()
        for line in lex_file:
            row = line.split('\t')
            raw_ipa = row[5].split(' ')
            ipa = clean(raw_ipa)
            data += [[languages[row[0]], 'northeuralex', ' '.join(ipa), row[5]]]

    with open('data/lex_data/northeuralex.csv', 'w', encoding='utf8') as out_file:
        cols = ['language', 'source', 'ipa', 'original_ipa']
        dict_writer = csv.writer(out_file, delimiter='\t')
        dict_writer.writerow(cols)
        dict_writer.writerows(data)
