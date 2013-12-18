
# the main application
core = new Backbone.Marionette.Application()


core.addRegions
  # the regions when selecting a project
  AppContainer: ".app-container"
  BreadCrumbs: ".app-breadcrumbs"

  ComponentSelectorContainer: ".app-modules-container"

core.addInitializer ->
  
  # show the main view listing the projects
  ProjectList = App.View.ProjectList # new keyword doesn't allow dot notation
  mainView = new ProjectList

  core.AppContainer.show mainView
  
  Backbone.history.start
    pushState: false
    root: "demo.html#"

  App.router.navigate "app/",
    trigger:true


# namespacing
App.core = core


$(document).ready ->
  
  App.core.start()





