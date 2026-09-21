import subprocess

import psycopg2
import pytest

DB_CONFIG = {
    "database": "dwh_hw_db",
    "user": "postgres",
    "password": "",
    "host": "localhost",
    "port": "5432",
}


@pytest.fixture(scope="session")
def db_cursor():

    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    yield cursor
    cursor.close()
    conn.close()


def pytest_sessionfinish(session, exitstatus):

    results_dir = session.config.getoption("--alluredir", default=None)
    if not results_dir:
        return
    report_dir = f"{results_dir}_report"
    cmd = (
        f'allure generate "{results_dir}" --single-file --clean -o "{report_dir}"'
    )
    try:
        subprocess.run(cmd, shell=True, check=True)
        print(f"\n[ALLURE] Single-file report generated in: {report_dir}")
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"\n[ALLURE] Report generation skipped ({exc}).")
