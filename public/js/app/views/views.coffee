Sprout  = window.Sprout or {}
Sprout.View = {}

Sprout.View.Item = Backbone.Marionette.ItemView.extend
  template: "#itemView-template"
  tagName: 'div'
  className: ''


Sprout.View.ProjectList = Backbone.Marionette.CompositeView.extend
  tagName: "div"
  id: "app-main"
  className: " "
  template: "#ProjectList-template" 
  itemView: Sprout.View.Item

