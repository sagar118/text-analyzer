import re
import string

import mlflow
import pandas as pd
import unidecode
import contractions
from utils.emoticons import EMOTICONS


class ModelService:
    def __init__(self, model_bucket, experiment_id, run_id):
        self.model_bucket = model_bucket
        self.experiment_id = experiment_id
        self.run_id = run_id

    def get_model_location(self):
        model_location = f's3://{self.model_bucket}/{self.experiment_id}/{self.run_id}/artifacts/models/'
        return model_location

    def load_model(self):
        model_location = self.get_model_location()
        model = mlflow.pyfunc.load_model(model_location)
        return model

    def prepare_data(self, data):
        features = {}
        features['cleaned_text'] = self.clean_text(data)
        return features

    def clean_text(self, text):
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
        emoticons_pattern = re.compile(
            u'(' + u'|'.join(emo for emo in EMOTICONS) + u')'
        )
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

    def predict(self, data):
        model = self.load_model()
        features = self.prepare_data(data)
        prediction = model.predict(features)
        return prediction[0]
