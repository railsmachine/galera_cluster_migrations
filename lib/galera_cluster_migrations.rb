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
      enable_rsu
      yield
      disable_wsrep_on
    ensure
      enable_toi
    end

    def enable_toi
      say "Setting wsrep_OSU_method to TOI"
      unless [:development, :test].include?(Rails.env)
        execute "SET GLOBAL wsrep_OSU_method=TOI"
      end
    end

    def disable_wsrep_on
      say "Setting wsrep_on to OFF"
      unless [:development, :test].include?(Rails.env)
        execute "SET wsrep_on=OFF"
      end
    end
  end
end
