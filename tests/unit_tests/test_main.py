"""
Test Main Module
This module contains unit tests for the FastAPI application defined in the 'main.py' module.

The tests cover the following:
- Basic functionality of the root endpoint.

"""

import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

sys.path.append(str(Path(__file__).resolve().parents[2]))
sys.path.append(str(Path(__file__).resolve().parents[2]) + '/deployment/app')

from deployment.app.main import app

client = TestClient(app)


def test_read_root():
    """
    Test Root Endpoint
    Test the basic functionality of the root endpoint.

    """
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"hello": "world"}


if __name__ == "__main__":
    pytest.main([__file__])
