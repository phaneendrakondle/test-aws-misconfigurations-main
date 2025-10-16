# AWS Misconfiguration Test Repository

This repository contains intentionally misconfigured AWS infrastructure files designed for security testing, penetration testing, and educational purposes. **DO NOT USE THESE CONFIGURATIONS IN PRODUCTION ENVIRONMENTS.**

## Files Included

### Terraform Files
1. **terraform-s3-misconfigured.tf** - Misconfigured S3 bucket with public access
2. **terraform-ec2-misconfigured.tf** - Misconfigured EC2 instance with multiple security vulnerabilities
3. **terraform-tomcat-misconfigured.tf** - Apache Tomcat deployment demonstrating CVE-2025-24813 vulnerability and mitigation

### CloudFormation Files
1. **cloudformation-s3-misconfigured.yaml** - Misconfigured S3 bucket using CloudFormation
2. **cloudformation-ec2-misconfigured.yaml** - Misconfigured EC2 instance using CloudFormation

## Security Misconfigurations Included

### S3 Bucket Misconfigurations
- ❌ Public access block disabled
- ❌ Public read/write ACL permissions
- ❌ No server-side encryption
- ❌ Versioning disabled
- ❌ No access logging
- ❌ Public bucket policy allowing full access
- ❌ No lifecycle policies
- ❌ No CloudTrail monitoring

### EC2 Instance Misconfigurations
- ❌ Security groups allowing access from 0.0.0.0/0 on multiple ports (SSH, RDP, HTTP, HTTPS, databases)
- ❌ IAM roles with excessive permissions (PowerUserAccess, IAMFullAccess)
- ❌ Hardcoded credentials in user data
- ❌ Unencrypted EBS volumes
- ❌ IMDSv1 enabled (vulnerable to SSRF attacks)
- ❌ No detailed monitoring
- ❌ Public IP assignment
- ❌ Weak user passwords
- ❌ SSH password authentication enabled
- ❌ Firewall disabled
- ❌ Sudo access without password requirements
- ❌ Sensitive information exposed via web interface

### Apache Tomcat Vulnerability (CVE-2025-24813)
- ✅ Demonstrates critical Apache Tomcat vulnerability
- ✅ Shows proper mitigation using secure version (10.1.35)
- ✅ Default servlet writes disabled (readonly=true)
- ✅ Directory listings disabled
- ✅ Configuration review for partial PUT support
- **CVSS Score:** 9.8 (CRITICAL)
- **Risk:** Remote Code Execution, Information Disclosure, Malicious Content Injection

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed (for .tf files)
- CloudFormation access (for .yaml files)

### Terraform Deployment
```bash
# For S3 misconfigured bucket
cd terraform-s3-work
cp ../terraform-s3-misconfigured.tf .
terraform init
terraform plan
terraform apply

# For EC2 misconfigured instance
cd terraform-ec2-work
cp ../terraform-ec2-misconfigured.tf .
terraform init
terraform plan
terraform apply

# For Apache Tomcat with CVE-2025-24813 demonstration
cd terraform-tomcat-work
cp ../terraform-tomcat-misconfigured.tf .
terraform init
terraform plan
terraform apply
```

### CloudFormation Deployment
```bash
# For S3 misconfigured bucket
aws cloudformation create-stack \
  --stack-name misconfigured-s3-stack \
  --template-body file://cloudformation-s3-misconfigured.yaml

# For EC2 misconfigured instance
aws cloudformation create-stack \
  --stack-name misconfigured-ec2-stack \
  --template-body file://cloudformation-ec2-misconfigured.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

## Security Testing Tools

These misconfigurations can be detected by various security scanning tools:
- **AWS Config Rules**
- **AWS Security Hub**
- **AWS Inspector**
- **Scout Suite**
- **Prowler**
- **CloudSploit**
- **Checkov**
- **Terrascan**
- **tfsec**

## ⚠️ Important Warnings

1. **DO NOT deploy these in production environments**
2. **These resources will incur AWS charges**
3. **Public S3 buckets may be discovered and abused by attackers**
4. **EC2 instances with weak security groups are vulnerable to attacks**
5. **Always destroy resources after testing**: `terraform destroy` or `aws cloudformation delete-stack`
6. **Monitor your AWS bill and usage during testing**

## Educational Use Cases

- Security training and awareness
- Penetration testing practice
- Security tool validation
- Infrastructure security scanning
- DevSecOps pipeline testing
- Compliance testing

## CVE-2025-24813 - Apache Tomcat Critical Vulnerability

### Overview
This repository includes a demonstration of CVE-2025-24813, a critical vulnerability in Apache Tomcat with a CVSS score of 9.8.

### Affected Versions
- Apache Tomcat 11.0.0-M1 through 11.0.2
- Apache Tomcat 10.1.0-M1 through 10.1.34
- Apache Tomcat 9.0.0.M1 through 9.0.98
- Apache Tomcat 8.5.0 through 8.5.100 (End of Life)

### Vulnerability Details
The vulnerability allows for potential:
- **Remote Code Execution (RCE)**
- **Information Disclosure**
- **Malicious Content Injection**

Under specific conditions:
1. Writes enabled for the default servlet (disabled by default)
2. Support for partial PUT (enabled by default)
3. Security-sensitive files uploaded via partial PUT
4. Application using Tomcat's file-based session persistence with default storage location
5. Application includes a library vulnerable to deserialization attacks

### Mitigation (Implemented in terraform-tomcat-misconfigured.tf)
✅ **Upgraded to Apache Tomcat 10.1.35** (patched version)
✅ **Default servlet writes DISABLED** (readonly=true)
✅ **Directory listings DISABLED**
✅ **Partial PUT support reviewed** (not exploitable with writes disabled)

### Secure Versions
- Apache Tomcat **11.0.3** or later
- Apache Tomcat **10.1.35** or later
- Apache Tomcat **9.0.99** or later

### Testing the Deployment
After deploying the Tomcat instance:
1. Access the Tomcat server at `http://<public-ip>:8080`
2. Review the security status page showing:
   - Current Tomcat version
   - CVE-2025-24813 mitigation status
   - Security configuration details

## Cleanup

Always remember to clean up resources after testing:

```bash
# Terraform cleanup
terraform destroy

# CloudFormation cleanup
aws cloudformation delete-stack --stack-name misconfigured-s3-stack
aws cloudformation delete-stack --stack-name misconfigured-ec2-stack
```

## Contributing

If you find additional misconfigurations that should be included or improvements to existing ones, please feel free to contribute via pull requests.

## License

This repository is for educational and testing purposes only. Use at your own risk.