# RadissonBlu Booking - Data Engineering Project

End-to-end Snowflake Data Engineering project for processing hotel booking data.

## Architecture

```
Python → CSV → Staging → Bronze → Silver → Gold
```

| Layer | Description |
|-------|-------------|
| **Python/CSV** | Generates synthetic booking data |
| **Staging** | Stores the first raw copy via internal stage |
| **Bronze** | Raw ingestion; `BOOKING_ID` converted to lowercase |
| **Silver** | Data cleaning, validation, deduplication, and quarantine |
| **Gold** | Business aggregations and analytics |

## Project Files

| File | Purpose |
|------|---------|
| `stagging_stage.sql` | File format and internal stage creation |
| `bronze_state.sql` | Bronze table creation and data load from stage |
| `silver_state.sql` | Data quality checks, quarantine, and clean data insertion |
| `gold_state1.sql` | VIP customer identification |
| `gold_state2.sql` | Booking growth analysis |
| `gold_state3.sql` | Guest-type demand analysis |
| `gold_state4.sql` | Cancellation rate |
| `gold_state5.sql` | Top 10 countries by revenue |

## Branches

- **main** — Snowflake SQL pipeline
- **candidate** — Python script and generated CSV

> `initial.sql` is only for testing/reference and is not part of the actual pipeline.

## Technologies

- Python
- Snowflake
- SQL
- Git & GitHub

---

This project was completed by **Atharv Pawar**.