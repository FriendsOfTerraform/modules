import re

folder = 'aws/eventbridge-scheduler'
varFile = ''

docRe = r'([ ]*)- \([\w()]+\) \*\*`([^`\s]+)(?:\s=.+)?`\*\*\s_\[since\sv([\w\d.]+)\]_\n+(\s*)(.*)'
linkRefRe = r'\[([^\]]+)\]\[([^\]]+)\]'
linkRefDefRe = r'\[([^\]]+)\]:\s*(.*)'

with open(f'{folder}/variables.tf', 'r') as f:
  varFile = f.read()

with open(f'{folder}/README.md', 'r') as f:
  lines = f.read()
  variables = re.findall(docRe, lines)
  linkRefDictMatches = re.findall(linkRefDefRe, lines)
  linkRefDict = { m[0]: m[1] for m in linkRefDictMatches }

  variablesDict = {}
  for idx, match in enumerate(variables):
    pathName = []
    rawIndentation = match[0]
    isTopLevel = len(rawIndentation) == 0
    varName = match[1]
    since = match[2]
    description = match[4]

    if isTopLevel:
      pathName = [match[1]]
    else:
      pathName = [variables[idx][1]]
      currentLevel = len(variables[idx][0])

      for i in range(idx - 1, -1, -1):
        prevIndent = len(variables[i][0])

        if prevIndent < currentLevel:
          pathName.insert(0, variables[i][1])
          currentLevel = prevIndent

          if prevIndent == 0:
            break

    pathKey = '.'.join(pathName)
    variablesDict[pathKey] = (rawIndentation, varName, since, description)

  for pathName, [rawIndentation, varName, since, description] in variablesDict.items():
    isTopLevel = len(rawIndentation) == 0
    linkRefs = re.findall(linkRefRe, description)
    if linkRefs:
      pass

    docBlkSrc = [description, '', f'@since {since}']
    renderDocBlk = lambda prefix: '\n'.join([f'{prefix}{l}' for l in docBlkSrc])

    if isTopLevel:
      varDefRe = r'(variable "' + re.escape(varName) + r'"[\s\S]*?description = )("[^\n]*")'
      varFileSplit = re.search(varDefRe, varFile, re.MULTILINE)
      descReplacement = f"""<<EOT
{renderDocBlk('    ')}
  EOT"""

      if varFileSplit is None:
        print(f'Variable definition not found for top-level variable: {varName}')
        continue

      varFile = f'{varFile[0:varFileSplit.end(1)]}{descReplacement}{varFile[varFileSplit.end(2):]}'
    else:
      delimiterRe = r'(?:[\s\S]+?)'
      pathNameArr = pathName.split('.')
      varDefRe = r'(variable "' + pathNameArr[0] + delimiterRe + ''.join(map(lambda x: x + r'\s+=' + delimiterRe, pathNameArr[1:-1])) + r'\n)([ ]+)(' + pathNameArr[-1] + r'\s+=)'
      varFileSplit = re.search(varDefRe, varFile, re.MULTILINE)

      if varFileSplit is None:
        print(f'Variable definition not found for nested variable: {varName}')
        continue

      descReplacement = renderDocBlk(varFileSplit.group(2) + '/// ')
      varFile = f'{varFile[0:varFileSplit.end(1)]}{descReplacement}\n{varFileSplit.group(2)}{varFile[varFileSplit.start(3):]}'

with open(f'{folder}/variables.tf', 'w') as f:
  f.write(varFile)
