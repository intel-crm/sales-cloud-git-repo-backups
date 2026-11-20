({
    getActions : function() {
        return {
            
            // +=+=+=+ SETTINGS ACTIONS A-Z HERE +=+=+=+
            changeSetting: function(params) {
                return function(dispatch, getState, callServer) {
                    console.log("changeSetting:params");
                    console.log(params);
                    return dispatch({ type: 'changeSetting', settings: params });
                };
            },
        };
    }
    
})