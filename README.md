# AWS Misconfiguration Test Repository

This repository contains intentionally misconfigured AWS infrastructure files designed for security testing, penetration testing, and educational purposes. **DO NOT USE THESE CONFIGURATIONS IN PRODUCTION ENVIRONMENTS.**

## Files Included

### Terraform Files
1. **terraform-s3-misconfigured.tf** - Misconfigured S3 bucket with public access
2. **terraform-ec2-misconfigured.tf** - Misconfigured EC2 instance with multiple security vulnerabilities

### CloudFormation Files
1. **cloudformation-rds-misconfig.yaml** - Misconfigured RDS database using CloudFormation
2. **cloudformation-sg-misconfig.yaml** - Misconfigured Security Group using CloudFormation

### Ruby on Rails Vulnerability Files
1. **Gemfile** - Vulnerable Ruby on Rails dependencies (CVE-2016-0752)
2. **CVE-2016-0752-README.md** - Documentation for the Action View directory traversal vulnerability
3. **vulnerable_controller_example.rb** - Example of vulnerable and secure controller code
4. **VULNERABILITY-TESTING.md** - Complete guide for testing and fixing CVE-2016-0752
5. **check-vulnerability.sh** - Automated script to detect the vulnerability

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

### RDS Database Misconfigurations
- ❌ Publicly accessible database instances
- ❌ Open security groups (0.0.0.0/0)
- ❌ No backup retention
- ❌ Deletion protection disabled
- ❌ Storage encryption disabled
- ❌ Public snapshots

### Application Library Vulnerabilities
- ❌ **CVE-2016-0752**: Directory Traversal in Action View (Rails 4.2.5)
  - HIGH severity (CVSS 7.5)
  - Vulnerable Ruby on Rails dependencies in Gemfile
  - Allows attackers to read arbitrary files via path traversal

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed (for .tf files)
- CloudFormation access (for .yaml files)
- Ruby and Bundler (for testing CVE-2016-0752)

### Terraform Deployment
```bash
# For S3 misconfigured bucket
terraform init
terraform plan -var-file="terraform-s3-misconfigured.tf"
terraform apply -var-file="terraform-s3-misconfigured.tf"

# For EC2 misconfigured instance
terraform init
terraform plan -var-file="terraform-ec2-misconfigured.tf"
terraform apply -var-file="terraform-ec2-misconfigured.tf"
```

### CloudFormation Deployment
```bash
# For RDS misconfigured database
aws cloudformation create-stack \
  --stack-name misconfigured-rds-stack \
  --template-body file://cloudformation-rds-misconfig.yaml

# For misconfigured security group
aws cloudformation create-stack \
  --stack-name misconfigured-sg-stack \
  --template-body file://cloudformation-sg-misconfig.yaml
```

### Testing CVE-2016-0752 Vulnerability
```bash
# Check for the vulnerability
./check-vulnerability.sh

# The script will detect the vulnerable Rails 4.2.5 version
# and provide remediation guidance

# For detailed testing instructions, see:
# - CVE-2016-0752-README.md
# - VULNERABILITY-TESTING.md
```

## Security Testing Tools

These misconfigurations can be detected by various security scanning tools:

### Infrastructure Scanning
- **AWS Config Rules**
- **AWS Security Hub**
- **AWS Inspector**
- **Scout Suite**
- **Prowler**
- **CloudSploit**
- **Checkov**
- **Terrascan**
- **tfsec**

### Dependency/Vulnerability Scanning
- **Bundler Audit** - For Ruby dependencies: `bundle audit`
- **Snyk** - For dependency vulnerabilities
- **Dependabot** - GitHub's dependency scanner
- **OWASP Dependency-Check**
- **Brakeman** - Rails security scanner

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