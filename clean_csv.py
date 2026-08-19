import pandas as pd
import numpy as np


# ============================================================
# 1. READ RAW CSV
# ============================================================

input_file = r"C:\Users\atharv.MSI\Downloads\RadissonBlu_booking_de_raw_unclean.csv"
output_file = r"C:\Users\atharv.MSI\Downloads\RadissonBlu_booking_de_cleaned.csv"

df = pd.read_csv(
    input_file,
    dtype=str,              # Read everything as string initially
    keep_default_na=False   # Keep values like "NULL" available for cleaning
)

print("Original Shape:", df.shape)
print("Original Columns:", len(df.columns))


# ============================================================
# 2. STANDARDIZE COLUMN NAMES
# ============================================================

df.columns = (
    df.columns
      .str.strip()
      .str.lower()
      .str.replace(" ", "_")
)


# ============================================================
# 3. CLEAN STRING COLUMNS
# ============================================================

# Values that should be treated as NULL
null_values = [
    "",
    "null",
    "none",
    "n/a",
    "na",
    "nan",
    "nil"
]

for col in df.columns:
    df[col] = (
        df[col]
        .astype(str)
        .str.strip()
    )

    df[col] = df[col].replace(
        null_values,
        np.nan
    )


# ============================================================
# 4. NUMERIC COLUMNS
# ============================================================

numeric_columns = [
    "booking_id",
    "numbers_of_persons",
    "adults",
    "childrens",
    "days_of_stays",
    "amount",
    "special_discount",
    "tax",
    "total_amounts",
    "rooms_booked",
    "guest_age"
]

for col in numeric_columns:
    df[col] = pd.to_numeric(
        df[col],
        errors="coerce"
    )


# ============================================================
# 5. TIMESTAMP COLUMNS
# ============================================================

timestamp_columns = [
    "check_in_timestamp",
    "check_out_timestamp"
]

for col in timestamp_columns:
    df[col] = pd.to_datetime(
        df[col],
        errors="coerce"
    )


# ============================================================
# 6. STANDARDIZE YES / NO VALUES
# ============================================================

df["requires_travels_facility"] = (
    df["requires_travels_facility"]
    .str.strip()
    .str.lower()
    .map({
        "yes": "Yes",
        "no": "No",
        "y": "Yes",
        "n": "No"
    })
)


# ============================================================
# 7. STANDARDIZE GENDER
# ============================================================

df["guest_gender"] = (
    df["guest_gender"]
    .str.strip()
    .str.upper()
    .replace({
        "M": "M",
        "MALE": "M",
        "F": "F",
        "FEMALE": "F"
    })
)


# ============================================================
# 8. STANDARDIZE EMAIL
# ============================================================

df["guest_email"] = (
    df["guest_email"]
    .str.strip()
    .str.lower()
)


# ============================================================
# 9. VALIDATE GUEST AGE
# ============================================================

# Invalid ages become NULL
df.loc[
    (df["guest_age"] < 0) |
    (df["guest_age"] > 120),
    "guest_age"
] = np.nan


# ============================================================
# 10. VALIDATE NUMERIC VALUES
# ============================================================

# Negative values are not valid for these columns
non_negative_columns = [
    "numbers_of_persons",
    "adults",
    "childrens",
    "days_of_stays",
    "amount",
    "special_discount",
    "tax",
    "total_amounts",
    "rooms_booked"
]

for col in non_negative_columns:
    df.loc[df[col] < 0, col] = np.nan


# ============================================================
# 11. REMOVE DUPLICATE BOOKINGS
# ============================================================

before_duplicates = len(df)

df = df.drop_duplicates(
    subset=["booking_id"],
    keep="first"
)

after_duplicates = len(df)

print(
    "Duplicate bookings removed:",
    before_duplicates - after_duplicates
)


# ============================================================
# 12. FORMAT DECIMAL COLUMNS
# ============================================================

decimal_columns = [
    "amount",
    "special_discount",
    "tax",
    "total_amounts"
]

for col in decimal_columns:
    df[col] = df[col].round(2)


# ============================================================
# 13. FORMAT TIMESTAMPS FOR SNOWFLAKE
# ============================================================

for col in timestamp_columns:
    df[col] = df[col].dt.strftime(
        "%Y-%m-%d %H:%M:%S"
    )


# ============================================================
# 14. SAVE CLEAN CSV
# ============================================================

df.to_csv(
    output_file,
    index=False,
    na_rep=""
)

print("\nCleaning completed successfully!")
print("Cleaned Shape:", df.shape)
print("Output File:", output_file)


# ============================================================
# 15. BASIC DATA QUALITY REPORT
# ============================================================

print("\n========== DATA QUALITY REPORT ==========")

print("\nMissing Values:")
print(df.isnull().sum())

print("\nData Types:")
print(df.dtypes)

print("\nDuplicate Booking IDs:")
print(df["booking_id"].duplicated().sum())

print("\nFinal Columns:")
print(len(df.columns))