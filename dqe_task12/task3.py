

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.relative_locator import locate_with

driver = webdriver.Chrome()
driver.implicitly_wait(5)
driver.get("https://phptravels.com/demo")


def check(label, by, value):
    els = driver.find_elements(by, value)
    status = "OK" if len(els) == 1 else "NOT UNIQUE"
    print(f"[{status}] {label:12} {value!r} -> {len(els)} match(es)")


def check_relative(label, relative_locator):
    els = driver.find_elements(relative_locator)
    status = "OK" if len(els) == 1 else "NOT UNIQUE"
    print(f"[{status}] {label:12} -> {len(els)} match(es)")


#CLASS NAME
check("class name", By.CLASS_NAME, "first_name")
check("class name", By.CLASS_NAME, "last_name")

#ID
check("id", By.ID, "demo-form")
check("id", By.ID, "number")

#NAME
check("name", By.NAME, "website")
check("name", By.NAME, "robots")

#CSS SELECTOR
check("css", By.CSS_SELECTOR, "input[type='email']")
check("css", By.CSS_SELECTOR, "select.country_id")

#XPATH
check("xpath", By.XPATH, "//h1[contains(text(),'Test the Booking Engine')]")
check("xpath", By.XPATH, "//h2[text()='Request Instant Demo']")

#RELATIVE LOCATORS
check_relative(
    "relative",
    locate_with(By.CLASS_NAME, "last_name").to_right_of({By.CLASS_NAME: "first_name"})
)
check_relative(
    "relative",
    locate_with(By.CLASS_NAME, "company_name").below({By.CLASS_NAME: "first_name"})
)

driver.quit()
