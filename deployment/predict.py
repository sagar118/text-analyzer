from fastapi import FastAPI

app = FastAPI()

@app.get('/predict')
def predict():
    return {'prediction': 'This is a prediction'}