import os
import re
from helper_functions import *

def WriteTfvars(data, tfvars_path):
    # Ensure the file exists
    if not os.path.exists(tfvars_path):
        with open(tfvars_path, "w") as f:
            f.write("projects = {\n}\n")

    with open(tfvars_path, "r") as f:
        content = f.read()

    # Ensure we have "projects = { ... }"
    if "projects" not in content:
        content = "projects = {\n}\n"

    # Use project_id as the project block name
    project_id = data.get("project_id")
    if not project_id:
        print("[!] No project_id found in YAML data. Skipping.")
        return

    if project_id in content:
        print(f"[!] Project with project_id '{project_id}' already exists. Skipping.")
        return

    # Build the project block
    project_block = f'  {project_id} = {{\n'
    for key, value in data.items():
        if value is None:
            project_block += f'    {key} = null\n'
        elif isinstance(value, str):
            project_block += f'    {key} = "{value}"\n'
        elif isinstance(value, dict):
            project_block += f'    {key} = {{\n'
            for k, v in value.items():
                project_block += f'      "{k}" = "{v}"\n'
            project_block += f'    }}\n'
        elif isinstance(value, list):
            project_block += f'    {key} = [\n'
            for v in value:
                project_block += f'      "{v}",\n'
            project_block += f'    ]\n'
        else:
            project_block += f'    {key} = {value}\n'
    project_block += f'  }}\n'

    # Insert before last closing brace
    new_content = re.sub(r"\}\s*$", project_block + "}\n", content, count=1)

    with open(tfvars_path, "w") as f:
        f.write(new_content)

if __name__ == "__main__":
    data = ReadYaml(sys.argv, Path(__file__).resolve().name)
    # Get parent directory of this script
    parent_dir = Path(__file__).resolve().parent.parent
    tfvars_path = parent_dir / "terraform.tfvars"
    WriteTfvars(data, tfvars_path)
    RunTerraform(parent_dir)
