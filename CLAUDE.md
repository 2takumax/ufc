# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a UFC Fight Prediction system that uses machine learning to predict Ultimate Fighting Championship fight outcomes. The project implements a comprehensive data pipeline using modern cloud-native infrastructure.

## Commands

### Infrastructure Management (Terragrunt/Terraform)

```bash
# Deploy all infrastructure
cd infrastructure/terragrunt/environments/prod
terragrunt run-all apply

# Plan changes for specific module
cd infrastructure/terragrunt/environments/prod/snowflake_schema_object
terragrunt plan

# Destroy infrastructure
terragrunt run-all destroy
```

### Data Pipeline (dbt)

```bash
# Run dbt models
cd pipeline/dags/dbt
dbt run

# Test dbt models
dbt test

# Compile dbt models
dbt compile

# Clean dbt artifacts
dbt clean
```

### Python Development

```bash
# Install pipeline dependencies
pip install -r pipeline/dags/requirements.txt

# Install Streamlit app dependencies
pip install -r streamlit/requirements.txt
```

## Architecture

### Infrastructure Layers

1. **Data Collection**: AWS Lambda functions scheduled via EventBridge scrape data from ufcstats.com, bestfightodds.com, and sherdog.com
2. **Data Storage**: Raw data stored in S3, structured data in Snowflake
3. **Data Processing**: Apache Airflow (MWAA) orchestrates dbt transformations
4. **ML/Analytics**: Jupyter notebooks for model development, Streamlit app for predictions

### Key Infrastructure Modules

- `snowflake_schema_object`: Creates Snowflake databases, schemas, and tables from JSON configurations
- `scraping`: AWS Lambda functions for web scraping
- `mwaa`: Amazon Managed Workflows for Apache Airflow
- `integration`: S3-Snowflake integration with pipes and stages

### Data Model Organization

dbt models follow a layered approach:
- `src/`: Source data models (ephemeral)
- `dim/`: Dimension tables (materialized as tables)
- `fct/`: Fact tables
- `mart/`: Analytics-ready datasets for ML features

### Configuration Management

- Infrastructure parameters stored in `/infrastructure/terragrunt/environments/parameters/`
- Table definitions in JSON format under `snowflake_system_schema_object/table/`
- Database configuration in CSV format
- Environment-specific settings in `env.hcl` files

## Development Workflow

### Working with Infrastructure

1. Navigate to the specific module directory under `infrastructure/terragrunt/environments/prod/`
2. Run `terragrunt plan` to preview changes
3. Run `terragrunt apply` to deploy changes
4. State is managed in S3 with locking

### Working with Data Pipeline

1. dbt project is located at `pipeline/dags/dbt/`
2. Models are organized into src, dim, fct, and mart directories
3. Use dbt commands to develop and test transformations
4. Airflow DAGs orchestrate the pipeline execution

### Adding New Components

#### New DAGs
- Add DAG files to `/pipeline/dags/etl_dags/`
- Follow existing patterns for Lambda invocation or Snowflake operations
- Use `schedule_interval=None` for manually triggered DAGs
- See `/pipeline/dags/README.md` for detailed instructions

#### New dbt Models
- Source models: `/pipeline/dags/dbt/models/src/`
- Dimension tables: `/pipeline/dags/dbt/models/dim/`
- Fact tables: `/pipeline/dags/dbt/models/fct/`
- Mart tables: `/pipeline/dags/dbt/models/mart/`
- Update `sources.yml` when adding new source tables

#### New Lambda Functions
- Add Lambda code to `/infrastructure/terragrunt/modules/scraping/script/`
- Define Lambda resources in corresponding Terraform modules
- Update MWAA IAM role if new Lambda functions need to be invoked

### Key File Locations

- Terragrunt root config: `infrastructure/terragrunt/root.hcl`
- Environment config: `infrastructure/terragrunt/environments/prod/env.hcl`
- dbt project: `pipeline/dags/dbt/dbt_project.yml`
- Streamlit app: `streamlit/`
- ML notebooks: `notebooks/`