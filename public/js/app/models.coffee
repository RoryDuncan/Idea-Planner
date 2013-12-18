App  = window.App

App.ComponentModel = class Component
  constructor: (attributes) ->
    _.extend @, @defaults
    _.extend @, attributes
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

  # Methods for interacting with components #


  components: ->
    # simple alias
    return @get "components"

  isSorted: ->
    list = @components()
    return true if _.has list[0], "order"
    #else
    return false

  getIndexOfComponent: (id) ->
    list = @get "components"
    #shrink into a simple array (plucked)
    plucked = _.pluck list, "id"
    index = _.indexOf plucked, id
    return index

  getComponent: (filter) ->

    list = @get "components"
    criteria = _.keys(filter)[0]
    search = _.values(filter)[0]

    result = _.find list, (element, index, list) ->

      return element[criteria] is search


    return result

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

    list = @get "components"
    plucked = _.pluck list, "id"
    index = _.indexOf plucked, id
    list = _.without list, list[index]
    @set "components", list

    @save()
  
  setComponent: (id, newData) ->

    list = @get "components"
    oldComponent = @getComponent({"id":id})

    return unless oldComponent

    #merge old component and new data, using newData as source
    c = _.extend oldComponent, newData


    index = @getIndexOfComponent id
    #update list with new extended component
    list[index] = c

    #update the model
    @set "components", list
    callbax = 
      error: (e) ->
        console.warn "Component did not save:", e
        $(".edit-component-menu li.save-progress").text("Oops! Did Not Save!")
      success: ->
        $(".edit-component-menu li.save-progress").text("Saved.")

    @save({}, callbax)







