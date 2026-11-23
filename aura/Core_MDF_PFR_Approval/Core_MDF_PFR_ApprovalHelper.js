({
    loadApprovalFlowAction: function (component, event, helper) {
        var result;
        var action = component.get("c.loadPFRRecord");
      
        action.setParams({
        "pfrId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            var state = response.getState();
           if (state === "SUCCESS") {            
            if (result != null) {
                component.set('v.externalUser', result.userPermissionsPowerPartner);
                    // Set the new attribute for the dual role
                    component.set('v.isIPAAccountMgrAndPCTApprover', result.isIPAAccountMgrAndPCTApprover);
                //US946280 : [Opal CCF/DCF] - Activity Edits - Activity Status = Pending Approval - Show Reject button for Internal Account Manager
                //Ramapriya - Approve/Reject/Recall button visibility for In-Progress Pending Review / In-Progress Pending Approval Status
                if((result.pfrInstance.Core_MDF_Program__c == 'Client' 
                || result.pfrInstance.Core_MDF_Program__c == 'Datacenter' 
                || (result.pfrInstance.Core_MDF_Program__c =='Intel Partner Alliance' && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c==false)
                || result.pfrInstance.Core_MDF_Program__c == 'Ecosystem Extension Fund') 
                    && (((((result.isMarktngOwner ||  result.isFieldOwner) && !result.isAdditionalReviewer) || result.isIPAAccountMgr) && 
                    (result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm") ||
                    result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_InProgress_PendingApproval") ||
                    ((result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") || 
                      result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_InProgress_PendingReview")  ) &&
                    result.pfrInstance.Core_MDF_Approval_Step_Completed__c != 0)))                    
                   || (result.userPermissionsPowerPartner 
                       && result.pfrInstance.Core_MDF_Fund_Request_Status__c == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"))
                    || result.userPermissionsEEFRecall)
                    && !result.isIPAAccountMgrAndPCTApprover){                   
                  
                    component.set('v.rejectInternalVisble', true);
                    component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Activity_Recall_Nm"));
                    component.set('v.buttonValue', 'Recall');
                    component.set('v.buttonToBeVisible', true);  
                    component.set('v.showRecallOnly', true);  
                }
                
                //Changes by Ealisha for opal act approval process--start
                else if(result.isIntelActivityApprover){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isOpalActApprovalRequired', true);
                }
                 //Aswin
                else if(result.isAdditionalReviewer){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isOpalActApprovalRequired', true);
                }
                //Changes by Ealisha for opal act approval process--end
                
                else if (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' && 
                    ('EMEA').includes(result.pfrInstance.Core_MDF_Region_nm__c) &&      
                    !result.approverAssigned && !result.userPermissionsPowerPartner && result.userEmeaReviewer) {
                     console.log('<EMEA>');
                    component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Retail_SubmitForApproval"));
                    component.set('v.buttonValue', 'Submit for Approval');
                    component.set('v.buttonToBeVisible', true);
                }  else if(result.isAccountMng && result.approverAssigned && !result.isGeoLeadApprover && 
                           (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval')
                            && result.pfrInstance.Core_MDF_Program__c == 'Retail Marketing Funds' /*&& result.pfrInstance.Core_MDF_Approval_Status_Stage_txt__c == 'Geo Marketing Lead'*/){
                  // US1072007 : [RMF] - Ability for RSM to Edit an Activity when in Geo Lead's Queue
                  // US1099159 : [RMF] - Change button Label
                  component.set('v.buttonName', $A.get("$Label.c.Core_MDF_Activity_Recall_Nm"));
                  component.set('v.buttonValue', 'Recall');
                  component.set('v.buttonToBeVisible', true);
                  component.set("v.commentsMandatory",false);
                  component.set('v.rejectInternalVisble', true);
                  component.set('v.isApprovalCommentsRequired', false); 
                } else if (result.userPermissionsPowerPartner && 
                           (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval'
                        || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Approval' )){
                         
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                }       
                //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers
                else if(result.isUserPCTApprover && result.isPriceReviewer && result.pfrInstance.Core_MDF_Approval_Stage__c == 'Price Reviewer'
                            && (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                                || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review' )
                            ){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isPCTReviewer', true);
                  }
                    // New condition for dual-role functionality
                    else if (result.isIPAAccountMgrAndPCTApprover) {
                        component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                        component.set('v.buttonValue', 'Approve');
                        component.set('v.buttonToBeVisible', true);
                } 
                //IPA L1
                 else if (result.pfrInstance.Core_MDF_Program__c == 'Intel Partner Alliance' 
                          && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                          && result.isLevel1Approver
                         && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c == false){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isLevel1Approver', true);
                 }
                  else if (result.pfrInstance.Core_MDF_Program__c == 'Intel Partner Alliance' 
                          && (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                          || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review' )
                          && result.isPORApprover
                         && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c == false){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isPORApprover', true);
                 }
                  else if (result.pfrInstance.Core_MDF_Program__c == 'Intel Partner Alliance' 
                          && (result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review' 
                            || result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'In-Progress Pending Review' )
                          && result.isLevel2Approver
                         && result.pfrInstance.Core_MDF_Proposal_Based_Ind__c == false){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isLevel2Approver', true);
                 }
             
              else if (result.pfrInstance.Core_MDF_Program__c == 'Retail Marketing Funds'
              			&& result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'
                          && result.isGeoLeadApprover){
                    component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                    component.set('v.buttonValue', 'Approve');
                    component.set('v.buttonToBeVisible', true);
                    component.set('v.isGeoLeadApprover', true);
                } else if (result.pfrInstance.Core_MDF_Program__c == 'Ecosystem Extension Fund' 
                           && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Review'){
                            if(result.isL1PrimaryPartnerApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isL1PrimaryPartnerApprover', true);
                            } else if(result.isL1ActivatingPartnerApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isL1ActivatingPartnerApprover', true);
                            }else if(result.isL2PrimaryApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isL2PrimaryApprover', true);
                            } else if(result.isEEFPORApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isPORApprover', true);
                            } else if(result.isEEFPCTApprover){
                                component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                                component.set('v.buttonValue', 'Approve');
                                component.set('v.buttonToBeVisible', true);
                                component.set('v.isPCTReviewer', true);
                            }
                } else if (result.pfrInstance.Core_MDF_Program__c == 'Ecosystem Extension Fund' 
                            && result.pfrInstance.Core_MDF_Fund_Request_Status__c == 'Pending Approval'){
                        if(result.isPrimaryPartnerApprover){
                            component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                            component.set('v.buttonValue', 'Approve');
                            component.set('v.buttonToBeVisible', true);
                            component.set('v.isPrimaryPartnerApprover', true);
                        } else if(result.isActivatingPartnerApprover){
                            component.set("v.buttonName", $A.get("$Label.c.Core_MDF_Retail_Approve"));
                            component.set('v.buttonValue', 'Approve');
                            component.set('v.buttonToBeVisible', true);
                            component.set('v.isActivatingPartnerApprover', true);
                        }
                }
                else {
                    component.set('v.buttonToBeVisible', false);
                }
                component.set('v.pfrMapInstance', result.pfrMapInstance);
          }
	  }
           else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.fireToastEvent(errorMessage, "5000", "error");
            }
        });
            $A.enqueueAction(action);
    },

    //Function to validate the approval comments heave been entered or not
    checkApprovalComment: function (component, pfrId, btnType) 
    {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: $A.get("$Label.c.Core_MDF_Error"),
            type: 'error',
            message: $A.get("$Label.c.Core_MDF_Approval_Comment_Error"), // Please provide a comment
            mode: 'sticky',
        });
        toastEvent.fire();

    },

    //Function that will called on click of the button
    onClickButton: function (component, pfrId, btnValue)
    {
       
        // Throw error only when rejection happens and comments are blank or empty or null
        if ((btnValue == 'Reject' && component.get("v.commentsMandatory")) && component.get("v.approvalComments") != null && $A.util.isEmpty(component.get("v.approvalComments").trim()))
        {
            component.set("v.disablebuttonName",false);
            this.toastMessage($A.get("$Label.c.Core_MDF_Error"),'error',$A.get("$Label.c.Core_MDF_Approval_Comment_Error"));
        }
        else{
            //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers - Added PCT Reviewer
            if (btnValue == 'Approve' && !component.get('v.externalUser') && !component.get("v.isOpalActApprovalRequired") && !component.get("v.isPCTReviewer") && !component.get("v.isLevel1Approver") && !component.get("v.isLevel2Approver") && !component.get("v.isPORApprover") && !component.get("v.isGeoLeadApprover") && !component.get("v.isL1PrimaryPartnerApprover") && !component.get("v.isL2PrimaryApprover") && !component.get("v.isL1ActivatingPartnerApprover") && !component.get("v.isPrimaryPartnerApprover") && !component.get("v.isActivatingPartnerApprover") && !component.get("v.isIPAAccountMgrAndPCTApprover")){
             	this.sendActivityForExternalApproval(component); 
            //TWC702-1949: [Technical] [X-Platform] - Account Based PCT approvers - Added PCT Reviewer
            } else if ((btnValue == 'Approve' || btnValue == 'Reject' || btnValue == 'Recall') && (component.get('v.externalUser') || (component.get("v.rejectInternalVisble") || component.get("v.isOpalActApprovalRequired") || component.get("v.isPCTReviewer") || component.get("v.isLevel1Approver") || component.get("v.isLevel2Approver") || component.get("v.isPORApprover")||component.get("v.isGeoLeadApprover") || component.get("v.isL1PrimaryPartnerApprover") || component.get("v.isL2PrimaryApprover") || component.get("v.isL1ActivatingPartnerApprover") || component.get("v.isPrimaryPartnerApprover") || component.get("v.isActivatingPartnerApprover") || component.get("v.isIPAAccountMgrAndPCTApprover")))) {
                var mapInstance = component.get("v.pfrMapInstance");
                var mapStatusInstance = component.get("v.statusMapInstance");
                mapStatusInstance['Approval Action Comment'] = btnValue; //component.get("v.approvalComments");
                mapInstance[pfrId] = mapStatusInstance;                
                var aprAction = component.get("c.approveRejectActivity");
                aprAction.setParams({
                "mapValues": mapInstance,
                "approvalComments" : component.get("v.approvalComments"),
                "isExternal" : component.get('v.externalUser')
                })

                aprAction.setCallback(this, function (response) {
                    var stateSave = response.getState();
                    var res = response.getReturnValue();
                    var msgTxt = '';
                    var resValue = 'true';
                    
                    if(stateSave === "SUCCESS"){
                        if(res == resValue){
                        var msgTxt = '';
                        if (btnValue == 'Approve') {
                            msgTxt = $A.get("$Label.c.Core_MDF_Activity_Approved");
                        }  
                        else if (btnValue == 'Reject') {
                            msgTxt = $A.get("$Label.c.Core_MDF_Activity_Rejected");
                        } 
                        else if (btnValue == 'Recall') {
                            msgTxt = $A.get("$Label.c.Core_MDF_Activity_Recall_Msg");
                        }
                            
                    this.toastMessage($A.get("$Label.c.Core_MDF_Success"),'success',msgTxt);
                    this.windowTimeOut();
                    }else{
                      if (btnValue == 'Approve' || btnValue == 'Reject' || btnValue == 'Recall') {
                         msgTxt = res;
                      }
                         this.toastMessage("Error",'error',msgTxt);
                    	 this.windowTimeOut();
                   }          
                }      
                });    
                $A.enqueueAction(aprAction);               
 
                //Manasa
                //$A.get('e.force:refreshView').fire();
            }
            else if (btnValue == 'Submit for Approval') {
                var pfrIDs = [];
                pfrIDs.push(component.get("v.recordId"));
                var action = component.get("c.submitForApproval");
                action.setParams({
                    "pfrIds": pfrIDs,
                    "approvalComments" : component.get("v.approvalComments")
                })
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        
                        this.toastMessage($A.get("$Label.c.Core_MDF_SuccessToastTitle"),'success',$A.get("$Label.c.Core_MDF_Activity_SubmittedForApproval"));
                        this.windowTimeOut();
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },
    toastMessage : function(toastTitleLabel,toastTypeLabel,toastMessageLabel){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: toastTitleLabel,
            type: toastTypeLabel,
            message: toastMessageLabel,
            mode: 'sticky',
        });
        toastEvent.fire();  
    },
    windowTimeOut : function(){
        window.setTimeout(
            $A.getCallback(function () {
                window.location.reload();
            }), 3000
        );
    },
    sendActivityForExternalApproval : function(component){
        var pfrIDs = [];
        pfrIDs.push(component.get("v.recordId"));
        var action = component.get("c.submitForApprovalClosed");
        action.setParams({
        "pfrIds": pfrIDs,
         "comments" : component.get("v.approvalComments")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.toastMessage($A.get("$Label.c.Core_MDF_SuccessToastTitle"),'success',$A.get("$Label.c.Core_MDF_Activity_Approved"));
                this.windowTimeOut();
            }
        });
        $A.enqueueAction(action);
    },
    //common toast event to handle success and error scenarios
    fireToastEvent: function (message, duration, type) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            duration: duration,
            key: "info_alt",
            type: type,
            mode: 'sticky',
        });
        toastEvent.fire();
    }
})