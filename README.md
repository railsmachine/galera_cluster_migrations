# GaleraClusterMigrations

GaleraClusterMigrations helps to alleviate some of the woes of executing Rails
database migrations with [Galera Cluster](http://galeracluster.com). Galera
Cluster provides two options for executing DDL (Data Definition Language)
statements: Total Order Isolation (TOI) and Rolling Schema Upgrade (RSU).
Each has its advantages and disadvantages, but once your database reaches a
certain size you must start considering RSU for modifications on large tables.

## Total Order Isolation (TOI)

TOI is the default DDL replication method in Galera Cluster. When the master
node receives a DDL statement it sends out a replication event before starting
the DDL processing. Every node in the cluster will processs the replicated DDL
statement during the same "slot" in the cluster transaction stream. This
ensures that every node in the cluster will process the schema change at the
same time.

With this guarantee you don't have to worry about schema backwards
compatibility, but there are some drawbacks. The strict commit order will make
every transaction wait until DDL processing is over. Meaning that altering a
table will block any queries that are trying to access that table. For a table
with a large number or rows, altering a table or adding an index could take
several minutes, or longer, during which the table cannot be queried.

## Rolling Schema Upgrade (RSU)

To allow the rest of the cluster to continue operating at full speed Galera
Cluster offers the RSU method for DDL statements. During RSU the node executing
a DDL statement is desynchronized from replication for the duration of the DDL
processing. All incoming replication events are buffered and the node will not
send replication events to the other nodes in the cluster. When DDL processing
is over, the node will automatically join back into the cluster and process
missed transactions from the buffer. Once the node has rejoined and caught up
with the rest of the cluster, you must repeat the DDL statements on the next
node in the cluster.

The RSU method will not slow down the cluster; all other transactions can
complete at full speed on the two synced nodes. However, there are caveats that
must be considered when using RSU. The entire session will be processed with
RSU (i.e. any insert statements will not be replicated to the other nodes).
Second, upgrading the schema on all nodes is a manual operation. As a result
the schema changes must be backward compatible since queries will be processed
against and replicated to upgraded and non-upgraded nodes.

## Installation

Add this line to your application's Gemfile:

    gem 'galera_cluster_migrations'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install galera_cluster_migrations

## Usage

GaleraClusterMigrations contains 3 components:

1. An ActiveSupport concern that should be included in your database migrations,
2. A rake task for performing database migrations on a single cluster node,
3. And a capistrano task for remotely executing the rake task.

### To Use RSU within a Migration

The `GaleraClusterMigrations` ActiveSupport concern contains methods to enable
RSU and TOI. The `#with_rsu` method is the recommended way to run migrations
with RSU. It accepts a block and will enable RSU for the duration of the block
and then re-enable TOI.

The first step is to include the `GaleraClusterMigrations` module in your
migration and use the `#with_rsu` method to enable RSU for DDL statements
specified inside a block:

    # db/migrate/20140710000000_add_foo_to_bars.rb
    class AddFooToBars < ActiveRecord::Migration
      include GaleraClusterMigrations

      def change
        with_rsu do
          add_column :bars, :foo, :integer, default: 0
        end
      end
    end

The `add_column` statement above will be executed in RSU mode when the migration
is run.

If you are using Capistrano, require `galera_cluster_migrations/capistrano` in
your `config/deploy.rb` file and use the `galera:migrate` task to run the
migration on each node:

    # config/deploy.rb
    ...
    require 'galera_cluster_migrations/capistrano'
    ...

You should also disable the default `deploy:migrate` task from running during
a deploy. Once the migration has been deployed to your cluster, execute the
migration on each node checking that the entire cluster is in the *Synced*
state before proceeding with the next node. Be sure to use the `HOSTFILTER`
option to specify a single node to migrate at a time.

    $ cap production galera:migrate HOSTFILTER=db1.example.com
    # check that db1 has rejoined the cluster and is Synced
    $ cap production galera:migrate HOSTFILTER=db2.example.com
    # check that db2 has rejoined the cluster and is Synced
    $ cap production galera:migrate HOSTFILTER=db3.example.com
    # check that db3 has rejoined the cluster and is Synced

You have now successfully upgraded the schema on every database node using
RSU! During this time the two nodes not processing the migration will be
available to process queries at full speed.

For migrations that you want to run using TOI there is nothing special required
to migrate the database. Write the database migration as you normally would and
migrate the database with `cap production deploy:migrate`.

## Contributing

1. Fork it ( https://github.com/railsmachine/galera_cluster_migrations/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
