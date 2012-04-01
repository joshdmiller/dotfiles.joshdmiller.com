(function() {

  require(["dojo/data/ItemFileReadStore", "dijit/tree/TreeStoreModel", "dijit/Tree", "dijit/layout/ContentPane", "dojo/dom", "dojo/on", "dojo/dom-style", "dijit/registry", "citeplasm/Router", "dojo/domReady!"], function(ItemFileReadStore, TreeStoreModel, Tree, ContentPane, dom, bind, domStyle, registry, Router) {
    var body, router, store, tree, treeModel;
    console.log("Creating router...");
    router = new Router([
      {
        path: /^\/.*$/,
        handler: function(params, route) {
          var actions;
          actions = route.hash;
          if (!(actions != null) || actions === "") return;
          console.log("Received request to route to: " + actions);
          registry.byId("body").set("content", "<div class='loadingOverlay'></div>");
          return require(["dojo/_base/xhr"], function(xhr) {
            var deferred, url;
            url = "/dotfiles" + actions;
            console.log("Loading file " + url + ".html...");
            return deferred = dojo.xhrGet({
              url: "" + url + ".html",
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
      }, {
        path: "/",
        defaultRoute: true,
        handler: function() {
          return router.go("/introduction");
        }
      }
    ], {
      noInitialRoute: false
    });
    console.log("Loading interface...");
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
        return location.href = "#/" + item.id;
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
    router.init();
    return domStyle.set(dom.byId("preloader"), "display", "none");
  });

}).call(this);
