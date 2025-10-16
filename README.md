# AWS Misconfiguration Test Repository

This repository contains intentionally misconfigured AWS infrastructure files designed for security testing, penetration testing, and educational purposes. **DO NOT USE THESE CONFIGURATIONS IN PRODUCTION ENVIRONMENTS.**

## Files Included

### Terraform Files
1. **terraform-s3-misconfigured.tf** - Misconfigured S3 bucket with public access
2. **terraform-ec2-misconfigured.tf** - Misconfigured EC2 instance with multiple security vulnerabilities

### CloudFormation Files
1. **cloudformation-sg-misconfig.yaml** - Misconfigured security group using CloudFormation
2. **cloudformation-rds-misconfig.yaml** - Misconfigured RDS instance using CloudFormation

### Application Security Vulnerabilities
1. **rails-directory-traversal-cve-2016-0752.rb** - CVE-2016-0752: Directory traversal vulnerability in Ruby on Rails Action View
2. **CVE-2016-0752-DOCUMENTATION.md** - Comprehensive documentation on the vulnerability, exploitation, and mitigation
3. **rails-directory-traversal-cve-2016-0752_spec.rb** - Test suite for validating the security fix

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

### Application Security Vulnerabilities
#### CVE-2016-0752: Directory Traversal in Action View
- ❌ **Severity**: HIGH (CVSS 7.5)
- ❌ **Type**: Path Traversal / Directory Traversal
- ❌ **Impact**: Allows attackers to read arbitrary files on the server
- ❌ **Vulnerable Pattern**: Using `render` method with unsanitized user input
- ❌ **Attack Vector**: `../../../etc/passwd` in URL parameters
- ✅ **Mitigation**: Input validation, whitelist approach, path sanitization
- 📚 **Documentation**: See `CVE-2016-0752-DOCUMENTATION.md` for detailed information
- 🧪 **Tests**: Run `rails-directory-traversal-cve-2016-0752_spec.rb` to validate the fix

## Usage

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed (for .tf files)
- CloudFormation access (for .yaml files)

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

### Application Security Testing Tools
For testing the Rails directory traversal vulnerability (CVE-2016-0752):
- **Brakeman** - Static analysis security scanner for Rails applications
- **bundler-audit** - Checks for vulnerable versions of gems
- **OWASP ZAP** - Web application security scanner
- **Burp Suite** - Web vulnerability scanner
- **RSpec** - Run the included test suite to validate fixes

```bash
# Install Brakeman
gem install brakeman

# Scan for security vulnerabilities
brakeman -A -q

# Run the test suite
rspec rails-directory-traversal-cve-2016-0752_spec.rb
```

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
- Application security testing (OWASP Top 10)
- Web application vulnerability assessment
- Secure coding practices training
- CVE research and mitigation strategies

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