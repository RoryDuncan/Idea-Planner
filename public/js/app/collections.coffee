App  = window.App

App.Collection = Backbone.Collection.extend
  model: App.ProjectModel
  localStorage: new Backbone.LocalStorage("ProjectList")
  callbacks:
	  success: (models) ->

	  error: (models) ->
	  	

App.projects = new App.Collection()
App.projects.fetch(App.projects, App.projects.callbacks)