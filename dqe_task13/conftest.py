import os
from unittest.mock import MagicMock

import pytest
import yaml
from selenium import webdriver

from Pages.capture_report_views_page import CaptureReportViewsPage


# ---------------- API fixtures (from Task 12, unchanged) ----------------
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


# ---------------- Selenium config + browser fixtures ----------------
def _load_selenium_config():
    root = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(root, "Configs", "config_selenium.yaml")) as f:
        return yaml.safe_load(f)["global"]


@pytest.fixture(scope="session")
def selenium_config():
    return _load_selenium_config()


@pytest.fixture
def browser(selenium_config):
    driver = webdriver.Chrome()                       # Selenium Manager handles the driver
    driver.maximize_window()
    driver.implicitly_wait(selenium_config["delay"])
    driver.get(selenium_config["report_uri"])
    yield driver
    driver.quit()


@pytest.fixture
def capture_page(browser, selenium_config):
    return CaptureReportViewsPage(browser, selenium_config["delay"])
