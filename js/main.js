(function() {

  $(document).ready(function() {
    return require(["dojo/data/ItemFileReadStore", "dijit/tree/TreeStoreModel", "dijit/Tree"], function(ItemFileReadStore, TreeStoreModel, Tree) {
      var Router, app, store, tree, treeModel;
      Router = Backbone.Router.extend({
        routes: {
          "*actions": "defaultRoute"
        },
        defaultRoute: function(actions) {
          if (!(actions != null) || actions === "") return;
          console.log("Received request to route to: " + actions);
          return require(["dojo/_base/xhr", "dojo/dom"], function(xhr, dom) {
            var deferred;
            console.log("Loading file...");
            return deferred = dojo.xhrGet({
              url: "/" + actions + ".html",
              handleAs: "text",
              load: function(data) {
                return dom.byId("body").innerHTML = data;
              },
              error: function(error) {
                return console.log(error);
              }
            });
          });
        }
      });
      app = new Router();
      Backbone.history.start();
      store = new ItemFileReadStore({
        url: "/tree.json"
      });
      treeModel = new TreeStoreModel({
        store: store,
        childrenAttrs: ["children"]
      });
      tree = new Tree({
        model: treeModel,
        showRoot: false
      }, "tree");
      return tree.onClick = function(item) {
        if (!(item.children != null) || item.children.length === 0) {
          return location.href = "#" + item.id;
        }
      };
    });
  });

}).call(this);
