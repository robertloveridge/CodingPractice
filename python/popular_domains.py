#!/usr/bin/python

import sys

# Write a script that takes a list of email addresses on STDIN and outputs the 10 
# most common domains (including counts).

domains = {}

for line in sys.stdin:
	line = line.rstrip()

	local, domain = line.split('@')

	if domain not in domains:
		domains[domain] = 1
	else:
		domains[domain] += 1

counter = 0;
for domain, count in sorted(domains.items(), lambda a, b: cmp(a[1], b[1]), reverse=True):
	if counter == 10:
		break
	counter += 1
	print "%r => %r" % (domain, count)
