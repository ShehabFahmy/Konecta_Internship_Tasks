# DevOps Intern Project – AutoGCP: Simple GCP Project Creation via YAML

Hi team,

This is your mini project for the week. The idea is to help us simplify how we create GCP projects. Right now, setting up a new project means writing and editing Terraform code manually—which isn’t very efficient. By the end of this project, we want to be able to define a new GCP project in a simple YAML file, run a script, and let Terraform do the rest.

---

## Project Goal

Your goal is to build a small working setup that can:

1. Take a YAML config file with project details.
2. Use that to generate a new GCP project automatically.
3. Be easy enough for anyone to reuse without writing Terraform every time.

Here’s what you’ll work on:

- A reusable Terraform module.
- A sample YAML input file.
- A small Python script that reads the YAML and runs Terraform.

---

## Tools You’ll Use

We’ll be working with:

- **Terraform** – to provision GCP resources
- **GCP** – where we’ll create the projects
- **Python** – for scripting
- **YAML** – to keep project configs clean and readable
- **Git** – to version your work

---

## Project Folder Structure

Here’s how the project should be organized:

```
gcp-autoproject/
├── main.tf
├── variables.tf
├── modules/
│   └── project/
│       ├── main.tf
│       └── variables.tf
├── configs/
│   └── example-project.yaml
├── scripts/
│   └── deploy.py
└── README.md
```

---

## What To Do – Step by Step

### 1. Create the Terraform Module (`modules/project/`)

This module should handle:

- Creating a GCP project
- Linking it to a billing account
- Adding labels
- Enabling essential APIs (like Compute and IAM)

Use inputs like `project_id`, `organization_id`, and `billing_account`.

### 2. Write the Root Config (`main.tf`)

This is where you use the module and feed it the variables.

### 3. Create a Sample YAML Config (`configs/example-project.yaml`)

Here’s an example of what the input file should look like:

```yaml
project_id: "dev-intern-poc"
organization_id: "YOUR_ORG_ID"
billing_account: "XXXXXX-XXXXXX-XXXXXX"
labels:
  owner: intern
  environment: test
apis:
  - compute.googleapis.com
  - iam.googleapis.com
```

### 4. Write a Python Script (`scripts/deploy.py`)

This script should:

- Read the YAML file
- Convert it into a `.tfvars` file
- Run `terraform init` and `terraform apply` automatically

### 5. Run and Test

Try it out with the example YAML:

```bash
cd scripts
python deploy.py ../configs/example-project.yaml
```

If it runs smoothly, you’ll have a GCP project created with minimal effort. That’s the goal.

---

## What You Should Submit

By the end of the week, please share:

- Your full code and folder structure
- At least one working YAML config
- A `README.md` explaining how it works and how to use it

---

## Extra Credit (Optional)

If you finish early and want to go further:

- Add a `destroy.py` script to delete the project
- Set up a GitHub Actions workflow to run the script when a new YAML file is added
- Add Slack/email notifications on successful provisioning

---

## What You'll Learn

This project will give you experience with:

- Writing and structuring Terraform modules
- Managing cloud infrastructure on GCP
- YAML-to-code automation pipelines
- Python scripting
- Real-world DevOps workflows

---

Feel free to ask questions at any point. It’s okay to get stuck or break things—this is how you learn. Just focus on building something that works, and keep it as clean and understandable as possible.

Let’s make something useful together.
