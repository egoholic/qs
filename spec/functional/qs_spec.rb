require "bundler"

Bundler.setup :test

require "yaml"
require "json"
require "pg"
require "redis"

RSpec.describe Qs, functional: true do
  let! :pg_connection_params do
    path = File.expand_path("../configs/postgresql_connection_config.yaml", __FILE__)
    file = File.open path

    YAML.load(file)["postgresql"]["connection_params"]
  end

  let :redis_connection_params do
    path = File.expand_path("../configs/redis_connection_config.yaml", __FILE__)
    file = File.open path

    YAML.load(file)["redis"]["connection_params"]
  end

  let :redis do
    Qs.resource :redis, {host: "localhost"}, ->(connection_params) do
      Redis.new connection_params
    end
  end

  let :postgresql do
    Qs.resource :postgresql, {user: "postgres", host: "localhost"}, ->(connection_params) do
      PG.connect connection_params
    end
  end

  let :tasks do
    Qs.domain :tasks
  end

  let :find_all do
    Qs.query :find_all, Qs.params_validator(limit: {type: Fixnum}), ->(resources, params) do
      resources[:postgresql].connection.exec("SELECT * FROM tasks LIMIT $1;", [params[:limit]]).to_a
    end
  end

  let :find_by_title do
    Qs.query :find_by_title, Qs.params_validator(title: {type: String, length_in: 3..64}), ->(resources, params) do
      title = params[:title]
      
      result = resources[:redis].connection.hgetall(title)

      if result.empty?
        result = resources[:postgresql].connection.exec("SELECT * FROM tasks WHERE title = $1 LIMIT 1;", [title])[0]
        resources[:redis].connection.mapped_hmset title, result
      end

      result
    end
  end

  let(:querier) { Qs.querier :main }

  before :suite do
    c = PG.connect pg_connection_params

    c.exec <<-SQL
CREATE TABLE IF NOT EXISTS tasks (
  title       VARCHAR(64) PRIMARY KEY,
  description TEXT        NOT NULL
);
    SQL

    c.close
  end

  before do
    tasks.resources.add postgresql.name, postgresql
    tasks.resources.add redis.name, redis

    tasks.queries.add find_all.name, find_all
    tasks.queries.add find_by_title.name, find_by_title

    querier.domains.add tasks.name, tasks

    c = Redis.new redis_connection_params
    c.flushall

    c = PG.connect pg_connection_params

    c.exec <<-SQL
TRUNCATE TABLE tasks;
INSERT INTO tasks (title, description)
  VALUES ('Task 1', 'Description for task 1.'),
         ('Task 2', 'Description for task 2.'),
         ('Task 3', 'Description for task 3.');
    SQL

    c.close
  end

  after do
    c = PG.connect pg_connection_params

    c.exec("TRUNCATE TABLE tasks;")
    c.close
  end

  describe "querier" do
    subject { querier }

    describe "tasks domain" do
      describe "queries" do
        describe "find_all" do
          it "returns correct data from PostgreSQL" do
            expect(subject.exec :tasks, :find_all, {limit: 2}).to eq([
              {
                "title"       => "Task 1",
                "description" => "Description for task 1."
              },

              {
                "title"       => "Task 2",
                "description" => "Description for task 2."
              }
            ])
          end
        end

        describe "find_by_title" do
          context "when data is not cached" do
            it "returns correct data from PostgreSQL" do
              expect(subject.exec :tasks, :find_by_title, title: "Task 1").to eq({
                "title"       => "Task 1",
                "description" => "Description for task 1."
              })
            end

            it "caches data in Redis" do
              expect { subject.exec(:tasks, :find_by_title, title: "Task 1") }
                .to change { redis.connection.hgetall("Task 1") }.from({}).to({
                  "title"       => "Task 1",
                  "description" => "Description for task 1."
                })
            end
          end

          context "when data cached" do
            before {
              subject.exec :tasks, :find_by_title, title: "Task 1"
              postgresql.connection.exec "DELETE FROM tasks where title = 'Task 1';"
            }

            it "returns correct data from Redis" do
              expect(subject.exec(:tasks, :find_by_title, title: "Task 1")).to eq({
                "title"       => "Task 1",
                "description" => "Description for task 1."
              })
            end
          end
        end
      end
    end
  end
end
