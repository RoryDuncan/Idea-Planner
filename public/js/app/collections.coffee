App  = window.App

App.Collection = Backbone.Collection.extend
  model: App.Model
  localStorage: new Backbone.LocalStorage("Projects")

App.projects = new App.Collection()