# VULNERABLE CODE EXAMPLE - DO NOT USE IN PRODUCTION
# This file demonstrates the CVE-2016-0752 vulnerability in Action View
# 
# CVE-2016-0752: Directory Traversal Vulnerability in Action View
# Severity: HIGH (CVSS 7.5)
#
# This vulnerability allows remote attackers to read arbitrary files
# by exploiting an application's unrestricted use of the render method

class VulnerableController < ApplicationController
  # VULNERABILITY 1: Direct use of user input in render method
  # An attacker could exploit this by passing: template=../../../../etc/passwd
  def show_template
    # VULNERABLE: User-controlled input passed directly to render
    render params[:template]
    
    # Example malicious request:
    # GET /vulnerable/show_template?template=../../../../etc/passwd
    # This would attempt to read and render the /etc/passwd file
  end

  # VULNERABILITY 2: Partial rendering with user input
  def render_partial
    # VULNERABLE: User-controlled partial name
    partial_name = params[:partial]
    render partial: partial_name
    
    # Example malicious request:
    # GET /vulnerable/render_partial?partial=../../../../config/database
    # This would attempt to read the database configuration file
  end

  # VULNERABILITY 3: Dynamic template selection without validation
  def dynamic_view
    # VULNERABLE: No whitelist validation
    template_name = params[:view]
    render template: template_name
    
    # Example malicious request:
    # GET /vulnerable/dynamic_view?view=../../../../app/config/secrets
    # This would attempt to read secret credentials
  end

  # VULNERABILITY 4: File rendering with user input
  def show_file
    # VULNERABLE: Direct file path from user
    file_path = params[:file]
    render file: file_path
    
    # Example malicious request:
    # GET /vulnerable/show_file?file=/etc/shadow
    # This would attempt to read the system shadow file
  end
end

# SECURE ALTERNATIVES - How to fix these vulnerabilities:

class SecureController < ApplicationController
  # FIX 1: Use a whitelist of allowed templates
  ALLOWED_TEMPLATES = {
    'home' => 'pages/home',
    'about' => 'pages/about',
    'contact' => 'pages/contact',
    'products' => 'pages/products'
  }.freeze

  def show_template_secure
    template_key = params[:template]
    
    # Validate against whitelist
    if ALLOWED_TEMPLATES.key?(template_key)
      render ALLOWED_TEMPLATES[template_key]
    else
      # Log the attempted access for security monitoring
      Rails.logger.warn("Invalid template access attempt: #{template_key}")
      render plain: 'Invalid template', status: :bad_request
    end
  end

  # FIX 2: Use predefined partials with conditional logic
  def render_partial_secure
    partial_name = params[:partial]
    
    # Whitelist approach
    case partial_name
    when 'user_info'
      render partial: 'users/info'
    when 'user_stats'
      render partial: 'users/stats'
    when 'user_settings'
      render partial: 'users/settings'
    else
      head :not_found
    end
  end

  # FIX 3: Use action-based routing instead of dynamic templates
  def show_view_secure
    # Instead of dynamic template selection, use proper routing
    # and controller actions for each view
    render :show
  end

  # FIX 4: Never render files based on user input
  # If file downloads are needed, use send_file with whitelist
  def download_secure
    file_id = params[:id]
    
    # Fetch from database with proper authorization
    document = Document.find_by(id: file_id)
    
    if document && authorized_to_download?(document)
      # Use send_file with absolute path from secure storage
      send_file document.file_path,
                type: document.content_type,
                disposition: 'attachment',
                filename: document.filename
    else
      head :forbidden
    end
  end

  private

  def authorized_to_download?(document)
    # Implement proper authorization logic
    current_user && document.user_id == current_user.id
  end
end

# TESTING THE VULNERABILITY
# 
# To test if your application is vulnerable:
# 1. Install the vulnerable Rails version (4.2.5)
# 2. Create a controller with vulnerable code
# 3. Try accessing: /controller/action?template=../../../../etc/passwd
# 4. If you can read system files, the vulnerability exists
#
# To fix:
# 1. Update Rails to a patched version (>= 4.2.5.1, >= 4.1.14.1, >= 3.2.22.1)
# 2. Never use user input directly in render methods
# 3. Always use whitelists for allowed templates
# 4. Implement proper input validation and sanitization
# 5. Use Rails security best practices

# DETECTION
#
# Run: bundle audit check
# Expected output should show:
# Name: actionview
# Version: 4.2.5
# Advisory: CVE-2016-0752
# Criticality: High
# URL: https://groups.google.com/forum/#!topic/rubyonrails-security/335P1DcLG00
# Title: Possible Information Leak Vulnerability in Action View
