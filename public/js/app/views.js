
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
  editModelPrompt: function() {},
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
    },
    "click .editing:not(.selected)": function(e) {
      var id;
      id = e.currentTarget.id;
      this.selectComponent(id);
      return this.showComponentOptions(id);
    },
    "click .edit-component-menu ul li.delete": function() {
      return this["component:delete"]();
    },
    "keypress .watching": function(e) {
      console.log("--");
      $(".edit-component-menu li.save-progress").text("Saving Changes...");
      if (e.which === 13) {
        this["component:update"]();
        console.log("score!");
      }
      return this.proxySave();
    }
  },
  modelEvents: {
    "change": function() {
      return this.render();
    }
  },
  initialize: function() {
    return this.proxySave = _.debounce(this.saveComponent, 5000);
  },
  saveComponent: function() {
    console.log("proxied");
    return this["component:update"]();
  },
  loadEditView: function() {
    var ComponentSelector, editor, modsel;
    ComponentSelector = App.View.ComponentSelector;
    modsel = new ComponentSelector({
      model: this.model
    });
    editor = modsel;
    return editor;
  },
  unloadEditView: function() {
    return this["mode:summary"]();
  },
  renderComponents: function(bulk, scope) {
    var compile, compiled, list, render;
    if (!scope.model.hasComponents()) {
      return;
    }
    list = scope.model.components();
    if (list.length === 0) {
      return;
    }
    $("div.project-components").text("");
    compiled = "";
    render = function() {
      $("div.project-components").append(compiled);
      return compiled = " ";
    };
    compile = function(component) {
      var html, type;
      type = component.type;
      type = type.split("");
      type[0] = type[0].toUpperCase();
      type = type.join("");
      return html = _.template($("#Component-" + type).html(), component);
    };
    if (bulk === true) {
      _.forEach(list, function(c) {
        var html;
        html = compile(c);
        return compiled += html;
      });
      return render();
    } else {
      return _.forEach(list, function(c) {
        var html;
        html = compile(c);
        compiled += html;
        render();
        return compiled = " ";
      });
    }
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
    modeMethod.call(this);
    return this.onModeChange();
  },
  "mode:edit": function() {
    var view;
    view = this.loadEditView();
    return App.core.ComponentSelectorContainer.show(view);
  },
  "mode:summary": function() {
    this.unselectComponents();
    return App.core.ComponentSelectorContainer.close();
  },
  updateComponentStyles: function() {
    var editStyles, summaryStyles;
    editStyles = function() {
      return $(".component").addClass('editing');
    };
    summaryStyles = function() {
      return $(".component").removeClass('editing');
    };
    if (this.mode === "summary") {
      return summaryStyles();
    } else if (this.mode === "edit") {
      return editStyles();
    }
  },
  showComponentOptions: function(id) {
    $(".edit-component-menu").slideDown();
    return $('.edit-component-menu').attr('id', id);
  },
  selectComponent: function(id) {
    if (id === $('.edit-component-menu').attr('id')) {
      return;
    }
    this.currentlySelectedComponent = id;
    $(".component").removeClass("selected");
    $(".component textarea").removeClass("watching");
    $("#" + id).addClass("selected");
    return this.selectComponentTypeBranching();
  },
  selectComponentTypeBranching: function() {
    var text, type;
    text = function() {
      $(".selected textarea").addClass("watching");
      $(".selected textarea").focus();
      return "text";
    };
    type = (function() {
      switch (false) {
        case !$(".selected").is(".component-text"):
          return text();
        case !$(".selected").is(".component-header"):
          return "header";
        case !$(".selected").is(".component-resource"):
          return "resource";
        case !$(".selected").is(".component-wrapper"):
          return "wrapper";
        case !$(".selected").is(".component-image"):
          return "image";
        case !$(".selected").is(".component-code"):
          return "code";
        case !$(".selected").is(".component-diagram"):
          return "diagram";
        default:
          return "header";
      }
    })();
    return console.log("Selected a", type);
  },
  unselectComponents: function() {
    $(".component input").removeClass("watching");
    $(".component").removeClass("selected");
    this.currentlySelectedComponent = null;
    return this.closeComponentOptions();
  },
  closeComponentOptions: function() {
    $(".edit-component-menu").hide();
    return $('.edit-component-menu').attr('id', "");
  },
  "component:delete": function() {
    var ctx;
    ctx = this;
    return vex.dialog.confirm({
      message: "Are you sure you want to delete this <span class='text-danger'>component</span>?",
      callback: function(response) {
        var id;
        if (!response) {
          return;
        }
        id = ctx.currentlySelectedComponent;
        return ctx.model.removeComponent(id);
      }
    });
  },
  "component:update": function() {
    console.log("saving component", this.currentlySelectedComponent);
    this.model;
    $(".edit-component-menu li.save-progress").text("Saved");
    return _.delay(function() {
      return $(".edit-component-menu li.save-progress").text("Save All");
    }, 2000);
  },
  toggleTasks: function() {
    return $('.tasks').fadeToggle(100);
  },
  onBeforeRender: function() {
    return this.templateHelpers.mode = this.mode;
  },
  onRender: function() {
    var afterRender, ctx;
    $('.app-optionsbar').show();
    afterRender = this.onAfterRender;
    ctx = this;
    return _.defer(function() {
      return afterRender.apply(ctx);
    });
  },
  onAfterRender: function(scope) {
    this.renderComponents(true, this);
    return this.changeMode(this.mode);
  },
  onModeChange: function() {
    return this.updateComponentStyles();
  },
  onClose: function() {
    $('.app-optionsbar').hide();
    return this.unloadEditView();
  }
});

App.View.ComponentSelector = Backbone.Marionette.ItemView.extend({
  model: App.Model,
  template: _.template($("#ComponentSelector-template").html()),
  className: "app-components-wrapper",
  $preview: $('.app-components-preview'),
  events: {
    "click .add-components": function() {
      return this.toggleComponentsList();
    },
    "click .app-components-list ul li": function(e) {
      var type;
      type = e.currentTarget.classList[0];
      return this.createComponent(type.toLowerCase());
    }
  },
  createComponent: function(type) {
    var attributes;
    attributes = {
      "type": type
    };
    return this.model.addComponent(attributes);
  },
  saveComponents: function() {
    return console.log("wow");
  },
  toggleComponentsList: function() {
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
  onRender: function() {},
  onBeforeClose: function() {
    this.toggleWrapper();
    return App.core.ComponentSelectorContainer.onShow = function() {};
  }
});

// Generated by CoffeeScript 1.5.0-pre
