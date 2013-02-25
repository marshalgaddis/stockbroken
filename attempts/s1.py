"""
# Script to log in to website and store cookies.
# run as: python stockbroken.py
#
# sources of code include:
#
# http://stackoverflow.com/questions/2954381/python-form-post-using-urllib2-also-question-on-saving-using-cookies
# http://stackoverflow.com/questions/301924/python-urllib-urllib2-httplib-confusion
# http://www.voidspace.org.uk/python/articles/cookielib.shtml
#
# mashed together by Martin Chorley
# 
# Licensed under a Creative Commons Attribution ShareAlike 3.0 Unported License.
# http://creativecommons.org/licenses/by-sa/3.0/
"""

import urllib
import urllib2
import cookielib
#import sys


class WebLogin(object):

    def __init__(self):
        # url for website we want to log in to
        self.base_url = 'https://secure.lightspeed.com/secure'
        # file for storing cookies
        self.cookie_file = 'login.cookies'

        # user provided username and password
        self.username = 'MG3980274'
        self.password = 'Mcg4739700'

        # set up a cookie jar to store cookies
        self.cj = cookielib.MozillaCookieJar(self.cookie_file)

        # set up opener to handle cookies, redirects etc
        self.opener = urllib2.build_opener(
            urllib2.HTTPRedirectHandler(),
            urllib2.HTTPHandler(debuglevel=0),
            urllib2.HTTPSHandler(debuglevel=0),
            urllib2.HTTPCookieProcessor(self.cj)
        )

        # pretend we're a web browser and not a python script
        self.opener.addheaders = [('User-agent',
            ('Mozilla/4.0 (compatible; MSIE 6.0; '
            'Windows NT 5.2; .NET CLR 1.1.4322)'))
        ]

        # open the front page of the website to set and save initial cookies
        response = self.opener.open(self.base_url)
        self.cj.save()

        # try and log in to the site
        response = self.login()

        outfile = open('log.html', 'w')
        outfile.write(response.read())
        outfile.close()

    # method to do login
    def login(self):

        # parameters for login action
        # may be different for different websites
        # check html source of website for specifics
        login_data = urllib.urlencode({
            'Username': self.username,
            'Password': self.password,
            'remember_me': True
        })

        # construct the url
        login_url = self.base_url
        # then open it
        response = self.opener.open(login_url, login_data)
        # save the cookies and return the response
        self.cj.save()
        return response


if __name__ == "__main__":

#    args = sys.argv
#
#    # check for username and password
#    if len(args) != 3:
#        print "Incorrect number of arguments"
#        print "Argument pattern: username password"
#        exit(1)
#
#    username = args[1]
#    password = args[2]

    # initialise and login to the website

    WebLogin()
