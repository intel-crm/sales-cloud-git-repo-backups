({
	callApex : function(cmp,evt,hlpr) {
        debugger;
		var action = cmp.get("c.saveFeedbackFromRecordLevel");
        //action.setStorable();
        action.setParams({
            recordId : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var resp = response.getReturnValue();
                if(resp.check == true){
                    cmp.set("v.objValue",resp.objName);
                    cmp.set("v.userValue",resp.userValue);
                    cmp.set("v.feedbackrecId",resp.feedbackrecId);
                    cmp.set("v.popUpHeading",resp.headerMessage);
					cmp.set("v.isModalOpen",true);
                }
            }
        });
           $A.enqueueAction(action);     
	},
    
    saveFeedback : function(cmp,evt,hlpr) {
        var action = cmp.get("c.saveFeedbackPopUp");
        action.setParams({
            recordId : cmp.get("v.recordId"),
            rating : cmp.get("v.rating"),
            comments : cmp.get("v.userComments")
        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var resp = response.getReturnValue();
                cmp.set("v.isModalOpen",false);
                var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Information has been recorded successfully.",
                    "type": "success"
                });
                toastEvent.fire();
            }
        });
           $A.enqueueAction(action);
    },
    handleSkipFeedback : function(component, event, helper){
        var action = component.get("c.skipFeedback");
        action.setParams({
            recordId : component.get("v.recordId"),
        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var resp = response.getReturnValue();
                component.set("v.isModalOpen",false);
            }
        });
           $A.enqueueAction(action);
    },
})