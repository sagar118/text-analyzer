"""
predict.py - FastAPI Prediction Endpoint
"""

from fastapi import FastAPI

app = FastAPI()


@app.get('/predict')
def predict():
    """
    Handle GET requests to the '/predict' endpoint.

    Returns:
        dict: A dictionary containing a prediction response.
    """
    return {'prediction': 'This is a prediction'}
