import subprocess
import os
import pandas as pd
import time
from concurrent.futures import wait, FIRST_COMPLETED
from pebble import ProcessPool

#TODO: set up a parrallel process to run the vastai command and check questions.csv to see if the question has been answered already

def run_remote_command(query, new_contract=os.environ.get('CONTRACT_NUMBER')):
    
    with ProcessPool(max_workers=2) as pool:
        # Check if the question was already answered in the questions.csv file using pandas
        f1 = pool.schedule(find_in_csv,[query]) #find_in_csv(query)
        # Get the SSH URL from the vastai command
        f2 = pool.schedule(vastSSH,[query,new_contract]) #vastSSH(query, new_contract)
        
        done, not_done = wait([f1, f2], return_when=FIRST_COMPLETED)
        for f in not_done:
            f.cancel()
        # TODO: Fix what is returned from the functions
        for f in done:
            return f.result()
    
    
def vastSSH(query, new_contract):
    try:
        vastai_command = ["vastai", "ssh-url", str(new_contract)]
        vastai_process = subprocess.run(vastai_command, text=True, capture_output=True, check=True)
        ssh_url = vastai_process.stdout.strip()  # Remove any extra whitespace
    except subprocess.CalledProcessError as e:
        return '',f"Error obtaining SSH URL: {e.stderr}",e.returncode, False
    
    # Command to run on the remote server
    remote_command = f"/usr/bin/python3 /root/sqlcoder/sqlcoder/inference.py -q '{query}'"

    # Build the full SSH command to run the main command
    ssh_command = [
        "ssh",
        "-o",
        "StrictHostKeychecking=no",
        ssh_url,
        remote_command
    ]

    # Execute the main command on the remote server
    try:
        result = subprocess.run(ssh_command, text=True, capture_output=True, check=True)
        return result.stdout, result.stderr, result.returncode, False
    except subprocess.CalledProcessError as e:
        return e.stdout, e.stderr, e.returncode, False


def find_in_csv(query):
    if os.path.exists('questions.csv'):
        questions_df = pd.read_csv('questions.csv')
        if query in questions_df['Question'].values:
            for i in range(len(questions_df[questions_df['Question'] == query]['Rating'].values)):
                if questions_df[questions_df['Question'] == query]['Rating'].values[i] == 5:
                    return questions_df[questions_df['Question'] == query]['SQL'].values[i], '', 0, True
    time.sleep(100000)
    return '', '', 0, False
    
def sshConfirm(new_contract=os.environ.get('CONTRACT_NUMBER')):
    try:
        vastai_command = ["vastai", "ssh-url", str(new_contract)]
        vastai_process = subprocess.run(vastai_command, text=True, capture_output=True, check=True)
        print(f"stdout : {vastai_process.stdout}")
        print(f"stderr : {vastai_process.stderr}")
        print(f"returncode : {vastai_process.returncode}")
        ssh_url = vastai_process.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error obtaining SSH URL: {e.stderr}")
        return
    
    remote_command = f"/usr/bin/python3 /root/sqlcoder/sqlcoder/inference.py -q 'How many patients are there?'"

    # Build the full SSH command to run the main command
    ssh_command = [
        "ssh",
        "-o",
        "StrictHostKeychecking=no",
        ssh_url,
        remote_command
    ]
    try:
        result = subprocess.run(ssh_command, text=True, capture_output=True, check=True)
        print(f"stdout : {result.stdout}")
        print(f"stderr : {result.stderr}")
        print(f"returncode : {result.returncode}")
    except subprocess.CalledProcessError as e:
        print(f"stdout : {e.stdout}")
        print(f"stderr : {e.stderr}")
        print(f"returncode : {e.returncode}")
        return e.stdout, e.stderr, e.returncode
    


def installPackages(new_contract=os.environ.get('CONTRACT_NUMBER') ):
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
            "ssh",
            "-o",
            "StrictHostKeychecking=no", ssh_url,
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


# This will run if the script is run directly
if __name__ == "__main__":
    try:
        sOut, sErr, sReturn = sshConfirm()
    except Exception as e:
        print("Error: ", e)
        sReturn = 0
    if sReturn == 0:
        print("SSH connection successful")
    else:
        print("SSH connection failed")
        print("Installing required packages...")
        installPackages()
        print("Packages installed")
        print("Confirming SSH connection...")
        sshConfirm()

    
    
