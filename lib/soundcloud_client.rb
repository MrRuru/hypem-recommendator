# A wrapper for the soundcloud ruby client, with custom accessors
# Returns hashes =>
# User : id, name, url, favorites_count
# Track : id, user_id, title, url, artwork_url, favoriters_count


class SoundcloudClient

  # The constants for the max page size and max offset for api queries
  MAX_PAGE_SIZE = 200
  MAX_OFFSET = 8000
  DEFAULT_LIMIT = 20


  # Fetches a user data, and its favorites
  # Arguments:
  # - limit (default 20) : the number of favorites to fetch
  def user(id, opts = {})
    res = api.get("/users/#{id}")
    return process_user(res)
  end


  def user_favorites(user_id, opts={})
    limit = opts[:limit] || DEFAULT_LIMIT

    return fetch_pages_for(limit) do |page|
      api.get("/users/#{user_id}/favorites", :limit => page[:limit], :offset => page[:offset]).map{|res|process_track(res)}
    end
  end

  # Fetches a track, and the users who favorited it
  # Arguments:
  # - limit (default 20) : the number of favoriters to fetch
  def track(id, opts = {})
    res = api.get("/tracks/#{id}")
    return process_track(res)
  end

  def track_favoriters(track_id, opts = {})
    limit = opts[:limit] || DEFAULT_LIMIT

    return fetch_pages_for(limit) do |page|
      api.get("/tracks/#{track_id}/favoriters", :limit => page[:limit], :offset => page[:offset]).map{|res|process_user(res)}
    end
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


  def process_user(res)
    {
      :id => res.id,
      :name => res.username,
      :url => res.permalink_url,
      :favorites_count => res.public_favorites_count
    }
  end

  def process_track(res)
    {
      :id => res.id,
      :uploader_id => res.user_id,
      :title => res.title,
      :url => res.permalink_url,
      :artwork_url => res.artwork_url,
      :favoriters_count => res.favoritings_count
    }
  end


end