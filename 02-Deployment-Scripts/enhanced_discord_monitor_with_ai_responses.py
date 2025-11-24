[33mcommit b204628eb7cb00385924bd872f6cf91541daf1d8[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mmain[m[33m)[m
Author: kevin landry <kevinlandrycyber@gmail.com>
Date:   Mon Nov 24 00:22:20 2025 -0500

    Final sanitized results from 45+ days of attacker data

[33mcommit 6bece191b036bf173db90a36d29b5d437d00cbb1[m[33m ([m[1;31morigin/main[m[33m, [m[1;31morigin/HEAD[m[33m)[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Sat Oct 25 21:45:54 2025 -0400

    Add PCAP conversion tools for presentation analysis

[33mcommit 19847a63243139b55888dc2142f479bd993c1ab3[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Sat Oct 25 21:34:24 2025 -0400

    Clean up project: Remove outdated UML diagrams and remaining AI troll references

[33mcommit 75f06621332de3a99c3f0790c2a7ba3276df6c47[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Sat Oct 25 21:29:28 2025 -0400

    Remove remaining AI troll references from integrated architecture diagram

[33mcommit 734b868300ec68f18a4c9cb356682a5354a55e54[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Sat Oct 25 17:12:31 2025 -0400

    Remove AI troll components from UML diagrams - not feasible for implementation

[33mcommit 9a9561fbbd515ad25b52a50cd53fc5f8e83907ac[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Sat Oct 25 17:03:03 2025 -0400

    Rebrand: Replace CerberusMesh with PatriotPot Deception Framework

[33mcommit 8d79fa0410fb63337da7286df42c09fd7314e67a[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Sat Oct 25 16:48:33 2025 -0400

    Remove AI troll agent documentation and references - feature not implemented

[33mcommit f04b1b62915c7ce782fb6aa540db10962da812d4[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Thu Oct 23 22:00:00 2025 -0400

    Major infrastructure upgrade: Lambda enrichment, MITRE mapping, Shodan heatmaps

[33mcommit 20a2d6325674342dc85befa9fa1da353146eb7f7[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Thu Oct 23 21:50:55 2025 -0400

    Update Shodan heatmap to 60-day lookback

[33mcommit 63c253937e94095cd17c071b9338a01d40565f1e[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Thu Oct 23 21:47:53 2025 -0400

    Add Shodan API integration for daily heatmaps

[33mcommit 5730089ba4d6810ce1601ae01f47635baf95c89b[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Thu Oct 23 21:33:51 2025 -0400

    Lambda Enrichment Pipeline + MITRE Mapping + Directory Cleanup

[33mcommit 2a304c208948b7574d1d3def99ec3e6a355fb833[m
Author: copilot-swe-agent[bot] <198982749+Copilot@users.noreply.github.com>
Date:   Fri Oct 24 00:55:03 2025 +0000

    Add comprehensive summary of PlantUML fixes and enhancements
    
    Co-authored-by: DadOpsMateoMaddox <142954851+DadOpsMateoMaddox@users.noreply.github.com>

[33mcommit 439e71929b0c8bbeac393555389a3a5b1b89f83e[m
Author: copilot-swe-agent[bot] <198982749+Copilot@users.noreply.github.com>
Date:   Fri Oct 24 00:52:25 2025 +0000

    Update PlantUML-README to document operational-sequence diagram
    
    Co-authored-by: DadOpsMateoMaddox <142954851+DadOpsMateoMaddox@users.noreply.github.com>

[33mcommit 0657f81d078d69472bbd63fdc63707e642e07f3b[m
Author: copilot-swe-agent[bot] <198982749+Copilot@users.noreply.github.com>
Date:   Fri Oct 24 00:50:56 2025 +0000

    Fix encoding issue in honeypot-architecture.puml and add operational-sequence.puml
    
    Co-authored-by: DadOpsMateoMaddox <142954851+DadOpsMateoMaddox@users.noreply.github.com>

[33mcommit bf330b37ca173ccc500b30306ee8a96f553a9c86[m
Author: DadOpsMateoMaddox <DadOpsMateoMaddox@users.noreply.github.com>
Date:   Thu Oct 23 20:40:23 2025 -0400

    Checkpoint from VS Code for coding agent session

[33mcommit 8704171157a1d3417da4a498d4a67a0283fb85eb[m
Author: dadopsmateomaddox <dadopsmateomaddox@gmail.com>
Date:   Fri Sep 26 22:56:05 2025 -0400

     Add Discord Webhook Integration System
    
     Complete Discord monitoring for Cowrie honeypot
    - Real-time alerts for login attempts, commands, file transfers
    - Comprehensive Python monitoring script with smart filtering
    - Systemd service for continuous monitoring
    - Security-focused configuration management
    - Team-friendly deployment and setup scripts
    - Detailed documentation and tutorials
    
     Key Features:
    -  Critical alerts: Successful logins, file uploads (RED)
    -  Warning alerts: Suspicious commands, downloads (ORANGE)
    -  Info alerts: Failed logins, normal commands (BLUE)
    -  Secure webhook URL management (excluded from git)
    -  Auto-restart service with error handling
    -  Customizable alert levels and command filtering
    
     Files Added:
    - discord_honeypot_monitor.py - Main monitoring script
    - discord_config_template.json - Configuration template
    - cowrie-discord-monitor.service - Systemd service
    - deploy_discord_monitor.sh - Automated deployment
    - quick_setup_discord.sh - Team setup script
    - setup_discord_complete.sh - All-in-one installer
    - Comprehensive team documentation
    
    Ready for deployment to AWS honeypot!

[33mcommit 1919f63253e6e5219774038713de1ed0d55ba0e5[m
Author: dadopsmateomaddox <dadopsmateomaddox@gmail.com>
Date:   Fri Sep 26 22:01:06 2025 -0400

     Initial Release: CerberusMesh AWS Honeypot Framework
    
     GMU AIT670 Team Collaborative Project
     Multi-tier deception framework with Cowrie SSH honeypot
    
     Features:
     Cowrie v2.5.0 honeypot on AWS EC2 infrastructure
     Comprehensive team collaboration protocols
     Complete documentation and tutorial system
     PlantUML architecture diagrams and workflows
     Automated deployment with CloudFormation IaC
     Realistic fake filesystem with security decoys
     24/7 monitoring and threat intelligence gathering
     Professional academic documentation standards
    
     Team Effort:
     Collaborative development and testing
     Shared monitoring and analysis responsibilities
     Cross-training and knowledge sharing protocols
     Coordinated infrastructure management
     Joint academic research and documentation
    
     Security:
     All private keys and credentials excluded
     Isolated AWS environment with proper security groups
     Comprehensive logging and session recording
     Ethical research guidelines and academic compliance
    
     Complete Documentation:
     Beginner-friendly team access tutorials
     Advanced deployment automation scripts
     Professional architecture and sequence diagrams
     Academic project proposals and research methodology
