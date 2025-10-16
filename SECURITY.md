# Security Policy

## Repository Scope

This repository is a **testing repository for AWS misconfigurations** and is intended for:
- Security training and awareness
- Penetration testing practice
- Infrastructure security scanning demonstrations
- DevSecOps pipeline testing

## Technologies Used

This repository contains:
- **Terraform configuration files** (.tf)
- **CloudFormation templates** (.yaml)
- **Bash deployment scripts** (.sh)

This repository does **NOT** contain:
- Ruby or Ruby on Rails applications
- Node.js/JavaScript applications
- Python applications
- Any web application frameworks

## CVE-2016-0752 Notice

**This repository is NOT affected by CVE-2016-0752.**

CVE-2016-0752 is a directory traversal vulnerability in Action View component of Ruby on Rails. Since this repository:
1. Does not contain any Ruby or Rails code
2. Does not use Ruby on Rails as a dependency
3. Only contains AWS infrastructure configuration files

This vulnerability does not apply to this repository.

If this issue was flagged by an automated security scanner, it appears to be a false positive or misfiled report intended for a different repository (likely github.com/crowdtilt/crowdtiltopen).

## Security Considerations for This Repository

### ⚠️ Intentional Misconfigurations

This repository intentionally contains **vulnerable and misconfigured** AWS infrastructure definitions for educational purposes. These configurations should:

- **NEVER** be deployed in production environments
- Only be used in isolated testing environments
- Be destroyed immediately after testing
- Be monitored for AWS costs and security risks

### Known Intentional Vulnerabilities

The infrastructure templates in this repository intentionally include:
- Public S3 buckets without encryption
- Overly permissive security groups
- Disabled security features
- Weak access controls
- Missing monitoring and logging

These are **intentional** for testing purposes and should not be reported as security issues.

## Reporting Security Issues

If you discover an actual security issue in the **infrastructure configuration scripts** (not the intentional misconfigurations), please:

1. Do not open a public issue
2. Contact the repository maintainer directly
3. Provide details about the vulnerability
4. Allow time for assessment and remediation

## Supported Versions

This is a testing repository with intentionally vulnerable configurations. There are no "supported versions" in the traditional sense, as all versions are meant for testing only.

## Dependencies

This repository has minimal dependencies:
- AWS CLI (for CloudFormation deployments)
- Terraform (for Terraform deployments)
- Bash (for deployment scripts)

None of these dependencies are affected by CVE-2016-0752, which is specific to Ruby on Rails.
