# This controller is handling user inputs

# angular.module 'playerServices', [], ($provide) ->

#   $provide.factory 'playlist', [$q], ($q) ->
#     deferred = $q.defer()
#     MixerApp.Playlist.bootstrap () ->
#       deferred.resolve this
#     deferred.promise

Mixer.App

  # Playlist handler
  .factory 'Playlist', ($rootScope) ->
    {
      initialize: () ->
        # TODO : initialize/ reset / get method instead
        Mixer.Playlist.bootstrap () =>
          # Broadcast in an apply because not called in a controller
          @index = 0
          $rootScope.$broadcast('initializePlaylist')

      shuffle: () ->
        Mixer.Playlist.bootstrap () =>
          $rootScope.$apply () =>
            # Shuffling goes here instead of index change
            @index = 1
            $rootScope.$broadcast('changeTrack')

      current: () ->
        @get(0)

      get: (delta) ->
        index = @index + delta
        track = Mixer.Playlist.get(index)
        track

      previous: () ->
        @index = @index - 1
        $rootScope.$broadcast('changeTrack')

      next: () ->
        @index = @index + 1
        $rootScope.$broadcast('changeTrack')
    }


  # Actual souncloud player handler
  .factory 'SoundcloudPlayer', ($rootScope) ->
    {
      sound: null

      initialize: () ->
        SC.initialize {
          client_id: 'f8afa16ecbaaa97fde4b046b9ba331eb'
        }

      # Cancel current playback and start new one
      play: (track_id) ->
        console.log 'playing track', track_id
        @sound && @sound.unload()
        SC.stream ("/tracks/" + track_id), (sound) =>
          @sound = sound
          @sound.play()

      resume: () ->
        console.log 'resuming playback'
        @sound && @sound.play()

      pause: () ->
        console.log 'pausing playback'
        @sound && @sound.pause()

    }


  # App initialization
  .run (Playlist, SoundcloudPlayer) ->
    console.log "initializing app"
    Playlist.initialize()
    SoundcloudPlayer.initialize()


  # Playlist controller
  .controller 'PlayerCtrl', ($scope, Playlist, SoundcloudPlayer) ->

    $scope.playing = 'stopped'

    $scope.$on 'initializePlaylist', (e) =>
      $scope.$apply () ->
        $scope.updateTracks()


    $scope.$on 'changeTrack', (e) ->
      $scope.updateTracks()
      SoundcloudPlayer.play $scope.currentTrack.id


    $scope.$watch 'playing', (new_status, old_status) ->
      # Playing
      if new_status == 'playing'
        # When was stopped : play the track
        if old_status == 'stopped'
          console.log 'new playback'
          SoundcloudPlayer.play $scope.currentTrack.id
        else
          console.log 'resuming playback'
          SoundcloudPlayer.resume()

      # Paused
      else
        console.log 'pausing playback'
        SoundcloudPlayer.pause()


    $scope.playPreviousTrack = ->
      Playlist.previous()

    $scope.playNextTrack = ->
      Playlist.next()

    $scope.togglePlay = ->
      if $scope.playing == 'stopped' || $scope.playing == 'paused'
        $scope.playing = 'playing'
      else
        $scope.playing = 'paused'

    $scope.like = (track) ->
      alert('liking ' + track)

    $scope.shufflePlaylist = ->
      Playlist.shuffle()

    $scope.updateTracks = ->
      $scope.currentTrack = Playlist.current()
      $scope.previousTrack = Playlist.get(-1)
      $scope.nextTrack = Playlist.get(1)

# MixerApp.PlayerCtrl.$inject ['$playlist']