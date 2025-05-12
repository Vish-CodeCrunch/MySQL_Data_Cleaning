# 🛠️ Electronics Retail Data Cleaning Project

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

Welcome to the **Electronics Retail Data Cleaning Project**! This repository contains a MySQL script to clean and preprocess an electronics retail dataset, tackling issues like duplicates, inconsistent formats, and missing values. Perfect for data enthusiasts looking to refine their datasets for analysis! 🚀

---

## 📋 Table of Contents

- [Overview](#overview)
- [Dataset](#dataset)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Cleaning Tasks](#cleaning-tasks)
- [Project Structure](#project-structure)
- [Example](#example)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## 🌟 Overview

This project provides a MySQL script, `electronics_retail_final.sql`, to clean and preprocess a dataset for an electronics retail database. The script addresses common data quality issues such as:

- 🗑️ Removing duplicates
- 🔄 Standardizing formats
- 🛠️ Handling missing values
- 📅 Correcting data types

The cleaned dataset is ready for analysis or reporting, making it a great starting point for retail data projects.

---

## 📊 Dataset

The script works on the `electronics_retail` table in the `mysql_projects` database. Below is the table structure:

| **Column Name**    | **Original Type** | **Cleaned Type** | **Description**          |
|--------------------|-------------------|------------------|--------------------------|
| `product_id`       | VARCHAR(50)       | VARCHAR(50)      | Unique product identifier |
| `product_name`     | VARCHAR(100)      | VARCHAR(100)     | Name of the product      |
| `category`         | VARCHAR(50)       | VARCHAR(50)      | Product category         |
| `stock_quantity`   | INT               | INT              | Available stock          |
| `unit_price`       | VARCHAR(50)       | DECIMAL(10,2)    | Price per unit           |
| `sales_quantity`   | INT               | INT              | Quantity sold            |
| `order_date`       | VARCHAR(50)       | DATE             | Date of the order        |
| `customer_id`      | VARCHAR(50)       | VARCHAR(50)      | Unique customer identifier |
| `store_location`   | VARCHAR(50)       | VARCHAR(50)      | Store location (e.g., New York) |
| `discount`         | FLOAT             | FLOAT            | Discount applied         |
| `warehouse_id`     | VARCHAR(50)       | VARCHAR(50)      | Warehouse identifier     |
| `supplier_name`    | VARCHAR(100)      | VARCHAR(100)     | Name of the supplier     |
| `order_status`     | VARCHAR(50)       | VARCHAR(50)      | Status of the order      |
| `customer_email`   | VARCHAR(100)      | VARCHAR(100)     | Customer email address   |
| `restock_date`     | VARCHAR(50)       | DATE             | Date of restocking       |

### Sample Data Source

The dataset is imported from a CSV file (`electronics_retail_unclean_5000_extended.csv`) containing 5,000 records, using a Python script included in the SQL comments.

---

## 🛠️ Prerequisites

- **MySQL Server**: Version 8.0 or later, installed and running 🐬.
- **MySQL Client**: Use MySQL Workbench, phpMyAdmin, or the MySQL command-line client.
- **Python** (for data import): Python 3.x with the following libraries:
  - `pandas`
  - `mysql-connector-python`
- **CSV File**: `electronics_retail_unclean_5000_extended.csv` with the raw data.
- **Database Access**: A MySQL user with permissions to create databases, tables, and modify data.

---

## 🚀 Installation

1. **Clone the Repository**:

   ```bash
   https://github.com/Vish-CodeCrunch/MySQL_Data_Cleaning.git
   ```

2. **Navigate to the Project Directory**:

   ```bash
   cd electronics-retail-data-cleaning
   ```

3. **Ensure MySQL Server is Running**:
   - Start your MySQL server using your preferred method (e.g., `sudo service mysql start` on Linux).

---

## 📝 Usage

### Step 1: Import the Data

1. Place the `electronics_retail_unclean_5000_extended.csv` file in the same directory as your Python script.
2. Run the Python script (from the SQL comments) to import the data into the `electronics_retail` table:

   ```bash
   python import_data.py
   ```

   Alternatively, copy the Python script from the comments in `electronics_retail_final.sql` into a file (e.g., `import_data.py`), update the database credentials, and run it.

### Step 2: Run the Cleaning Script

Execute the `electronics_retail_final.sql` script to clean the data:

- **MySQL Command Line**:

  ```bash
  mysql -u your_username -p mysql_projects < electronics_retail_final.sql
  ```

  Enter your password when prompted.

- **MySQL Workbench**:
  - Open `electronics_retail_final.sql`.
  - Click the lightning bolt icon (Execute) to run the script.

- **phpMyAdmin**:
  - Go to the SQL tab, upload the script, and click "Go".

### Step 3: Verify the Results

Check the cleaned data:

```sql
SELECT * FROM electronics_retail LIMIT 10;
```

---

## 🧹 Cleaning Tasks

The `electronics_retail_final.sql` script performs the following:

### 1. Remove Duplicates 🗑️

- Identifies and removes exact duplicate rows across all columns using a temporary table and row numbering.

### 2. Correct Data Types 📅

- `unit_price`: Converts from VARCHAR to DECIMAL(10,2), removing `$` and `USD`.
- `order_date`: Converts from VARCHAR to DATE, handling formats like `MM/DD/YYYY`, `YYYY-MM-DD`, `MMM YYYY`.
- `restock_date`: Converts from VARCHAR to DATE, handling multiple formats and imputing missing values with an average date.

### 3. Standardize Formats 🔄

- **store_location**: Standardizes values (e.g., "NY" and "new york" to "New York").
- **order_status**: Converts to lowercase and corrects misspellings (e.g., "delivrd" to "delivered").
- **product_id**: Standardizes formats (e.g., "P001", "2", "PROD-003" to "P002").
- **warehouse_id**: Standardizes formats (e.g., "001", "WH-003" to "WH001").
- **customer_email**: Formats incomplete emails (e.g., "cust8@" to "cust8@email.com").

### 4. Handle Missing Values 🛠️

- `stock_quantity`: Imputes with the median.
- `customer_id`, `warehouse_id`, `supplier_name`, `customer_email`: Sets to "UNKNOWN".
- `discount`: Sets to 0.
- `restock_date`: Imputes with the average restock date.

---

## 📂 Project Structure

- `electronics_retail_final.sql`: The main MySQL script for data cleaning.
- `electronics_retail_unclean_5000_extended.csv`: (Not included) The raw dataset to be cleaned.
- `README.md`: This documentation file.

---

## 📈 Example

### Before Cleaning

| `product_id` | `product_name` | `category`    | `stock_quantity` | `unit_price` | `order_date` | `customer_email` | `store_location` | `order_status` |
|--------------|----------------|---------------|------------------|--------------|--------------|------------------|------------------|----------------|
| P001         | Laptop         | Electronics   | NULL             | $500 USD     | Jan 2023     | cust8@           | NY               | delivrd        |
| 2            | Mouse          | Accessories   | 50               | $20 USD      | 2023-01-15   | NULL             | la               | pendng         |

### After Cleaning

| `product_id` | `product_name` | `category`    | `stock_quantity` | `unit_price` | `order_date` | `customer_email`      | `store_location` | `order_status` |
|--------------|----------------|---------------|------------------|--------------|--------------|-----------------------|------------------|----------------|
| P001         | Laptop         | Electronics   | 50               | 500.00       | 2023-01-01   | customer8@email.com   | New York         | delivered      |
| P002         | Mouse          | Accessories   | 50               | 20.00        | 2023-01-15   | UNKNOWN               | Los Angeles      | pending        |

---

## 🤝 Contributing

We’d love your contributions! To get started:

1. Fork this repository 🍴.
2. Create a new branch (`git checkout -b feature/your-feature`).
3. Make your changes and commit (`git commit -m "Add your feature"`).
4. Push to your branch (`git push origin feature/your-feature`).
5. Create a pull request 📬.

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 📬 Contact

Have questions or feedback? Reach out!

- **GitHub**: [your-username](https://github.com/Vish-CodeCrunch)
- **Email**: vishal.ds7428@gmail.com

---

⭐ If you find this project helpful, give it a star on GitHub! ⭐
