def gcd (a,b):
    if (b == 0):
        return a
    else:
         return gcd (b, a % b)
s = input()
A = [ord(c) for c in s]
res = A[0]
for c in A[1::]:
    res = gcd(res , c)
code = '+'*res
code += '['
code += '+'*(ord(s[0])//res)
for c in s[1:]:
    code += '>'
    code += '+'*(ord(c)//res)
code += ']'
print(code)