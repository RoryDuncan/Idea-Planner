
App.View = {};

App.View.Item = Backbone.Marionette.ItemView.extend({
  model: App.Model,
  template: _.template($("#ProjectList-item-template").html()),
  tagName: 'li',
  className: '',
  events: {
    "click .app-projects-list-item .project-name": function() {
      return this.openAsOwnView();
    },
    "click .app-projects-list-item ul.dropdown-menu li a.open": function() {
      return this.openAsOwnView();
    },
    "click .app-projects-list-item ul.dropdown-menu li a.delete": function() {
      return this.deletePrompt();
    }
  },
  openAsOwnView: function() {
    var clickedModel, uri;
    clickedModel = this.model;
    uri = clickedModel.get("uri");
    return App.router.navigate("m/" + uri, {
      trigger: true,
      replace: true
    });
  },
  deletePrompt: function() {
    var ctx, name, namePrompt;
    ctx = this;
    name = this.model.get("name");
    namePrompt = function(response) {
      if (response) {
        return vex.dialog.prompt({
          message: "Type in <span class='text-danger'>" + name + "</span> to delete it forever.",
          callback: function(projectname) {
            if (projectname === name) {
              vex.dialog.alert({
                message: "<span class='text-success'>" + name + " deleted.</span>"
              });
              return ctx.deleteModel();
            }
          }
        });
      } else {

      }
    };
    return vex.dialog.confirm({
      message: "Are you sure you want to delete <span class='text-danger'>" + name + "</span>?",
      callback: function(response) {
        return namePrompt(response);
      }
    });
  },
  deleteModel: function() {
    var ctx;
    ctx = this;
    return this.model.destroy({
      success: function() {
        console.log("Model successfully destroyed.");
        return ctx.render();
      },
      error: function(err) {
        console.warn("Model was not destroyed.");
        return console.error(err);
      }
    });
  }
});

App.View.ProjectList = Backbone.Marionette.CompositeView.extend({
  tagName: "div",
  className: " ",
  template: "#ProjectList-template",
  itemView: App.View.Item,
  itemViewContainer: ".app-projects-list",
  collection: App.projects,
  events: {
    "click .app-projects-footer > button.btn": function() {
      return this.createModelPrompt();
    }
  },
  createModelPrompt: function() {
    var ctx, description, name;
    ctx = this;
    name = false;
    description = "";
    return vex.dialog.prompt({
      message: 'Concept Name:',
      callback: function(projectName) {
        if (projectName) {
          return vex.dialog.prompt({
            message: projectName + "\'s description:",
            callback: function(projectDescription) {
              name = projectName;
              description = projectDescription || "";
              ctx.addModel.call(ctx, name, description);
            }
          });
        } else {

        }
      }
    });
  },
  editModelPrompt: function() {
    return console.log("editing");
  },
  addModel: function(name, description) {
    var model;
    model = new App.ProjectModel({
      name: name,
      description: description
    });
    return this.collection.add(model);
  },
  collectionEvents: {
    "add": function(model, collection) {
      var name;
      name = model.get('name');
      console.log(name + " added to collection");
      return model.save({}, {
        success: function(a) {
          return console.log("and the model was saved.");
        },
        error: function(error) {
          console.warn("and the model was not saved.");
          return console.error(error);
        }
      });
    }
  }
});

App.View.ProjectSummary = Backbone.Marionette.ItemView.extend({
  mode: "summary",
  model: App.Model,
  className: "app-project-wrapper",
  template: _.template($("#ProjectSummary-template").html()),
  templateHelpers: {
    isActiveMode: function(mode) {
      if (mode === this.mode) {
        return "active";
      }
    },
    mode: ""
  },
  events: {
    "click .toggletasks": function() {
      return this.toggleTasks();
    },
    "click a.switch-edit:not(.active)": function() {
      return this.changeMode("edit");
    },
    "click a.switch-summary:not(.active)": function() {
      return this.changeMode("summary");
    }
  },
  modelEvents: {
    "change": function() {
      return this.render();
    }
  },
  onBeforeRender: function() {
    this.templateHelpers.mode = this.mode;
    console.log("mode", this.mode);
    return this.loadEditView();
  },
  onClose: function() {
    console.log("wow");
    return this.unloadEditView();
  },
  loadEditView: function() {
    var ComponentSelector, modsel;
    ComponentSelector = App.View.ComponentSelector;
    modsel = new ComponentSelector({
      model: this.model
    });
    return this.editor = modsel;
  },
  unloadEditView: function() {
    console.log("close pls");
    return App.core.ComponentSelectorContainer.close();
  },
  changeMode: function(mode) {
    var modeMethod;
    if (mode === !"edit" || mode === !"summary") {
      throw new Error("" + mode + " is not a valid mode name. [Modes: 'edit', 'summary']");
    }
    modeMethod = this["mode:" + mode];
    this.mode = mode;
    $('.tasks a').removeClass("active");
    $(".switch-" + mode).addClass("active");
    return modeMethod.call(this);
  },
  "mode:edit": function() {
    return App.core.ComponentSelectorContainer.show(this.editor);
  },
  "mode:summary": function() {
    return App.core.ComponentSelectorContainer.close();
  },
  toggleTasks: function() {
    return $('.tasks').fadeToggle(100);
  },
  onRender: function() {
    return $('.app-optionsbar').show();
  },
  onBeforeClose: function() {
    return $('.app-optionsbar').hide();
  }
});

App.View.ComponentSelector = Backbone.Marionette.ItemView.extend({
  model: App.Model,
  template: _.template($("#ComponentSelector-template").html()),
  className: "app-components-wrapper",
  events: {
    "click .add-components": function() {
      return this.toggleComponents();
    }
  },
  initialize: function() {},
  toggleComponents: function() {
    return $('.app-components-addmode').slideToggle("fast");
  },
  toggleWrapper: function() {
    return $(".app-components-wrapper").slideToggle("fast");
  },
  onBeforeRender: function() {
    var ctx;
    ctx = this;
    return App.core.ComponentSelectorContainer.onShow = function() {
      return ctx.toggleWrapper();
    };
  },
  onBeforeClose: function() {
    this.toggleWrapper();
    return App.core.ComponentSelectorContainer.onShow = function() {};
  }
});

// Generated by CoffeeScript 1.5.0-pre
