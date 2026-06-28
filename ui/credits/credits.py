import csv
import re
from dataclasses import dataclass

cat_map = {
        "Level Programmer": "Level",
        "UI Programmer": "UI",
        "Enemy Programmer": "Enemies",
        "Boss Programmer": "Bosses",
        "Player Programmer": "Player",

        "Music (Sound)": "Music",
        "SFX (Sound)": "SFX",
        "Cutscene Scores (Sound)": "Cutscene Scores",

        "Character Artist": "Character",
        "Enviormental Artist": "Environment",
        "Enemy/Boss Artist": "Enemy/Boss",
        "Weapon Artist": "Weapons",
        "Cutscene Artist": "Cutscenes",
        "UI (art)": "UI",


        "UI/UX Designer": "UI",
        "Enemies/bosses (design)": "Enemies/Bosses",
        "Weapons (design)": "Weapons",
        "Skill Tree (design)": "Skill Tree",
        "Systems Designer": "Systems",
        "Level Designer": "Level",
        "Narrative Designer & Scriptwriter (design)": "Narrative",
        "Character Designer": "Characters",
}

# category -> team
team_map = {
        "Level Programmer": "programming",
        "UI Programmer": "programming",
        "Enemy Programmer": "programming",
        "Boss Programmer": "programming",
        "Player Programmer": "programming",

        "Music (Sound)": "sound",
        "SFX (Sound)": "sound",
        "Cutscene Scores (Sound)": "sound",

        "Character Artist": "art",
        "Enviormental Artist": "art",
        "Enemy/Boss Artist": "art",
        "Weapon Artist": "art",
        "Cutscene Artist": "art",
        "UI (art)": "art",

        "UI/UX Designer": "design",
        "Enemies/bosses (design)": "design",
        "Weapons (design)": "design",
        "Skill Tree (design)": "design",
        "Systems Designer": "design",
        "Level Designer": "design",
        "Narrative Designer & Scriptwriter (design)": "design",
        "Character Designer": "design",
        "QA Tester": "design",
}

# team -> category
inv_team_map: dict[str, list[str]] = {}
for cat in team_map:
    team = team_map[cat]
    inv_team_map[team] = inv_team_map.get(team, []) + [cat]

@dataclass
class Person:
    name: str
    categories: list[str]

people_dict: dict[str, Person] = {}

regex = r',\s*(?![^()]*\))'
with open('gdignored/credits.csv', newline='') as csvfile:
    reader = csv.reader(csvfile)
    i = iter(reader)
    _ = next(i) # skip first line

    for row in i:
        name = row[1].strip()
        categories = re.split(regex, row[3])

        if name in people_dict: # if person exists, just update the list of categories
            person = people_dict[name]
            person.categories = list(set(person.categories) | set(categories))
        else:
            people_dict[name] = Person(name, categories)
        # meow


        # people.append(Person(name, categories, team))

people: list[Person] = list(people_dict.values())

people.sort(key = lambda p: p.name)

officers = [
    Person("Khalid Moosa", ["President"]),
    Person("Mira Maclennan", ["Vice President"]),
    Person("Joan Palacios", ["Production Manager"]),
    Person("Alex Xayavong", ["Assistant Production Manager"]),
    Person("Kaiden Zamora-Soon", ["Webmaster"]),
    Person("Jordan Tatum", ["Social Media Manager"]),
    Person("Jonathan Seek", ["Secretary"]),
    Person("Zachary Kim", ["Treasurer"]),

    Person("Jesse Park", ["Game Director"]),

    Person("Connor Hayes", ["Sound Director"]),
    Person("Grace Dorl", ["Assistant Sound Director"]),
    Person("Michael Campbell", ["Programming Co-director"]),
    Person("Justin Langdon", ["Programming Co-director"]),
    Person("Ethan Hayes", ["Design Director"]),
    Person("Kshaunish Shaik", ["Assistant Design Director"]),
    Person("Jordan McGill", ["Assistant Design Director"]),
    Person("Jonah Kossoy", ["Art Director"]),
    Person("Jordan Tatum", ["Assistant Art Director"]),
]

inv_team_map["officers"] = []
for officer in officers:
    people.append(officer)
    inv_team_map["officers"].append(officer.categories[0])
    team_map[officer.categories[0]] = "officers"

TEAM_FONT_SIZE = 75
CATEGORY_FONT_SIZE = 50
EPILOGUE_FONT_SIZE = 35

def print_with_shake(s: str):
    print(f"{s}")

def build_string(left: str, cats: list[str], length: int, max_right: int, pad: str =' ') -> str:
    cats = [cat_map.get(cat, cat) for cat in cats]
    cat_strings: list[str] = [""]
    for cat in cats:
        if len(cat_strings[-1]) > max_right:
            cat_strings[-1] += ','
            cat_strings.append("")
        if cat_strings[-1] == "":
            cat_strings[-1] = cat
        else:
            cat_strings[-1] += ", " + cat

    ret = ""
    ret += left + (pad * ((length - len(left) - len(cat_strings[0])) // len(pad))) + cat_strings[0]
    for s in cat_strings[1:]:
        ret += '' + (pad * ((length - len(s)) // len(pad))) + s

    return ret
    # length = length - len(left) - len(right)
    # return left + (pad * (length // len(pad))) + right

for team in ["sound", "programming", "design", "art", "officers"]:
    display_team = team.capitalize()
    print(f"2~{display_team}")

    # for person in prologue_people[team]:
    #     print(f"\t{person.role} {person.name}")

    for person in filter(
            lambda p: any([(cat in inv_team_map[team]) for cat in p.categories]), 
            people
    ):
        print_with_shake('3~'+build_string(person.name, list(filter(lambda c: c in inv_team_map[team], person.categories)), 50, 15))

    # print()

print("1~Thanks for playing!")