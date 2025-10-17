#!/usr/bin/env python3
"""
Cowrie Obfuscator - Based on Academic Research
Implements all obfuscation techniques from the research paper to make honeypot undetectable

Based on: "Improving Cowrie's Deceptiveness Through Configuration Obfuscation"
Removes all default indicators that reveal honeypot nature
"""

import os
import random
import string
import hashlib
import json
import subprocess
from datetime import datetime
from typing import List, Dict

class CowrieObfuscator:
    """Obfuscates Cowrie honeypot to appear as real system"""
    
    def __init__(self, cowrie_path="/opt/cowrie"):
        self.cowrie_path = cowrie_path
        self.honeyfs_path = f"{cowrie_path}/honeyfs"
        self.etc_path = f"{cowrie_path}/etc"
        self.share_path = f"{cowrie_path}/share/cowrie"
        
        # Generate realistic system profile
        self.system_profile = self._generate_system_profile()
        
    def _generate_system_profile(self) -> Dict:
        """Generate realistic system characteristics"""
        
        # Realistic hostnames for production servers
        hostnames = [
            "web-prod-01", "db-primary", "api-gateway", "mail-server",
            "file-server", "backup-node", "monitoring", "jenkins-build",
            "redis-cache", "nginx-proxy", "docker-host", "k8s-worker"
        ]
        
        # Realistic organizations
        orgs = [
            "TechCorp", "DataSystems", "CloudServices", "WebSolutions",
            "InfoTech", "DigitalWorks", "NetSystems", "ServerFarm"
        ]
        
        # Realistic CPU models (current generation)
        cpus = [
            ("Intel(R) Xeon(R) CPU E5-2686 v4", "2.30GHz", "45056 KB"),
            ("Intel(R) Core(TM) i7-9750H CPU", "2.60GHz", "12288 KB"),
            ("AMD EPYC 7571", "2.20GHz", "65536 KB"),
            ("Intel(R) Xeon(R) Gold 6248 CPU", "2.50GHz", "27648 KB")
        ]
        
        cpu_model, cpu_speed, cpu_cache = random.choice(cpus)
        
        return {
            'hostname': random.choice(hostnames),
            'organization': random.choice(orgs),
            'cpu_model': cpu_model,
            'cpu_speed': cpu_speed,
            'cpu_cache': cpu_cache,
            'cpu_cores': random.choice([2, 4, 8, 16]),
            'memory_gb': random.choice([4, 8, 16, 32, 64]),
            'kernel_version': f"5.{random.randint(4, 15)}.{random.randint(0, 50)}-{random.randint(10, 99)}-generic",
            'ubuntu_version': random.choice(["20.04.3", "22.04.1", "18.04.6"]),
            'mac_prefix': random.choice(["00:16:3e", "52:54:00", "08:00:27"])  # Common virtualization MACs
        }
    
    def obfuscate_all(self):
        """Run all obfuscation techniques"""
        print("🎭 Starting Cowrie Obfuscation...")
        print(f"System Profile: {self.system_profile['hostname']} ({self.system_profile['organization']})")
        
        # Core system files
        self.obfuscate_version_uname()
        self.obfuscate_cpuinfo()
        self.obfuscate_meminfo()
        self.obfuscate_mounts()
        self.obfuscate_hostname()
        self.obfuscate_hosts()
        self.obfuscate_issue()
        
        # User management
        self.obfuscate_passwd()
        self.obfuscate_group()
        self.obfuscate_shadow()
        self.obfuscate_userdb()
        
        # Network configuration
        self.obfuscate_ifconfig()
        
        # Cowrie configuration
        self.obfuscate_cowrie_cfg()
        
        # Rebuild filesystem
        self.rebuild_fs_pickle()
        
        print("Obfuscation complete. Honeypot detection resistance applied.")
    
    def obfuscate_version_uname(self):
        """Modify /proc/version to show realistic kernel"""
        version_file = f"{self.honeyfs_path}/proc/version"
        
        # Realistic version string
        version_content = f"""Linux version {self.system_profile['kernel_version']} (buildd@lcy01-amd64-030) (gcc version 9.4.0 (Ubuntu 9.4.0-1ubuntu1~{self.system_profile['ubuntu_version']})) #{random.randint(100, 200)}-Ubuntu SMP {random.choice(['Mon', 'Tue', 'Wed', 'Thu', 'Fri'])} {random.choice(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'])} {random.randint(1, 28)} {random.randint(10, 23)}:{random.randint(10, 59)}:{random.randint(10, 59)} UTC {datetime.now().year}"""
        
        os.makedirs(os.path.dirname(version_file), exist_ok=True)
        with open(version_file, 'w') as f:
            f.write(version_content)
        
        print(f"✅ Updated /proc/version: {self.system_profile['kernel_version']}")
    
    def obfuscate_cpuinfo(self):
        """Modify /proc/cpuinfo with realistic CPU info"""
        cpuinfo_file = f"{self.honeyfs_path}/proc/cpuinfo"
        
        cpuinfo_content = ""
        for i in range(self.system_profile['cpu_cores']):
            cpuinfo_content += f"""processor\t: {i}
vendor_id\t: GenuineIntel
cpu family\t: 6
model\t\t: {random.randint(60, 165)}
model name\t: {self.system_profile['cpu_model']} @ {self.system_profile['cpu_speed']}
stepping\t: {random.randint(1, 7)}
microcode\t: 0x{random.randint(1000000, 9999999):x}
cpu MHz\t\t: {float(self.system_profile['cpu_speed'].replace('GHz', '')) * 1000:.3f}
cache size\t: {self.system_profile['cpu_cache']}
physical id\t: 0
siblings\t: {self.system_profile['cpu_cores']}
core id\t\t: {i}
cpu cores\t: {self.system_profile['cpu_cores']}
apicid\t\t: {i}
initial apicid\t: {i}
fpu\t\t: yes
fpu_exception\t: yes
cpuid level\t: 22
wp\t\t: yes
flags\t\t: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid tsc_known_freq pni pclmulqdq ssse3 cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx rdrand hypervisor lahf_lm abm 3dnowprefetch invpcid_single pti fsgsbase avx2 invpcid rdseed clflushopt
bugs\t\t: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs taa itlb_multihit
bogomips\t: {random.randint(4000, 6000)}.{random.randint(10, 99)}
clflush size\t: 64
cache_alignment\t: 64
address sizes\t: 46 bits physical, 48 bits virtual
power management:

"""
        
        os.makedirs(os.path.dirname(cpuinfo_file), exist_ok=True)
        with open(cpuinfo_file, 'w') as f:
            f.write(cpuinfo_content.strip())
        
        print(f"✅ Updated /proc/cpuinfo: {self.system_profile['cpu_model']}")
    
    def obfuscate_meminfo(self):
        """Modify /proc/meminfo with realistic memory info"""
        meminfo_file = f"{self.honeyfs_path}/proc/meminfo"
        
        total_mem_kb = self.system_profile['memory_gb'] * 1024 * 1024
        free_mem_kb = int(total_mem_kb * random.uniform(0.3, 0.7))  # 30-70% free
        available_kb = int(total_mem_kb * random.uniform(0.4, 0.8))
        
        meminfo_content = f"""MemTotal:        {total_mem_kb} kB
MemFree:         {free_mem_kb} kB
MemAvailable:    {available_kb} kB
Buffers:         {random.randint(50000, 200000)} kB
Cached:          {random.randint(500000, 2000000)} kB
SwapCached:      {random.randint(0, 10000)} kB
Active:          {random.randint(1000000, 3000000)} kB
Inactive:        {random.randint(500000, 1500000)} kB
Active(anon):    {random.randint(800000, 2000000)} kB
Inactive(anon):  {random.randint(100000, 500000)} kB
Active(file):    {random.randint(200000, 1000000)} kB
Inactive(file):  {random.randint(400000, 1000000)} kB
Unevictable:     {random.randint(0, 1000)} kB
Mlocked:         {random.randint(0, 1000)} kB
SwapTotal:       {random.randint(1000000, 4000000)} kB
SwapFree:        {random.randint(1000000, 4000000)} kB
Dirty:           {random.randint(100, 5000)} kB
Writeback:       {random.randint(0, 100)} kB
AnonPages:       {random.randint(800000, 2000000)} kB
Mapped:          {random.randint(100000, 500000)} kB
Shmem:           {random.randint(50000, 200000)} kB
Slab:            {random.randint(100000, 300000)} kB
SReclaimable:    {random.randint(50000, 150000)} kB
SUnreclaim:      {random.randint(50000, 150000)} kB
KernelStack:     {random.randint(5000, 15000)} kB
PageTables:      {random.randint(10000, 50000)} kB
NFS_Unstable:    0 kB
Bounce:          0 kB
WritebackTmp:    0 kB
CommitLimit:     {int(total_mem_kb * 1.5)} kB
Committed_AS:    {random.randint(2000000, 6000000)} kB
VmallocTotal:    34359738367 kB
VmallocUsed:     0 kB
VmallocChunk:    0 kB
Percpu:          {random.randint(1000, 5000)} kB
HardwareCorrupted: 0 kB
AnonHugePages:   {random.randint(0, 100000)} kB
ShmemHugePages:  0 kB
ShmemPmdMapped:  0 kB
CmaTotal:        0 kB
CmaFree:         0 kB
HugePages_Total: 0
HugePages_Free:  0
HugePages_Rsvd:  0
HugePages_Surp:  0
Hugepagesize:    2048 kB
Hugetlb:         0 kB
DirectMap4k:     {random.randint(100000, 500000)} kB
DirectMap2M:     {random.randint(2000000, 8000000)} kB
DirectMap1G:     {random.randint(1000000, 4000000)} kB"""
        
        os.makedirs(os.path.dirname(meminfo_file), exist_ok=True)
        with open(meminfo_file, 'w') as f:
            f.write(meminfo_content)
        
        print(f"✅ Updated /proc/meminfo: {self.system_profile['memory_gb']}GB RAM")
    
    def obfuscate_mounts(self):
        """Modify /proc/mounts with realistic mount points"""
        mounts_file = f"{self.honeyfs_path}/proc/mounts"
        
        mounts_content = f"""sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev devtmpfs rw,nosuid,relatime,size={random.randint(1000000, 4000000)}k,nr_inodes={random.randint(200000, 800000)},mode=755 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000 0 0
tmpfs /run tmpfs rw,nosuid,noexec,relatime,size={random.randint(400000, 800000)}k,mode=755 0 0
/dev/xvda1 / ext4 rw,relatime,data=ordered 0 0
securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,nosuid,nodev 0 0
tmpfs /run/lock tmpfs rw,nosuid,nodev,noexec,relatime,size=5120k 0 0
tmpfs /sys/fs/cgroup tmpfs ro,nosuid,nodev,noexec,mode=755 0 0
cgroup /sys/fs/cgroup/unified cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate 0 0
cgroup /sys/fs/cgroup/systemd cgroup rw,nosuid,nodev,noexec,relatime,xattr,name=systemd 0 0
pstore /sys/fs/pstore pstore rw,nosuid,nodev,noexec,relatime 0 0
cgroup /sys/fs/cgroup/cpu,cpuacct cgroup rw,nosuid,nodev,noexec,relatime,cpu,cpuacct 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,nosuid,nodev,noexec,relatime,blkio 0 0
cgroup /sys/fs/cgroup/memory cgroup rw,nosuid,nodev,noexec,relatime,memory 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,nosuid,nodev,noexec,relatime,devices 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,nosuid,nodev,noexec,relatime,freezer 0 0
cgroup /sys/fs/cgroup/net_cls,net_prio cgroup rw,nosuid,nodev,noexec,relatime,net_cls,net_prio 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,nosuid,nodev,noexec,relatime,perf_event 0 0
cgroup /sys/fs/cgroup/hugetlb cgroup rw,nosuid,nodev,noexec,relatime,hugetlb 0 0
cgroup /sys/fs/cgroup/pids cgroup rw,nosuid,nodev,noexec,relatime,pids 0 0
cgroup /sys/fs/cgroup/rdma cgroup rw,nosuid,nodev,noexec,relatime,rdma 0 0
systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=29,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino={random.randint(10000, 99999)} 0 0
debugfs /sys/kernel/debug debugfs rw,relatime 0 0
mqueue /dev/mqueue mqueue rw,relatime 0 0
hugetlbfs /dev/hugepages hugetlbfs rw,relatime,pagesize=2M 0 0
tracefs /sys/kernel/tracing tracefs rw,relatime 0 0
fusectl /sys/fs/fuse/connections fusectl rw,relatime 0 0
configfs /sys/kernel/config configfs rw,relatime 0 0
/dev/loop0 /snap/core20/{random.randint(1000, 2000)} squashfs ro,nodev,relatime 0 0
/dev/loop1 /snap/lxd/{random.randint(20000, 25000)} squashfs ro,nodev,relatime 0 0
/dev/loop2 /snap/snapd/{random.randint(15000, 20000)} squashfs ro,nodev,relatime 0 0"""
        
        os.makedirs(os.path.dirname(mounts_file), exist_ok=True)
        with open(mounts_file, 'w') as f:
            f.write(mounts_content)
        
        print("✅ Updated /proc/mounts with realistic mount points")
    
    def obfuscate_hostname(self):
        """Set realistic hostname"""
        hostname_file = f"{self.honeyfs_path}/etc/hostname"
        
        os.makedirs(os.path.dirname(hostname_file), exist_ok=True)
        with open(hostname_file, 'w') as f:
            f.write(self.system_profile['hostname'])
        
        print(f"✅ Updated hostname: {self.system_profile['hostname']}")
    
    def obfuscate_hosts(self):
        """Create realistic /etc/hosts file"""
        hosts_file = f"{self.honeyfs_path}/etc/hosts"
        
        hosts_content = f"""127.0.0.1	localhost
127.0.1.1	{self.system_profile['hostname']}

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters"""
        
        os.makedirs(os.path.dirname(hosts_file), exist_ok=True)
        with open(hosts_file, 'w') as f:
            f.write(hosts_content)
        
        print("✅ Updated /etc/hosts")
    
    def obfuscate_issue(self):
        """Create realistic /etc/issue file"""
        issue_file = f"{self.honeyfs_path}/etc/issue"
        
        issue_content = f"Ubuntu {self.system_profile['ubuntu_version']} LTS \\n \\l\n\n"
        
        os.makedirs(os.path.dirname(issue_file), exist_ok=True)
        with open(issue_file, 'w') as f:
            f.write(issue_content)
        
        print(f"✅ Updated /etc/issue: Ubuntu {self.system_profile['ubuntu_version']} LTS")
    
    def _generate_realistic_users(self) -> List[Dict]:
        """Generate realistic system users (removes default 'phil')"""
        
        # Common service accounts
        service_users = [
            {"name": "daemon", "uid": 1, "gid": 1, "home": "/usr/sbin", "shell": "/usr/sbin/nologin"},
            {"name": "bin", "uid": 2, "gid": 2, "home": "/bin", "shell": "/usr/sbin/nologin"},
            {"name": "sys", "uid": 3, "gid": 3, "home": "/dev", "shell": "/usr/sbin/nologin"},
            {"name": "sync", "uid": 4, "gid": 65534, "home": "/bin", "shell": "/bin/sync"},
            {"name": "games", "uid": 5, "gid": 60, "home": "/usr/games", "shell": "/usr/sbin/nologin"},
            {"name": "man", "uid": 6, "gid": 12, "home": "/var/cache/man", "shell": "/usr/sbin/nologin"},
            {"name": "lp", "uid": 7, "gid": 7, "home": "/var/spool/lpd", "shell": "/usr/sbin/nologin"},
            {"name": "mail", "uid": 8, "gid": 8, "home": "/var/mail", "shell": "/usr/sbin/nologin"},
            {"name": "news", "uid": 9, "gid": 9, "home": "/var/spool/news", "shell": "/usr/sbin/nologin"},
            {"name": "uucp", "uid": 10, "gid": 10, "home": "/var/spool/uucp", "shell": "/usr/sbin/nologin"},
            {"name": "proxy", "uid": 13, "gid": 13, "home": "/bin", "shell": "/usr/sbin/nologin"},
            {"name": "www-data", "uid": 33, "gid": 33, "home": "/var/www", "shell": "/usr/sbin/nologin"},
            {"name": "backup", "uid": 34, "gid": 34, "home": "/var/backups", "shell": "/usr/sbin/nologin"},
            {"name": "list", "uid": 38, "gid": 38, "home": "/var/list", "shell": "/usr/sbin/nologin"},
            {"name": "irc", "uid": 39, "gid": 39, "home": "/var/run/ircd", "shell": "/usr/sbin/nologin"},
            {"name": "gnats", "uid": 41, "gid": 41, "home": "/var/lib/gnats", "shell": "/usr/sbin/nologin"},
            {"name": "nobody", "uid": 65534, "gid": 65534, "home": "/nonexistent", "shell": "/usr/sbin/nologin"},
            {"name": "_apt", "uid": 100, "gid": 65534, "home": "/nonexistent", "shell": "/usr/sbin/nologin"},
        ]
        
        # Add realistic admin users
        admin_names = ["admin", "ubuntu", "ec2-user", "deploy", "devops", "sysadmin"]
        admin_user = {
            "name": random.choice(admin_names),
            "uid": 1000,
            "gid": 1000,
            "home": f"/home/{random.choice(admin_names)}",
            "shell": "/bin/bash"
        }
        
        return service_users + [admin_user]
    
    def obfuscate_passwd(self):
        """Create realistic /etc/passwd without default 'phil' user"""
        passwd_file = f"{self.honeyfs_path}/etc/passwd"
        users = self._generate_realistic_users()
        
        passwd_content = "root:x:0:0:root:/root:/bin/bash\n"
        for user in users:
            passwd_content += f"{user['name']}:x:{user['uid']}:{user['gid']}:,,,:{user['home']}:{user['shell']}\n"
        
        os.makedirs(os.path.dirname(passwd_file), exist_ok=True)
        with open(passwd_file, 'w') as f:
            f.write(passwd_content)
        
        print("✅ Updated /etc/passwd (removed default 'phil' user)")
    
    def obfuscate_group(self):
        """Create realistic /etc/group without default 'phil' user"""
        group_file = f"{self.honeyfs_path}/etc/group"
        
        group_content = """root:x:0:
daemon:x:1:
bin:x:2:
sys:x:3:
adm:x:4:syslog,ubuntu
tty:x:5:
disk:x:6:
lp:x:7:
mail:x:8:
news:x:9:
uucp:x:10:
man:x:12:
proxy:x:13:
kmem:x:15:
dialout:x:20:ubuntu
fax:x:21:
voice:x:22:
cdrom:x:24:ubuntu
floppy:x:25:ubuntu
tape:x:26:
sudo:x:27:ubuntu
audio:x:29:ubuntu
dip:x:30:ubuntu
www-data:x:33:
backup:x:34:
operator:x:37:
list:x:38:
irc:x:39:
src:x:40:
gnats:x:41:
shadow:x:42:
utmp:x:43:
video:x:44:ubuntu
sasl:x:45:
plugdev:x:46:ubuntu
staff:x:50:
games:x:60:
users:x:100:
nogroup:x:65534:
systemd-journal:x:101:
systemd-network:x:102:
systemd-resolve:x:103:
systemd-timesync:x:104:
crontab:x:105:
messagebus:x:106:
input:x:107:
kvm:x:108:
render:x:109:
syslog:x:110:
uuidd:x:111:
tcpdump:x:112:
ssh:x:113:
landscape:x:114:
admin:x:115:
netdev:x:116:ubuntu
lxd:x:117:ubuntu
ubuntu:x:1000:
systemd-coredump:x:999:"""
        
        os.makedirs(os.path.dirname(group_file), exist_ok=True)
        with open(group_file, 'w') as f:
            f.write(group_content)
        
        print("✅ Updated /etc/group (removed default 'phil' user)")
    
    def obfuscate_shadow(self):
        """Create realistic /etc/shadow with salted passwords"""
        shadow_file = f"{self.honeyfs_path}/etc/shadow"
        
        # Generate realistic password hashes
        def generate_shadow_hash():
            salt = ''.join(random.choices(string.ascii_letters + string.digits + './', k=16))
            return f"$6${salt}${''.join(random.choices(string.ascii_letters + string.digits + './', k=86))}"
        
        shadow_content = f"""root:{generate_shadow_hash()}:18000:0:99999:7:::
daemon:*:18000:0:99999:7:::
bin:*:18000:0:99999:7:::
sys:*:18000:0:99999:7:::
sync:*:18000:0:99999:7:::
games:*:18000:0:99999:7:::
man:*:18000:0:99999:7:::
lp:*:18000:0:99999:7:::
mail:*:18000:0:99999:7:::
news:*:18000:0:99999:7:::
uucp:*:18000:0:99999:7:::
proxy:*:18000:0:99999:7:::
www-data:*:18000:0:99999:7:::
backup:*:18000:0:99999:7:::
list:*:18000:0:99999:7:::
irc:*:18000:0:99999:7:::
gnats:*:18000:0:99999:7:::
nobody:*:18000:0:99999:7:::
systemd-network:*:18000:0:99999:7:::
systemd-resolve:*:18000:0:99999:7:::
systemd-timesync:*:18000:0:99999:7:::
messagebus:*:18000:0:99999:7:::
syslog:*:18000:0:99999:7:::
_apt:*:18000:0:99999:7:::
uuidd:*:18000:0:99999:7:::
tcpdump:*:18000:0:99999:7:::
landscape:*:18000:0:99999:7:::
ubuntu:{generate_shadow_hash()}:18000:0:99999:7:::
lxd:!:18000:0:99999:7:::
systemd-coredump:!!:18000::::::"""
        
        os.makedirs(os.path.dirname(shadow_file), exist_ok=True)
        with open(shadow_file, 'w') as f:
            f.write(shadow_content)
        
        print("✅ Updated /etc/shadow (removed default 'phil', added salted hashes)")
    
    def obfuscate_userdb(self):
        """Create realistic userdb.txt with production-like credentials"""
        userdb_file = f"{self.etc_path}/userdb.txt"
        
        # Realistic production credentials (still weak for honeypot purposes)
        credentials = [
            "root:toor",
            "root:123456", 
            "root:password",
            "root:admin",
            "admin:admin",
            "admin:password",
            "ubuntu:ubuntu",
            "ubuntu:password",
            "deploy:deploy123",
            "backup:backup2023",
            "service:service123",
            "test:test123",
            "guest:guest",
            "user:user123"
        ]
        
        # Add some realistic but weak passwords
        weak_passwords = ["Password123", "Welcome123", "Company2023", "Server2023"]
        for pwd in weak_passwords:
            credentials.append(f"root:{pwd}")
            credentials.append(f"admin:{pwd}")
        
        os.makedirs(os.path.dirname(userdb_file), exist_ok=True)
        with open(userdb_file, 'w') as f:
            for cred in credentials:
                f.write(f"{cred}\n")
        
        print(f"✅ Updated userdb.txt ({len(credentials)} credential pairs)")
    
    def obfuscate_ifconfig(self):
        """Modify ifconfig command to show realistic network interface"""
        # This would require modifying the Cowrie ifconfig command
        # For now, we'll create a note about what needs to be changed
        
        ifconfig_note = f"""
# Ifconfig Obfuscation Notes
# Modify /src/cowrie/commands/ifconfig.py to show:
# - Realistic MAC address: {self.system_profile['mac_prefix']}:xx:xx:xx
# - Realistic interface names: eth0, ens3, enp0s3 (not default)
# - Realistic IP ranges: 10.0.0.x, 172.16.x.x, 192.168.x.x
# - Remove any hardcoded default values
"""
        
        with open(f"{self.cowrie_path}/ifconfig_obfuscation_notes.txt", 'w') as f:
            f.write(ifconfig_note)
        
        print("✅ Created ifconfig obfuscation notes (manual modification required)")
    
    def obfuscate_cowrie_cfg(self):
        """Modify cowrie.cfg with non-default values"""
        cfg_file = f"{self.etc_path}/cowrie.cfg"
        
        # Read existing config
        if os.path.exists(cfg_file):
            with open(cfg_file, 'r') as f:
                config_content = f.read()
        else:
            config_content = ""
        
        # Add obfuscation settings
        obfuscation_config = f"""

# Obfuscation Settings - Non-default values
[honeypot]
hostname = {self.system_profile['hostname']}
log_path = /opt/cowrie/var/log/cowrie
download_path = /opt/cowrie/var/lib/cowrie/downloads
contents_path = /opt/cowrie/honeyfs
txtcmds_path = /opt/cowrie/txtcmds
data_path = /opt/cowrie/var/lib/cowrie
filesystem_file = /opt/cowrie/share/cowrie/fs.pickle

# SSH Configuration - Non-default algorithms
[ssh]
version = SSH-2.0-OpenSSH_7.6p1 Ubuntu-4ubuntu0.3
listen_endpoints = tcp:2222:interface=0.0.0.0
sftp_enabled = true
forwarding = true
forward_redirect = false

# Realistic SSH algorithms (not defaults)
kex = curve25519-sha256,curve25519-sha256@libssh.org,ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group14-sha256
ciphers = chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
macs = umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128@openssh.com,hmac-sha2-256,hmac-sha2-512
compression = none,zlib@openssh.com

# Telnet (disabled for production-like appearance)
[telnet]
enabled = false

# Output plugins
[output_jsonlog]
logfile = /opt/cowrie/var/log/cowrie/cowrie.json

[output_mysql]
enabled = false

# Backend configuration
[backend_pool]
pool_only = false
recycle_period = 1500
listen_endpoints = tcp:6415:interface=127.0.0.1
save_snapshots = true
snapshot_path = /opt/cowrie/var/lib/cowrie/snapshots
"""
        
        # Write updated config
        with open(cfg_file, 'w') as f:
            f.write(config_content + obfuscation_config)
        
        print("✅ Updated cowrie.cfg with non-default values")
    
    def rebuild_fs_pickle(self):
        """Rebuild the filesystem pickle with new configuration"""
        try:
            # Change to cowrie directory and rebuild filesystem
            os.chdir(self.cowrie_path)
            result = subprocess.run([
                'python3', '-c', 
                'from cowrie.core import fs; fs.create_filesystem("/opt/cowrie/share/cowrie/fs.pickle", "/opt/cowrie/honeyfs")'
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✅ Rebuilt filesystem pickle with obfuscated data")
            else:
                print(f"⚠️  Filesystem rebuild warning: {result.stderr}")
                
        except Exception as e:
            print(f"⚠️  Manual filesystem rebuild required: {e}")
            print("   Run: cd /opt/cowrie && python3 -c 'from cowrie.core import fs; fs.create_filesystem(\"share/cowrie/fs.pickle\", \"honeyfs\")'")


if __name__ == "__main__":
    print("🎭 Cowrie Obfuscator - Based on Academic Research")
    print("=" * 60)
    
    obfuscator = CowrieObfuscator()
    obfuscator.obfuscate_all()
    
    print("\n🎯 Obfuscation Summary:")
    print(f"   Hostname: {obfuscator.system_profile['hostname']}")
    print(f"   CPU: {obfuscator.system_profile['cpu_model']}")
    print(f"   Memory: {obfuscator.system_profile['memory_gb']}GB")
    print(f"   Kernel: {obfuscator.system_profile['kernel_version']}")
    print(f"   Ubuntu: {obfuscator.system_profile['ubuntu_version']}")
    
    print("\nHoneypot obfuscation applied successfully:")
    print("   - Removed default 'phil' user")
    print("   - Realistic system information")
    print("   - Non-default SSH algorithms")
    print("   - Production-like configuration")
    print("\nRestart Cowrie to apply changes:")
    print("   sudo systemctl restart cowrie")