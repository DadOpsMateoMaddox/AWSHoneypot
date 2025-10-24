#!/usr/bin/env python3
"""
Honey Credentials - Fake AWS credentials trap
If attackers try to use them, CloudTrail will alert
"""

import os
import json

class HoneyCredentials:
    def __init__(self):
        self.fake_credentials = {
            'aws': {
                'access_key_id': 'AKIAIOSFODNN7EXAMPLE',
                'secret_access_key': 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
                'region': 'us-east-1'
            },
            'github': {
                'token': 'ghp_ExampleToken1234567890abcdefghijklmno',
                'username': 'admin'
            },
            'database': {
                'host': 'prod-db.internal.company.com',
                'username': 'dbadmin',
                'password': 'P@ssw0rd123!',
                'database': 'production'
            }
        }
    
    def create_fake_aws_credentials(self, cowrie_fs_path='/opt/cowrie/honeyfs'):
        """Create fake .aws/credentials file in honeypot filesystem"""
        aws_dir = os.path.join(cowrie_fs_path, 'home/admin/.aws')
        os.makedirs(aws_dir, exist_ok=True)
        
        creds_file = os.path.join(aws_dir, 'credentials')
        with open(creds_file, 'w') as f:
            f.write('[default]\n')
            f.write(f"aws_access_key_id = {self.fake_credentials['aws']['access_key_id']}\n")
            f.write(f"aws_secret_access_key = {self.fake_credentials['aws']['secret_access_key']}\n")
            f.write(f"region = {self.fake_credentials['aws']['region']}\n")
        
        print(f"✅ Fake AWS credentials planted: {creds_file}")
    
    def create_fake_env_file(self, cowrie_fs_path='/opt/cowrie/honeyfs'):
        """Create fake .env file with credentials"""
        env_file = os.path.join(cowrie_fs_path, 'home/admin/.env')
        
        with open(env_file, 'w') as f:
            f.write('# Production Environment Variables\n')
            f.write(f"AWS_ACCESS_KEY_ID={self.fake_credentials['aws']['access_key_id']}\n")
            f.write(f"AWS_SECRET_ACCESS_KEY={self.fake_credentials['aws']['secret_access_key']}\n")
            f.write(f"GITHUB_TOKEN={self.fake_credentials['github']['token']}\n")
            f.write(f"DB_HOST={self.fake_credentials['database']['host']}\n")
            f.write(f"DB_USER={self.fake_credentials['database']['username']}\n")
            f.write(f"DB_PASS={self.fake_credentials['database']['password']}\n")
        
        print(f"✅ Fake .env file planted: {env_file}")
    
    def create_fake_ssh_keys(self, cowrie_fs_path='/opt/cowrie/honeyfs'):
        """Create fake SSH private keys"""
        ssh_dir = os.path.join(cowrie_fs_path, 'home/admin/.ssh')
        os.makedirs(ssh_dir, exist_ok=True)
        
        key_file = os.path.join(ssh_dir, 'id_rsa')
        with open(key_file, 'w') as f:
            f.write('-----BEGIN RSA PRIVATE KEY-----\n')
            f.write('MIIEpAIBAAKCAQEA1234567890abcdefghijklmnopqrstuvwxyz\n')
            f.write('FAKE_KEY_DATA_FOR_HONEYPOT_TRAP_DO_NOT_USE\n')
            f.write('-----END RSA PRIVATE KEY-----\n')
        
        print(f"✅ Fake SSH key planted: {key_file}")
    
    def deploy_all_traps(self):
        """Deploy all honey credential traps"""
        print("🍯 Deploying honey credential traps...")
        self.create_fake_aws_credentials()
        self.create_fake_env_file()
        self.create_fake_ssh_keys()
        print("✅ All honey traps deployed!")

if __name__ == "__main__":
    honey = HoneyCredentials()
    honey.deploy_all_traps()
