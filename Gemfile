# Intentionally Vulnerable Ruby on Rails Dependencies
# FOR SECURITY TESTING ONLY - DO NOT USE IN PRODUCTION
# 
# This Gemfile contains a vulnerable version of Action View to demonstrate
# CVE-2016-0752: Directory Traversal Vulnerability in Action View
#
# Vulnerable versions:
# - All versions before 3.2.22.1
# - 4.0.x and 4.1.x before 4.1.14.1
# - 4.2.x before 4.2.5.1

source 'https://rubygems.org'

# VULNERABILITY: CVE-2016-0752 - Directory Traversal in Action View
# Using a vulnerable version of Rails (4.2.5) which contains vulnerable Action View
# This allows remote attackers to read arbitrary files via a .. (dot dot) in a pathname
gem 'rails', '4.2.5'

# The vulnerable actionview gem is included as a dependency of rails
# Explicitly showing it here for clarity
gem 'actionview', '4.2.5'

# Other Rails components (all vulnerable versions for demonstration)
gem 'actionpack', '4.2.5'
gem 'activerecord', '4.2.5'
gem 'actionmailer', '4.2.5'
gem 'activesupport', '4.2.5'
gem 'activejob', '4.2.5'

# Required dependencies
gem 'sqlite3', '~> 1.3.6'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

group :development, :test do
  gem 'byebug'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end
