
Sprout = window.Sprout or {}
Sprout.Templates = {}
console.clear()
console.log "%cSprout.io", "color: #60aa90; font-weight: 800; font-size:16px"
console.log "Loading Templates"

# The template 
Sprout.Templates.ListedItem = (data) ->
  template = "#item-template"
  console.log template
  return _.template template, data
###
  var data =   {site: 'NetTuts'},
      template =   'Welcome! You are at <%= site %>';
  var parsedTemplate = _.template(template,  data );
  console.log(parsedTemplate);
  // Welcome! You are at NetTuts

###