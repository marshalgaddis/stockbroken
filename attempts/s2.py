import urllib
import urllib2
import cookielib

f = open('names.txt')
line = f.readline()
username, password = line.strip().split(':')
f.close()
url = 'https://secure.lightspeed.com/secure/'
logfile = open('log.html', 'w')
cj = cookielib.MozillaCookieJar('login.cookies')

login_data = urllib.urlencode({'Username': username,
                               'Password': password,
                               'remember_me': True})

opener = urllib2.build_opener(urllib2.HTTPRedirectHandler(),
                              urllib2.HTTPHandler(debuglevel=0),
                              urllib2.HTTPSHandler(debuglevel=0),
                              urllib2.HTTPCookieProcessor(cj))

response = opener.open(url)
cj.save()
response = opener.open(url, login_data)
cj.save()

logfile.write(response.read())

f.close()
logfile.close()
