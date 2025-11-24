#!/bin/bash
# Create IAM users for team members
aws iam create-user --user-name teammate1
aws iam create-user --user-name teammate2  
aws iam create-user --user-name teammate3

# Create access keys (they'll need these to login)
aws iam create-access-key --user-name teammate1
aws iam create-access-key --user-name teammate2
aws iam create-access-key --user-name teammate3

# Create a group with honeypot permissions
aws iam create-group --group-name honeypot-team

# Attach necessary policies
aws iam attach-group-policy --group-name honeypot-team --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-group-policy --group-name honeypot-team --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess

# Add users to group
aws iam add-user-to-group --group-name honeypot-team --user-name teammate1
aws iam add-user-to-group --group-name honeypot-team --user-name teammate2
aws iam add-user-to-group --group-name honeypot-team --user-name teammate3