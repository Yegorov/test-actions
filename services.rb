require "redis"
require "pg"
require "elasticsearch"

redis = Redis.new(
  host: ENV["REDIS_HOST"] || 'localhost',
  port: (ENV["REDIS_PORT"] || 6379).to_i
)

redis.set("key", "hello world")
puts redis.get("key")


pg = PG.connect(
  host: ENV["PG_HOST"] || 'localhost',
  port: (ENV["PG_PORT"] || 5432).to_i,
  user: ENV["PG_USER"] || 'postgres',
  password: ENV["PG_PASSWORD"] || 'postgres',
  dbname: ENV["PG_DBNAME"]
)

pg.exec(<<~SQL)
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
  )
SQL

pg.exec('INSERT INTO users (name) VALUES ($1)', ['Artem'])
puts pg.exec('SELECT name FROM users WHERE id = $1', [1]).getvalue(0, 0)


elastic = Elasticsearch::Client.new(
  url: ENV["ELASTIC_URL"] || 'http://localhost:9200',
)
elastic.ping
elastic.cluster.health
elastic.indices.create(index: 'my_index')
document = { name: 'elasticsearch-ruby' }
response = elastic.index(index: 'my_index', body: document)
puts elastic.get(index: 'my_index', id: response['_id'])
