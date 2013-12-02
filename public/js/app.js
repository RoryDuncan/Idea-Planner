
var Application = function() {
	this.Author = "Rory Duncan";
	this.Github = "https://github.com/RoryDuncan"
}

/* Site Dependencies */
var $ = require('jquery-browserify'),
    jQuery = $;
    window.jQuery = jQuery;
    


// todo: remove modals section from bootstrap to cut down on size
var bootstrap = require('./lib/bootstrap.min.js');

// vex for beautiful dialogues (see http://github.hubspot.com/vex/)
var vex = require('./lib/vex.js');
	vex.dialog = require('./lib/vex.dialog.js');
	window.vex.defaultOptions.className = 'vex-theme-wireframe';
/* Application Dependencies */
var _ = require('underscore');
	window._ = _;
var Backbone = require('backbone');
    Backbone.$ = $;
    Backbone.LocalStorage = require("backbone.localstorage");
    window.Backbone = Backbone; //module.exports isn't working for me it seems, #GlobalNamespaceChaos
    

var marionette = require('backbone.marionette');

window.App = new Application();
var templates = require('./app/templates.js');
var models = require('./app/models.js');
var collections = require('./app/collections.js');
var views = require('./app/views.js');
var routes = require('./app/routes.js');
var core = require('./app/core.js');

