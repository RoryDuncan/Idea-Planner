App = window.App

class Breadcrumb
  set: (name) ->
    if $('.app-breadcrumbs ol.breadcrumb li.active').length is 0
      $('.app-breadcrumbs ol.breadcrumb').append "<li class='active'> </li>"
    $('.app-breadcrumbs ol.breadcrumb li.active').html name
  reset: () ->
    $('.app-breadcrumbs ol.breadcrumb').html '<li><a href="#app/">App Home</a></li>'


Router = Backbone.Router.extend

  routes:
    ":action"   : "appRoot"
    "app/"      : "appRoot"
    "m/:model"  : "modelByName"

  breadcrumb: new Breadcrumb()

  toRoot: () ->
    App.router.navigate "app"

  appRoot: (action) ->


    ProjectList = App.View.ProjectList # new keyword doesn't allow dot notation
    mainView = new ProjectList
    # show it
    App.core.AppContainer.show mainView

    @breadcrumb.reset()
    return @

  modelByName: (uri) ->

    # find based on the uri (which is constructed from the name)
    model = App.projects.findWhere
      "uri" : uri


    ProjectSummary = App.View.ProjectSummary # new keyword doesn't allow dot notation

    singleModelView = new ProjectSummary
      "model": model
    App.core.AppContainer.show singleModelView

    #breadcrumbing
    name = model.get "name"
    console.log @
    @breadcrumb.set name

    return @

App.router = new Router()



