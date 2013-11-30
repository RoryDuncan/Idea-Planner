
App.View = {}

App.View.Item = Backbone.Marionette.ItemView.extend
  model: App.Model
  template: _.template $("#app-item-template").html()
  tagName: 'li'
  className: ''
  events:
    "click .app-projects-list-item": () ->
      console.log "Todo: Open single Model"


App.View.ProjectList = Backbone.Marionette.CompositeView.extend
  tagName: "div"
  id: "app-main"
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




