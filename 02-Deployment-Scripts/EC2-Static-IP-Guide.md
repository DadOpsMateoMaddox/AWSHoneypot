# 🔧 EC2 Static IP Issue — What Happened & How We Fixed It

## What Happened
Our honeypot EC2 instance public IP changed from **44.222.200.1** to **18.223.22.36**, which broke everyone's SSH connections and bookmarks.

---

## Why This Happened
EC2 instances get **dynamic public IPs** by default. AWS will assign a new public IP when any of these occur:

- You stop and start the instance (not just reboot).  
- The instance crashes and AWS restarts it.  
- AWS performs certain maintenance events.

In these cases AWS assigns a NEW random public IP from their pool.

---

## Why My Previous "Static IP" Fix Failed
A few likely causes for thinking it was static when it wasn't:

- I may have just noted the current public IP and assumed it was permanent.  
- I allocated an Elastic IP but never **associated** it with the instance.  
- I associated it temporarily but it got disconnected during a stop/start.  
- I mixed up dynamic vs static IP concepts.

Key lesson: just because an IP doesn't change for a while doesn't mean it's static.

---

## ✅ What We Did Differently This Time

### Step 1 — Allocated a TRUE Elastic IP  
Allocated: **3.140.96.146** (this is now ours permanently while attached)

### Step 2 — Properly Associated It
Used:
```bash
aws ec2 associate-address --instance-id i-097cb628946b07879 --public-ip 3.140.96.146
```
(You can also associate by `--allocation-id` if you used `allocate-address --domain vpc`.)

> Run in CloudShell

### Step 3 — Verified the Association
- Confirmed EC2 console shows Elastic IP attached to `i-097cb628946b07879`.  
- Confirmed SSH works at `3.140.96.146`.  
- Verified the IP survives stop/start cycles.

---

## 📚 Educational Walkthrough — Follow Along

### Understanding AWS IP Types

**Dynamic Public IP (Default):**
- ❌ Changes when instance stops/starts  
- ❌ Free but unreliable for persistent services  
- ❌ Can't be moved between instances

**Elastic IP (Static):**
- ✅ Stays the same until you release it  
- ✅ Can be moved between instances  
- ✅ Free while attached to a running instance  
- ⚠️ Costs apply (~$3.65/month) if allocated but **not attached**

---

## How to Check Your Current Setup

### Method 1 — AWS Console
EC2 Dashboard → Instances → Select your instance → Look at **Public IPv4 address**

### Method 2 — CloudShell / CLI
Get current public IP:
```bash
aws ec2 describe-instances --instance-ids YOUR_INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
```

Check whether an IP is an Elastic IP:
```bash
aws ec2 describe-addresses --public-ips YOUR_PUBLIC_IP
```
> Run in CloudShell

### Method 3 — From Inside the Instance
```bash
curl http://checkip.amazonaws.com/
```
> Run in CloudShell

---

## How to Assign a Static IP (Elastic IP) — Step by Step

### Option A — AWS Console (GUI)
1. EC2 Console → **Elastic IPs** → Allocate Elastic IP address  
2. Keep defaults → Allocate  
3. Select new IP → Actions → **Associate Elastic IP address**  
4. Choose your instance → Associate

### Option B — CloudShell / CLI (recommended)
1. Allocate a new Elastic IP (VPC):
```bash
aws ec2 allocate-address --domain vpc
```
Note the returned `AllocationId` (example: `eipalloc-xxxxxx`).

2. Associate it with your instance:
```bash
aws ec2 associate-address --instance-id YOUR_INSTANCE_ID --allocation-id eipalloc-xxxxx
```
> Run in CloudShell

### Option C — One-liner (if you already have the Elastic IP)
```bash
aws ec2 associate-address --instance-id YOUR_INSTANCE_ID --public-ip YOUR_ELASTIC_IP
```
> Run in CloudShell

---

## How to Verify It Worked
Check association:
```bash
aws ec2 describe-addresses --public-ips YOUR_ELASTIC_IP
```
The output should show an `AssociationId` and your `InstanceId`.

---

## Testing Static IP Persistence (Recommended)
1. Note current IP.
2. Stop the instance:
```bash
aws ec2 stop-instances --instance-ids YOUR_INSTANCE_ID
```
3. Wait for stopped state.
4. Start the instance:
```bash
aws ec2 start-instances --instance-ids YOUR_INSTANCE_ID
```
5. Check IP again — it should be the same.

> Run in CloudShell

---

## 🔄 Updated Connection Info

**New Static IP:** `3.140.96.146`

**SSH Command:**
```bash
ssh -i gmu-honeypot-key.pem ubuntu@3.140.96.146
```
Note: username is **ubuntu** for Ubuntu Jammy AMI.

**Web Access:**
```
http://3.140.96.146
```

**Termius Settings:**
- Host: `3.140.96.146`  
- User: `ubuntu`  
- Port: `22`  
- Key: `gmu-honeypot-key.pem`

---

## 💡 Key Takeaways
- Always use an Elastic IP for production services that need a stable public address.  
- "Allocate" ≠ "Associate" — both steps are required.  
- Verify your Elastic IP by performing a stop/start cycle.  
- CloudShell / CLI is faster and scriptable for repetitive ops; GUI is fine for one-offs.  
- Dynamic IPs are fine for temporary/dev usage — not for long lived services.

---

This IP will now remain **3.140.96.146** until we release the Elastic IP — so bookmarks and scripts will be stable. 🎯

---

## 🔍 Current Instance Details

- **Instance ID**: i-097cb628946b07879
- **Name**: GMU-Honeypot-Cowrie
- **Public IP**: **3.140.96.146** (Elastic IP)
- **Private IP**: 172.31.39.74
- **Region**: us-east-2c
- **Instance Type**: t3.micro
- **AMI**: Ubuntu Jammy 22.04
- **Username**: ubuntu
- **Key**: gmu-honeypot-key.pem
- **Security Group**: gmu-honeypot-sg

---

**Questions?** This is great learning material for AWS networking concepts! 🚀
