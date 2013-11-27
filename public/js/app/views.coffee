
App.View = {}

App.View.Item = Backbone.Marionette.ItemView.extend
  model: App.Model
  template: _.template $("#app-item-template").html()
  tagName: 'li'
  className: ''


App.View.ProjectList = Backbone.Marionette.CompositeView.extend
  tagName: "div"
  id: "app-main"
  className: " "
  template: "#ProjectList-template" 
  itemView: App.View.Item
  itemViewContainer: ".app-projects-list"
  collection: App.projects
  events:
    "click .app-projects-footer > button.btn": ->
      callback = (val) ->
        console.log val
      # first dialogue for naming the project
      vex.dialog.prompt
        message: 'Concept Name:',
        callback: (value) ->
          callback value
          # second dialogue for model description
          if value
            
            vex.dialog.prompt
              message: (value + "\'s description:"),
              callback: callback 


  collectionEvents:

    "add": (model, collection) ->

      name = model.get('name')
      console.log name + " added to collection"




