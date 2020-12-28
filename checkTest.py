

right = open('right.txt').read().split('\n')
output = open('output.txt').read().split('\n')

for i, j in zip(right, output):
  if i != j:
    print(i, j)
