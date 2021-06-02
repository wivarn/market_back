# frozen_string_literal: true

source 'https://rubygems.org'

gem 'jets', '~> 3.0'
gem 'pg', '~> 1.2.3'

# rodauth
gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.2'
gem 'rodauth', '~> 2.12'
gem 'rotp', '~> 6.2'
gem 'rqrcode', '~> 2.0'
gem 'sequel-activerecord_connection', '~> 1.2'

group :development, :staging do
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
