({

  afterScriptsLoaded : function(component, event, helper) {
    var SETTINGS = helper._getReduxSettings();
    component.set('v.__debugMode', SETTINGS.debugEnabled);

    // Sets up the Redux store if it does not yet exist--
    // This only happens ONCE!
    if (!window[SETTINGS.globalStoreName]) {

      // if no actions or reducer components exist skip Redux setup
      if (!component.find("actions")) return;
      if (!component.find("reducer")) return;

      // ACTIONS
      // sets actions (so we only have to do this once)
      window[SETTINGS.globalStoreName + '_actions'] = [].concat(component.find('actions'))
        .reduce(function(allActions, actionCmp) {
          // uses the .getActions() aura method on the actions component
          if (actionCmp.getActions) {
            var cmpActions = actionCmp.getActions();
            Object.keys(cmpActions).forEach(function(actionName) {
              if (allActions[actionName]) throw('Redux Error Duplicate action exists!' + actionName);
              allActions[actionName] = cmpActions[actionName];
            });
          } else {
            throw('Error getting actions from ' + actionCmp.getName() + '.' +
                  'No .getActions() function exists on component.');
          }
          return allActions;
        }, {});

      // REDUCERS
      // combines all the reducers (also get cache formatters)
      var cacheFormatterFunctions = {};
      var reducers = [].concat(component.find("reducer"))
        .reduce(function(reducerFunctions, reducer) {
          var storeName = reducer.get('v.storeName');
          if (!storeName) throw('Error with Reducer. No storeName set for ' + reducer.getName());
          reducerFunctions[storeName] = reducer.getReducer();
          cacheFormatterFunctions[storeName] = reducer.getCacheFormatter();
          return reducerFunctions;
        }, {});

      var appReducer = window.Redux.combineReducers(reducers);
      var rootReducer = function(state, action) {
        // adds a specific override action for demo widget to set the state
        if (SETTINGS.appStateOverrideEnabled &&
          action.type == SETTINGS.appStateOverrideActionName) {
          return action.payload;
        }
        return appReducer(state, action);
      };

      var initialAppState = {};

      // restore a cached app state if it exists
      if (SETTINGS.cachingEnabled) {
        var key = SETTINGS.cachingLocalStorageKey; // localStorage key name
        var cacheExpiration = parseInt(window.localStorage.getItem(key + '.expires'));
        if (!cacheExpiration || (cacheExpiration > Date.now())) {
          var cachedState = JSON.parse(window.localStorage.getItem(key));
          if (cachedState && SETTINGS.debugEnabled) {
            console.log('REDUX restoring state from LocalStorage ', cachedState);
          }
          initialAppState = cachedState || {};
        }
        var newExpiration = Date.now() + SETTINGS.cachingLifeSpan;
        window.localStorage.setItem(key + '.expires', newExpiration);
      } else {
        try { window.localStorage.removeItem(key); } catch(e) {}
      }

      // Redux Middleware
      // uses thunk (w/ extra argument api -- 'callServer' function for easy AuraMethod access)
      // https://github.com/reduxjs/redux-thunk#injecting-a-custom-argument
      var callServerApi = function(auraMethodName, params, returnSFobject) {
          //debugger;
        return new Promise(function(resolve, reject) {
            //debugger;
          $A.createComponent(SETTINGS.ReduxApiComponentName, { debug: SETTINGS.debugEnabled },
            function(api, status, errorMessage) {
              if (status === "SUCCESS") {
                  //debugger;
                resolve(api.callServerFromReduxAction(api, auraMethodName, params, returnSFobject));
              } else if (status === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
                reject(Promise.reject());
              } else if (status === "ERROR") {
                console.log("Error: " + errorMessage);
                reject(Promise.reject());
              }
            }
          );
        });
      };

      var thunk = function(_ref) {
        return function (next) {
          return function (action) {
            if (typeof action === 'function') {
              return action(_ref.dispatch, _ref.getState, callServerApi);
            }
            if (typeof action === 'string') {
              return next({ type: action });
            }
            return next(action);
          };
        };
      };

      // Cache Middleware using LocalStorage
      var cacheEnabled = SETTINGS.cachingEnabled;
      var cacheKey = SETTINGS.cachingLocalStorageKey;
      var cacher = function(_ref) {
        return function (next) {
          return function (action) {
            var returnValue = next(action);
            if (cacheEnabled) {
              var currentState = _ref.getState(), cachedState = {};
              Object.keys(cacheFormatterFunctions).forEach(function(storeName) {
                var storeCachedState = cacheFormatterFunctions[storeName](currentState[storeName]);
                if (storeCachedState) cachedState[storeName] = storeCachedState;
              });
              window.localStorage.setItem(cacheKey, JSON.stringify(cachedState));
            }
            return returnValue;
          }
        }
      }

      // logger middleware
      var loggerEnabled = SETTINGS.debugEnabled;
      var logger = function(_ref) {
        return function(next) {
          return function (action) {
            var returnValue = next(action);
            if (loggerEnabled && action.type) {
/*
                var oldWarn = window.console.warn;
              window.console.warn = function() {
                var messages = [].concat(arguments).filter(function(m) {
                  return typeof m == 'string';
                });
                // filter annoying Javascript warnings
                // re: Lightning Proxy objects -> JSON strings
                // despite this being SF recommended debug method
                messages.forEach(function(message) {
                  if (message.match('method: toJSON')) return;
                  oldWarn(message);
                });
              };
*/              
              console.log('REDUX dispatch: ' + action.type, {
                action: JSON.parse(JSON.stringify(action)),
                appState: JSON.parse(JSON.stringify(_ref.getState()))
              });
            }
            return returnValue;
          };
        };
      };

      // CREATES REDUX STORE
      window[SETTINGS.globalStoreName] = window.Redux.createStore(
        rootReducer,
        initialAppState,
        window.Redux.applyMiddleware(thunk, cacher, logger)
      );

      // checks for any queued actions (actions dispatched before Redux finished setting up)
      var queuedActions = window[SETTINGS.globalStoreName + '_queuedActions'] || [];
      var lengthOfQueue = queuedActions.length;
      queuedActions.forEach(function(queuedAction, idx) {
        helper.dispatch(component, queuedAction.actionName, queuedAction.params)
          .then(function() {
            var state = window[SETTINGS.globalStoreName].getState();
            window[SETTINGS.globalStoreName + '_queuedActions_promises'][idx](state);
            if (idx + 1 == lengthOfQueue) window[SETTINGS.globalStoreName + '_queuedActions_promises'] = null;
          });
      });
      window[SETTINGS.globalStoreName + '_queuedActions'] = [];
    }
    // ---- end setup


    // Updates SubComponents with changed App State / Store State
    // Keeps track of prevState
    var prevState, updateSubComponent = function() {
      // get the current state from Redux
      var nextState = window[SETTINGS.globalStoreName].getState();

      // updates the v.appState attribute
      component.set('v.appState', nextState);

      // updates the v.state attribute (if v.storeName exists)
      if (component.get('v.storeName')) {
        component.set('v.state', nextState[component.get('v.storeName')]);

        // updates specific attributes (if they have changed)
        if (component.get('v.mapStateToAttributes')) {
          var mapStateToAttributes = component.get('v.mapStateToAttributes');
          var nextValues = mapStateToAttributes(nextState[component.get('v.storeName')]);
          var keys = Object.keys(nextValues);
          keys.forEach(function(key) {
            var prevValue = component.get('v.' + key);
            var nextValue = nextValues[key];
            if (nextValue && typeof nextValue == 'object') {
              if (JSON.stringify(prevValue) !== JSON.stringify(nextValue)) {
                component.set('v.' + key, nextValue);
              }
            } else if (prevValue !== nextValue) {
              component.set('v.' + key, nextValue);
            }
          });
        }
      }

      prevState = nextState;
    };

    // For all subcomponents, add store subscriptions to update attributes
    var unsubscribe = window[SETTINGS.globalStoreName].subscribe($A.getCallback(function() {
      if (component.isValid()) {
        updateSubComponent();
      } else {
        unsubscribe();
      }
    }));

    // Sets attributes initially (subscriptions don't fire when initialized)
    updateSubComponent();
  },

})