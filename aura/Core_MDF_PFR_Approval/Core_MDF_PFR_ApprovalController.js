({

  doInit: function (component, event, helper) {
    // NEW: Check AI approval access and store in separate attribute
    var recordId = component.get("v.recordId");
    var action = component.get("c.hasAIApprovalAccess");
    action.setParams({
        "recordId": recordId
    });
    action.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
            var hasEmailAccess = response.getReturnValue();
            component.set("v.hasEmailWhitelistAccess", hasEmailAccess);
        } else {
            component.set("v.hasEmailWhitelistAccess", false);
        }
    });
    $A.enqueueAction(action);  
   	helper.loadApprovalFlowAction(component, event, helper);
  },
  
    approvalAction: function (component, event, helper) {
        var btnvalue = event.getSource().get("v.value");
        component.set('v.btnValue',btnvalue);
        if(btnvalue == 'Approve' || btnvalue == 'Reject'){
            var userID = $A.get("$SObjectType.CurrentUser.Id");
           component.set("v.userId", userID);
            var action = component.get("c.isApproverActive");
           action.setParams({
                "recId": component.get("v.recordId"),
                "userId": component.get("v.userId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    if(res == false){
                        var msg = $A.get("$Label.c.Core_MDF_IUPGM_Error");
                        helper.toastMessage($A.get("$Label.c.Core_MDF_Error"),'error',msg);
                        helper.windowTimeOut(); 
                   }else{
                        if (btnvalue == 'Approve') {
                            component.set('v.commentType', 'Approval Comment');
                            component.set('v.isApprovalCommentsRequired', false); 
                            component.set('v.showApprovalCommentSection', true);
                            component.set('v.isSaveDisable', true);
                        } 
                        //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
                        
                        else if (btnvalue == 'Reject' && !component.get("v.rejectInternalVisble") && !component.get("v.isOpalActApprovalRequired") /*&& !component.get("v.isPCTReviewer")*/) {
                            component.set('v.commentType', 'Rejection Comment');
                            component.set('v.isApprovalCommentsRequired', true);// Rejection Comment Mandatory
                            component.set('v.showApprovalCommentSection', true);
                            component.set('v.isSaveDisable', true);
                        }
                            else if (btnvalue == 'Reject' && component.get("v.isOpalActApprovalRequired")) {
                                component.set('v.commentType', 'Comment');
                                component.set('v.showApprovalCommentSection', true);
                                component.set('v.isSaveDisable', true);
                            }  
                            
                    }                
                }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.fireToastEvent(errorMessage, "5000", "error");
                }
            });
            $A.enqueueAction(action);
            
        }   if(btnvalue != 'Approve' && btnvalue != 'Reject') {
            component.set('v.commentType', 'Comment');
            component.set('v.showApprovalCommentSection', true);
            component.set('v.isSaveDisable', true);}
 },

  // UPDATED: Handle AI decision click to show detailed popup
  handleAIDecisionClick: function(component, event, helper) {
      // Show the popup with existing AI data
      if (component.get("v.aiSuggestionText")) {
          component.set("v.showSmartAssistPopup", true);
      } else {
          // If somehow AI data is not available, show loading and fetch
          component.set("v.isLoadingAISuggestion", true);
          component.set("v.showSmartAssistPopup", true);
          
          var recordId = component.get("v.recordId");
          helper.callAISuggestionService(component, recordId);
      }
  },

    // Close Smart Assist Popup
    closeSmartAssistPopup: function(component, event, helper) {
        component.set("v.showSmartAssistPopup", false);
        // Don't clear AI data as we want to keep it for the disclaimer
    },
  // Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var communityUrl = component.get("v.externalUser");
        var communityBaseUrl = $A.get("$Label.c.Core_MDF_PFRCommunityLink");
        var outcomebaseActivity= component.get("v.isOutcomebaseActivity");
        if(outcomebaseActivity){
            var communityUrl = component.get("v.externalUser");
            var recordId= component.get("v.recordId");
            var url = communityUrl
            ? communityBaseUrl + 's/outcome-based-campaign-details?recordId=' + recordId
            : '/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail?c__recordId=' + recordId;
            window.location.href = url;
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.recordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
        }
    },
  callApprovalProcessAndUpdateField : function (component, event, helper) {
      	component.set("v.disablebuttonName",true);
     	helper.onClickButton(component, component.get("v.recordId"), component.get("v.btnValue"));
      	$A.get("e.force:closeQuickAction").fire();
  }
})