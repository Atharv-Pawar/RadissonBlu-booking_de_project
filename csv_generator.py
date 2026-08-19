import csv
import random
import re
import string
from copy import deepcopy
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP
from collections import defaultdict


# ============================================================
# CONFIGURATION
# ============================================================

random.seed(20260427)

TOTAL_RECORDS = 5000
OUTPUT_FILE = "next_5000_booking_records.csv"

columns = [
    "booking_id",
    "hotel_name",
    "hotel_city",
    "hotel_state",
    "hotel_zipcode",
    "hotel_country",
    "booking_for",
    "numbers_of_persons",
    "adults",
    "childrens",
    "days_of_stays",
    "check_in_timestamp",
    "check_out_timestamp",
    "requires_travels_facility",
    "mode_of_travels",
    "amount",
    "discount_category",
    "special_discount",
    "tax",
    "total_amounts",
    "rooms_booked",
    "room_type",
    "booking_source",
    "payment_method",
    "guest_email",
    "booking_status",
    "room_number",
    "guest_type",
    "guest_age",
    "guest_gender"
]


# ============================================================
# HOTEL DATA
# Format:
# (hotel_name, hotel_city, hotel_state, hotel_zipcode, country)
# ============================================================

hotels = [
    ("Radisson Blu Plaza Hotel Sydney", "Sydney", "New South Wales", "2000", "Australia"),
    ("Radisson Blu Dhaka Water Garden", "Dhaka", "Dhaka Division", "1206", "Bangladesh"),
    ("Radisson Blu Chattogram Bay View", "Chattogram", "Chattogram Division", "4000", "Bangladesh"),
    ("Radisson Blu Astrid Hotel Antwerp", "Antwerp", "Antwerp", "2018", "Belgium"),
    ("Radisson Blu Royal Hotel Brussels", "Brussels", "Brussels-Capital", "1000", "Belgium"),
    ("Radisson Blu Toronto Downtown", "Toronto", "Ontario", "M5J 2N5", "Canada"),
    ("Radisson Blu Scandinavia Hotel Copenhagen", "Copenhagen", "Capital Region", "2300", "Denmark"),
    ("Radisson Blu Hotel Alexandria", "Alexandria", "Alexandria Governorate", "21934", "Egypt"),
    ("Radisson Blu Hotel Cairo Heliopolis", "Cairo", "Cairo Governorate", "11757", "Egypt"),
    ("Radisson Blu Hotel Addis Ababa", "Addis Ababa", "Addis Ababa", "1000", "Ethiopia"),
    ("Radisson Blu Hotel Espoo", "Espoo", "Uusimaa", "02130", "Finland"),
    ("Radisson Blu Seaside Hotel Helsinki", "Helsinki", "Uusimaa", "00180", "Finland"),
    ("Radisson Blu Hotel Oulu", "Oulu", "North Ostrobothnia", "90100", "Finland"),
    ("Radisson Blu Hotel Lyon", "Lyon", "Auvergne-Rhone-Alpes", "69003", "France"),
    ("Radisson Blu Hotel Nice", "Nice", "Provence-Alpes-Cote d'Azur", "06200", "France"),
    ("Radisson Blu Hotel Paris Boulogne", "Boulogne-Billancourt", "Ile-de-France", "92100", "France"),
    ("Radisson Blu Hotel Bremen", "Bremen", "Bremen", "28195", "Germany"),
    ("Radisson Blu Hotel Cologne", "Cologne", "North Rhine-Westphalia", "50679", "Germany"),
    ("Radisson Blu Hotel Dortmund", "Dortmund", "North Rhine-Westphalia", "44139", "Germany"),
    ("Radisson Blu Conference Hotel Dusseldorf", "Dusseldorf", "North Rhine-Westphalia", "40474", "Germany"),
    ("Radisson Blu Hotel Frankfurt", "Frankfurt", "Hesse", "60486", "Germany"),
    ("Radisson Blu Hotel Hamburg", "Hamburg", "Hamburg", "20355", "Germany"),

    # India
    ("Radisson Blu Hotel Amritsar", "Amritsar", "Punjab", "143001", "India"),
    ("Radisson Blu Atria Bengaluru", "Bengaluru", "Karnataka", "560001", "India"),
    ("Radisson Blu Bengaluru Outer Ring Road", "Bengaluru", "Karnataka", "560037", "India"),
    ("Radisson Blu Hotel Chennai City Centre", "Chennai", "Tamil Nadu", "600008", "India"),
    ("Radisson Blu Hotel and Suites GRT Chennai", "Chennai", "Tamil Nadu", "600016", "India"),
    ("Radisson Blu Coimbatore", "Coimbatore", "Tamil Nadu", "641004", "India"),
    ("Radisson Blu Hotel Guwahati", "Guwahati", "Assam", "781033", "India"),
    ("Radisson Blu Plaza Hotel Hyderabad Banjara Hills", "Hyderabad", "Telangana", "500034", "India"),
    ("Radisson Blu Hotel Indore", "Indore", "Madhya Pradesh", "452010", "India"),
    ("Radisson Blu Jaipur", "Jaipur", "Rajasthan", "302018", "India"),
    ("Radisson Blu Jammu", "Jammu", "Jammu and Kashmir", "180004", "India"),
    ("Radisson Blu Kochi", "Kochi", "Kerala", "682020", "India"),
    ("Radisson Blu Mumbai International Airport", "Mumbai", "Maharashtra", "400059", "India"),
    ("Radisson Blu Hotel Nagpur", "Nagpur", "Maharashtra", "440015", "India"),
    ("Radisson Blu Hotel New Delhi Dwarka", "New Delhi", "Delhi", "110075", "India"),
    ("Radisson Blu Plaza Delhi Airport", "New Delhi", "Delhi", "110037", "India"),
    ("Radisson Blu MBD Hotel Noida", "Noida", "Uttar Pradesh", "201301", "India"),
    ("Radisson Blu Hotel Pune Kharadi", "Pune", "Maharashtra", "411014", "India"),
    ("Radisson Blu Hotel Ranchi", "Ranchi", "Jharkhand", "834001", "India"),
    ("Radisson Blu Hotel Rudrapur", "Rudrapur", "Uttarakhand", "263153", "India"),
    ("Radisson Blu Udaipur Palace Resort and Spa", "Udaipur", "Rajasthan", "313001", "India"),

    # Ireland
    ("Radisson Blu Hotel Athlone", "Athlone", "County Westmeath", "N37 A8X9", "Ireland"),
    ("Radisson Blu Hotel and Spa Cork", "Cork", "County Cork", "T45 WF53", "Ireland"),
    ("Radisson Blu Royal Hotel Dublin", "Dublin", "County Dublin", "D08 VRR7", "Ireland"),
    ("Radisson Blu St Helen's Hotel Dublin", "Dublin", "County Dublin", "A94 V6W3", "Ireland"),
    ("Radisson Blu Hotel Dublin Airport", "Dublin", "County Dublin", "K67 H5H9", "Ireland"),
    ("Radisson Blu Hotel and Spa Limerick", "Limerick", "County Limerick", "V94 YA2R", "Ireland"),
    ("Radisson Blu Hotel and Spa Sligo", "Sligo", "County Sligo", "F91 XW7Y", "Ireland"),

    # Kenya
    ("Radisson Blu Hotel Nairobi Upper Hill", "Nairobi", "Nairobi County", "00100", "Kenya"),
    ("Radisson Blu Hotel and Residence Nairobi Arboretum", "Nairobi", "Nairobi County", "00100", "Kenya"),

    # Other countries
    ("Radisson Blu Hotel Kuwait", "Kuwait City", "Al Asimah", "13122", "Kuwait"),
    ("Radisson Blu Latvija Conference and Spa Hotel", "Riga", "Riga", "LV-1010", "Latvia"),
    ("Radisson Blu Elizabete Hotel Riga", "Riga", "Riga", "LV-1050", "Latvia"),
    ("Radisson Blu Hotel Lietuva Vilnius", "Vilnius", "Vilnius County", "LT-09308", "Lithuania"),
    ("Radisson Blu Royal Astorija Hotel Vilnius", "Vilnius", "Vilnius County", "LT-01128", "Lithuania"),
    ("Radisson Blu Hotel Casablanca City Center", "Casablanca", "Casablanca-Settat", "20250", "Morocco"),
    ("Radisson Blu Hotel Marrakech Carre Eden", "Marrakech", "Marrakesh-Safi", "40000", "Morocco"),
    ("Radisson Blu Hotel and Residence Maputo", "Maputo", "Maputo", "1100", "Mozambique"),
    ("Radisson Blu Hotel Amsterdam City Center", "Amsterdam", "North Holland", "1012 CP", "Netherlands"),
    ("Radisson Blu Hotel Amsterdam Airport Schiphol", "Schiphol-Rijk", "North Holland", "1119 PT", "Netherlands"),
    ("Radisson Blu Anchorage Hotel Lagos", "Lagos", "Lagos State", "101241", "Nigeria"),
    ("Radisson Blu Hotel Lagos Ikeja", "Ikeja", "Lagos State", "100271", "Nigeria"),
    ("Radisson Blu Royal Hotel Bergen", "Bergen", "Vestland", "5003", "Norway"),
    ("Radisson Blu Plaza Hotel Oslo", "Oslo", "Oslo", "0185", "Norway"),
    ("Radisson Blu Scandinavia Hotel Oslo", "Oslo", "Oslo", "0161", "Norway"),
    ("Radisson Blu Atlantic Hotel Stavanger", "Stavanger", "Rogaland", "4005", "Norway"),
    ("Radisson Blu Hotel Tromso", "Tromso", "Troms", "9259", "Norway"),
    ("Radisson Blu Hotel Gdansk", "Gdansk", "Pomeranian", "80-828", "Poland"),
    ("Radisson Blu Hotel Krakow", "Krakow", "Lesser Poland", "31-101", "Poland"),
    ("Radisson Blu Hotel Sopot", "Sopot", "Pomeranian", "81-718", "Poland"),
    ("Radisson Blu Hotel Szczecin", "Szczecin", "West Pomeranian", "70-419", "Poland"),
    ("Radisson Blu Sobieski Hotel Warsaw", "Warsaw", "Masovian", "02-025", "Poland"),
    ("Radisson Blu Hotel Wroclaw", "Wroclaw", "Lower Silesian", "50-156", "Poland"),
    ("Radisson Blu Hotel Doha", "Doha", "Doha", "1768", "Qatar"),
    ("Radisson Blu Hotel and Convention Centre Kigali", "Kigali", "Kigali", "N/A", "Rwanda"),
    ("Radisson Blu Hotel Riyadh", "Riyadh", "Riyadh Province", "11484", "Saudi Arabia"),
    ("Radisson Blu Hotel Dakar Sea Plaza", "Dakar", "Dakar Region", "BP 16868", "Senegal"),
    ("Radisson Blu Hotel Waterfront Cape Town", "Cape Town", "Western Cape", "8002", "South Africa"),
    ("Radisson Blu Hotel and Residence Cape Town", "Cape Town", "Western Cape", "8001", "South Africa"),
    ("Radisson Blu Hotel Gqeberha", "Gqeberha", "Eastern Cape", "6001", "South Africa"),
    ("Radisson Blu Scandinavia Hotel Gothenburg", "Gothenburg", "Vastra Gotaland", "S-401 24", "Sweden"),
    ("Radisson Blu Riverside Hotel Gothenburg", "Gothenburg", "Vastra Gotaland", "417 56", "Sweden"),
    ("Radisson Blu Hotel Malmo", "Malmo", "Skane", "211 35", "Sweden"),
    ("Radisson Blu Royal Viking Hotel Stockholm", "Stockholm", "Stockholm County", "111 20", "Sweden"),
    ("Radisson Blu Waterfront Hotel Stockholm", "Stockholm", "Stockholm County", "111 64", "Sweden"),
    ("Radisson Blu Hotel Basel", "Basel", "Basel-Stadt", "4051", "Switzerland"),
    ("Radisson Blu Hotel Lucerne", "Lucerne", "Lucerne", "6005", "Switzerland"),
    ("Radisson Blu Hotel Zurich Airport", "Zurich", "Zurich", "8058", "Switzerland"),
    ("Radisson Blu Hotel Istanbul Pera", "Istanbul", "Istanbul", "34430", "Turkey"),
    ("Radisson Blu Hotel Istanbul Sisli", "Istanbul", "Istanbul", "34360", "Turkey"),
    ("Radisson Blu Hotel Vadistanbul", "Istanbul", "Istanbul", "34396", "Turkey"),
    ("Radisson Blu Hotel Abu Dhabi Yas Island", "Abu Dhabi", "Abu Dhabi", "93725", "United Arab Emirates"),
    ("Radisson Blu Hotel Dubai Deira Creek", "Dubai", "Dubai", "476", "United Arab Emirates"),
    ("Radisson Blu Hotel Dubai Media City", "Dubai", "Dubai", "211723", "United Arab Emirates"),
    ("Radisson Blu Hotel Dubai Waterfront", "Dubai", "Dubai", "N/A", "United Arab Emirates"),
    ("Radisson Blu Hotel Birmingham", "Birmingham", "England", "B1 1BT", "United Kingdom"),
    ("Radisson Blu Hotel Bristol", "Bristol", "England", "BS1 4BY", "United Kingdom"),
    ("Radisson Blu Hotel Cardiff", "Cardiff", "Wales", "CF10 2FL", "United Kingdom"),
    ("Radisson Blu Hotel Edinburgh City Centre", "Edinburgh", "Scotland", "EH1 1TH", "United Kingdom"),
    ("Radisson Blu Hotel Glasgow", "Glasgow", "Scotland", "G2 8DL", "United Kingdom"),
    ("Radisson Blu Hotel Leeds City Centre", "Leeds", "England", "LS1 5DL", "United Kingdom"),
    ("Radisson Blu Hotel London Stansted Airport", "Stansted", "England", "CM24 1PP", "United Kingdom"),
    ("Radisson Blu Hotel Manchester Airport", "Manchester", "England", "M90 3RA", "United Kingdom"),
    ("Radisson Blu Mall of America", "Bloomington", "MN", "55425", "USA"),
    ("Radisson Blu Aqua Hotel Chicago", "Chicago", "IL", "60601", "USA"),
    ("Park Plaza Vondelpark, Amsterdam", "Amsterdam", "North Holland", "1071 AJ", "Netherlands"),
    ("Park Plaza Victoria Amsterdam", "Amsterdam", "North Holland", "1012 LG", "Netherlands"),
    ("art'otel Amsterdam", "Amsterdam", "North Holland", "1012 AB", "Netherlands"),
    ("Park Inn by Radisson Amsterdam City West", "Amsterdam", "North Holland", "1043 NT", "Netherlands"),

    ("Park Plaza Bangkok Soi 18", "Bangkok", "Bangkok", "10110", "Thailand"),

    ("art'otel Berlin Mitte", "Berlin", "Berlin", "10179", "Germany"),
    ("Park Plaza Berlin", "Berlin", "Berlin", "10789", "Germany"),

    ("Hotel Erzsébet City Center Budapest", "Budapest", "Budapest", "1053", "Hungary"),
    ("Park Inn by Radisson Budapest", "Budapest", "Budapest", "1138", "Hungary"),

    ("Park Plaza London Riverbank", "London", "England", "SE1 7TJ", "United Kingdom"),
    ("Park Plaza Westminster Bridge London", "London", "England", "SE1 7UT", "United Kingdom"),
    ("Park Plaza County Hall London", "London", "England", "SE1 7UT", "United Kingdom"),
    ("Park Plaza London Waterloo", "London", "England", "SE1 7UT", "United Kingdom"),

    ("Park Inn by Radisson London Heathrow", "London", "England", "UB7 0EA", "United Kingdom"),
    ("Park Inn by Radisson Manchester City Centre", "Manchester", "England", "M4 4HY", "United Kingdom"),
    ("Park Inn by Radisson Birmingham Walsall", "Walsall", "England", "WS2 8TJ", "United Kingdom"),

    ("Park Plaza Cardiff", "Cardiff", "Wales", "CF10 3AL", "United Kingdom"),
    ("Park Inn by Radisson Cardiff City Centre", "Cardiff", "Wales", "CF10 2JX", "United Kingdom"),
    ("Park Plaza Leeds", "Leeds", "England", "LS1 5PS", "United Kingdom"),
    ("Park Plaza Nottingham", "Nottingham", "England", "NG1 6FL", "United Kingdom"),
    ("Park Plaza Birmingham", "Birmingham", "England", "B1 1BN", "United Kingdom"),

    ("Park Plaza County Hall Berlin", "Berlin", "Berlin", "10785", "Germany"),
    ("Park Inn by Radisson Berlin Alexanderplatz", "Berlin", "Berlin", "10178", "Germany"),

    ("Park Inn by Radisson Frankfurt Airport", "Frankfurt", "Hesse", "60549", "Germany"),
    ("Park Inn by Radisson Cologne City West", "Cologne", "North Rhine-Westphalia", "50823", "Germany"),
    ("Park Inn by Radisson Stuttgart", "Stuttgart", "Baden-Württemberg", "70173", "Germany"),

    ("Park Inn by Radisson Brussels Midi", "Brussels", "Brussels-Capital", "1060", "Belgium"),
    ("Park Inn by Radisson Antwerp Berchem", "Antwerp", "Antwerp", "2600", "Belgium"),

    ("Park Inn by Radisson Oslo", "Oslo", "Oslo", "0155", "Norway"),
    ("Park Inn by Radisson Stockholm Hammarby Sjostad", "Stockholm", "Stockholm County", "120 30", "Sweden"),
    ("Park Inn by Radisson Gothenburg", "Gothenburg", "Vastra Gotaland", "412 50", "Sweden"),

    ("Park Plaza Utrecht", "Utrecht", "Utrecht", "3511 CE", "Netherlands"),
    ("Park Plaza Eindhoven", "Eindhoven", "North Brabant", "5611 AJ", "Netherlands"),
    ("Park Plaza Maastricht", "Maastricht", "Limburg", "6221 EN", "Netherlands"),

    ("art'otel Cologne", "Cologne", "North Rhine-Westphalia", "50667", "Germany"),
    ("art'otel Berlin Kudamm", "Berlin", "Berlin", "10719", "Germany"),
    ("art'otel London Battersea Power Station", "London", "England", "SW11 8AL", "United Kingdom"),

    ("Park Plaza Nuremberg", "Nuremberg", "Bavaria", "90443", "Germany"),
    ("Park Plaza Trier", "Trier", "Rhineland-Palatinate", "54292", "Germany"),

    ("Park Plaza Beijing Wangfujing", "Beijing", "Beijing", "100006", "China"),
    ("Park Plaza Shanghai Science and Technology Park", "Shanghai", "Shanghai", "201204", "China"),

    ("Park Plaza Sukhumvit Bangkok", "Bangkok", "Bangkok", "10110", "Thailand"),
    ("Park Plaza Bangkok Soi 18", "Bangkok", "Bangkok", "10110", "Thailand"),

    ("Park Inn by Radisson Danang", "Da Nang", "Da Nang", "550000", "Vietnam"),
    ("Park Inn by Radisson Clark", "Clark", "Pampanga", "2023", "Philippines"),

    ("Park Plaza Chennai OMR", "Chennai", "Tamil Nadu", "600119", "India"),
    ("Park Plaza Faridabad", "Faridabad", "Haryana", "121003", "India"),
    ("Park Plaza Ludhiana", "Ludhiana", "Punjab", "141001", "India"),
    ("Park Inn by Radisson New Delhi IP Extension", "New Delhi", "Delhi", "110092", "India"),
    ("Park Inn by Radisson Gurgaon Bilaspur", "Gurugram", "Haryana", "122413", "India"),
    ("Park Plaza Chandigarh Zirakpur", "Zirakpur", "Punjab", "140603", "India"),

    ("Park Plaza Sukhumvit Bangkok", "Bangkok", "Bangkok", "10110", "Thailand"),

    ("Park Inn by Radisson Bucharest Hotel & Residence", "Bucharest", "Bucharest", "010131", "Romania"),
    ("Park Inn by Radisson Krakow", "Krakow", "Lesser Poland", "31-416", "Poland"),
    ("Park Inn by Radisson Poznan", "Poznan", "Greater Poland", "60-813", "Poland"),
    ("Park Inn by Radisson Katowice", "Katowice", "Silesian", "40-026", "Poland"),

    ("Park Inn by Radisson Pristina", "Pristina", "Pristina District", "10000", "Kosovo"),
    ("Park Inn by Radisson Yerevan", "Yerevan", "Yerevan", "0010", "Armenia"),

    ("Park Inn by Radisson Istanbul Atasehir", "Istanbul", "Istanbul", "34746", "Turkey"),
    ("Park Inn by Radisson Izmir", "Izmir", "Izmir", "35410", "Turkey"),
    ("Park Plaza Dubai Science Park", "Dubai", "Dubai", "500001", "United Arab Emirates"),
    ("Park Inn by Radisson Dubai Motor City", "Dubai", "Dubai", "39215", "United Arab Emirates"),
    ("Park Inn by Radisson Abu Dhabi Yas Island", "Abu Dhabi", "Abu Dhabi", "93725", "United Arab Emirates"),

    ("Park Plaza Doha", "Doha", "Doha", "00000", "Qatar"),
    ("Park Inn by Radisson Riyadh", "Riyadh", "Riyadh Province", "12214", "Saudi Arabia"),

    ("Park Inn by Radisson Cape Town Foreshore", "Cape Town", "Western Cape", "8001", "South Africa"),
    ("Park Inn by Radisson Johannesburg Sandton", "Johannesburg", "Gauteng", "2031", "South Africa"),

    ("Park Plaza Minneapolis Mall of America", "Bloomington", "MN", "55425", "USA"),
    ("Park Inn by Radisson New York City", "New York", "NY", "10001", "USA")
]


# ============================================================
# GUEST DATA
# ============================================================

first_names = [
    # Existing names
    "olivia", "liam", "emma", "noah", "amelia", "oliver", "sophia",
    "elijah", "isabella", "lucas", "mia", "james", "charlotte", "henry",
    "ava", "benjamin", "luna", "theodore", "camila", "jack", "harper",
    "alexander", "evelyn", "daniel", "scarlett", "michael", "eleanor",
    "ethan", "abigail", "logan", "emily", "sebastian", "hazel", "mason",
    "lily", "jacob", "violet", "william", "aurora", "owen",
    "sophie", "aiden", "grace", "carter", "chloe", "angela", "maya",
    "hritik", "ananya", "arjun", "priya", "rohit", "sneha", "vijay",
    "pooja", "divya", "supriya", "rahul", "priyanka", "suresh",
    "meera", "vivek", "anita", "rakesh",

    # More Indian names
    "aditya", "akshay", "aman", "amit", "ankit", "ayush",
    "deepak", "dhruv", "gaurav", "harsh", "ishaan", "karan",
    "kunal", "manish", "mohit", "naveen", "nikhil", "nitin",
    "pankaj", "pranav", "raj", "rajesh", "ravi", "sachin",
    "sahil", "sameer", "sanjay", "shubham", "tushar", "varun",
    "vishal", "yash", "yuvraj",

    "aadhya", "aakanksha", "aditi", "akshara", "alisha", "bhavna",
    "diya", "isha", "janhavi", "kajal", "kavya", "khushi",
    "kriti", "lakshmi", "madhuri", "neha", "nidhi", "nikita",
    "palak", "payal", "radhika", "riya", "sakshi", "shalini",
    "shreya", "simran", "tanvi", "trisha", "vaishnavi", "vidhi",

    # American / European names
    "aaron", "adam", "adrian", "alan", "andrew", "anthony",
    "arthur", "austin", "brandon", "brian", "caleb", "charles",
    "chris", "christian", "connor", "david", "dylan", "edward",
    "evan", "gabriel", "george", "grayson", "jackson", "jason",
    "jeremy", "jonathan", "jordan", "joseph", "joshua", "julian",
    "kevin", "leon", "levi", "matthew", "max", "nathan",
    "nicholas", "nolan", "patrick", "ryan", "samuel", "steven",
    "thomas", "tyler", "victor", "zachary",

    "alice", "anna", "anna", "bella", "caroline", "claire",
    "clara", "elena", "ella", "ellie", "elizabeth", "ellie",
    "eva", "faith", "florence", "hannah", "isla", "jade",
    "jasmine", "julia", "kate", "kayla", "lauren", "leah",
    "lillian", "lucy", "madeline", "madison", "natalie",
    "nora", "penelope", "rachel", "rebecca", "rose", "ruby",
    "samantha", "sarah", "stella", "victoria", "zoe",

    # Middle Eastern names
    "ahmed", "ali", "amr", "bilal", "faisal", "farhan",
    "hamza", "hassan", "ibrahim", "imran", "khalid", "mahmoud",
    "mohammed", "mustafa", "omar", "osman", "rashid", "saad",
    "salman", "tariq", "waleed", "yusuf",

    "aisha", "amina", "fatima", "hana", "huda", "iman",
    "layla", "maryam", "nadia", "noor", "sana", "sara",
    "yasmin", "zainab",

    # East / Southeast Asian names
    "wei", "ming", "jun", "chen", "hao", "li", "yang",
    "jie", "kai", "tao", "yuki", "haruto", "ren", "akira",
    "kenji", "sora", "mei", "rina", "yuna", "hana",
    "minji", "jiwoo", "seojun", "hyunwoo",

    # African names
    "abebe", "chinedu", "emeka", "kwame", "kofi", "mandla",
    "musa", "olumide", "tendai", "thabo", "youssef",
    "amina", "amara", "ayomide", "chioma", "eshe", "ifunanya",
    "nala", "zola"
]

last_names = [
    # Existing names
    "smith", "johnson", "williams", "brown", "jones", "garcia", "miller",
    "davis", "rodriguez", "martinez", "hernandez", "lopez", "gonzalez",
    "wilson", "anderson", "thomas", "taylor", "moore", "jackson", "martin",
    "lee", "perez", "thompson", "white", "harris", "sanchez", "clark",
    "ramirez", "lewis", "robinson", "walker", "young", "allen", "king",
    "wright", "scott", "torres", "nguyen", "hill", "flores",
    "pandey", "doe", "none", "kumar", "sharma", "khan", "khanna", "dutta",

    # --------------------------------------------------------
    # More Indian surnames
    # --------------------------------------------------------

    "agarwal", "ahmed", "arora", "bansal", "bhatt", "bhatia",
    "bhattacharya", "biswas", "bohra", "chakraborty", "chandra",
    "chauhan", "chopra", "das", "desai", "dhawan", "dubey",
    "gandhi", "ganguly", "ghosh", "gill", "goel", "gupta",
    "iyer", "jain", "joshi", "kapoor", "kashyap", "kaur",
    "kulkarni", "malhotra", "mehta", "menon", "mishra", "modi",
    "nair", "narang", "nayak", "pandit", "patel", "pawar",
    "pillai", "prasad", "rao", "reddy", "roy", "saxena",
    "sen", "sethi", "singh", "sinha", "sodhi", "srivastava",
    "thakur", "tiwari", "tripathi", "varma", "verma", "yadav",

    # --------------------------------------------------------
    # More American / European surnames
    # --------------------------------------------------------

    "adams", "baker", "bell", "bennett", "brooks", "carter",
    "collins", "cooper", "cook", "cox", "edwards", "evans",
    "fisher", "foster", "gray", "griffin", "hall", "hayes",
    "henderson", "holmes", "howard", "hughes", "hunt",
    "jenkins", "kelly", "kennedy", "lawson", "morgan", "murphy",
    "nelson", "parker", "peterson", "phillips", "powell",
    "price", "reed", "richardson", "riley", "roberts", "ross",
    "russell", "ryan", "sanders", "shaw", "simpson", "stewart",
    "sullivan", "turner", "ward", "watson", "webb", "west",
    "wood", "woods",

    # --------------------------------------------------------
    # Spanish / Portuguese surnames
    # --------------------------------------------------------

    "alvarez", "castro", "costa", "cruz", "diaz", "dominguez",
    "fernandez", "gomez", "herrera", "jimenez", "marquez",
    "mendoza", "morales", "navarro", "ortega", "ortiz",
    "ramos", "rivera", "romero", "ruiz", "silva", "soto",
    "suarez", "vargas", "vasquez", "vega",

    # --------------------------------------------------------
    # French surnames
    # --------------------------------------------------------

    "bernard", "blanc", "bonnet", "chevalier", "dubois",
    "duval", "fontaine", "fournier", "garnier", "girard",
    "leblanc", "leclerc", "legrand", "martin", "moreau",
    "perrin", "robert", "rousseau", "thomas",

    # --------------------------------------------------------
    # German surnames
    # --------------------------------------------------------

    "bauer", "becker", "brandt", "fischer", "frank", "franke",
    "friedrich", "graf", "gross", "hartmann", "hoffmann",
    "horn", "jung", "keller", "klein", "krause", "kruger",
    "lang", "lange", "maier", "meyer", "neumann", "richter",
    "schmidt", "schneider", "scholz", "schroeder", "schubert",
    "schulz", "schumacher", "schwarz", "stein", "weber",
    "zimmermann",

    # --------------------------------------------------------
    # Scandinavian surnames
    # --------------------------------------------------------

    "andersson", "berg", "dahl", "eriksson", "hansen", "hansson",
    "johansson", "karlsson", "larsen", "larsson", "lind",
    "lund", "nielsen", "nilsson", "olsen", "olsson", "pettersson",
    "sorensen", "svensson",

    # --------------------------------------------------------
    # Eastern European surnames
    # --------------------------------------------------------

    "ivanov", "ivanova", "kowalski", "kovacs", "kuznetsov",
    "lewandowski", "novak", "nowak", "petrov", "popov",
    "sokolov", "volkov", "wagner", "wojcik", "zielinski",

    # --------------------------------------------------------
    # Middle Eastern surnames
    # --------------------------------------------------------

    "abdullah", "alavi", "almasri", "alsayed", "farooq",
    "haddad", "hamdan", "hassan", "hussein", "ibrahim",
    "jaber", "khalil", "mansour", "mohamed", "nasser",
    "rahman", "saleh", "shah", "syed", "younis",

    # --------------------------------------------------------
    # African surnames
    # --------------------------------------------------------

    "adebayo", "adewale", "chukwu", "diallo", "dlamini",
    "duarte", "kone", "mensah", "moyo", "ndlovu", "okafor",
    "okoro", "oluwaseun", "owusu", "sarpong", "toure",
    "traore", "williams",

    # --------------------------------------------------------
    # Chinese / East Asian surnames
    # --------------------------------------------------------

    "chen", "cheng", "fang", "gao", "han", "huang", "lin",
    "liu", "ma", "peng", "sun", "tang", "wang", "wu",
    "xiao", "xu", "yang", "zhang", "zhao", "zhou",

    # Japanese surnames
    "sato", "suzuki", "takahashi", "tanaka", "watanabe",
    "ito", "yamamoto", "nakamura", "kobayashi", "kato",
    "yoshida", "yamada", "sasakI", "yamaguchi", "matsumoto",

    # Korean surnames
    "kim", "park", "choi", "jung", "kang", "cho", "yoon",
    "jang", "lim", "han", "shin", "seo",

    # --------------------------------------------------------
    # Additional international surnames
    # --------------------------------------------------------

    "alexander", "marshall", "mitchell", "mason", "owens",
    "palmer", "porter", "powers", "quinn", "reynolds",
    "robinson", "spencer", "stevens", "stone", "sutton",
    "walker", "warren", "washington", "wilkins", "wilkinson",
    "williams", "wilson", "wong", "young"
]

invalid_emails = [
    "invalid-email",
    "user@",
    "@example.com",
    "guest.example.com",
    "user@@example.com",
    "user@.com",
    "user domain@example.com",
    "guest#example.com",
    "missing-at-sign.com",
    "user@example",
    "None",
    "",
    "john..doe@example.com",
    "user@domain..com"
]


# ============================================================
# BOOKING DATA
# ============================================================

room_types = [
    "Standard Queen",
    "Standard King",
    "Deluxe Queen",
    "Deluxe King",
    "Executive King",
    "Executive Twin",
    "Family Suite",
    "Ocean View King",
    "Double Room",
    "Cabin Suite"
]

booking_sources = [
    "Website",
    "Mobile App",
    "Travel Agent",
    "Corporate Portal",
    "Walk-in"
]

payment_methods = [
    "Credit Card",
    "Debit Card",
    "PayPal",
    "Cash",
    "Invoice"
]

booking_statuses = [
    "Confirmed",
    "Confirmed",
    "Confirmed",
    "Pending",
    "Cancelled",
    "Completed"
]

discount_rates = {
    "None": Decimal("0.00"),
    "Seasonal": Decimal("0.10"),
    "Corporate": Decimal("0.10"),
    "Holiday": Decimal("0.10"),
    "Early Bird": Decimal("0.10"),
    "Member": Decimal("0.10"),
    "Group": Decimal("0.10")
}

travel_modes = [
    "Flight",
    "Car",
    "Train",
    "Bus"
]

guest_types = [
    "Regular",
    "Regular",
    "VIP",
    "Corporate"
]


# ============================================================
# HELPER FUNCTIONS
# ============================================================

def money(value):
    return str(
        Decimal(value).quantize(
            Decimal("0.01"),
            rounding=ROUND_HALF_UP
        )
    )


# Separate RNG so booking ID randomness does not disturb
# the main random data generation.
id_rng = random.Random(987654321)

ALNUM = string.ascii_lowercase + string.digits

_STOPWORDS = {
    "the",
    "of",
    "and",
    "at",
    "on",
    "de",
    "la",
    "le",
    "es",
    "s"
}


def hotel_code(name, length=5):
    """
    Generate a short hotel code from hotel name.
    Example:
        Radisson Blu Plaza Hotel Sydney
        -> RBSPH
    """

    if not name or name.strip().lower() in {
        "none",
        "null",
        "nan",
        ""
    }:
        return "UNKWN"

    words = [
        word
        for word in re.findall(r"[A-Za-z0-9]+", name)
        if word.lower() not in _STOPWORDS
    ]

    if not words:
        return "UNKWN"

    code = "".join(
        word[0]
        for word in words
    ).upper()

    if len(code) < length:
        last_word = re.sub(
            r"[^A-Za-z0-9]",
            "",
            words[-1]
        ).upper()

        code += last_word[1:]

    return code[:length].ljust(
        length,
        "X"
    )


_code_by_name = {}
_used_codes = set()


def get_code(name):
    """
    Generate one stable and unique code per hotel.
    """

    if name in _code_by_name:
        return _code_by_name[name]

    base = hotel_code(name)
    code = base
    n = 1

    while code in _used_codes:

        n += 1
        suffix = str(n)

        code = (
            base[:5 - len(suffix)]
            + suffix
        )

    _code_by_name[name] = code
    _used_codes.add(code)

    return code


hotel_counters = defaultdict(int)
issued_ids = set()


def make_booking_id(name):
    """
    Generate unique booking ID.

    Example:
    BKRBSPH-a1b2-0001-x9yz
    """

    code = get_code(name)

    hotel_counters[code] += 1

    idx = str(
        hotel_counters[code]
    ).zfill(4)

    while True:

        random_part_1 = "".join(
            id_rng.choices(
                ALNUM,
                k=4
            )
        )

        random_part_2 = "".join(
            id_rng.choices(
                ALNUM,
                k=4
            )
        )

        bid = (
            f"BK{code}-"
            f"{random_part_1}-"
            f"{idx}-"
            f"{random_part_2}"
        )

        if bid not in issued_ids:

            issued_ids.add(bid)

            return bid


# ============================================================
# GENERATE RECORDS
# ============================================================

start_date = datetime(
    2026,
    4,
    27,
    15,
    0,
    0
)

records = []


for index in range(TOTAL_RECORDS):

    # --------------------------------------------------------
    # Select hotel FIRST
    # --------------------------------------------------------

    hotel_name, city, state, zipcode, country = random.choice(
        hotels
    )

    # Intentionally create NULL-like hotel values
    if index % 19 == 0:
        hotel_name = "None"

    # --------------------------------------------------------
    # Generate booking ID AFTER hotel selection
    # --------------------------------------------------------

    booking_number = make_booking_id(
        hotel_name
    )

    # --------------------------------------------------------
    # Create exact duplicate approximately every 57 records
    # --------------------------------------------------------

    if (
        index > 0
        and index % 57 == 0
    ):
        records.append(
            deepcopy(records[-1])
        )
        continue

    # --------------------------------------------------------
    # Booking type
    # --------------------------------------------------------

    booking_for = random.choice([
        "Leisure",
        "Leisure",
        "Business"
    ])

    # --------------------------------------------------------
    # Guests
    # --------------------------------------------------------

    if booking_for == "Business":

        adults = random.randint(
            1,
            3
        )

        childrens = 0

    else:

        adults = random.randint(
            1,
            4
        )

        childrens = random.randint(
            0,
            3
        )

    number_of_persons = (
        adults
        + childrens
    )

    # --------------------------------------------------------
    # Stay / rooms
    # --------------------------------------------------------

    days = random.randint(
        1,
        7
    )

    rooms_booked = max(
        1,
        (number_of_persons + 2) // 3
    )

    # --------------------------------------------------------
    # Check-in / Check-out
    # --------------------------------------------------------

    check_in = (
        start_date
        + timedelta(days=index * 2)
    )

    check_in = check_in.replace(
        hour=random.choice([
            13,
            14,
            15,
            16
        ]),
        minute=0,
        second=0
    )

    check_out = (
        check_in
        + timedelta(days=days)
    )

    check_out = check_out.replace(
        hour=random.choice([
            10,
            11,
            12
        ]),
        minute=0,
        second=0
    )

    # --------------------------------------------------------
    # Travel facility
    # --------------------------------------------------------

    requires_travel = (
        "Yes"
        if (
            booking_for == "Business"
            or random.random() < 0.25
        )
        else "No"
    )

    travel_mode = random.choice(
        travel_modes
    )

    # --------------------------------------------------------
    # Room
    # --------------------------------------------------------

    room_type = random.choice(
        room_types
    )

    # --------------------------------------------------------
    # Pricing
    # --------------------------------------------------------

    nightly_rate = random.choice([
        120,
        140,
        160,
        180,
        200,
        220,
        250,
        280,
        300
    ])

    base_amount = Decimal(
        nightly_rate
        * days
        * rooms_booked
    ).quantize(
        Decimal("0.01")
    )

    # --------------------------------------------------------
    # Discount
    # --------------------------------------------------------

    if booking_for == "Business":

        discount_category = random.choice([
            "Corporate",
            "Corporate",
            "None"
        ])

    elif number_of_persons >= 5:

        discount_category = random.choice([
            "Group",
            "Holiday",
            "Seasonal"
        ])

    else:

        discount_category = random.choice([
            "None",
            "Seasonal",
            "Holiday",
            "Early Bird",
            "Member"
        ])

    discount_rate = discount_rates[
        discount_category
    ]

    special_discount = (
        base_amount
        * discount_rate
    ).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP
    )

    # --------------------------------------------------------
    # Tax
    # --------------------------------------------------------

    tax = (
        base_amount
        * Decimal("0.15")
    ).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP
    )

    # --------------------------------------------------------
    # Total
    # --------------------------------------------------------

    total_amount = (
        base_amount
        - special_discount
        + tax
    ).quantize(
        Decimal("0.01"),
        rounding=ROUND_HALF_UP
    )

    # --------------------------------------------------------
    # Booking source
    # --------------------------------------------------------

    booking_source = random.choice(
        booking_sources
    )

    if booking_source == "Corporate Portal":

        payment_method = "Invoice"

    elif booking_source == "Walk-in":

        payment_method = random.choice([
            "Cash",
            "Credit Card"
        ])

    else:

        payment_method = random.choice(
            payment_methods
        )

    # --------------------------------------------------------
    # Guest
    # --------------------------------------------------------

    first_name = random.choice(
        first_names
    )

    last_name = random.choice(
        last_names
    )

    # --------------------------------------------------------
    # Invalid emails intentionally introduced
    # --------------------------------------------------------

    if (
        index % 23 == 0
        or index % 41 == 0
    ):

        guest_email = random.choice(
            invalid_emails
        )

    else:

        guest_email = (
            f"{first_name}."
            f"{last_name}"
            f"{booking_number}"
            f"@email.com"
        )

    # --------------------------------------------------------
    # Guest demographic data
    # --------------------------------------------------------

    gender = random.choice([
        "Male",
        "Female",
        "Non-binary"
    ])

    guest_age = random.randint(
        18,
        79
    )

    guest_type = random.choice(
        guest_types
    )

    if (
        booking_for == "Business"
        and random.random() < 0.65
    ):
        guest_type = "Corporate"

    # --------------------------------------------------------
    # Final record
    # --------------------------------------------------------

    record = {

        "booking_id":
            booking_number,

        "hotel_name":
            hotel_name,

        "hotel_city":
            city,

        "hotel_state":
            state,

        "hotel_zipcode":
            zipcode,

        "hotel_country":
            country,

        "booking_for":
            booking_for,

        "numbers_of_persons":
            number_of_persons,

        "adults":
            adults,

        "childrens":
            childrens,

        "days_of_stays":
            days,

        "check_in_timestamp":
            check_in.strftime(
                "%Y-%m-%d %H:%M:%S"
            ),

        "check_out_timestamp":
            check_out.strftime(
                "%Y-%m-%d %H:%M:%S"
            ),

        "requires_travels_facility":
            requires_travel,

        "mode_of_travels":
            travel_mode,

        "amount":
            money(base_amount),

        "discount_category":
            discount_category,

        "special_discount":
            money(special_discount),

        "tax":
            money(tax),

        "total_amounts":
            money(total_amount),

        "rooms_booked":
            rooms_booked,

        "room_type":
            room_type,

        "booking_source":
            booking_source,

        "payment_method":
            payment_method,

        "guest_email":
            guest_email,

        "booking_status":
            random.choice(
                booking_statuses
            ),

        "room_number":
            random.randint(
                101,
                1599
            ),

        "guest_type":
            guest_type,

        "guest_age":
            guest_age,

        "guest_gender":
            gender
    }

    records.append(
        record
    )


# ============================================================
# WRITE CSV
# ============================================================

with open(
    OUTPUT_FILE,
    "w",
    newline="",
    encoding="utf-8"
) as csv_file:

    writer = csv.DictWriter(
        csv_file,
        fieldnames=columns
    )

    writer.writeheader()

    writer.writerows(
        records
    )


# ============================================================
# VALIDATION / SUMMARY
# ============================================================

exact_duplicates = sum(
    records[i] == records[i - 1]
    for i in range(
        1,
        len(records)
    )
)


unique_booking_ids = len({
    record["booking_id"]
    for record in records
})


print("=" * 60)
print("CSV GENERATION COMPLETED")
print("=" * 60)

print(
    f"Output file       : {OUTPUT_FILE}"
)

print(
    f"Total data records: {len(records)}"
)

print(
    f"CSV columns       : {len(columns)}"
)

print(
    f"Unique booking IDs: {unique_booking_ids}"
)

print(
    f"Exact duplicates  : {exact_duplicates}"
)

print(
    f"First booking ID  : {records[0]['booking_id']}"
)

print(
    f"Last booking ID   : {records[-1]['booking_id']}"
)

print("=" * 60)