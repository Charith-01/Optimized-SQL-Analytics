"""
Inspect all worksheets in the raw Excel dataset.

This script displays:
- worksheet names
- dataset shape
- column names
- data types
- missing values
- duplicate rows
- duplicate values in possible ID columns
- sample records
"""

from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent.parent
FILE_PATH = PROJECT_ROOT / "data" / "raw" / "Datasets.xlsx"


def inspect_sheet(sheet_name: str, dataframe: pd.DataFrame) -> None:
    """
    Print a data-quality summary for one Excel worksheet.

    Args:
        sheet_name: Name of the Excel worksheet.
        dataframe: DataFrame loaded from the worksheet.
    """

    print("\n" + "=" * 80)
    print(f"SHEET: {sheet_name}")
    print("=" * 80)

    print("\n1. Dataset shape")
    print(f"Rows: {dataframe.shape[0]}")
    print(f"Columns: {dataframe.shape[1]}")

    print("\n2. Column names")
    for column in dataframe.columns:
        print(f"- {column}")

    print("\n3. Data types")
    print(dataframe.dtypes)

    print("\n4. Missing values")
    missing_values = dataframe.isna().sum()
    print(missing_values)

    print("\n5. Fully duplicated rows")
    duplicate_rows = dataframe.duplicated().sum()
    print(f"Duplicate rows: {duplicate_rows}")

    print("\n6. Possible ID-column validation")
    id_columns = [
        column
        for column in dataframe.columns
        if column.lower().endswith("_id")
    ]

    if id_columns:
        for column in id_columns:
            duplicate_ids = dataframe[column].duplicated().sum()
            missing_ids = dataframe[column].isna().sum()

            print(
                f"{column}: "
                f"{duplicate_ids} duplicate values, "
                f"{missing_ids} missing values"
            )
    else:
        print("No ID columns detected.")

    print("\n7. Unique values in categorical columns")
    categorical_columns = dataframe.select_dtypes(
        include=["object", "string"]
    ).columns

    for column in categorical_columns:
        unique_count = dataframe[column].nunique(dropna=True)

        if unique_count <= 20:
            unique_values = dataframe[column].dropna().unique()
            print(f"{column}: {list(unique_values)}")
        else:
            print(f"{column}: {unique_count} unique values")

    print("\n8. First five records")
    print(dataframe.head())


def main() -> None:
    """
    Load and inspect every worksheet in the Excel workbook.
    """

    if not FILE_PATH.exists():
        raise FileNotFoundError(
            f"Dataset not found at: {FILE_PATH}"
        )

    excel_file = pd.ExcelFile(FILE_PATH)

    print("DATASET INSPECTION REPORT")
    print(f"File: {FILE_PATH}")
    print(f"Total worksheets: {len(excel_file.sheet_names)}")

    print("\nWorksheet names:")
    for sheet_name in excel_file.sheet_names:
        print(f"- {sheet_name}")

    for sheet_name in excel_file.sheet_names:
        dataframe = pd.read_excel(
            FILE_PATH,
            sheet_name=sheet_name,
        )

        inspect_sheet(sheet_name, dataframe)


if __name__ == "__main__":
    main()