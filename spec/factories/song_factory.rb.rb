# # Define song stubs at different times of its lifecycle
# FactoryGirl.define do
# 
#   # Alphanumerical random generator
#   # http://h3manth.com/content/generate-unique-random-alphanumeric-strings-ruby
#   sequence(:random_string) {|n| rand(36 ** 5 - 1).to_s(36).rjust(5, "0") }
# 
#   factory :song do
#     id { generate :random_string }
#     initialize_with { new(id) }
#   end
#   
#   factory :synced_song, :class => Song do
#     song
#     artist { generate :random_string }
#     title { generate :random_string }
#     synced_at { Time.now }
#   end
#   
#   factory :outdated_sync_song, :class => Song do
#     synced_song
#     synced_at { Time.now - Song.EXPIRE_AFTER - 1 }
#   end
# 
#   factory :crawled_song, :class => Song do
#     synced_song
#     crawled_at { Time.now }
#     crawl_depth { Song.DEFAULT_CRAWL_DEPTH }    
#   end
#   
# end
