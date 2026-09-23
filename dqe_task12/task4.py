from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

driver = webdriver.Chrome()

driver.implicitly_wait(5)

driver.get("https://www.google.com")

input(">>> Handle any CAPTCHA/consent in the browser, then press Enter here...")

search_box = driver.find_element(By.NAME, "q")
search_box.send_keys("Selenium")
search_box.send_keys(Keys.RETURN)

input(">>> If a CAPTCHA appeared after searching, solve it, then press Enter...")


first_result = WebDriverWait(driver, 10).until(
    EC.element_to_be_clickable((By.CSS_SELECTOR, "div#search h3"))
)
first_result.click()

WebDriverWait(driver, 10).until(lambda d: "Google" not in d.title)
print("Opened page title:", driver.title)

driver.quit()
