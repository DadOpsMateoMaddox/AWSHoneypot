# Advanced Cowrie Configuration to Increase Honeypot Deceptiveness

**Warren Z Cabral, Craig Valli, Leslie F Sikos, Samuel G Wakeling**  
*Cyber Security Co-operative Research Centre, Perth, WA, Australia*  
*Security Research Institute, Edith Cowan University, Perth, WA, Australia*

---

## Abstract

> Cowrie is a medium-interaction SSH, and Telnet honeypot used to record brute force attacks and SSH requests. Cowrie utilizes a Python codebase, which is maintained and publicly available on GitHub. Since its source code is publicly released, not only security specialists but cybercriminals can also analyze it. Nonetheless, cybersecurity specialists deploy most honeypots with default configurations. This outcome is because modern computer systems and infrastructures do not provide a standard framework for optimal deployment of these honeypots based on the various configuration options available to produce a non-default configuration. This option would allow them to act as effective deceptive systems. Honeypot deployments with default configuration settings are easier to detect because cybercriminals have known scripts and tools such as NMAP and Shodan for identifying them. This research aims to develop a framework that enables for the customized configuration of the Cowrie honeypot, thereby enhancing its functionality to achieve a high degree of deceptiveness and realism when presented to the Internet. A comparison between the default and configured deployments is further conducted to prove the modified deployments' effectiveness.

**Keywords:** Cybersecurity, Honeypots, Deception, Cowrie, SSH.

---

## 1. Introduction

Honeypots are viable tools for network monitoring; to detect, record and analyze attacks in a network. Cybersecurity specialists and academic researchers use a collection of honeypots, i.e., honeynets – to monitor cyberattacks across networks and the entire cyberspace [1, 2]. They reveal an attacker's IP, location, commands entered and can also be used to study targeted vulnerabilities and capture malware binaries.

This research focuses on the **Cowrie honeypot**[^1], which interacts with cybercriminals within a simulated SSH environment. Simulation is a biology-inspired deceptive process through which the honeypot provides a service that functions like the actually expected system. For example, being an SSH honeypot, Cowrie simulates an SSH server's behaviour and usually a Linux operating system (It can also be configured to simulate a Windows environment exposing SSH to a PowerShell session), thereby allowing cybercriminals to log into the system. Still, every command is only imitated and logged but not actually executed [3]. Hence, cybercriminals can easily detect the difference between a simulated session (honeypot environment) and a legitimate OS session [4].

High-interaction honeypots are challenging to identify because they provide the entire operating system to the cybercriminal rather than a simulated environment [5], and they typically are expensive to operate. Because of high operational costs, many honeypot operators rely on low-interaction or medium-interaction open-source honeypots to simulate vulnerable network services such as SSH, ICMP, and SCADA services. This is because they are not only cost-effective but are easily deployable and maintainable.

However, the usage of this method of simulation also entails a number of operational weaknesses: poor deceptive capability and use of default deployments due to an absence of a standard deployment architecture and lack of knowledge on how to deploy honeypots securely and completely.

Cybercriminals rely on numerous tools and strategies to detect honeypots. These are:

#### i. The Mental Mindset
"Honeypot detection lies in a cybercriminal's ability to detect and find out about the deceptive nature of the honeypot". Tsikerdekis [6] wrote this, implying that a honeypot's detection lies in what a cybercriminal thinks about how a honeypot typically functions and interacts. This means a cybercriminal may believe that they are attacking a honeypot when it is the real system, or they think they are attacking the existing network but are instead interacting with a honeypot. Therefore, at times honeypot detection depends on the cybercriminal's thinking. For example, the honeypot environment may not be configured correctly; there may be a lack or absence of security mechanisms securing the honeypot. Therefore, the cybercriminal may realize the target is too easy and hence it is a possible trap.

#### ii. Default Configurations
As previously mentioned, honeypot deployments with default configuration settings are easier to detect and must be configured before deployment. According to Vetterl [7], the main cause for convenient and easy honeypot detection is that honeypot operators deploy honeypots with default configurations. Their research aimed specifically at Kippo and Cowrie honeypots. It was discovered that 72% of honeypots were deployed with default values. To confirm their hypothesis, the `uname -a` command was executed on the detected honeypots. The command returned the string `Linux [hostname] 3.2.0-4-amd64 #1 SMP Debian 3.2.68-1+deb7u1 x86 64 GNU/Linux\r\n` [8], which is indeed a default value for the Cowrie honeypot instance.

#### iii. NMAP
NMAP[^2] is a network mapping tool used for detecting and identifying open ports and services [9]. Default instances of Cowrie reveal port 2222 operating on a default Cowrie SSH string.

#### iv. Shodan
Shodan[^3] is a scanning service developed by Matherly [10] used to "crawl" the Internet. When analyzing a device, Shodan queries the device's banners, IP address, protocols, port number, and other metadata.

#### v. Automated Scripts
Some cybercriminals have automated scripts developed that can be executed to detect honeypots based on type, settings, and other default values. For example, the python script `cowrie_detect.py`[^4] scans the network by collecting hostnames, ports, default arguments and accurately displays if the monitored machine is operating a Cowrie instance.

Over 19,208 open-source honeypots were detected using simple tools and signatures. This outcome is because these systems received no configuration before deployment and because cybercriminals are already aware of their default configurations [3, 7]. This research aims to mitigate this problem by modifying these configurations.

---

## 2. Research Process

This section describes the process in which this study was conducted. The research process (RP) comprises three main phases: sample selection, conduct experiments, and observation.

### 2.1 RP-1: Sample Selection

1.  **RP-1.1:** Acquire the latest stable version of the Cowrie honeypot using `git clone`.
2.  **RP-1.2:** Activate and test the honeypot environments using a virtual machine (VM) based installation of Ubuntu 18.04.5 LTS.

### 2.2 RP-2: Conduct Experiments

1.  **RP-2.1: Configuration Modification**
    - Cowrie has numerous files such as `ifconfig.py`, `userdb.txt`, and `honeyfs` files that can be modified.
    - The `obscurer.py`[^5] script was used to automatically configure the Cowrie honeypot artefacts, as shown in Table 1.

    **Table 1. Configurations employed by the `obscurer.py` script**
| Function Name     | Usage                                                                    | File Location                      |
| :---------------- | :----------------------------------------------------------------------- | :--------------------------------- |
| `ifconfig_py()`   | Modifies ARP table and `ifconfig` output.                                | `/src/cowrie/commands/ifconfig.py` |
| `version_uname()` | Alters the OS version string.                                            | `/honeyfs/proc/version`            |
| `meminfo_py()`    | Alters memory information.                                               | `/honeyfs/proc/meminfo.py`         |
| `mounts()`        | Alters mounted drive names.                                              | `/honeyfs/proc/mounts`             |
| `cpuinfo()`       | Edits CPU model, speed, and cache info.                                  | `/honeyfs/proc/cpuinfo`            |
| `group()`         | Deletes default user "phil" and adds random users.                       | `/honeyfs/etc/group`               |
| `passwd()`        | Deletes default user "phil" and adds random users.                       | `/honeyfs/etc/passwd`              |
| `shadow()`        | Deletes default user "phil" and adds random users with salted passwords. | `/honeyfs/etc/shadow`              |
| `cowrie_cfg()`    | Configures `cowrie.cfg` with non-default values.                         | `/etc/cowrie.cfg`                  |
| `hosts()`         | Replaces default hostnames.                                              | `/honeyfs/etc/hosts`               |
| `hostname_py()`   | Changes the hostname file.                                               | `/honeyfs/etc/hostname.py`         |
| `issue()`         | Changes the OS issue file.                                               | `/honeyfs/etc/issue`               |
| `userdb()`        | Creates and modifies `userdb.txt` with unique credentials.               | `/etc/userdb.txt`                  |
| `fs_pickle()`     | Recreates the honeypot filesystem pickle.                                | `/share/cowrie/fs.pickle`          |

2.  **RP-2.2: IP Blacklisting**
    - A list of well-known automated scanners and their subnets were identified and blocked using the `ufw` firewall to reduce scanner detection.

3.  **RP-2.3: Deployment and Validation**
    - Three honeypots were deployed: one with default configurations and two with automated, modified configurations.

    **Table 2. Cowrie Deployment Cycle**
| Honeypot | Deployment Type | Deployment Period             | Credentials         |
| :------- | :-------------- | :---------------------------- | :------------------ |
| Cowrie A | Default         | 1st Nov 2020 – 29th Nov 2020  | Default credentials |
| Cowrie B | Configured      | 30th Nov 2020 – 28th Dec 2020 | `tech` / `enable`   |
| Cowrie C | Configured      | 29th Dec 2020 – 26th Jan 2021 | `root` / `nproc`    |

### 2.3 RP-3: Observation

The default honeypots were observed against the configured deployments to study the distinction in deceptiveness. The following variables were analyzed:
-   **Emulated service activity (SI)**
-   **IP connections (IP)**
-   **Connection to deceptive ports (CDP)**
-   **Brute force count (BF)**

---

## 3. Results and Analysis

### 3.1 NMAP Scan Analysis

NMAP scans were conducted using the command: `nmap -sV -Pn -p- [IP_address]`

**Table 3. NMAP scan output for Cowrie A (Default)**
| Port     | State | Service | Version                           |
| :------- | :---- | :------ | :-------------------------------- |
| 22/tcp   | Open  | SSH     | OpenSSH (7.6p1 Ubuntu-4ubuntu0.3) |
| 2222/tcp | Open  | SSH     | OpenSSH (6.0p1 Debian 4+deb7u2)   |

**Table 4. NMAP scan output for Cowrie B & C (Configured)**
| Port      | State  | Service        | Version                            |
| :-------- | :----- | :------------- | :--------------------------------- |
| 22/tcp    | Open   | SSH            | OpenSSH (7.6p1 Ubuntu- 4ubuntu0.3) |
| 53/tcp    | Closed | Domain         | N/A                                |
| 80/tcp    | Closed | HTTP           | N/A                                |
| 47808/tcp | Closed | BACnet         | N/A                                |
| 10000/tcp | Closed | Sentsensormgmt | N/A                                |

The NMAP scan for Cowrie A revealed the default honeypot port 2222 and default SSH string, a clear indicator. In contrast, Cowrie B and C showed only a single open SSH port and no suspicious indicators.

### 3.2 Shodan Scan Analysis

Shodan scans confirmed the NMAP findings. It also revealed the default SSH algorithms used by Cowrie A, which were different from the configured algorithms on Cowrie B and C, further reducing their detectability.

**Table 5. SSH algorithms used by the Cowrie honeypot instances**
| SSH Algorithm       | Cowrie A (Default)                 | Cowrie B & C (Configured)                                        |
| :------------------ | :--------------------------------- | :--------------------------------------------------------------- |
| **KEX Algorithms**  | `diffie-hellman-group14-sha1`, ... | `curve25519-sha256`, `diffie-hellman-group-exchange-sha256`, ... |
| **Server Host Key** | `ssh-rsa`, `ssh-dss`               | `ssh-rsa`, `rsa-sha2-512`, `ssh-ed25519`, ...                    |
| **Encryption**      | `aes128-cbc`, `3des-cbc`, ...      | `chacha20-poly1305@openssh.com`, `aes256-ctr`, ...               |
| **MAC Algorithms**  | `hmac-sha1`, `hmac-md5`            | `hmac-sha2-512-etm@openssh.com`, `hmac-sha2-512`, ...            |

### 3.3 Splunk Analysis

Data from Splunk showed a significant increase in engagement with the configured honeypots.

-   **24-hour deployment:** Cowrie C saw an **894% increase** in service interaction compared to Cowrie A.
-   **7-day deployment:** Cowrie C logged a **6,574% increase** in connections to deceptive ports compared to Cowrie A.
-   **28-day deployment:** Cowrie C detected a **400% increase** in emulation activity and a **255% surge** in brute force attempts.

### 3.4 `cowrie_detect.py` Detection Analysis

-   **Cowrie A (Default):** Detected as a honeypot with 100% certainty due to the default user "phil", static MAC address, and default system info.
-   **Cowrie B & C (Configured):** The script could not find any default indicators, verifying that the modified versions are 100% more deceptive against this specific tool.

### 3.5 Miscellaneous Observations

Attackers who gained access to the default honeypot (Cowrie A) exited quickly after running commands like `uname -a` or `cat /proc/cpuinfo` returned default, unrealistic values.
-   **Average Session Time (Cowrie A):** 112.36 seconds.
-   **Average Session Time (Cowrie C):** 537.82 seconds.

Attackers on the configured honeypot (Cowrie C) executed 65% more commands and stayed in the interactive shell significantly longer.

---

## 4. Conclusion

The results demonstrate the effectiveness of configured deployments over default ones. Configured Cowrie honeypots provided a dramatic improvement in the quality and quantity of intelligence gathered, including:
-   Increased number of distinct IP connections.
-   Longer attacker session times and more commands executed.
-   Higher rates of brute force attempts and file downloads.

In the future, the `obscurer` script will be further modified to enhance simulation for command outputs and create even more unique system profiles.

---

## 5. Acknowledgements

The work has been supported by the Cyber Security Research Centre, whose activities are partially funded by the Australian Government's Cooperative Research Centres program.

---

## References

[1] Cabral, W.Z., Valli, C., Sikos, L.F., Wakeling, S.G.: Analysis of Conpot and its BACnet Features for Cyber-Deception. (2020).  
[2] Morishita, S., et al.: Detect me if you… oh wait. An internet-wide view of self-revealing honeypots. (2019).  
[3] Cabral, W.Z., Valli, C., Sikos, L.F., Wakeling, S.G.: Review and Analysis of Cowrie Artefacts and their Potential to be used Deceptively. (2019).  
[4] Zhang, F., et al.: Honeypot: a supplemented active defense system for network security. (2003).  
[5] Nicomette, V., et al.: Set-up and deployment of a high-interaction honeypot. (2010).  
[6] Chen, Y., et al.: Exploring Shodan From the Perspective of Industrial Control Systems. (2020).  
[7] Vetterl, A., Clayton, R., Walden, I.: Counting outdated honeypots: Legal and useful. (2019).  
[8] Oosterhof, M.: Cowrie SSH and Telnet Honeypot. (2020).  
[9] Lyon, G.F.: Nmap - Network Mapper. (2021).  
[10] Matherly, J.: Shodan. (2021).  
[11] Chen, Y., et al.: Exploring Shodan From the Perspective of Industrial Control Systems. (2020).

---
[^1]: [https://github.com/cowrie/cowrie](https://github.com/cowrie/cowrie)
[^2]: [https://nmap.org](https://nmap.org)
[^3]: [https://www.shodan.io/](https://www.shodan.io/)
[^4]: [https://github.com/boscutti939/Cowrie_Detect](https://github.com/boscutti939/Cowrie_Detect)
[^5]: [https://github.com/boscutti939/obscurer](https://github.com/boscutti939/obscurer)