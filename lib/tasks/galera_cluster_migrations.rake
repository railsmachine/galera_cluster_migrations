namespace :galera do
  namespace :db do
    desc "Alters the database settings for the specified task"
    task :alter, [:task] => [:environment] do |t, args|
      configuration = ActiveRecord::Base.configurations[Rails.env]
      configuration['host'] = 'localhost'
      ActiveRecord::Base.establish_connection(configuration)
      Rake::Task[args.task].invoke
    end
  end
end
