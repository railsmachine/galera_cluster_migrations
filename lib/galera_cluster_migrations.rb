require "galera_cluster_migrations/version"
require 'active_support/concern'

module GaleraClusterMigrations
  extend ActiveSupport::Concern

  require 'galera_cluster_migrations/railtie' if defined?(Rails)

  included do
    def enable_rsu
      say "Setting wsrep_OSU_method to RSU"
      unless [:development, :test].include?(Rails.env)
        execute "SET GLOBAL wsrep_OSU_method=RSU"
      end
    end

    def with_rsu
      unless [:development, :test].include?(Rails.env)
        execute "SET GLOBAL wsrep_OSU_method=RSU"
        execute "SET GLOBAL wsrep_desync=ON"
        execute "SET wsrep_on=OFF"
      end

      yield

      unless [:development, :test].include?(Rails.env)
        execute "SET GLOBAL wsrep_desync=OFF"
        execute "SET GLOBAL wsrep_OSU_method=TOI"
      end
    end

    def enable_toi
      say "Setting wsrep_OSU_method to TOI"
      unless [:development, :test].include?(Rails.env)
        execute "SET GLOBAL wsrep_OSU_method=TOI"
      end
    end
  end
end
