App = window.App
C = {}


class C.Base

  constructor: (options) ->
    console.log "Component Created."

  getTemplate: ->
    console.log "wow"  
  addToDOM: ->
    #


class C.TextComponent extends Base
  #



App.Components = C