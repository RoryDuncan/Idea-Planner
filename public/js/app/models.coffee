App  = window.App

App.ComponentModel = class Component
  constructor: (attributes) ->
    _.extend @, @defaults
    _.extend @, attributes
    console.log "component model:", @
  defaults:
    #aka underscore templating fallbacks
    "type": "text"
    "text": "[empty]"
    "url": "[empty]"
    "description": "[empty]"
    "title": "[empty]"


App.ProjectModel = Backbone.Model.extend
  "defaults":
    "name": "Untitled"
    "description": ""
    "com_length": 0
    "components": []

  initialize: ->
    if @get "name"
      @nameURI()
    unless @has "com_length"
      @set "com_length", 0

  nameURI: () ->

    name = @get "name"
    `name = name.replace(/ /g, "_")`
    @set "uri", name
    uri = @get "uri"
    return uri

  components: ->
    return @get "components"

  isSorted: ->
    list = @components()
    return true if _.has list[0], "order"
    #else
    return false

  getComponent: (filter) ->

    list = @get "components"
    criteria = _.keys filter
    search = _.values filter
    result = _.find list, (element, index, list) ->
      return element[criteria] is search

    console.log result

  hasComponents: ->
    components = @get("components")
    return true unless components.length is 0
    #else
    return false

  _newComponent: (attributes) ->
    #not meant to be accessed directly
    modelId = @get "id"
    list = @get("com_length")
    list += 1
    Component = App.ComponentModel
    attributes = _.extend {"parent": modelId, "id": "com_#{list}"}, attributes
    c = new Component attributes
    return c

  addComponent: (attributes) ->
    # Create the component
    component = @_newComponent attributes
    # Increment total component 'length'
    l = (@get "com_length") + 1
    
    # add to component's list
    list = @get "components"
    list.push component

    @set "com_length", l
    @set "components", list
    @save()

  removeComponent: (id) ->
    console.warn "removing component", id
    list = @get "components"
    console.log list
    plucked = _.pluck list, "id"
    index = _.indexOf plucked, id
    list = _.without list, list[index]
    @set "components", list
    console.log "updating?"
    @save()
    


