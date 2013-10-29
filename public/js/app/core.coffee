
Sprout = window.Sprout or {}
App = new Backbone.Marionette.Application()

App.addRegions
  projects: ".app-container"


App.addInitializer ->

  ProjectList = Sprout.View.ProjectList
  mainView = new ProjectList

  App.projects.show mainView
  


window.Sprout.App = App

$(document).ready ->
  App.start()
  console.log Sprout



