# Apache Tomcat Secure Deployment Configuration

This directory contains configuration files for deploying Apache Tomcat with proper security measures to mitigate **CVE-2025-24813**.

## CVE-2025-24813 Overview

**Severity:** CRITICAL (CVSS 7.5)

**Description:** A critical vulnerability in Apache Tomcat caused by path equivalence issues in file.Name (Internal Dot) handling, which may lead to:
- Remote Code Execution (RCE)
- Information disclosure
- Malicious content injection

### Affected Versions
- Apache Tomcat 11.0.0-M1 through 11.0.2
- Apache Tomcat 10.1.0-M1 through 10.1.34
- Apache Tomcat 9.0.0.M1 through 9.0.98
- Apache Tomcat 8.5.0 through 8.5.100 (End of Life)

### Secure Versions
- **Apache Tomcat 11.0.3+**
- **Apache Tomcat 10.1.35+**
- **Apache Tomcat 9.0.99+** ✅ (Used in this configuration)

## Files

### 1. tomcat-config.yaml
Configuration file specifying the secure Tomcat version (9.0.99) and security hardening settings:
- Readonly mode enabled for default servlet
- Partial PUT support disabled
- File-based session persistence disabled
- Proper JVM memory settings

### 2. cloudformation-tomcat-secure.yaml
AWS CloudFormation template for deploying a secure Tomcat instance:
- Installs Apache Tomcat 9.0.99
- Applies CVE-2025-24813 mitigation measures
- Configures systemd service
- Creates security status page
- Properly configured security groups

## Deployment

### Using CloudFormation

```bash
aws cloudformation create-stack \
  --stack-name secure-tomcat-stack \
  --template-body file://src/cloudformation-tomcat-secure.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=your-key-pair
```

### Manual Installation

```bash
# Install Java
yum install -y java-11-openjdk java-11-openjdk-devel

# Download secure Tomcat version
TOMCAT_VERSION="9.0.99"
cd /opt
wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz
ln -s apache-tomcat-${TOMCAT_VERSION} tomcat

# Create tomcat user
useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat
chown -R tomcat:tomcat /opt/apache-tomcat-${TOMCAT_VERSION}
chown -h tomcat:tomcat /opt/tomcat
```

## Security Hardening Measures

### 1. Default Servlet Configuration
Edit `/opt/tomcat/conf/web.xml` to add:
```xml
<init-param>
    <param-name>readonly</param-name>
    <param-value>true</param-value>
</init-param>
```

### 2. Disable Partial PUT
Add to `/opt/tomcat/conf/catalina.properties`:
```properties
org.apache.catalina.servlets.DefaultServlet.ALLOW_PARTIAL_PUT=false
```

### 3. Session Management
Avoid file-based session persistence in the default location. Use alternative session management:
- Database-backed sessions
- Redis/Memcached
- Distributed session managers

### 4. Additional Security Settings
- Disable directory listings
- Remove default applications
- Configure SSL/TLS properly
- Enable security manager
- Regular security updates

## Verification

After deployment, verify the Tomcat version:

```bash
# SSH into the instance
curl http://localhost:8080

# Check Tomcat version
/opt/tomcat/bin/version.sh
```

Expected output should show version `9.0.99` or higher.

## Testing

Access the status page at `http://<instance-ip>:8080` to verify:
- Tomcat version is 9.0.99
- CVE-2025-24813 is marked as PATCHED
- All mitigation measures are applied

## References

- [CVE-2025-24813 Details](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2025-24813)
- [Apache Tomcat Security](https://tomcat.apache.org/security-9.html)
- [Apache Tomcat Downloads](https://tomcat.apache.org/download-90.cgi)

## Warning

⚠️ Always ensure you are using the latest patched version of Apache Tomcat and follow security best practices for production deployments.

## Cleanup

To remove the CloudFormation stack:

```bash
aws cloudformation delete-stack --stack-name secure-tomcat-stack
```
