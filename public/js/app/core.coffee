Sprout = window.Sprout or {}
App = new Backbone.Marionette.Application()

App.addRegions
  "projects": ".app-projects"



window.Sprout.App = App
App.start()
console.log "%c ← Sprout.io →", "color: #60aa90; font-weight: 800;"
console.log Sprout

