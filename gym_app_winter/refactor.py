import os
import re
import glob

def refactor_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    # Regex patterns
    # SizedBox(height: X) -> SizedBox(height: ResponsiveHelper.h(X))
    content = re.sub(r'SizedBox\(\s*height:\s*(\d+(?:\.\d+)?)\s*\)', r'SizedBox(height: ResponsiveHelper.h(\1))', content)
    # SizedBox(width: X) -> SizedBox(width: ResponsiveHelper.w(X))
    content = re.sub(r'SizedBox\(\s*width:\s*(\d+(?:\.\d+)?)\s*\)', r'SizedBox(width: ResponsiveHelper.w(\1))', content)
    # EdgeInsets.all(X) -> EdgeInsets.all(ResponsiveHelper.w(X))
    content = re.sub(r'EdgeInsets\.all\(\s*(\d+(?:\.\d+)?)\s*\)', r'EdgeInsets.all(ResponsiveHelper.w(\1))', content)
    # EdgeInsets.symmetric(horizontal: X)
    content = re.sub(r'EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*\)', r'EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(\1))', content)
    # EdgeInsets.symmetric(vertical: X)
    content = re.sub(r'EdgeInsets\.symmetric\(\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)', r'EdgeInsets.symmetric(vertical: ResponsiveHelper.h(\1))', content)
    # EdgeInsets.symmetric(horizontal: X, vertical: Y)
    content = re.sub(r'EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*,\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)', r'EdgeInsets.symmetric(horizontal: ResponsiveHelper.w(\1), vertical: ResponsiveHelper.h(\2))', content)
    # EdgeInsets.symmetric(vertical: Y, horizontal: X)
    content = re.sub(r'EdgeInsets\.symmetric\(\s*vertical:\s*(\d+(?:\.\d+)?)\s*,\s*horizontal:\s*(\d+(?:\.\d+)?)\s*\)', r'EdgeInsets.symmetric(vertical: ResponsiveHelper.h(\1), horizontal: ResponsiveHelper.w(\2))', content)
    # BorderRadius.circular(X)
    content = re.sub(r'BorderRadius\.circular\(\s*(\d+(?:\.\d+)?)\s*\)', r'BorderRadius.circular(ResponsiveHelper.w(\1))', content)
    
    # Icon sizes
    # Icon(Icons.foo, size: X) -> Icon(Icons.foo, size: ResponsiveHelper.w(X))
    content = re.sub(r'(Icon\([^)]*size:\s*)(\d+(?:\.\d+)?)', r'\1ResponsiveHelper.w(\2)', content)

    # fontSize in TextStyle
    # TextStyle(fontSize: X) -> TextStyle(fontSize: ResponsiveHelper.sp(X))
    content = re.sub(r'(TextStyle\([^)]*fontSize:\s*)(\d+(?:\.\d+)?)', r'\1ResponsiveHelper.sp(\2)', content)

    # TextTheme replacements where simple
    # It might be risky to auto-replace TextStyle with Theme.of(context).textTheme without Context.
    # We will just scale the fonts using ResponsiveHelper.sp() for now to make them adaptive.

    if content != original_content:
        # Check if import exists
        if 'package:gym_app_winter/utils/responsive_helper.dart' not in content and "'../utils/responsive_helper.dart'" not in content:
            # Add import after first flutter/material.dart or other imports
            import_statement = "import 'package:gym_app_winter/utils/responsive_helper.dart';\n"
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if line.startswith('import '):
                    lines.insert(i + 1, import_statement)
                    break
            content = '\n'.join(lines)

        with open(filepath, 'w') as f:
            f.write(content)
        return True
    return False

def main():
    directories = ['lib/widgets', 'lib/screens']
    modified_files = 0
    for directory in directories:
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith('.dart'):
                    filepath = os.path.join(root, file)
                    if refactor_file(filepath):
                        print(f"Refactored: {filepath}")
                        modified_files += 1
    print(f"Total files modified: {modified_files}")

if __name__ == '__main__':
    main()
