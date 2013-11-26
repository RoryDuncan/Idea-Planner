App = window.App;
App.Templates = {}

# factory for list-item template
App.Templates.ListedItem = (model) ->
  template = $("#app-item-template").html()
  console.log template
  compiled = _.template template, 
    name: model.name
    description: model.description

  console.log compiled
  return compiled
###
  var data =   {site: 'NetTuts'},
      template =   'Welcome! You are at <%= site %>';
  var parsedTemplate = _.template(template,  data );
  console.log(parsedTemplate);
  // Welcome! You are at NetTuts

###