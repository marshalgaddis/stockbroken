import requests
import codecs

f = open('names.txt')
line = f.readline()
username, password = line.strip().split(':')
f.close()
url = 'https://secure.lightspeed.com/secure/'
logfile = codecs.open('log.html', 'w', 'utf-8')

login_data = {'Username': username,
              'Password': password,
              'remember_me': True}

s = requests.Session()

r1 = s.post(url, data=login_data)

r2 = s.get('https://secure.lightspeed.com/secure/OPSignon.php')
r2.encoding = 'utf-8'

logfile.write(r2.text)

f.close()
logfile.close()
