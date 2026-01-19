import re

docRe = r'([ ]*)- \([\w()]+\) \*\*`([^`\s]+)(?:\s=.+)?`\*\*\s_\[since\sv([\w\d.]+)\]_\n+(\s*)(.*)'
linkRefRe = r'\[([^\]]+)\]\[([^\]]+)\]'
linkRefDefRe = r'\[([^\]]+)\]:\s*(.*)'

def migrate_module(folder: str):
    with open(f'{folder}/variables.tf', 'r') as f:
      var_file = f.read()

    with open(f'{folder}/README.md', 'r') as f:
      lines = f.read()
      variables = re.findall(docRe, lines)
      link_ref_dict_matches = re.findall(linkRefDefRe, lines)
      linkRefDict = { m[0]: m[1] for m in link_ref_dict_matches }

      variables_dict = {}
      for idx, match in enumerate(variables):
        raw_indentation = match[0]
        is_top_level = len(raw_indentation) == 0
        var_name = match[1]
        since = match[2]
        description = match[4]

        if is_top_level:
          path_name = [match[1]]
        else:
          path_name = [variables[idx][1]]
          current_level = len(variables[idx][0])

          for i in range(idx - 1, -1, -1):
            prev_indent = len(variables[i][0])

            if prev_indent < current_level:
              path_name.insert(0, variables[i][1])
              current_level = prev_indent

              if prev_indent == 0:
                break

        path_key = '.'.join(path_name)
        variables_dict[path_key] = (raw_indentation, var_name, since, description)

      for path_name, [raw_indentation, var_name, since, description] in variables_dict.items():
        is_top_level = len(raw_indentation) == 0
        link_refs = re.findall(linkRefRe, description)
        if link_refs:
          pass

        doc_blk_src = [description, '', f'@since {since}']
        render_doc_blk = lambda prefix: '\n'.join([f'{prefix}{l}' for l in doc_blk_src])

        if is_top_level:
          var_def_re = r'(variable "' + re.escape(var_name) + r'"[\s\S]*?description = )("[^\n]*")'
          var_file_split = re.search(var_def_re, var_file, re.MULTILINE)
          desc_replacement = f"""<<EOT
{render_doc_blk('    ')}
  EOT"""

          if var_file_split is None:
            print(f'Variable definition not found for top-level variable: {var_name}')
            continue

          var_file = f'{var_file[0:var_file_split.end(1)]}{desc_replacement}{var_file[var_file_split.end(2):]}'
        else:
          delimiter_re = r'(?:[\s\S]+?)'
          path_name_arr = path_name.split('.')
          var_def_re = r'(variable "' + path_name_arr[0] + delimiter_re + ''.join(map(lambda x: x + r'\s+=' + delimiter_re, path_name_arr[1:-1])) + r'\n)([ ]+)(' + path_name_arr[-1] + r'\s+=)'
          var_file_split = re.search(var_def_re, var_file, re.MULTILINE)

          if var_file_split is None:
            print(f'Variable definition not found for nested variable: {var_name}')
            continue

          desc_replacement = render_doc_blk(var_file_split.group(2) + '/// ')
          var_file = f'{var_file[0:var_file_split.end(1)]}{desc_replacement}\n{var_file_split.group(2)}{var_file[var_file_split.start(3):]}'

    with open(f'{folder}/variables.tf', 'w') as f:
      f.write(var_file)

if __name__ == '__main__':
    provider = 'aws'
    exclude = [
        'acm',
        'cloudfront-distribution',
        'ec2',
        'ecr',
        'ecs',
        'ecs-service',
        'efs',
        'eks',
        'route53',
    ]

    from pathlib import Path

    modules = Path(provider)
    for module in modules.iterdir():
        if module.name in exclude:
            continue

        if module.is_file():
            continue

        print(f'Migrating {module.name}...')
        migrate_module(f'{provider}/{module.name}')
