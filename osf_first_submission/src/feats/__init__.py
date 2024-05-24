class Features():
    def __init__(self, feat_file='panphon.csv'):
        with open(feat_file, encoding="utf8") as f_file:
            self.feat_names = f_file.readline().strip('\n').split(',')[1:]
            self.feats = {}
            for line in f_file:
                line = line.strip('\n')
                line = line.split(',')
                line = [-1 if x == '-' else x for x in line]
                line = [1 if x == '+' else x for x in line]
                self.feats[line[0]] = dict(zip(self.feat_names, [int(i) for i in line[1:]]))

    def get_feats(self, segment):
        if segment in self.feats:
            return self.feats[segment]
        raise ValueError(f"Features are not defined for [{segment}]")

    def get_segments(self, feature, value):
        if feature not in self.feat_names:
            raise ValueError("{feature} is not a defined feature")
        if value not in [-1, 0, 1]:
            raise ValueError("Feature values must be 0, 1, or -1")
        return [seg for (seg, feats) in self.feats.items() if (feature, value) in feats.items()]
