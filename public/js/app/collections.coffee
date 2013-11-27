App  = window.App

App.Collection = Backbone.Collection.extend
  model: App.Model
  localStorage: new Backbone.LocalStorage("Projects")
  callbacks:
	  success: (models) ->
	  	console.log "Collection Fetched."

	  error: (models) ->
	  	console.log "Collection fetch error."

App.projects = new App.Collection()
App.projects.sync("read", App.projects, App.projects.callbacks)