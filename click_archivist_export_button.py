#!/usr/bin/env python3

"""
Python 3
    Web scraping using selenium to click export button
"""

import sys
import time

from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities 

driver = webdriver.Remote(
         command_executor='http://selenium-standalone-firefox:4444/wd/hub',
         desired_capabilities=DesiredCapabilities.FIREFOX)

# driver = webdriver.Firefox(executable_path="/home/jenny/Documents/python_scripts.git/geckodriver")


def archivist_login(url, uname, pw):
    """
    Log in to archivist
    """
    driver.get(url)
    time.sleep(5)
    driver.find_element_by_id("login-email").send_keys(uname)
    driver.find_element_by_id("login-password").send_keys(pw)
    driver.find_element_by_class_name("btn-default").click()
    time.sleep(5)


def click_export_button(uname, pw):
    """
    Click 'Export' for the only study
    """
    # log in
    archivist_url = "https://closer-temp.herokuapp.com"
    export_url = "https://closer-temp.herokuapp.com/admin/export"
    archivist_login(archivist_url, uname, pw)
    driver.get(export_url)
    time.sleep(10)

    # locate id and link
    trs = driver.find_elements_by_xpath("html/body/div/div/div/div/div/div/table/tbody/tr")
    tr = trs[1]

    # column 2 is "Prefix"
    xml_prefix = tr.find_elements_by_xpath("td")[1].text

    # column 6 is "Actions", click on "export"
    exportButton = tr.find_elements_by_xpath("td")[5].find_elements_by_xpath("a")[1]

    print("Click export button for " + xml_prefix)
    exportButton.click()
    time.sleep(5)

    driver.quit()


def main():
    uname = sys.argv[1]
    pw = sys.argv[2]

    click_export_button(uname, pw)


if __name__ == "__main__":
    main()
