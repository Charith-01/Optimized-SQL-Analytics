"""
Prepare selected Excel worksheets for loading into MySQL.

The script:
- reads selected worksheets;
- standardizes column names;
- converts formatted IDs into numeric IDs;
- validates required columns;
- checks duplicate and missing IDs;
- exports processed CSV files.
"""

from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent.parent
INPUT_FILE = PROJECT_ROOT / "data" / "raw" / "Datasets.xlsx"
OUTPUT_DIRECTORY = PROJECT_ROOT / "data" / "processed"


def normalize_columns(dataframe: pd.DataFrame) -> pd.DataFrame:
    """
    Convert column names into lowercase SQL-friendly names.
    """

    dataframe = dataframe.copy()

    dataframe.columns = (
        dataframe.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_", regex=False)
        .str.replace("-", "_", regex=False)
    )

    return dataframe


def extract_numeric_id(
    series: pd.Series,
    prefix: str,
) -> pd.Series:
    """
    Remove an ID prefix and convert the remaining value to an integer.

    Example:
        E0001 -> 1
        C0001 -> 1
    """

    cleaned_series = (
        series.astype("string")
        .str.strip()
        .str.replace(prefix, "", regex=False)
    )

    return pd.to_numeric(cleaned_series, errors="raise").astype("Int64")


def validate_unique_id(
    dataframe: pd.DataFrame,
    column_name: str,
    dataset_name: str,
) -> None:
    """
    Validate that an ID column has no missing or duplicate values.
    """

    missing_count = dataframe[column_name].isna().sum()
    duplicate_count = dataframe[column_name].duplicated().sum()

    if missing_count > 0:
        raise ValueError(
            f"{dataset_name}: {column_name} contains "
            f"{missing_count} missing values."
        )

    if duplicate_count > 0:
        raise ValueError(
            f"{dataset_name}: {column_name} contains "
            f"{duplicate_count} duplicate values."
        )


def prepare_employee_attrition() -> pd.DataFrame:
    """
    Prepare the Employee_Attrition worksheet.
    """

    dataframe = pd.read_excel(
        INPUT_FILE,
        sheet_name="Employee_Attrition",
    )

    dataframe = normalize_columns(dataframe)

    dataframe = dataframe.rename(
        columns={
            "years": "years_of_service",
            "performance": "performance_score",
        }
    )

    dataframe["employee_code"] = dataframe["employee_id"]

    dataframe["employee_id"] = extract_numeric_id(
        dataframe["employee_code"],
        prefix="E",
    )

    validate_unique_id(
        dataframe,
        "employee_id",
        "Employee_Attrition",
    )

    ordered_columns = [
        "employee_id",
        "employee_code",
        "age",
        "department",
        "role",
        "years_of_service",
        "salary",
        "job_satisfaction",
        "performance_score",
        "attrition",
    ]

    return dataframe[ordered_columns]


def prepare_performance() -> pd.DataFrame:
    """
    Prepare the Performance worksheet.
    """

    dataframe = pd.read_excel(
        INPUT_FILE,
        sheet_name="Performance",
    )

    dataframe = normalize_columns(dataframe)

    dataframe["employee_id"] = pd.to_numeric(
        dataframe["employee_id"],
        errors="raise",
    ).astype("Int64")

    validate_unique_id(
        dataframe,
        "employee_id",
        "Performance",
    )

    return dataframe


def prepare_recruitment() -> pd.DataFrame:
    """
    Prepare the Recruitment worksheet.
    """

    dataframe = pd.read_excel(
        INPUT_FILE,
        sheet_name="Recruitment",
    )

    dataframe = normalize_columns(dataframe)

    dataframe["candidate_code"] = dataframe["candidate_id"]

    dataframe["candidate_id"] = extract_numeric_id(
        dataframe["candidate_code"],
        prefix="C",
    )

    validate_unique_id(
        dataframe,
        "candidate_id",
        "Recruitment",
    )

    return dataframe


def prepare_recommendation() -> pd.DataFrame:
    """
    Prepare the Recommendation worksheet.
    """

    dataframe = pd.read_excel(
        INPUT_FILE,
        sheet_name="Recommendation",
    )

    dataframe = normalize_columns(dataframe)

    dataframe["candidate_id"] = pd.to_numeric(
        dataframe["candidate_id"],
        errors="raise",
    ).astype("Int64")

    validate_unique_id(
        dataframe,
        "candidate_id",
        "Recommendation",
    )

    return dataframe


def save_csv(
    dataframe: pd.DataFrame,
    filename: str,
) -> None:
    """
    Save a processed DataFrame as a CSV file.
    """

    output_path = OUTPUT_DIRECTORY / filename

    dataframe.to_csv(
        output_path,
        index=False,
        encoding="utf-8",
    )

    print(
        f"Created {filename}: "
        f"{dataframe.shape[0]} rows, "
        f"{dataframe.shape[1]} columns"
    )


def main() -> None:
    """
    Prepare and export all selected datasets.
    """

    if not INPUT_FILE.exists():
        raise FileNotFoundError(
            f"Dataset not found at: {INPUT_FILE}"
        )

    OUTPUT_DIRECTORY.mkdir(
        parents=True,
        exist_ok=True,
    )

    employees = prepare_employee_attrition()
    performance = prepare_performance()
    candidates = prepare_recruitment()
    recommendations = prepare_recommendation()

    save_csv(
        employees,
        "employees.csv",
    )

    save_csv(
        performance,
        "employee_performance.csv",
    )

    save_csv(
        candidates,
        "candidates.csv",
    )

    save_csv(
        recommendations,
        "candidate_recommendations.csv",
    )

    print("\nData preparation completed successfully.")


if __name__ == "__main__":
    main()