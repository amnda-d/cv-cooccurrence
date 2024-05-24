class NatClassSim(object):
    def __init__(self, features):
        self.feats = features
        self.nat_classes = {}

    def get_nat_classes(self, inventory):
        if tuple(set(inventory)) in self.nat_classes.keys():
            return self.nat_classes[tuple(set(inventory))]

        cls = [set(inventory)]
        # get single feature classes
        for f in self.feats.feat_names:
            pos_cl = {x for x in self.feats.get_segments(f, 1) if x in inventory}
            neg_cl = {x for x in self.feats.get_segments(f, -1) if x in inventory}
            if len(pos_cl) > 0 and pos_cl not in cls:
                cls += [pos_cl]
            if len(neg_cl) > 0 and neg_cl not in cls:
                cls += [neg_cl]

        # get intersections between sets until no new classes found
        new = cls
        while len(new) > 0:
            new = self.get_intersections(cls, new)
            cls += new
        self.nat_classes[tuple(set(inventory))] = cls
        return cls

    def get_intersections(self, set1, set2):
        new = []
        for c1 in set1:
            for c2 in set2:
                int = c1.intersection(c2)
                if len(int) > 0 and int not in set1 and int not in set2 and int not in new:
                    new += [int]
        return new

    def similarity(self, inventory, s1, s2):
        if s1 not in inventory or s2 not in inventory:
            raise ValueError("Segment not in inventory")
        cls = self.get_nat_classes(inventory)
        shared = [c for c in cls if s1 in c and s2 in c]
        s1_cls = [c for c in cls if s1 in c and s2 not in c]
        s2_cls = [c for c in cls if s2 in c and s1 not in c]

        return len(shared)/(len(shared) + len(s1_cls) + len(s2_cls))
