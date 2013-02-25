from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
import unittest, time, re

class S5(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Firefox()
        self.driver.implicitly_wait(30)
        self.base_url = "https://secure.lightspeed.com/"
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_s5(self):
        driver = self.driver
        driver.get(self.base_url + "/secure/index.php")
        driver.find_element_by_id("inputUserName").clear()
        driver.find_element_by_id("inputUserName").send_keys("MG3980274")
        driver.find_element_by_name("Password").clear()
        driver.find_element_by_name("Password").send_keys("Itsagood1")
        driver.find_element_by_name("Login").click()
        driver.find_element_by_link_text("Online Account Access").click()
        # ERROR: Caught exception [ERROR: Unsupported command [selectWindow | name=reportaccess | ]]
        driver.find_element_by_id("BasicMenui23").click()
        driver.find_element_by_id("_ctl1_radTradeTransactions").click()
        driver.find_element_by_id("_ctl1_btnNext_btn").click()
        driver.find_element_by_id("_ctl1_radDateRange").click()
        driver.find_element_by_id("_ctl1_btnNext_btn").click()
        driver.find_element_by_id("_ctl1_radTradeDate").click()
        driver.find_element_by_id("_ctl1_btnNext_btn").click()
        driver.find_element_by_id("_ctl1_ctlFromToDates_txtStartDate_txt").clear()
        driver.find_element_by_id("_ctl1_ctlFromToDates_txtStartDate_txt").send_keys("01/01/2012")
        driver.find_element_by_id("_ctl1_ctlFromToDates_txtEndDate_txt").clear()
        driver.find_element_by_id("_ctl1_ctlFromToDates_txtEndDate_txt").send_keys("02/01/2013")
        driver.find_element_by_id("_ctl1_btnGo_btn").click()
        driver.find_element_by_id("_ctl1_ctlTitlebar_imgSave").click()
        # ERROR: Caught exception [ERROR: Unsupported command [waitForPopUp | PensonPopupWindow | 30000]]
        # ERROR: Caught exception [ERROR: Unsupported command [selectWindow | name=PensonPopupWindow | ]]
        driver.find_element_by_id("btnDL_btn").click()
        driver.find_element_by_id("lblRightClick").click()
    
    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException, e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert.text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
