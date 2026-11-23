({
    doInit: function(component, event, helper) {
    try {
        component.set("v.showSpinner", true);
        // Initialize basic values
        helper.initializeBasicAttributes(component);
       
        component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c",true);
        //component.set("v.newPFR.Core_MDF_Proposal_Based_Ind__c", false);
        
        // Set mode based on recordId
        if(helper.isNotBlank(component.get("v.recordId")) || helper.isNotBlank(component.get("v.checkCloneRecordId"))) {
            if(component.get("v.checkCloneAttribute")) {
                component.set("v.mode", "clone");
                component.set("v.checkStatusAttribute", false);
                component.set("v.recordId", component.get("v.checkCloneRecordId"));
            }else {
                component.set("v.mode", "edit");
                //helper.onRegionChange(component, event, helper)
                var selectedRegion = component.get("v.newPFR.Core_MDF_Outcome_Region_nm__c");
                component.set("v.SelRegion", selectedRegion);

                // Fetch list filtered by region using allowed list from AllCountryOptions
                helper.fetchCountriesByRegionUsingAllOptions(component, selectedRegion);
            }
           
        } else {
            component.set("v.checkStatusAttribute", false);
           
        }

         helper.loadInitialData(component);
        //helper.SetAccMgrDisabledState(component);

        
    } catch(error) {
        component.set("v.showSpinner", false);
        helper.displaySuccessErrorMsg('Error initializing component: ' + error.message, 'Error', 'error','dismissible');
    }
},

focusAreaChange: function(component, event, helper){
    var selectedFocusArea = component.get("v.selectedFocusArea");
    
    if(helper.isNotBlank(selectedFocusArea)) {
        component.set("v.showSpinner", true);
        if(!component.get("v.initialFocusAreaLoaded")){
            helper.clearDependentFieldSelections(component);
        }else{
            component.set("v.initialFocusAreaLoaded", false);
        }
        
        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
            
        component.set("v.showSpinner", false);
        component.set("v.showDependentFields", true);
       
    }
},

//method called on change of Total Investment
calculateBudgetAmount: function(component, event, helper) {
    var budgetAmount = parseFloat(event.getSource().get("v.value")) || 0;
    var maxIntelContribution = parseFloat(component.get("v.maxIntelInvestment")) || 0;

    component.set("v.showErrorMsgForSpendingLimit", false);
    component.set("v.ErrorMsgForSpendingLimit", "");

    // Validate budget amount - must be at least $1 with no decimal points
    if (budgetAmount < 1) {
        component.set("v.showErrorMsgForSpendingLimit", true);
        component.set("v.ErrorMsgForSpendingLimit", $A.get("$Label.c.Core_MDF_TotalInvestment_grtthanzero_Error"));
    } else {
        // Clear error messages if validation passes
        component.set("v.showErrorMsgForSpendingLimit", false);
        component.set("v.ErrorMsgForSpendingLimit", "");
    }
    
    maxIntelContribution = component.get("v.maxIntelInvestment");
    
    if (maxIntelContribution!=null && budgetAmount >= maxIntelContribution && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", false);
    } 
    else if (maxIntelContribution > budgetAmount && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", true);
        component.set("v.ErrorMsgForMaxIntelInvest", $A.get("$Label.c.Core_MDF_MaxIntelInvest_Exceed_Error"));
    } 

    component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", budgetAmount);
    component.set("v.BudgetLocal", budgetAmount);

    // Recalculate reimbursement rate based on new budget amount
    helper.calculateReimbursementRate(component, budgetAmount, maxIntelContribution,false);
},

//method called on change of Maximum Intel Investment
calculateMaxIntelInvestment: function(component, event, helper) {
    var maxIntelContribution = parseFloat(event.getSource().get("v.value")) || 0;
    
    var budgetAmount = parseFloat(component.get("v.BudgetLocal")) 
                    || parseFloat(component.get("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c")) || 0;

    // Check for decimal places in the input value
    var decimalPlaces = (maxIntelContribution.toString().split('.')[1] || []).length;
    
    // Reset error message visibility and content
    component.set("v.showErrorMsgForMaxIntelInvest", false);
    component.set("v.ErrorMsgForMaxIntelInvest", "");
    
    // Validate minimum amount and decimal places - must be at least $1 with no decimal points
    if (maxIntelContribution < 1 || decimalPlaces > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", true);
        component.set("v.ErrorMsgForMaxIntelInvest", $A.get("$Label.c.Core_MDF_MaxIntelInvest_grtthanzero_Error"));
        
    } 
    // Validate that maximum Intel investment doesn't exceed total budget amount
    else if (maxIntelContribution > budgetAmount && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntelInvest", true);
        component.set("v.ErrorMsgForMaxIntelInvest", $A.get("$Label.c.Core_MDF_MaxIntelInvest_Exceed_Error"));
    } 
    else {
        // Clear error messages if all validations pass
        component.set("v.showErrorMsgForMaxIntelInvest", false);
        component.set("v.ErrorMsgForMaxIntelInvest", "");
    }

    component.set("v.maxIntelInvestment", maxIntelContribution);
    component.set("v.newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c", maxIntelContribution);

    // Recalculate reimbursement rate based on new maximum Intel investment
    helper.calculateReimbursementRate(component, budgetAmount, maxIntelContribution,true);
},


    hidePopup: function(component, event){
        var EventData = event.getParam("ButtonClick");
        var popupType = event.getParam("popupName");
        
        if(popupType == 'Event'){
            component.set("v.PopupButtonValue", EventData);
            component.set("v.PopupType", null);
        } else {
            component.set("v.ELCPopupButtonValue", EventData);
        }
        
        component.set("v.ShowEventPopup", false);
        
        if (EventData == false){
            component.set("v.PopupType", null);
            component.set("v.recordApplicableForActivityRules", true);
            component.set("v.goForSave", false);
        } else if(EventData == true){
            if(popupType == 'Event'){
                
                if(component.get("v.SelCategory") != $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
                    component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
                } else {
                    component.set("v.EventMessage", $A.get("$Label.c.core_mdf_terms_tactics_ELC_popup"));
                }
                component.set("v.AgreeButtonLabel", $A.get("$Label.c.Core_MDF_I_Understand"));            
                component.set("v.DisagreeButtonLabel", $A.get("$Label.c.Core_MDF_CancelOption"));
                component.set("v.PopupType", "ELC");
                component.set("v.ShowEventPopup", true);
            } else if(popupType == 'ELC'){
                component.set("v.ShowEventPopup", false);
            }     
        }
    },

    uploadfile: function(component, event){
        component.set("v.ContentDocumentIds", event.getParam("uploadFilesIds"));
        component.set("v.Uploadfinished", event.getParam("fileUploaded"));
        if (event.getParam("fileUploaded")){
            component.set("v.message", "");
            component.set("v.messageType", "");
            component.set("v.ChgndAttach", true);
        }    
    },

    closeModalClosedActivtiy: function (component, event, helper) {
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                recordId: component.get("v.selectedLookUpRecord.Id"),
                slideDevName: "detail"
            });
            homeEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        } else {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                scope: "PartnerFundRequest"
            });
            homeEvent.fire();
        }
    },

	// Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        if((component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit')){
        	var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                recordId: component.get("v.recordId"),
                slideDevName: "detail"
            });
            homeEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }else{
           var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    scope: "PartnerFundRequest"
                });
                homeEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
        }  
         $A.get('e.force:refreshView').fire(); 
    },    
    setCtryResetCPLed: function(component, event, helper) {
        var selctryLst = component.get("v.selectedCountryOptions");
        var ctryOpts = "";
        for(var i=0; i<selctryLst.length; i++ ){
            if(i!=selctryLst.length-1)
                ctryOpts+=selctryLst[i]+";";
            else
                ctryOpts+=selctryLst[i];            
        }  
        
        //component.set("v.SelMarketValue",ctryOpts);
        component.set("v.newPFR.Core_MDF_Country_nm__c",ctryOpts);
    },

    
   onTacticsChange:function(component, event, helper){
        var selectedTactics = event.getParam('value');
        var selectedTacticsOptions = "";
        if(!$A.util.isEmpty(selectedTactics) && selectedTactics != undefined){
                for(var i=0; i<selectedTactics.length; i++ ){
                    if(i!=selectedTactics.length-1)
                        selectedTacticsOptions+=selectedTactics[i]+";";
                    else 
                    selectedTacticsOptions+=selectedTactics[i];            
                }
        }
        if(!$A.util.isEmpty(selectedTacticsOptions) && selectedTacticsOptions != undefined){
           
            component.set("v.newPFR.Core_MDF_Tactics_nm__c", selectedTacticsOptions);
            var marketingTactics = $A.get("$Label.c.Core_MDF_Marketing_Act_Tactis").split(',');
            for(var index=0;index<marketingTactics.length;index++){
                if(selectedTacticsOptions.includes(marketingTactics[index])){
                    component.set("v.selActivityClassification",'Marketing');
                    break;
                }else{
                    component.set("v.selActivityClassification",'Sales');
                }
            
            }
        } 
        helper.checkSPIFActSecVisible(component);

        if(!$A.util.isEmpty(selectedTacticsOptions) && selectedTacticsOptions != undefined) {
            var lwcTacticMetricsComp = component.find("tacticMetrics");        
            var tacticMetricsValues;var isTacticMetricsModified;
            if (lwcTacticMetricsComp != null) {
                if(helper.isNotBlank(lwcTacticMetricsComp[0])){
                    tacticMetricsValues = lwcTacticMetricsComp[0].handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                }else{
                    tacticMetricsValues = lwcTacticMetricsComp.handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                }
               
            }
            
        }

       //helper.resetHelper(component);
       if( !$A.util.isEmpty(component.get("v.selectedTacticsOptions"))){
           if(helper.checkEventTactics(component)==false){
                component.set("v.renderPrintQuestion", false);
                component.set("v.renderGovtQuestion", false);
                component.set("v.renderTechExplorationQuestSection", false);
            }
         }
        
    },
	
   //Function called on change of Start Date
    createAdditionalfilter: function(component, event, helper) {
        helper.resetHelper(component);
        var checkStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
	
    if(checkStartDate) {
        var minDateString = $A.get("$Label.c.Core_MDF_IPA_AccountBased_StartDate");
        var minDate = new Date(minDateString);
        var selectedStartDate = new Date(checkStartDate);
        
        if(selectedStartDate < minDate) {
            // Show error using label
            helper.displaySuccessErrorMsg(
                $A.get("$Label.c.Core_MDF_Activity_Outcome_Startdate_Error"),
                "Error",
                "error",
                "sticky"
            );
            
            // Clear the invalid date
            component.set("v.newPFR.Core_MDF_Start_Date__c", null);
            
            return;
        }
    }
       
        
        // Only fetch budget if account is also selected
        var selectedAccount = component.get("v.selectedAccount");
        if(selectedAccount && selectedAccount.Id) {
            if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit'){
                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
		            helper.checkAvailAllocationAmt(component);
                    helper.fetchBudgetInfo(component);
                }
            }
        } 
        
        component.set("v.startDate", component.get("v.newPFR.Core_MDF_Start_Date__c"));
    },

   

    //Function called on change of End Date
    createNewAdditionalfilter: function(component, event, helper) {
        var checkEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        helper.resetHelper(component);
        
        // Only fetch budget if account is also selected
        var selectedAccount = component.get("v.selectedAccount");
        if(selectedAccount && selectedAccount.Id) {
            if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit'){
                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                    helper.fetchBudgetInfo(component);
                }
            }
        } 
        component.set("v.endDate", component.get("v.newPFR.Core_MDF_End_Date__c"));
    },

   saveBudget: function(component,event,helper){
        helper.checkAvailAllocationAmt(component);
        
    },

    customSave : function(component, event, helper) {
          
        var buttonClicked = event.getSource().getLocalId();
                
		if(buttonClicked == "SaveandNew"){
            component.set("v.isSaveandNew",true);
        }
        else{
            component.set("v.isSaveandNew",false);
        }
       
        //check for Event Popup and File upload
        //Component required validation
        var validData = component.find('NewForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var localmsg = "";
		var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")
          && (component.get("v.mode") != 'clone' && !component.get("v.externalper")) ){
            var Actreim=component.get("v.SelReimbursementRate");
            
            if(helper.isNotBlank(Actreim)){
             component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.SelReimbursementRate"));
            }
            
            
        }*/
        
		
        var isExternal = component.get("v.externalper");
        var isInternal = component.get("v.accmgrper");
        var budType = component.get("v.selBudgetType");
        var intelContri = component.get("v.maxIntelInvestment");
        var selectedCountry = component.get("v.selectedCountryOptions");
        var actStatus = component.get("v.CurrentStatus");
		
		if(component.get("v.showErrorMsgForMaxIntelInvest")){
            validData = false; 
            localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(component.get("v.showErrorMsgForSpendingLimit")){
            validData = false; 
            localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(!helper.isNotBlank(component.get("v.BudgetLocal"))){
            validData = false; 
            localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }

        if(component.get("v.isOutcomeSelectionInvalid")){
            validData = false;
            localmsg = $A.get("$Label.c.Core_MDF_Campaign_Outcome_Validation");
        }

        var budgetAmount = parseFloat(component.get("v.BudgetLocal")) || 0;
        var maxIntelInvestment = parseFloat(component.get("v.maxIntelInvestment")) || 0;
    
        // Final validation before save
        if (maxIntelInvestment > budgetAmount && budgetAmount > 0) {
        component.set("v.showErrorMsgForMaxIntel", true);
        component.set("v.ErrorMsgForMaxIntel", "Maximum Intel Investment should not exceed Total Investment amount.");
        validData = false;
        localmsg = "Maximum Intel Investment should not exceed Total Investment amount.";
        }
        	 
        //Initiative None selection error
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && helper.isNotBlank(component.get("v.newPFR.Core_MDF_Initiative_nm__c"))){
            var splitInitiative = [];
            splitInitiative = component.get("v.newPFR.Core_MDF_Initiative_nm__c").split(';');
            if(helper.isNotBlank(splitInitiative)){
                if(splitInitiative.includes('None') && splitInitiative.length>1){
                    localmsg = localmsg + $A.get("$Label.c.Core_MDF_Initiative_None_Selection_Error") + '\n';
                    validData = false;
                }
            }
        }
			 
        
		var todaysDate = helper.getTodayDateLocalTime();
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
        var pfrStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var budgetType = component.get("v.selBudgetType");
        var mode = component.get("v.mode");
        var diffDate = Date.parse(startDate) - Date.parse(todaysDate);
        var dateDifference = diffDate/(3600*24*1000) ;
        
        
       if( mode == '' || mode == 'clone'){
        /*if(component.get("v.externalper") && component.get("v.SelCategory") == "Event" 
           &&  dateDifference < $A.get("$Label.c.Core_MDF_60DaysMoreThan_50K") && component.get("v.IPAIntelContri") >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold")) {
            var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Event_60_Days");                                
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
            validData = false;
           }
        } */
		}
        
    	var recordTypeName = component.get("v.recordtypeDeveloperName");
        var proposalBasedCamp = component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c");
        
        //Throw error when Focus Area field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedFocusArea")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Focus_Area_Error_Msg_OutcomeBased") + '\n';
        }

        //Throw error when 
        
        
        //Throw error when Target Audience field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTargetAudienceOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_TargetAudienceError_OutcomeBased") + '\n';
        }
        
        //Throw error when Ecosystem Partner field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedEcosystemPartnerOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_EcosystemPartner_ReqError_OB") + '\n';
        }

        //Throw error when Initiative field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedInitiativeOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Initiative_Error_Msg_OutcomeBased") + '\n';
        }

        //Throw error when Brand field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedBrandOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_BrandError_OutcomeBased") + '\n';
        }

        //Throw error when Technology field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTechnologyOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Error_Message_for_Technology") + '\n';
        }

        //Throw error when Product Type field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.SelProductType")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_ProductTypeError_OutcomeBased") + '\n';
        }

        //Throw error when Outcome Metric field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedOutcomeMetricOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Error_Message_for_Outcomes") + '\n';
        }

        //Throw error when Tactic field is empty 
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTacticsOptions")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Activity_Tactics_Error_OutcomeBased") + '\n';
        }

        
	   
	   
	   
        
        //Removing the status value in clone condition
        if(component.get("v.SelectedStatus") != "" && component.get("v.checkCloneAttribute")){
            component.set("v.SelectedStatus","");
        }
        
		//Error for 'Budget Amount'
        var budgetAmount = component.find("BudgetAmount");
        var actSpendingAmount= component.get("v.BudgetLocal");
        
		//Error if not Acc mgr or Submitter 
        if(component.get("v.userWithoutAccess") && !((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
              && helper.isCurrentUsrIsApprover(component)) && !component.get("v.priceReviewersPer") && !component.get("v.ipaL2Approver")){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_CloneAccessError") + '\n';
            validData = false;
        }
        
        if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ){
            if ($A.util.isEmpty(component.get("v.newPFR.Title")) ||
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Activity_Description__c")) || 
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Start_Date__c")) ||
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_End_Date__c")) ){ 
                    	
                var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible"); // call common method to display error
                validData = false;
            }
        } 
		
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var oldstdate = component.get("v.oldsdate");
        var stdate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldstatus = component.get("v.oldstatus");
        var accmgrper = component.get("v.accmgrper");
        var edate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var oldedate = component.get("v.oldedate");
		
        if ((helper.isNotBlank(stdate) && helper.isNotBlank(oldstdate) && stdate>oldstdate) && accmgrper && oldstatus == 'In-Progress'  && !component.get("v.checkCloneAttribute"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_Date_Mod_Error") + '\n';
            validData = false;
        }
		
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.isPropBasedCampaign") == false
		&& (component.get("v.selAvailableBudget") == null  || component.get("v.selAvailableBudget") == undefined || component.get("v.selAvailableBudget") ==""))
		{
			validData = false;
			localmsg = localmsg + $A.get("$Label.c.Core_MDF_AvailableBudget_ErrMsg") + '\n';            
		}
        
		var activityAmount = component.get("v.maxIntelInvestment");
		//Condition to save SPIF/Incentive segment on save of activity
        if(helper.checkSPIFTactics(component)) {
            var lwcSegmentcomp = component.find("segmentComp");        
            var segmentValues;var isSegmentModified;var spifAmount;
            if (lwcSegmentcomp != null) {
                if(helper.isNotBlank(lwcSegmentcomp[0])){
                    segmentValues = lwcSegmentcomp[0].getSegmentValues();
                    isSegmentModified = lwcSegmentcomp[0].isSegmentModified();
                    spifAmount = lwcSegmentcomp[0].fetchSPIFAmount();
                }else{
                    segmentValues = lwcSegmentcomp.getSegmentValues();
                    isSegmentModified = lwcSegmentcomp.isSegmentModified();
                    spifAmount = lwcSegmentcomp.fetchSPIFAmount();
                }
                component.set("v.segmentString",'');
                if(segmentValues.length == 0) {
                   if(lwcSegmentcomp){
                       if(lwcSegmentcomp[0] != undefined){
		              lwcSegmentcomp[0].isFormValid();
                    }
                       else{
		              lwcSegmentcomp.isFormValid();
                   }
                   }
                   validData = false;
		           component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",false);
                   var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                   helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible");
                }
                else if(activityAmount < spifAmount){
                    validData = false;
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible");
                }
				else { 
                      if (helper.isNotBlank(segmentValues)) {                     
                          var segmentListStr = JSON.stringify(segmentValues);
                          component.set("v.segmentString", segmentListStr);
						  component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",true);
						  component.set("v.isSPIFSecModified",isSegmentModified);
                          if(component.get("v.isSPIFSecModified") && component.get("v.mode") == 'edit'){ 
                            component.set("v.newPFR.Core_MDF_SPIF_Modified_ind__c",true);
                          }
                          if(component.get("v.checkCloneAttribute")){
                              component.set("v.segmentString", segmentListStr);
                          }  
                      }
                }
            }
			if (component.get("v.isSPIFSecModified") == true && component.get("v.mode") == 'edit') {
			var todDate = helper.getTodayDateLocalTime();
			
			
			if(helper.isNotBlank(component.get("v.oldPFR.Core_MDF_Start_Date__c")) && component.get("v.oldPFR.Core_MDF_Start_Date__c") < todDate ){
				if( (helper.isNotBlank(component.get("v.newPFR.Core_MDF_Start_Date__c")) && component.get("v.newPFR.Core_MDF_Start_Date__c") < todDate ) ||
				   component.get("v.oldPFR.Core_MDF_Start_Date__c") != component.get("v.newPFR.Core_MDF_Start_Date__c")) {
					if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required')
					{ if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
						component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_RR"));
					}
					 
					 else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_RR"))){
						 component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_RR"));}
					}
					
					else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
						if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
							component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_Planned_Status"));
						}
						else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_Planned_Status")))
						{component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_Planned_Status"));}
					}
					else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress'){
						if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
							component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_In_Progress_Status"));
						}
						else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_In_Progress_Status")))
						{component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_In_Progress_Status"));}
					}
				}
			}
		}
           
		var segDisplayComp = component.find("displaySegment");        
		var spifAmount;
		if (segDisplayComp != null) {
		   spifAmount = segDisplayComp.fetchSpifAmount();
		   component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",true);
		   if(activityAmount < spifAmount){
				validData = false;
				var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
				helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible");
			}
		}
            
        }
        
        if(!$A.util.isEmpty(component.get("v.selectedTacticsOptions")) && helper.isNotBlank(component.get("v.selectedTacticsOptions"))) {
            var lwcTacticMetricsComp = component.find("tacticMetrics");        
            var tacticMetricsValues;var isTacticMetricsModified;var isFormValid;
            if (lwcTacticMetricsComp != null) {
                if(helper.isNotBlank(lwcTacticMetricsComp[0])){
                    tacticMetricsValues = lwcTacticMetricsComp[0].getTacticMetricsValues();
                    isTacticMetricsModified = lwcTacticMetricsComp[0].isTacticMetricsModified();
                    isFormValid = lwcTacticMetricsComp[0].isFormValid();

                }else{
                    tacticMetricsValues = lwcTacticMetricsComp.getTacticMetricsValues();
                    isTacticMetricsModified = lwcTacticMetricsComp.isTacticMetricsModified();
                    isFormValid = lwcTacticMetricsComp.isFormValid();
                }
                if(!isFormValid){
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error","dismissible"); 
                    validData = false;
                }
               component.set("v.tacticMetricsValues",'');
                if(tacticMetricsValues.length > 0){ 
                      if (helper.isNotBlank(tacticMetricsValues)) {                     
                          var tacticMetricsVal = JSON.parse(JSON.stringify(tacticMetricsValues));
                          component.set("v.tacticMetricsValues", tacticMetricsVal);
			              //component.set("v.isSPIFSecModified",isTacticMetricsModified);
                          if(isTacticMetricsModified && component.get("v.mode") == 'edit'){ 
                            component.set("v.newPFR.Core_MDF_Metrics_Modified_ind__c",true);
                          }
                          if(component.get("v.checkCloneAttribute")){
                              component.set("v.tacticMetricsValues", tacticMetricsVal);
                          }  
                      }
                }
            }
            
        }
        else{
            component.set("v.tacticMetricsValues", null);
        }
        if ( !$A.util.isEmpty(component.get("v.selectedOutcomeMetricOptions")) && helper.isNotBlank(component.get("v.selectedOutcomeMetricOptions"))) {
            var lwcOutcomeActivityComp = component.find("activityOutcomeCmp");
            var outcomeActivityValues;
            var isFormValid;
            
            var lwcChild = lwcOutcomeActivityComp;
            if (helper.isNotBlank(lwcOutcomeActivityComp) && lwcOutcomeActivityComp.length > 0) {
                lwcChild = lwcOutcomeActivityComp[0];
            }
            if (lwcChild != null) {
                isFormValid = lwcChild.validate();
                if (!isFormValid) {
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                    helper.displaySuccessErrorMsg(alertMsg, "Error!", "error","dismissible");
                    validData = false;
                    return;
                }
                outcomeActivityValues = lwcChild.getAllActivityOutcomesDetails();
                component.set("v.outcomeActivityValues", "");
                
                if (outcomeActivityValues && outcomeActivityValues.length > 0) {
                    var outcomeActivityVal = JSON.parse(JSON.stringify(outcomeActivityValues));
                    component.set("v.outcomeActivityValues", outcomeActivityVal);
                }
            }
            } else {
                component.set("v.outcomeActivityValues", null);
            }
        
		
        var actStatus = component.get("v.CurrentStatus");
        var existingOwner = component.get("v.existingIntelOwner");
        var mode = component.get("v.mode");
        
        // If all the Entered Data are valid in terms of text or Number
        if(validData){
            
            if(helper.isNotBlank(component.get("v.selectedAccount").Id)){
                component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedAccount").Id);
            }		
            
            //helper.calculateReimbursementRate(component, budgetAmount, maxIntelInvestment);
            
			component.set("v.newPFR.Core_MDF_Focus_Area_nm__c",component.get("v.selectedFocusArea"));
			component.set("v.newPFR.Core_MDF_Activity_Classification_nm__c",component.get("v.selActivityClassification"));
			component.set("v.newPFR.Core_MDF_Tactics_nm__c",component.get("v.selectedTacticsOptions"));
            component.set("v.newPFR.Core_MDF_Outcomes_nm__c",component.get("v.selectedOutcomeMetricOptions"));
			component.set("v.newPFR.Core_MDF_ActivityCategory__c",$A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
            component.set("v.newPFR.Core_MDF_Activity_Types__c",$A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
			component.set("v.newPFR.Core_MDF_Proposal_Based_Ind__c",false);
            component.set("v.newPFR.Core_MDF_Is_Outcome_Based_Ind__c",true);
            component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
            component.set("v.newPFR.Core_MDF_Priority_nm__c",component.get("v.SelPriority"));
			component.set("v.newPFR.Core_MDF_Priority_2_nm__c",component.get("v.SelPriority2"));
            //component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c",component.get("v.selectedEcosystemPartnerOptions"));
            //component.set("v.newPFR.Core_MDF_Technology_txt__c",component.get("v.selectedTechnologyOptions"));
            component.set("v.newPFR.RecordTypeId",component.get("v.recordtype"));
			component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.CurrentStatus"));
			component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",$A.get("$Label.c.Core_MDF_PFR_Output_Currency"));
            component.set("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c",component.get("v.maxIntelInvestment"));
			component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
			//component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", component.get("v.SelReimbursementRate"));
			//component.set("v.newPFR.Core_MDF_Reimbursement_Rate_pct__c", component.get("v.SelReimbursementRate"));
			//component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selBudgetType"));		
            //component.set("v.newPFR.Core_MDF_Outcomes_nm__c", component.get("v.selectedOutcomeMetricOptions"));	
            //component.set("v.newPFR.Core_MDF_Initiative_nm__c", component.get("v.selectedInitiativeOptions"));
            component.set("v.newPFR.RequestedAmount", component.get("v.maxIntelInvestment"));
            component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", component.get("v.SelRegion"));
            component.set("v.newPFR.Core_MDF_Country_nm__c", component.get("v.selectedCountryOptions"));
            component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
                    	
            if(component.get("v.SelRegion")) {
            component.set("v.newPFR.Core_MDF_Outcome_Region_nm__c", component.get("v.SelRegion"));
            }

            // Making Id null in order to save New Record from clone
            if(component.get("v.checkCloneAttribute")){
			 
              component.set("v.newPFR.Id", null);
              component.set("v.recordId", null);
              component.set("v.newPFR.CreatedDate", null);
              component.set("v.newPFR.Core_MDF_Activity_Closure_Type__c", '');
              component.set("v.newPFR.BudgetId", null);  
              //component.set("v.newPFR.AllocationId", null);   

            }
            
            if(component.get("v.selAvailableBudget")) {
            component.set("v.newPFR.BudgetId", component.get("v.selAvailableBudget"));
            }
            
            if(component.get("v.SelectedStatus") != "" ){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.SelectedStatus"));
            }  
            
        if(((recordTypeDeveloperName == 'Core_MDF_Intel_Partner_Alliance')
                   && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false) && component.get("v.ipaAcctMgr")){
              
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",1);                                     
            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');
        }
            
		if(component.get("v.SelectedStatus") != undefined && component.get("v.recordId") != null && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")&&(component.get("v.isPropBasedCampaign") == false))){
            if (!component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                    !$A.get("$Label.c.Core_MDF_PFR_Status_Closed").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                helper.setIPAAccountBasedActivityStatus(component);
            }  
        }
            
		var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
		var removeFieldNotReqVal = editedFieldRequiresApproval.toString().replace(',Core_MDF_Require_Additional_Review_ind__c', '');
		var convertArrayFieldSet = removeFieldNotReqVal.split(',');  
		if((helper.fieldEligibleForApprovalModified(component, convertArrayFieldSet)
			  || component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") == true) && component.get("v.mode") == 'edit' &&
			 component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_CCP_Planned_Status") &&
			 (component.get("v.ipaAcctMgr") || component.get("v.ipaL2Approver")) &&
			 ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) 
			   && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)) {
			 component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
		}
		//Outcome Based changes - to show govt question, Event, ELC Popup when selected tactics is Event
        if(!$A.util.isEmpty(component.get("v.selectedTacticsOptions")) && component.get("v.selectedTacticsOptions").includes('Event') && component.get("v.goForSave")==false){
            
            helper.isTacticsGovtEventQuesSecVisible(component);
	        helper.isTacticsEventPopUpVisible(component);
            helper.isTacticsELCPopUpVisible(component);
        }else{
            	component.set("v.goForSave",true);
                helper.saveHelperMethod(component, component.get("v.newPFR"));
            }
		//ATF Flag
        var todDate = helper.getTodayDateLocalTime();
        if(component.get("v.mode") == 'edit' && (helper.isNotBlank(component.get("v.oldPFR.Core_MDF_Start_Date__c")) && component.get("v.oldPFR.Core_MDF_Start_Date__c") < todDate) && component.get("v.Uploadfinished")){
        if( (component.get("v.newPFR.Core_MDF_Start_Date__c") < todDate ) ||
              component.get("v.oldPFR.Core_MDF_Start_Date__c") != component.get("v.newPFR.Core_MDF_Start_Date__c")) {
			   if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required')
			   { if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
			   component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_RR"));
			   }
           
                else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_RR"))){
                    component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_RR"));}
					}
                
				else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
				if(component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") == null){
			   component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",$A.get("$Label.c.Core_MDF_ATF_Planned_Status"));
			   }
			 else if(!component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c").includes($A.get("$Label.c.Core_MDF_ATF_Planned_Status")))
                {component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",component.get("v.oldPFR.Core_MDF_ATF_Flag_nm__c") +';' + $A.get("$Label.c.Core_MDF_ATF_Planned_Status"));}
				}
           }
            }           
        } 
        else
        {
            if (localmsg != "")
            {
               
                
               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": localmsg,
                    "type" : "error"
                    
                });
                toastEvent.fire();
                return;
            }
        }
    },

    // Add these methods to your existing controller

filterCountry: function (component, event, helper) {
    // Get the current country options (might be filtered by region)
    // If filter is completely empty (backspaced to nothing), reset and return
    var countryName = component.get("v.AllCountryOptions");
    if (!countryName || countryName.length === 0) {
        return;
    }
    var filterCountrySearch = new Array();
    var filterCountryNonSearch = new Array();
    
    if (helper.isNotBlank(component.get("v.countryFilter"))) {
        var countrySearch = component.get("v.countryFilter").toUpperCase();
        
        for (var index = 0; index < countryName.length; index++) {
            if (countryName[index].label.toUpperCase().includes(countrySearch)) {
                filterCountrySearch.push({
                    label: countryName[index].label,
                    value: countryName[index].value
                });
            } else {
                filterCountryNonSearch.push({
                    label: countryName[index].label,
                    value: countryName[index].value
                });
            }
        }
        component.set("v.AllCountryOptions", filterCountrySearch.concat(filterCountryNonSearch));
    } else {
        // Reset based on current region selection
        /*var selectedRegion = component.get("v.SelRegion");
        if(selectedRegion) {
            helper.filterCountriesByRegion(component, selectedRegion);
        } else {
            helper.setHardcodedCountryOptions(component);
        }*/
    }
        
},



onBrandChange: function (component, event, helper) {
    var selectedBrand = event.getParam('value');
    var selectedBrandOptions = "";
    
    if(!$A.util.isEmpty(selectedBrand) && selectedBrand != undefined){
        for(var i=0; i<selectedBrand.length; i++ ){
            if(i!=selectedBrand.length-1)
                selectedBrandOptions+=selectedBrand[i]+";";
            else 
                selectedBrandOptions+=selectedBrand[i];            
        }
    }
    
    if(!$A.util.isEmpty(selectedBrandOptions) && selectedBrandOptions != undefined){
        component.set("v.newPFR.Core_MDF_Brand_nm__c", selectedBrandOptions);
    }
    
    // Reset helper for dependent fields
    helper.resetHelper(component);
},

onTargetAudienceChange: function (component, event, helper) {
    var selectedTargetAudience = event.getParam('value');
    var selectedTargetAudienceOptions = "";
    
    if(!$A.util.isEmpty(selectedTargetAudience) && selectedTargetAudience != undefined){
        for(var i=0; i<selectedTargetAudience.length; i++ ){
            if(i!=selectedTargetAudience.length-1)
                selectedTargetAudienceOptions+=selectedTargetAudience[i]+";";
            else 
                selectedTargetAudienceOptions+=selectedTargetAudience[i];            
        }
    }
    
    if(!$A.util.isEmpty(selectedTargetAudienceOptions) && selectedTargetAudienceOptions != undefined){
        component.set("v.newPFR.Core_MDF_TargetAudience_nm__c", selectedTargetAudienceOptions);
    }
},

onInitiativesChange: function (component, event, helper) {
    var selectedInitiatives = event.getParam('value');
    var selectedInitiativeOptions = "";
    
    if(!$A.util.isEmpty(selectedInitiatives) && selectedInitiatives != undefined){
        for(var i=0; i<selectedInitiatives.length; i++ ){
            if(i!=selectedInitiatives.length-1)
                selectedInitiativeOptions+=selectedInitiatives[i]+";";
            else
                selectedInitiativeOptions+=selectedInitiatives[i];            
        }
    }
    
    if(!$A.util.isEmpty(selectedInitiativeOptions) && selectedInitiativeOptions != undefined){
        component.set("v.newPFR.Core_MDF_Initiative_nm__c", selectedInitiativeOptions);
    }
},

onEcosystemPartnerChange: function (component, event, helper) {
    var selectedEcosystemPartner = event.getParam('value');
    var selectedEcosystemPartnerOptions = "";
    
    if(!$A.util.isEmpty(selectedEcosystemPartner) && selectedEcosystemPartner != undefined){
        for(var i=0; i<selectedEcosystemPartner.length; i++ ){
            if(i!=selectedEcosystemPartner.length-1)
                selectedEcosystemPartnerOptions+=selectedEcosystemPartner[i]+";";
            else
                selectedEcosystemPartnerOptions+=selectedEcosystemPartner[i]; 
        }
    }
    
    if(selectedEcosystemPartnerOptions != undefined && selectedEcosystemPartnerOptions != null){              
        component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c", selectedEcosystemPartnerOptions);
    }
},

onTechnologyChange: function (component, event, helper) {
    var selectedTechnology = event.getParam('value');
    var selectedTechnologyOptions = "";
    
    if(!$A.util.isEmpty(selectedTechnology) && selectedTechnology != undefined){
        for(var i=0; i<selectedTechnology.length; i++ ){
            if(i!=selectedTechnology.length-1)
                selectedTechnologyOptions+=selectedTechnology[i]+";";
            else
                selectedTechnologyOptions+=selectedTechnology[i]; 
        }
    }
   
    if(!$A.util.isEmpty(selectedTechnologyOptions) && selectedTechnologyOptions != undefined){              
        component.set("v.newPFR.Core_MDF_Technology_txt__c", selectedTechnologyOptions);
        //var techie = component.get("v.selectedTechnologyOptions");
        
    }
},     

onOutcomeMetricOptionsChange: function (component, event, helper) {
    var selectedOutcomeMetric = event.getParam('value');
    var prev = component.get("v.prevSelectedOutcomes");

    if(selectedOutcomeMetric.length === 0 && (!prev || prev.length === 0)) {
        component.set("v.prevSelectedOutcomes", []);
        component.set("v.selectedOutcomes", []);
        return;
    }
      
    if(selectedOutcomeMetric.length === 1) {

        var outcomeString = selectedOutcomeMetric[0];
        component.set("v.newPFR.Core_MDF_Outcomes_nm__c", outcomeString);
        component.set("v.showActivityPurpose", true);
        component.set("v.prevSelectedOutcomes", selectedOutcomeMetric.slice(0));
        component.set("v.selectedOutcomes", selectedOutcomeMetric);
        component.set("v.isOutcomeSelectionInvalid", false);
        
    } else if(selectedOutcomeMetric.length === 2 && prev.length === 1) {
        var newSelection = selectedOutcomeMetric.find(item => !prev.includes(item));
        if(newSelection) {
            component.set("v.newPFR.Core_MDF_Outcomes_nm__c", newSelection);
            component.set("v.showActivityPurpose", true);
            component.set("v.prevSelectedOutcomes", [newSelection]);
            component.set("v.selectedOutcomes", [newSelection]);
            component.set("v.isOutcomeSelectionInvalid", false);
            component.set("v.selectedOutcomeMetricOptions", [newSelection]);
        }
        
    } else {
        var alertMsg = $A.get("$Label.c.Core_MDF_Campaign_Outcome_Validation");
        helper.displaySuccessErrorMsg(alertMsg, "Error!", "error","dismissible");
        component.set("v.selectedOutcomeMetricOptions", prev);
    }
},

//Method to handle Priority change
handlePriority1Change: function(component, event, helper) {
    var selectedValue = event.getParam("value");
    component.set("v.SelPriority", selectedValue);
    helper.validatePriorityFieldsImmediate(component);
},

// Method to handle Priority 2 change  
handlePriority2Change: function(component, event, helper) {
    var selectedValue = event.getParam("value");
    component.set("v.SelPriority2", selectedValue);
    helper.validatePriorityFieldsImmediate(component);
},

// Function called on the change of Account
resetAccountattributes : function(component, event, helper){
    if(component.get("v.selectedAccount") == null || component.get("v.selectedAccount").Id == null){
        component.set("v.newPFR.ChannelPartnerId",null);
    } 
    else{
        component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedAccount").Id );
    }
    
    // Only fetch budget if account is also selected
    var selectedAccount = component.get("v.selectedAccount");
    if(selectedAccount && selectedAccount.Id && component.get("v.selAvailableBudget")) {
        if (component.get("v.mode") == "" || component.get("v.mode") == 'clone' || component.get("v.mode") == 'edit'){
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                helper.checkAvailAllocationAmt(component);
                helper.fetchBudgetInfo(component);
            }
        }
    }
    
    //Populate BudgetType field based on ABA
    if(selectedAccount && selectedAccount.Id){
        helper.fetchBudgetTypesBasedOnBenefits(component);
    }else{//Reset BudgetType if the account is Removed
        var budgetTypeOptionList = [];
        budgetTypeOptionList.push({label: "---None---", value: "" });
        component.set("v.budgetTypeVal", budgetTypeOptionList);
        component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", '');
        component.set("v.selBudgetType", '');
        component.set("v.showBudgetTypeError", false);
    }
    
    },

    onRegionChange: function(component, event, helper) {
        var selectedRegion = null;
        if (event && event.getParam) 
            {selectedRegion = event.getParam('value');
            }
        if (!selectedRegion) {selectedRegion = component.get("v.SelRegion");}

        component.set("v.SelRegion", selectedRegion);

        // Fetch list filtered by region using allowed list from AllCountryOptions
        helper.fetchCountriesByRegionUsingAllOptions(component, selectedRegion);
    },

   onCountryChange: function(component, event, helper) {
    
        var selectedCountries = event.getParam('value');
        var selectedCountryOptions = "";

        if (!$A.util.isEmpty(selectedCountries) && selectedCountries != undefined) {
            for (var i = 0; i < selectedCountries.length; i++) {
                if (i != selectedCountries.length - 1)
                    selectedCountryOptions += selectedCountries[i] + ";";
                else
                    selectedCountryOptions += selectedCountries[i];
            }
        }

        if (!$A.util.isEmpty(selectedCountryOptions) && selectedCountryOptions != undefined) {
            component.set("v.newPFR.Core_MDF_Country_nm__c", selectedCountryOptions);
        }


},

    onBudgetTypeChange: function(component, event, helper) {
        
        var selectedBudgetType = event.getParam('value');
        //var selectedBudgetType = event.getSource().get("v.value");
        if(selectedBudgetType == '' ||selectedBudgetType == 'Account Plan'){
            component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", selectedBudgetType);
        }else{
            component.set("v.selBudgetType", "");
             helper.displaySuccessErrorMsg(
                $A.get("$Label.c.Core_MDF_Activity_Outcome_ProposalBT_Selection_Error"),
                "Error",
                "error",
                "sticky"
            );
        }
    }

})