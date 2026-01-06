import re

folder = 'aws/elastic-load-balancer'
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

  for idx, match in enumerate(variables):
    indent = len(match[0]) // 2
    pathName = '.'.join([m[1] for m in variables[max(0, idx-indent):min(len(variables)-1, idx+1)]])
    varName = match[1]
    since = match[2]
    description = match[4]

    linkRefs = re.findall(linkRefRe, description)
    if linkRefs:
      pass

    docBlkSrc = [description, '', f'@since {since}']
    renderDocBlk = lambda prefix: '\n'.join([f'{prefix}{l}' for l in docBlkSrc])

    if indent == 0:
      varDefRe = r'(variable "' + re.escape(varName) + r'"[\s\S]*?description = )([^\n]*)'
      varFileSplit = re.search(varDefRe, varFile, re.MULTILINE)
      descReplacement = f"""<<EOT
{renderDocBlk('    ')}
  EOT"""

      if varFileSplit is None:
        print(f'Variable definition not found for top-level variable: {varName}')
        continue

      varFile = f'{varFile[0:varFileSplit.end(1)]}{descReplacement}{varFile[varFileSplit.end(2):]}'
    else:
      pass

#     docBlk = f"""
# /// {description}
# ///
# /// @since {since}
# {varName} =
# """.rstrip()

#     varFile = re.sub(rf'\s+{varName}\s+=', docBlk, varFile)

  print(varFile)
