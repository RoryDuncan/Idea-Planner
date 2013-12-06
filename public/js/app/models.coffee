
App.ProjectModel = Backbone.Model.extend
  "defaults":
    "name": "Untitled"
    "description": ""
    "components": []

   nameURI: () ->

    name = @get "name"
    `name = name.replace(/ /g, "_")`
    @set "uri", name
    uri = @get "uri"
    return uri

  initialize: ->
    if @get "name"
      @nameURI()

