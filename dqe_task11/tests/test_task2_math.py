import os

import pytest
import yaml

def get_numbers_data(config_name):
    with open(config_name, "r") as stream:
        config = yaml.safe_load(stream)
    return config["cases"]


def add_numbers(a, b, c):
    try:
        return a + b + c
    except TypeError:
        raise TypeError("Please check the parameters. All of them must be numeric")


CONFIG_PATH = os.path.join(os.path.dirname(__file__), "config.yaml")
CASES = get_numbers_data(CONFIG_PATH)


@pytest.mark.smoke
@pytest.mark.parametrize(
    "numbers, expected",
    [(case["input"], case["expected"]) for case in CASES],
    ids=[case["case_name"] for case in CASES],
)
def test_add_numbers(numbers, expected):
    a, b, c = numbers
    result = add_numbers(a, b, c)
    assert result == expected, (
        f"add_numbers({a}, {b}, {c}) returned {result}, expected {expected}"
    )

@pytest.mark.critical
def test_add_invalid_types():
    with pytest.raises(TypeError):
        add_numbers("a", 2, 1)
