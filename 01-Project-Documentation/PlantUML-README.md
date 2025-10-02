# PlantUML Diagrams - AWS Honeypot Project

This directory contains PlantUML diagrams that visualize the honeypot architecture, attack flows, and deployment processes.

## Diagram Files

### 1. `honeypot-architecture.puml`
**System Architecture Diagram**
- Shows overall AWS infrastructure
- Illustrates Cowrie honeypot components
- Displays network flow and security boundaries
- Highlights team access patterns

### 2. `attack-sequence-diagram.puml`
**Attack Flow Sequence**
- Details attacker interaction with honeypot
- Shows how Cowrie captures and logs activity
- Demonstrates fake filesystem responses
- Illustrates monitoring and analysis workflow

### 3. `deployment-sequence.puml`
**Deployment and Team Access**
- Shows infrastructure deployment process
- Details team member onboarding
- Illustrates VS Code and WSL integration
- Demonstrates monitoring and maintenance procedures

## How to View Diagrams

### Online Viewers
1. **PlantUML Web Server**: http://www.plantuml.com/plantuml/uml/
   - Copy and paste diagram code
   - Generate PNG/SVG instantly

2. **VS Code Extension**:
   - Install "PlantUML" extension
   - Open `.puml` files
   - Press `Alt+D` to preview

### Local Setup
```bash
# Install PlantUML (requires Java)
# Ubuntu/WSL:
sudo apt install plantuml

# Generate images
plantuml honeypot-architecture.puml
plantuml attack-sequence-diagram.puml
plantuml deployment-sequence.puml
```

### Export Formats
- **PNG**: High-quality images for documentation
- **SVG**: Scalable vector graphics
- **PDF**: Professional presentation format

## Diagram Themes
- **AWS Orange**: Official AWS styling for architecture diagrams
- **Sketchy**: Hand-drawn style for sequence diagrams
- **Default**: Clean, professional appearance

## Usage in Documentation
These diagrams can be included in:
- Project presentations
- Technical documentation
- Academic reports
- Team training materials
- Security briefings

## Customization
To modify diagrams:
1. Edit the `.puml` source files
2. Test changes with online viewer
3. Generate updated images
4. Include in documentation

---
*Generated for GMU AIT670 - Cloud Computing Project*
*AWS Honeypot Security Research Initiative*