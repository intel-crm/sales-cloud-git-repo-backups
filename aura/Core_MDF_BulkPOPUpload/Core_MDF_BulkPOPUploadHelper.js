({
    initiateComponent: function (component, event, helper) {
       
        component.set("v.spinner",true);
        var action = component.get("c.fetchPendingDocumentsRecords"); 
        action.setParams({clmBatchId : component.get("v.recordId")});
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
        var rowIndex = event.getSource().get("v.name");
        var bulkClaimData = component.get("v.bulkClmStgRecData");
        var row = bulkClaimData[rowIndex];

        // Roshan - Tactics POC
        var isOutcomeBased = row.Core_MDF_ActivityCategory__c === $A.get("$Label.c.Core_MDF_Outcome_Based_CatType");
        component.set("v.claimAttributeList", []);

        component.set("v.clmBatchStgRec", row);
        var action = component.get("c.fetchActivityDetails");
        action.setParams({
            activityNbr: row.Core_MDF_Activity_Nbr__c
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                var budgetType = response.getReturnValue().Core_MDF_Budget_Type_nm__c;
                component.set("v.budgetType", budgetType);
            } else {
                this.showToast(component, event, "Error", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });
        $A.enqueueAction(action);
        
        var claimStageList = [row];
        claimStageList[0].Core_MDF_Processing_Status_Nm__c = "Submitted";
        var createClaimInstanceAction = component.get("c.createClaimInstanceAction");
        createClaimInstanceAction.setParams({
            stageList: claimStageList
        });
        createClaimInstanceAction.setCallback(this, function (result) {
            if (result.getState() === "SUCCESS" && result.getReturnValue() != null) {
                var claimInstanceList = result.getReturnValue();
                claimInstanceList[0].Core_MDF_Reimbursement_Percent__c = row.Core_MDF_Reimbursement_Percent_Nbr__c;
                claimInstanceList[0].Core_MDF_Program__c = row.Core_MDF_Program_Txt__c;
                claimInstanceList[0].Core_MDF_Budget_Type_Options_Nm__c = row.Core_MDF_Budget_Type_Nm__c;
                claimInstanceList[0].Core_MDF_Ultimate_Account_ID__c = row.Core_MDF_Ultimate_Account_ID__c;
                claimInstanceList[0].Core_MDF_AccountCompany__c = row.Core_MDF_Ultimate_Account_Txt__c;
                claimInstanceList[0].Core_MDF_Activity_Types__c = row.Core_MDF_Activity_Type_Nm__c;
                claimInstanceList[0].Core_MDF_Activity_Category__c = row.Core_MDF_ActivityCategory__c;
                component.set("v.simpleNewClaim", claimInstanceList[0]);
                console.log("claim --->", claimInstanceList[0]);

                // Roshan - Tactics POC
                if (isOutcomeBased) {
                    component.set("v.spinner", true);
                    component.set("v.openTacticsSection", true);
                    component.set("v.selectedTacticsActivityId", row.Core_MDF_Request_Id__c);
                    this.loadCampaignPurpose(component, row);
                } else {
                    component.set("v.openPopUp", true);
                    component.set("v.openManageAuditDocPopup", true);//added to open manage audit document section on click of upload
                }
            } else {
                this.showToast(component, event, "Error", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });
        $A.enqueueAction(createClaimInstanceAction);
    },

    loadCampaignPurpose: function (component, batchRow) {
        component.set("v.campaignPurposeColumns", []);
        component.set("v.campaignPurposeRows", []);

        var action = component.get("c.getCampaignPurposeDetails");
        action.setParams({
            activityId: component.get("v.selectedTacticsActivityId"),
            claimId: null
        });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                var result = response.getReturnValue();
                if (result.showTacticMetric) {
                    this.setCampaignPurposeColumns(component, result);
                    this.setCampaignPurposeRows(component, result);
                }
                this.calculateAmountFields(component, batchRow);
            } else {
                component.set("v.spinner", false);
                this.showToast(component, null, "error", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
            }
        });

        $A.enqueueAction(action);
    },

    setCampaignPurposeColumns: function (component, result) {
        component.set("v.campaignPurposeColumns", [
            { label: result.outcomeMetricLabel, fieldName: "outcome", displayField: "outcomeLabel", editable: false },
            { label: result.baselineQuantityLabel, fieldName: "baselineQuantity", editable: false, type: "number", required: false, min: 1, max: 2147483647, step: 1, helpText: result.baselineQuantityHelpText },
            { label: result.goalQuantityLabel, fieldName: "goalQuantity", editable: false, type: "number", required: false, min: 1, max: 2147483647, step: 1, helpText: result.goalQuantityHelpText },
            { label: result.quantityToDateLabel, fieldName: "quantity", editable: true, type: "number", required: true, min: 0, max: 2147483647, step: 1, helpText: result.quantityToDateHelpText },
            { label: result.outcomeCriteriaLabel, fieldName: "outcomeCriteria", editable: false, type: "textarea", maxLength: 1000, required: false, helpText: result.outcomeCriteriaHelpText }
        ]);
    },

    setCampaignPurposeRows: function (component, result) {
        component.set("v.campaignPurposeRows", [{
            id: "1",
            outcome: result.outcomeMetric,
            outcomeLabel: result.outcomeMetric,
            baselineQuantity: result.baselineQuantity,
            goalQuantity: result.goalQuantity,
            quantity: result.quantityToDate,
            outcomeCriteria: result.outcomeCriteria
        }]);
    },

    handleCampaignPurposeChange: function (component, event, helper) {
        var updatedRows = event.getParams("detail")[0];
        component.set("v.simpleNewClaim.Core_MDF_Quantity_to_Date_Nbr__c", parseInt(updatedRows.quantity));
    },

    calculateAmountFields: function (component, batchRow) {
        let claimRecord = Object.assign({}, component.get("v.simpleNewClaim"));
        claimRecord.Core_MDF_Reimbursement_Percent__c = batchRow.Core_MDF_Reimbursement_Percent_Nbr__c;
        claimRecord.Core_MDF_Currency__c = batchRow.Core_MDF_Inv_Receipt_Cur_Cd__c;
        claimRecord.Core_MDF_Total_Invoice_Amount_Local__c = batchRow.Core_MDF_Total_Amt__c;
        claimRecord.Core_MDF_OtherCostsnotReimbursable_Local__c = batchRow.Core_MDF_Non_Reimbursable_Amt__c;
        claimRecord.Core_MDF_Taxes_Local__c = batchRow.Core_MDF_Taxes_Local_Amt__c;
        component.set("v.simpleNewClaim", claimRecord);

        var amountFields = {
            totalAmountLocal: batchRow.Core_MDF_Total_Amt__c,
            costNotReimbursable: batchRow.Core_MDF_Non_Reimbursable_Amt__c,
            taxesLocal: batchRow.Core_MDF_Taxes_Local_Amt__c
        };
        var action = component.get("c.calculateAmountFields");
        action.setParams({
            pfcList: claimRecord,
            amountFields: JSON.stringify(amountFields)
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.Core_MDF_Reimbursable_Transaction_Amount__c) {
                    component.set('v.reimbursableAmountUsd', result.Core_MDF_Reimbursable_Transaction_Amount__c);
                }
            } else {
                let errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.handleServerExceptions(component, errorMessage);
            }
            component.set("v.spinner", false);
        });

        $A.enqueueAction(action);
    },

    closeTacticsModal: function (component) {
        component.set("v.openTacticsSection", false);
        component.set("v.selectedTacticsActivityId", null);
        component.set("v.reimbursableAmountUsd", null);
        component.set("v.campaignPurposeColumns", []);
        component.set("v.campaignPurposeRows", []);
        component.set("v.claimAttributeList", []);
        component.set("v.simpleNewClaim.Core_MDF_Quantity_to_Date_Nbr__c", null);
        component.set("v.spinner", false);
    },

    saveTacticsAction: function (component, event, helper) {
        var isCampaignPurposeValid = true;
        if (component.find("campaignPurposeCmp")) {
            isCampaignPurposeValid = component.find("campaignPurposeCmp").validate().isValid;
        }

        var tacticMetricResult = this.validateTacticMetric(component);
        var tacticSpendingResult = this.validateTacticSpending(component);
        var isMetricValid = tacticMetricResult.valid;
        var isSpendingValid = tacticSpendingResult.valid;

        if (!isCampaignPurposeValid || !isMetricValid || !isSpendingValid) {
            // this.showToast(component, null, "error", "Please fill all tactics.");
            return;
        }

        var finalClaimAttributeList = [];
        if (tacticSpendingResult.claimAttributes.length > 0) {
            finalClaimAttributeList = finalClaimAttributeList.concat(tacticSpendingResult.claimAttributes);
        }
        if (tacticMetricResult.claimAttributesObj.length > 0) {
            finalClaimAttributeList = finalClaimAttributeList.concat(tacticMetricResult.claimAttributesObj);
        }
        component.set("v.claimAttributeList", finalClaimAttributeList);
        component.set("v.clmBatchStgRec.Core_MDF_Claim_Attributes_JSON_txt__c", JSON.stringify(finalClaimAttributeList));
        console.log('claimAttributeList@@@', component.get("v.claimAttributeList"));

        component.set("v.openTacticsSection", false);
        component.set("v.spinner", false);
        component.set("v.openPopUp", true);
        component.set("v.openManageAuditDocPopup", true);
    },

    navigateBackToTactics: function (component) {
        component.set("v.openManageAuditDocPopup", false);
        component.set("v.openPopUp", false);
        component.set("v.openTacticsSection", true);
        component.set("v.spinner", false);
    },

    validateTacticMetric: function (component) {
        const tacticMetricCmp = component.find("tacticMetricCmp");
        const result = tacticMetricCmp ? tacticMetricCmp.validate() : true;
        let finalResult = { valid: result, claimAttributesObj: [] };
        if (result && tacticMetricCmp) {
            finalResult.claimAttributesObj = tacticMetricCmp.getAllMatricValueforRecordcreation();
        }
        return finalResult;
    },

    validateTacticSpending: function (component) {
        const tacticSpendingCmp = component.find("tacticSpendingCmp");
        const result = tacticSpendingCmp ? tacticSpendingCmp.validate() : true;
        let finalResult = { valid: result, claimAttributes: [] };
        if (result && tacticSpendingCmp) {
            finalResult.claimAttributes = tacticSpendingCmp.prepareClaimAttributes();
        }
        return finalResult;
    },

    saveClaimResult: function (component, event, helper) {
        component.set("v.spinner",true);
        var action = component.get("c.saveClaim");
        action.setParams({
                //"claim": component.get("v.simpleNewClaim"),
                claimBatchRec: component.get("v.clmBatchStgRec"),
                auditDocList: component.get("v.auditDocument"), //POP
                claimAttributeList: component.get("v.claimAttributeList"),
                quantityToDate: component.get("v.simpleNewClaim.Core_MDF_Quantity_to_Date_Nbr__c")
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
        var errorToastModal = component.find("errorToast");
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
    getMiniLayout: function (component, event) {
        var getAllClaimRec = component.get("v.bulkClmStgRecData");
        for (var i = 0; i < getAllClaimRec.length; i++) {
            if (getAllClaimRec[i].Id === component.get("v.reId")) {
                component.set("v.mouseHoverData", getAllClaimRec[i]);
                break;
            }
        }
        console.log("hover" + component.get("v.mouseHoverData"));
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
    },

    showToast: function(component, event, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: type,
            key: "info_alt",
        });
        toastEvent.fire();
    }
});