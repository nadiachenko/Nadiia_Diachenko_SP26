from unittest.mock import MagicMock

import pytest


@pytest.fixture
def base_url():

    return "https://jsonplaceholder.typicode.com"


@pytest.fixture
def gcp_bucket():
    return "gcp-forecast-source-bucket"


@pytest.fixture
def gcp_date_prefix():
    return "forecasts/2026-09-22/"


@pytest.fixture
def gcp_client():
    client = MagicMock()
    fake_blob = MagicMock()
    fake_blob.name = "forecasts/2026-09-22/part-0001.parquet"
    client.list_blobs.return_value = iter([fake_blob])
    return client

@pytest.fixture
def target_bucket():
    return "nadiia-diachenko-dwh-bucket"


@pytest.fixture
def date_prefix():
    return "forecasts/2026-09-22/"


@pytest.fixture
def s3_client():
    client = MagicMock()
    client.list_objects_v2.return_value = {
        "KeyCount": 1,
        "Contents": [{"Key": "forecasts/2026-09-22/part-0001.parquet"}],
    }
    return client
