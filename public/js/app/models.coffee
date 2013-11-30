
App.ProjectModel = Backbone.Model.extend
  "defaults":
    "name": "Untitled"
    "description": ""

   nameToId: () ->

    name = @get "name"
    `name = name.replace(/ /g, "")`
    id = "#" + name

