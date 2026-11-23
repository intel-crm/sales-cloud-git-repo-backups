({
    doInit : function(component, event, helper) {
        var channel = '/event/Approval_Flow_Error__e';
        const replayId = -1;
         
        const empApi = component.find("empApi");
         
        //A callback function that's invoked for every event received
        const callback = function (message) {
            var msg = message.data.payload;
            console.log('msg = '+JSON.stringify(msg));
            
            console.log('Message returned : ' +msg.message__c );
             
            //fire toast message
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "mode": 'sticky',
                "title": "Warning",
                "message": msg.message__c,
                "type" : "warning"
            });
            toastEvent.fire();
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, callback).then(function(newSubscription) {
            //console.log("Subscribed to channel 1" + channel);
        });
        const errorHandler = function (message) {
            console.error("Received error ", JSON.stringify(message));
        };
        //A callback function that's called when an error response is received from the server for the handshake, connect, subscribe, and unsubscribe meta channels.
        empApi.onError(errorHandler);  
            
    }
})