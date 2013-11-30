App  = window.App

App.Collection = Backbone.Collection.extend
  model: App.ProjectModel
  localStorage: new Backbone.LocalStorage("ProjectList")
  callbacks:
	  success: (models) ->
	  	console.log "Collection Fetched."
	  	console.log models.length

	  error: (models) ->
	  	console.log "Collection fetch error."

App.projects = new App.Collection()
App.projects.fetch(App.projects, App.projects.callbacks)