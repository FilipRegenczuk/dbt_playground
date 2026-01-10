# dbt-playground

For playing around with DBT models, tests, macros etc.

## Prerequisites

- [uv](https://github.com/astral-sh/uv) - Fast Python package installer and resolver
- [direnv](https://direnv.net/) - Automatically loads environment variables from `.env` file
- `curl` - Usually pre-installed on macOS/Linux
- `bash` - Usually pre-installed on macOS/Linux

### Installing direnv

**macOS:**
```bash
brew install direnv
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install direnv

# Or via other package managers
```

**After installation**, add to your shell configuration:

For **zsh** (add to `~/.zshrc`):
```bash
eval "$(direnv hook zsh)"
```

For **bash** (add to `~/.bashrc` or `~/.bash_profile`):
```bash
eval "$(direnv hook bash)"
```

Then restart your terminal or run:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

## Local Installation

### Step 1: Install uv (if not already installed)

If you don't have `uv` installed, install it using:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Or using Homebrew on macOS:

```bash
brew install uv
```

### Step 2: Clone the repository (if applicable)

```bash
git clone <repository-url>
cd dbt_playground
```

### Step 3: Run the setup script

Run the setup script to install the uv environment and dbt-fusion:

```bash
./setup.sh
```

This script will:
1. Set up the uv Python environment (`uv sync`)
2. Install dbt-fusion into the uv virtual environment (not globally)



## Configuration

### Environment Variables

This project uses environment variables for sensitive credentials (stored in `.env` file). The project uses **direnv** to automatically load these variables when you enter the project directory.

1. **Create your `.env` file**:
   ```bash
   cp .env.example .env
   ```

   Or manualy copy `.env.example` file and rename it to `.env`.

2. **Edit `.env`** and fill in your Snowflake credentials:
   ```bash
   SNOWFLAKE_ACCOUNT=your_account
   SNOWFLAKE_USER=your_user
   SNOWFLAKE_PASSWORD=your_password
   SNOWFLAKE_WAREHOUSE=your_warehouse
   SNOWFLAKE_DATABASE=your_database
   SNOWFLAKE_SCHEMA=your_schema
   ```

3. **Allow direnv to load the `.envrc` file** (first time only):
   ```bash
   direnv allow
   ```

The `.env` file is gitignored and will not be committed to version control. The `.envrc` file is committed to version control and tells direnv to load the `.env` file.

## Usage

After installation and configuration, you can use dbt commands directly. **direnv automatically loads your `.env` file** when you enter the project directory, so all environment variables are available.

### Preparing Snowflake instance

In Snowflake execute following commands to set up instaces and load test data:
```sql

-- create test instances

create warehouse transforming; 

create database raw; 

create database analytics; 

create schema raw.jaffle_shop; 

create schema raw.stripe;


-- create test tables
create table raw.jaffle_shop.customers 
( id integer,
  first_name varchar,
  last_name varchar
);

create table raw.jaffle_shop.orders
( id integer,
  user_id integer,
  order_date date,
  status varchar,
  _etl_loaded_at timestamp default current_timestamp
);

create table raw.stripe.payment 
( id integer,
  orderid integer,
  paymentmethod varchar,
  status varchar,
  amount integer,
  created date,
  _batched_at timestamp default current_timestamp
);

-- populate test tables

copy into raw.jaffle_shop.customers (id, first_name, last_name)
from 's3://dbt-tutorial-public/jaffle_shop_customers.csv'
file_format = (
    type = 'CSV'
    field_delimiter = ','
    skip_header = 1
    );
    
copy into raw.jaffle_shop.orders (id, user_id, order_date, status)
from 's3://dbt-tutorial-public/jaffle_shop_orders.csv'
file_format = (
    type = 'CSV'
    field_delimiter = ','
    skip_header = 1
    );

copy into raw.stripe.payment (id, orderid, paymentmethod, status, amount, created)
from 's3://dbt-tutorial-public/stripe_payments.csv'
file_format = (
    type = 'CSV'
    field_delimiter = ','
    skip_header = 1
    );
```

### Running dbt commands

Simply run dbt commands through uv:

```bash
uv run dbt --version
uv run dbt run
uv run dbt test
uv run dbt compile
uv run dbt docs generate
```

The environment variables from your `.env` file are automatically loaded by direnv, so `profiles.yml` will have access to all the `env_var()` references.

### Verifying direnv is working

When you `cd` into the project directory, you should see a message like:
```
direnv: loading .envrc
direnv: export +SNOWFLAKE_ACCOUNT +SNOWFLAKE_USER ...
```

If you don't see this, make sure:
1. direnv is installed and hooked into your shell
2. You've run `direnv allow` in the project directory

**Note:** The dbt-fusion installer installs a binary named `dbt` (which is dbt-fusion, not dbt-core).

## Project Structure

```
dbt_playground/
├── models/          # dbt models
│   ├── staging/     # Staging models
│   └── marts/       # Mart models
├── tests/           # dbt tests
├── macros/          # dbt macros
├── seeds/           # Seed files
├── snapshots/       # Snapshot definitions
├── analyses/        # Analysis queries
├── dbt_project.yml  # dbt project configuration
├── profiles.yml     # dbt profiles (uses env vars from .env)
├── pyproject.toml   # Python project configuration
├── setup.sh         # Setup script
├── .envrc           # direnv configuration (loads .env)
├── .env.example     # Example environment variables template
└── .env             # Your actual credentials (gitignored)
```
