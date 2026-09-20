import time

import pytest

@pytest.fixture(scope="session", autouse=True)
def track_suite_time():
    suite_start = time.perf_counter()
    yield
    suite_elapsed = time.perf_counter() - suite_start
    print(f"\n[SUITE] Total suite execution time: {suite_elapsed:.4f} s")


@pytest.fixture()
def track_test_time():
    test_start = time.perf_counter()
    yield
    test_elapsed = time.perf_counter() - test_start
    print(f"\n[TEST]  Test execution time: {test_elapsed:.4f} s")


def add_numbers(a, b):
    return a + b

@pytest.mark.parametrize(
    "a, b, delay, expected",
    [
        (3, 5, 2, 8),
        (-3, -5, 3, -8),
    ],
    ids=["two_positive", "two_negative"],
)
def test_add_numbers(track_test_time, a, b, delay, expected):
    result = add_numbers(a, b)
    time.sleep(delay)
    assert result == expected, (
        f"add_numbers({a}, {b}) returned {result}, expected {expected}"
    )


def test_add_negative_and_positive_numbers():
    a, b = -3, 5
    result = add_numbers(a, b)
    time.sleep(10)
    assert result == 2, f"add_numbers({a}, {b}) returned {result}, expected 2"
