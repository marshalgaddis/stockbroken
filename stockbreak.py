import re
import datetime
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
import stocktrim


def drive(driver, username, password, startdate="01/01/2013",
          enddate=datetime.date.today().strftime("%d/%m/%Y")):
    base_url = "https://secure.lightspeed.com"

    driver.get(base_url + "/secure/index.php")

    driver.find_element_by_id("inputUserName").clear()
    driver.find_element_by_id("inputUserName").send_keys(username)
    driver.find_element_by_name("Password").clear()
    driver.find_element_by_name("Password").send_keys(password)
    driver.find_element_by_name("Login").click()
    driver.find_element_by_link_text("Online Account Access").click()

    driver.switch_to_window('reportaccess')

    elem = driver.find_element_by_id("BasicMenui21")
    hover = ActionChains(driver).move_to_element(elem)
    hover.perform()
    driver.find_element_by_id("BasicMenui23").click()

    driver.find_element_by_id("_ctl1_radTradeTransactions").click()
    driver.find_element_by_id("_ctl1_btnNext_btn").click()
    driver.find_element_by_id("_ctl1_radDateRange").click()
    driver.find_element_by_id("_ctl1_btnNext_btn").click()
    driver.find_element_by_id("_ctl1_radTradeDate").click()
    driver.find_element_by_id("_ctl1_btnNext_btn").click()

    fdate = driver.find_element_by_id("_ctl1_ctlFromToDates_txtStartDate_txt")
    fdate.clear()
    fdate.send_keys(startdate)

    tdate = driver.find_element_by_id("_ctl1_ctlFromToDates_txtEndDate_txt")
    tdate.clear()
    tdate.send_keys(enddate)

    driver.find_element_by_id("_ctl1_btnGo_btn").click()
    driver.find_element_by_id("_ctl1_ctlTitlebar_imgSave").click()

    driver.switch_to_window("PensonPopupWindow")

    driver.find_element_by_id("btnDL_btn").click()
    driver.find_element_by_id("lblRightClick").click()

    s = str(driver.page_source)
    return justText(s)


def justText(s):
    return re.sub(r"<.*?>", "", s)


def main():
    f = open('names.txt', 'r')
    line = f.readline()
    username, password = line.strip().split(':')
    f.close()

    g = open('dates.log', 'a+')
    g.seek(0)
    lines = g.readlines()
    lastdate = lines[-1]

    d = webdriver.Chrome()
    data = drive(d, username, password, lastdate)
    d.quit()

    linedata = data.strip().split("\n")

    outtext = stocktrim.main(linedata[1:])

    outfile = open('newdata.csv', 'w')
    for line in outtext:
        outfile.write(line)
    outfile.close()

    g.write(datetime.date.today().strftime("%d/%m/%Y") + "\n")
    g.close()


if __name__ == "__main__":
    main()
