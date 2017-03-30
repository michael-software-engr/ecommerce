# ... edited by app gen (Capistrano)

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

# Load the SCM plugin appropriate to your project:
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# ... not sure about why rails, rails/assets and rails/migrations
#     It's what was used in prev project so we're going with it.
#     Original generated Capfile generated...
#       require "capistrano/rails/assets"
#       require "capistrano/rails/migrations"
require 'capistrano/rails'
# require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/console'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |rk_file| import rk_file }
