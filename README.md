This README provides a comprehensive guide to deploying and verifying the **Sudo Privilege Escalation CTF Environment**. This project automates the creation of a vulnerable cloud laboratory using Terraform, Jenkins, and CTFd.

---

# 🚩 CTF Infrastructure: Sudo `find` PrivEsc

## 🏗️ Architectural Decisions

To ensure a robust, scalable, and reproducible environment, the following design choices were made:

1. **Immutable Infrastructure (AMI Baking):** Instead of relying solely on `user_data` (which can be slow or fail silently), we use a "Gold Image" strategy. A base instance is configured, and an **AMI is created** from it. The final CTF target is launched from this AMI, ensuring every instance is identical and ready instantly.
2. **Modular Terraform:** Networking (VPC/Subnets) is separated from Compute logic. This allows for independent scaling and reuse of the networking layer for other CTF challenges.
3. **Loose Coupling (JSON Handoff):** The Jenkins pipeline exports Terraform outputs to a JSON file. The CTFd plugin consumes this file. This decouples the infrastructure layer from the application layer—if the IP changes, the plugin updates automatically without hardcoding.
4. **Admin-Only Validation:** The connectivity plugin is restricted to CTFd admins to prevent players from probing internal infrastructure details.

---

## 🚀 Setup Instructions

### 1. Prerequisites

* **AWS Account:** With programmatic access (Access Key / Secret Key).
* **Jenkins Server:** (See installation steps below).
* **Tools installed on Jenkins:** `terraform`, `docker`, `docker-compose`.

### 2. Jenkins Installation & Service Setup

* Setup Jenkins using the installation script `Jenkins/install.sh` on a Linux machine (Can use EC2).  
This script install Jenkins , runs it as a service , and configure to automatically start on boot.  
The script also install terraform , docker and docker-compose.  


### 3. Deployment Flow

1. **Configure AWS Credentials:** Add your AWS keys to Jenkins (Manage Jenkins > Credentials).
2. **Create Pipeline:** Point a new Jenkins Pipeline job to your repository containing the `Jenkinsfile`.
3. **Build with Parameters:** * Ensure `DESTROY_INFRA` is **unchecked** for first-time deployment.
* The pipeline will provision the VPC, bake the AMI, launch the target, and start CTFd.



---

## 🔍 Verification Flow

### 1. Vulnerability Verification (Manual)

Once the instance is live, you can verify the misconfiguration.

* **SSH into the target:** `ssh -i your-key.pem ctf@<Target_IP>`
* **Check Sudo Permissions:** Run `sudo -l`. You should see:
> `(root) NOPASSWD: /usr/bin/find`


* **Exploit:** Execute a root shell using the `find` escape:
```bash
sudo find . -exec /bin/sh \; -quit

```


* **Verify Root:** Run `whoami`. It should return `root`.

### 2. Plugin Behavior (CTFd UI)

The "Reachability" plugin ensures the lab is ready for students.

1. Log in to **CTFd Admin** (`http://<Jenkins_IP>:8000/admin`).
2. Navigate to the **Reachability** tab (defined in the plugin blueprint).
3. Click **"Run Validation"**.
4. **Success:** The plugin pings the IP stored in `tf_output.json` and returns a green "Online" status.
5. **Failure:** If the instance is down or the Security Group blocks ICMP, a red "Offline" status appears.