import re

folder = 'aws/elastic-load-balancer'
varFile = ''

docRe = r'- \([\w()]+\) \*\*`([^`\s]+)(?:\s=.+)?`\*\*\s_\[since\sv([\w\d.]+)\]_\n+(\s*)(.*)'
linkRefRe = r'\[([^\]]+)\]\[([^\]]+)\]'
linkRefDefRe = r'\[([^\]]+)\]:\s*(.*)'

with open(f'{folder}/variables.tf', 'r') as f:
  varFile = f.read()

with open(f'{folder}/README.md', 'r') as f:
  lines = f.read()
  variables = re.findall(docRe, lines)
  linkRefDictMatches = re.findall(linkRefDefRe, lines)
  linkRefDict = { m[0]: m[1] for m in linkRefDictMatches }

  for match in variables:
    docBlkSrc = [match[3], '']

    linkRefs = re.findall(linkRefRe, match[3])

    if linkRefs:
      pass

    docBlk = f"""
/// {match[3]}
///
/// @since {match[1]}
{match[0]} =
""".rstrip()

    varFile = re.sub(rf'\s+{match[0]}\s+=', docBlk, varFile)

  print(varFile)
