
###
	var data =   {site: 'NetTuts'}, template =   'Welcome! You are at <%= site %>';
	var parsedTemplate = _.template(template,  data );
	console.log(parsedTemplate);
	// Welcome! You are at NetTuts

###