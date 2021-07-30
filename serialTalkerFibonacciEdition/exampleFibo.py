n1 = 0
n2 = 1
nt = 0 
print(n1)
print(n2)
for i in range(0,100):
    nt = n2
    n2 = n1 + n2
    n1 = nt
    print(n2)