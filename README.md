This README provides a comprehensive guide to deploying and verifying the **Sudo Privilege Escalation CTF Environment**. This project automates the creation of a vulnerable cloud laboratory using Terraform, Jenkins, and CTFd.

---

# 🚩 CTF Infrastructure: Sudo `find` PrivEsc

## 🏗️ Architectural Decisions

To ensure a robust, scalable, and reproducible environment, the following design choices were made:

1. **Immutable Infrastructure (AMI Baking):** Instead of relying solely on `user_data` (which can be slow or fail silently), we use a "Gold Image" strategy. A base instance is configured, and an **AMI is created** from it. The final CTF target is launched from this AMI, ensuring every instance is identical and ready instantly.
2. **Modular Terraform:** Networking (VPC/Subnets) is separated from Compute logic. This allows for independent scaling and reuse of the networking layer for other CTF challenges.
3. **Loose Coupling (JSON Handoff):** The Jenkins pipeline exports Terraform outputs to a JSON file. The CTFd plugin consumes this file. The terraform passes the output file to CTFd Plugin's API. This decouples the infrastructure layer from the application layer—if the IP changes, the plugin updates from the pipeline using the API.
4. **Admin-Only Validation:** The connectivity plugin is restricted to CTFd admins to prevent players from probing internal infrastructure details.

---

## 🚀 Setup Instructions

### 1. Prerequisites

* **AWS Account:** For Jenkins with programmatic access (Access Key / Secret Key).
* **S3 Bucket**: Create S3 bucket called `terraform-state-bucket` to save the terraform state file.
* **Jenkins Server:** (See installation steps below).
* **CTFd:** (See installation steps below).

### 2. Jenkins Installation & Service Setup

* Create User for Jenkins in AWS console and create "Access Keys" and save the keys, you need to provide those keys during Jenkins installation script to configure aws cli.
* Setup Jenkins using the installation script `Jenkins/install.sh` on a Linux machine (Can use EC2).  
This script install Jenkins , runs it as a service , and configure to automatically start on boot.  
The script also install terraform , docker and docker-compose, awscli.
* SSH into the jenkins and get the initial admin password from `/var/lib/jenkins/secrets/initialAdminPassword`  
* Log into jenkins web using the password retrieved and go throught the setup.
* Create a new "Item" and choose "Pipeline"
* Under "Pipeline" Header select `Pipeline script from SCM`:
** SCM: Choose git
** Paste the repository URL , if private repo setup credentials for accessing the repo.
** Change branch to main
** Set the Pipeline file to `Jenkins/Jenkinsfile`

### 3. CTFd installation

* Run setup.sh script from from the repo in `CTFd/setup.sh` folder - to run the container with the plugin folder mounted, The script also installs neccessary `ping` command.
* Log in to **CTFd** (`http://<CTFd_machine>:8000`).
* Go through the setup , create user and password.
* Create API key from the settings (`http://<CTFd_machine>:8000/settings`).
* Save the API key as Credentials of type "Secret Text" in Jenkins with the ID (name) `CTFD_ADMIN_TOKEN`.
* Paste the URL of the CTFd machine when running the Jenkins Pipeline.

### 4. Deployment Flow

1. **Verify Jenkins is installed:** Verify Jenkins is installed and aws configured.
2. **Verify CTFd:** Verify all the steps from step 3 are configured and the server have network access.
3. **Verify S3 Bucket:** Verify you created the bucket `terraform-state-bucket` for terraform to keep the state file.
3. **Build with Parameters:** * Ensure `DESTROY_INFRA` is **unchecked** for first-time deployment.
** Paste the URL of the CTFd machine when running the Jenkins Pipeline.
** Verify the API key for CTFd is configured as Credentials in Jenkins.
** The pipeline will provision the VPC, bake the AMI, launch the target, and pass the output to CTFd API.
4. **CTFd installation:** The pipeline will push the terraform output to the CTFd plugin.
5. **Verify:** Continue to Verification Flow to check the CTFd plugin.
---
## 🔍 Verification Flow

### 1. Plugin Behavior (CTFd UI)

The "Reachability" plugin ensures the lab is ready for students.

1. Log in to **CTFd** (`http://<CTFd_machine>:8000`).
2. Navigate to the ***Plugin Page*** in `http://<CTFd_machine>:8000/admin/tf-validate`.
3. Click **"Run Validation"**.
4. **Success:** The plugin pings the IP stored in `tf_output.json` and returns a green "Online" status.
5. **Failure:** If the instance is down or the Security Group blocks ICMP, a red "Offline" status appears.

### 2. Vulnerability Verification (Manual)

Once the instance is live, you can verify the misconfiguration.

* **SSH into the target:** `ssh -i your-key.pem ctf@<Target_IP>`
* **Check Sudo Permissions:** Run the verification step :
```
# Verification Step
echo "--- Verification ---"
sudo -U "$USER_NAME" -l | grep '/usr/bin/find' && echo "Sudo rule verified."

# Test execution (non-destructive)
sudo -u "$USER_NAME" sudo /usr/bin/find . -maxdepth 0 -exec whoami \; | grep 'root' && \
    echo "Privilege escalation capability confirmed: 'find' can execute as root."
``` 
