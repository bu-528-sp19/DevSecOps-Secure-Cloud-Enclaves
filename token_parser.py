# -*- coding: utf-8 -*-
file = open(r"/inf/auth_token.txt", "r")
contents = file.readlines()
file.close()
for line in contents:
        if "| id         | " in line:
                token = line[len("| id         | "):len(line)-3]
command = 'TOKEN='+token
file = open(r"/inf/token.sh", "w")
file.write(command)
file.close()
