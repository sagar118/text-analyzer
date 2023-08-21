"""
Main FastAPI Application
This script defines a FastAPI application that serves a machine learning model for predictions.

It provides two endpoints:
- '/' - Returns a simple greeting message.
- '/predict' - Accepts input data and returns predictions from a machine learning model.

"""

import os

import uvicorn
from model import ModelService
from mangum import Mangum
from fastapi import FastAPI
from fastapi.responses import JSONResponse

MODEL_BUCKET = os.getenv('MODEL_BUCKET', None)
EXPERIMENT_ID = os.getenv('EXPERIMENT_ID', None)
RUN_ID = os.getenv('RUN_ID', None)

print(f'MODEL_BUCKET: {MODEL_BUCKET}')
print(f'EXPERIMENT_ID: {EXPERIMENT_ID}')
print(f'RUN_ID: {RUN_ID}')

model_service = ModelService(MODEL_BUCKET, EXPERIMENT_ID, RUN_ID)

app = FastAPI()
handler = Mangum(app)


@app.get('/')
def read_root():
    """
    Root Endpoint
    Returns a simple greeting message.

    Returns:
        dict: A dictionary containing a greeting message.
    """
    return {
        'hello': 'world',
    }


@app.get('/predict')
def prediction(data: str):
    """
    Prediction Endpoint
    Accepts input data and returns predictions from a machine learning model.

    Args:
        data (str): Input data for prediction.

    Returns:
        JSONResponse: A JSON response containing the prediction.
    """
    y_pred = model_service.predict(data)
    return JSONResponse(
        {
            'prediction': int(y_pred),
        }
    )


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
