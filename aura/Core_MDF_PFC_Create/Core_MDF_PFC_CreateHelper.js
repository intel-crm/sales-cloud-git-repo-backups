({
    // doInit method to initialize all the required parameters on Page Load. 
    doInit: function (component, event, helper) {
        this.checkIsClaimEzyEnabled(component);
        let fileFormats = $A.get("$Label.c.Core_MDF_AllowedFileTypes_POC").split(",");
        component.set("v.accept", fileFormats);
        let title = $A.get("$Label.c.Core_MDF_Campaign_Purpose") + ' (' + $A.get("$Label.c.Core_MDF_Brand_and_Technology") + ')';
        component.set("v.tableTitle", title);
        this.partnerEffortMetricforClaimCreation(component);
        // Setting Spinner to true
        component.set("v.spinner", true);
        //This is to fetch record type meta data map and set activity record type developer name
        this.fetchRecordTypeMetaData(component);
        //To identify Partner User
        this.fetchMemberPartnerDetails(component);
        console.log("simple new claim", JSON.stringify(component.get("v.simpleNewClaim")));
        //This is to fetch Applicable VAT Percentage Picklist field values
        this.fetchApplicableVATPercentagePicklistValues(component);
    
        //To identify weather its clone or EDit claim process
        if (component.get("v.simpleNewClaim.Id") != '' && component.get("v.simpleNewClaim.Id") != undefined) {
            //Setting simple new caim Id to temporary field, which is used in loadKPIAttributes payload
            component.set('v.clonedClaimId', component.get("v.simpleNewClaim.Id"));
                        if (component.get("v.isCloneClaim")) {
                //TWC3117-2558-while cloning a claim from CSC claim submitter, the owner is getting stamped with previous claim's owner.
                //empty the claim submitter id in case of clone claim
                component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c", "");
                component.set("v.isClaimEdit", false);
                this.onCloneClaim(component);
                //It would clean up claim id on Clone Claim 
                this.clearUpClaimIdOnClone(component);
                this.getTacticInformation(component, event, helper);//IPA-Jegan
            }
            else {
                component.set("v.isClaimEdit", true);
                component.set("v.oldVATOptIn", component.get("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c"));
                component.set("v.oldBankId", component.get("v.simpleNewClaim.Core_MDF_Bank__c"));
                component.set("v.oldApplicableVatPer", component.get("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c"));
                this.onEditClaim(component);
                this.getTacticInformation(component, event, helper);//IPA-Jegan
                //Added by VB - AI PIC
                let program = component.get("v.simpleNewClaim.Core_MDF_Program__c");
                let programsEnabledForAIPIC = $A.get("$Label.c.Core_MDF_AI_POP_Validation_EnabledPrograms").split(';');
                if (programsEnabledForAIPIC.includes(program)) {
                    component.set("v.isProgramEnabledForAIPIC", true);
                    this.getClaimFieldsForAIPICProcess(component, event, helper);
                }
            }
            let claimStartDate = component.get("v.simpleNewClaim.Core_MDF_Ad_Run_Start_Date__c");
            this.handleStartDateChange(component, event, helper, claimStartDate);
        }
        // Vat OptIn PicklistValues	 
        //this.getVatOptInPicklistValues(component,event);  
        // This is to fetch the Invoice Currency Picklist and Logged In User Info
        this.fetchUserAndPicklistInfo(component);
    
        // This is to fetch page URL to redirect to the list view
        this.getPageUrl(component);
        component.set("v.isError", false);
        // Setting Spinner to false
        //component.set("v.spinner", false);
    
        // This is to fetch the By-pass indicator of Core_MDF_Log_Info_txt__c field mapping.
        this.fetchLogInfoByPassCheckValue(component);
	
        // This is to populate the Processing Preference on claim
        this.setPayTypeDefaultValuePicklist(component);
    },
    
    // This method is to set Claim record type on the basis of Activity Record Type
    setClaimActivityAttributes: function (component) {
        // This method sets the status filter on Activity Lookup
        this.setActivityFilter(component);
        if (component.get("v.recordId") != '' && component.get("v.recordId") != undefined) {
            this.createClaimFromEscalationOrActivity(component);
        } else {
            //Checking for record type and setting the record type Variable 
            // Edit/Clone
            if (!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim").RecordType)) {
                //to hold claim record type developer name
                var claimRecordType = component.get("v.simpleNewClaim").RecordType.DeveloperName;
                                //Setting selected claim record type
                component.set('v.recordtypeDeveloperName', claimRecordType);
            }
            // On Create/Edit/Clone
            if (!$A.util.isUndefinedOrNull(component.get('v.recordTypeMap'))) {
                var claimRecordType = component.get('v.recordtypeDeveloperName');
                if (component.get('v.recordTypeMap').hasOwnProperty(claimRecordType)) {
                    component.set('v.activityRecordTypeDevName', (component.get('v.recordTypeMap')[claimRecordType]).Core_MDF_Activity_RecordType_txt__c);
                    component.set('v.isActivityProposalBasedInd', (component.get('v.recordTypeMap')[claimRecordType]).Core_MDF_isProposalBased__c);
                     component.set('v.claimProgramName', component.get('v.Core_MDF_Program__c'));
                                        //Assign POPMandatory and swapRetailFields flag
                    this.assignRecordTypeMetaDataValues(component);
                }
            }
        }
    },
    
    //This helper function is used to set activity status filter, whcih is used in activity lookup
    setActivityFilter: function (component) {
        // To get the activity status to create claim
        var activityStatusToCreateClaim = ($A.get("$Label.c.Core_MDF_PFR_Status_CreateClaim")).split(";");
    
        //To get Activity Closure Type
        var activityClosureType = ($A.get("$Label.c.Core_MDF_Activity_Closure_Type_to_create_claim")).split(";");
    
        // Closed activity should be available in look up in case if Claim case reveiwer or Manager or CSC Claim submitter creates claim
        if (component.get("v.isUserClaimCaseReviewerOrManager")||component.get("v.isCSCClaimSubmitter")) {
            activityStatusToCreateClaim = activityStatusToCreateClaim.concat($A.get("$Label.c.Core_MDF_Claim_Activity_Closed_Status"));
        }
    
        component.set('v.activityStatusList', activityStatusToCreateClaim);
        var activityStatusCommaSeparated = "@quote;" + activityStatusToCreateClaim.join("@quote;,@quote;") + "@quote;";
        component.set('v.activityStatusCommaSeparated', activityStatusCommaSeparated);
    
        component.set('v.activityClosureTypeList', activityClosureType);
        var activityClosureTypeSeparated = "@quote;" + activityClosureType.join("@quote;,@quote;") + "@quote;";
        component.set('v.activityClosureTypeSeparated', activityClosureTypeSeparated);
    
        var searchCriteria = 'Core_MDF_Fund_Request_Status__c IN (' + activityStatusCommaSeparated + ')' + 'AND Core_MDF_Activity_Closure_Type__c NOT IN (' + activityClosureTypeSeparated + ')';
        component.set('v.activitySearchCriteria', searchCriteria);
    
    },
    
    //This helper function is used to set escalation id and activity id when claim create from escalation
    //and fetch activity details , when claim create from activity
    createClaimFromEscalationOrActivity: function (component) {
        //fetch Activity from Escalation
        var escActId = component.get("v.escActivityId");
        var escalationId = component.get("v.escalationId");
        // Create Claim from escalation
        if (escActId != '' && !$A.util.isUndefinedOrNull(escActId) && escalationId != '' && !$A.util.isUndefinedOrNull(escalationId)) {
                        //Function calls in case, claim create from Escalation
            component.set("v.simpleNewClaim.RequestId", escActId);
            component.set("v.sObjectId", escActId);
            //Function calls in case, claim create from Escalation
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c", escalationId);            
            //used in case of clear lookup
            component.set("v.escObjectId", escalationId);
        }
        else { // Create Claim from activity
            //Function calls in case, claim create from activity
            this.getActivityDtlsByRecordId(component);
        }
    },
    
    //This helper function is used to validate claim form
    validateClaimForm: function (component) {
        // Show error messages if required fields are blank
        var validClaim = true;
        var auraIds = [];
        switch (component.get('v.recordtypeDeveloperName').toUpperCase()) {
            case $A.get("$Label.c.Core_MDF_Claim_SPCF_Program").toUpperCase():
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_SPCF").split(",");
                break;
    
            case $A.get("$Label.c.Core_MDF_RetailProgram").toUpperCase():
                if (component.get('v.budgetType') == $A.get("$Label.c.Core_MDF_RetailMDF_BudgetType")) {
                    auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_RMF_MDF").split(",");
                }
                else {
                    auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_RSA_MD").split(",");
                }
                break;
            case $A.get("$Label.c.Core_MDF_IPA_RecordType").toUpperCase():
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_IPA").split(",");
                if (component.get("v.hideBank")) {//IPABankHide
                    auraIds = auraIds.filter(e => e !== 'claimBank');
                }
                break;
            case $A.get("$Label.c.Core_MDF_IPA_AccountBased_RecType_DevName").toUpperCase():
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_IPA_Acct_Based").split(",");
                if (component.get("v.hideBank")) {//IPABankHide
                    auraIds = auraIds.filter(e => e !== 'claimBank');
                }
                break;            
                case $A.get("$Label.c.Core_MDF_EEF_RecordType").toUpperCase():
                    auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_EEF").split(",");
                    if (component.get("v.hideBank")) {//IPABankHide
                        auraIds = auraIds.filter(e => e !== 'claimBank');
                    }
                break;
            //ananth changes 
            case $A.get("$Label.c.Core_MDF_Claim_COGTM_RecordType").toUpperCase():
                component.set("v.isCoGtm", true);
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_COGTM").split(",");
                if (component.get("v.hideBank")) {//IPABankHide
                    auraIds = auraIds.filter(e => e !== 'claimBank');
                }
                break;
            // end

    
            default:
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_CCF_DCF_Boost").split(",");
                if (this.isOEMRecordType(component)) {
                    if (component.get("v.hideBank") == true) {
                        auraIds = auraIds.filter(e => e !== 'claimBank');
                    }
                    //For Opal budget types check and remove the tax field population
                    var opalBudgetTypes = ($A.get("$Label.c.Core_MDF_ClaimEzy_Taxes_Not_Applicable")).split(";");
                    if (opalBudgetTypes.includes(component.get('v.budgetType'))) {
                        auraIds = auraIds.filter(e => e !== 'claimTaxesLocal');
                        component.set("v.simpleNewClaim.Core_MDF_Taxes_Local__c", 0);  
                    }
                }
        }
    
        for (var i = 0; i < auraIds.length; i++) {
            if (auraIds[i] != "activityId" && auraIds[i] != "activityIdRetail") {
    
                var inputCmp = component.find(auraIds[i]);
                var inputCmpValidity = inputCmp.get("v.validity").valid;
                if (inputCmpValidity == false) {
                    inputCmp.showHelpMessageIfInvalid();
                    validClaim = false;
                }
            }
    
            else {
                var activityCmp;
                if (component.get('v.isClaimActivitySwap')) {
                    activityCmp = component.find("activityIdRetail");
                } else {
                    activityCmp = component.find("activityId");
                }
                if (activityCmp.get("v.value") == '') {
                    validClaim = false;
                }
    
            }
        }
        return validClaim;
    },
    
    // This method clears Claim Id for Clone , since its clone claim and It will create New record
    clearUpClaimIdOnClone: function (component) {
        if (component.get("v.isCloneClaim")) {
            component.set("v.simpleNewClaim.Id", null);
        }
    },
    
    
    // This method clears Claim Id for Clone , since its clone claim and It will create New record
    isOEMRecordType: function (component) {
        var technicalProgName = component.get("v.technicalProgName").toUpperCase();
        if (technicalProgName == $A.get("$Label.c.Core_MDF_NonTranslateCCFRecordType").toUpperCase() || technicalProgName == $A.get("$Label.c.Core_MDF_NonTranslateDCFRecordType").toUpperCase()) { //Areefa 7/6/21
            return true;
        }
        else {
            return false;
        }
    
    },
    /*This helper function is used to save claim data
    The if is executed when no documents are uploaded for a doc submission mandatory claim - claim create/clone
    The else if is executed when the mandatory document types are not uploaded for a doc submission mandatory claim - create/clone/edit of claim
    The else is executed when the above two conditions are not met */

    saveClaim: function (component, event, helper, actionType) {
        component.set("v.spinner", true);
        component.set("v.isDocumentTypeNotSelected", false);
        component.set("v.actionType", actionType);
        //console.log("manageAuditComponent.get('v.isSubmitEnabled')", manageAuditComponent.get('v.isSubmitEnabled'));
        //console.log("user access from manual audit comp", manageAuditComponent.get('v.sObjectDocumentWrapper.enableComponentOnDetail'));
        //console.log('is3rdPartyPOP1::',component.get("v.is3rdPartyPOP1"));
        if(component.get("v.isKpiSectionVisible")) {
            this.validateKPIFields(component, event, helper, 'save');
        } else {
            this.validateClaimBeforeSave(component, event, helper);
        }

    },
    
    validateClaimBeforeSave: function(component, event, helper) {
        var manageAuditComponent = component.find('manageAuditRevamp');
        if (this.isPOPMandatory(component)) {
            // Documents are Mandatory for Retail Program
            component.set("v.claimErrorMsg", $A.get("$Label.c.Core_MDF_RetailDocMandatoryError"));
            component.set("v.spinner", false);
            this.populateErrorToastModal(component);
        } else if (manageAuditComponent != null && manageAuditComponent.get("v.isDocSubmissionMandatory") && !manageAuditComponent.get("v.isAllMandatoryDocumentTypesSubmitted") && manageAuditComponent.get("v.auditDocumentDetailsWrapper") != null && manageAuditComponent.get("v.auditDocumentDetailsWrapper.enableDocumentUploadSection")) {
            // Mandatory Document Types for Retail - Proof of Branding;Proof of Execution
            component.set("v.claimErrorMsg", $A.get("$Label.c.Core_MDF_Mandatory_Document_Types_Error_Message"));
            component.set("v.spinner", false);
            this.populateErrorToastModal(component);
        } else {
            if (manageAuditComponent != null) {
                component.set("v.isDocSubmissionMandatory", manageAuditComponent.get("v.isDocSubmissionMandatory"));
                component.set("v.isAllMandatoryDocumentTypesSubmitted", manageAuditComponent.get("v.isAllMandatoryDocumentTypesSubmitted"));
                component.set("v.isClaimEligibleForPICReview", manageAuditComponent.get("v.isClaimEligibleForPICReview"));
            }
            this.checkDocumentTypesSelection(component);
            if (component.get("v.isDocumentTypeNotSelected")) {
                component.set("v.claimErrorMsg", $A.get("$Label.c.Core_MDF_Manage_Document_Error_Message"));
                component.set("v.spinner", false);
                this.populateErrorToastModal(component);
            } else {
                this.isClaimEligibleForPICReview(component, event, helper);
            }
        }
    },
    
    //Safe Check - To ensure that document type is selected all the time (Part of document uploaded without doucment type fix)
    checkDocumentTypesSelection: function (component) {
        let auditDocumentList = component.get("v.auditDocument");
        if (auditDocumentList.length > 0) {
            auditDocumentList.map(auditDoc => {
                if ($A.util.isUndefinedOrNull(auditDoc.Core_MDF_Document_Types__c) || $A.util.isEmpty(auditDoc.Core_MDF_Document_Types__c) || auditDoc.Core_MDF_Document_Types__c == "") {
                    component.set("v.isDocumentTypeNotSelected", true);
                }
            })
        }
    },
    
    //This medthod is to display 'Submit for PIC' popup conditionally
    isClaimEligibleForPICReview: function(component, event, helper) {
        let isClaimEligibleForPICReview = component.get("v.isClaimEligibleForPICReview");
        let isAllMandatoryDocumentTypesSubmitted = component.get("v.isAllMandatoryDocumentTypesSubmitted");
        if (isClaimEligibleForPICReview) {
            if (isAllMandatoryDocumentTypesSubmitted) {
                component.set("v.showConfirmationPopupForPIC", true);
                component.set("v.spinner", false);
            } else {
                this.isDocSubmissionPopupRequired(component, event, helper);
            }
        } else {
            this.isDocSubmissionPopupRequired(component, event, helper);
        }
    },
    //This method is to check whether document submission confirmation popup has to be displayed or not.
    isDocSubmissionPopupRequired: function (component, event, helper) {
        let isPICReviewCompleted = component.get("v.simpleNewClaim.Core_MDF_PIC_Review_Completed__c");
        let isLegacyClaim = component.get("v.simpleNewClaim.Core_MDF_Legacy_Claim_Ind__c");
        let isDocSubmissionMandatory = component.get("v.isDocSubmissionMandatory");
        if (isDocSubmissionMandatory) {
            if (isLegacyClaim) {
                this.canSubmitClaimForPIC(component, event, helper);
            } else {
                if (!isPICReviewCompleted) {
                    component.set("v.showConfirmationPopupForPIC", false);
                    component.set("v.isConfirmPopupVisible", true);
                    component.set("v.spinner", false);
                } else {
                    this.saveClaimMethods(component, event, helper);
                }
            }
        } else {
            component.set("v.showConfirmationPopupForPIC", false);
            this.canSubmitClaimForPIC(component, event, helper);
        }
    
    },
    
    //Update the claim status to PIC pending when Yes is selected from submit for PIC, else just save the claim.
    canSubmitClaimForPIC: function (component, event, helper) {
        if (component.get("v.isClaimSubmittedForPIC")) {
            this.updateClaimStatusToPICPending(component, event, helper);
        } else {
            this.saveClaimMethods(component, event, helper);
        }
    },
    
    isPOPMandatory: function (component) {
        var auditdocumentList = component.get("v.auditDocument");
        if (!component.get("v.isClaimEdit") && component.get('v.isPOPMandatory') &&
            auditdocumentList != null && auditdocumentList.length == 0) {
            return true;
        } else {
            return false;
        }
    },
    
    
    //This function is used to save claim or display error message if claim save fails
    saveClaimResult: function (component) {
        component.set("v.spinner", true);
        let hasAnyChangeOnClaim = false;
        this.setVATPercentageFor420and650(component);
        //Added by VB -> CDB AI Callout - enable for IPA ouctome based in future
        if (component.get("v.isProgramEnabledForAIPIC") && component.get("v.isClaimEdit") && !component.get('v.isOutcomeBased')) {
            hasAnyChangeOnClaim = this.validateEditsOnClaim(component);
        }
        //For Opal budget types check and remove the tax field population
    	var opalBudgetTypes = ($A.get("$Label.c.Core_MDF_ClaimEzy_Taxes_Not_Applicable")).split(";");
        if (opalBudgetTypes.includes(component.get('v.budgetType'))) {
            component.set("v.simpleNewClaim.Core_MDF_Taxes_Local__c", 0);  
        }
    
        var amountFields =
        {
            totalAmountLocal:component.get("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c"),
            costNotReimbursable:component.get("v.simpleNewClaim.Core_MDF_OtherCostsnotReimbursable_Local__c"),
            taxesLocal:component.get("v.simpleNewClaim.Core_MDF_Taxes_Local__c")
        };
        if(component.get("v.isClaimEdit") == false){
            component.set("v.simpleNewClaim.Core_MDF_StartTime_dtm__c", component.get("v.claimCreationStartTime"));
        }
        /**TWC3117-18501**/
        if (component.get("v.actionType") == "saveAsDraftClaim") {
            component.set("v.simpleNewClaim.Core_MDF_Status__c", "Draft");
        } else /**TWC3117-18501**/ if(component.get("v.actionType") == 'submitFinalOutcomeBasedClaim' && (component.get("v.isCoGtm") || component.get("v.simpleNewClaim.Core_MDF_Status__c") == undefined || component.get("v.simpleNewClaim.Core_MDF_Status__c") == '' || component.get("v.simpleNewClaim.Core_MDF_Status__c") == 'Draft')){ //TWC3117-18501 added isCoGtm check
            component.set("v.simpleNewClaim.Core_MDF_Status__c", "Pending Review");
            //TWC3117-18501
	    //component.set("v.simpleNewClaim.Core_MDF_Approval_Stage_nm__c", "Account Manager");
            var approvalStage = component.get("v.isCoGtm") 
                ? "Technical Approver"
                : "Account Manager";

            component.set("v.simpleNewClaim.Core_MDF_Approval_Stage_nm__c", approvalStage);
	    //TWC3117-18501
        }
        

        var action = component.get("c.saveClaim");
        var isClone =component.get("v.isCloneClaim");
        action.setParams({
            "claim": component.get("v.simpleNewClaim"),
            "auditDocList": component.get("v.auditDocument"),
            "amountFields": JSON.stringify(amountFields),
            "docId": component.get("v.invoiceDocId"),
            "isOutcomeBased": component.get('v.isOutcomeBased'),
            "claimAttributeList": component.get('v.claimAttributeList'),
            "hasAnyChangeOnClaim": hasAnyChangeOnClaim,
            "subClaimList": component.get("v.subClaimList"),
            "isClone": component.get("v.isCloneClaim"),
        });
        action.setCallback(this, function (saveResult) {
            if (saveResult.getReturnValue() != null && saveResult.getReturnValue().claimDetail != null && !saveResult.getReturnValue().errorDetail.startsWith('Exception')) {
                component.set("v.spinner", false);
                // Success! Prepare a toast UI message
                // Hide error Modal
                var errorToastModal = component.find('errorToast');
                $A.util.addClass(errorToastModal, "slds-hide");
                //changes for EDit claim - start
                var successMessage;
                var successTitle;
                if (component.get("v.isClaimEdit")) {
                    successTitle = $A.get("$Label.c.Core_MDF_SuccessUpdateMsgTitle");
                    if(saveResult.getReturnValue().claimDetail.Core_MDF_Excess_Requested_Amount__c != 0){
                        successMessage = $A.get("$Label.c.Core_MDF_SuccessUpdateMsg")+' '+ $A.get("$Label.c.Core_MDF_Claim_amount_exceeding_activity_limit");
                    }
                    else{
                        successMessage = $A.get("$Label.c.Core_MDF_SuccessUpdateMsg");
                    }

                } else {
                    successTitle = $A.get("$Label.c.Core_MDF_SuccessMsgTitle");
                    if(saveResult.getReturnValue().claimDetail.Core_MDF_Excess_Requested_Amount__c != 0){
                        successMessage = $A.get("$Label.c.Core_MDF_SuccessMsg")+' '+ $A.get("$Label.c.Core_MDF_Claim_amount_exceeding_activity_limit");
                    }
                    else{
                        successMessage = $A.get("$Label.c.Core_MDF_SuccessMsg");
                    }
                }
                //changes for EDit claim - end
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": 'success',
                    "title": successTitle,
                    "message": successMessage,
                    "mode": 'sticky'
                });
    
                //navigate to detail page
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": saveResult.getReturnValue().claimDetail.Id
                });
                navEvt.fire();
                $A.get("e.force:closeQuickAction").fire();
    
                //page reload-only in edit case
                if (component.get("v.isClaimEdit")) {
                    setTimeout(function () { window.location.reload(); }, 2000);
                }
                resultsToast.fire();
            }
            else if (saveResult.getState() === "ERROR" || (saveResult.getReturnValue() != null && saveResult.getReturnValue().errorDetail.startsWith('Exception'))) {
                // Call the function to Handle the Server Exceptions
                var error = JSON.stringify(saveResult.getError());
                let errorMessage = (saveResult.getReturnValue() != null && saveResult.getReturnValue().errorDetail.startsWith('Exception')) ? saveResult.getReturnValue().errorDetail : $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                component.set("v.spinner", false);
                this.handleServerExceptions(component, errorMessage);
            }
        });
    
        $A.enqueueAction(action);
    },
    
    //This function is used to set vat percentage for banks with legal entity code 420 [and 650]
    setVATPercentageFor420and650: function (component) {
        const selectedbankId = component.get("v.simpleNewClaim.Core_MDF_Bank__c");
        const bankList = component.get("v.bankObjectList");
        const index = bankList.findIndex(bank => bank.value.Core_MDF_Bank__c == selectedbankId);
        
        if (index != -1) {
            const hasOptedForVat = component.get("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c");

            if (bankList[index].value.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c== '420') {
                if (hasOptedForVat == $A.get("$Label.c.Core_MDF_nonTranslate_Service_Invoice_to_Intel")) {  //new VAT process changes - RP
                    component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c",$A.get("$Label.c.Core_MDF_ApplicableVATPercenatgeFor420"));
                } else {
                    component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", "");
                }
            } else if(bankList[index].value.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c== '650') {  //new VAT process changes - RP
                if (hasOptedForVat == $A.get("$Label.c.Core_MDF_nonTranslate_Service_Invoice_to_Intel")) {
                    const existingVat = component.get("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c");
                    component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", existingVat === '8' ? '8' : '10');
                } else {
                    component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", '0');
                }

                }
            }
    
    },
    
    showVATWarningForNonEMEACountries: function (component) {
        const selectedbankId = component.get("v.simpleNewClaim.Core_MDF_Bank__c");
        const bankList = component.get("v.bankObjectList");
        const index = bankList.findIndex(bank => bank.value.Core_MDF_Bank__c == selectedbankId);
       if (index != -1) {
      
            if(component.get("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c") == $A.get("$Label.c.Core_MDF_nonTranslate_Service_Invoice_to_Intel") && bankList[index].value.Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c =='GB' 
                  && !$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c")) && (component.get("v.activityRegion") != 'EMEA')) {
            component.set("v.showVATWarning", true);
        }
           
        }

    },  
    
    //This function is used to show error toast message
    populateErrorToastModal: function (component) {
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.isError", true);
        component.set("v.spinner", false);
        //Auto hide error modal after 4sec
        window.setTimeout($A.getCallback(function () {
            if (component.isValid()) {
                $A.util.addClass(errorToastModal, "slds-hide");
            }
        }), 4000);
        component.set("v.isSaveDisabled", false);
    },
    
    //This helper function is used to fetch Currency picklist values and Logged In User Info
    fetchUserAndPicklistInfo: function (component) {
        var action = component.get("c.fetchUserAndPicklistInfo");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'fieldApiName': component.get("v.fieldName")
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
    
                var currValList = [];
                var mapResp = a.getReturnValue().pickListValuesMap;
                for (var key in mapResp) {
                    currValList.push({ value: mapResp[key], key: key });
                }
                component.set("v.currList", currValList);
                //checking if logged in user's type as power partner and setting flag to true
                if (a.getReturnValue().userDtls != '' && a.getReturnValue().userDtls.UserType != '' &&
                    a.getReturnValue().userDtls.UserType == $A.get("$Label.c.Core_MDF_Partner_User_Type")) {
                    component.set("v.isPortal", true);
                }
    
            }
            else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    //This helper function is used to fetch Applicable VAT Perncentage Picklist Values
    fetchApplicableVATPercentagePicklistValues: function (component) {
        var action = component.get("c.getPickListvalues");
        action.setParams({
            'objectName': component.get("v.ObjectName"),
            'fieldApiName': 'Core_MDF_Applicable_VAT_Percentage_nm__c'
        });
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS" && res.getReturnValue() != null) {
    
                var vatPercentageMap = [];
                var mapResp = res.getReturnValue();
                for (var key in mapResp) {
                    vatPercentageMap.push({ key: key, value: mapResp[key] });
                }
                component.set("v.applicableVATPercentageMap", vatPercentageMap);
                            }
            else {
                this.handleServerExceptions(component, res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    //This helper function is used to fetch activity details
    fetchActivityRecord: function (component, event, helper) {
        //Bypass fetch activity details, when we click on save and got any validation error,in case of retail/KPI, 
        //call only once,if KPI loaded
        component.set('v.spinner', true);
        if (!component.get("v.isKpiLoaded")) {
            var action = component.get("c.getActivityDetails");
            var requestId = component.get("v.simpleNewClaim.RequestId");
            component.set('v.activityIdForEsc',requestId);
            if (!$A.util.isUndefined(requestId) && !$A.util.isEmpty(requestId)) {
                action.setParams({
                    'activityId': component.get("v.simpleNewClaim.RequestId")
                });
                action.setCallback(this, function (a) {
                    var state = a.getState();
                    if (state === "SUCCESS" && a.getReturnValue() != null) {
                        // to set activity values in create claim scree
                        this.setActivityValuesInClaim(a.getReturnValue(), component);
                        // To populate activity lookup on search
                        this.autoPopulateActivity(component);
                        this.fetchBankRecords(component);
                        component.set('v.isOutcomeBased', false);
                        component.set('v.isOutcomeBasedActivity', a.getReturnValue().isOutcomeBasedActivity);
                        this.getTacticInformation(component, event, helper);
                        let activitydetails = a.getReturnValue().activityDetails;
                        if (activitydetails.Core_MDF_Program__c != 'Co-GTM') {
                        this.fetchCountryRecords(component);
                        }
                        this.fetchActivitySubTypes(component);
                        this.assignRecordTypeMetaDataValues(component);
                        //added by Vaishali for owner change to show mapped Claim submitter values of Request's ultimate account                        
                        this.fetchClaimSubmitters(component);
                        this.setPayTypeDefaultValuePicklist(component);
                        // To copy the Activity Title in claim Title for Retail Claim
                        if (component.get('v.isClaimActivitySwap')) {
                            component.set("v.simpleNewClaim.Title", a.getReturnValue().activityDetails.Title);
                        }
                        //this.showLookupPill(component,component.find("activityId"));  
                        component.set("v.showActivityLookupPill", true);
                    }
                    else {
                        this.handleServerExceptions(component, a.getReturnValue());
                    }
                });
                $A.enqueueAction(action);
            }
            else {
                this.resetActivityValuesInClaim(component);
            }
            //This function used to check for escalation lookup to be enabled/disabled, on activity select/deselect
            this.manageEscalationLookup(component);
            //This function used to check for Claim Submitter lookup to be enabled/disabled, on activity select/deselect
            //added by Vaishali for owner change
            this.manageClaimSubmitterLookup(component);
        }
        //component.set('v.spinner', false);
    },
    
    //This method is used to set activity values
    setActivityValuesInClaim: function (activityDetailsWrap, component) {
        let partnerFundRequest = activityDetailsWrap.activityDetails;
                component.set("v.isProposalbasedInd", partnerFundRequest.Core_MDF_Proposal_Based_Ind__c);
        component.set("v.activityRegion",partnerFundRequest.Core_MDF_Region_nm__c);
        component.set("v.simpleNewClaim.Core_MDF_Activity_Category__c", partnerFundRequest.Core_MDF_ActivityCategory__c);
        component.set("v.simpleNewClaim.Core_MDF_Activity_Types__c", partnerFundRequest.Core_MDF_Activity_Types__c);
        component.set("v.simpleNewClaim.Core_MDF_Activity_Start_Date__c", partnerFundRequest.Core_MDF_Start_Date__c);
        component.set("v.simpleNewClaim.Core_MDF_Activity_End_Date__c", partnerFundRequest.Core_MDF_End_Date__c);
        //Core_MDF_Brand__c - For CoGTM, get it from Campaign
        if (partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_Co_GTM_program_name")) {
            component.set("v.simpleNewClaim.Core_MDF_Brand_nm__c", partnerFundRequest.Campaign.Core_MDF_Brand__c);
        } else {
        component.set("v.simpleNewClaim.Core_MDF_Brand_nm__c", partnerFundRequest.Core_MDF_Brand_nm__c);
        }
        component.set("v.simpleNewClaim.Core_MDF_Target_Audience__c", partnerFundRequest.Core_MDF_TargetAudience__c);
        component.set("v.simpleNewClaim.Core_MDF_Reimbursement_Percent__c", partnerFundRequest.Core_MDF_Reimbursement_Rate__c);
        component.set("v.simpleNewClaim.Core_MDF_Program__c", partnerFundRequest.Core_MDF_Program__c);
        //added by Vaishali for owner change functionality to send this value to server to get its claim submitters
        component.set("v.technicalProgName", partnerFundRequest.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);//added by VD for owner change
        component.set("v.programName", partnerFundRequest.ChannelPartner.Core_MDF_Channel_Program__r.Name); //added by VB to pass program value to manage audit component
        
        component.set("v.simpleNewClaim.Core_MDF_Budget_Type_Options_Nm__c", partnerFundRequest.Core_MDF_Budget_Type_nm__c); // For 3rd party POP
        //component.set("v.simpleNewClaim.Core_MDF_Ultimate_Account_ID__c", partnerFundRequest.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id); // For 3rd party POP
        let ultimateAccountId = partnerFundRequest.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id;
        component.set("v.simpleNewClaim.Core_MDF_Ultimate_Account_ID__c", ultimateAccountId != null ? ultimateAccountId.substr(0, 15) : ultimateAccountId); // For 3rd party POP
        component.set("v.localizedBudgetType", partnerFundRequest.LocalizedBudgetType);
        component.set("v.budgetType", partnerFundRequest.Core_MDF_Budget_Type_nm__c);
        if (partnerFundRequest.Core_MDF_Program__c == "Retail Marketing Funds" || partnerFundRequest.Core_MDF_Program__c == "Intel Partner Alliance") {
            component.set("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c", partnerFundRequest.Core_MDF_Activity_SubType_nm__c);
        }
        component.set("v.simpleNewClaim.LocalizedActivitySubType", partnerFundRequest.LocalizedActivitySubType);
        
        if(partnerFundRequest.CampaignId != null){
        component.set("v.simpleNewClaim.Core_MDF_Campaign_Id__c", partnerFundRequest.CampaignId);
        }
        
        //IPA
        if (partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_IPA_Program_Name") && partnerFundRequest.CampaignId != null){
            component.set("v.campaignName", partnerFundRequest.Campaign.Name);
            component.set("v.campaignDesc", partnerFundRequest.Campaign.Description);
            component.set("v.isActivityPurposeVisible", false);  
           	component.set("v.isCampaignPurposeVisible", true); 
                       }
                //IPABankHide
        if ((partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_IPA_Program_Name") || partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_Co_GTM_program_name")) && !component.get('v.isClaimEdit')) { 
            var accountNodePaymentType = !$A.util.isUndefinedOrNull(partnerFundRequest.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c) && partnerFundRequest.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c != ''? partnerFundRequest.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c : partnerFundRequest.ChannelPartner.Core_MDF_Payment_Type_nm__c;
            component.set("v.simpleNewClaim.Core_MDF_Paid_By_Payment_Type_nm__c", accountNodePaymentType);
            this.hideBankBasedOnPaymentType(component, accountNodePaymentType);
        }
    
        if (partnerFundRequest.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r != null) {
            component.set("v.simpleNewClaim.Core_MDF_AccountCompany__c", partnerFundRequest.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
            //added by Vaishali for owner change functionality to send this value to server to get its claim submitters
            component.set("v.ultimateAccountId", partnerFundRequest.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id);
        }
        component.set("v.simpleNewClaim.ChannelPartner", partnerFundRequest.ChannelPartner.Name);
        component.set("v.bankAccountId", partnerFundRequest.ChannelPartner.Id);
        component.set("v.activityRecordTypeDevName", partnerFundRequest.RecordType.DeveloperName);
        component.set("v.activitySearchString", partnerFundRequest.Core_MDF_Activity_Number__c);
        //Multiple country picklist values of activity
        if (!$A.util.isUndefinedOrNull(partnerFundRequest.Core_MDF_Country_nm__c) && !$A.util.isUndefinedOrNull(partnerFundRequest.countryNameLocalized)) {
            component.set("v.activityCountriesMap", ({ key: activityDetailsWrap.nonLocalizedCountryValues, value: activityDetailsWrap.localizedCountryValues }));
        }
        var invoiceAmtCmp = component.find('claimInvoiceAmntLocal');
        //To stamp PFR requested amount on claim screen for RMF/IPA
        if(partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_Retail_Channel_Program_Name") || partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_IPA_Program_Name")) {
            invoiceAmtCmp.set('v.value', partnerFundRequest.RequestedAmount);
        }
    
        // Load KPI attributes to display KPI fields to enter value for CCF/DCF/RMF/IPA
        if (partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_Retail_Channel_Program_Name")
            || partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_IPA_Program_Name")
            || partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_CCF_Program_Name")
            || partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_Non_Localized_DCF_Program_Name")) {
            this.loadKpiAttributes(component);
        }
        else {
            component.set("v.isCurrDisabled", false);
        }
		  component.set("v.isSuperClaim", partnerFundRequest.Core_MDF_Activity_Level_nm__c === 'Super Activity');
		//component.set("v.hideBank", partnerFundRequest.Core_MDF_Activity_Level_nm__c === 'Super Activity');
        this.checkPopDocRequired(component);
        if (this.isOEMRecordType(component)) {
            this.isBankHidden(component);
            //this.isPOPMandateForBudgetType(component);
            if (!$A.util.isUndefinedOrNull(partnerFundRequest.Core_MDF_Activity_SubType_nm__c) && !$A.util.isUndefinedOrNull(partnerFundRequest.LocalizedActivitySubType)) {
                component.set("v.isActySubTypeFieldRequired", true);
                component.set("v.activitySubTypesMap", ({ key: partnerFundRequest.Core_MDF_Activity_SubType_nm__c, value: partnerFundRequest.LocalizedActivitySubType }));
    
            } else {
                component.set("v.isActySubTypeFieldRequired", false);
                component.set("v.activitySubTypesMap", "");
    
            }
        }
    
        if(partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_IPA_Program_Name") && partnerFundRequest.Core_MDF_Is_Outcome_Based_Ind__c && !partnerFundRequest.Core_MDF_Proposal_Based_Ind__c){
            component.set("v.isOutcomeBasedAccountBasedAct", true);//Tavishi
            component.set("v.outcomeDesc", partnerFundRequest.Core_MDF_Activity_Description__c);
            component.set("v.hideBank", partnerFundRequest.Core_MDF_Activity_Level_nm__c === 'Super Activity');
        }
    },

    //IPABankHide and CoGTM BankHide
    hideBankBasedOnPaymentType: function (component, paymentType) {
        let paymentTypesValuetoToHideBank = $A.get("$Label.c.Core_MDF_PaymentTypes_to_hideBank").split(','); //Customer (Pass Through),Distributor (Credit Memo),Vistex (Credit Memo),Customer (Credit Memo)
        if (paymentTypesValuetoToHideBank.includes(paymentType)) {
            component.set('v.hideBank', true);
            component.set('v.showApplicableVatPercentage', false);
            component.set('v.vatOptInPicklistVisible', false);
            component.set('v.simpleNewClaim.Core_MDF_Bank__c', '');
            component.set('v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c', '');
            component.set('v.simpleNewClaim.Core_MDF_VAT_Opt_In__c', '');
            var inputCmp = component.find('claimBankDocUrlDiv');
            if (inputCmp != null && inputCmp != '') {
                $A.util.addClass(inputCmp, 'slds-hide');
            }
        }
    },
    
    //This method is used to clear activty values, if we clear activity from activity lookup
    resetActivityValuesInClaim: function (component) {
        component.set("v.simpleNewClaim.Core_MDF_Activity_Category__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Activity_Types__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Activity_Start_Date__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Activity_End_Date__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Brand_nm__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Country_nm__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Target_Audience__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Reimbursement_Percent__c", "");
        component.set("v.simpleNewClaim.Core_MDF_AccountCompany__c", "");
        component.set("v.simpleNewClaim.ChannelPartner", "");
        component.set("v.bankAccountId", "");
        component.set("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c", "");
        component.set("v.simpleNewClaim.Title", component.get('v.isClaimActivitySwap') ? "" : component.get("v.simpleNewClaim.Title"));
        component.set("v.vatOptInPicklistVisible", false);
        component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Bank__c", "");
        component.set('v.spinner', false);
        component.set("v.hideBank", false);
        component.set("v.budgetType", "");
        component.set("v.localizedBudgetType", "");
        component.set("v.isSpifSectionVisible", true); //SPIF section visibility
        component.set("v.activeSections", "spifAccordionSection"); //SPIF Accordion default Open
        this.resetActivitySubType(component);
    },
    
    resetActivitySubType: function (component) {
        if (!$A.util.isUndefinedOrNull(component.get('v.simpleNewClaim.LocalizedActivitySubType'))) {
            if (this.isOEMRecordType(component)) {
                component.set("v.isActySubTypeFieldRequired", false);
                component.set("v.actySubTypeOptions", "");
                component.find('ActSubTypes').clear();
            } else {
                component.set("v.simpleNewClaim.LocalizedActivitySubType", ""); // to clear retail Acty subtype
            }
        } else {
            component.set("v.isActySubTypeFieldRequired", false);
            component.set("v.actySubTypeOptions", "");
        }
    },
    
    //This helper function is used to fetch mapped claim submitters of request's ultimate account
    fetchClaimSubmitters: function (component) {
        //this flag will ensure that it is not getting called if claim submitters are creating claim
        if (!component.get("v.claimSubDisabled")) {
            var userIdList;
            var action1 = component.get("c.fetchClaimSubmitters");
            action1.setParams({
                'ultimateAccountId': component.get("v.ultimateAccountId"),
                'techProgramName': component.get("v.technicalProgName")
            });
            action1.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS" && response.getReturnValue() != null) {
                    userIdList = response.getReturnValue();
    
                    var userIds = "@quote;" + userIdList.join("@quote;,@quote;") + "@quote;";
    
                    var searchCriteria = 'Id IN (' + userIds + ')';
                    component.set('v.claimSubSearchCriteria', searchCriteria);
                    component.set("v.spinner", false);
                }
                else if (response.getState() !== "SUCCESS") {
                    this.handleServerExceptions(component, response.getReturnValue());
                }
            });
            $A.enqueueAction(action1);
        }
    },
    
    //This helper function is used to fetch bank pick list values
    fetchBankRecords: function (component) {
        //Hold all mapped banks with account
        var bankValList = [];
        var action1 = component.get("c.fetchBankRecords");
        action1.setParams({
            'accountId': component.get("v.bankAccountId")
        });
        action1.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                var bankList = a.getReturnValue();
                var bankDetailsList = [];
                for (var i = 0; i < bankList.length; i++) {
                    //Check exisiting bank and mark as defaulted selected
                    if (bankList[i].Core_MDF_Bank__r.Id == component.get("v.simpleNewClaim.Core_MDF_Bank__c")) {
                        bankValList.push({ value: bankList[i], selected: true });
                        component.set("v.isBankMappedWithAcnt", true);
                    } else {
                        bankValList.push({ value: bankList[i], selected: false });
                    }
                    bankDetailsList.push(bankList[i].Core_MDF_Bank__r);
                }
                    
                if (bankValList != null) {
                    component.set("v.bankObjectList", bankValList);
                    this.prepareCountryCodeToRegionMap(component,bankDetailsList);
                } else {
                    //If no bank is mapped with account
                    component.set("v.isBankMappedWithAcnt", false);
                }
                    
            } else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    },
    
    prepareCountryCodeToRegionMap: function (component,bankDetailsList) {
        
        var action = component.get("c.fetchBankRegion");
        action.setParams({
            'bankList': bankDetailsList
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                 component.set("v.countryCodeToRegionMap",a.getReturnValue());
                 this.showOrHideVATOptInOptionFor420and650(component,false);
        
            } else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action);

    },


    //This function is used to fetch country pick list from selected activity
    fetchCountryRecords: function (component) {
    //Hold activity country values
    var countryValList = [];
    //Hold activity country splitted values
    var splittedActCountry;
    var splittedLocalActCountry;
    if (!$A.util.isUndefinedOrNull(component.get("v.activityCountriesMap"))) {
        //exisiting activity countries
        var activityCountries = component.get("v.activityCountriesMap").key;
        var activityLocalCountries = component.get("v.activityCountriesMap").value;
        //Split multiple country into array
        splittedActCountry = activityCountries.split(";");
        splittedLocalActCountry = activityLocalCountries.split(";");
        for (var index = 0; index < splittedActCountry.length; index++) {
            //Check exisiting country and mark as defaulted selected
            if ((splittedActCountry[index] == component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c"))
                || (!component.get("v.isClaimEdit") && splittedActCountry.length == 1)) {
                countryValList.push({ value: splittedActCountry[index], label: splittedLocalActCountry[index], selected: true });
                component.set("v.isClaimCountryAvailInAct", true);
                //Setting latest country value
                component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c", splittedActCountry[index]);
            } else {
                countryValList.push({ value: splittedActCountry[index], label: splittedLocalActCountry[index], selected: false });
            }
        }
        //country list null check
        //if(countryValList!=null){ As part of Major fix,insted of null check we are doing Length check.
        if (countryValList.length > 0) {
            component.set("v.countryList", countryValList);
        }
    } else {
        //If no country fetched from activity
        component.set("v.isClaimCountryAvailInAct", false);
    }
    },
        
    //This function is used to fetch subtype pick list from selected activity
    fetchActivitySubTypes: function (component) {
        if (this.isOEMRecordType(component)) {
            //Hold activity subtype values
            var subtypeValList = [];
            //Hold activity subtype splitted values
            var splittedActSubType;
            var splittedLocalSubType;
            //if (!$A.util.isUndefinedOrNull(component.get('v.activitySubTypesMap'))) {
            if (!$A.util.isEmpty(component.get('v.activitySubTypesMap')) && !$A.util.isUndefinedOrNull(component.get('v.activitySubTypesMap'))) {
                component.set("v.isActySubTypeFieldRequired", true);
                var activitySubTypes = component.get("v.activitySubTypesMap").key;
                var activityLocalSubTypes = component.get("v.activitySubTypesMap").value;
                //Split multiple subtypes into array
                splittedActSubType = activitySubTypes.split(";");
                splittedLocalSubType = activityLocalSubTypes.split(";");
                if (splittedActSubType.length > 0 && (!component.get("v.isClaimEdit")) && (!component.get("v.isCloneClaim"))) {
                    for (var index = 0; index < splittedActSubType.length; index++) {
                        subtypeValList.push({ value: splittedActSubType[index], label: splittedLocalSubType[index], selected: false });
                    }
                }
                else {
                    var selectedSubTypes = component.get("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c").split(";");
                    for (var index = 0; index < splittedActSubType.length; index++) {
                        //Check selected subtype and mark as defaulted selected
                        if (selectedSubTypes.includes(splittedActSubType[index])) {
                            subtypeValList.push({ value: splittedActSubType[index], label: splittedLocalSubType[index], selected: true });
                        } else {
                            subtypeValList.push({ value: splittedActSubType[index], label: splittedLocalSubType[index], selected: false });
                        }
                    }
                }
                if (subtypeValList.length > 0) {
                    component.set("v.actySubTypeOptions", subtypeValList);
                }
            }
            else {
                //If no sub type fetched from activity
                component.set("v.isActySubTypeFieldRequired", false);
                component.set("v.actySubTypeOptions", "");
            }
        }
    },
    
    //This helper function is used to autopopulate activity over claim
    autoPopulateActivity: function (component) {
        var activityAuraId;
        if (!$A.util.isUndefinedOrNull(component.get('v.isClaimActivitySwap'))) {
            activityAuraId = 'activityIdRetail';
        } else {
            activityAuraId = 'activityId';
        }
        var activitySearch = component.get('v.activitySearchString');
        if (activitySearch != '' & !$A.util.isUndefinedOrNull(activitySearch)) {
            var activityLookup = component.find(activityAuraId);
            if (activityLookup != '' & !$A.util.isUndefinedOrNull(activityLookup)) {
                activityLookup.select2();
            }
        }
    },
    
    //This helper function is used to autopopulate esccalation over claim
    autoPopulateEscalation: function (component) {
        var escalationSearch = component.get('v.escalationNoSearchString');
        if (escalationSearch != '' & !$A.util.isUndefinedOrNull(escalationSearch)) {
            var escalationLookup = component.find('escalationId');
            escalationLookup.select2();
        }
    },
    
    //This helper function called to redirect to passed object
    closeModel: function (component, docIds) {  // Added docIds for POP
        var homeEvent = $A.get("e.force:navigateToSObject");
	var urlEvent = $A.get("e.force:navigateToURL"); //Added by AJ 
        var isPfr = component.get("v.isPfrUrl");
        var isCampaignUrl = component.get("v.isCampaignUrl");
        var objName;
        if (Boolean(isPfr)) {
            homeEvent.setParams({
                "recordId": component.get("v.recordId")
            });
            homeEvent.fire();
        } else if (Boolean(component.get("v.isOutcomeBasedIntUrl"))) { //Added by AJ - Start
            window.location.href= $A.get("$Label.c.Core_MDF_Outcome_Internal_Link") + component.get("v.recordId");
        } else if (Boolean(component.get("v.isOutcomeBasedExtUrl"))) {
            urlEvent.setParams({
                "url": $A.get("$Label.c.Core_MDF_Outcome_Community_Link") + component.get("v.recordId")
            });
            urlEvent.fire();    //Added by AJ - End
        } else if (Boolean(isCampaignUrl)) {
            homeEvent.setParams({
                "recordId": component.get("v.simpleNewClaim.Core_MDF_Campaign_Id__c")
            });
            homeEvent.fire();
        } else if (!$A.util.isUndefinedOrNull(component.get("v.batchRecordId"))) {
            homeEvent.setParams({
                "recordId": component.get("v.batchRecordId")
            });
            homeEvent.fire();
        } else {
            if (component.get("v.escalationId") != null && component.get("v.escalationId") != ''
                && component.get("v.escalationId") != undefined) {
                homeEvent.setParams({
                    "recordId": component.get("v.escalationId")
                });
                homeEvent.fire();
            } else {
                
                // Roshan - Hide close button conditionally
                if (!component.get("v.isClaimEdit") && !component.get("v.isCloneClaim")) {
                    objName = $A.get("$Label.c.Core_MDF_PFCText");
                    var homeEvents = $A.get("e.force:navigateToObjectHome");
                    homeEvents.setParams({
                        "scope": objName
                    });
                    homeEvents.fire();
                } else {
                    var targetRecordId = component.get("v.simpleNewClaim.Id");
                    if ($A.util.isUndefinedOrNull(targetRecordId) || targetRecordId === '') {
                        targetRecordId = component.get("v.clonedClaimId");
                    }
                    homeEvent.setParams({
                        "recordId": targetRecordId
                    });
                    homeEvent.fire();
                }
            }
        }
        $A.get("e.force:closeQuickAction").fire();
    },
    
    // This helper function called to get page url and checking for PFR
    getPageUrl: function (component) {
        var sPageURL = decodeURIComponent(window.location.href);
        component.set("v.pageUrl", sPageURL);
        var urlToLowerCase = sPageURL.toLowerCase();
        var pfrText = $A.get("$Label.c.Core_MDF_PFRText");
        var campaignText = $A.get("$Label.c.Core_MDF_CampaignText");
	//Added by AJ - Start
        var outcomeBasedIntUrl = $A.get("$Label.c.Core_MDF_Outcome_Internal_Link");
        var outcomeBasedExtUrl = $A.get("$Label.c.Core_MDF_Outcome_Community_Link");
        if (urlToLowerCase.includes(outcomeBasedIntUrl.toLowerCase())) {
            component.set("v.isOutcomeBasedIntUrl", true);
        }
        if (urlToLowerCase.includes(outcomeBasedExtUrl.toLowerCase())) {
            component.set("v.isOutcomeBasedExtUrl", true);
        }
        //Added by AJ - End
        if (urlToLowerCase.includes(pfrText.toLowerCase())) {
            component.set("v.isPfrUrl", true);
        }
        if (urlToLowerCase.includes(campaignText.toLowerCase())) {
            component.set("v.isCampaignUrl", true);
        }
    },
    //This helper function is used to fetch bank pick list values
    getDuplicateRecords: function (component) {
        var action1 = component.get("c.duplicateClaimCheck");
        action1.setParams({
            'newClaim': component.get("v.simpleNewClaim")
        });
        action1.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                var dupList = a.getReturnValue();
    
                //If not duplicate record
                if (Object.keys(dupList).length == 0) {
                    //in case of retail
                    this.navigateToPopAndKpiTab(component);
                }
    
                //if it is duplicate record
                else {
                    component.set("v.spinner", false);
                    //To set duplicate list size according to duplicate claim size
                    if (Object.keys(dupList).length > $A.get("$Label.c.Core_MDF_DuplicateClaimSize")) {
                        dupList.length = $A.get("$Label.c.Core_MDF_DuplicateClaimSize");
                    }
    
                    //In Edit case
                    if (component.get("v.isClaimEdit")) {
                        if (component.get("v.simpleNewClaim.Core_MDF_Duplicate_Claim__c") != undefined
                            && component.get("v.simpleNewClaim.Core_MDF_Duplicate_Claim__c") == true) {
                            //No duplicate check will prompt
    
                            //In case of retail
                            this.navigateToPopAndKpiTab(component);
                        } else {
                            component.set("v.duplicateClaimList", dupList);
                        }
                    } else {
                        component.set("v.duplicateClaimList", dupList);
                    }
                }
            } else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    },
    
    // This helper function called to process edit claim
    onEditClaim: function (component) {
        //this.isMemberEligibleForEditOnIntelHoldClaim(component);
        this.isClaimEligibleForEdit(component);
        this.fetchClaimDetails(component);
    },
    
    //This helper function called to process Clone claim
    onCloneClaim: function (component) {
        //check claim type
        if (($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type")) == (component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c"))) {
            component.set("v.isClaimNegativeType", true);
            component.set("v.isClaimEditable", false);
        }
        else {
    
            this.fetchClaimDetails(component);
        }
    },
    
    //This method will fetch claim details during clone and edit
    fetchClaimDetails: function (component) {
        if (component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c") != ''
            && component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c") != undefined) {
            component.set("v.activitySearchString", component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c"));
            component.set("v.isOutcomeBasedActivity",component.get("v.simpleNewClaim.Request.Core_MDF_Is_Outcome_Based_Ind__c")); 
            this.autoPopulateActivity(component);
            component.set("v.bankAccountId", component.get("v.simpleNewClaim.ChannelPartner.Id"));
            this.fetchBankRecords(component);
            this.onEditOrCloneOfClaimShowOrHidevatOptIn(component);
            if(component.get("v.simpleNewClaim.Request.Campaign.Id") != null){
                component.set("v.isCampaignPurposeVisible",true);
                component.set("v.isActivityPurposeVisible",false);
            }
            component.set("v.technicalProgName", component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c"));//added by vaishali for owner change to get claim submitter list
            component.set("v.programName", component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Channel_Program__r.Name")); //added by VB to pass program value to manage audit component
            component.set("v.ultimateAccountId", component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id"));//added by vaishali for owner change to get claim submitter list
            component.set("v.activityRegion", component.get("v.simpleNewClaim.Request.Core_MDF_Region_nm__c"));
            component.set('v.activityIdForEsc',component.get("v.simpleNewClaim.RequestId"));
            //added by vaishali // to fetch mapped claim submitter of request's ultimate account
            this.fetchClaimSubmitters(component);
            component.set("v.activityId", component.get("v.simpleNewClaim.RequestId"));
            //hold latest country picklist values from activity, incase of clone and edit
            this.fetchCountryRecords(component);
            //hold activity subtype picklist values from activity, incase of clone and edit
            component.set("v.recordtypeDeveloperName", component.get('v.simpleNewClaim.RecordType.DeveloperName'));
            //this.fetchActivitySubTypes(component);
            //This function used to check for activity lookup to be enabled/disabled, in case on clone/Edit
            this.manageActivityLookup(component);
            //This function used to check for claim submitter lookup to be enabled/disabled, in case on clone/Edit
            this.manageClaimSubmitterLookup(component);
            component.set("v.simpleNewClaim.ChannelPartner", component.get("v.simpleNewClaim.ChannelPartner.Name"));
            if (component.get("v.isClaimEdit") && $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c"))
                && !$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c"))) {
                var claimSubName;
                if (!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Contact.Email")))
                    claimSubName = component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Name") + '-' + component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Contact.Email");
                else {
                    claimSubName = component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Name") + '-' + component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Email");
                }
                component.set("v.claimSubSearchString", claimSubName);
            }
            //Escalation- Set Escalation Id - for clear lookup
            component.set("v.escObjectId",
                component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c"));
            //Claim to be Audited 
            component.set("v.isClaimAudited",
                component.get("v.simpleNewClaim.Core_MDF_To_Be_Audited_Ind__c"));
    
            //Set Budget Type
            component.set("v.localizedBudgetType", component.get("v.activityBudgetType"));
            component.set("v.budgetType", component.get("v.simpleNewClaim.Request.Core_MDF_Budget_Type_nm__c"));
            component.set("v.simpleNewClaim.Core_MDF_Budget_Type_Options_Nm__c", component.get("v.simpleNewClaim.Request.Core_MDF_Budget_Type_nm__c"));  // Areefa for 3rd party POP
            component.set("v.simpleNewClaim.Core_MDF_Ultimate_Account_ID__c", component.get("v.simpleNewClaim.Core_MDF_Ultimate_Account_ID__c"));  // Areefa for 3rd party POP
            //Marketing Key Performance and Next Ind
            component.set("v.isProposalbasedInd", component.get("v.simpleNewClaim.Core_MDF_Proposal_Based_Ind__c"));
            component.set("v.isOutcomeBased", component.get("v.simpleNewClaim.Request.Core_MDF_Is_Outcome_Based_Ind__c"));
            if(component.get('v.recordtypeDeveloperName') == 'Core_MDF_IPA_Account_Based' && component.get("v.isOutcomeBased")){
            	component.set("v.isOutcomeBasedAccountBasedAct", true);
                component.set("v.outcomeDesc",component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Description__c"));
                component.set("v.hideBank", component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Level_nm__c") === 'Super Activity');
        	}
                component.set("v.isSuperClaim", component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Level_nm__c") === 'Super Activity');
		        //component.set("v.hideBank", component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Level_nm__c") === 'Super Activity');//15393
            var isSubClaimCheck = (!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Id__c")) && component.get("v.simpleNewClaim.Core_MDF_Claim_Id__c") != '');
            component.set("v.isSubClaim", isSubClaimCheck);
            //This function used to manageClaimFields and hide fields          
            this.manageClaimFields(component);
            //IPA            
            this.setIPAFields(component);
            this.checkPopDocRequired(component);
            if (this.isOEMRecordType(component)) {
                this.isBankHidden(component);
                //this.isPOPMandateForBudgetType(component);
                this.fetchActivitySubTypes(component);
            } else {
                component.set("v.isActySubTypeFieldRequired", false);
                component.set("v.actySubTypeOptions", "");
                component.set("v.activitySubTypesMap", "")
            }

            //IPABankHide and CoGTM BankHide
            if (component.get('v.programName') == $A.get("$Label.c.Core_MDF_IPA_Program_Name") || component.get('v.programName') == $A.get("$Label.c.Core_MDF_Co_GTM_program_name")) { 
                if (component.get("v.isClaimEdit")) {
                    this.hideBankBasedOnPaymentType(component, component.get('v.simpleNewClaim.Core_MDF_Paid_By_Payment_Type_nm__c'));
                } else if (component.get("v.isCloneClaim")) {
                    var paymentTypeNodeLevel = component.get('v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Payment_Type_NodeLevel_nm__c');
                    var paymentType = component.get('v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Payment_Type_nm__c')
                    var accountNodePaymentType = (!$A.util.isUndefinedOrNull(paymentTypeNodeLevel) && paymentTypeNodeLevel != '') ? paymentTypeNodeLevel : paymentType;
                    component.set("v.simpleNewClaim.Core_MDF_Paid_By_Payment_Type_nm__c", accountNodePaymentType);
                    this.hideBankBasedOnPaymentType(component, accountNodePaymentType);
                }
            }
    
        }
    },
    
    //This helper function is used to check current user is internal audit user and check permission set on Edit
    isClaimEligibleForEdit: function (component) {
        var action = component.get("c.isInternalAuditUser");
        action.setParams({
            'custPermissionName': $A.get("$Label.c.Core_MDF_ClaimEditAccessToAuditUser")
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                component.set("v.isAuditUser", a.getReturnValue());
                this.isClaimEditable(component);
            } else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
    
        $A.enqueueAction(action);
    },
    
    
    //Partner Deatils
    fetchMemberPartnerDetails: function (component) {
        var action = component.get("c.fetchUserDetails");
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                //checking if logged in user's type as power partner and setting flag to true
                if (a.getReturnValue().userInfo != null && a.getReturnValue().userInfo.UserType != '' && a.getReturnValue().userInfo.UserType == $A.get("$Label.c.Core_MDF_Partner_User_Type")) {
                    component.set("v.isPartner", true);
                }
                //checking user is payment admin
                component.set("v.isUserPaymentAdmin", a.getReturnValue().isUserPaymentAdmin);
                //checking user is retail claim submitter
                component.set("v.isRetailClaimSubmitter", a.getReturnValue().isRetailClaimSubmitter);
                //checking user is CCR or CCRM
                component.set("v.isUserClaimCaseReviewerOrManager", a.getReturnValue().isUserClaimCaseReviewerOrManager);
                //checking user is RMF 
                component.set("v.isUserPRCRMFClaimOperation", a.getReturnValue().isRMFPRCClaimOperation);
                //checking user is csc claim submitter
                component.set("v.isCSCClaimSubmitter", a.getReturnValue().isCSCClaimSubmitter);
                //This function used to check for escalation lookup to be enabled/disabled - on doint
                this.manageEscalationLookup(component);
                //This function used to enable/disable claim submitter lookup
                this.manageClaimSubmitterLookup(component);
                //chekcing user is CCR or CCRM or CSC Claim Submitter
                if ((!(($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type")) == (component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c"))))
                    && (component.get("v.isUserClaimCaseReviewerOrManager")|| component.get("v.isCSCClaimSubmitter"))) {
                    //onload, removing by default displayed cross icon,If user is CCR or CCRM
                    var escalationLookup = component.find('escalationId');
                    if (escalationLookup != null && escalationLookup != '' && !$A.util.isUndefinedOrNull(escalationLookup)) {
                        escalationLookup.clearLookupPill();
                        //this.showLookupPill(component, component.find("escalationId"));
                    }
                    //auto populate escalation in case of edit /clone
                    if (component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__r.Name") != ''
                        && component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__r.Name") != undefined) {
                        component.set("v.escalationNoSearchString", component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__r.Name"));
                        //not in case of edit, just need to set escalation name
                        if (!component.get("v.isClaimEdit")) {
                            this.autoPopulateEscalation(component);
                        }
                    }
                }
                // This method is to set Claim record type on the basis of Activity Record Type
                this.setClaimActivityAttributes(component);
                component.set("v.spinner", false);
            }
            else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    //Claim cannot be edit by member if it is on Intel Hold
    IsUserEligibleToEditClaimOnMembHold: function (component) {
        var curretMemHoldStatus = component.get("v.simpleNewClaim.Core_MDF_Intel_Manual_Hold_Ind__c");
        var isMember = component.get("v.isPartner");
        var isMysteryShopperUser = component.get("v.isUserPRCRMFClaimOperation") || component.get("v.isCSCClaimSubmitter");
    
        if (curretMemHoldStatus == true && (isMember == true || isMysteryShopperUser == true)) {
            return true;
        } else {
            return false;
        }
    },
    
    // this method checks if user can edit claim depending on claim status, user permissions, type of claim and Activity status
    isClaimEditable: function (component) {
        var auditHoldFlag = component.get("v.simpleNewClaim.Core_MDF_Audit_Hold__c");
        var flaggedForAudit = component.get("v.simpleNewClaim.Core_MDF_FlaggedForAudit__c");
        var flaggedForDocHold = component.get("v.simpleNewClaim.Core_MDF_Document_Hold_Eligibility_Ind__c");
        var docHoldFlag = component.get("v.simpleNewClaim.Core_MDF_Document_Hold_Ind__c");
        var bankDocHoldFlag = component.get("v.simpleNewClaim.Core_MDF_Bank_Doc_Hold_Ind__c");
        if(component.get("v.isSubClaim")){
            component.set("v.isClaimEditable", false);
        }
        else if (($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type")) == (component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c"))) {
            component.set("v.isClaimNegativeType", true);
            component.set("v.isClaimEditable", false);
        }
        //if it is a Partner user and it is a Positive Adjustment claim
        else if ((component.get("v.isPartner") || component.get("v.isUserPRCRMFClaimOperation")) && component.get("v.simpleNewClaim.Core_MDF_CRR_Positive_Ind__c")) {
            component.set("v.isClaimEditable", false);
            component.set("v.restrictCRRClaimEdit", true);
        }
        else {
            // To ensure that claim with Closed activity OR escalation cannot be edited by any other user except CCR/CCM and CSC claim submitter
            if (!(component.get("v.isUserClaimCaseReviewerOrManager") || component.get("v.isCSCClaimSubmitter")) && (component.get("v.simpleNewClaim.Request.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_Claim_Activity_Closed_Status")
                || component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c") != null)) {
                component.set("v.isClaimEditable", false);
    
            } else {
                if (component.get("v.simpleNewClaim.Core_MDF_Status__c") != ''
                    && component.get("v.simpleNewClaim.Core_MDF_Status__c") != undefined) {
                    var claimStatus = ($A.get("$Label.c.Core_MDF_EditClaimStatusValues")).split(";");
                    if (claimStatus.includes(component.get("v.simpleNewClaim.Core_MDF_Status__c"))) {
    
                        if (!component.get("v.isAuditUser") && component.get("v.simpleNewClaim.Core_MDF_PIC_Review_Completed__c")) {
                            if (component.get("v.isPartner") && bankDocHoldFlag) {
                                component.set("v.isClaimEditable", true);
                                component.set("v.isEditDisabled", true);
                            }
                            // function to check if payment admin & can edit claim
                            else if (component.get("v.isUserPaymentAdmin")) {
                                this.isPaymentAdminEligibletoEdit(component);
                            }
                            else {
                                component.set("v.isClaimEditable", false);
                            }
                        }
                        if (component.get("v.isAuditUser") && component.get("v.simpleNewClaim.Core_MDF_PIC_Review_Completed__c")) {
                            component.set("v.isClaimEditable", true);
                            component.set("v.isEditDisabled", true);
                        }
                        if (this.IsUserEligibleToEditClaimOnMembHold(component)) {
                            component.set("v.isClaimEditable", false);
                        }
                        if (component.get("v.simpleNewClaim.Core_MDF_Status__c") == $A.get("$Label.c.Core_MDF_Claim_Status_Queued_for_Payment")) {
                            component.set("v.isClaimEditable", true);
                            component.set("v.isEditDisabled", true);
                        }
                    } else {
                        component.set("v.isClaimEditable", false);
                    }
                } else {
                    component.set("v.isClaimEditable", false);
                }
            }
        }
        if (component.get("v.spinner")) {
            //Spinner starts
            component.set("v.spinner", false);
        }
    },
    
    // This function is called from doInit and used when create claim from activity record
    getActivityDtlsByRecordId: function (component) {
                var action = component.get("c.checkClaimFromActivity");
        action.setParams({
            objectName: "PartnerFundClaim",
            activityId: component.get('v.recordId'),
            isPartnerUser: component.get("v.isPartner")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null) {
                var result = response.getReturnValue();
                if (!$A.util.isUndefinedOrNull(result)) {
                    component.set("v.createClaimWrapper", result);
                    if ((component.get('v.activityStatusList').includes(result.activityObj.Core_MDF_Fund_Request_Status__c)) &&
                        result.checkCreate == true && (!component.get('v.activityClosureTypeList').includes(result.activityObj.Core_MDF_Activity_Closure_Type__c))) {
                        component.set("v.isValidActivityToCreateClaim", true);
                        component.set("v.isOutcomeBasedActivity", result.activityObj.isOutcomeBasedActivity); 
                        component.set("v.simpleNewClaim.RequestId", result.activityObj.Id);
                        component.set("v.activityRecordTypeDevName", result.activityObj.RecordType.DeveloperName);
                        component.set("v.sObjectId", result.activityObj.Id);
                        component.set("v.isProposalbasedInd", result.activityObj.Core_MDF_Proposal_Based_Ind__c);
                        if(component.get("v.isPartner")) {
                            component.set("v.isActivityProposalBasedInd", result.activityObj.Core_MDF_Proposal_Based_Ind__c);
                        }
                        //lookup cmp will visible ,only if user is CCR/CCRM
                        if (component.get('v.isUserClaimCaseReviewerOrManager')) {
                            var escalationLookup = component.find('escalationId');
                            escalationLookup.clearLookupPill();
                                   				}
                    } else {
                        if (!result.checkCreate) {
                            // show error if no permission
                            component.set("v.claimFromActivityErrorMsg", $A.get("$Label.c.Core_MDF_NoClaimCreatePermissionText"));
                        } else {
                            //Ramapriya's Changes related to Error on click of Create claim button in In-progress Approval statuses
                            var activityInprogressApprovalStatuses = ($A.get("$Label.c.Core_MDF_PFR_Status_Restrict_CreateClaim")).split(";");
                            component.set('v.activityInProgressApprovalStatusList', activityInprogressApprovalStatuses);
                            //Roshan - added as part of Super claim validations
                            var isFinalOutcomeBased = result.activityObj.Core_MDF_Is_Outcome_Based_Ind__c;
                            if (component.get('v.activityInProgressApprovalStatusList').includes(result.activityObj.Core_MDF_Fund_Request_Status__c)) {
                                component.set("v.claimFromActivityErrorMsg", isFinalOutcomeBased ? $A.get("$Label.c.Core_MDF_Validate_CreateClaim_InProgress_FinalOutcomeBased") : $A.get("$Label.c.Core_MDF_Validate_CreateClaim_InProgress_Error"));
                            }
                            else{
                            // show error for invalid activity status
                            component.set("v.claimFromActivityErrorMsg", $A.get("$Label.c.Core_MDF_NoClaimCreateOnInvalidStatus"));
                            }
                        }
                        component.set("v.isClaimEditable", false);
                    }
    
                }
            } else if (state === "ERROR" || response.getReturnValue() == null) {
                this.handleServerExceptions(component, response.getReturnValue());
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
                console.log("inside handleServerExceptions");
                $A.util.addClass(errorToastModal, "slds-hide");
            }
        }), 4000);
        component.set("v.isSaveDisabled", false);
    },
    
    //This helper function is used to fetch all record type meta data map and set activity record type developer name
    fetchRecordTypeMetaData: function (component) {
        var action = component.get("c.fetchRecordTypeMetaData");
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                //Setting record Type map
                component.set('v.recordTypeMap', a.getReturnValue());
                var activityId = component.get('v.activityId');
                if (!$A.util.isUndefined(activityId) && !$A.util.isEmpty(activityId)) {
                    component.set('v.simpleNewClaim.RequestId', activityId);
                }
            }
            else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    //This helper function is used to fetch escalation details
    fetchEscalationDetails: function (component) {
        var action = component.get("c.getEscalationFields");
        var escalationId = component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c");
        
        if (!$A.util.isUndefined(escalationId) && !$A.util.isEmpty(escalationId)) {
                action.setParams({
                'escalationId': escalationId
            });
            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS" && a.getReturnValue() != null) {
                    component.set("v.escalationNoSearchString", a.getReturnValue().Name);
                    component.set("v.escalationRecordType", a.getReturnValue().RecordType.DeveloperName);
                    component.set("v.escalationClaimSubmitter", a.getReturnValue().Core_MDF_Claim_Submitter_Id__c);
                    //This function used to check for activity lookup to be enabled/disabled, in case on claim create from escalation
                    this.manageActivityLookup(component);
                    //This function used to check for claim submitter lookup to be enabled/disabled, in case on claim create from escalation
                    //added by Vaishali
                    this.manageClaimSubmitterLookup(component);
                    component.set("v.showEscLookupPill", true);
                }
                else {
                    this.handleServerExceptions(component, a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        else {
            component.set("v.escalationNoSearchString", "");
        }
    },
    
    //This helper function is used to clear picklist valus, on acivity clear lookup
    clearPicklistValues: function (component) {
        //clear country list
        var listOfCountry = component.get("v.countryList");
        listOfCountry.splice(0, listOfCountry.length);
        component.set("v.countryList", listOfCountry);
    
        //Clear bank list
        var listOfbank = component.get("v.bankObjectList");
        listOfbank.splice(0, listOfbank.length);
        component.set("v.bankObjectList", listOfbank);
    },
    
    //check if payment admin has edit access
    isPaymentAdminEligibletoEdit: function (component) {
        // To disable POP for Payment Admin 
        component.set("v.isPOPEnabled", false);
        component.set("v.isClaimEditable", true);
        component.set("v.isEditDisabled", true);
    },
    
    
    
    //This helper function is used to manageClaimFields
    manageClaimFields: function (component) {
        var auraIds = [];
        var activityTypesArr = [];
        var activityCatArr = [];
        //Find currency field
        var currCmp = component.find('claimCurrency');
        if (!$A.util.isUndefinedOrNull(component.get('v.recordtypeDeveloperName')) && component.get('v.recordtypeDeveloperName') != ''
            && !component.get("v.isClaimNegativeType")) {
            switch (component.get('v.recordtypeDeveloperName').toUpperCase()) {
                case $A.get("$Label.c.Core_MDF_RetailProgram").toUpperCase():
                    //currCmp.set('v.value', $A.get("$Label.c.Core_MDF_PFR_Output_Currency"));
                    //component.set("v.isCurrDisabled", true);
                    if (component.get('v.budgetType') == $A.get("$Label.c.Core_MDF_Retail_RSA_MD_Budget_Type")) {
                        auraIds = $A.get("$Label.c.Core_MDF_Hide_RSA_MD_Ids").split(",");
                        component.set("v.hideBank", true);
                    }
                    else {
                        auraIds = $A.get("$Label.c.Core_MDF_Hide_RMF_MDF_Ids").split(",");
                    }
                    break;
                case $A.get("$Label.c.Core_MDF_IPA_RecordType").toUpperCase():
                    component.set("v.isIPAFieldRequired", false);   // *manditory field   
                    component.set("v.actyPOPDescReq", "true");
                    // Create claim : should be default to USD, Clone claim:should pick up from cloning claim Currency, Edit claim : currency Should come as is later user can change 
                    if (!(component.get("v.isClaimEditable") || component.get("v.isCloneClaim"))) {
                        component.find('claimCurrency').set('v.value', $A.get("$Label.c.Core_MDF_PFR_Output_Currency"));
                    }
                    auraIds = $A.get("$Label.c.Core_MDF_Hide_IPA_Ids").split(",");
                    break;
                case $A.get("$Label.c.Core_MDF_IPA_AccountBased_RecType_DevName").toUpperCase():
                    component.set("v.isIPAFieldRequired", false);
                    component.set("v.actyPOPDescReq", "true");
                    auraIds = $A.get("$Label.c.Core_MDF_Hide_IPA_AccountBased_Ids").split(",");
                    break;                
                case $A.get("$Label.c.Core_MDF_EEF_RecordType").toUpperCase():
                    auraIds = $A.get("$Label.c.Core_MDF_Hide_EEF").split(",");
                    break;
                // anantha changes
                case $A.get("$Label.c.Core_MDF_Claim_COGTM_RecordType").toUpperCase():
                    auraIds = $A.get("$Label.c.Core_MDF_Hide_COGTM").split(",");
                    break;
                // end
                default:
                    var opalBudgetTypes = ($A.get("$Label.c.Core_MDF_OPAL_BudgetTypes")).split(";");
                    if (opalBudgetTypes.includes(component.get('v.budgetType'))) {
                        auraIds = $A.get("$Label.c.Core_MDF_Hide_OPAL").split(",");
                    } else {
                        auraIds = $A.get("$Label.c.Core_MDF_Hide_CCF_DCF_SPCF_Boost").split(",");
                    }
    
            }
        }
    
        var auraIdsLength = auraIds.length;
        for (var index = 0; index < auraIdsLength; index++) {
            var inputCmp = component.find(auraIds[index]);
            if (inputCmp != null && inputCmp != '') {
                $A.util.addClass(inputCmp, 'slds-hide');
            }
        }
    },
    
    
    //This helper function is used to check whether Bank has to be hidden or not
    isBankHidden: function (component) {
        var action = component.get("c.getBudgetTypetoHideBank");
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                var budgetTypestoHideBank = a.getReturnValue().split(',');
                if (budgetTypestoHideBank.includes(component.get('v.budgetType'))) {
                    component.set("v.hideBank", true);
                }
                else {
                    component.set("v.hideBank", false);
                }
            }
            else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
        
    checkPopDocRequired: function (component) {
        var action = component.get("c.isCheckPopDocRequired");
        action.setParams({
            'program': component.get("v.simpleNewClaim.Core_MDF_Program__c"),
            'budgetType': component.get("v.budgetType")
        });
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                var res = a.getReturnValue();
                if (Boolean(res)) {
                    component.set("v.isPOPMandatory", true);//use for confirmation msg
                }
                else {
                    component.set("v.isPOPMandatory", false);
                }
            }
    
        });
        $A.enqueueAction(action);
    },
    
    
    
    //set Data for CampaignId,CampaignName,CampaignDescription and POPDescription
    setIPAFields: function (component) {
        if (component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Program_Name") && component.get("v.simpleNewClaim.Request.Campaign") != null) {
            component.set("v.campaignName", component.get("v.simpleNewClaim.Request.Campaign.Name"));
            component.set("v.campaignDesc", component.get("v.simpleNewClaim.Request.Campaign.Description"));
            component.set("v.simpleNewClaim.Core_MDF_Campaign_Id__c", component.get("v.simpleNewClaim.Request.Campaign.Id"));
        }
            
    },
    
    //This helper function is used to assign POP mandatory and Swap retail field flag
    //corresponding to activity record type
    assignRecordTypeMetaDataValues: function (component) {
        //populate record type metadata values
        this.populatePopAndClaimActSwapFlag(component);
        this.manageClaimFields(component);
    
    },
    
    //If escalation record type is Claim Case Review Result, then claim review indicator would be true
    //It will bypass the audit process
    populateClaimReviewEscIndicator: function (component) {
        if (!$A.util.isUndefinedOrNull(component.get("v.escalationRecordType"))
            && component.get("v.escalationRecordType") != '' &&
            component.get("v.escalationRecordType") == $A.get("$Label.c.Core_MDF_ClaimCaseReviewResult_RecordType")) {
            component.set("v.simpleNewClaim.Core_MDF_IsClaimReviewEscalation_Ind__c", true);
        }
    },
    
    //populate POP and claim swap flag from metadata, set claim record type if not exists
    populatePopAndClaimActSwapFlag: function (component) {
        var recordTypesMap = component.get('v.recordTypeMap');
        if (!$A.util.isUndefinedOrNull(recordTypesMap)
            && Object.keys(recordTypesMap).length > 0) {
            for (let claimRecType of Object.keys(recordTypesMap)) {
                if (recordTypesMap.hasOwnProperty(claimRecType) &&
                    recordTypesMap[claimRecType].Core_MDF_Activity_RecordType_txt__c
                    == component.get('v.activityRecordTypeDevName') &&
                    recordTypesMap[claimRecType].Core_MDF_isProposalBased__c
                    == component.get('v.isProposalbasedInd')
                ) {
                    //component.set('v.isPOPMandatory', recordTypesMap[claimRecType].Core_MDF_POP_Mandatory_Ind__c);
                    component.set('v.isClaimActivitySwap', recordTypesMap[claimRecType].Core_MDF_Claim_Activity_Name_Swap_Ind__c);
                    // To populate recordtypeDeveloperName in case of Create Claim from Escalation and Activity
                    if (component.get('v.recordtypeDeveloperName') == '' || $A.util.isUndefinedOrNull(component.get('v.recordtypeDeveloperName'))) {
                        component.set('v.recordtypeDeveloperName', claimRecType);
                    }
                }
            }
        }
    },
    
    //This helper function is used to load KPI attributes
    loadKpiAttributes: function (component) {
    
        if (!component.get("v.spinner")) {
            //Spinner starts
            component.set("v.spinner", true);
        }
        component.set("v.isKpiLoaded", true);
        //load and display KPI attributes  corresponding to claim
        var kpiComponent = component.find('kpiDetail');
        if (kpiComponent != null) {
            var inputParams = {};
            inputParams.enableKPI = true;
            inputParams.objName = 'PartnerFundClaim';
            inputParams.activityCategory = component.get("v.simpleNewClaim.Core_MDF_Activity_Category__c");
            inputParams.activityType = component.get("v.simpleNewClaim.Core_MDF_Activity_Types__c");
            inputParams.program = component.get("v.simpleNewClaim.Core_MDF_Program__c");
            inputParams.title = $A.get("$Label.c.Core_MDF_ActualKPILabel");
            if (component.get("v.simpleNewClaim.Core_MDF_Program__c") == "Retail Marketing Funds") {
                inputParams.activitySubType = component.get("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c");
                inputParams.recordId = component.get('v.clonedClaimId')
                component.set('v.isClearedOnClone', false);
                
            } else {
                let actsubType = component.get("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c");
                inputParams.activitySubType =  !$A.util.isUndefinedOrNull(actsubType) && actsubType != "" ? actsubType.split(';') : [];
                inputParams.activityId = component.get('v.simpleNewClaim.RequestId');
                inputParams.parentObjName = 'PartnerFundRequest';
                component.set('v.isDecimalApplicable', true);
                component.set('v.isClearedOnClone', component.get('v.isClaimEdit') ? false : true);
                inputParams.recordId = component.get('v.isClaimEdit') ? component.get('v.clonedClaimId') : undefined;
            }
            inputParams.isProposalBased = component.get("v.isProposalbasedInd");
            kpiComponent.loadKPIAttributes(inputParams);
        } else {
            component.set("v.spinner", false);
        }
    },
    
    
    //This helper function is used to merge PFC and KPI values
    mergePfcAndKpiValues: function (component) {
        var kpiComp = component.find('kpiDetail');
        if (kpiComp != null) {
            var kpiValues = kpiComp.getKPIValues();
            if (kpiValues != null) {
                var pfcmain = component.get("v.simpleNewClaim");
                //Setting temp claim ID in pfcmain object and clearing the same after merge
                pfcmain["Id"] = component.get('v.clonedClaimId');
                //merging pfc and KPI values, if any
                var mergedObj = Object.assign({}, pfcmain, kpiValues);
                component.set("v.simpleNewClaim", mergedObj);

                //VB -> To merge claim and KPI details on Load
                let claimdetailsOnLoad = component.get("v.claimDataOnLoad");
                let claimAndKPIDt = Object.assign({}, claimdetailsOnLoad, component.get("v.kpiDetailsOnLoad"));
                component.set("v.claimDataOnLoad", claimAndKPIDt);
            }
        }
    },
    
    //This helper function is used to validate KPI fields/check is KPI fields valid or not
    validateKPIFields: function (component, event, helper, context) {
        var self = this;
        window.setTimeout($A.getCallback(function () {
            var kpiComponent = component.find('kpiDetail');
            var kpiReadOnlyComponent = component.find('claimkpiread');
            //check KPI values are valid, if yes go to POP page else KPI section 
            if ((kpiReadOnlyComponent != null) || (kpiComponent != null && kpiComponent.isFormValid())) {
                let nonEditableKPIStatuses = $A.get("$Label.c.Core_MDF_Pre_Payment_Claim_Statuses").split(';');  //Pending Available Fund, Hold, Payment Due

                if ((component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_CCF_Program_Name") || component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_Non_Localized_DCF_Program_Name")) 
                    && !nonEditableKPIStatuses.includes(component.get("v.simpleNewClaim.Core_MDF_Status__c"))) {

                    var validationResult = kpiComponent.checkValidationPotentialWinners();
                    if (validationResult === 'perExceedError') {
                        //handle percentage exceeding 33%
                        component.set('v.claimErrorMsg', $A.get('$Label.c.Core_MDF_Error_Potenial_Winner'));
                        self.populateErrorToastModal(component);
                        return;
                    } else if (validationResult === 'noExpPotCheck') {
                        //handle winners greater than participants
                        component.set('v.claimErrorMsg', $A.get('$Label.c.Core_Potential_Greater_Error'));
                        self.populateErrorToastModal(component);
                        return; 
                    }
                }

		
                component.set("v.currentStep", "3");
                if(context == 'save') {
                    self.validateClaimBeforeSave(component, event, helper);
                }
            }
    
            else {
                if(context == 'save') {
                    component.set("v.claimErrorMsg", $A.get("$Label.c.Core_MDF_ValidationMessageForKPIActualMetrics"));
                    self.populateErrorToastModal(component);
                }
                component.set("v.currentStep", "2");
                component.set("v.spinner", false);
            }
        }), 1000);
    },
    
    //This helper function is uaed to navigate to POP and KPI tab, on click of duplicate OK button and click on Tab
    navigateToPopAndKpiTab: function (component) {
        //If we click on POP tab
        if (component.get("v.moveToThirdPage")) {
            component.set("v.currentStep", "3");
        } else if (component.get('v.isKpiSectionVisible') || component.get('v.isOutcomeBased')) {
            component.set("v.currentStep", "2");
        } else {
            //In case there are only 2 tabs and if we click on next button of tab 1
            component.set("v.currentStep", "3");
        }
         component.set("v.spinner",false);
    },
    
    /**This helper function is used for Claim manditory fields & duplicate claim validation
     * with navigation to next tab
     **/
    navigationOnNextButton: function (component) {
        component.set("v.moveToThirdPage", false);
        //on click on next button [Claim form fields tab]
        if (component.get("v.currentStep") == "1") {
            if (this.validateClaimForm(component)) {
                //calling of validateClaimSubmitterLookup method done by vaishali 
                //to validate claim submitter value is not blank before moving to next button
                if (!this.validateClaimSubmitterLookup(component) && !this.validateVatOptIn(component) && !(this.validateClaimDates(component, "claimActStartDate") || this.validateClaimDates(component, "claimActEndDate")) && !this.handleAmountValidation(component)) {  //Roshan
                    this.showVATWarningForNonEMEACountries(component);
                    if(component.get("v.showVATWarning"))
                    {
                        component.set("v.showVATWarningModal",true);
                    }
                    else
                    {
                        this.getDuplicateRecords(component);
                    }

                }


                if(component.get('v.isOutcomeBased')){
                    //Call Apex method to calculate amount fields
                    this.calculateAmountFields(component);
                }
            }
            else {
                //if valid claim form fails
                component.set("v.currentStep", "1");
            }
        }
        //on click of tab 2 [KPI section]
        else if (component.get("v.currentStep") == "3") {
            component.set("v.currentStep", "2");
        }
    
    },


    calculateAmountFields: function (component,callback) {
        var amountFields = {
            totalAmountLocal: component.get("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c"),
            costNotReimbursable: component.get("v.simpleNewClaim.Core_MDF_OtherCostsnotReimbursable_Local__c"),
            taxesLocal: component.get("v.simpleNewClaim.Core_MDF_Taxes_Local__c")
        };

        var action = component.get("c.calculateAmountFields");
        action.setParams({
            claim: component.get('v.simpleNewClaim'),
            amountFields: JSON.stringify(amountFields)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.Core_MDF_Reimbursable_Transaction_Amount__c){
                    //Core_MDF_Reimbursable_Transaction_Amount__c
                    component.set('v.reimbursableAmountUsd', result.Core_MDF_Reimbursable_Transaction_Amount__c);
                }                
                if(callback){
                    callback(); //indu defect fix
                }                
            } else {
                let errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.handleServerExceptions(component, errorMessage);
            }
        });

        $A.enqueueAction(action);
    },

    validateVatOptIn: function (component) {
        var isOptInFieldBlank = false;
        //To Validate VAT opt-in field
        if (component.get("v.vatOptInPicklistVisible") &&
            component.get("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c") == "") {
    
            isOptInFieldBlank = true;
            component.find('vatOptIn').showHelpMessageIfInvalid();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: $A.get("$Label.c.Core_MDF_VatOptInMandatoryMessage"),
                type: "error"
            });
            toastEvent.fire();
    
        }
    
        //To Validate Applicable VAT Percentage field
        if(component.get("v.showApplicableVatPercentage")
            && (component.get("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c") == "" || $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c")))) {
    
            isOptInFieldBlank = true;
            component.find('applicableVatPercentage').showHelpMessageIfInvalid();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: $A.get("$Label.c.Core_MDF_Applicable_VAT_Perc_Mandatory_Msg"),
                type: "error"
            });
            toastEvent.fire();
        }
    
        return isOptInFieldBlank;
    },
    
    //added by Vaishali to validate claim submitter value is not blank
    validateClaimSubmitterLookup: function (component) {
        var isClaimSubValueBlank = false;
        if (component.get("v.isUserClaimCaseReviewerOrManager") &&
            (component.get("v.claimSubValue") == '' || $A.util.isUndefinedOrNull(component.get("v.claimSubValue")))
            && !(component.get("v.isClaimEdit")) &&
            !component.get("v.claimSubDisabled")) {
            isClaimSubValueBlank = true;
    
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: "Claim Submitter is mandatory.",
                type: "error"
            });
            toastEvent.fire();
        }
        return isClaimSubValueBlank;
    },
    
    // This helper function is use to move to pervious Tab
    navigateToPreviousTab: function (component) {
        // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if (getCurrentStep == "2") {
            component.set("v.currentStep", "1");
        } else {
            //If KPI availble , goto KPI(second) page
            component.set("v.moveToThirdPage", false);
            if (component.get("v.isKpiSectionVisible") || component.get('v.isOutcomeBased')) {
                component.set("v.currentStep", "2");
            } else {
                //move to first page
                component.set("v.currentStep", "1");
            }
        }
    },
    // This helper function clears the RequestId and escalationId on change of Activity LookUp
    clearLookupField: function (component, event) {
        //Escalation check
        if ((event.getParam("instanceId")) == 'escalationId') {
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c", '');
            component.set("v.escalationNoSearchString", '');
            this.manageClaimSubmitterLookup(component);
        }
        else if ((event.getParam("instanceId")) == 'claimownerId') {
            //added by vaishali to clean up claim submitter lookup field
            component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c", '');
            component.set("v.claimSubSearchString", '');
            component.set("v.claimSubValue", '');
        }
        else {
            this.clearActivityLookUpFields(component, event);
        }
    },
    // This method is to clean up the activity related fields during lookup clean
    clearActivityLookUpFields: function (component, event) {
        //KPI flag to false on clear activity
        component.set("v.isKpiLoaded", false);
        //set flag to false on clear activity
        component.set("v.isKpiSectionVisible", false);
        //Clear pick list values, country and request ID , on activity clear lookup
        component.set("v.simpleNewClaim.RequestId", '');
        component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c", '');
        component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c", '');//added by vaishali to clean up claim submitter id when clearing up the lookup
        component.set("v.claimSubValue", '');
        // To disable claim submitter field
        component.set('v.claimSubSearchCriteria', '');
        component.set('v.spinner', false);
        this.clearPicklistValues(component);
        //lookup cmp will visible ,only if user is CCR/CCRM or CSC Claim Submitter
        //It will clear lookup and escalation Id
        if (component.get('v.isUserClaimCaseReviewerOrManager')|| component.get("v.isCSCClaimSubmitter")) {
            this.clearEscLookupWithEscId(component);
            //It will clear lookup and claim submitter Id;
            this.clearClaimSubLookup(component);
        }
        var bankComponent = component.find('claimBankDiv');
        if (!$A.util.isUndefinedOrNull(bankComponent)) {
            $A.util.removeClass(bankComponent, "slds-hide");
        }
        component.set("v.vatOptInPicklistVisible", false);
        component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", "");
        component.set("v.isOutcomeBasedAccountBasedAct", false);
        component.set("v.outcomeDesc", "");
    },
    // This helper function sets the RequestId and escalationId on change of Activity LookUp
    updateLookupField: function (component, event) {
        var recordId = event.getParam("sObjectId");
        
        let recordTypeName = component.get('v.recordtypeDeveloperName');
        let labelValue = $A.get("$Label.c.Core_MDF_Program_RecordTypes");
        let recordTypeList = labelValue.split(',').map(item => item.trim());
        
        //Escalation check
        if ((event.getParam("instanceId")) == 'escalationId') {
            component.set("v.escObjectId", recordId);
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c", recordId);
        }
        else if ((event.getParam("instanceId")) == 'claimownerId') {
    
            //to store claim submitter lookup value in claim submitter field on claim //added by vaishali
            component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c", recordId);
            component.set("v.claimSubValue", recordId);
    
        }
        else {
            component.set("v.sObjectId", recordId);
            // component.set("v.simpleNewClaim.RequestId",'');//Added to chek prod issue
            component.set("v.simpleNewClaim.RequestId", recordId);
            if (recordTypeList.includes(recordTypeName)) {//made Rishabh
                this.getTacticInformation(component, event, helper);
            }
            if (component.get('v.isUserClaimCaseReviewerOrManager')) {
                var escalationLookup = component.find('escalationId');
                if (!$A.util.isUndefined(escalationLookup)) {
                    escalationLookup.clearLookupPill();
                }
            }
        }
    },
    getTacticInformation : function(component, event, helper) {
        var action = component.get("c.getCampaignPurposeDetails");
        let claimId = (!component.get('v.isCloneClaim') ? component.get("v.simpleNewClaim.Id") : '');
        action.setParams({
            activityId: component.get("v.simpleNewClaim.RequestId"),
            claimId: claimId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.campaignPurposeWrapper", result);
                //Set columns and rows
                if(result.showTacticMetric){
                    component.set('v.isOutcomeBased', result.showTacticMetric);
                    component.set('v.tacticMetricsEditable', result.metricsEditable);
                    this.setColumns(component, result);
                    this.setRows(component);
                    if(result.quantityToDate != ''){
                        component.set('v.simpleNewClaim.Core_MDF_Quantity_to_Date_Nbr__c', parseInt(result.quantityToDate));
                    }
                }
            } else {
                let errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.handleServerExceptions(component, errorMessage);
            }
        });

        $A.enqueueAction(action);
    },

    handleCampaignPurposeChange : function(component, event, helper) {
        var updatedRows = JSON.parse(JSON.stringify(event.getParams('detail')))[0];
        component.set('v.simpleNewClaim.Core_MDF_Quantity_to_Date_Nbr__c', parseInt(updatedRows.quantity));
    },

    setColumns: function(component, result){
        let columns = component.get("v.isCampaignPurposeVisible") ? [
			{ label: result.outcomeMetricLabel, fieldName: 'outcome', displayField: 'outcomeLabel', editable: false },
			{ label: result.baselineQuantityLabel, fieldName: 'baselineQuantity', editable: false, type: 'number', required: false, min: 1, max: 2147483647, step: 1, helpText: result.baselineQuantityHelpText },
			{ label: result.goalQuantityLabel, fieldName: 'goalQuantity', editable: false, type: 'number', required: false, min: 1, max: 2147483647, step: 1, helpText: result.goalQuantityHelpText },
			{ label: result.quantityToDateLabel, fieldName: 'quantity', editable: component.get('v.tacticMetricsEditable'), type: 'number', required: true,min: 0, max: 2147483647, step: 1, helpText: result.quantityToDateHelpText},
			{ label: result.outcomeCriteriaLabel, fieldName: 'outcomeCriteria', editable: false, type: 'textarea', maxLength: 1000, required: false, helpText: result.outcomeCriteriaHelpText }
        ] :
        [
            { label: result.outcomeMetricLabel, fieldName: 'outcome', displayField: 'outcomeLabel', editable: false },
            { label: result.baselineQuantityLabel, fieldName: 'baselineQuantity', editable: false, type: 'number', required: false, min: 1, max: 2147483647, step: 1, helpText: result.baselineQuantityHelpText },
            { label: result.goalQuantityLabel, fieldName: 'goalQuantity', editable: false, type: 'number', required: false, min: 1, max: 2147483647, step: 1, helpText: result.goalQuantityHelpText },
            { label: result.quantityToDateLabel, fieldName: 'quantity', editable: component.get('v.tacticMetricsEditable'), type: 'number', required: true, min: 0, max: 2147483647, step: 1, helpText: result.quantityToDateHelpText },
            { label: result.baselinePeriodLabel, fieldName: 'baselinePeriod', editable: false, helpText: result.baselinePeriodHelpText },
            { label: result.resultValueLabel, fieldName: 'resultValue', editable: false, helpText: result.resultValueHelpText }
		];

        component.set('v.columns', columns);
    },

    setRows: function(component){
        let result = component.get("v.campaignPurposeWrapper");
        let resultArray = [];
        resultArray.push(result);
        let rows = component.get("v.isCampaignPurposeVisible") ? resultArray.map(function (row) {
            return {
                id: '1',
                outcome: row.outcomeMetric,
                outcomeLabel: row.outcomeMetric,
                baselineQuantity: row.baselineQuantity,
                goalQuantity: row.goalQuantity,
                quantity: row.quantityToDate,
                outcomeCriteria: row.outcomeCriteria
            };
        }) : resultArray.map(function (row) {
            return {
                id: '1',
                outcome: row.outcomeMetric,
                outcomeLabel: row.outcomeMetric,
                baselineQuantity: row.baselineQuantity,
                goalQuantity: row.goalQuantity,
                quantity: row.quantityToDate,
                baselinePeriod: row.baselinePeriod,
                resultValue: row.resultValue
            };
        });
        component.set("v.rows", rows);
    },

    //This helper function is used to clear claim submitter lookup and claim submitter id
    clearClaimSubLookup: function (component) {
        var claimSubLookup = component.find('claimownerId');
        //clear lookup pill only if claim submitter lookup is editable 
        if (!$A.util.isUndefinedOrNull(claimSubLookup) && !$A.util.isUndefined(claimSubLookup)) {
            //clear claim submitter lookup
            if (claimSubLookup.clearLookupPill) {
                claimSubLookup.clearLookupPill();
            }
        }
        // To clear the claim submitter id Value on clearing Activity Lookup
        if (!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c"))) {
            component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c", '');
        }
        // To clear the claim submitter text value
        if (!$A.util.isUndefinedOrNull(component.get("v.claimSubSearchString"))) {
            component.set("v.claimSubSearchString", '');
        }
    },
    
    //This helper function is used to clear escalation lookup and escalation id
    clearEscLookupWithEscId: function (component) {
        var escalationLookup = component.find('escalationId');
        //clear lookup pill only if escalation lookup is editable 
        if (!$A.util.isUndefinedOrNull(escalationLookup) && !$A.util.isUndefined(escalationLookup)) {
            //clear escalation lookup
            if (escalationLookup.clearLookupPill) {
                escalationLookup.clearLookupPill();
            }
        }
        // To clear the escalation id Value on clearing Activity Lookup
        if (!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c"))) {
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c", '');
        }
        // To clear the escalation text value
        if (!$A.util.isUndefinedOrNull(component.get("v.escalationNoSearchString"))) {
            component.set("v.escalationNoSearchString", '');
            //to enable disable claim submitter value based on escalation
            this.manageClaimSubmitterLookup(component);
        }
    },
    
    //Custom logic to load KPI after default renderer function on Claim Clone and Edit
    loadKPIAttributesOnCloneAndEdit: function (component) {
        if (((component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_Retail_Channel_Program_Name")) ||
            (component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Technical_program_name")) ||
            (component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_CCF_Program_Name")) ||
            (component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_Non_Localized_DCF_Program_Name")))
            && (component.get("v.isCloneClaim") || component.get("v.isClaimEdit"))) {
            // helper function to load KPI attributes
            this.loadKpiAttributes(component);
        }
    },
    
    //This helper function is used to navigate on tab click
    navigationOverTab: function (component, event, helper) {
        const runValidation = () => {
            //Validate tactic metrics // indu defect fix 
                        //const campaignPurposeResult = this.validateCampaignPurpose(component, event, helper);
                        const result = component.get("v.isCampaignPurposeVisible") === true ? this.validateCampaignPurpose(component, event, helper) : this.validateActivityPurpose(component, event, helper);//TWC3117-14942                        
                        const tacticMetricResult = this.validateTacticMetric(component, event, helper);
                        const tacticSpendingResult = this.validateTacticSpending(component, event, helper);
						//console.log('@@result567==>',result);
                        let finalClaimAttributeList = [];
                        //Incase of No Errors
                        //Need to add Edit Condition
                        if (result && tacticMetricResult.valid && tacticSpendingResult.valid ) {
                            if (tacticSpendingResult.claimAttributes.length > 0) {
                                finalClaimAttributeList = finalClaimAttributeList.concat(tacticSpendingResult.claimAttributes);
                            }
                            if (tacticMetricResult.claimAttributesObj.length > 0) {     // IPA-Rishabh
                                finalClaimAttributeList = finalClaimAttributeList.concat(tacticMetricResult.claimAttributesObj);
                            }

                            if (finalClaimAttributeList.length > 0) {
                                component.set('v.claimAttributeList', finalClaimAttributeList);
                            }

                            component.set("v.currentStep", "3");
                        } else {
                            component.set("v.moveToThirdPage", false);
                            //component.set("v.currentStep", "3");
                            finalClaimAttributeList = [];
                            component.set('v.claimAttributeList', finalClaimAttributeList);
                        }
        };
        const executeClaimFlow = () => {
            if (component.get("v.currentStep") == "1") {
                if(component.get("v.isSuperClaim")){
            		const subClaimresult = this.validateSubClaimItems(component, event, helper);
            	
            	if (!subClaimresult) {return;}
                }
                if (this.validateClaimForm(component)) {
                    //calling of validateClaimSubmitterLookup method done by vaishali 
                    //to validate claim submitter value is not blank before moving to next button
                    if (!this.validateClaimSubmitterLookup(component) && !this.validateVatOptIn(component) && !(this.validateClaimDates(component, "claimActStartDate") || this.validateClaimDates(component, "claimActEndDate")) && !this.handleAmountValidation(component)) {
                        this.showVATWarningForNonEMEACountries(component);
                        if (component.get("v.showVATWarning")) {
                            component.set("v.showVATWarningModal", true);
                        }
                        else {
                            this.getDuplicateRecords(component);
                        }

                    }



                    //IPA-Jegan
                    if (component.get('v.isOutcomeBased')) {
                        //Call Apex method to calculate amount fields
                        this.calculateAmountFields(component);
                    }


                }
                else {
                    //if valid claim form fails
                    component.set("v.currentStep", "1");
                }
            }

        };
        
        //focused tab value
        var stepValue = event.getSource().get("v.value");
        if (stepValue == "1") {
            component.set("v.currentStep", "1");
            //POP page
            component.set("v.moveToThirdPage", false);
        } else if (stepValue == "2" || stepValue == "3") {
            //If we clicked on KPI tab
            if (stepValue == "2") {
                component.set("v.moveToThirdPage", false);
                //on click of tab 2 [KPI section]
                if (component.get("v.currentStep") == "3") {
                    component.set("v.currentStep", "2");
                }
            } else {
                //If we clicked on POP tab
                component.set("v.moveToThirdPage", true);
                // validate KPI fields using validForm attribute
                if (component.get("v.currentStep") == "2" || stepValue == "3") {
                    if(component.get('v.isKpiSectionVisible') && stepValue != "3"){//IPA-Jegan
                        //click on KPI page next button
                        this.validateKPIFields(component, event, helper);
                    } else if (component.get('v.isOutcomeBased')) {
                        this.calculateAmountFields(component, () => {
                            runValidation();
                            executeClaimFlow();
                        });
                        return;

                    }
                }
            }
    
            //If opened tab is claim form and we clicked on KPI/POP tab
            if (component.get("v.currentStep") == "1") {
                if(component.get("v.isSuperClaim")){
            		  const subClaimresult = this.validateSubClaimItems(component, event, helper);
                  if (!subClaimresult) {return;}
                }
                if (this.validateClaimForm(component)) {
                    //calling of validateClaimSubmitterLookup method done by vaishali 
                    //to validate claim submitter value is not blank before moving to next button
                    if (!this.validateClaimSubmitterLookup(component) && !this.validateVatOptIn(component) && !(this.validateClaimDates(component, "claimActStartDate") || this.validateClaimDates(component, "claimActEndDate")) && !this.handleAmountValidation(component)) {  //Roshan
                        this.showVATWarningForNonEMEACountries(component);
                        if(component.get("v.showVATWarning"))
                        {
                            component.set("v.showVATWarningModal",true);
                        }
                        else
                        {
                            this.getDuplicateRecords(component);
                        }
    
                    }

                    //IPA-Jegan
                    if(component.get('v.isOutcomeBased')){
                        //Call Apex method to calculate amount fields
                        this.calculateAmountFields(component);
                    }
                }
                else {
                    //if valid claim form fails
                    component.set("v.currentStep", "1");
                }
            }
        }
    },
    
    //This helper function is used to move to next tab
    navigateToNextTab: function (component, event, helper) {
        //current step        
        var getCurrentStep = component.get("v.currentStep");
        if (getCurrentStep == "1") {
            if(component.get("v.isSuperClaim")){
            	const subClaimresult = this.validateSubClaimItems(component, event, helper);
              if (!subClaimresult) {return;}
            }
            //Navigate to KPI/POP page on click of claim form next button
            this.navigationOnNextButton(component);
        } else {
            //Navigate to POP page  on click of KPI section next button  
            if(component.get('v.isKpiSectionVisible')){//IPA-Jegan
                this.validateKPIFields(component, event, helper);
            }else if(component.get('v.isOutcomeBased')){
                //Validate tactic metrics
                //const campaignPurposeResult = this.validateCampaignPurpose(component, event, helper);
                const result = component.get("v.isCampaignPurposeVisible") === true ? this.validateCampaignPurpose(component, event, helper) : this.validateActivityPurpose(component, event, helper);
                const tacticMetricResult = this.validateTacticMetric(component, event, helper);
                const tacticSpendingResult = this.validateTacticSpending(component, event, helper);
                
                let finalClaimAttributeList = [];
                //Incase of No Errors
                //Need to add Edit Condition
                if (result && tacticMetricResult.valid && tacticSpendingResult.valid) {
                    if(tacticSpendingResult.claimAttributes.length > 0){
                        finalClaimAttributeList = finalClaimAttributeList.concat(tacticSpendingResult.claimAttributes);
                    }
                    if(tacticMetricResult.claimAttributesObj.length > 0){     // IPA-Rishabh
                        finalClaimAttributeList = finalClaimAttributeList.concat(tacticMetricResult.claimAttributesObj);
                    }

                    if(finalClaimAttributeList.length > 0){
                        component.set('v.claimAttributeList', finalClaimAttributeList);
                    }

                    component.set("v.currentStep", "3");
                }else{
                    finalClaimAttributeList = [];
                    component.set('v.claimAttributeList', finalClaimAttributeList);
                }
            }
        }
    },

    //IPA-Jegan
    validateCampaignPurpose: function (component, event, helper) {
        const tacticSpendingCmp = component.find("campaignPurposeCmp");
        const result = tacticSpendingCmp.validate();
        
        return result.isValid;
    },
    validateActivityPurpose: function (component, event, helper) {
        const activityPurposeCmp = component.find("activityPurposeCmp");
        const result = activityPurposeCmp.validate();
        return result.isValid;
    },
	// IPA-Rishabh
    validateTacticMetric: function (component, event, helper) {
        const tacticMetricCmp = component.find("tacticMetricCmp");
        const result = tacticMetricCmp.validate();
        let finalResult = {valid: result};
        let claimAttributesObj = {};
        if(result){
            claimAttributesObj = tacticMetricCmp.getAllMatricValueforRecordcreation();
            finalResult.claimAttributesObj = claimAttributesObj; 
        }
        return finalResult;
    },

    validateTacticSpending: function (component, event, helper) {
        const tacticSpendingCmp = component.find("tacticSpendingCmp");
        const result = tacticSpendingCmp.validate();
        let finalResult = {valid: result};
        let claimAttributes = {};
        if(result){
            claimAttributes = tacticSpendingCmp.prepareClaimAttributes();
            finalResult.claimAttributes = claimAttributes;
        }
        
        return finalResult;
    },

    //This function used to check for escalation lookup to be enabled/disabled
    manageEscalationLookup: function (component) {
        if ((component.get("v.isRetailClaimSubmitter") || component.get("v.isUserPRCRMFClaimOperation") || component.get("v.isCSCClaimSubmitter")) && component.get("v.escalationId") != ''
            && !$A.util.isUndefinedOrNull(component.get("v.escalationId"))) {
            //escalation lookup will be disabled , if retail claim submiter is trying to create claim from escalation
            component.set("v.escalationDisabled", true);
        } else if (component.get("v.isUserClaimCaseReviewerOrManager")||component.get("v.isCSCClaimSubmitter")) {
            if (component.get("v.isClaimEdit") || $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.RequestId"))
                || component.get("v.simpleNewClaim.RequestId") == '') {
                //escalation lookup will be disabled in case of edit or if activity is not selected
                component.set("v.escalationDisabled", true);
            } else {
                //escalation lookup will be enabled in case of clone or if activity is selected
                component.set("v.escalationDisabled", false);
            }
        }
    },

    //This function used to check for claim submitter lookup to be enabled/disabled
    //added by vd for owner change
    manageClaimSubmitterLookup: function (component) {
        var isEscPopulated;
        if ($A.util.isUndefinedOrNull(component.get("v.escalationNoSearchString")) || component.get("v.escalationNoSearchString") == '') {
            isEscPopulated = false;
        }
        else {
            isEscPopulated = true;
        }
        if (component.get("v.isUserClaimCaseReviewerOrManager") &&
            (component.get("v.isClaimEdit") || component.get("v.simpleNewClaim.RequestId") == ''
                || $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.RequestId")) ||
                Boolean(isEscPopulated))) {
            component.set("v.claimSubDisabled", true);
            if (Boolean(isEscPopulated)) {
                component.set("v.claimSubSearchString", '');
                if (!$A.util.isUndefinedOrNull(component.get("v.escalationClaimSubmitter"))) {
                    component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c", component.get("v.escalationClaimSubmitter"));
                }
            }
        }
        else {
            component.set("v.claimSubDisabled", false);
        }
    
    },
    
    /**This function used to disable activity lookup in case of edit claim, clone claim and
     if retail claim submitter create claim from late claim escalation**/
    manageActivityLookup: function (component) {
        if (!component.get("v.activityDisabled")
            && (component.get("v.isClaimEdit") || component.get("v.isCloneClaim") ||
                ((component.get("v.isRetailClaimSubmitter") || component.get("v.isUserPRCRMFClaimOperation") || component.get("v.isCSCClaimSubmitter")) && component.get("v.escalationId") != ''
                    && !$A.util.isUndefinedOrNull(component.get("v.escalationId"))))) {
            component.set("v.activityDisabled", true);
        }
    },
    
    // Show or Hide Vat Opt In field for selected Bank's legal entity(Edit/Clone) or when its changed
    showOrHideVatOptIn: function (component) {
        // On Changing Bank Clear Off the Vat Opt In picklist Value
        component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", "");
    
        // On Changing Bank Clear Off the Applicable VAT Percentage picklist Value
        component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", "");
    
        var bankObjectList = component.get("v.bankObjectList");
        var legalEntity;
        var bankId = component.get("v.simpleNewClaim.Core_MDF_Bank__c");
        for (var index = 0; index < bankObjectList.length; index++) {
            if (bankObjectList[index].value.Core_MDF_Bank__r.Id == bankId) {
                legalEntity = bankObjectList[index].value.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c;
                break;
            }
        }
        var program = component.get("v.technicalProgName");
    
        this.showOrHideVatOptInAndVATPercentage(component, program, legalEntity);
    },
    
    
    //To show or Hide VAT opt-in field and Applicable VAT Percentage
    showOrHideVatOptInAndVATPercentage: function(component, program, legalEntity){
    
        var action = component.get("c.ckeckProgramLEForVatOptIn");
        action.setParams({
            'legalEntity': legalEntity,
            'channelProgram': program
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                var res = response.getReturnValue();
                //component.set("v.vatMdtRecord", res); //added as part of Handle Tax Code Story for 420 LE
                //To Show or Hide Core_MDF_VAT_Opt_In__c field
                if(Boolean(res.Core_MDF_VAT_Mandatory__c)) {
                    // Hide the Picklist field When Response is coming false; by default Set Picklist value as Yes
                    component.set('v.vatOptInPicklistVisible', false);
                    component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", (component.get('v.hideBank') ? '' : $A.get("$Label.c.Core_MDF_nonTranslate_Service_Invoice_to_Intel")));
                }
                else if(Boolean(res.Core_MDF_VAT_Opt_in_Option_Required__c)){
                    // To Show Picklist field When reponse value is true it wont override we are not setting the value only hide and show.
                    this.showOrHideVATOptInOptionFor420and650(component,false);
                    //component.set('v.vatOptInPicklistVisible', component.get('v.hideBank') ? false : true);
                }else{
                    // If both checkboxes are untrue then Hide the Picklist field and nullify Core_MDF_VAT_Opt_In__c
                    component.set('v.vatOptInPicklistVisible', false);
                    component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", "");
                }
    
                //To show or Hide Core_MDF_Show_Applicable_VAT_Percentage__c field - new VAT process changes - RP
                // if (res.Core_MDF_Show_Applicable_VAT_Percentage__c) {
                //     component.set('v.showApplicableVatPercentage', component.get('v.hideBank') ? false : true);
                //     this.setApplicableVatPercenatgeFor650(component);
                // } else {
                //     component.set('v.showApplicableVatPercentage', false);
                // }
    
    
            }
            else if (state === "SUCCESS" && response.getReturnValue() == null) {
                // If Response is null Hide the Picklist field and nullify Core_MDF_VAT_Opt_In__c and Core_MDF_Applicable_VAT_Percentage_nm__c
                component.set('v.vatOptInPicklistVisible', false);
                component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", "");
                
                component.set('v.showApplicableVatPercentage', false);
                component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", "");
                }
            else {
                this.handleServerExceptions(component, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    onCountryChangeShowOrHideVATOption: function (component) {
        
            // On Changing Country  Clear Off the Applicable VAT Percentage picklist Value
            this.showOrHideVATOptInOptionFor420and650(component,true);
    
    },
    
    //Show or Hide VAT-opt in for 420 LE based on Bank or Claim Country [and 650]
    showOrHideVATOptInOptionFor420and650: function (component,isCountryChanged) {
        
        if (!$A.util.isUndefinedOrNull(component.get("v.countryCodeToRegionMap")) && !$A.util.isEmpty(component.get("v.countryCodeToRegionMap")) 
        && !$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Bank__c")) && !$A.util.isEmpty(component.get("v.simpleNewClaim.Core_MDF_Bank__c"))
            && (!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c")) && !$A.util.isEmpty(component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c")) || component.get("v.technicalProgName") == $A.get("$Label.c.Core_MDF_Co_GTM_Technical_program_name"))) { 
            const selectedbankId = component.get("v.simpleNewClaim.Core_MDF_Bank__c");
            const bankList = component.get("v.bankObjectList");
            
            const index = bankList.findIndex(bank => bank.value.Core_MDF_Bank__c == selectedbankId);
            if (index != -1) {
                if (bankList[index].value.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c== '420')
                { 
                    if(isCountryChanged) {
                        component.set('v.simpleNewClaim.Core_MDF_VAT_Opt_In__c', '');
                    }           
                    
                    this.getBankRegion(component,bankList[index].value);
                    
                } //new VAT process changes - RP
                else if(bankList[index].value.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c== '650') {
                    component.set('v.vatOptInPicklistVisible', component.get('v.hideBank') ? false : true);
                    
                }
                 
            }
        }
    
    },
    
    //get Bank Region based country code and Set VAT Opt-in visibility
    getBankRegion: function (component, bankRecord) {

            const bankCountryCode = bankRecord.Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c ;
            let geoToRegionMap = component.get("v.countryCodeToRegionMap");
            var bankRegion ;

            for (const [key, value] of Object.entries(geoToRegionMap)) {
                    if(key == bankCountryCode)
                    {
                       bankRegion = value;
                       break;
                    }
            }           
        if (bankRegion == 'EMEA' && (bankRecord.Core_MDF_Bank__r.Core_MDF_Supplier_Country_txt__c == 'GB' || component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c") == 'UNITED KINGDOM' || component.get("v.technicalProgName") == $A.get("$Label.c.Core_MDF_Co_GTM_Technical_program_name"))) { 
                        component.set('v.vatOptInPicklistVisible', component.get('v.hideBank') ? false : true);
                }
            else {
                        component.set('v.vatOptInPicklistVisible', false);
                        component.set('v.simpleNewClaim.Core_MDF_VAT_Opt_In__c',  $A.get("$Label.c.Core_MDF_nonTranslate_Reimbursement_Request_for_3rd_party_payment"));
                        component.set("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c", "");
                }       
    
    },

    // WW05 - Set applicable VAT Percentage for 650 LE
    setApplicableVatPercenatgeFor650: function (component) {
    
        if(component.get('v.showApplicableVatPercentage'))
                {
            const vatPercentage = component.get("v.applicableVATPercentageMap");
            const applicablePercentageFor650 = $A.get("$Label.c.Core_MDF_VATPercentageFor650").split(',');
                        const existingVatPerKey = component.get("v.simpleNewClaim.Core_MDF_Applicable_VAT_Percentage_nm__c");
            const existingVatPerValue = new Array(existingVatPerKey + '%');
            let vatPercentageMapFor650 =[];
            if(!$A.util.isUndefinedOrNull(vatPercentage))
                    {
                vatPercentage.forEach(vat => {
                    if(applicablePercentageFor650.includes(vat.value))
                            {
                        vatPercentageMapFor650.push(vat);
                    } else {// Added by JK - For retaining 8% of tax code in case of edit for existing data.
                        if(component.get("v.isClaimEdit") && (!$A.util.isUndefinedOrNull(existingVatPerValue)) && existingVatPerValue.includes(vat.value)) {
                            vatPercentageMapFor650.push(vat);
                        }
                    }
                });
                component.set("v.applicableVATPercentageMap", vatPercentageMapFor650);
    
            }
    
        }
    },
    // On Click of Edit of Claim - Show selected previous value of vat Opt In 
    // Or render Picklist field based on the legal Entity and Program
    onEditOrCloneOfClaimShowOrHidevatOptIn: function (component) {
    
        if (component.get("v.isCloneClaim")) {
            component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c", "");
        }
        var legalEntity = component.get("v.simpleNewClaim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c");
        var channelProgram = component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c");
    
        this.showOrHideVatOptInAndVATPercentage(component, channelProgram, legalEntity);
    },
    
    showLookupPill: function (component, sobjectLookupInstace) {
        // Show the Lookup pill
        var lookupPill = sobjectLookupInstace.find("lookup-pill");
        $A.util.addClass(lookupPill, 'slds-show');
        $A.util.removeClass(lookupPill, 'slds-hide');
        var lookup = sobjectLookupInstace.find("lookup");
        $A.util.addClass(lookup, 'slds-hide');
        $A.util.removeClass(lookup, 'slds-show');
    },
    
    saveClaimMethods: function (component, event, helper) {
        component.set("v.showConfirmationPopupForPIC", false);
        component.set("v.isConfirmPopupVisible", false);
        this.populateClaimReviewEscIndicator(component);
        if (component.get('v.isKpiSectionVisible')) {
            this.mergePfcAndKpiValues(component);
        }
        this.clearUpClaimIdOnClone(component);
        this.saveClaimResult(component, event, helper);
    },
    
    
    //This method is to update the claim Status
    updateClaimStatusToPICPending: function (component, event, helper) {
        const isOutcomeBased = component.get("v.isOutcomeBasedAccountBasedAct");
        //update the status to PIC Pending(for claim status - resubmission required, pending documents)
        if (component.get("v.simpleNewClaim.Core_MDF_Status__c") === $A.get("$Label.c.Core_MDF_Claim_Status_Resubmission_Required")) {//only for resubmission required
            component.set("v.simpleNewClaim.Core_MDF_Legacy_Reminder_txt__c", '');
        }
        component.set("v.simpleNewClaim.Core_MDF_Status__c", isOutcomeBased ? $A.get("$Label.c.Core_MDF_Claim_Status_Payment_Clearance_Processing"): $A.get("$Label.c.Core_MDF_Claim_Status_PIC_Pending"));
        component.set("v.simpleNewClaim.Core_MDF_Doc_Hold_Doc_Sub_Due_Date_Dtm__c", null);
        this.saveClaimMethods(component, event, helper);
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
    
    update3rdPartyDetails: function (component, event, helper) {
        var is3rdPartyPOP = event.getParam("passData");
        console.log(" event is3rdPartyPOP", is3rdPartyPOP);
        component.set("v.simpleNewClaim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c", is3rdPartyPOP.isThirdPartyPOP);
        component.set("v.simpleNewClaim.Core_MDF_Review_Hold_Rule_Nm__c", is3rdPartyPOP.ruleId);
    
        if(!component.get('v.byPassLogInfoFieldMapping')){
            //Claim Details
            var claimDetails = 'Claim Details: \n Id: ' + component.get("v.simpleNewClaim.Id") +
                ', Core_MDF_3rd_Party_POP_Doc_Required_Ind__c: ' + component.get("v.simpleNewClaim.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c") +
                ', Core_MDF_Activity_Types__c: ' + component.get("v.simpleNewClaim.Core_MDF_Activity_Types__c") +
                ', Core_MDF_Ultimate_Account_ID__c: ' + component.get("v.simpleNewClaim.Core_MDF_Ultimate_Account_ID__c") +
                ', Core_MDF_Total_Invoice_Amount_Local__c: ' + component.get("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c") +
                ', Core_MDF_Program__c: ' + component.get("v.simpleNewClaim.Core_MDF_Program__c") +
                ', Core_MDF_Budget_Type_Options_Nm__c: ' + component.get("v.simpleNewClaim.Core_MDF_Budget_Type_Options_Nm__c") + '\n\n';
    
            //Rule engine details
            var ruleEngineDetails = 'Rule Engine Details: \n ' + JSON.stringify(is3rdPartyPOP) + '\n\n\n';
    
            var thirdPartyDetails = '';
    
            //Adding Claim details
            if(claimDetails != undefined){
                thirdPartyDetails = claimDetails;
            }
    
            //Adding Rule engine details
            if(ruleEngineDetails != undefined){
                thirdPartyDetails += ruleEngineDetails;
            }
    
            //Add existing Core_MDF_Log_Info_txt__c field value incase of Update
            thirdPartyDetails = component.get("v.simpleNewClaim.Core_MDF_Log_Info_txt__c") != null ? (thirdPartyDetails + component.get("v.simpleNewClaim.Core_MDF_Log_Info_txt__c")) : thirdPartyDetails;
            //Get first 100000 characters
            thirdPartyDetails = (thirdPartyDetails != undefined) ? thirdPartyDetails.slice(0,100000) : '';
    
            component.set("v.simpleNewClaim.Core_MDF_Log_Info_txt__c", thirdPartyDetails);
    
            //console.log('Core_MDF_Log_Info_txt__c' + component.get("v.simpleNewClaim.Core_MDF_Log_Info_txt__c"));
        }
    },
    
    // Capture Start Time during Claim Creation
    partnerEffortMetricforClaimCreation : function(component){
        var currDateTime = new Date();
        const startDateTime = new Date(currDateTime).toISOString();
        component.set("v.claimCreationStartTime",startDateTime);
    },
    handleChange: function(component, event, helper) {
        helper.handleFieldChange(component, event, helper);
        //Roshan
        if (event.getSource().get("v.name") === 'Core_MDF_Total_Invoice_Amount_Local__c') {
            helper.handleAmountValidation(component);
        }
    },

    //capture onchanged field names to not populate value from ClaimEzy result
    handleFieldChange: function(component, event, helper) {
        var changedFieldName = event.getSource().get("v.name");
        var changedFieldValue = event.getSource().get("v.value");

        var changedFields = component.get("v.changedFieldsfromUI");

        if (!changedFields.includes(changedFieldName) && changedFieldValue != '' && changedFieldValue != null) { // Add field names into an array
            changedFields.push(changedFieldName);
            component.set("v.changedFieldsfromUI", changedFields);
        }else if(changedFieldValue == '' || changedFieldValue == null){ // Remove field names from an array
            var filteredArray = changedFields.filter(function(item) {
                return item !== changedFieldName;
            });
            component.set("v.changedFieldsfromUI", filteredArray);
        }
    },
    
    //Method to validate the uploaded file and continue the ClaimEzy process to auto populate fields based on uploaded file.
    handleFilesChange: function (component, event, helper) {
        component.set("v.spinner", true);
      
        //Get the uploaded file details(File name, DocumentId)
        let uploadedFiles = event.getParam("files");
        var fileName = 'No File Selected..';
        var fileId;
        var fileExt = '';
        if (event.getParam("files").length > 0) {
            fileName = event.getParam("files")[0]['name'];   
            fileId = event.getParam("files")[0]['documentId']; 
            //To get the uploaded file format
            if(fileName.includes('.')){
                fileExt = fileName.split('.').pop();
            }
        }

        //Allowed file formats for ClaimEzy process
        var fileFormatsSupported = $A.get("$Label.c.Core_MDF_AllowedFileTypes_POC");

        if(fileFormatsSupported.includes(fileExt)){

            var action1 = component.get("c.getDocumentData"); 
            action1.setParams({docId: fileId});
            action1.setCallback(this, function(response) {
            
                if (response.getState() === "SUCCESS" &&  response.getReturnValue() != null && response.getReturnValue().proposedClaimData != null) {

                    component.set("v.spinner", false);
                    
                    //Clear simpleNewClaim pre populated fields
                    this.resetProposedValues(component);

                    //Populate the fields based on the results
                    //Ignore the fields where the user done manual changes
                    var changedFieldsFromUI = component.get('v.changedFieldsfromUI');
                    if (!changedFieldsFromUI.includes('Core_MDF_Invoice_Date__c')) {
                        component.set("v.simpleNewClaim.Core_MDF_Invoice_Date__c", response.getReturnValue().proposedClaimData.Core_MDF_Invoice_Date__c);
                    }
                    if (!changedFieldsFromUI.includes('Core_MDF_Invoice_Number__c')) {
                        component.set("v.simpleNewClaim.Core_MDF_Invoice_Number__c", response.getReturnValue().proposedClaimData.Core_MDF_Invoice_Number__c);
                    }
                    if (!changedFieldsFromUI.includes('Core_MDF_Total_Invoice_Amount_Local__c')) {
                        component.set("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c", response.getReturnValue().proposedClaimData.Core_MDF_Total_Invoice_Amount_Local__c);
                    }
                    // Roshan - Commented as part of TWC3117-15435
                    // if (!changedFieldsFromUI.includes('Core_MDF_Taxes_Local__c')) {
                    //     component.set("v.simpleNewClaim.Core_MDF_Taxes_Local__c", response.getReturnValue().proposedClaimData.Core_MDF_Taxes_Local__c);
                    // }
                    if (!changedFieldsFromUI.includes('Core_MDF_Currency__c')) {
                        component.set("v.simpleNewClaim.Core_MDF_Currency__c", response.getReturnValue().proposedClaimData.Core_MDF_Currency__c);
                    }
                    component.set("v.invoiceDocId", response.getReturnValue().docId);

                    //Add the uploaded file in the Audit document object and populate the Audit document fields.
                    this.auditDocumentFieldPopulation(component, uploadedFiles);
                    
                } else if(response.getState() === "SUCCESS" &&  response.getReturnValue() != null && response.getReturnValue().isError){
                    // Call the function to Handle the Server Exceptions
                    component.set("v.spinner", false);
                    var error = response.getReturnValue().errorMsg;
                    //In case of any unhandled error showing custom error instead of Application error
                    var customErrorMsg = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,' + $A.get("$Label.c.Core_MDF_Claim_ezy_NovaluePopulatedError") + ':';
                    let errorMessage = (error != null && error.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) ? error : customErrorMsg;
                    
                    //In case of any error delete the uplaoded file
                    if(fileId != undefined){
                        this.deleteContentDocuments(component, fileId);
                    }
                    this.handleServerExceptions(component, errorMessage);
                }else {
                    // Call the function to Handle the Server Exceptions
                    component.set("v.spinner", false);
                    var error = JSON.stringify(response.getError());
                    //In case of any unhandled error showing custom error instead of Application error
                    var customErrorMsg = 'FIELD_CUSTOM_VALIDATION_EXCEPTION,' + $A.get("$Label.c.Core_MDF_Claim_ezy_NovaluePopulatedError") + ':';
                    let errorMessage = response.getError() != null ? ((response.getError()[0].message != null && response.getError()[0].message.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) ? response.getError()[0].message : customErrorMsg ) : customErrorMsg ;
                    
                    //In case of any error delete the uplaoded file
                    if(fileId != undefined){
                        this.deleteContentDocuments(component, fileId);
                    }
                    this.handleServerExceptions(component, errorMessage);
                }
            });
            $A.enqueueAction(action1);
        }else{//If the uploaded file is not in valid format then show the error and delete the uplaoded file
            component.set("v.spinner", false);
            if(fileId != undefined){
                //In case of file format issue, delete the uploaded file 
                this.deleteContentDocuments(component, fileId);
            }
            this.handleServerExceptions(component, 'FIELD_CUSTOM_VALIDATION_EXCEPTION,' + $A.get("$Label.c.Core_MDF_Claim_ezy_SupportedFileFormatsError") + ':');
       }
     },

    //Method to add the uploaded file in the Audit document object and populate the Audit document fields.
    auditDocumentFieldPopulation: function (component, uploadedFiles) {
        var auditDocList = [];
        let uploadedFileNameWithoutExt;
        let encodedUploadedFileName;
        let encodedUploadedFileNameWithExt;
        let reduction = 0;
        let extPosition;
        let fileExt;
        auditDocList= component.get("v.auditDocument");
        uploadedFiles.map(uploadedFile => {
            var fileNameShorteningInd = $A.get("$Label.c.Core_MDF_SFTNameShortening_Ind");

            if(fileNameShorteningInd == 'True'){
                extPosition = uploadedFile.name.lastIndexOf(".");//extention position 
                fileExt = uploadedFile.name.substring(extPosition);
                uploadedFileNameWithoutExt = uploadedFile.name.substring(0, extPosition);
                encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                var updatedName = uploadedFile.name.replaceAll("`","_");
                encodedUploadedFileNameWithExt = encodeURI(updatedName.replace(/[{}|\\^~[\]]/g, "_"));
                while(encodedUploadedFileNameWithExt.length > 130){
                    uploadedFileNameWithoutExt = uploadedFileNameWithoutExt.substring(0, 60 - reduction);
                    encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                    encodedUploadedFileNameWithExt = encodeURI(uploadedFileNameWithoutExt +fileExt);
                    reduction = reduction + 5 ;
                }
            }

            auditDocList.push({
                sobjectType: "Core_MDF_Audit_Document__c",
                Core_MDF_Document_Title__c: uploadedFile.name,
                Core_MDF_Download_Document_Title_txt__c:decodeURI(encodedUploadedFileNameWithExt),
                Core_MDF_Encoded_Document_Title_txt__c:encodedUploadedFileNameWithExt,
                Core_MDF_Document_Id__c: uploadedFile.documentId,
                Core_MDF_Document_Types__c: "Proof of Cost",
                Core_MDF_Old_Document_Id__c : this.generateAppId(),
                Core_MDF_App_Document_Types_nm__c: "Proof of Cost;Proof of Execution;Proof of Attribution",
                Core_MDF_ContentVersion_Id__c : uploadedFile.contentVersionId,
                isNewDocument: true,
            });
    
            component.set("v.auditDocument",auditDocList);
        });
     },

    //Delete errored docs because of exception or file format issue(Ex: .xls,.doc)
    deleteContentDocuments : function(component, documentId) {
        var action = component.get("c.deleteDocuments");
        action.setParams({ contentDocumentId : documentId });
        
        action.setCallback(this, function(response) {
            
        });
        $A.enqueueAction(action);
    },
    
    //Reset the autopoulated fields
    resetProposedValues: function (component){
        
        //Reset the values
        //Ignore the fields where the user done manual changes
        var changedFieldsFromUI = component.get('v.changedFieldsfromUI');
        if (!changedFieldsFromUI.includes('Core_MDF_Invoice_Date__c')) {
            component.set("v.simpleNewClaim.Core_MDF_Invoice_Date__c", '' );
        }
        if (!changedFieldsFromUI.includes('Core_MDF_Invoice_Number__c')) {
            component.set("v.simpleNewClaim.Core_MDF_Invoice_Number__c",'' );
        }
        if (!changedFieldsFromUI.includes('Core_MDF_Total_Invoice_Amount_Local__c')) {
            component.set("v.simpleNewClaim.Core_MDF_Total_Invoice_Amount_Local__c", '');
        }
        // Roshan - Commented as part of TWC3117-15435
        // if (!changedFieldsFromUI.includes('Core_MDF_Taxes_Local__c')) {
        //     component.set("v.simpleNewClaim.Core_MDF_Taxes_Local__c", '');
        // }
        if (!changedFieldsFromUI.includes('Core_MDF_Currency__c')) {
            component.set("v.simpleNewClaim.Core_MDF_Currency__c",'' );
        }
    },
             
    //Indicator check to enable and disable the Claim ezy process
	checkIsClaimEzyEnabled: function (component){
        var action = component.get("c.isClaimEzyEnabled");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                var res = response.getReturnValue();
            if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Claim_COGTM_RecordType")) || component.get("v.isCoGtm")==true){ 
                res = false;
            }
                component.set("v.isClaimEzyEnabled",res);
            }else{
                let errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                component.set("v.spinner", false);
                this.handleServerExceptions(component, errorMessage);
            }
        });
        $A.enqueueAction(action);
    },

    generateAESKey: function() {
        // Generate a random 128-bit (16 bytes) key
        var array = new Uint8Array(16);
        window.crypto.getRandomValues(array);
        return array;
    },

    byteArrayToHex: function(byteArray) {
        return Array.from(byteArray, function(byte) {
            return ('0' + (byte & 0xFF).toString(16)).slice(-2);
        }).join('');
    },

    formatDateTime:function(date) {
        let year = date.getFullYear();
        let month = (date.getMonth() + 1).toString().padStart(2, '0'); // Months are zero-indexed
        let day = date.getDate().toString().padStart(2, '0');
        let hours = date.getHours().toString().padStart(2, '0');
        let minutes = date.getMinutes().toString().padStart(2, '0');
        let seconds = date.getSeconds().toString().padStart(2, '0');
    
        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    },

    deleteWhitespace: function(str) {
        // Remove all whitespace from a string
        return str.replace(/\s+/g, '');
    },

    generateAppId: function() {
        // Generate AES key
        var key = this.generateAESKey();
        // Convert byte array to hex string
        var hexKey = this.byteArrayToHex(key);
        // Get current timestamp
        var timestamp = this.formatDateTime(new Date());
        // Combine key and timestamp
        var guid = hexKey + timestamp;
        // Remove dashes and colons
        guid = guid.replace(/-/g, '');
        guid = guid.replace(/:/g, '');
        // Remove all whitespace
        var appId = this.deleteWhitespace(guid);
        return appId;
    },

    handleStartDateChange: function(component, event, helper, claimStartDate) {
        let selStartDate;
        if(!$A.util.isUndefinedOrNull(claimStartDate)) {
            selStartDate = claimStartDate;
        } else {
            selStartDate = event.getSource().get("v.value");

        }
        let convertedStartDate = new Date(selStartDate);
        let yearOfstrtDate = convertedStartDate.getUTCFullYear();
        if(yearOfstrtDate >= 2025) {
            component.set("v.showExcludedTaxMessage", true);
        } else {
            component.set("v.showExcludedTaxMessage", false);
        }
        this.validateClaimDates(component, "claimActStartDate");  //Roshan
    },
    
    setPayTypeDefaultValuePicklist: function(component) {
		const isFinalOutcomeBased = component.get("v.isOutcomeBasedAccountBasedAct");
        // Stamping value from current claim for edit scenario
        if (component.get("v.isClaimEdit")) {
            const processingPreference = !isFinalOutcomeBased ? component.get("v.simpleNewClaim.Core_MDF_Processing_Preference_nm__c") : $A.get("$Label.c.Core_MDF_nonTranslate_Fast_Pay");
            component.set("v.simpleNewClaim.Core_MDF_Processing_Preference_nm__c",processingPreference);
            //component.set("v.simpleNewClaim.Core_MDF_Processing_Preference_nm__c", component.get("v.simpleNewClaim.Core_MDF_Processing_Preference_nm__c"));
        } else {
            var action = component.get("c.getDefaultPayTypePicklist");
            var formattedDate = new Date();
            var programName = component.get("v.simpleNewClaim.Core_MDF_Program__c");
            var budgetTypeName = component.get("v.simpleNewClaim.Core_MDF_Budget_Type_Options_Nm__c");

            action.setParams({
                claimCreatedDate: formattedDate,
                program: programName,
                budgetType: budgetTypeName
            });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS" && response.getReturnValue() != null) {
                    var payType = response.getReturnValue();  
                    var selectedValue = payType.surePay ? $A.get("$Label.c.Core_MDF_nonTranslate_Sure_Pay") : $A.get("$Label.c.Core_MDF_nonTranslate_Fast_Pay");
                    const processingPreference = !isFinalOutcomeBased ? selectedValue : $A.get("$Label.c.Core_MDF_nonTranslate_Fast_Pay");
                    component.set("v.simpleNewClaim.Core_MDF_Processing_Preference_nm__c",processingPreference);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"),
                        type: "error"
                    });
                    toastEvent.fire();

                    this.closeModel(component);
                }
            });
            $A.enqueueAction(action);
        }
	},
  
    //Roshan
    validateClaimDates: function (component, changedField) {
        const userTimeZone = $A.get("$Locale.timezone");
        const userToday = new Date().toLocaleDateString("en-CA", { timeZone: userTimeZone });

        const claimStartDate = component.find("claimActStartDate").get("v.value");
        const claimEndDate = component.find("claimActEndDate").get("v.value");
        const activityStart = component.get("v.simpleNewClaim.Core_MDF_Activity_Start_Date__c");
        const activityEnd = component.get("v.simpleNewClaim.Core_MDF_Activity_End_Date__c");
        const isFinalOutcomeBased = component.get("v.isOutcomeBasedAccountBasedAct");

        let errorMessage = "";
        let isDateInvalid = false;

        const isStart = changedField === "claimActStartDate";
        const currentValue = component.find(changedField).get("v.value");

        if (currentValue) {
            if (currentValue > userToday) {
                errorMessage = isStart ? $A.get("$Label.c.Core_MDF_StartDateFutureValidation") : $A.get("$Label.c.Core_MDF_EndDateFutureValidation");
            } else if (currentValue < activityStart || currentValue > activityEnd) {
                errorMessage = isFinalOutcomeBased ? (isStart ? $A.get("$Label.c.Core_MDF_StartDateValidation_OutcomeBased") : $A.get("$Label.c.Core_MDF_EndDateValidation_OutcomeBased")) : (isStart ? $A.get("$Label.c.Core_MDF_StartDateValidation") : $A.get("$Label.c.Core_MDF_EndDateValidation"));
            } else if (claimStartDate && claimEndDate && claimStartDate > claimEndDate) {
                errorMessage = isStart ? $A.get("$Label.c.Core_MDF_StartDate_EndDate_Validation") : $A.get("$Label.c.Core_MDF_EndDate_StartDate_Validation");
            }
        }

        if (errorMessage) {
            component.find(changedField).setCustomValidity(errorMessage);
            isDateInvalid = true;
        } else {
            component.find(changedField).setCustomValidity("");
        }
        component.find(changedField).reportValidity();

        if (claimStartDate && claimEndDate) {
            const insideActDateRange = claimStartDate >= activityStart && claimStartDate <= activityEnd && claimEndDate >= activityStart && claimEndDate <= activityEnd;
            const dateNotInFuture = claimStartDate <= userToday && claimEndDate <= userToday;

            if (dateNotInFuture && insideActDateRange && claimStartDate <= claimEndDate) {
                component.find("claimActStartDate").setCustomValidity("");
                component.find("claimActEndDate").setCustomValidity("");
                component.find("claimActStartDate").reportValidity();
                component.find("claimActEndDate").reportValidity();
                isDateInvalid = false;
            }
        }

        return isDateInvalid;
    },

    handleAmountValidation: function (component) {
        var isAmountInvalid = false;

        const claimInvoiceAmntLocal = parseFloat(component.find("claimInvoiceAmntLocal").get("v.value")) || 0;
        const claimOtherCostsNotReimbursableLocal = parseFloat(component.find("claimOtherCostsNotReimbursableLocal").get("v.value")) || 0;
        const taxesLocal = parseFloat(component.find("claimTaxesLocal").get("v.value")) || 0;
        const reimbursableAmt = claimInvoiceAmntLocal - (claimOtherCostsNotReimbursableLocal + taxesLocal);

        if (reimbursableAmt <= 0 || isNaN(reimbursableAmt)) {
            this.showToast($A.get("$Label.c.Core_MDF_Claim_Reimbursable_Transaction_Amount"), "error");
            isAmountInvalid = true;
        }
        return isAmountInvalid;
    },

    showToast: function (message, variant) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": message,
            "type": variant
        });
        toastEvent.fire();
    },
    
    getClaimFieldsForAIPICProcess: function (component, event, helper) {
        var action = component.get("c.getClaimFieldsForAIPICProcess");
        action.setCallback(this, function (res) {
            var state = res.getState();
            if (state === "SUCCESS" && res.getReturnValue() != null) {
                component.set("v.claimFieldsForAIPIC", res.getReturnValue());
            }
            else {
                this.handleServerExceptions(component, res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    //To validate any edits on claim UI - AI PIC
    validateEditsOnClaim: function (component) {
        let hasClaimOrKPIFieldsUpdated = false;

        if (!$A.util.isUndefinedOrNull(component.get("v.claimFieldsForAIPIC")) && !$A.util.isEmpty(component.get("v.claimFieldsForAIPIC"))) {
            let claimKPIAndCampPurpFields = component.get("v.claimFieldsForAIPIC");//Claim Fields
            //KPI Fields
            if (component.get('v.isKpiSectionVisible') && !$A.util.isUndefinedOrNull(component.get("v.kpiDetailsOnLoad")) && !$A.util.isEmpty(component.get("v.kpiDetailsOnLoad"))) {
                let kpiFields = Object.keys(component.get('v.kpiDetailsOnLoad')); 
                claimKPIAndCampPurpFields.push(...kpiFields);
            }

            let finalClaimDetails = component.get("v.simpleNewClaim");//latest copy
            let claimDetailsOnLoad = component.get("v.claimDataOnLoad");//initial copy - load of claim UI

            hasClaimOrKPIFieldsUpdated = claimKPIAndCampPurpFields.some(clmFld => claimDetailsOnLoad[clmFld] !== finalClaimDetails[clmFld]);

        }

        //Audit Documents
        let hasAnyChangeOnAuditDoc = component.get("v.hasAnyChangeOnAuditDoc");

        if (hasAnyChangeOnAuditDoc || hasClaimOrKPIFieldsUpdated) {
            return true;
        } else {
            return false;
        }
    },
	validateSubClaimItems: function (component, event, helper){
        const subclaimItemCmp = component.find("subClaimLwc");
        const result = subclaimItemCmp.validate();
		return result;
    },
    formatToTwoDecimals: function (inputCmp) {
        if (!inputCmp) return;
        var value = inputCmp.get("v.value");
        if (value === null || value === '') {
            return;
        }
        var num = Number(value);
        if (!isNaN(num)) {
            inputCmp.set("v.value", num.toFixed(2));
        }
    },
})
})