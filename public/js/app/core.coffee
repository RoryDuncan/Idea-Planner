

core = new Backbone.Marionette.Application()

core.addRegions
  projects: ".app-container"

core.addInitializer ->

  ProjectList = App.View.ProjectList
  mainView = new ProjectList

  core.projects.show mainView
  
App.core = core


$(document).ready ->

  core.start()
