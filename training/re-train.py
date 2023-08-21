"""
Re-training Script
This script defines a Prefect flow that loads, cleans, and trains a machine learning model using text data.
The trained model is logged using MLflow for monitoring and versioning.

The script performs the following tasks:
1. Loading data from a CSV file.
2. Cleaning and preprocessing text data.
3. Creating a pipeline for text vectorization and model training.
4. Training the model and logging it using MLflow.

"""

import re
import string

import mlflow
import pandas as pd
import unidecode
import contractions
from prefect import flow, task, get_run_logger
from utils.emoticons import EMOTICONS
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.feature_extraction.text import TfidfVectorizer


@task(name="Load Data", log_prints=True, retries=3, retry_delay_seconds=2)
def load_data(path):
    """
    Load Data from CSV File
    Load the data from the specified CSV file.

    Args:
        path (str): Path to the CSV file.

    Returns:
        pd.DataFrame: Loaded data as a DataFrame.
    """
    logger = get_run_logger()
    logger.info("Loading data from %s", path)
    df = pd.read_csv(path)
    return df


@task(name="Clean Data", log_prints=True)
def clean_text(text):
    """
    Clean Text Data
    Preprocess the text data by removing noise, special characters, URLs, etc.

    Args:
        text (pd.Series): Series containing text data to be cleaned.

    Returns:
        pd.Series: Cleaned text data.
    """
    logger = get_run_logger()
    logger.info("Cleaning text: Started")
    # Convert the text to lowercase
    text = text.str.lower()

    # Remove HTML entities and special characters
    text = text.str.replace(r'(&amp;|&lt;|&gt;|\n|\t)', ' ', regex=True)

    # Remove URLs
    text = text.str.replace(r'https?://\S+|www\.\S+', ' ', regex=True)

    # Remove email addresses
    text = text.str.replace(r'\S+@\S+', ' ', regex=True)

    # Remove dates in various formats (e.g., DD-MM-YYYY, MM/DD/YY)
    text = text.str.replace(
        r'\d{1,2}(st|nd|rd|th)?[-./]\d{1,2}[-./]\d{2,4}', ' ', regex=True
    )

    # Remove month-day-year patterns (e.g., Jan 1st, 2022)
    pattern = re.compile(
        r'(\d{1,2})?(st|nd|rd|th)?[-./,]?\s?(of)?\s?([J|j]an(uary)?|[F|f]eb(ruary)?|[Mm]ar(ch)?|[Aa]pr(il)?|[Mm]ay|[Jj]un(e)?|[Jj]ul(y)?|[Aa]ug(ust)?|[Ss]ep(tember)?|[Oo]ct(ober)?|[Nn]ov(ember)?|[Dd]ec(ember)?)\s?(\d{1,2})?(st|nd|rd|th)?\s?[-./,]?\s?(\d{2,4})?'
    )
    text = text.str.replace(pattern, ' ', regex=True)

    # Remove emoticons
    emoticons_pattern = re.compile(u'(' + u'|'.join(emo for emo in EMOTICONS) + u')')
    text = text.str.replace(emoticons_pattern, ' ', regex=True)

    # Remove mentions (@) and hashtags (#)
    text = text.str.replace(r'(@\S+|#\S+)', ' ', regex=True)

    # Fix contractions (e.g., "I'm" becomes "I am")
    text = text.apply(lambda x: contractions.fix(x))

    # Remove punctuation
    PUNCTUATIONS = string.punctuation
    text = text.str.replace('[{}]'.format(PUNCTUATIONS), '', regex=True)

    # Remove unicode
    text = text.apply(lambda x: unidecode.unidecode(x))

    # Replace multiple whitespaces with a single space
    text = text.str.replace(r'\s+', ' ', regex=True)

    logger.info("Cleaning text: Completed")
    return text


@flow(name="Train Model", log_prints=True)
def start_training():
    """
    Train Model Flow
    Prefect flow that orchestrates the data loading, cleaning, and model training process.

    """
    logger = get_run_logger()
    logger.info("Starting training process...")
    mlflow.set_tracking_uri("http://localhost:5000")
    mlflow.set_experiment("Re-training Model")

    # Load the data
    df = load_data("data/raw/train.csv")

    # Clean the text
    df["processed_text"] = clean_text(df['text'])

    # Create Pipeline
    pipeline = Pipeline(
        [
            (
                'vectorizer',
                TfidfVectorizer(
                    stop_words='english', min_df=2, max_df=0.75, ngram_range=(1, 2)
                ),
            ),
            ('clf', LogisticRegression(solver='liblinear', penalty='l2', C=1.0)),
        ]
    )

    # Train the model
    pipeline.fit(df["processed_text"], df["target"])

    # Log the model
    with mlflow.start_run():
        logger.info("Logging the model...")
        mlflow.set_tag("model", "Logistic Regression")
        mlflow.set_tag("tag", "Re-tarin")

        mlflow.sklearn.log_model(pipeline, "model")

    logger.info("Completed training process...")


if __name__ == "__main__":
    start_training()
