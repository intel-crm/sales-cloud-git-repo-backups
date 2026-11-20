({

  getCacheFormatter: function() {
    return function(state) {
      return Object.assign({}, state, {
        notificationMessage: ''
      });
    };
  },

  getReducer: function() {
    return function(state, action) {

      // Initial State
      if (!state) state = {
          items: [],
          // IPA2.0 + US TWC4497-1631
          // multipleOfferingDetails:[],
        notificationMessage: ''
      };

      switch(action.type) {

        case 'clearCompareTray':
          return Object.assign({}, state, { items: [], notificationMessage: '' });

        case 'clearCompareTrayNotification':
          return Object.assign({}, state, { notificationMessage: '' });

        case 'showCompareTrayNotification':
          return Object.assign({}, state, { notificationMessage: action.msg });
          // IPA2.0 + US TWC4497-1631 
          // case 'fetchMultipleOfferingDetails':
          //     return Object.assign({}, state, { multipleOfferingDetails: action.response });

        case 'toggleCompareTrayItem':
          var idx = state.items.findIndex(function(i) { return i.id == action.item.id; });
          var newItems = state.items.slice();
          if (idx > -1) {
            newItems.splice(idx, 1);
          } else {
            newItems.push(action.item);
          }
          return Object.assign({}, state, {
            items: newItems,
            notificationMessage: ''
          });
              
          

        default:
          return state;
      }
    };
	},

})