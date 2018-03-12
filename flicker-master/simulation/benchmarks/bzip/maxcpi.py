log = open("run.log")
NUM = 1000
maxcpis = [0.0] * NUM
i = 0
maxrange = 0.0

for line in log:
    if line.startswith("Cycle Count:"):
        parts = (" ".join(line.split())).split(" ")              
        cpi = float(parts[5])/float(parts[2])
        maxcpis[i%NUM] = cpi
        temp = 0.0
        for k in range(NUM):
            temp = temp + maxcpis[k]
        if temp > maxrange: maxrange = temp
        i = i+1
print("Max avg CPI: %f" % (maxrange/NUM))
