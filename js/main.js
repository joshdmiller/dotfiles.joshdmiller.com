(function() {

  $(document).ready(function() {
    return require(["dojo/data/ItemFileReadStore", "dijit/tree/TreeStoreModel", "dijit/Tree", "dijit/layout/ContentPane", "dojo/dom", "dojo/on", "dojo/dom-style", "dijit/registry"], function(ItemFileReadStore, TreeStoreModel, Tree, ContentPane, dom, bind, domStyle, registry) {
      var Router, app, body, store, tree, treeModel;
      Router = Backbone.Router.extend({
        routes: {
          "*actions": "defaultRoute"
        },
        defaultRoute: function(actions) {
          if (!(actions != null) || actions === "") return;
          console.log("Received request to route to: " + actions);
          return require(["dojo/_base/xhr"], function(xhr) {
            var deferred;
            console.log("Loading file...");
            return deferred = dojo.xhrGet({
              url: "/" + actions + ".html",
              handleAs: "text",
              load: function(data) {
                return registry.byId("body").set("content", data);
              },
              error: function(error) {
                console.log(error);
                return registry.byId("body").set("content", "<h4 class='error'>Unfortunately, I cannot find the document '" + actions + "'</h4>");
              }
            });
          });
        }
      });
      app = new Router();
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
      tree.onClick = function(item) {
        if (!(item.children != null) || item.children.length === 0) {
          return location.href = "#" + item.id;
        }
      };
      body = new ContentPane({}, "body");
      bind(dom.byId("collapse"), "click", function(event) {
        event.preventDefault();
        return require(["dojo/_base/fx"], function(fx) {
          if (domStyle.get(dom.byId("body"), "left") === 0) {
            fx.fadeIn({
              node: "menu"
            }).play();
            return fx.animateProperty({
              node: "body",
              properties: {
                left: 320
              }
            }).play();
          } else {
            fx.fadeOut({
              node: "menu"
            }).play();
            return fx.animateProperty({
              node: "body",
              properties: {
                left: 0
              }
            }).play();
          }
        });
      });
      return Backbone.history.start();
    });
  });

}).call(this);
