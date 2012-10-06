RecommandationApp = 
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: ->
    new ExampleApp.Routers.Tasks()
    Backbone.history.start()
