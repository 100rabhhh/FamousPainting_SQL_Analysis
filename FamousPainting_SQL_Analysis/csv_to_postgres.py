import pandas as pd
from sqlalchemy import create_engine
import os

# Connection string for PostgreSQL with URL-encoded password
conn_string = 'postgresql://postgres:yug%402019@localhost/painting'
db = create_engine(conn_string)

# List of CSV files to process
csv_files = [
    'artist.csv',
    'image_link.csv',
    'museum.csv',
    'museum_hours.csv',
    'product_size.csv',
    'subject.csv',
    'work.csv',
    'canvas_size.csv'
]

# Base path for the CSV files
base_path = 'C:/Users/soura/Downloads/Famous Paintings/'

for file_name in csv_files:
    csv_path = os.path.join(base_path, file_name)
    
    if os.path.exists(csv_path):
        # Load the CSV file into a DataFrame
        df = pd.read_csv(csv_path)

        # Try connecting to the database and writing the DataFrame
        try:
            with db.connect() as conn:  # Automatically closes the connection
                # Use the file name (without .csv) as the table name
                table_name = os.path.splitext(file_name)[0]
                df.to_sql(table_name, con=conn, if_exists='replace', index=False)
                print(f"{table_name} table updated successfully.")
        except Exception as e:
            print(f"Error updating {file_name}: {e}")
    else:
        print(f"{file_name} does not exist.")
