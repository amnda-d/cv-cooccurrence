class FeatSim(object):
    def __init__(self, features):
        self.feats = features
        self.contrastive = {}

    def contrastive_feats(self, inventory):
        if tuple(set(inventory)) in self.contrastive:
            return self.contrastive[tuple(set(inventory))]
        contrastive_feats = []
        for ft in self.feats.feat_names:
            if len({self.feats.get_feats(s)[ft] for s in inventory}) != 1:
                contrastive_feats += [ft]
        self.contrastive[tuple(set(inventory))] = contrastive_feats
        return contrastive_feats

    def similarity(self, inventory, s1, s2):
        if s1 not in inventory or s2 not in inventory:
            raise ValueError("Segment not in inventory")
        contrastive = self.contrastive_feats(inventory)
        s1_fts = self.feats.get_feats(s1)
        s2_fts = self.feats.get_feats(s2)
        return sum([1 if s1_fts[ft] == s2_fts[ft] else 0 for ft in contrastive])/len(contrastive)
