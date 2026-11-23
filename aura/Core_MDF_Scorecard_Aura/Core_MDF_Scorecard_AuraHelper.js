({
	onInit : function(component, event, helper) {
        var recId = component.get("v.recordId");
        var caseId =recId;
       	helper.callServer(component, "c.getScoreCardDetailsAndAccess", (response) => {component.set('v.resultMap', response); }, {caseRecord : caseId});   
        helper.subscribe(component, event, helper);
    },
    subscribe : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        const channel = '/event/Core_MDF_Listener_PE__e';
        // Replay option to get new events
        const replayId = -1;

        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
            var recId = component.get("v.recordId");
            var result = eventReceived;
            if(recId==result.data.payload.Core_MDF_Object_ID__c){
            /*window.location.reload(); 
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
        	dismissActionPanel.fire();
            $A.get("e.force:navigateToSObject").setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        	}).fire();*/      
            location.reload();
        }    
        }))
        .then(subscription => {
            // Subscription response received.
            console.log('Subscription request sent to: ', subscription.channel);
        });
    },
    callServer: function (component, method, callback, params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback.call(this, response.getReturnValue());
                var result = response.getReturnValue();
                for(var key in result){
                    component.set("v.scoreCardId", key);
                    component.set("v.editFlag",result[key]);
                }
                console.log('flag' + component.get("v.editFlag"));
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})