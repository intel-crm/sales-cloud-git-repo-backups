({
    // Method is called on component Initalization
    doInit: function (component, event, helper) {
        helper.doInit(component, event, helper); 
    },

    // Method is called on click of cancel icon
    closeModal: function (component, event, helper) {
        helper.closeModel(component);
    },

    // This method fetches the Activity details
    fetchActivityDetails: function (component, event, helper) {
        helper.fetchActivityRecord(component, event, helper);
    },

    // This method sets the RequestId and escalationId on change of Activity LookUp
    updateLookUpId: function (component, event, helper) {
        helper.updateLookupField(component, event);
    },

    // This method clears the RequestId and escalationId on change of Activity LookUp
    clearLookUpId: function (component, event, helper) {
        console.log('Inside clear LookupId event');
        helper.clearLookupField(component, event);
    },
    //This function is used to close error toast message
    closeErrorToast: function (component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');
    },

    // Method is called on click of Finish and Save Button
    finish: function (component, event, helper) {
        helper.saveClaim(component);
    },

    //This function is used to moveNext/KPI/Document uploade section from duplicate OK button
    handleDuplicateClick: function (component, event, helper) {
        component.set("v.isOkDisabled", true);
        component.set("v.isDuplicate", false);
        //Navigate to POP and KPI tab, on click of duplicate OK button and click on POP Tab
        helper.navigateToPopAndKpiTab(component);
    },
    //This function is used to check Duplicate Claims after VAT Confirmation OK button
    handleVATModalClick: function (component, event, helper) { 
        //component.set("v.isOkForVATDisabled", true);
        component.set("v.showVATWarningModal", false);
        component.set("v.showVATWarning", false);
        component.set("v.spinner",true);
        helper.getDuplicateRecords(component);
    },

    //This function used to open popup, if duplicate claim exists
    openDuplicateModel: function (component, event, helper) {
        component.set('v.isDuplicate', true);
        component.set("v.isOkDisabled", false);
    },


    //This function is used to close duplicate model
    closeDuplicateModel: function (component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "False"  
        component.set("v.isDuplicate", false);
        component.set("v.isSaveDisabled", false);
        component.set("v.isOkDisabled", false);
        component.set("v.currentStep", "1");
    },

    //This function is used to close VAT Confirmation model
    closeVATModel: function (component, event, helper) {
        // for Hide/Close Model 
        component.set("v.showVATWarningModal", false);
        component.set("v.showVATWarning", false);
        component.set("v.isSaveDisabled", false);
        component.set("v.isOkForVATDisabled", false);
        component.set("v.currentStep", "1");
    },


    // This function is use to move to pervious Tab
    moveBack: function (component, event, helper) {
        helper.navigateToPreviousTab(component);
    },

    // This method fetches the escalation details
    fetchEscalationDetails: function (component, event, helper) {
        helper.fetchEscalationDetails(component);
    },

    //This function is use to set KPI flag to show KPI section
    setKpiFlag: function (component, event) {
        debugger;
        component.set('v.isKpiSectionVisible', event.getParam('isKpiApplicable'));        
        //Spinner stops when KPI tab opens
        component.set("v.spinner", false);
    },
    //This function is used to set SPIF visibility flag based on the child SPIF event
    setSpifFlag: function (component, event) {
        component.set('v.isSpifSectionVisible', event.getParam('isSPIFApplicable'));
    },
    // This function is use to move to Next/pervious Tab on click on Tab
    navigateOverTab: function (component, event, helper) {
        helper.navigationOverTab(component, event, helper);
    },

    // This function is use to move to next Tab on click of next button
    moveNext: function (component, event, helper) {
        helper.navigateToNextTab(component, event, helper);
    },

    // Show/ Hide Vat OptIn Picklist field based on the Legal Entity(bank) Selected
    showOrHideVatOptInOnLEChange: function (component, event, helper) {
        helper.showOrHideVatOptIn(component);
    },

    onValueSelection: function (component, event, helper) {
        component.set("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c", event.getParam('value'));
    },
    handle3rdPartyPOPEvent: function (component, event, helper) {
        helper.update3rdPartyDetails(component, event, helper);
    },
    handlePopSubmitEvent: function (component, event, helper) {
        helper.canSubmitClaimForPIC(component, event, helper);

    },
    handlePopCloseEvent: function (component, event, helper) {
        component.set("v.spinner", false);
        component.set("v.isClaimSubmittedForPIC", false);
        component.set("v.isConfirmPopupVisible", false);
    },
    //on click of yes - set the claim status to PIC Pending
    submitClaimForPIC: function (component, event, helper) {
        component.set("v.isClaimSubmittedForPIC", true);
        helper.isDocSubmissionPopupRequired(component, event, helper);
    },
    //on click of No from Confirmation popup(submit for PIC review), close the confirmation popup and save the changes done.
    closeSubmitForClaimPopup: function (component, event, helper) {
        component.set("v.isClaimSubmittedForPIC", false);
        component.set("v.showConfirmationPopupForPIC", false);
        helper.saveClaimMethods(component, event, helper);
    },

    //show or hide VAT Opt for 420
    showOrHideVATOptOnCountryChange: function (component, event, helper) {
        helper.onCountryChangeShowOrHideVATOption(component);
    },

    //Once file upload completed, call the method to do claimEzy Process to auto populate fields based on uploaded file.
    handleInvoiceUploadFinished:function (component, event, helper) {
        helper.handleFilesChange(component, event, helper);
    },

    handleChange:function (component, event, helper) {
        helper.handleChange(component, event, helper);
    },

    handleDateChange: function(component, event, helper) {
        helper.handleStartDateChange(component, event, helper);
    },
    handleCampaignPurposeChange: function(component, event, helper) {
        helper.handleCampaignPurposeChange(component, event, helper);
    },
    handleDateValidation: function (component, event, helper) {
        helper.validateClaimDates(component, "claimActEndDate");
    },
    handleAmountValidation: function (component, event, helper) {
        helper.handleAmountValidation(component);
    },
    getKPIDetailsOnLoad: function(component, event, helper) {
        component.set('v.kpiDetailsOnLoad', event.getParam('kpiFieldsAndValMap'));
    },
    handleDocumentTypeChange: function(component, event) {
        component.set("v.hasAnyChangeOnAuditDoc", !event.getParam("disableSubmitButton"));
    }
})