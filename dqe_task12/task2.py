from selenium import webdriver

driver = webdriver.Chrome()
driver.get("https://google.com")
print("Chrome title:", driver.title)
driver.quit()


from selenium.webdriver.firefox.service import Service

service = Service(executable_path=r"C:\Users\user\geckodriver-v0.37.1-win64\geckodriver.exe")
ff_driver = webdriver.Firefox(service=service)
ff_driver.get("https://google.com")
print("Firefox title:", ff_driver.title)
ff_driver.quit()