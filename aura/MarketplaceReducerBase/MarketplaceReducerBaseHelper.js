({

  // -+-+- NOTE: These functions to be overriden in Reducer SubComponents

  // By Default nothing is cached in LocalStorage (optional)
  getCacheFormatter: function() {
    return function(state) {
      return null;
    }
  },

  // This is the function to get the main reducer function (required)
  getReducer: function() {
    console.warn(
      'Reducer Base Function getReducer called.' + '\n' +
      'Store Name: ' + component.get('v.storeName') + '\n' +
      'This function should be overwritten in the reducer subcomponent.'
    );
    return {};
  }

})