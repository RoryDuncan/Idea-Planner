
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
  events: {
    "click .toggletasks": function() {
      return this.toggleTasks();
    },
    "click a.switch-edit": function() {
      return this.changeMode("edit");
    },
    "click a.switch-summary": function() {
      return this.changeMode("summary");
    }
  },
  modelEvents: {
    "change": function() {
      return this.render();
    }
  },
  onBeforeRender: function() {
    if (!this.mode) {
      this.mode = "summary";
    }
    return this.loadEditView();
  },
  onBeforeClose: function() {
    return this.unloadEditView();
  },
  loadEditView: function() {
    var ModuleSelector, modsel;
    ModuleSelector = App.View.ModuleSelector;
    return modsel = new ModuleSelector({
      model: this.model
    });
  },
  unloadEditView: function() {
    return App.core.ModuleSelectorContainer.hide;
  },
  changeMode: function(mode) {
    if (mode === !"edit" || mode === !"summary") {
      throw new Error("" + mode + " is not a valid mode name. [Modes: 'edit', 'summary']");
    }
    return this["mode:" + mode]();
  },
  mode: {
    edit: function() {
      return App.core.ModuleSelectorContainer.show(modsel);
    }
  },
  mode: {
    summary: function() {
      return App.core.ModuleSelectorContainer.hide;
    }
  },
  toggleTasks: function() {
    return $('.tasks').toggle();
  },
  onRender: function() {
    return $('.app-optionsbar').show();
  },
  onBeforeClose: function() {
    return $('.app-optionsbar').hide();
  }
});

App.View.ModuleSelector = Backbone.Marionette.ItemView.extend({
  model: App.Model,
  template: _.template($("#ModuleSelector-template").html())
});

// Generated by CoffeeScript 1.5.0-pre
