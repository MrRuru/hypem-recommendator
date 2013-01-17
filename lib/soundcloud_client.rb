# A wrapper for the soundcloud ruby client, with custom accessors

class SoundcloudClient

  # The constants for the max page size and max offset for api queries
  MAX_PAGE_SIZE = 200
  MAX_OFFSET = 8000
  DEFAULT_LIMIT = 20


  # Fetches a user data, and its favorites
  # Arguments:
  # - limit (default 20) : the number of favorites to fetch
  def user(id, opts = {})
    user = api.get("/users/#{id}")

    limit = opts[:limit] || DEFAULT_LIMIT

    user.favorites = fetch_pages_for(limit) do |page|
      api.get("/users/#{id}/favorites", :limit => page[:limit], :offset => page[:offset])
    end

    return user
  end


  # Fetches a track, and the users who favorited it
  # Arguments:
  # - limit (default 20) : the number of favoriters to fetch
  def track(id, opts = {})
    track = api.get("/tracks/#{id}")

    limit = opts[:limit] || DEFAULT_LIMIT

    track.favorites = fetch_pages_for(limit) do |page|
      api.get("/tracks/#{id}/favoriters", :limit => page[:limit], :offset => page[:offset])
    end

    return track
  end


  # Getter for the API client, handling expirations
  # The credentials are defined in config/config.yml
  def api
    if @client && !@client.expired?
      @client
    else      
      @client = Soundcloud.new({
        :client_id     => Rails.application.config.soundcloud_credentials["client_id"],
        :client_secret => Rails.application.config.soundcloud_credentials["client_secret"],
        :username      => Rails.application.config.soundcloud_credentials["username"],
        :password      => Rails.application.config.soundcloud_credentials["password"]        
      })
    end
  end


  private

  # Generates the limit/offset pairs to get an arbitrary number of records
  def fetch_pages_for(number, &block)
    if number > MAX_OFFSET + MAX_PAGE_SIZE
      throw "Cannot fetch more than #{MAX_OFFSET + MAX_PAGE_SIZE} records from the soundcloud API"
    end

    # First generate the offset/limit pairs for the full page requests needed
    pages = (number/MAX_PAGE_SIZE).times.with_index.map{ |index|

      # Index in this scope is the request number, starting at 0
      offset = index * MAX_PAGE_SIZE
      limit = MAX_PAGE_SIZE
      {:offset => offset, :limit => limit}
    }

    # Then, if the number of records to fetch if inferior to the max page size, or if 
    # the full page requests do not sum to make the total number, there is a last request to make
    limit = number % MAX_PAGE_SIZE
    if limit > 0
      last_page = {:offset => (pages.count * MAX_PAGE_SIZE), :limit => limit}
      pages.append last_page
    end

    # Lastly, call the given block for each request and merge the results
    results = pages.map{|page| yield(page) }.flatten
    return results
  end

end