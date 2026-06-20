import os
import re

def fix_const_in_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    # Remove `const ` before widgets/classes that use ResponsiveHelper
    patterns_to_remove_const = [
        r'const\s+(SizedBox\()',
        r'const\s+(EdgeInsets\.)',
        r'const\s+(BorderRadius\.)',
        r'const\s+(Icon\()',
        r'const\s+(TextStyle\()',
        r'const\s+(Padding\()',
        r'const\s+(Container\()',
        r'const\s+(Row\()',
        r'const\s+(Column\()',
        r'const\s+(BoxDecoration\()',
        r'const\s+(Align\()',
        r'const\s+(Center\()',
        r'const\s+(Expanded\()',
        r'const\s+(Flexible\()',
        r'const\s+(Text\()',
    ]

    for pattern in patterns_to_remove_const:
        content = re.sub(pattern, r'\1', content)

    # We might have cases like `const [ ... SizedBox(...) ... ]` which is harder to catch.
    # We will remove `const ` before `[` if the array contains ResponsiveHelper
    # A simple hack is to just replace `const [` with `[` and `const <Widget>[` with `<Widget>[`
    # if ResponsiveHelper is in the file.
    if 'ResponsiveHelper' in content:
        content = re.sub(r'const\s+\[', r'[', content)
        content = re.sub(r'const\s+<Widget>\[', r'<Widget>[', content)
        content = re.sub(r'const\s+<String>\[', r'<String>[', content)
        content = re.sub(r'const\s+BoxConstraints\(', r'BoxConstraints(', content)
        content = re.sub(r'const\s+BorderSide\(', r'BorderSide(', content)
        content = re.sub(r'const\s+RoundedRectangleBorder\(', r'RoundedRectangleBorder(', content)
        content = re.sub(r'const\s+CircleBorder\(', r'CircleBorder(', content)
        content = re.sub(r'const\s+Offset\(', r'Offset(', content)
        content = re.sub(r'const\s+Spacer\(', r'Spacer(', content)
        content = re.sub(r'const\s+Divider\(', r'Divider(', content)
        
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def main():
    directories = ['lib/widgets', 'lib/screens', 'lib']
    modified_files = 0
    for directory in directories:
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith('.dart'):
                    filepath = os.path.join(root, file)
                    if fix_const_in_file(filepath):
                        print(f"Fixed const in: {filepath}")
                        modified_files += 1
    print(f"Total files modified for const: {modified_files}")

if __name__ == '__main__':
    main()
