
def main():
  # filename = input('Enter the file name: ')
  AV_assemble('test.txt')
  
def AV_assemble(filename):

  # open input and output files
  file = open(filename, 'r', encoding='utf-8')
  output = open('output.txt', 'w', encoding='utf-8')

  # read the code from the file
  code = file.read()

  # split the code into lines
  lines = code.split('\n')

  # loop over lines
  labels = {}   # to save labels
  variables = {} # to save variables
  index = 0     # index of the current line
  for line in lines:
    # remove whitespace from beginning and end of line
    line = line.strip()

    # if there is a comment slice it
    i = line.find(';')
    if i != -1:
      line = line[:i]

    # label
    label = line.find(':')
    if label != -1:
      # save the label and remove it from the line
      labels[line[:label]] = index
      line = line[label+1:].strip()
    
    # skip empty lines
    if len(line) == 0:
      continue
    
    mneum = line[:line.find(' ')]
    print(mneum, end=' ')
    
    if mneum == 'Define':
      # variables
      print('Variable')
      continue

    comma = line.find(',')
    if comma != -1:
      # two operands
      print('two operands and index is ', index)
    else:
      # one operand or branch or nop
      print('one operand or branch or nop and index is ', index)
    index += 1
    print(line, file=output)

  for item in labels.items():
    print(item)


if __name__ == '__main__':
  main()