# import os
# import sys
# import pytest

# from pathlib import Path
# from fastapi.testclient import TestClient
# from unittest.mock import Mock, patch

# sys.path.append(str(Path(__file__).resolve().parents[2]))
# sys.path.append(str(Path(__file__).resolve().parents[2]) + '/deployment/app')

# from deployment.app.main import app
# from deployment.app.model import ModelService

# client = TestClient(app)

# @pytest.fixture
# def mock_model_service():
#     mock = Mock()
#     mock.predict.return_value = 0  # Mock prediction result
#     return mock

# @patch.dict(
#     os.environ,
#     {
#         "MODEL_BUCKET": "mlops-zc-ta-stg-model-registry",
#         "EXPERIMENT_ID": 6,
#         "RUN_ID": "465a65643f584504a46364b45fec831d",
#     },
# )
# def test_read_root():
#     response = client.get("/")
#     assert response.status_code == 200
#     assert response.json() == {"hello": "world"}

# def test_predict(mock_model_service):
#     app.dependency_overrides[ModelService] = lambda: mock_model_service
#     response = client.get("/predict?data=some_data")
#     assert response.status_code == 200
#     assert response.json() == {"prediction": 1}

# def test_predict_no_data(mock_model_service):
#     app.dependency_overrides[ModelService] = lambda: mock_model_service
#     response = client.get("/predict")
#     assert response.status_code == 422  # Data parameter missing

# if __name__ == "__main__":
#     pytest.main([__file__])


# import requests
# import pytest
# from time import sleep

# # Replace with your API Gateway URL
# API_URL = "https://66hadw5gc7.execute-api.us-east-1.amazonaws.com/stg/predict/"

# def test_api_call():
#     headers = {
#         "Content-Type": "application/json",
#         # Add any required headers here
#     }

#     # Replace with the appropriate HTTP method
#     http_method = "GET"

#     payload = {}

#     query_parameters = {
#         "data": "hello world"
#     }
#     data = "hello world"
#     print('start')
#     # response = requests.request(http_method, API_URL, params=query_parameters, json=payload, timeout=20)
#     # response = requests.get(API_URL)
#     response = requests.get(API_URL, params={'data': data}).json()
#     print('response')
#     print(response)
#     # print(requests.request(http_method, API_URL, params=query_parameters, json=payload, timeout=20))
#     # sleep(10)

#     # assert response.status_code == 200, f"Expected status code 200, but got {response.status_code}"

#     # response_data = response.json()
#     # assert "prediction" in response_data, "Expected 'key' in response data"
#     # assert response_data["prediction"] == '{"prediction":0}', "Expected 'key' value to be '{\"prediction\":0}'"

# if __name__ == "__main__":
#     pytest.main([__file__])
#     test_api_call()
