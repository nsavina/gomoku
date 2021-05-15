    Pattern[] patterns = [
        Pattern(r"7XXXX|X7XXX|XX7XX|XXX7X|XXXX7", r"7OOOO|O7OOO|OO7OO|OOO7O|OOOO7", 99999),
        Pattern(r".7XXX.|.X7XX.|.XX7X.|.XXX7.", r".7OOO.|.O7OO.|.OO7O.|.OOO7.", 7000),
        Pattern(r".7XXX|.X7XX|.XX7X|.XXX7", r".7OOO|.O7OO|.OO7O|.OOO7", 4000),
        Pattern(r"7XXX.|X7XX.|XX7X.|XXX7.", r"7OOO.|O7OO.|OO7O.|OOO7.", 4000),
        Pattern(r".7.XXX|.X.7XX|.X.X7X|.X.XX7", r".7.OOO|.O.7OO|.O.O7O|.O.OO7", 2000),
        Pattern(r".7X.XX|.X7.XX|.XX.7X|.XX.X7", r".7O.OO|.O7.OO|.OO.7O|.OO.O7", 2000),
        Pattern(r".7XX.X|.X7X.X|.XX7.X|.XXX.7", r".7OO.O|.O7O.O|.OO7.O|.OOO.7", 2000),
        Pattern(r"7XX.X.|X7X.X.|XX7.X.|XXX.7.", r"7OO.O.|O7O.O.|OO7.O.|OOO.7.", 2000),
        Pattern(r"7X.XX.|X7.XX.|XX.7X.|XX.X7.", r"7O.OO.|O7.OO.|OO.7O.|OO.O7.", 2000),
        Pattern(r"7.XXX.|X.7XX.|X.X7X.|X.XX7.", r"7.OOO.|O.7OO.|O.O7O.|O.OO7.", 2000),
        Pattern(r".7XX.|.X7X.|.XX7.", r".7OO.|.O7O.|.OO7.", 3000),
        Pattern(r".7XX|.X7X|.XX7", r".7OO|.O7O|.OO7", 1500),
        Pattern(r"7XX.|X7X.|XX7.", r"7OO.|O7O.|OO7.", 1500),
        Pattern(r".7X.X|.X7.X|.XX.7", r".7O.O|.O7.O|.OO.7", 800),
        Pattern(r".7.XX|.X.7X|.X.X7", r".7.OO|.O.7O|.O.O7", 800),
        Pattern(r"7X.X.|X7.X.|XX.7.", r"7O.O.|O7.O.|OO.7.", 800),
        Pattern(r"7.XX.|X.7X.|X.X7.", r"7.OO.|O.7O.|O.O7.", 800),
        Pattern(r".7X.|.X7.", r".7O.|.O7.", 200),
    ]