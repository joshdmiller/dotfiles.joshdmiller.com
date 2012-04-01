require ["dojo/data/ItemFileReadStore", 
         "dijit/tree/TreeStoreModel", 
         "dijit/Tree", 
         "dijit/layout/ContentPane",
         "dojo/dom", 
         "dojo/on", 
         "dojo/dom-style", 
         "dijit/registry",
         "citeplasm/Router",
         "dojo/domReady!"
], (ItemFileReadStore, TreeStoreModel, Tree, ContentPane, dom, bind, domStyle, registry, Router) ->
    console.log "Creating router..."
    router = new Router [
            path: /^\/.*$/
            handler: (params, route) ->
                actions = route.hash
                return if !actions? or actions is ""
                console.log "Received request to route to: #{actions}"

                # Before we load the page, we create the loading overlay.
                registry.byId("body").set "content", "<div class='loadingOverlay'></div>"

                # Time to load the page.
                require ["dojo/_base/xhr"], (xhr) ->
                    url = "/dotfiles" + actions
                    console.log "Loading file #{url}.html..."
                    deferred = dojo.xhrGet
                        url: "#{url}.html"
                        handleAs: "text"
                        load: (data) ->
                            registry.byId("body").set "content", data
                        error: (error) ->
                            console.log error
                            registry.byId("body").set "content", "<h4 class='error'>Unfortunately, I cannot find the document '"+actions+"'</h4>"
        ,
            path: "/"
            defaultRoute: true
            handler: () ->
                router.go "/introduction"
    ], { noInitialRoute: false }

    console.log "Loading interface..."
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
            location.href = "#/" + item.id

    # Create the content pane that will store all of the body documenets.
    body = new ContentPane {}, "body"

    # Collapse and Uncollapse the tree menu when a#collapse is clicked.
    bind dom.byId("collapse"), "click", (event) ->
        # First, prevent the browser from following the link, which would
        # trigger the router.
        event.preventDefault()

        # Now run the effect and do what we need to do.
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
    router.init()

    # Now that everything's peachy, remove the preloader
    domStyle.set(dom.byId("preloader"), "display", "none")

