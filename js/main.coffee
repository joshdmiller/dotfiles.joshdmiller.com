$(document).ready () ->

    require ["dojo/data/ItemFileReadStore", "dijit/tree/TreeStoreModel", "dijit/Tree"], (ItemFileReadStore, TreeStoreModel, Tree) ->
        Router = Backbone.Router.extend
            routes:
                "*actions"       : "defaultRoute"

            defaultRoute: (actions) ->
                @updateMenu()
                console.log "Received request to route to: #{actions}"

            # updateMenu updates the currently-selected item in the navbar. If the
            # current hash mark is not or does not match an existing route, we
            # default to #/home. Further, if it is a multi-part route, we chop off
            # all but the first portion of the route before attempting a match.
            # That is "#/projects/1234" will be "#/projects".
            updateMenu: () ->
                defaultUrl = "#/home"
                url = document.location.hash
                if !url? or url is ""
                    url = defaultUrl

                if url.split("/").length > 2
                    url = "#/" + url.split("/")[1]
                
                if !@.routes[url.split("#")[1]]?
                    url = defaultUrl
                
                $("#header .nav > li").removeClass("active")
                $('#header .nav a[href="'+url+'"]').parent().addClass("active")

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

