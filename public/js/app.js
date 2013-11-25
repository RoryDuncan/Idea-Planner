

// basic site things
var $ = require('jquery-browserify'),
    jQuery = $;
var bootstrap = require('./lib/bootstrap.min.js');

//app dependencies
var underscore = require('underscore');


var Backbone =  require('backbone');
    Backbone.$ = $;
    module.exports.Backbone = Backbone;

var marionette = require('backbone.marionette');

var templates = require('./app/templates.js');
var models = require('./app/models.js');
var collections = require('./app/collections.js');
var views = require('./app/views.js');
var core = require('./app/core.js');
