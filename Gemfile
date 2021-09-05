# frozen_string_literal: true

source 'https://rubygems.org'

gem 'aasm', '~> 5.2'
gem 'after_commit_everywhere', '~> 1.0.0'
gem 'aws-sdk-s3', '~> 1.99'
gem 'aws-sdk-sesv2', '~> 1.17'
gem 'blueprinter', '~> 0.25.3'
gem 'carrierwave', '~> 2.2'
gem 'fog-aws', '~> 3.12'
gem 'jets', '~> 3.0'
gem 'kaminari-activerecord', '~> 1.2'
gem 'oj', '~> 3.13'
gem 'pg', '~> 1.2.3'
gem 'pg_search', '~> 2.3'
gem 'rollbar', '~> 3.2'
gem 'stripe', '~> 5.34'

# seems to be a dependancy for ActionMailer::Base.add_delivery_method to work
gem 'mailgun-ruby', '~> 1.2'

# rodauth
gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.2'
gem 'rodauth', '~> 2.16'
gem 'rotp', '~> 6.2'
gem 'rqrcode', '~> 2.0'
gem 'sequel-activerecord_connection', '~> 1.2.3'

group :development, :staging do
  gem 'faker', '~> 2.18'
  gem 'mail_safe', '~> 0.3.4'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'puma'
  gem 'rack'
  gem 'rubocop', '~> 1.13'
  gem 'shotgun'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'rspec'
end

gem "sentry-ruby", "~> 4.7"
