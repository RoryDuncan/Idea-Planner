
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
  events:
    "click .toggletasks" : ->
      @toggleTasks()
    "click a.switch-edit" : ->
      @changeMode "edit"
    "click a.switch-summary" : ->
      @changeMode "summary"
  modelEvents:
    "change": ->
      @render()

  onBeforeRender: ->
    # default mode is summary
    @mode = "summary" unless @mode
    @loadEditView()

  onBeforeClose: ->
    #
    @unloadEditView()

  loadEditView: ->
    ModuleSelector = App.View.ModuleSelector

    modsel = new ModuleSelector
      model: @model

  unloadEditView: ->
    #
    App.core.ModuleSelectorContainer.hide

  changeMode: (mode) ->
    throw new Error("#{mode} is not a valid mode name. [Modes: 'edit', 'summary']") if mode is not "edit" or mode is not "summary"
    @["mode:#{mode}"]()

  mode:edit: ->
    #
    App.core.ModuleSelectorContainer.show modsel

  mode:summary: ->
    #
    App.core.ModuleSelectorContainer.hide

  toggleTasks: () ->
    # this functionality might not be needed..
    $('.tasks').toggle()

  onRender: ->
    #
    $('.app-optionsbar').show()

  onBeforeClose: ->
    #
    $('.app-optionsbar').hide()


App.View.ModuleSelector = Backbone.Marionette.ItemView.extend
  model: App.Model
  template: _.template $("#ModuleSelector-template").html()


