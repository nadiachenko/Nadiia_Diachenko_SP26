from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC


class CaptureReportViewsPage:
    """Page Object for the 'Capture report views' showcase.

    Power BI renders the report itself inside a nested iframe with
    auto-generated, unstable locators, so we test the STABLE outer
    showcase UI instead (a title and a control button). The text below
    comes from the app's own UI-string table, so it reliably renders.
    """

    def __init__(self, driver, delay):
        self.driver = driver
        self.delay = delay

        # Stable, human-readable text locators on the outer showcase page.
        self.showcase_title = (
            By.XPATH, "//*[normalize-space(text())='Capture report views']"
        )
        self.get_resources_button = (
            By.XPATH, "//*[normalize-space(text())='Get resources']"
        )
        # Fallbacks if 'Get resources' is not found: 'Full screen', 'Showcases'.

    def _wait_present(self, locator):
        WebDriverWait(self.driver, self.delay).until(
            EC.presence_of_element_located(locator)
        )
        return self.driver.find_elements(*locator)

    def is_showcase_title_displayed(self):
        elements = self._wait_present(self.showcase_title)
        return any(e.is_displayed() for e in elements)

    def is_get_resources_present(self):
        return len(self._wait_present(self.get_resources_button)) > 0
