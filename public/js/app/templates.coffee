App = window.App;
App.Templates = {}

# The template 
App.Templates.ListedItem = (data) ->
  template = "#item-template"
  return _.template template, data
###
  var data =   {site: 'NetTuts'},
      template =   'Welcome! You are at <%= site %>';
  var parsedTemplate = _.template(template,  data );
  console.log(parsedTemplate);
  // Welcome! You are at NetTuts

###