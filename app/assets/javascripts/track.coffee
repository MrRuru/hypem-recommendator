# This model is a wrapper for the api responses

class MixerApp.Track
  constructor: ({@title, @artist}) ->

  image_url: () ->
    "https://i1.sndcdn.com/artworks-000020208116-tw81u0-t120x120.jpg"