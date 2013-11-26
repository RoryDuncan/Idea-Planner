var Application = function() {
	this.Author = "Rory Duncan";
	this.Github = "https://github.com/RoryDuncan"
}

// basic site things
var $ = require('jquery-browserify'),
    jQuery = $;
var bootstrap = require('./lib/bootstrap.min.js');

// app dependencies
var _ = require('underscore');
	window._ = _;
var Backbone =  require('backbone');
    Backbone.$ = $;
    window.Backbone = Backbone;
// modules.exports did not and is not working for module.exports = Backbone;


	Backbone.LocalStorage = require("backbone.localstorage");

var marionette = require('backbone.marionette');

window.App = new Application;
var templates = require('./app/templates.js');
var models = require('./app/models.js');
var collections = require('./app/collections.js');
var views = require('./app/views.js');
var core = require('./app/core.js');

