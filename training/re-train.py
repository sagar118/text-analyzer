import re
import os
import string

import mlflow
import pandas as pd
import unidecode
import contractions
from prefect import flow, task
from utils.emoticons import EMOTICONS
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.feature_extraction.text import TfidfVectorizer


@task(name="Load Data", log_prints=True)
def load_data(path):
    df = pd.read_parquet(path)
    return df


@task(name="Clean Data", log_prints=True)
def clean_text(text):
    # Convert the text to lowercase
    text = text.lower()

    # Remove HTML entities and special characters
    text = re.sub(r'(&amp;|&lt;|&gt;|\n|\t)', '', text)

    # Remove URLs
    text = re.sub(r'https?://\S+|www\.\S+', '', text)

    # Remove email addresses
    text = re.sub(r'\S+@\S+', '', text)

    # Remove dates in various formats (e.g., DD-MM-YYYY, MM/DD/YY)
    text = re.sub(r'\d{1,2}(st|nd|rd|th)?[-./]\d{1,2}[-./]\d{2,4}', '', text)

    # Remove month-day-year patterns (e.g., Jan 1st, 2022)
    pattern = re.compile(
        r'(\d{1,2})?(st|nd|rd|th)?[-./,]?\s?(of)?\s?([J|j]an(uary)?|[F|f]eb(ruary)?|[Mm]ar(ch)?|[Aa]pr(il)?|[Mm]ay|[Jj]un(e)?|[Jj]ul(y)?|[Aa]ug(ust)?|[Ss]ep(tember)?|[Oo]ct(ober)?|[Nn]ov(ember)?|[Dd]ec(ember)?)\s?(\d{1,2})?(st|nd|rd|th)?\s?[-./,]?\s?(\d{2,4})?'
    )
    text = pattern.sub(r'', text)

    # Remove emoticons
    emoticons_pattern = re.compile(u'(' + u'|'.join(emo for emo in EMOTICONS) + u')')
    text = emoticons_pattern.sub(r'', text)

    # Remove mentions (@) and hashtags (#)
    text = re.sub(r'(@\S+|#\S+)', '', text)

    # Fix contractions (e.g., "I'm" becomes "I am")
    text = contractions.fix(text)

    # Remove punctuation
    PUNCTUATIONS = string.punctuation
    text = text.translate(str.maketrans('', '', PUNCTUATIONS))

    # Remove unicode
    text = unidecode.unidecode(text)

    # Replace multiple whitespaces with a single space
    text = re.sub(r'\s+', ' ', text)

    return text


@flow(name="Train Model", log_prints=True)
def start_training():
    print(f'Current Path: {os.getcwd()}')
    mlflow.set_tracking_uri("http://localhost:5000")
    mlflow.set_experiment("Re-training Model")

    # Load the data
    df = load_data("data/raw/train.parquet")

    # Clean the text
    df["processed_text"] = df["text"].apply(clean_text)

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
        mlflow.set_tag("model", "Logistic Regression")
        mlflow.set_tag("tag", "Re-tarin")

        mlflow.sklearn.log_model(pipeline, "model")


if __name__ == "__main__":
    start_training()
