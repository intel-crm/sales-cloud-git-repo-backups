({
    initiateComponent: function (component, event, helper) {
       
        component.set("v.spinner",true);
        var action = component.get("c.fetchPendingDocumentsRecords"); 
        action.setParams({clmBatchId : component.get('v.recordId')});
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
                if(result!= null &&  result.length > 0){
                    component.set("v.clmBatchStgRecExists",true);
                    component.set("v.bulkClmStgRecData", response.getReturnValue());
                }
                else{
                    component.set("v.clmBatchStgRecExists",false);
                }
                component.set("v.spinner",false);
                }            
            else if(response.getState() === "ERROR"){
                component.set("v.spinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    message: $A.get(
                        "$Label.c.Core_MDF_ApplicationErrorMessage"
                    ),
                    duration: "5000",
                    key: "info_alt",
                    type: "error"
                });
                toastEvent.fire();}
                
        });
        $A.enqueueAction(action);

        // This is to fetch the By-pass indicator of Core_MDF_Log_Info_txt__c field mapping.
        this.fetchLogInfoByPassCheckValue(component);
    }, 
    
  uploadAction: function (component, event, helper) {
      			var target = event.target;
        		var rowIndex = target.getAttribute("data-row-index");
      			var bulkClaimData = component.get("v.bulkClmStgRecData");
      			var row = bulkClaimData[rowIndex];
                component.set("v.clmBatchStgRec",row);
                var action = component.get("c.fetchActivityDetails");
                action.setParams
                ({
                    activityNbr: component.get("v.clmBatchStgRec.Core_MDF_Activity_Nbr__c")
                })
                action.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                        var budgetType = response.getReturnValue().Core_MDF_Budget_Type_nm__c;
                        component.set('v.budgetType', budgetType);
                    }            
                    else {this.showToast(component, event, 'Error', $A.get("$Label.c.Core_MDF_ApplicationErrorMessage")); }
                });
                $A.enqueueAction(action);
        
        var claimStageList = [row];
        claimStageList[0].Core_MDF_Processing_Status_Nm__c = 'Submitted';
        var createClaimInstanceAction = component.get("c.createClaimInstanceAction");
        createClaimInstanceAction.setParams
        ({
            stageList :claimStageList
        })
        createClaimInstanceAction.setCallback(this, function (result) {
            console.log("callback");
            if (result.getState() === "SUCCESS" && result.getReturnValue()!= null) {
                var claimInstanceList = result.getReturnValue();
                claimInstanceList[0].Core_MDF_Reimbursement_Percent__c = row.Core_MDF_Reimbursement_Percent_Nbr__c;
                claimInstanceList[0].Core_MDF_Program__c = row.Core_MDF_Program_Txt__c;
                claimInstanceList[0].Core_MDF_Budget_Type_Options_Nm__c=row.Core_MDF_Budget_Type_Nm__c;
                claimInstanceList[0].Core_MDF_Ultimate_Account_ID__c=row.Core_MDF_Ultimate_Account_ID__c;
                claimInstanceList[0].Core_MDF_AccountCompany__c=row.Core_MDF_Ultimate_Account_Txt__c;
                claimInstanceList[0].Core_MDF_Activity_Types__c=row.Core_MDF_Activity_Type_Nm__c;
		claimInstanceList[0].Core_MDF_Activity_Category__c =row.Core_MDF_ActivityCategory__c;
                component.set("v.simpleNewClaim",claimInstanceList[0]);
                console.log('claim --->',claimInstanceList[0]);
                component.set("v.openPopUp",true);
                component.set("v.openManageAuditDocPopup", true);//added to open manage audit document section on click of upload
            }            
            else {
                this.showToast(component, event, 'Error', $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });
        $A.enqueueAction(createClaimInstanceAction);
        //component.set("v.openPopUp",true);
            },

    saveClaimResult: function (component, event, helper) {
	    component.set("v.spinner",true);
            var action = component.get("c.saveClaim");
           action.setParams({
                //"claim": component.get("v.simpleNewClaim"),
                "claimBatchRec": component.get("v.clmBatchStgRec"),
                "auditDocList": component.get("v.auditDocument") //POP
            });
        action.setCallback(this, function (saveResult) {
            if (saveResult.getState() === "SUCCESS" && saveResult.getReturnValue() != null && !saveResult.getReturnValue().startsWith('Exception')) {
                component.set("v.spinner", false);
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: $A.get(
                        "$Label.c.Core_MDF_Manage_Document_Submit_Success_Message"
                    ),
                    duration: "5000",
                    key: "info_alt",
                    type: "success"
                });
                toastEvent.fire();

                component.set("v.isConfirmPopupVisible", false);
                component.set("v.openPopUp", false);
                this.initiateComponent(component, event, helper);
                component.set("v.isSaveDisabled",false);
                component.set("v.spinner",false);
                    
                }
                else if (saveResult.getState() === "ERROR" || (saveResult.getReturnValue() != null && saveResult.getReturnValue().startsWith('Exception'))) {
                    // Call the function to Handle the Server Exceptions
                    var error = JSON.stringify(saveResult.getError());
                    this.handleServerExceptions(component, saveResult.getReturnValue());
                    component.set("v.isSaveDisabled",false);
                    component.set("v.spinner",false);
                }
                else {
                    this.showToast(component, event, 'Error', $A.get("$Label.c.Core_MDF_ApplicationErrorMessage")); 
                    component.set("v.isSaveDisabled",false);
                    component.set("v.spinner",false);
                }
            });
            
            $A.enqueueAction(action);
        },
    
    handleServerExceptions: function (component, returnValue) {
        
        // Error! Show Validation message through a toast UI message
        // Show error Modal
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.isError", true);
        component.set("v.spinner", false);
        var exceptionerrors = returnValue;
        
        // check if exceptionerrors is null or not
        if (exceptionerrors != null && exceptionerrors.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            // process the error message here
            // if its validation error message
            var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 1);
            var err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
            var errorMsg = err.substring(err.indexOf(',') + 1);
            component.set("v.claimErrorMsg", errorMsg);
        }
        else {
            // show general error message
            var genericMsg = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            component.set("v.claimErrorMsg", genericMsg);
        }
        
        //Auto hide error modal after 4sec
        window.setTimeout($A.getCallback(function () {
            if (component.isValid()) {
                $A.util.addClass(errorToastModal, "slds-hide");
            }
        }), 4000);
        component.set("v.isSaveDisabled", false);
    },
     //This function is used to show error toast message
    populateErrorToastModal: function (component) {
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.isError", true);
        component.set("v.spinner", false);
       /* //Auto hide error modal after 10sec
        window.setTimeout($A.getCallback(function () {
            if (component.isValid()) {
                $A.util.addClass(errorToastModal, "slds-hide");
            }
        }), 10000); */
        component.set("v.isSaveDisabled", false);
    },
    getMiniLayout:function(component, event, helper){
        
        var getAllClaimRec = component.get('v.bulkClmStgRecData');
        for(var i=0;i<getAllClaimRec.length;i++){
            if(getAllClaimRec[i].Id == component.get("v.reId")){
                component.set('v.mouseHoverData',getAllClaimRec[i]);
                break;
            }
        }
        console.log('hover'+component.get('v.mouseHoverData'));
        component.set("v.hoverRow", parseInt(event.target.dataset.index));
        component.set("v.togglehover",true);
    },

    fetchLogInfoByPassCheckValue : function(component){
        var action = component.get("c.fetchLogInfoByPassCheckValue");
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                if (res.getReturnValue()) {
                    component.set("v.byPassLogInfoFieldMapping", res.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    update3rdPartyDetails: function (component, thirdPartyWrapper) {

        component.set("v.clmBatchStgRec.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c",thirdPartyWrapper.isThirdPartyPOP);
        component.set("v.clmBatchStgRec.Core_MDF_Review_Hold_Rule_Nm__c",thirdPartyWrapper.ruleId);

        if(!component.get('v.byPassLogInfoFieldMapping')){
            //Claim Batch Stage Details
            var claimBatchStageDetails = 'Claim Details: \n Claim Stage Id: ' + component.get("v.clmBatchStgRec.Id") + 
                                ', Core_MDF_3rd_Party_POP_Doc_Required_Ind__c: ' + component.get("v.clmBatchStgRec.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c") + 
                                ', Core_MDF_Activity_Types__c: ' + component.get("v.clmBatchStgRec.Core_MDF_Activity_Type_Nm__c") +
                                ', Core_MDF_Ultimate_Account_ID__c: ' + component.get("v.clmBatchStgRec.Core_MDF_Ultimate_Account_ID__c") +
                                ', Core_MDF_Total_Invoice_Amount_Local__c: ' + component.get("v.clmBatchStgRec.Core_MDF_Total_Amt__c") + 
                                ', Core_MDF_Program__c: ' + component.get("v.clmBatchStgRec.Core_MDF_Program_Txt__c") + 
                                ', Core_MDF_Budget_Type_Options_Nm__c: ' + component.get("v.clmBatchStgRec.Core_MDF_Budget_Type_Nm__c") + '\n\n';

            //Rule engine details
            var ruleEngineDetails = 'Rule Engine Details: \n ' + JSON.stringify(thirdPartyWrapper) + '\n\n\n';

            var thirdPartyDetails = '';

            //Adding Claim details
            if(claimBatchStageDetails != undefined){
                thirdPartyDetails = claimBatchStageDetails;
            }

            //Adding Rule engine details
            if(ruleEngineDetails != undefined){
                thirdPartyDetails += ruleEngineDetails;
            }

            //Add existing Core_MDF_Log_Info_txt__c field value incase of Update
            thirdPartyDetails = component.get("v.clmBatchStgRec.Core_MDF_Log_Info_txt__c") != null ? (thirdPartyDetails + component.get("v.clmBatchStgRec.Core_MDF_Log_Info_txt__c")) : thirdPartyDetails;
            //Get first 100000 characters
            thirdPartyDetails = (thirdPartyDetails != undefined) ? thirdPartyDetails.slice(0,100000) : '';

            component.set("v.clmBatchStgRec.Core_MDF_Log_Info_txt__c", thirdPartyDetails);
                    
            //console.log('Core_MDF_Log_Info_txt__c' + thirdPartyDetails);
        }
    }
})