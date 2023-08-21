"""
Test Model Module
This module contains unit tests for the ModelService class defined in the 'model.py' module.

The tests cover the following:
- ModelService methods including 'get_model_location', 'load_model', 'clean_text', 'prepare_data', and 'predict'.
"""

import sys
from pathlib import Path
from unittest.mock import Mock, patch

import pytest

sys.path.append(str(Path(__file__).resolve().parents[2]))
sys.path.append(str(Path(__file__).resolve().parents[2]) + '/deployment/app')

from deployment.app.model import ModelService


@pytest.fixture
def mock_model_service():
    """
    Mock ModelService Fixture
    Returns a ModelService instance with mock values for testing.
    """
    return ModelService('test-bucket', 'test-experiment', 'test-run')


def test_get_model_location(mock_model_service):
    """
    Test Get Model Location
    Test the functionality of the get_model_location method.
    """
    expected_location = 's3://test-bucket/test-experiment/test-run/artifacts/models/'
    assert mock_model_service.get_model_location() == expected_location


@patch('mlflow.pyfunc.load_model')
def test_load_model(mock_load_model, mock_model_service):
    """
    Test Load Model
    Test the functionality of the load_model method.
    """
    mock_load_model.return_value = Mock()
    model = mock_model_service.load_model()
    mock_load_model.assert_called_once_with(
        's3://test-bucket/test-experiment/test-run/artifacts/models/'
    )
    assert isinstance(model, Mock)


def test_clean_data(mock_model_service):
    """
    Test Clean Data
    Test the functionality of the clean_text method.
    """
    input_text = "Hello! This is a Text. #Testing123"
    expected_output = "hello this is a text "

    cleaned_text = mock_model_service.clean_text(input_text)
    assert cleaned_text == expected_output


def test_prepare_data(mock_model_service):
    """
    Test Prepare Data
    Test the functionality of the prepare_data method.
    """
    input_data = "Hello, world! #Testing123"
    expected_features = {'cleaned_text': {0: 'hello world '}}

    features = mock_model_service.prepare_data(input_data)
    assert features.to_dict() == expected_features


@patch('mlflow.pyfunc.load_model')
def test_predict(mock_load_model, mock_model_service):
    """
    Test Predict
    Test the functionality of the predict method.
    """
    mock_load_model.return_value = Mock(predict=Mock(return_value=[0]))
    prediction = mock_model_service.predict('test data')
    assert prediction == 0
    mock_load_model.assert_called_once()


if __name__ == "__main__":
    pytest.main([__file__])
