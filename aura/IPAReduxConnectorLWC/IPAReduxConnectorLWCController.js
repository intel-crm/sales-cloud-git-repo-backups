({
    
    doInit: function(component, event, helper) {
        if (!window.__suppressConsoleWarnings__) {
            window.__suppressConsoleWarnings__ = true;
            // suppress annoying json parse/stringify warnings
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
  
            var oldError = window.console.error;
            window.console.error = function(err) {
              // filter annoying Javascript errors
              if (err.toString().match('WireContextEvent')) return;
              oldError(err);
            };
        }
        
  
        if (!window.currentAppState) {
            console.error('Race condition with ISGRedux -- Redux not set up properly.');
        } else {
            let appState = Object.assign({}, window.currentAppState);
            // BACKWARDS CAMPATIBILITY (uses capitalized store names)
            Object.keys(appState).forEach(function(key) {
                var capitalizedKey = key[0].toUpperCase() + key.substr(1);
                appState[capitalizedKey] = appState[key];
            });
            component.set('v.appState', appState);
            if (component.get('v.storeName')) {
                component.set('v.state', appState[component.get('v.storeName')]);
            }
            // Subscribe to further changes
            helper.subscribeToRedux(component, helper);
        }
    },
  
    handleResetState: function(component, event, helper) {
        helper.mapStateToAttributes(component, helper);
    },
  
    handleResetAppState: function(component, event, helper) {
        helper.mapAppStateToAttributes(component, helper);
    },
  
  });