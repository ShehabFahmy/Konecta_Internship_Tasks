from helper_functions import *
import os
import re

def WriteTfvars(data, tfvars_path):
    """
    Remove a project block from terraform.tfvars if project_id exists in it.
    """
    project_id = data.get("project_id")
    if not project_id:
        print("[!] No 'project_id' found in YAML data.")
        return

    if not os.path.exists(tfvars_path):
        print(f"[!] File '{tfvars_path}' does not exist.")
        return

    with open(tfvars_path, "r") as f:
        content = f.read()

    # Find all project blocks (project_id = { ... })
    pattern = r"(  [a-zA-Z0-9\-_]+\s*=\s*\{.*?\n  \})"
    blocks = re.findall(pattern, content, flags=re.DOTALL)

    # Search for block containing the project_id
    block_to_remove = None
    for block in blocks:
        if project_id in block:
            block_to_remove = block
            break

    if not block_to_remove:
        print(f"[!] No project found with project_id '{project_id}'.")
        return

    # Remove block
    new_content = content.replace(block_to_remove, "").rstrip()

    # Ensure closing brace remains
    if not new_content.endswith("}"):
        new_content += "\n}"
    
    # Remove empty lines
    new_content = re.sub(r'\n\s*\n+', '\n', new_content)
    
    with open(tfvars_path, "w") as f:
        f.write(new_content)

if __name__ == "__main__":
    data = ReadYaml(sys.argv, Path(__file__).resolve().name)
    # Get parent directory of this script
    parent_dir = Path(__file__).resolve().parent.parent
    tfvars_path = parent_dir / "terraform.tfvars"
    WriteTfvars(data, tfvars_path)
    RunTerraform(parent_dir)
