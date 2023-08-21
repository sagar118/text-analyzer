"""
Evidently Grafana Metrics Script
This script defines a Prefect flow that calculates various metrics using the Evidently library,
and inserts these metrics into a PostgreSQL database for monitoring purposes.

It performs the following tasks:
1. Preparing the PostgreSQL database for storing metrics.
2. Calculating and extracting metrics using the Evidently library.
3. Inserting calculated metrics into the PostgreSQL database.

"""

import math
import time
import logging
import datetime

import pandas as pd
import psycopg
from joblib import load
from prefect import flow, task
from evidently import ColumnMapping
from evidently.report import Report
from evidently.metric_preset import TextOverviewPreset, ClassificationPreset

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s [%(levelname)s]: %(message)s"
)
SEND_TIMEOUT = 10
begin = datetime.datetime(2023, 8, 1, 0, 0, tzinfo=datetime.timezone.utc)

create_table_query = """
create table if not exists metrics (
    timestamp timestamp,
    current_missing_count integer,
    reference_missing_count integer,
    current_text_length_mean float,
    reference_text_length_mean float,
    current_oov_mean float,
    reference_oov_mean float,
    current_non_letter_char_mean float,
    reference_non_letter_char_mean float,
    non_letter_char_drift_score float,
    oov_drift_score float,
    text_length_drift_score float,
    current_accuracy_score float,
    reference_accuracy_score float,
    current_precision_score float,
    reference_precision_score float,
    current_recall_score float,
    reference_recall_score float,
    current_f1_score float,
    reference_f1_score float
);
"""

# Load data and model
current_data = pd.read_parquet('./data/current.parquet')
reference_data = pd.read_parquet('./data/reference.parquet')
with open('models/log_reg.pkl', 'rb') as handle:
    model = load(handle)

col_mapping = ColumnMapping(
    text_features=['processed_text'], target='target', prediction='prediction'
)

report = Report(
    metrics=[TextOverviewPreset(column_name='processed_text'), ClassificationPreset()]
)


@task
def prep_db():
    """
    Prepare Database
    Ensure that the PostgreSQL database 'evidently' is created and ready for use.

    """
    with psycopg.connect(
        "host=localhost port=5432 user=postgres password=postgres", autocommit=True
    ) as conn:
        res = conn.execute("SELECT 1 FROM pg_database WHERE datname = 'evidently'")
        if len(res.fetchall()) == 0:
            conn.execute("CREATE DATABASE evidently;")
        with psycopg.connect(
            "host=localhost port=5432 user=postgres password=postgres dbname=evidently",
            autocommit=True,
        ) as conn:
            conn.execute(create_table_query)


@task
def calculate_metrics_postgresql(curr, i):
    """
    Calculate Metrics and Insert into PostgreSQL
    Calculate various metrics using the Evidently library and insert them into the PostgreSQL database.

    Args:
        curr: The PostgreSQL cursor.
        i (int): Index for processing the data in chunks.

    """
    current = current_data.iloc[i * 500 : (i + 1) * 500]
    current['prediction'] = model.predict(current['processed_text'])

    report.run(
        current_data=current, reference_data=reference_data, column_mapping=col_mapping
    )
    json_data = report.as_dict()

    current_missing_count = json_data['metrics'][0]['result'][
        'current_characteristics'
    ]['missing']
    reference_missing_count = json_data['metrics'][0]['result'][
        'reference_characteristics'
    ]['missing']

    current_text_length_mean = json_data['metrics'][0]['result'][
        'current_characteristics'
    ]['text_length_mean']
    reference_text_length_mean = json_data['metrics'][0]['result'][
        'reference_characteristics'
    ]['text_length_mean']

    current_oov_mean = json_data['metrics'][0]['result']['current_characteristics'][
        'oov_mean'
    ]
    reference_oov_mean = json_data['metrics'][0]['result']['reference_characteristics'][
        'oov_mean'
    ]

    current_non_letter_char_mean = json_data['metrics'][0]['result'][
        'current_characteristics'
    ]['non_letter_char_mean']
    reference_non_letter_char_mean = json_data['metrics'][0]['result'][
        'reference_characteristics'
    ]['non_letter_char_mean']

    non_letter_char_drift_score = json_data['metrics'][4]['result']['drift_by_columns'][
        'Non Letter Character %'
    ]['drift_score']
    oov_drift_score = json_data['metrics'][4]['result']['drift_by_columns']['OOV %'][
        'drift_score'
    ]
    text_length_drift_score = json_data['metrics'][4]['result']['drift_by_columns'][
        'Text Length'
    ]['drift_score']

    current_accuracy_score = json_data['metrics'][5]['result']['current']['accuracy']
    reference_accuracy_score = json_data['metrics'][5]['result']['reference'][
        'accuracy'
    ]

    current_precision_score = json_data['metrics'][5]['result']['current']['precision']
    reference_precision_score = json_data['metrics'][5]['result']['reference'][
        'precision'
    ]

    current_recall_score = json_data['metrics'][5]['result']['current']['recall']
    reference_recall_score = json_data['metrics'][5]['result']['reference']['recall']

    current_f1_score = json_data['metrics'][5]['result']['current']['f1']
    reference_f1_score = json_data['metrics'][5]['result']['reference']['f1']

    curr.execute(
        """
        INSERT INTO metrics (
            timestamp,
            current_missing_count,
            reference_missing_count,
            current_text_length_mean,
            reference_text_length_mean,
            current_oov_mean,
            reference_oov_mean,
            current_non_letter_char_mean,
            reference_non_letter_char_mean,
            non_letter_char_drift_score,
            oov_drift_score,
            text_length_drift_score,
            current_accuracy_score,
            reference_accuracy_score,
            current_precision_score,
            reference_precision_score,
            current_recall_score,
            reference_recall_score,
            current_f1_score,
            reference_f1_score
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)""",
        (
            begin + datetime.timedelta(i),
            current_missing_count,
            reference_missing_count,
            current_text_length_mean,
            reference_text_length_mean,
            current_oov_mean,
            reference_oov_mean,
            current_non_letter_char_mean,
            reference_non_letter_char_mean,
            non_letter_char_drift_score,
            oov_drift_score,
            text_length_drift_score,
            current_accuracy_score,
            reference_accuracy_score,
            current_precision_score,
            reference_precision_score,
            current_recall_score,
            reference_recall_score,
            current_f1_score,
            reference_f1_score,
        ),
    )


@flow
def batch_monitoring():
    """
    Batch Monitoring Flow
    Prefect flow that orchestrates the monitoring process, including metric calculation and database insertion.

    """
    prep_db()
    ROWS = current_data.shape[0]
    iters = math.ceil(ROWS / 500)
    last_send = datetime.datetime.now() - datetime.timedelta(seconds=10)
    with psycopg.connect(
        "host=localhost port=5432 dbname=evidently user=postgres password=postgres",
        autocommit=True,
    ) as conn:
        for i in range(iters):
            with conn.cursor() as curr:
                calculate_metrics_postgresql(curr, i)

            new_send = datetime.datetime.now()
            seconds_elapsed = (new_send - last_send).total_seconds()
            if seconds_elapsed < SEND_TIMEOUT:
                time.sleep(SEND_TIMEOUT - seconds_elapsed)
            while last_send < new_send:
                last_send = last_send + datetime.timedelta(seconds=10)
            logging.info("data sent")


if __name__ == '__main__':
    batch_monitoring()
