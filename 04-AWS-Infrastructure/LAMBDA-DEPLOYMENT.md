# 🚀 Lambda Enrichment Pipeline Deployment

## Architecture
```
Cowrie JSON → SNS Topic → Lambda Enrichment → Discord + S3
```

## Benefits
- ✅ Decoupled enrichment from alerting
- ✅ API outages don't block alerts
- ✅ Async processing with retry logic
- ✅ Immutable S3 archival
- ✅ MITRE ATT&CK auto-mapping
- ✅ Cost: ~$0.20/million events

---

## Step 1: Create S3 Bucket

```bash
aws s3 mb s3://honeypot-enriched-logs
aws s3api put-bucket-versioning \
  --bucket honeypot-enriched-logs \
  --versioning-configuration Status=Enabled

# Enable Object Lock for immutability
aws s3api put-object-lock-configuration \
  --bucket honeypot-enriched-logs \
  --object-lock-configuration \
  'ObjectLockEnabled=Enabled,Rule={DefaultRetention={Mode=COMPLIANCE,Days=365}}'
```

---

## Step 2: Create SNS Topic

```bash
aws sns create-topic --name honeypot-events

# Get topic ARN
aws sns list-topics | grep honeypot-events
```

---

## Step 3: Create Lambda Function

### Create IAM Role
```bash
aws iam create-role \
  --role-name HoneypotEnrichmentRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach policies
aws iam attach-role-policy \
  --role-name HoneypotEnrichmentRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam put-role-policy \
  --role-name HoneypotEnrichmentRole \
  --policy-name S3WritePolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["s3:PutObject"],
      "Resource": "arn:aws:s3:::honeypot-enriched-logs/*"
    }]
  }'
```

### Deploy Lambda
```bash
# Package function
cd 04-AWS-Infrastructure
zip lambda_function.zip lambda_enrichment_handler.py

# Create function
aws lambda create-function \
  --function-name HoneypotEnrichment \
  --runtime python3.10 \
  --role arn:aws:iam::ACCOUNT_ID:role/HoneypotEnrichmentRole \
  --handler lambda_enrichment_handler.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --timeout 30 \
  --memory-size 256 \
  --environment Variables='{
    DISCORD_WEBHOOK=https://discord.com/api/webhooks/YOUR_WEBHOOK,
    S3_BUCKET=honeypot-enriched-logs,
    GREYNOISE_KEY=t6UcPKF1RR1hn6eRuOsqc7X5FU8uM6ldUdcRUWA6uldMgsTysCQnWhmk2SIZN3C1
  }'
```

---

## Step 4: Connect SNS to Lambda

```bash
# Subscribe Lambda to SNS
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT_ID:honeypot-events \
  --protocol lambda \
  --notification-endpoint arn:aws:lambda:us-east-1:ACCOUNT_ID:function:HoneypotEnrichment

# Grant SNS permission to invoke Lambda
aws lambda add-permission \
  --function-name HoneypotEnrichment \
  --statement-id AllowSNSInvoke \
  --action lambda:InvokeFunction \
  --principal sns.amazonaws.com \
  --source-arn arn:aws:sns:us-east-1:ACCOUNT_ID:honeypot-events
```

---

## Step 5: Configure Cowrie to Send to SNS

### Install boto3 on EC2
```bash
sudo pip3 install boto3
```

### Create SNS Publisher Script
```python
# /opt/cowrie/sns_publisher.py
import boto3
import json

sns = boto3.client('sns', region_name='us-east-1')
TOPIC_ARN = 'arn:aws:sns:us-east-1:ACCOUNT_ID:honeypot-events'

def publish_event(event):
    sns.publish(
        TopicArn=TOPIC_ARN,
        Message=json.dumps(event)
    )
```

### Add to Cowrie Output Plugin
```bash
# Edit /opt/cowrie/etc/cowrie.cfg
[output_sns]
enabled = true
topic_arn = arn:aws:sns:us-east-1:ACCOUNT_ID:honeypot-events
```

---

## Step 6: Test the Pipeline

```bash
# Test Lambda directly
aws lambda invoke \
  --function-name HoneypotEnrichment \
  --payload '{
    "Records": [{
      "Sns": {
        "Message": "{\"eventid\":\"cowrie.command.input\",\"input\":\"whoami\",\"src_ip\":\"1.2.3.4\",\"session\":\"test123\"}"
      }
    }]
  }' \
  response.json

# Check response
cat response.json

# Check S3
aws s3 ls s3://honeypot-enriched-logs/events/ --recursive

# Check CloudWatch Logs
aws logs tail /aws/lambda/HoneypotEnrichment --follow
```

---

## Monitoring

### CloudWatch Metrics
- Invocations
- Duration
- Errors
- Throttles

### CloudWatch Alarms
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name HoneypotEnrichmentErrors \
  --alarm-description "Alert on Lambda errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=FunctionName,Value=HoneypotEnrichment
```

---

## Cost Estimate

| Component | Usage | Cost/Month |
|-----------|-------|------------|
| Lambda | 1M invocations | $0.20 |
| SNS | 1M messages | $0.50 |
| S3 Storage | 10GB | $0.23 |
| S3 Requests | 1M PUT | $0.005 |
| **Total** | | **~$1.00/month** |

---

## Security Checklist

- ✅ Lambda has minimal IAM permissions (S3 write only)
- ✅ S3 bucket has Object Lock enabled
- ✅ Discord webhook has no admin rights
- ✅ API keys stored in environment variables
- ✅ CloudWatch logging enabled
- ✅ VPC isolation (optional)

---

## Troubleshooting

### Lambda not receiving events
```bash
# Check SNS subscription
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT_ID:honeypot-events

# Check Lambda permissions
aws lambda get-policy --function-name HoneypotEnrichment
```

### Discord alerts not sending
```bash
# Check Lambda logs
aws logs tail /aws/lambda/HoneypotEnrichment --follow

# Test webhook manually
curl -X POST YOUR_DISCORD_WEBHOOK \
  -H "Content-Type: application/json" \
  -d '{"content":"Test from Lambda"}'
```

### S3 uploads failing
```bash
# Check IAM permissions
aws iam get-role-policy \
  --role-name HoneypotEnrichmentRole \
  --policy-name S3WritePolicy

# Check bucket exists
aws s3 ls s3://honeypot-enriched-logs/
```

---

**Status:** Ready to Deploy  
**Estimated Setup Time:** 30 minutes  
**Maintenance:** Minimal (serverless)