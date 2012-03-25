# ## License

# This file is part of the Citeplasm Web Client.
# 
# The Citeplasm Web Client is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# The Citeplasm Web Client is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
# 
# You should have received a copy of the GNU General Public License along with
# The Citeplasm Web Client.  If not, see <http://www.gnu.org/licenses/>.

# ## Summary

#
# citeplasm/Router is a dojo/hash-based URL router as part of Citeplasm's MVC
# approach, based on Colin Snover's dbp.Router.
#
# Router allows individual routes to include both query and path string
# parameters which are then available inside the handling function. Here is an
# example of url routes and paths that resolve to them:
#
#     /docs/:id         ->      #/docs/12345
#     /search           ->      #/search?query=polymerase
#
# A route has three components: a regular expression string representing the
# path of the route, a method handler that is invoked each time the route is
# matched, and a boolean value indicating whether this value should be
# considered the default. 
#
# The route handler method is a function that takes two parameters: an object
# containing the parameters pulled from the route path, and an object
# containing information about the route that invoked the method handler.
#
# If no default is specified, the first route provided becomes the default.
#
# Example usage:
#
#     router = new Router [
#             path: "/docs/:id"
#             defaultRoute: true
#             handler: (params, route) ->
#                 console.log "Inside the route"
#         ,
#             path: "/search"
#             defaultRoute: false
#             handler: (params, route) ->
#                 console.log "Inside the route"
#     ]
#

# ## RequireJS-style AMD Definition

define [
    "dojo/_base/declare",
    "dojo/hash",
    "dojo/_base/array",
    "dojo/_base/connect",
    "dojo/_base/lang",
    "dojo/io-query"
], (declare, hash, array, connect, lang, ioquery) ->

    # ## Global Variables

    PATH_REPLACER = "([^\/]+)"
    PATH_NAME_MATCHER = /:([\w\d]+)/g

    # ## citeplasm/router
    #
    # citeplasm/Router is defined using Dojo's declare with no superclass.
    declare("citeplasm.Router", null,

        # ### constructor
        #
        # The constructor creates an instance of citeplasm/Router and loads it
        # with the routes provided; if no default was provided, the first route
        # provided becomes the default.
        constructor: (userRoutes, options) ->
            # _routes is an array of all routes registered to the router.
            @_routes = []

            # _routeCache is a cache of the parsed routes. The routes are loaded
            # initially, but are parsed to regex, etc., only when necessary.
            @_routeCache = {}
            
            # _currentPath is the current hash value.
            @_currentPath = null

            # _subscriptions contains the dojo/subscribe return objects used by the
            # class. These are stored for cleanup.
            @_subscriptions = []

            # The default route to use when no route is provided.
            @_defaultRoute = null

            if !userRoutes? or !userRoutes.length
                throw new Error "No routes provided to citeplasm/Router."

            array.forEach userRoutes, (r) ->
                @_registerRoute r.path, r.handler, r.defaultRoute
            , this

            # if there is no default, use the first as the default
            if !@_defaultRoute?
                @_defaultRoute = @_routes[0]

            # If options were provided, merge them now.
            lang.mixin(@, options) if options?

            return

        # ### init
        #
        # The init method processes the current hash or, if none exists, uses
        # the default route. Also subscribe to the event 'dojo/hashchange'
        # which is called, appropriately enough, when the URL hash changes,
        # triggering the '_handle' method when published.
        init: () ->
            # if the Router was initialized with the document having a route,
            # handle it. Otherwise, redirect to the default route.
            currentHash = hash()
            if currentHash? and currentHash isnt ""
                @_handle(currentHash)
            else if !@noInitialRoute
                @go @_defaultRoute.path

            @_subscriptions.push connect.subscribe("/dojo/hashchange", @, () ->
                @_handle hash()
                return
            )

        # ### go
        #
        # The go method redirects to the specified path.
        go: (path) ->
            if !path? or (path = lang.trim path) is ""
                console.warn "citeplasm/Router::go() invoked with no path."
                return
            
            console.log "citeplasm/Router::go(#{path})"

            # If the path provided is missing the hash mark, we must add it in
            # prior to changing the hash.
            if path.indexOf("#") isnt 0
                path = "#" + path

            # FIXME: Using both _handle as well as changing the hash causes the
            # handle function to be called twice: once manually and once
            # through the subscription to /dojo/hashchange. The second call
            # returns because the path doesn't match. Using both is needed for
            # the tests to work appropriately without manually inserting a
            # delay.  We should find a better way to do this.
            if path isnt @_currentPath
                @_handle path
                hash path

        # ### _handle
        #
        # The _handle method is the internal handler for for all hash changes.
        _handle: (hashValue) ->
            path = hashValue.replace("#", "")
            
            if path == @_currentPath
                return
            
            console.log "citeplasm/Router::_handle Changing current path to '#{path}'"

            route = @_chooseRoute @_getRouteablePath(path) or @_defaultRoute

            # If the path does not represent a known route, go to the default route.
            if !route
                return @go @_defaultRoute.path

            @_currentPath = path
            params = @_parseParams path, route

            route = lang.mixin route,
                hash: hashValue
                params: params

            route.handler params, route

        # ### _chooseRoute
        #
        # The _chooseRoute method is the internal means of relating a hash to a
        # route.
        _chooseRoute: (path) ->
            if !@_routeCache[path]
                routeablePath = @_getRouteablePath path
                array.forEach @_routes, (r) ->
                    @_routeCache[path] = r if routeablePath.match r.matcher
                , @

            @_routeCache[path]

        # ### _registerRoute
        #
        # The _registerRoute method internally handles associating a route with
        # this instance of the router. 
        #
        # The first parameter (path) is either a String or Regex that
        # represents pattern of the path to which this route applies.  The
        # second parameter (fx) is a function handler to be executed when the
        # route is run.  The last parameter (defaultRoute) is a Boolean value
        # indicating whether this route shouldbe considered the default.
        _registerRoute: (path, fx, defaultRoute) ->
            r =
                path: path
                handler: fx
                matcher: @_convertPathToMatcher path
                paramNames: @_getParamNames path

            @_routes.push r

            @_defaultRoute = r if defaultRoute
            console.log "citeplasm/Router::_registerRoute Setting default route to #{path}" if defaultRoute

        # ### _convertPathToMatcher
        #
        # The _convertPathToMatcher method converts a String path to a regex
        # that can be used as a matcher. If a regex is already provided, it is
        # returned without alteration.
        #
        # The route parameter is either a String or a Regex to be converted to a regex.
        #
        # _convertPathToMatcher returns a Regex matcher.
        _convertPathToMatcher: (route) ->
            if lang.isString route
                new RegExp "^" + route.replace(PATH_NAME_MATCHER, PATH_REPLACER) + "(/){0,1}$"
            else
                route

        # ### _parseParams
        #
        # The _parseParams method generates an object containing the parameter
        # names and values of the provided hash and route object. The object
        # contains all query object parameters in an associative array called
        # 'query' and all route parameters as members.
        #
        # Given the example route '/doc/:id' and the path
        # '/doc/1234?param1=hello&param2=goodbye', the return object is of the
        # form:
        #     
        #   {
        #       id: "1234",
        #       queryParams: {
        #           param1: "hello",
        #           param2: "goodbye"
        #       }
        #   }
        _parseParams: (hashValue, route) ->
            parts = hashValue.split "?"
            path = parts[0]
            query = parts[1]
            _decode = decodeURIComponent
            params = {}

            # If there indeed are query parameters, we use dojo/io-query's
            # queryToObject to create an object from the query parameters. See
            # http://livedocs.dojotoolkit.org/dojo/queryToObject for more
            # information.
            params.query = if query then lang.mixin {}, ioquery.queryToObject(query) else {}

            # Now that we have the query parameters, we need to match the
            # route's parameters too. For example, the route matcher '/doc/:id'
            # and the path '/doc/1234' should yield a parameter with a value of
            # '1234'.
            if (pathParams = route.matcher.exec @_getRouteablePath(path)) isnt null
                # Of course, the first match is the full path so we'll ignore it.
                pathParams.shift()

                # Now we loop through each of the matches in the route. If
                # there is a matching parameter name, we simply add the
                # parameter and its value to the object. Otherwise, we add it
                # to the splat.
                array.forEach pathParams, (param, i) ->
                    return if !param?
                    if route.paramNames[i]
                        params[route.paramNames[i]] = _decode param
                    else
                        params.query[param] = _decode(param)

            return params

        # ### _getRouteablePath
        #
        # This method removes the query string from the provided path string so
        # it can be used in matching methods.
        _getRouteablePath: (path) ->
            path.split("?")[0]

        # ### _getParamNames
        #
        # This method takes a provided path as either a string or a regex and
        # returns an array of parameter names expected by the route.
        _getParamNames: (path) ->
            paramNames = []

            PATH_NAME_MATCHER.lastIndex = 0

            while (pathMatch = PATH_NAME_MATCHER.exec(path)) isnt null
                paramNames.push pathMatch[1]

            return paramNames

        # ### destroy
        #
        # When necessary to clean up, destroy all subscriptions.
        destroy: () ->
            array.forEach @_subscriptions, connect.unsubscribe
    )

