# CVEs That Do NOT Affect This Repository

This document lists Common Vulnerabilities and Exposures (CVEs) that have been incorrectly flagged against this repository. This repository contains only AWS infrastructure configuration files (Terraform and CloudFormation) and does not include application code.

## CVE-2016-0752 - Ruby on Rails Action View Directory Traversal

**Status**: NOT AFFECTED

**Reason**: This repository does not contain any Ruby or Ruby on Rails code. CVE-2016-0752 affects the Action View component in Ruby on Rails versions prior to:
- 3.2.22.1
- 4.1.14.1
- 4.2.5.1
- 5.0.0.beta1.1

**Technologies in this repository**:
- Terraform configuration files
- AWS CloudFormation templates
- Bash scripts

**No Ruby/Rails dependencies exist in this repository.**

## How This CVE Was Incorrectly Flagged

This CVE may have been flagged due to:
1. Automated security scanning tools incorrectly identifying this repository
2. The CVE being intended for a different repository (github.com/crowdtilt/crowdtiltopen)
3. Metadata or naming confusion in security scanning systems

## Repository Technology Stack

For clarity, this repository uses:
- **Infrastructure as Code**: Terraform (.tf files), CloudFormation (.yaml files)
- **Scripting**: Bash shell scripts
- **No application frameworks**: No Ruby, Rails, Node.js, Python web frameworks, etc.

## Verification

To verify this repository does not contain Ruby/Rails code:

```bash
# Search for Ruby files
find . -name "*.rb" -o -name "Gemfile*" -o -name "*.gemspec"
# Result: No files found

# Search for Rails-specific files
find . -name "config.ru" -o -name "application.rb"
# Result: No files found
```

## References

- CVE-2016-0752 Details: https://nvd.nist.gov/vuln/detail/CVE-2016-0752
- Repository Security Policy: [SECURITY.md](SECURITY.md)
- Repository README: [README.md](README.md)
