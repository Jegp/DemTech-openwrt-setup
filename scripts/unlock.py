import hashlib
import sys

def getCode(imei, salt):
    digest = hashlib.md5((imei+salt).lower()).digest()
    code = 0
    for i in range(0,4):
        code += (ord(digest[i])^ord(digest[4+i])^ord(digest[8+i])^ord(digest[12+i])) << (3-i)*8
        code &= 0x1ffffff
        code |= 0x2000000
    return code

# Your IMEI goes here:
imei = sys.argv[1]

print "%s" % getCode(imei, "5e8dd316726b0335")
