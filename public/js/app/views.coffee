
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
    console.log "editing"  
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

  modelEvents:
    "change": ->
      @render()

  onBeforeRender: ->
    @templateHelpers.mode = @mode
    # default mode is summary
    console.log "mode", @mode

    @loadEditView()

  onClose: ->
    #
    console.log "wow"
    @unloadEditView()

  loadEditView: ->
    ComponentSelector = App.View.ComponentSelector

    modsel = new ComponentSelector
      model: @model
    @editor = modsel

  unloadEditView: ->
    #
    console.log "close pls"
    App.core.ComponentSelectorContainer.close()

  changeMode: (mode) ->
    throw new Error("#{mode} is not a valid mode name. [Modes: 'edit', 'summary']") if mode is not "edit" or mode is not "summary"
    modeMethod = @["mode:#{mode}"]
    @mode = mode
    $('.tasks a').removeClass "active"
    $(".switch-#{mode}").addClass "active"
    modeMethod.call(@)


  "mode:edit": ->
    #
    App.core.ComponentSelectorContainer.show @editor

  "mode:summary": ->
    #
    App.core.ComponentSelectorContainer.close()


  toggleTasks: () ->
    # this functionality might not be needed..
    $('.tasks').fadeToggle(100)

  onRender: ->
    #
    $('.app-optionsbar').show()

  onBeforeClose: ->
    #
    $('.app-optionsbar').hide()


App.View.ComponentSelector = Backbone.Marionette.ItemView.extend
  model: App.Model
  template: _.template $("#ComponentSelector-template").html()
  className: "app-components-wrapper"
  events:
    "click .add-components": ->
      @toggleComponents()

  initialize: ->

  toggleComponents: ->
    $('.app-components-addmode').slideToggle "fast"
  toggleWrapper: ->
    $(".app-components-wrapper").slideToggle "fast"
    #$(".app-components-preview").slideToggle("fast")

    
  onBeforeRender: ->
    ctx = @
    App.core.ComponentSelectorContainer.onShow = ->
      ctx.toggleWrapper();

  onBeforeClose: ->
    @toggleWrapper()
    App.core.ComponentSelectorContainer.onShow = ->
      #


