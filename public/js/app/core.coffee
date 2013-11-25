
# the main application
core = new Backbone.Marionette.Application()


core.addRegions
  # the regions when selecting a project
  AppContainer: ".app-container"
  ListOfProjects: ".app-projects-list"
  ListedHeader: ".app-projects-header"
  ListedFooter: ".app-projects-footer"

# init
core.addInitializer ->
  #instantiate a class
  ProjectList = App.View.ProjectList
  mainView = new ProjectList
  # show it
  core.AppContainer.show mainView

# namespacing
App.core = core


$(document).ready ->

  console.log window.App

  
  App.core.start()
