module Syncable

  def self.extended(base)
    base.instance_eval do 
      has_attributes :synced_at
    end
  end

  def is_syncable_with(opts)
    syncer = opts[:syncer]
    expiration = opts[:expiration]

    define_method :synced? do
      !!synced_at && ( Time.parse(synced_at) > (Time.now - expiration))
    end

    define_method :sync! do |opts = {}|
      Resque.enqueue(syncer, {"id" => self.id}.merge(opts))
    end
  end

end