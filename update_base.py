import os

lib_dir = 'lib'
old_url = 'https://api.human.go.digitable.io/human/v2/api'
import_stmt = "import 'package:cn_pocket_hr/config.dart';\n"
new_call = "AppConfig.baseUrl"

for root, _, files in os.walk(lib_dir):
    for fn in files:
        if fn.endswith('.dart') and fn not in ['config.dart', 'api_config.dart']:
            fp = os.path.join(root, fn)
            with open(fp, 'r') as f:
                content = f.read()
            
            if old_url in content:
                print(f'Updating {fp}')
                if import_stmt not in content:
                    content = import_stmt + content
                
                content = content.replace(f"'{old_url}/", f"'${{{new_call}}}/")
                content = content.replace(f'"{old_url}/', f'"${{{new_call}}}/')
                content = content.replace(f"'{old_url}'", new_call)
                content = content.replace(f'"{old_url}"', new_call)
                content = content.replace(f"{old_url}", f"${{{new_call}}}")
                
                with open(fp, 'w') as f:
                    f.write(content)
