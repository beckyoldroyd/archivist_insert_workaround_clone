#!/usr/bin/env python3

"""
Python 3
    Web scraping using selenium to get .xml
"""

import sys
import time
import os

from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities 

driver = webdriver.Remote(
         command_executor='http://selenium-standalone-firefox:4444/wd/hub',
         desired_capabilities=DesiredCapabilities.FIREFOX)

#driver = webdriver.Firefox(executable_path="/home/jenny/Documents/python_scripts.git/geckodriver")

def archivist_login(url, uname, pw):
    """
    Log in to archivist
    """
    driver.get(url)
    time.sleep(5)
    driver.find_element_by_id("login-email").send_keys(uname)
    driver.find_element_by_id("login-password").send_keys(pw)
    driver.find_element_by_class_name("btn-default").click()
    time.sleep(10)


def archivist_download_xml(output_dir, uname, pw):
    """
    downloading the only xml
    """

    # Log in 
    archivist_url = "https://closer-temp.herokuapp.com"
    export_url = "https://closer-temp.herokuapp.com/admin/export"
    archivist_login(archivist_url, uname, pw)
    driver.get(export_url)
    time.sleep(5)

    # one and only one questionaire
    trs = driver.find_elements_by_xpath("html/body/div/div/div/div/div/div/table/tbody/tr")

    # row 0 is header: tr has "th" instead of "td"
    tr = trs[1]

    # column 2 is "Prefix"
    prefix = tr.find_elements_by_xpath("td")[1].text

    # column 5 is "Export date"
    xml_date = tr.find_elements_by_xpath("td")[4].text

    # column 6 is "Actions", need to have both "download latest and export"
    xml_location = tr.find_elements_by_xpath("td")[5].find_elements_by_xpath("a")[0].get_attribute("href")

    print(xml_location)

    if not xml_location:
        raise ValueError("No download link for " + prefix)

    print("Getting xml for " + prefix) 
    driver.get(xml_location)

    time.sleep(5)
    print("  Downloading xml for " + prefix)
    out_f = os.path.join(output_dir, prefix + ".xml")

    with open(out_f, "wb") as f:
        f.write(driver.page_source.encode("utf-8"))

    driver.quit()


def main():
    username = sys.argv[1]
    pw = sys.argv[2]
    output_dir = "export_xml"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    archivist_download_xml(output_dir, username, pw)


if __name__ == "__main__":
    main()

