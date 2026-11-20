({
    onInit: function (component, event, helper) {
        helper.queryAllChecklistItems(component, helper, "", "");
        
    },
    queryAllChecklistItems: function (component, helper) {
        var caseId =component.get("v.recordId");
        //On init, populates the checklist items for the case
        helper.callServer(component, "c.queryAllChecklistItems", (response) => {  var checklist = []; var conts = response;for ( var key in conts ) {checklist.push({value:conts[key], key:key}); }component.set('v.checklistItemsWithCat', checklist); }, {caseRecord : caseId}, helper,event);
        //On init, gets the case status so that the checklist is editable only under status 'Under Review'
        //AI Audit changes
	    helper.callServer(component, "c.getCaseStatus", (response) => {
            component.set('v.caseStatus',response);
            // Only call AI audit status if case status is "Under Review"
            if (response === "Under Review") {
                helper.getAIAuditStatus(component, helper, event);
            }
        }, {caseRecord : caseId}, helper,event);
		//Check if the logged in user is a Claim Case Reviewer / Manager [Checklist Enhancements v2 - US488875: [Checklist] HIGH: Assign additional Case Checklist permissions to Finance users]
        helper.callServer(component, "c.checkEditability", (response) => {component.set('v.isAClaimCaseReviewerOrManager',response);},{}, helper,event);
        helper.callServer(component, "c.calculateChecklistCompletion", (response) => {component.set('v.checklistCompletionPer',response);}, {caseRecord : caseId}, helper,event);
    },
    //This method is called to record the checklist inputs to the DB
    updateChecklistRecords: function (component,event, helper) {
        var checklistMap =component.get("v.checklistMap");
        var impactAmountMap =component.get("v.impactAmount");
        var commentMap =component.get("v.commentCopy");
        var caseId =component.get("v.recordId");

        helper.callServer(component, "c.updateChecklistRecords", (response) => {component.set('v.checklistCompletion',response);}, {checklistSelection : checklistMap,impactAmount : impactAmountMap, comments: commentMap, caseRecord:caseId}, helper,event);
    },
    //Checklist Enhancements v1 - US458776: [Case: Edit] Automatic Status for Checklist Results
    updateCaseStatus: function (component,event, helper) {
        var caseId =component.get("v.recordId");

        helper.callServer(component, "c.calculateCaseStatus", (response) => {component.set('v.caseStatusChange',response);}, {caseRecord : caseId, performUpdate: component.get("v.performUpdate")}, helper,event);
    },
    //Toast to display successful saving of Checklist
    showToast : function(message, flag) {
        var toastEvent = $A.get("e.force:showToast");
        
        if(flag==1){
            toastEvent.setParams({
                "title": "Error!",
                "message": message,
                "type": "error",
                "mode": "dismissible",
                "duration":"10000"
            });
        }
        else{
            toastEvent.setParams({
                "title": "Success!",
                "message": "The Checklist items are saved successfully",
                "type": "success",
                "mode": "dismissible",
                "duration": "5000"
            });
        }
        
        toastEvent.fire();
    },
   //Method to get AI Status from Scorecard
   getAIAuditStatus: function (component, helper, event) {
        var caseId = component.get("v.recordId");
        helper.callServer(component, "c.getAIAuditStatusFromScorecard", (response) => { 
            var result = response;
            component.set('v.scorecardDetails', result);
            if(result && result.scorecardRec) {
            	if(result.scorecardRec.Core_MDF_AI_Processing_Status_Nm__c =='' || result.scorecardRec.Core_MDF_AI_Processing_Status_Nm__c == null || result.scorecardRec.Core_MDF_AI_Processing_Status_Nm__c == undefined){
                	component.set("v.aiStatusMessage", 'AI Validation in progress. Please check back shortly or continue review.');
            		
                 }
               	else if(result.scorecardRec.Core_MDF_AI_Processing_Status_Nm__c =='AI Processing Failed'){
                	component.set("v.aiStatusMessage", 'AI Response not available. Please continue with review.');
                }
             }
        }, {caseRecordId : caseId}, helper, event);
    },

    callServer: function (component, method, callback, params, helper,event) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this, response.getReturnValue());
                console.log('method' + method);
                console.log('from callback' + component.get('v.isAClaimCaseReviewerOrManager'));
                if(method == 'c.updateChecklistRecords'){ 
                    if(component.get('v.checklistCompletion')!=100){$A.get('e.force:refreshView').fire(); helper.showToast();}
                    //Checklist Enhancements v1 - US458776: [Case: Edit] Automatic Status for Checklist Results
                    if(component.get('v.checklistCompletion') == 100){
            		helper.callServer(component, "c.calculateCaseStatus", (response) => {component.set('v.caseStatusChange',response);}, {caseRecord : component.get("v.recordId"), performUpdate: false}, helper,event);
        			}
                    
                    if(!component.set('v.caseStatusChange')){$A.get('e.force:refreshView').fire(); helper.showToast();}
                }
                //Checklist Enhancements v1 - US458776: [Case: Edit] Automatic Status for Checklist Results
                if(method == 'c.calculateCaseStatus' && component.get('v.caseStatusChange')== true && component.get('v.performUpdate')!= true){component.set("v.isOpen", true);}
                if(method == 'c.calculateCaseStatus' && component.get('v.performUpdate')== true){$A.get('e.force:refreshView').fire();}
            } 
            
            else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(errors[0].message,1);
                    }
                } else {
                    //throw new Error("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    }

})