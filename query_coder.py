import subprocess
import argparse

def run_remote_command(new_contract, query):
    # Get the SSH URL from the vastai command
    try:
        vastai_command = ["vastai", "ssh-url", str(new_contract)]
        vastai_process = subprocess.run(vastai_command, text=True, capture_output=True, check=True)
        ssh_url = vastai_process.stdout.strip()  # Remove any extra whitespace
    except subprocess.CalledProcessError as e:
        return '',f"Error obtaining SSH URL: {e.stderr}",e.returncode
    
    # Command to run on the remote server
    remote_command = f"/usr/bin/python3 /root/sqlcoder/inference.py -q '{query}'"

    # Build the full SSH command to run the main command
    ssh_command = [
        "ssh",
        ssh_url,
        remote_command
    ]

    # Execute the main command on the remote server
    try:
        result = subprocess.run(ssh_command, text=True, capture_output=True, check=True)
        return result.stdout, result.stderr, result.returncode
    except subprocess.CalledProcessError as e:
        return e.stdout, e.stderr, e.returncode
    


def installPackages(new_contract):
    print("Installing required packages...")

    try:
        vastai_command = ["vastai", "ssh-url", str(new_contract)]
        vastai_process = subprocess.run(vastai_command, text=True, capture_output=True, check=True)
        ssh_url = vastai_process.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error obtaining SSH URL: {e.stderr}")
        return

    for package in ["torch", "transformers", "sqlparse", "sqlcoder[transformers]", "sqlcoder[llama-cpp]", "argparse", "bitsandbytes", "accelerate", "backoff"]:
        install_command = [
            "ssh", ssh_url,
            "/usr/bin/python3", "-m", "pip", "install", package
        ]
        try:
            print(f"Running command: {' '.join(install_command)}")
            install_result = subprocess.run(install_command, text=True, capture_output=True)
            if install_result.stderr:
                print(f"Error installing {package}: {install_result.stderr}")
            if install_result.stdout:
                print(install_result.stdout)
            if install_result.returncode != 0:
                print(f"Failed to install {package} with exit status: {install_result.returncode}")
        except subprocess.CalledProcessError as e:
            print(f"Exception while trying to install {package}: {e.stderr}")


def uninstall_all_packages(new_contract):
    print("Uninstalling all packages...")
    try:
        vastai_command = ["vastai", "ssh-url", str(new_contract)]
        vastai_process = subprocess.run(vastai_command, text=True, capture_output=True, check=True)
        ssh_url = vastai_process.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error obtaining SSH URL: {e.stderr}")
        return
    
    uninstall_command = f"ssh {ssh_url} \"/usr/bin/python3 -m pip freeze | xargs /usr/bin/python3 -m pip uninstall -y\""
    print(f"Running command: {uninstall_command}")
    try:
        uninstall_result = subprocess.run(uninstall_command, text=True, capture_output=True, shell=True)
        if uninstall_result.stderr:
            print(f"Error uninstalling packages: {uninstall_result.stderr}")
        if uninstall_result.stdout:
            print(uninstall_result.stdout)
        if uninstall_result.returncode != 0:
            print(f"Failed to uninstall packages with exit status: {uninstall_result.returncode}")
    except subprocess.CalledProcessError as e:
        print(f"Exception while trying to uninstall packages: {e.stderr}")





    
    
parser = argparse.ArgumentParser(description='Use remote server to translate into SQL query')
parser.add_argument('-c', type=int, help='Contract number')
parser.add_argument('-q', type=str, help='Query to run')
args = parser.parse_args()

contract_number = 10595496  # Replace if contract number changes
query = "How many patients are there with more that 1 chronic condition?"

if args.c:
    contract_number = args.c
if args.q:
    query = args.q

noSql = True

while noSql:
    stdout, stderr, returncode = run_remote_command(contract_number, query)
    if returncode == 0:
        print(stdout)
        noSql = False
    else:
        print(stderr)
        print("Return Code:", returncode)
        if "ModuleNotFoundError" in stderr:
            # uninstall_all_packages(contract_number)
            installPackages(contract_number)
            noSql = True
