# GMU Honeypot Deployment Instructions

## Step 1: Create Key Pair
1. Go to **EC2** → **Key Pairs** → **Create key pair**
2. Name: `gmu-honeypot-key`
3. Download the `.pem` file

## Step 2: Deploy CloudFormation Stack
1. Go to **CloudFormation** → **Create stack**
2. Upload `gmu-honeypot-stack.yaml`
3. Stack name: `GMU-Honeypot-Stack`
4. Parameters:
   - KeyPairName: `gmu-honeypot-key`
   - TeamIPRange: Your team's IP range (or 0.0.0.0/0 for testing)
5. Click **Create stack**

## Step 3: Get Connection Info
After deployment completes:
1. Go to **Outputs** tab
2. Note the **HoneypotPublicIP**
3. Use the provided SSH commands

## Step 4: Test Honeypot
```bash
# Connect to honeypot (this gets logged)
ssh -p 2222 root@HONEYPOT_IP

# View logs (management access)
ssh -i gmu-honeypot-key.pem ubuntu@HONEYPOT_IP
sudo tail -f /opt/cowrie/var/log/cowrie/cowrie.log
```

## Team Access
Share with teammates:
- Honeypot IP address
- SSH command: `ssh -p 2222 root@IP`
- Log viewing instructions

## Budget Alert
Set up billing alert for $50/month in AWS Billing console.