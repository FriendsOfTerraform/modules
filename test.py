import re
from typing import Optional

docRe = r'([ ]*)- \(([\w()]+)\) \*\*`([^`\s]+)(?:\s=.+)?`\*\*\s_\[since\sv([\w\d.]+)\]_\n+(\s*)(.*)'
linkRefRe = r'\[([^\]]+)\][\(\[]([^\]\)]+)[\]\)]'
linkRefDefRe = r'\[([^\]]+)\]:\s*(.*)'

def return_enums_if_exists(str_val) -> tuple[list[str], str]:
    patterns = [
        r'Valid values:?\s*(?:are:?)?\s*(.+?)(?:\.|$)',
        r'Possible values are\s+(.+?)(?:\.|$)',
        r'Can be\s+(.+?)(?:\.|$)',
        r'Valid values are\s+(.+?)(?:\.|$)',
    ]

    for pattern in patterns:
        match = re.search(pattern, str_val, re.IGNORECASE | re.DOTALL)
        if match:
            values_str = match.group(1)

            # Extract values from backticks with optional quotes
            value_pattern = r'`"?([^"`]+?)"?`'
            values = re.findall(value_pattern, values_str)

            if values:
                cleaned_values = []
                for val in values:
                    val = val.strip()
                    # Filter out non-value patterns like ranges, time expressions, etc.
                    if val and not any(skip in val.lower() for skip in [
                        'example', 'e.g.', 'for example', 'such as',
                        'within', 'between', 'hours', 'minutes', 'days',
                        'default', 'null', 'arn:', 'http://', 'https://'
                    ]) and '-' not in val and '<' not in val and '>' not in val:
                        cleaned_values.append(val)

                if cleaned_values:
                    # Remove the matched text from the description
                    cleaned_str = str_val[:match.start()] + str_val[match.end():]
                    cleaned_str = re.sub(r'\s+', ' ', cleaned_str).strip()
                    return cleaned_values, cleaned_str

    return [], str_val

def return_examples_if_exists(str_val) -> tuple[list[str], str]:
    examples = []
    cleaned_str = str_val
    patterns = [
        r'\[(?:[Ss]ee\s+)?[Ee]xample\]\[([^\]]+)\]',
        r'\[(?:[Ss]ee\s+)?[Ee]xample\]\(([^)]+)\)',
        r'(?:[Pp]lease\s+)?[Ss]ee\s+\[example\]\[([^\]]+)\]',
        r'(?:[Pp]lease\s+)?[Ss]ee\s+\[example\]\(([^)]+)\)',
    ]

    for pattern in patterns:
        matches = re.finditer(pattern, cleaned_str)
        for match in matches:
            ref = match.group(1).strip()
            if ref.startswith('#'):
                ref = ref[1:]
            if ref and ref not in examples:
                examples.append(ref)
        # Remove the matched text from the description
        cleaned_str = re.sub(pattern, '', cleaned_str)

    # Clean up extra whitespace
    cleaned_str = re.sub(r'\s+', ' ', cleaned_str).strip()

    return examples, cleaned_str

def return_links_if_exists(str_val) -> list[tuple[str, str]]:
    linkMatches = re.findall(linkRefRe, str_val)

    return [(match[0], match[1]) for match in linkMatches]

def kebab_to_title(string):
    return string.replace('-', ' ').title()

def build_doc_block(description: str, since: str, link_ref_dict: dict, data_type: Optional[str] = None) -> list[str]:
    cleaned_description = description

    enum_values, cleaned_description = return_enums_if_exists(cleaned_description)
    example_refs, cleaned_description = return_examples_if_exists(cleaned_description)

    doc_blk_src = [cleaned_description, '']

    if enum_values:
        enum_str = '@enum ' + '|'.join(enum_values)
        doc_blk_src.append(enum_str)

    if example_refs:
        for example_ref in example_refs:
            doc_blk_src.append(f'@example "{kebab_to_title(example_ref)}" #{example_ref}')

    links = return_links_if_exists(description)
    if links:
        for link_name, link_url in links:
            if link_url.startswith('http'):
                doc_blk_src.append(f'@link "{link_name}" {link_url}')
            else:
                linked_ref_exists = link_ref_dict.get(link_url)

                if linked_ref_exists is not None:
                    doc_blk_src.append(f'@link {{{link_url}}} {linked_ref_exists}')

    if data_type is not None:
        doc_blk_src.append(f'@type {data_type}')

    doc_blk_src.append(f'@since {since}')

    return doc_blk_src

def render_doc_block(doc_blk_src: list[str], prefix: str = '    ') -> str:
    content = '\n'.join([f'{prefix}{l}' for l in doc_blk_src])

    return f"""<<EOT
{content}
  EOT"""

def read_file_safe(filepath: str) -> str | None:
    try:
        with open(filepath, 'r') as f:
            return f.read()
    except FileNotFoundError:
        return None

def split_readme_sections(readme_content: str) -> tuple[str, str | None]:
    outputs_section_match = re.search(r'## Outputs', readme_content)
    if outputs_section_match:
        variables_section = readme_content[:outputs_section_match.start()]
        outputs_section = readme_content[outputs_section_match.start():]
    else:
        variables_section = readme_content
        outputs_section = None

    return variables_section, outputs_section

def build_variable_path_dict(variables: list) -> dict:
    variables_dict = {}

    for idx, match in enumerate(variables):
        raw_indentation = match[0]
        is_top_level = len(raw_indentation) == 0
        data_type = match[1]
        var_name = match[2]
        since = match[3]
        description = match[5]

        if is_top_level:
            path_name = [match[2]]
        else:
            path_name = [variables[idx][2]]
            current_level = len(variables[idx][0])

            for i in range(idx - 1, -1, -1):
                prev_indent = len(variables[i][0])

                if prev_indent < current_level:
                    path_name.insert(0, variables[i][2])
                    current_level = prev_indent

                    if prev_indent == 0:
                        break

        path_key = '.'.join(path_name)
        variables_dict[path_key] = (raw_indentation, data_type, var_name, since, description)

    return variables_dict

def migrate_module(folder: str):
    with open(f'{folder}/variables.tf', 'r') as f:
        var_file = f.read()

    output_file = read_file_safe(f'{folder}/outputs.tf')

    with open(f'{folder}/README.md', 'r') as f:
        readme_content = f.read()

    variables_section, outputs_section = split_readme_sections(readme_content)
    variables = re.findall(docRe, variables_section)
    link_ref_dict_matches = re.findall(linkRefDefRe, readme_content)
    linkRefDict = { m[0]: m[1] for m in link_ref_dict_matches }
    variables_dict = build_variable_path_dict(variables)

    for path_name, [raw_indentation, _, var_name, since, description] in variables_dict.items():
        is_top_level = len(raw_indentation) == 0
        doc_blk_src = build_doc_block(description, since, linkRefDict)

        if is_top_level:
          var_def_re = r'(variable "' + re.escape(var_name) + r'"[\s\S]*?description = )("[^\n]*")'
          var_file_split = re.search(var_def_re, var_file, re.MULTILINE)
          desc_replacement = render_doc_block(doc_blk_src)

          if var_file_split is None:
            print(f'Variable definition not found for top-level variable: {var_name}')
            continue

          var_file = f'{var_file[0:var_file_split.end(1)]}{desc_replacement}{var_file[var_file_split.end(2):]}'
        else:
          delimiter_re = r'(?:[\s\S]+?)'
          path_name_arr = path_name.split('.')
          var_def_re = r'(variable "' + path_name_arr[0] + delimiter_re + ''.join(map(lambda x: r'\s+' + x + r'\s+=' + delimiter_re, path_name_arr[1:-1])) + r'\n)([ ]+)(' + path_name_arr[-1] + r'\s+=)'
          var_file_split = re.search(var_def_re, var_file, re.MULTILINE)

          if var_file_split is None:
            print(f'Variable definition not found for nested variable: {var_name}')
            continue

          nested_prefix = var_file_split.group(2) + '/// '
          desc_replacement = '\n'.join([f'{nested_prefix}{l}' for l in doc_blk_src])
          var_file = f'{var_file[0:var_file_split.end(1)]}{desc_replacement}\n{var_file_split.group(2)}{var_file[var_file_split.start(3):]}'

    with open(f'{folder}/variables.tf', 'w') as f:
      f.write(var_file)

    if output_file is not None and outputs_section is not None:
      outputs = re.findall(docRe, outputs_section)

      for match in outputs:
        raw_indentation = match[0]
        is_top_level = len(raw_indentation) == 0

        if not is_top_level:
          continue

        data_type = match[1]
        output_name = match[2]
        since = match[3]
        description = match[5]

        doc_blk_src = build_doc_block(description, since, linkRefDict, data_type)

        output_def_re = r'(output "' + re.escape(output_name) + r'"[\s\S]*?description = )("[^\n]*")'
        output_file_split = re.search(output_def_re, output_file, re.MULTILINE)

        if output_file_split is None:
          output_def_re_no_desc = r'(output "' + re.escape(output_name) + r'"\s*\{)'
          output_file_split_no_desc = re.search(output_def_re_no_desc, output_file, re.MULTILINE)

          if output_file_split_no_desc is not None:
            desc_replacement = f"""
  description = {render_doc_block(doc_blk_src)}
""".rstrip()
            output_file = f'{output_file[:output_file_split_no_desc.end()]}{desc_replacement}{output_file[output_file_split_no_desc.end():]}'
          else:
            print(f'Output definition not found for: {output_name}')
            continue
        else:
          desc_replacement = render_doc_block(doc_blk_src)
          output_file = f'{output_file[0:output_file_split.end(1)]}{desc_replacement}{output_file[output_file_split.end(2):]}'

      with open(f'{folder}/outputs.tf', 'w') as f:
        f.write(output_file)

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
        's3',
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
