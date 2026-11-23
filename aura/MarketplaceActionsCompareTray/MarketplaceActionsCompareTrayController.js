({
	getActions : function() {
    return {

      // +=+=+=+ COMPARE TRAY ACTIONS A-Z HERE +=+=+=+
			clearCompareTray: function(params) {
				return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'clearCompareTray' }));
        };
			},

			clearCompareTrayNotification: function(params) {
        return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'clearCompareTrayNotification' }));
        };
      },

			showCompareTrayNotification: function(params) {
        return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'showCompareTrayNotification' }, params));
        };
      },

      toggleCompareTrayItem: function(params) { 
        return function(dispatch, getState, callServer) {
          return dispatch(Object.assign({ type: 'toggleCompareTrayItem' }, params));
        };
      },

        fetchMultipleOfferingsAction:function(params){
            console.log("params2::");
            console.log(params.offeringIds);
            return function(dispatch, getState, callServer) {
                return callServer('fetchMultipleOfferings', { offeringIds:params.offeringIds, 
                                                     bEditOffering:params.bEditOffering,
                                                     bViewOffering:params.bViewOffering
                                                    },true).then(function(response) {
                    console.log("getFetchOfferings start2");
                    console.log(response);
                    console.log("getFetchOfferings end2");
                    dispatch({ type: 'fetchMultipleOfferingDetails', response: response });
                })
            };
        },

    };
	}

})