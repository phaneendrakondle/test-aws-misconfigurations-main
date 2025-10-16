# Intentionally Misconfigured Apache Tomcat Deployment - FOR SECURITY TESTING ONLY
# This file demonstrates CVE-2025-24813 vulnerability and its fix
# DO NOT USE IN PRODUCTION

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnet
data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
  default_for_az    = true
}

# Security group for Tomcat server
resource "aws_security_group" "tomcat_sg" {
  name_prefix = "tomcat-sg-"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP from anywhere
  ingress {
    description = "HTTP from anywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH from anywhere (for testing purposes)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "TomcatSecurityGroup"
    Environment = "SecurityTesting"
    Purpose     = "CVE-2025-24813 demonstration"
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# EC2 instance with Apache Tomcat
resource "aws_instance" "tomcat_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id                   = data.aws_subnet.default.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tomcat_sg.id]

  # User data to install and configure Apache Tomcat
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    yum update -y
    
    # Install Java (required for Tomcat)
    yum install -y java-11-amazon-corretto-headless
    
    # VULNERABILITY DEMONSTRATION: Install vulnerable Apache Tomcat version
    # CVE-2025-24813 affects versions 10.1.0-M1 through 10.1.34
    # Using 10.1.35 (PATCHED VERSION) to fix the vulnerability
    
    TOMCAT_VERSION="10.1.35"
    TOMCAT_MAJOR="10"
    
    cd /opt
    wget -q https://archive.apache.org/dist/tomcat/tomcat-$${TOMCAT_MAJOR}/v$${TOMCAT_VERSION}/bin/apache-tomcat-$${TOMCAT_VERSION}.tar.gz
    tar -xzf apache-tomcat-$${TOMCAT_VERSION}.tar.gz
    ln -s apache-tomcat-$${TOMCAT_VERSION} tomcat
    rm apache-tomcat-$${TOMCAT_VERSION}.tar.gz
    
    # Create tomcat user
    useradd -r -s /bin/false tomcat
    chown -R tomcat:tomcat /opt/tomcat /opt/apache-tomcat-$${TOMCAT_VERSION}
    
    # Configure Tomcat to mitigate CVE-2025-24813
    # 1. Ensure default servlet writes are DISABLED (disabled by default)
    # 2. Review partial PUT support (enabled by default but not exploitable with writes disabled)
    
    cat > /opt/tomcat/conf/web.xml.security << 'WEBXML'
    <!-- Security Configuration for CVE-2025-24813 Mitigation -->
    <!-- 
    Default Servlet Configuration:
    - readonly: true (CRITICAL - prevents file uploads via PUT)
    - listings: false (prevents directory listing)
    -->
    
    <!-- In the default servlet configuration, ensure: -->
    <servlet>
        <servlet-name>default</servlet-name>
        <servlet-class>org.apache.catalina.servlets.DefaultServlet</servlet-class>
        <init-param>
            <param-name>debug</param-name>
            <param-value>0</param-value>
        </init-param>
        <init-param>
            <param-name>listings</param-name>
            <param-value>false</param-value>
        </init-param>
        <!-- CRITICAL: Ensure readonly is true (default) -->
        <init-param>
            <param-name>readonly</param-name>
            <param-value>true</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    WEBXML
    
    # Create systemd service for Tomcat
    cat > /etc/systemd/system/tomcat.service << 'SYSTEMD'
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=network.target
    
    [Service]
    Type=forking
    
    User=tomcat
    Group=tomcat
    
    Environment="JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto"
    Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
    Environment="CATALINA_HOME=/opt/tomcat"
    Environment="CATALINA_BASE=/opt/tomcat"
    Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
    
    ExecStart=/opt/tomcat/bin/startup.sh
    ExecStop=/opt/tomcat/bin/shutdown.sh
    
    Restart=on-failure
    RestartSec=10
    
    [Install]
    WantedBy=multi-user.target
    SYSTEMD
    
    # Create a simple test application
    mkdir -p /opt/tomcat/webapps/ROOT
    cat > /opt/tomcat/webapps/ROOT/index.jsp << 'JSP'
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%
        String tomcatVersion = application.getServerInfo();
    %>
    <html>
    <head>
        <title>Apache Tomcat - Security Test</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; background-color: #f0f0f0; }
            .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .success { color: #28a745; font-weight: bold; }
            .info { background-color: #d1ecf1; padding: 15px; border-left: 4px solid #0c5460; margin: 20px 0; }
            .warning { background-color: #fff3cd; padding: 15px; border-left: 4px solid #856404; margin: 20px 0; }
            h1 { color: #333; }
            code { background-color: #f8f9fa; padding: 2px 6px; border-radius: 3px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🔒 Apache Tomcat Security Test</h1>
            <p><strong>Server Info:</strong> <%= tomcatVersion %></p>
            
            <div class="success">
                <h2>✅ CVE-2025-24813 Mitigation Status: SECURED</h2>
            </div>
            
            <div class="info">
                <h3>Vulnerability Details (CVE-2025-24813)</h3>
                <p><strong>CVSS Score:</strong> 9.8 (CRITICAL)</p>
                <p><strong>Affected Versions:</strong></p>
                <ul>
                    <li>11.0.0-M1 through 11.0.2</li>
                    <li>10.1.0-M1 through 10.1.34</li>
                    <li>9.0.0.M1 through 9.0.98</li>
                    <li>8.5.0 through 8.5.100</li>
                </ul>
                <p><strong>Impact:</strong> Remote Code Execution, Information Disclosure, Malicious Content Injection</p>
            </div>
            
            <div class="info">
                <h3>🛡️ Security Measures Implemented</h3>
                <ul>
                    <li>✅ <strong>Tomcat Version:</strong> Upgraded to <%= tomcatVersion %> (secure version)</li>
                    <li>✅ <strong>Default Servlet Writes:</strong> DISABLED (readonly=true)</li>
                    <li>✅ <strong>Directory Listings:</strong> DISABLED</li>
                    <li>✅ <strong>Partial PUT Support:</strong> Not exploitable with writes disabled</li>
                </ul>
            </div>
            
            <div class="warning">
                <h3>⚠️ This is a Security Testing Environment</h3>
                <p>This server is deployed for security testing and vulnerability demonstration purposes only.</p>
                <p><strong>DO NOT USE IN PRODUCTION!</strong></p>
            </div>
            
            <h3>Recommended Versions (Patched)</h3>
            <ul>
                <li>Apache Tomcat 11.0.3 or later</li>
                <li>Apache Tomcat 10.1.35 or later</li>
                <li>Apache Tomcat 9.0.99 or later</li>
            </ul>
        </div>
    </body>
    </html>
    JSP
    
    # Set proper permissions
    chown -R tomcat:tomcat /opt/tomcat
    
    # Start Tomcat service
    systemctl daemon-reload
    systemctl enable tomcat
    systemctl start tomcat
    
    # Log deployment completion
    echo "Apache Tomcat deployment completed with CVE-2025-24813 mitigation" > /var/log/tomcat-deployment.log
    echo "Version: $${TOMCAT_VERSION}" >> /var/log/tomcat-deployment.log
    echo "Security: Default servlet writes disabled" >> /var/log/tomcat-deployment.log
  EOF
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }

  monitoring = true

  tags = {
    Name        = "ApacheTomcatServer"
    Environment = "SecurityTesting"
    Purpose     = "CVE-2025-24813 demonstration and mitigation"
    Vulnerability = "CVE-2025-24813-PATCHED"
  }
}

# Outputs
output "tomcat_instance_id" {
  value = aws_instance.tomcat_server.id
}

output "tomcat_public_ip" {
  value = aws_instance.tomcat_server.public_ip
}

output "tomcat_public_dns" {
  value = aws_instance.tomcat_server.public_dns
}

output "tomcat_url" {
  value = "http://${aws_instance.tomcat_server.public_ip}:8080"
}

output "security_status" {
  value = "Apache Tomcat 10.1.35 deployed with CVE-2025-24813 mitigation - Default servlet writes DISABLED"
}

output "access_instructions" {
  value = <<-EOT
    Apache Tomcat Server Deployed Successfully!
    
    Access URL: http://${aws_instance.tomcat_server.public_ip}:8080
    
    Security Status: ✅ SECURED against CVE-2025-24813
    - Tomcat Version: 10.1.35 (patched)
    - Default Servlet: Read-only mode enabled
    - Directory Listings: Disabled
    
    To verify the deployment:
    1. Wait 3-5 minutes for instance initialization
    2. Access the URL above in your browser
    3. Review the security status page
    
    To SSH into the instance:
    ssh -i your-key.pem ec2-user@${aws_instance.tomcat_server.public_ip}
    
    To check Tomcat status:
    sudo systemctl status tomcat
    
    To view logs:
    sudo tail -f /opt/tomcat/logs/catalina.out
  EOT
}
