({

  //   See Component Documentation for more info and examples

  //   _getReduxSettings:  simply a place to centralize settings for this Redux component
  //   dispatch:           first gets action, then dispatches using the Redux store .dispatch

  _getReduxSettings: function() {
    return {

      // the name of the Api Component, giving actions access to callServer api
      ReduxApiComponentName:        "c:MarketplaceReduxAPI",

      // the window property name used for the Redux store
      globalStoreName:              'reduxAppState',

      // if enabled, used to set the entire app state with an action of type __OVERRIDE__
      appStateOverrideEnabled:      true,
      appStateOverrideActionName:   '__OVERRIDE__',

      // if enabled, logs all dispatched actions with current app states
      debugEnabled:                 true, // NOTE: set to 'false' for Production

      // if enabled, caches app state using LocalStorage
      cachingEnabled:               true,
      cachingLifeSpan:              10 * 60 * 1000, // 10 minutes
      cachingLocalStorageKey:       'ipa.reduxAppState.cache'
    };
  },

  dispatch : function(component, actionName, params) {
    var SETTINGS = this._getReduxSettings();
    // if Redux store is not yet set up, stores actions in a queue so they aren't dropped
    if (!window[SETTINGS.globalStoreName]) {
      var queue = SETTINGS.globalStoreName + '_queuedActions';
      window[queue] = window[queue] || [];
      window[queue].push({ actionName: actionName, params: params });
      window[queue + '_promises'] = window[queue + '_promises'] || [];
      var res, queuePromise = new Promise(function(resolve, reject) {
        res = resolve;
      });
      window[queue + '_promises'].push(res);
      return queuePromise;
    } else {
      if (window)
      // retrieves the loaded actions
      var actions = window[SETTINGS.globalStoreName + '_actions'];
      // checks to see if actionName exists in actions
      if (!actions[actionName]) throw('REDUX Error: No Action Found: ' + actionName);
      // calls action to get the Redux action object or thunk function
      var action = actions[actionName](params);
      // +++ DISPATCHES with Redux +++
      var dispatch = window[SETTINGS.globalStoreName].dispatch(action);
      // returns a promise and catches errors if dispatch is already a Promise
      if (typeof dispatch.then == 'function') {
        return dispatch
          .then(function() { return window[SETTINGS.globalStoreName].getState(); })
          .catch(function(e) {
            console.error('REDUX Error in dispatch: ' + actionName + ' -- ' + e);
          });
      } else { return Promise.resolve(dispatch); }
    }
  },

})