
App.View = {}

App.View.Item = Backbone.Marionette.ItemView.extend
  model: App.Model
  template: _.template $("#ProjectList-item-template").html()
  tagName: 'li'
  className: ''
  events:
    "click .app-projects-list-item .project-name": () ->
      @openAsOwnView()
    "click .app-projects-list-item ul.dropdown-menu li a.open": () ->
      @openAsOwnView()
    "click .app-projects-list-item ul.dropdown-menu li a.delete": ->
      @deletePrompt()
  openAsOwnView: () ->

    clickedModel = @model

    uri = clickedModel.get("uri")
    App.router.navigate "m/#{uri}",
      trigger: true
      replace: true


  deletePrompt: ->

    ctx = @
    name = @model.get "name"

    namePrompt = (response) ->
      if response
        vex.dialog.prompt
          message: ("Type in <span class='text-danger'>#{ name }</span> to delete it forever.")
          callback: (projectname) ->
            if projectname is name
              vex.dialog.alert
                message: "<span class='text-success'>#{ name } deleted.</span>"
              ctx.deleteModel()

      else return

    # first dialogue for deleting the project
    vex.dialog.confirm
      message: "Are you sure you want to delete <span class='text-danger'>#{ name }</span>?",
      callback: (response) ->
        namePrompt(response)
  deleteModel: ->
    ctx = @
    @model.destroy
      success: ->
        console.log "Model successfully destroyed."
        ctx.render()
      error: (err) ->
        console.warn "Model was not destroyed."
        console.error err


App.View.ProjectList = Backbone.Marionette.CompositeView.extend
  tagName: "div"
  className: " "
  template: "#ProjectList-template" 
  itemView: App.View.Item
  itemViewContainer: ".app-projects-list"
  collection: App.projects
  events:
    "click .app-projects-footer > button.btn": () ->
      @createModelPrompt()
    
  createModelPrompt: () ->
    ctx = @
    name = false
    description = ""

    # first dialogue for naming the project
    vex.dialog.prompt

      message: 'Concept Name:',
      callback: (projectName) ->
        # second dialogue for model description

        if projectName

          vex.dialog.prompt

            message: (projectName + "\'s description:"),
            callback: (projectDescription) ->
              name = projectName
              description = projectDescription or ""
              ctx.addModel.call(ctx, name, description)
              return

        else return
  editModelPrompt: () ->
    #todo
  addModel: (name, description) ->
    model = new App.ProjectModel({name, description})
    @collection.add model
  collectionEvents:

    "add": (model, collection) ->

      name = model.get('name')
      console.log name + " added to collection"

      model.save {},
        success: (a) ->
          console.log "and the model was saved."
        error: (error) ->
          console.warn "and the model was not saved."
          console.error error


App.View.ProjectSummary = Backbone.Marionette.ItemView.extend
  mode: "summary"
  model: App.Model
  className: "app-project-wrapper"
  template: _.template $("#ProjectSummary-template").html()
  templateHelpers:
    isActiveMode: (mode) ->
      return "active" if mode is @mode
    mode: ""

  events:
    "click .toggletasks" : ->
      @toggleTasks()
    "click a.switch-edit:not(.active)" : ->
      @changeMode "edit"
    "click a.switch-summary:not(.active)" : ->
      @changeMode "summary"

    "click .editing:not(.selected)": (e) ->
      id = e.currentTarget.id
      @selectComponent(id)
      @showComponentOptions(id)

    "click .edit-component-menu ul li.delete": () ->
      @["component:delete"]()

    "click .edit-component-menu ul li.unselect": () ->
      # appears visually as a "close" X
      @unselectComponents()

    "keypress .watching": (e) ->
      # the functionality for saving on keypress. if they press return, save immedietly
      $(".edit-component-menu li.save-progress").text("Saving...")

      @proxySave()



  modelEvents:
    "newcomponent": ->
      console.log "triggered"
      @render()

  initialize: ->

    @proxySave = _.debounce @saveComponent, 2000

  saveComponent: ->
    # proxied version of @["component:update"](), as well as easier to reference
    @["component:update"]()

  loadEditView: ->
    ComponentSelector = App.View.ComponentSelector

    modsel = new ComponentSelector
      model: @model
    editor = modsel
    return editor

  unloadEditView: ->
    #
    @["mode:summary"]()

  renderComponents: (bulk, scope) ->
    return unless scope.model.hasComponents()
    list = scope.model.components()
    return if list.length is 0
    $("div.project-components").text("")
    #compile into a a single HTML string since DOM manipulation is costly.
    #'bulk' argument to control this.
    compiled = ""

    render = () ->
      $("div.project-components").append compiled
      compiled = " "

    compile = (component) ->

      # capitilize the first letter, since that's the scheme used for the templating
      type = component.type

      type = type.split("")
      type[0] = type[0].toUpperCase()
      type = type.join("")

      return html = _.template $("#Component-#{type}").html(), component

    if bulk is true
      
      _.forEach list, (c) ->
        html = compile c
        compiled += html

      # renders 'compiled' after it's fully compiled
      render()

    else

      _.forEach list, (c) ->
        html = compile c
        compiled += html
        # renders 'compiled' after each step of compiling,
        render()
        #then clears (to not exponentially grow)
        compiled = " "

  changeMode: (mode) ->
    throw new Error("#{mode} is not a valid mode name. [Modes: 'edit', 'summary']") if mode is not "edit" or mode is not "summary"
    modeMethod = @["mode:#{mode}"]
    @mode = mode
    $('.tasks a').removeClass "active"
    $(".switch-#{mode}").addClass "active"
    modeMethod.call(@)
    @onModeChange()

  "mode:edit": ->

    view = @loadEditView()
    App.core.ComponentSelectorContainer.show view

  "mode:summary": ->
    #
    @unselectComponents()
    App.core.ComponentSelectorContainer.close()

  updateComponentStyles: ->
    #updateComponentStyles is based on the current mode

    editStyles = ->
      $(".component").addClass('editing')

    summaryStyles = ->
      $(".component").removeClass('editing')


    if @mode is "summary"
      summaryStyles()
      # additional styling options can be added here.
    else if @mode is "edit"
      editStyles()
      # additional styling options can be added here.

  showComponentOptions: (id) ->

    $(".edit-component-menu").slideDown()
    $('.edit-component-menu').attr('id', id);

  selectComponent: (id) ->

    return if id is $('.edit-component-menu').attr('id')

    # apply classes
    @selected =
      "id": id

    $(".component").removeClass("selected")
    $(".component textarea").removeClass("watching")
    $("##{id}").addClass("selected")

    @selectComponentTypeBranching()

  selectComponentTypeBranching: () ->

    # method for visual selection and type setting for later use
    # each type should have a function corrosponding

    text = ->
      $(".selected textarea").addClass("watching")
      $(".selected textarea").focus()
      return "text"

    type = switch
      when $(".selected").is(".component-text") then text()
      when $(".selected").is(".component-header") then "header"
      when $(".selected").is(".component-resource") then "resource"
      when $(".selected").is(".component-wrapper") then "wrapper"
      when $(".selected").is(".component-image") then "image"
      when $(".selected").is(".component-code") then "code"
      when $(".selected").is(".component-diagram") then "diagram"
      else text()

    @selected.type = type

  unselectComponents: () ->
    $(".component input").removeClass("watching")
    $(".component").removeClass("selected")
    @selected = {}
    @closeComponentOptions()

  closeComponentOptions: () ->
    
    $(".edit-component-menu").hide()
    $('.edit-component-menu').attr('id', "");

  "component:delete": () ->
    ctx = @
    vex.dialog.confirm
      message: "Are you sure you want to delete this <span class='text-danger'>component</span>?",
      callback: (response) ->
        return unless response
        id = ctx.selected.id
        ctx.model.removeComponent(id)
  
  "component:update": () ->

    # get the value of text
    val = @getTypeData @selected.type
    id = @selected.id

    # then save the model
    @model.setComponent(id, val)

    #capture original color

    _.delay ->
      $(".edit-component-menu li.save-progress").text(" ")
    , 3000

  getTypeData: (type) ->
    # each type will have a different DOM structure and a variable amount
    # of inputs to get values from. This method will use the current type to discern and get
    # the necessary values
    type = @selected.type unless type

    text = ->
      v = 
        "text" : $(".watching").val()
      return v

    image = ->
      v = 
        "url" : $(".watching").val()
      return v

    resource = ->
      return

    # todo: the rest of the value-getters

    value = switch
      when type is "text" then text()
      when type is "header" then text()
      when type is "resource" then resource()
      when type is "wrapper" then "wrapper"
      when type is "image" then "image"
      when type is "code" then "code"
      when type is "diagram" then "diagram"
      else "text"

    return value
  
  toggleTasks: () ->

    # this functionality might not be needed..
    $('.tasks').fadeToggle(100)
      
  onBeforeRender: ->

    @templateHelpers.mode = @mode

  onRender: ->

    $('.app-optionsbar').show()

    #for the onAfterRender event
    afterRender = @onAfterRender
    ctx = @
    _.defer ->
      afterRender.apply(ctx)

  onAfterRender: (scope) ->

    @renderComponents true, @
    @changeMode @mode

  onModeChange: ->
    #
    @updateComponentStyles()
    
  onClose: ->
    
    $('.app-optionsbar').hide()
    @unloadEditView()


App.View.ComponentSelector = Backbone.Marionette.ItemView.extend
  model: App.Model
  template: _.template $("#ComponentSelector-template").html()
  className: "app-components-wrapper"
  $preview: $('.app-components-preview')
  events:
    "click .add-components": ->
      @toggleComponentsList()
    "click .app-components-list ul li": (e) ->

      type = e.currentTarget.classList[0]
      @createComponent type.toLowerCase()

  createComponent: (type) ->

    attributes =
      "type": type
    @model.addComponent attributes
    @model.trigger "newcomponent"

  toggleComponentsList: ->
    $('.app-components-addmode').slideToggle "fast"

  toggleWrapper: ->
    $(".app-components-wrapper").slideToggle "fast"

    
  onBeforeRender: ->
    ctx = @
    App.core.ComponentSelectorContainer.onShow = ->
      ctx.toggleWrapper();

  onRender: ->
    #console.log @model.components()

  onBeforeClose: ->
    @toggleWrapper()
    App.core.ComponentSelectorContainer.onShow = ->
      # clear onShow


