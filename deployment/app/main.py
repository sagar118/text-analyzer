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
    return {
        'hello': 'world',
    }


@app.get('/predict')
def prediction(data: str):
    y_pred = model_service.predict(data)
    return JSONResponse(
        {
            'prediction': int(y_pred),
        }
    )


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
