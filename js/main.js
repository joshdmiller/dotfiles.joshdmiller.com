(function() {

  $(document).ready(function() {
    return require(["dojo/data/ItemFileReadStore", "dijit/tree/TreeStoreModel", "dijit/Tree"], function(ItemFileReadStore, TreeStoreModel, Tree) {
      var Router, app, store, tree, treeModel;
      Router = Backbone.Router.extend({
        routes: {
          "*actions": "defaultRoute"
        },
        defaultRoute: function(actions) {
          this.updateMenu();
          return console.log("Received request to route to: " + actions);
        },
        updateMenu: function() {
          var defaultUrl, url;
          defaultUrl = "#/home";
          url = document.location.hash;
          if (!(url != null) || url === "") url = defaultUrl;
          if (url.split("/").length > 2) url = "#/" + url.split("/")[1];
          if (!(this.routes[url.split("#")[1]] != null)) url = defaultUrl;
          $("#header .nav > li").removeClass("active");
          return $('#header .nav a[href="' + url + '"]').parent().addClass("active");
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
