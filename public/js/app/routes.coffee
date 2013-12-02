App = window.App

log = (action) ->
  console.log "--> route: #{action}"

Router = Backbone.Router.extend

  routes:
    "home"     : "appRoot"
    "m/:model"  : "modelByName"

  appRoot: (action) ->
    log action

    ProjectList = App.View.ProjectList # new keyword doesn't allow dot notation
    mainView = new ProjectList
    # show it
    App.core.AppContainer.show mainView
    return

  modelByName: (uri) ->
    log "model #{uri}"
    console.log "viewing model with the uri of \"", uri, "\"."

    # find based on the uri (which is constructed from the name)
    model = App.projects.findWhere
      "uri" : uri

    ProjectDeveloper = App.View.ProjectDeveloper # new keyword doesn't allow dot notation

    singleModelView = new ProjectDeveloper
      "model": model
    App.core.AppContainer.show singleModelView



App.router = new Router()



