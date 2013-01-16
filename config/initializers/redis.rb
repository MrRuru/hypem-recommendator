# Load the redis.yml configuration file 
redis_config = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env].symbolize_keys

# Connect to Redis using the redis_config host and port 
if redis_config 
  REDIS = Redis.new(redis_config)
end