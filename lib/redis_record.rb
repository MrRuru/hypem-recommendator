class RedisRecord
  
  attr_accessor :id
  
  def initialize(id, opts = {})
    @id = id
    @class_name = opts[:class_name] || self.class.name.underscore
  end
  
  def key
    [@class_name, @id].join(':')
  end
  
  [:sadd, :smembers, :exists, :hget, :hset].each do |redis_method|
    define_method redis_method do |*args, &block|
      redis.send(redis_method, *[key, *args], &block)
    end
  end
            
  private

  def redis
    @@redis ||= REDIS
  end


  # The fields are either in the hash or separate redis entries
  def self.has_attributes(*attributes)
    attributes.each do |attribute|
      
      define_method "#{attribute}" do
        hget(attribute)
      end
      
      define_method "#{attribute}=" do |value|
        hset(attribute, value)
      end
      
    end 
  end

  # Mass attributes assignment
  def set_attributes(attributes)
    attributes.each do |key, value|
      # Checking the method exists
      if self.respond_to? :"#{key}="
        self.send :"#{key}=", value
      else
        throw "Cannot set undefined attribute #{key} on #{self}"
      end
    end
  end

  def self.has_associated(*fields)
    fields.each do |field_id|
      
      define_method "#{field_id}" do
        return RedisRecord.new([@id, field_id].join(':'), :class_name => @class_name)
      end
      
    end
  end

end