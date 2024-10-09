<body>

<h1>🎨 FamousPainting_SQL_Analysis</h1>

<p>Welcome to the <strong>Famous Paintings SQL Analysis</strong> repository! My name is <strong>Sourabh Jha</strong>, and I built this project to explore and analyze data related to famous paintings, their prices, associated museums, and more using SQL queries. Throughout this project, I learned valuable skills in data analysis, SQL querying, and data visualization, which have enhanced my understanding of the art domain.</p>

<h2>📄 Project Overview</h2>

<p>In this project, I aimed to analyze various aspects of famous paintings and their associated metadata. The primary objectives included:</p>
<ul>
    <li><strong>Data Exploration</strong>: Analyzing the dataset to uncover valuable insights regarding paintings, artists, and museums.</li>
    <li><strong>Price Analysis</strong>: Examining pricing structures of paintings, identifying trends, and spotting potential outliers.</li>
    <li><strong>Museum Insights</strong>: Understanding the distribution of paintings across different museums and identifying any gaps in collections.</li>
    <li><strong>Data Quality Assessment</strong>: Ensuring the integrity of the dataset by identifying and removing duplicates.</li>
</ul>

<h2>🛠️ Tools and Technologies</h2>
<ul>
    <li>🔧 <strong>SQL</strong>: Used for querying and manipulating the database.</li>
    <li>🐍 <strong>Python</strong>: Employed for data processing and analysis.</li>
    <li>📊 <strong>Pandas</strong>: A library for data manipulation and analysis.</li>
    <li>📦 <strong>SQLAlchemy</strong>: Used for database interaction in Python.</li>
    <li>📈 <strong>PostgreSQL</strong>: The database management system used for storing and querying the data.</li>
</ul>

<h2>📂 File Structure</h2>

<ul>
    <li><strong>FamousPainting.sql</strong>: The core SQL file containing all the queries along with comments explaining each question and solution.</li>
    <li><strong>FamousPaintingPROJECT_SQL_Analysis.docx</strong>: A document detailing all the SQL queries and explanations, providing a narrative around the insights obtained from the data.</li>
</ul>

<h2>📝 Queries Answered</h2>

<p>This project addresses key questions that provide insights into the world of famous paintings:</p>
<ol>
    <li>🎨 <strong>Which paintings are not displayed in any museum?</strong><br>
        Fetches paintings not displayed in any museum by checking for <code>museum_id</code> set to <code>NULL</code> in the <code>work</code> table.
    </li>
    <li>🏛️ <strong>Are there museums without paintings?</strong><br>
        Identifies museums without any paintings associated with them by joining the <code>museum</code> and <code>work</code> tables.
    </li>
    <li>💵 <strong>How many paintings have an asking price higher than their regular price?</strong><br>
        Compares <code>sale_price</code> and <code>regular_price</code> from the <code>product_size</code> table to identify paintings with inflated asking prices.
    </li>
    <li>💰 <strong>Which paintings are on sale for less than half their regular price?</strong><br>
        Finds paintings where the sale price is less than 50% of the regular price, indicating potential discounts.
    </li>
    <li>🖼️ <strong>Which canvas size is the most expensive?</strong><br>
        Determines which canvas size commands the highest price by joining the <code>product_size</code> and <code>canvas_size</code> tables.
    </li>
    <li>🧹 <strong>How to remove duplicate records from the database?</strong><br>
        Provides SQL commands to delete duplicate entries from multiple tables, ensuring data integrity.
    </li>
</ol>

<h2>💻 Connect Multiple CSV Files to PostgreSQL</h2>

<p>To facilitate data importation into the PostgreSQL database, I used the following Python script. This script reads multiple CSV files and uploads them to corresponding database tables:</p>

<pre><code>import pandas as pd
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
</code></pre>

<h3>⚙️ Script Breakdown</h3>
<ul>
    <li><strong>Connection Setup</strong>: The script establishes a connection to the PostgreSQL database using SQLAlchemy.</li>
    <li><strong>CSV File Processing</strong>: It iterates over a list of CSV files, loading each into a Pandas DataFrame.</li>
    <li><strong>Data Upload</strong>: Each DataFrame is uploaded to the PostgreSQL database, with the option to replace existing tables.</li>
</ul>

<h2>📊 Visuals and Analysis</h2>

<p>The project includes several visuals and insights derived from the SQL queries executed against the dataset:</p>
<ul>
    <li><strong>SQL Queries</strong>: All queries are available in the <code>FamousPainting.sql</code> file, allowing for straightforward execution in a SQL environment.</li>
    <li><strong>Detailed Documentation</strong>: The <code>FamousPaintingPROJECT_SQL_Analysis.docx</code> provides a thorough explanation of each query, the rationale behind it, and the insights gained.</li>
</ul>

<h2>🚀 Future Enhancements</h2>

<ul>
    <li><strong>Data Visualization</strong>: Implement visual representations of query results using tools like <strong>Tableau</strong> or <strong>Power BI</strong> to make insights more accessible.</li>
    <li><strong>Advanced Queries</strong>: Explore additional queries that provide deeper insights into the relationships between paintings, artists, and museums.</li>
</ul>



<h3><p>Thank you for checking out my project! I hope you find it insightful and informative! 🎨🖼️✨</p></h3>

</body>
