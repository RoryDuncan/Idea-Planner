
App.View = {}

App.View.Item = Backbone.Marionette.ItemView.extend
  template: "#itemView-template"
  tagName: 'div'
  className: ''


App.View.ProjectList = Backbone.Marionette.CompositeView.extend
  tagName: "div"
  id: "app-main"
  className: " "
  template: "#ProjectList-template" 
  itemView: App.View.Item

