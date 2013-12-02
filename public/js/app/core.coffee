
# the main application
core = new Backbone.Marionette.Application()


core.addRegions
  # the regions when selecting a project
  AppContainer: ".app-container"
  BreadCrumbs: ".app-breadcrumbs"

  ListOfProjects: ".app-projects-list"
  ListedHeader: ".app-projects-header"
  ListedFooter: ".app-projects-footer"

# init
core.addInitializer ->
  #instantiate a class
  
  ProjectList = App.View.ProjectList # new keyword doesn't allow dot notation
  mainView = new ProjectList
  # show it
  core.AppContainer.show mainView
  
  currentRoute = Backbone.history.start
    pushState: false
    root: "demo.html#"


# namespacing
App.core = core


$(document).ready ->
  
  console.log "Starting App"
  App.core.start()

  console.log "Adding test models"
  console.log window.App




