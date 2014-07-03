require 'capistrano'

module GaleraClusterMigrations
  class Capistrano
    TASKS = [
      'galera:migrate'
    ]

    def self.load_into(capistrano_config)
      capistrano_config.load do

        namespace :galera do
          desc <<-DESC
            Run the migrate rake task. By default, it runs this in most recently \
            deployed version of the app. However, you can specify a different release \
            via the migrate_target variable, which must be one of :latest (for the \
            default behavior), or :current (for the release indicated by the \
            `current' symlink). Strings will work for those values instead of symbols, \
            too. You can also specify additional environment variables to pass to rake \
            via the migrate_env variable. Finally, you can specify the full path to the \
            rake executable by setting the rake variable. The defaults are:

              set :rake,           "rake"
              set :rails_env,      "production"
              set :migrate_env,    ""
              set :migrate_target, :latest
          DESC
          task :migrate, :roles => :db do
            rake = fetch(:rake, "rake")
            rails_env = fetch(:rails_env, "production")
            migrate_env = fetch(:migrate_env, "")
            migrate_target = fetch(:migrate_target, :latest)

            directory = case migrate_target.to_sym
              when :current then current_path
              when :latest  then latest_release
              else raise ArgumentError, "unknown migration target #{migrate_target.inspect}"
              end

            run "cd #{directory} && #{rake} RAILS_ENV=#{rails_env} #{migrate_env} galera:db:alter[db:migrate]"
          end
        end
      end
    end

  end
end

if Capistrano::Configuration.instance
  GaleraClusterMigrations::Capistrano.load_into(Capistrano::Configuration.instance)
end
