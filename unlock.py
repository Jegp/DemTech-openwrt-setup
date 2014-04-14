import hashlib

def getCode(imei, salt):
    digest = hashlib.md5((imei+salt).lower()).digest()
    code = 0
    for i in range(0,4):
        code += (ord(digest[i])^ord(digest[4+i])^ord(digest[8+i])^ord(digest[12+i])) << (3-i)*8
        code &= 0x1ffffff
        code |= 0x2000000
    return code

# Your IMEI goes here:
imei = "867989013465121"

print "Unlock code: %s" % getCode(imei, "5e8dd316726b0335")
print "Flash code: %s" % getCode(imei, "97b7bc6be525ab44")
