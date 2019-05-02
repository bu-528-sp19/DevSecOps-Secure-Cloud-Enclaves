# -*- coding: utf-8 -*-
"""
Created on Thu Apr 11 01:32:56 2019

@author: AvantikaDG
"""
import base64
import hashlib
from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

__key__ = hashlib.sha256(b'16-character key').digest()

def encrypt(raw):
    BS = AES.block_size
    pad = lambda s: s + (BS - len(s) % BS) * chr(BS - len(s) % BS)

    raw = base64.b64encode(pad(raw).encode('ISO-8859-1'))
    iv = get_random_bytes(AES.block_size)
    cipher = AES.new(key= __key__, mode= AES.MODE_CFB,iv= iv)
    return base64.b64encode(iv + cipher.encrypt(raw))

def decrypt(enc):
    unpad = lambda s: s[:-ord(s[-1:])]

    enc = base64.b64decode(enc)
    iv = enc[:AES.block_size]
    cipher = AES.new(__key__, AES.MODE_CFB, iv)
    return unpad(base64.b64decode(cipher.decrypt(enc[AES.block_size:])).decode('ISO-8859-1'))
    
file = open("Sample.txt", "r")
contents = file.readlines()
file.close()
newfile = []
for line in contents:
    enc = encrypt(line)
    newfile.append(enc)

makeitastring = ''.join(map(str, newfile))
file = open("Sample.txt", "w")
file.write(makeitastring)
file.close()


file = open("Sample.txt")
contents = file.readlines()
file.close()
decfile = []
for line in newfile:
    dec = decrypt(line)
    decfile.append(dec)
    


