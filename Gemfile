# frozen_string_literal: true

source 'https://rubygems.org'

gem 'jets', git: 'git@github.com:wivarn/jets.git', branch: 'master'
# gem 'jets', path: '../jets'
gem 'pg', '~> 1.2.3'

gem 'bcrypt', '~> 3.1'
gem 'jwt', '~> 2.2'
gem 'rodauth', '~> 2.12'
gem 'sequel-activerecord_connection', '~> 1.2'

gem 'letter_opener', '~> 1.7'

# development and test groups are not bundled as part of the deployment
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'puma'
  gem 'rack'
  gem 'rubocop', '~> 1.13'
  gem 'shotgun'
end

group :test do
  gem 'capybara'
  gem 'launchy'
  gem 'rspec' # rspec test group only or we get the "irb: warn: can't alias context from irb_context warning" when starting jets console
end
