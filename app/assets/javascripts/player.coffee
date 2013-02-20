# This controller is handling user inputs

# angular.module 'playerServices', [], ($provide) ->

#   $provide.factory 'playlist', [$q], ($q) ->
#     deferred = $q.defer()
#     MixerApp.Playlist.bootstrap () ->
#       deferred.resolve this
#     deferred.promise

Mixer.App

  # Playlist handler
  .factory 'Playlist', ($rootScope, $q) ->
    {
      initialize: () ->
        # TODO : initialize/ reset / get method instead
        Mixer.Playlist.bootstrap () =>
          # Broadcast in an apply because not called in a controller
          $rootScope.$apply () =>
            @index = 0
            $rootScope.$broadcast('changeTrack')

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

  # App initialization
  .run (Playlist) ->
    console.log "initializing app"
    Playlist.initialize()

  # Playlist controller
  .controller 'PlayerCtrl', ($scope, Playlist) ->

    $scope.$on 'changeTrack', (e) ->
      $scope.currentTrack = Playlist.current()
      $scope.previousTrack = Playlist.get(-1)
      $scope.nextTrack = Playlist.get(1)

    $scope.playPreviousTrack = ->
      Playlist.previous()

    $scope.playNextTrack = ->
      Playlist.next()

    $scope.shufflePlaylist = ->
      Playlist.shuffle()

# MixerApp.PlayerCtrl.$inject ['$playlist']