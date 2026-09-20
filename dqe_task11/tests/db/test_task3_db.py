import os

import pytest
import yaml

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "config_sql.yaml")


def load_queries(group):
    with open(CONFIG_PATH, "r") as stream:
        config = yaml.safe_load(stream)
    return config[group]


SMOKE = load_queries("smoke")
CRITICAL = load_queries("critical")


@pytest.mark.smoke
@pytest.mark.parametrize(
    "sql, expected",
    [(case["sql"], case["expected"]) for case in SMOKE],
    ids=[case["name"] for case in SMOKE],
)
def test_object_presence(db_cursor, sql, expected):
    db_cursor.execute(sql)
    result = db_cursor.fetchone()[0]
    assert result == expected, f"expected {expected}, got {result} -- query: {sql}"


@pytest.mark.critical
@pytest.mark.parametrize(
    "sql, expected",
    [(case["sql"], case["expected"]) for case in CRITICAL],
    ids=[case["name"] for case in CRITICAL],
)
def test_data_quality(db_cursor, sql, expected):
    db_cursor.execute(sql)
    result = db_cursor.fetchone()[0]
    assert result == expected, f"expected {expected}, got {result} -- query: {sql}"
