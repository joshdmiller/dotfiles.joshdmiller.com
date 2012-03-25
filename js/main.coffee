$(document).ready () ->

    require ["dojo/data/ItemFileReadStore", 
             "dijit/tree/TreeStoreModel", 
             "dijit/Tree", 
             "dijit/layout/ContentPane",
             "dojo/dom", 
             "dojo/on", 
             "dojo/dom-style", 
             "dijit/registry"
    ], (ItemFileReadStore, TreeStoreModel, Tree, ContentPane, dom, bind, domStyle, registry) ->
        Router = Backbone.Router.extend
            routes:
                "*actions"       : "defaultRoute"

            defaultRoute: (actions) ->
                return if !actions? or actions is ""
                console.log "Received request to route to: #{actions}"
                require ["dojo/_base/xhr"], (xhr) ->
                    console.log "Loading file..."
                    deferred = dojo.xhrGet
                        url: "/#{actions}.html"
                        handleAs: "text"
                        load: (data) ->
                            registry.byId("body").set "content", data
                        error: (error) ->
                            console.log error
                            registry.byId("body").set "content", "<h4 class='error'>Unfortunately, I cannot find the document '"+actions+"'</h4>"

        # Create a new instance of our application.
        app = new Router()
        
        # Create the store and Model for our tree menu
        store = new ItemFileReadStore
            url: "/tree.json"
        treeModel = new TreeStoreModel
            store: store
            childrenAttrs: ["children"]

        # Create the new dijit/Tree
        tree = new Tree
            model: treeModel
            showRoot: false
        , "tree"

        # Handle the click events. When the clicked item has no children, change to that URL.
        tree.onClick = (item) ->
            if !item.children? or item.children.length is 0
                location.href = "#" + item.id

        # Create the content pane that will store all of the body documenets.
        body = new ContentPane {}, "body"

        # Collapse and Uncollapse the tree menu when a#collapse is clicked.
        bind dom.byId("collapse"), "click", (event) ->
            event.preventDefault()
            require ["dojo/_base/fx"], (fx) ->
                if domStyle.get(dom.byId("body"), "left") is 0
                    fx.fadeIn
                        node: "menu"
                    .play()

                    fx.animateProperty
                        node: "body"
                        properties:
                            left: 320
                    .play()
                else
                    fx.fadeOut
                        node: "menu"
                    .play()

                    fx.animateProperty
                        node: "body"
                        properties:
                            left: 0
                    .play()

        # Launch the router and go to the provided route
        Backbone.history.start()

