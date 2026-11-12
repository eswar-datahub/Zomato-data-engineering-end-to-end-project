****Zomato-data-engineering-end-to-end-project****

Zomato/Food Delivery Dataset → Amazon S3 → Snowflake → dbt → Airflow → AI (OpenAI)

The dataset lands in an S3 data lake and flows into Snowflake through a storage integration, where dbt transforms it through medallion layers — RAW (Bronze) tables loaded via COPY INTO, cleaned STAGING (Silver) views, and business-ready MARTS (Gold) with dimensions, incremental facts, and aggregate marts. Apache Airflow orchestrates the whole pipeline as one daily DAG. On top of the warehouse sits an AI lane powered by GroqAI: LLM enrichment turns free-text reviews into structured, queryable columns; RAG lets you chat with your reviews; and text-to-SQL lets you query the warehouse in plain English. Streamlit serves the dashboards and AI apps.

**How the pipeline works**

1 · Data lands in S3
The seven CSVs are uploaded to s3://<BUCKET>/raw/<table>/ — one folder per table (restaurants/, users/, food/, menu/, orders/, order_items/, reviews/).

2 · S3 → Snowflake: one keyless handshake
Snowflake reads the bucket with no stored keys, using a storage integration + an IAM role. The Snowflake side is snowflake/02_storage_integration.sql; the AWS JSON documents live in aws/iam/:

File	Used for
s3-read-policy.json	IAM policy zomato-s3-read — read-only access to the bucket
snowflake-role-trust-policy-initial.json	IAM role snowflake-s3-role — placeholder trust used at creation time
snowflake-role-trust-policy-final.json	Final trust — Snowflake's IAM user ARN + external ID from DESC INTEGRATION
The order matters: create the AWS policy + role → create the Snowflake STORAGE INTEGRATION pointing at the role ARN → DESC INTEGRATION to get STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID → paste both into the role's trust policy. (Two hard-won lessons: the trust Principal must be Snowflake's IAM user ARN, not :root — and never re-run CREATE OR REPLACE on the integration afterward, it regenerates the external ID and breaks the trust.)

3 · Load — COPY INTO
Table DDL (snowflake/04_raw_tables.sql) matches each CSV's column order, then snowflake/05_copy_into.sql pulls each file from the stage into ZOMATO.RAW tables: 10M orders, ~23M order items, 300K reviews.

4 · Transform — dbt (medallion)
Staging (Silver) — one view per source: parse the messy restaurant dimension (-- → null, ₹ 200 → 200), lowercase emails, derive is_delivered, etc.
Dimensions (Gold) — dim_restaurants, dim_customer (with age segments), dim_food, a generated dim_date calendar.
Facts (Gold, incremental) — fct_orders and fact_order_items use materialized='incremental' with a MERGE strategy, so a re-run processes only new rows instead of rebuilding 10M+.
Marts (Gold) — one table per business question: daily city revenue (GMV/AOV/cancel rate), restaurant performance, delivery SLA (p50/p90 by city & hour), review insights.
Tests — unique / not_null / relationships / accepted_values plus a singular reconciliation test; dbt build runs models and tests in dependency order.
5 · Orchestrate — Airflow
One daily DAG, zomato_batch, runs the whole thing as a single graph:

reload_raw  →  dbt_build_core  →  enrich_reviews  →  dbt_build_ai
(COPY from S3)  (dbt build + tests)  (OpenAI enrichment)   (AI mart)
Credentials never touch the code: docker-compose injects SNOWFLAKE_* env vars (read by dbt's profiles.yml via env_var()) and an AIRFLOW_CONN_SNOWFLAKE_DEFAULT connection for the COPY task.

6 · AI layer — three capabilities
LLM enrichment (ai/enrich_reviews.py) — LLM as a transformation step. Reads review text, asks "openai/gpt-oss-120b" for structured JSON (sentiment + topic), writes it back to ZOMATO.AI.REVIEW_ENRICHED — which dbt then models into mart_review_insights like any other table. Idempotent and sample-capped (SAMPLE_N) so you never pay twice for the same review.
RAG (ai/rag_chat.py) — chat with your reviews. Embeds reviews, retrieves the most similar ones for a question, and generates an answer grounded in real reviews (with sources).
Text-to-SQL (ai/text_to_sql.py) — chat with your warehouse. The LLM gets the marts' schema, writes Snowflake SQL for an English question, and a SELECT-only guard validates it before running as DBT_ROLE.

