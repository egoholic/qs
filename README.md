# Qs

Qs is a lightweight and DB-agnostic library for querying.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qs

## Usage

Qs contains a number of entities that you will use for defining query set.


#### Resource

```Resource``` is an abstraction over DB drivers/adapters/interfaces/etc. You may think about resource as of lambda the execution of which returns connection to the particular DBMS.

```ruby
postgresql = Qs.resource :postgresql, {user: "postgres", host: "localhost"}, ->(connection_params) do
  PG.connect(connection_params)
end

redis = Qs.resource :redis, {user: "redis", host: "localhost", db: "tasks"}, ->(connection_params) do
  Redis.new connection_params
end
```


### Query

```Query``` is a high-level abstraction. You may think about Query as of lambda with some additional features.

```ruby
find_by_id = Qs.query :find_by_id, Qs.params_validator(id: {type: Fixnum}), ->(resources, params) do
  resources[:redis].connection.get params[:id] ||
  resources[:postgresql].connection.exec("SELECT * FROM tasks WHERE %{id} LIMIT 1;", params)
end

query.exec resources, id: 1
```


### ParamsValidator

To describe query parameters you need to use another entity - ```ParamsValidator``` (see above).


### Domain

```Domain``` is an aggregate for queries and resources. You may store queries related to some particular domain together using ```Domain``.

```ruby
tasks = Qs.domain :tasks
tasks.queries.add find_by_id.name, find_by_id
tasks.resources.add postgresql.name, postgresql
tasks.resources.add redis.name, redis

tasks.exec :find_by_id, id: 1
```

### Querier

```Querier``` is a aggregate for a number of domains. Use one querier per application. For example, if you use SCS architecture you need to create a querier per each self-contained system.

```ruby
querier = Qs.querier :main
querier.domains.add tasks.name, tasks

querier.exec :tasks, :find_by_id, id: 1
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/qs/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
