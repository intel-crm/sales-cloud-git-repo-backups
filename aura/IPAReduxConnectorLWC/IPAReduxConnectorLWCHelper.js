({
    
    // TO BE CALLED FROM SUBCOMPONENT
    // NOTE: This is backwards compatible with all aura components
    // State is duplicated to preserve old Uppercase store names
    dispatch: function(component, actionType, params) {
        return new Promise(function(resolve, reject) {
            if (!component.isValid()) {
                reject("Component no longer valid!");
            } else {
                window.dispatch(actionType, params).then(function(state) {
                    let newState = Object.assign({}, state);
                    Object.keys(newState).forEach(function(key) {
                        var capitalizedKey = key[0].toUpperCase() + key.substr(1);
                        newState[capitalizedKey] = newState[key];
                    });
                    resolve(newState);
                });
            }
        });
    },

    // TO BE CALLED FROM SUBCOMPONENT
    // subscribes with lwc Redux format
    // NOTE: Must use new lowerCamelCase LWC store names
    subscribe: function(component, path, reader) {
        return window.subscribe(path, reader);
    },

    // NOT TO BE CALLED FROM SUBCOMPONENT - SETUP ONLY
    subscribeToRedux: function(component, helper) {
        var appStateSubscription = window.subscribe(
            $A.getCallback(function(state) {
                if (component.isValid()) {
                    let newState = Object.assign({}, state);
                    Object.keys(newState).forEach(function(key) {
                        var capitalizedKey = key[0].toUpperCase() + key.substr(1);
                        newState[capitalizedKey] = newState[key];
                    });
                    var storeName = component.get("v.storeName");
                    if (storeName) {
                        helper.mapStateToAttributes(component, helper);
                        component.set("v.state", newState[storeName]);
                    }
                    helper.mapAppStateToAttributes(component, helper);
                    component.set("v.appState", newState);
                } else {
                    appStateSubscription(); // unsubscribes
                }
            }),
            true
        );
    },

    // NOT TO BE CALLED FROM SUBCOMPONENT - SETUP ONLY
    mapStateToAttributes: function(component, helper) {
        var mapStateToAttributes = component.get("v.mapStateToAttributes");
        var storeName = component.get("v.storeName");
        if (storeName && typeof mapStateToAttributes === "function") {
            storeName = storeName[0].toLowerCase() + storeName.substr(1);
            var state = window.currentAppState[storeName];
            var nextValues = mapStateToAttributes(state);
            var keys = Object.keys(nextValues);
            keys.forEach(function(key) {
                var prevValue = component.get("v." + key);
                var nextValue = nextValues[key];
                if (nextValue && typeof nextValue == "object") {
                    if (JSON.stringify(prevValue) !== JSON.stringify(nextValue)) {
                        component.set("v." + key, nextValue);
                    }
                } else if (prevValue !== nextValue) {
                    component.set("v." + key, nextValue);
                }
            });
        }
    },

    mapAppStateToAttributes: function(component, helper) {
        var mapAppStateToAttributes = component.get("v.mapAppStateToAttributes");
        if (typeof mapAppStateToAttributes === "function") {
            var nextValues = mapAppStateToAttributes(window.currentAppState);
            var keys = Object.keys(nextValues);
            keys.forEach(function(key) {
                var prevValue = component.get("v." + key);
                var nextValue = nextValues[key];
                if (nextValue && typeof nextValue == "object") {
                    if (JSON.stringify(prevValue) !== JSON.stringify(nextValue)) {
                        component.set("v." + key, nextValue);
                    }
                } else if (prevValue !== nextValue) {
                    component.set("v." + key, nextValue);
                }
            });
        }
    },
});