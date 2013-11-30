
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

testData = (numberOfModels) ->
  console.warn "Model Creation"
  modelList = []
  for x in [0..(numberOfModels-1)]
    m = new App.ProjectModel({
      name: "Model " + x
      description: "just wow " + x
    })
    modelList.push m


  App.projects.add modelList
# namespacing
App.core = core


$(document).ready ->
  

  #App.projects.reset()
  
  console.log "Starting App"
  App.core.start()

  console.log "Adding test models"
  #testData(4)
  console.log window.App
  console.log(App.projects)



