# class containing:
# 1 - the mneumonic of the line
# 2 - number of operands
# 3 - 1 boolean for src and another for destintion determining if they are indirect (0 = direct, 1 = ind)
# 4 - code for src Register and dest Register or name of the variable

# no_op
# 2 for 2 operands
# 1 for 1 operand
# 0 for nop

import re

class Line:
  def __init__(self, mneum="", no_op=0, srcCode=-1, dstCode=-1, index=-1, valueS=0, valueD=0, vSrc=0, vDst=0, jsr=0):
    self.mneum = mneum
    self.no_op = no_op
    self.srcCode = srcCode
    self.dstCode = dstCode
    self.index = index
    self.vSrc = vSrc
    self.vDst = vDst
    self.valueS = valueS
    self.valueD = valueD
    self.jsr = jsr

def check(op, variables):
  indir = 0
  code = -1
  vbool = 0
  t = 0
  value = -1
  if op[0] == '@':
    indir = 1
    op = op[1:]

  n = len(op)
  match = re.compile('R([0-7])')
  l = match.findall(op)
  if len(l) == 1 and n == 2:
    # register
    code = int(l[0])
    t = 0

  match = re.compile('\-\(R([0-7])\)')
  l = match.findall(op)
  if len(l) == 1:
    # auto decrement
    code = int(l[0])
    t = 2

  match = re.compile('\(R([0-7])\)\+')
  l = match.findall(op)
  if len(l) == 1:
    # auto increment
    code = int(l[0])
    t = 1

  match = re.compile('([0-9]+)\(R([0-7])\)')
  l = match.findall(op)
  if len(l) == 1:
    # indexed
    code = int(l[0][1])
    value = l[0][0]
    vbool = 1
    t = 3

  if op[0] == '#':
    code = 7
    indir = 0
    t = 1

    value = int(op[1:])
    if value > 32767 or value < -32768:
        print('nfs el 7aga ely fo2')
        exit(1)
    vbool = 1

  

  if code == -1:
    vbool = 2
    code = 7
    indir = 0
    t = 3
    value = op

  bstring = "{0:{fill}2b}".format(t, fill='0') + "{0:{fill}1b}".format(indir, fill='0') + "{0:{fill}3b}".format(code, fill='0')
  return (bstring, vbool, value)


opCode2 = {
  'mov': '0000', 'add': '0001', 'adc': '0010', 'sub': '0011',
  'sbc': '0100', 'and': '0101', 'or': '0110', 'xor': '0111', 'cmp': '1000'}
opCode1 = {
'inc': '0000', 'dec': '0001', 'clr': '0010', 'inv': '0011', 'lsr': '0100',
  'ror': '0101', 'asr': '0110', 'lsl': '0111', 'rol': '1000'
}
opCodeB = {
  'br': '000', 'beq': '001', 'bne': '010', 'blo': '011', 'bls': '100',
  'bhi': '101', 'bhs': '110'
}

misc = { 'jsr': '1100000000',
 'rts': '1100010000000000',
  'iret':'1100100000000000'}

opCodenop = {'hlt': '101100', 'nop': '101101'}
  


def main():
  # filename = input('Enter the file name: ')
  AV_assemble('test.txt')


def AV_assemble(filename):

  # open input file
  file = open(filename, 'r', encoding='utf-8')

  output = open('output.txt', 'w', encoding='utf-8')

  # read the code from the file
  code = file.read()

  # split the code into lines
  lines = code.split('\n')

  # loop over lines
  labels = {}   # to save labels
  variables = {}  # to save variables
  new_lines = []
  index = 0
  for i in range(len(lines)):
    if len(lines[i]) == 0:
      continue

    # if there is a comment slice it
    j = lines[i].find(';')
    if j != -1:
      lines[i] = lines[i][:j]

    if len(lines[i]) == 0:
      continue

    # if label save it and continue
    labelI = lines[i].find(':')
    if labelI != -1:
      labels[lines[i][:labelI]] = index
      continue

    
    lineOb = Line()
    lines[i] = lines[i].split()
    lines[i][0] = lines[i][0].lower()
    lineOb.index = index

    # if variable save it and continue
    if lines[i][0] == 'define':
      #variable
      variables[lines[i][1]] = (lines[i][2], index)
      index += 1
      continue

    
    if lines[i][0] in opCode2:
      lineOb.mneum = opCode2[lines[i][0]]
      
      # two operands
      lineOb.no_op = 2
      if len(lines[i]) == 2:
        ops = lines[i][1].split(',')
        if len(ops) == 2:          
          lineOb.srcCode, lineOb.vSrc, lineOb.valueS = check(ops[0], variables)
          lineOb.dstCode, lineOb.vDst, lineOb.valueD = check(ops[1], variables)
        else:
          print('error on this line: ', lines[i])
          exit(1)

      elif len(lines[i]) == 3:
        if lines[i][1][-1] == ',':
          lines[i][1] = lines[i][1][:-1]
          lineOb.srcCode, lineOb.vSrc, lineOb.valueS = check(lines[i][1], variables)
          lineOb.dstCode, lineOb.vDst, lineOb.valueD = check(lines[i][2], variables)
          
        else:
          print('error on this line: ', lines[i])
          exit(1)
      
      elif len(lines[i]) == 4:
        if lines[i][2] == ',':
          lineOb.srcCode, lineOb.vSrc, lineOb.valueS = check(lines[i][1], variables)
          lineOb.dstCode, lineOb.vDst, lineOb.valueD = check(lines[i][3], variables)
          
        else:
          print('error on this line: ', lines[i])
          exit(1)
      else:
        print('error on this line: ', lines[i])
        exit(1)

      if lineOb.vSrc != 0:
        index += 1
      if lineOb.vDst != 0:
        index += 1
    elif lines[i][0] in opCode1:
      lineOb.no_op = 1
      lineOb.mneum = opCode1[lines[i][0]]
      # one operand
      if len(lines[i]) == 2:
        lineOb.dstCode, lineOb.vDst, lineOb.valueD = check(lines[i][1], variables)
        
      else:
        print('error on this line: ', lines[i])
        exit(1)
      if lineOb.vDst != 0:
        index += 1

    elif lines[i][0] in opCodeB:
      lineOb.no_op = 1
      lineOb.mneum = opCodeB[lines[i][0]]
      # branch
      if len(lines[i]) == 2:
        lineOb.valueD = lines[i][1]
      else:
        print('error on this line: ', lines[i])
        exit(1)

    elif lines[i][0] in misc:
      lineOb.no_op = 5
      lineOb.mneum = misc[lines[i][0]]
      # misc
      if (len(lines[i]) == 2):
        lineOb.dstCode, lineOb.vDst, lineOb.valueD = check(lines[i][1], variables)
        lineOb.jsr = 1
        if lineOb.vDst != 0:
          index += 1
        
    else:
      lineOb.mneum = opCodenop[lines[i][0]]
      lineOb.no_op = 0
      # nop
      if len(lines[i]) != 1:
        print('error on this line: ', lines[i])
        exit(1)
    
    new_lines.append(lineOb)
    index += 1

  # final round -> you either win or die
  for line in new_lines:
    # print address of each line (first word)
    print(f"{hex(line.index)[2:]}: ", end="", file=output)
    if line.no_op == 0:
      line.mneum = line.mneum + '0000000000'
      print(line.mneum, file=output)
      continue
    elif line.no_op == 1:
      if len(line.mneum) == 4:
        line.mneum = '100100' + line.mneum
        # operand
        print(line.mneum+ line.dstCode, file=output)
        if line.vDst == 1:
          print(f"{hex(line.index+1)[2:]}: ", end='', file=output)
          print("{0:{fill}16b}".format((line.valueD + 2**16) % 2**16, fill='0'), file=output)
        elif line.vDst == 2:
          print(f"{hex(line.index+1)[2:]}: ", end='', file=output)
          print("{0:{fill}16b}".format((int(variables[line.valueD][1])-line.index-1 + 2**16) % 2**16, fill='0'), file=output)
          continue
      else:
        line.mneum = '10100' + line.mneum
        offset = int(labels[line.valueD]) - line.index-1
        print(line.mneum + "{0:{fill}8b}".format((offset + 2**8) % 2**8, fill='0'), file=output)
        continue
    
    elif line.no_op == 2:
      one = None
      two = None
      print(line.mneum + line.srcCode + line.dstCode, file=output)
      if line.vSrc == 1:
        one = line.valueS
      elif line.vSrc == 2:
        one = int(variables[line.valueS][1]) - line.index - 1
      if line.vDst == 1:
        two = line.valueD
      elif line.vDst == 2:
        two = int(variables[line.valueD][1]) - line.index - 1
        if one is not None:
          two -= 1
    
      if one is not None:
        print(f"{hex(line.index+1)[2:]}: ", end="", file=output)
        print("{0:{fill}16b}".format((one + 2**16) % 2**16, fill='0'), file=output)
      if two is not None:
        if line.vSrc != 0:
          line.index += 1
        print(f"{hex(line.index+1)[2:]}: ", end="", file=output)
        print("{0:{fill}16b}".format((two + 2**16) % 2**16, fill='0'), file=output)
  
    elif line.no_op == 5:
      if len(line.mneum) == 10:
        print(line.mneum+ line.dstCode, file=output)
        if line.vDst == 1:
          print(f"{hex(line.index+1)[2:]}: ", end="", file=output)
          print("{0:{fill}16b}".format((line.valueD + 2**16) % 2**16, fill='0'), file=output)
          
        elif line.vDst == 2:
          print(f"{hex(line.index+1)[2:]}: ", end='', file=output)
          address = ''
          if line.valueD in labels:
            address = labels[line.valueD]
          elif line.valueD in variables:
            address = int(variables[line.valueD][0])

          print("{0:{fill}16b}".format((address + 2**16) % 2**16, fill='0'), file=output)
          

      else:
        print(line.mneum, file=output)

  values = variables.values()
  values = sorted(values, key= lambda k : k[1])

  for value in values:
    print(f"{hex(value[1])[2:]}: " + "{0:{fill}16b}".format((int(value[0]) + 2**16) % 2**16, fill='0'), file=output)
  
    
    

if __name__ == '__main__':
  main()
