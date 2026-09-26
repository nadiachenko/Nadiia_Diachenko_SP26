import allure
import pytest


@pytest.mark.ui
@allure.title("Capture report views: showcase title is displayed")
def test_showcase_title_displayed(capture_page):
    with allure.step("The 'Capture report views' title is visible on the page"):
        assert capture_page.is_showcase_title_displayed(), \
            "Showcase title 'Capture report views' not displayed"


@pytest.mark.ui
@allure.title("Capture report views: a control button is present")
def test_control_button_present(capture_page):
    with allure.step("The 'Get resources' control is present on the page"):
        assert capture_page.is_get_resources_present(), \
            "'Get resources' control not found"
