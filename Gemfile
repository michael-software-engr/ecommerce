# ... edited by app gen, comments deleted
source 'https://rubygems.org'

# ... edited by app gen (Gemfile)
ruby '2.4.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'turbolinks', '~> 5'

group :development, :test do
  gem 'byebug', platform: :mri
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# ... core gems...
gem 'faker'
gem 'pry-rails'
gem 'figaro'
gem 'stripe'

# ... RSpec...
group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'selenium-webdriver'
end

# ... Devise
gem 'devise'

# ... Bootstrap...
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'kaminari'

# ... for getting images
gem 'httparty'

# ... for use in code for deployment to virtual server...
gem 'net-ssh'

# ... Capistrano...
group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rails-console'
  gem 'capistrano-rbenv'
end

# ... END, all
