# PatriotPot Deception Framework - Presentation Script

## SLIDE 1: Title Slide (30 seconds)
**"Good evening everyone. Welcome to our PatriotPot Deception Framework presentation. I'm Kevin Landry, team lead for this AWS Cowrie honeypot project. Tonight we're going to dive deep into hands-on cybersecurity - specifically how we've deployed a production honeypot that's been capturing real attacks for the past month. By the end of this session, each of you will have your own honeypot running and understand exactly how attackers operate in the wild."**

## SLIDE 2: Project Overview (2 minutes)
**"Let's start with the big picture. Our PatriotPot has been live since September, and the numbers are impressive. We've identified 43 unique attackers from 6 different countries, captured 669 distinct attack events, and geolocated 29 of these threat actors. This isn't theoretical - this is real cybersecurity happening right now."**

**"What makes this special is that we're running on AWS EC2 in the us-east-1 region, giving us enterprise-grade infrastructure. But more importantly, every single one of these attacks teaches us something about how real hackers operate."**

## SLIDE 3: Understanding Cowrie (2 minutes)
**"Now, what exactly is Cowrie? Think of it as the ultimate digital mousetrap. Cowrie is a medium-interaction honeypot written in Python that perfectly emulates a Linux SSH server. When attackers connect, they think they've found a vulnerable server, but they're actually interacting with our carefully crafted deception."**

**"The key here is 'medium-interaction' - it's realistic enough to fool attackers into spending significant time, but safe enough that they can't actually damage anything. We're running version 2.5.0 with a hardened configuration, 600-second timeouts, and complete JSON logging."**

## SLIDE 4: Honeypot Types (1.5 minutes)
**"Let me put this in context. There are three types of honeypots: low-interaction ones that just simulate services, high-interaction ones using real systems with monitoring, and medium-interaction like ours that emulate operating systems. We chose medium-interaction because it gives us the perfect balance - realistic enough to capture sophisticated attacks, but contained enough to be safe."**

**"Our implementation is specifically a research honeypot designed to study attack techniques and collect threat intelligence."**

## SLIDE 5: Network Architecture & OSI Model (2 minutes)
**"Here's where it gets technically interesting. We're operating across multiple layers of the OSI model to create our deception. At Layer 3, attackers see our public IP 44.218.220.47, but Cowrie shows them fake internal addresses. At Layer 4, we separate real admin access on port 22 from the honeypot on port 2222. At Layer 7, attackers get a completely fake filesystem while we maintain real system access."**

**"This multi-layer deception is crucial - attackers think they're on a different network segment entirely."**

## SLIDE 6: Filesystem Deception (1.5 minutes)
**"Speaking of deception, let's look at what attackers actually see. We've crafted a realistic filesystem with decoy files that are irresistible to attackers. There's a passwords.txt file with fake credentials, server_info.txt with fake infrastructure details, and config.json with fake API keys. Every file is designed to make attackers think they've hit the jackpot while giving us insight into their methods."**

## SLIDE 7: JSON Data Collection & PCAP Analysis (3 minutes)
**"Now here's where the real intelligence gathering happens. Let me show you actual attack data we captured just yesterday."**

**[Read the JSON attack data]**

**"This is a sophisticated persistence attack from IP 173.249.50.59. Watch the sequence: first they remove file attributes to make the .ssh directory modifiable, then they completely replace it with their own SSH key for backdoor access. The key identifier 'mdrfckr' tells us about this attacker's mindset."**

**"This maps to MITRE ATT&CK technique T1098.004 - Account Manipulation through SSH Authorized Keys. This is textbook persistence establishment."**

**"We capture this in JSON for automated analysis, but we also convert to PCAP format for Wireshark analysis. JSON gives us structured data perfect for SIEM integration, while PCAP gives us network-level forensics. Having both perspectives is crucial for complete attack reconstruction."**

## SLIDE 8: Threat Intelligence Stack (2 minutes)
**"Our threat intelligence stack is what turns raw attack data into actionable intelligence. We use GreyNoise API to distinguish between background internet noise and real threats. Shodan API gives us geographic attribution. Discord webhooks provide real-time team notifications. And we generate daily heatmaps showing global attack patterns."**

**"The MITRE ATT&CK mapping automatically categorizes attack techniques, helping us understand not just what happened, but how it fits into the broader threat landscape."**

## SLIDE 9: What We've Captured (1.5 minutes)
**"So what have we actually caught? Login attempts from 6 countries, malware download attempts, credential stuffing attacks, reconnaissance commands, and sophisticated persistence techniques like we just saw. Each attack teaches us something new about threat actor behavior and techniques."**

## SLIDE 10: Team Roles & Sprint Goals (2 minutes)
**"Now let's talk about your roles. We're organizing into two sprints. Sprint 1 is foundational - everyone deploys their own EC2 Cowrie instance, configures SSH access, and sets up Discord monitoring. Sprint 2 is where you specialize based on your interests."**

**"We have four specialized roles: Security Analyst focusing on forensics and attack pattern analysis, DevOps Engineer handling infrastructure automation, Security Engineer implementing threat detection, and Security Researcher analyzing attack trends and intelligence."**

## SLIDE 11-14: Individual Role Slides (1 minute each)
**[For each role slide, briefly highlight the key responsibilities and deliverables]**

**"Each role has specific tools you'll master and real-world deliverables. This isn't just academic - these are the exact skills and tools used in production security operations."**

## SLIDE 15: Today's Hands-On Lab (2 minutes)
**"Alright, let's get hands-on. Today we're going to walk through the complete deployment process together. We'll launch EC2 instances, install Cowrie from GitHub, configure security groups, test with simulated attacks, and analyze the results in real-time."**

**"The goal is simple: by the end of tonight, everyone has a working honeypot and has seen their first attack logged."**

## SLIDE 16: Success Criteria (1 minute)
**"Success means you can SSH to your honeypot, see the fake filesystem, watch logs being generated in JSON format, and view real-time attacks. Discord alerts are optional for personal instances, but I'll show you how to set them up."**

## SLIDE 17: Resources & Next Steps (1 minute)
**"All our code is on GitHub at DadOpsMateoMaddox/AWSHoneypot. Complete deployment guides are in the 03-Team-Tutorials folder. Our shared production honeypot at 44.218.220.47:2222 will keep running for comparison. Next meeting we'll do sprint reviews and demos of what you've built."**

## CLOSING (30 seconds)
**"Questions before we dive into the lab? Remember, this isn't just about learning tools - you're about to become part of the global cybersecurity intelligence community. Every attack you capture contributes to our understanding of how threats evolve. Let's get started."**

---

## PRESENTATION TIMING BREAKDOWN:
- **Total Time**: ~20 minutes presentation + 40 minutes hands-on lab
- **Key Emphasis**: Real attack data, practical skills, immediate hands-on application
- **Engagement Points**: Live attack data, Wireshark demo, role assignments
- **Technical Depth**: Balanced for mixed skill levels with deep-dive opportunities

## DEMO PREPARATION CHECKLIST:
- [ ] Live honeypot terminal ready with log tail
- [ ] Wireshark open with PCAP file loaded
- [ ] Discord channel visible for real-time alerts
- [ ] AWS Console open to EC2 dashboard
- [ ] GitHub repository ready to show
- [ ] Attack heatmap HTML file ready to display