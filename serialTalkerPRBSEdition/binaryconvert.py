file = open("sampleOutput.txt", "r")

for line in file:
    print(int(line, 2))

