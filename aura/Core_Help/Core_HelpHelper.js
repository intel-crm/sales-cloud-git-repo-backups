({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuestions");
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                debugger;
                
				var data = response.getReturnValue();
                component.set("v.queryList", data.aaq);
                component.set("v.objList", data.objs);
                component.set("v.isFeedbackOpen",false);
            }
			else if(state === "INCOMPLETE") {

			}
			else if(state === "ERROR") {

			}
		});
		$A.enqueueAction(action);
    },
    
	saveFeedback : function(component, event, helper) {
        console.log('rating:'+component.get("v.rating"));
        if(!$A.util.isEmpty(component.get("v.rating"))){
        component.set("v.isSpinner",true);
  		var action = component.get("c.saveFeedbackUtil");
        action.setParams({
            rating : component.get("v.rating"),
            areaOfFeedback : component.get("v.feedbackArea"),
            comments : component.get("v.userComments")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.data", response.getReturnValue());
                component.set("v.isFeedbackOpen",false);
                component.set("v.isSuccess",true);
                component.set("v.rating", "");
                component.set("v.userComments","");
                component.set("v.isError",false);
                component.set("v.isSpinner",false);
            }
			else if(state === "INCOMPLETE") {

			}
			else if(state === "ERROR") {

			}
		});
		$A.enqueueAction(action);
        }
        else{
            component.set("v.isError",true);
        }
    },
})