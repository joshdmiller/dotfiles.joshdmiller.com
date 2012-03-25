$(document).ready () ->

    require ["dojo/data/ItemFileReadStore", "dijit/tree/TreeStoreModel", "dijit/Tree"], (ItemFileReadStore, TreeStoreModel, Tree) ->
        Router = Backbone.Router.extend
            routes:
                "*actions"       : "defaultRoute"

            defaultRoute: (actions) ->
                return if !actions? or actions is ""
                console.log "Received request to route to: #{actions}"
                require ["dojo/_base/xhr", "dojo/dom"], (xhr, dom) ->
                    console.log "Loading file..."
                    deferred = dojo.xhrGet
                        url: "/#{actions}.html"
                        handleAs: "text"
                        load: (data) ->
                            dom.byId("body").innerHTML = data
                        error: (error) ->
                            console.log error

        # Create a new instance of our application.
        app = new Router()
        
        # Launch the router and go to the provided route
        Backbone.history.start()

        store = new ItemFileReadStore
            url: "/tree.json"

        treeModel = new TreeStoreModel
            store: store
            childrenAttrs: ["children"]

        tree = new Tree
            model: treeModel
            showRoot: false
        , "tree"

        tree.onClick = (item) ->
            if !item.children? or item.children.length is 0
                location.href = "#" + item.id

