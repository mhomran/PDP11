# class containing:
# 1 - the mneumonic of the line
# 2 - number of operands
# 3 - 1 boolean for src and another for destintion determining if they are indirect (0 = direct, 1 = ind)
# 4 - code for src Register and dest Register or name of the variable

# no_op
# 2 for 2 operands
# 1 for 1 operand
# 0 for nop


class Line:
  def init(self, mneum="", no_op=0, srcIndir=-1, srcCode=-1, dstIndir=-1, dstCode=-1, index=-1):
    self.mneum = mneum
    self.no_op = no_op
    self.dstIndir = dstIndir
    self.dstCode = dstCode
    self.index = index
    if no_op == 2:
      # two operands
      self.srcIndir = srcIndir
      self.srcCode = srcCode


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

opCodenop = {'hlt': '101100', 'nop': '101101'}
  


def main():
  # filename = input('Enter the file name: ')
  AV_assemble('test.txt')


def AV_assemble(filename):

  # open input file
  file = open(filename, 'r', encoding='utf-8')

  # output = open('output.txt', 'wb', encoding='utf-8')

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
      new_lines.append(lines[i])  
      continue

    # if variable save it and continue
    if i == 29:
      print('lol')
    lineOb = Line()
    lines[i] = lines[i].split()
    lines[i][0] = lines[i][0].lower()
    
    
    if lines[i][0] == 'define':
      #variable
      variables[lines[i][1]] = index
      index += 1
      continue

    
    if lines[i][0] in opCode2:
      # two operands
      if len(lines[i]) == 2:
        ops = lines[i][1].split(',')
        if len(ops) == 2:
          print(ops[0], ops[1])
          # ops[0] first
          # ops[1] second
        else:
          print('error on this line: ', lines[i])
          exit(1)

      elif len(lines[i]) == 3:
        if lines[i][1][-1] == ',':
          lines[i][1] = lines[i][1][:-1]
          # lines[i][1] first op
          # lines[i][2] second op
          print(lines[i][1], lines[i][2])
        else:
          print('error on this line: ', lines[i])
          exit(1)
      
      elif len(lines[i]) == 4:
        if lines[i][2] == ',':
          print(lines[i][1], lines[i][3])
          # lines[i][1] first op
          # lines[i][3] second op
        else:
          print('error on this line: ', lines[i])
          exit(1)
      else:
        print('error on this line: ', lines[i])
        exit(1)

    elif lines[i][0] in opCode1:
      # one operand
      if len(lines[i]) == 2:
        print(lines[i][1])
      else:
        print('error on this line: ', lines[i])
        exit(1)

    elif lines[i][0] in opCodeB:
      # branch
      if len(lines[i]) == 2:
        print(lines[i][1])
      else:
        print('error on this line: ', lines[i])
        exit(1)


    else:
      # nop
      if len(lines[i]) == 1:
        print(lines[i][0])
      else:
        print('error on this line: ', lines[i])
        exit(1)

    new_lines.append(lineOb)
    
    
  
  
    
    

if __name__ == '__main__':
  main()
