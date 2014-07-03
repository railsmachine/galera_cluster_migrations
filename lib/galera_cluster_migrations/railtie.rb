require 'galera_cluster_migrations'
require 'rails'

module GaleraClusterMigrations
  class RailTie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../../tasks/galera_cluster_migrations.rake', __FILE__)
    end
  end
end
