({   
    // Function Called On Change of the date fields on the Form to construct campaign lookup filter
    createAdditionalfilter : function(component, event, helper) {
        //Variable Reimbursement Rate changes
        helper.resetHelper(component);
        var checkStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        if(component.get("v.newPFR.Core_MDF_End_Date__c")== null){
        component.set("v.newPFR.Core_MDF_End_Date__c",checkStartDate);
       }
        var newEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
             if (component.get("v.isActivityCreationOnCampaign") == true || component.get("v.mode")== "" || component.get("v.mode")=='clone' ||component.get("v.mode")=='edit'){
            //helper.fetchCampBudgetInfo(component, event, helper, true);
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && 
              component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false)
            {
                helper.checkAvailAllocationAmt(component);
                helper.fetchBudgetInfo(component);//on change of start date
            }
                 
             }
        helper.constructadditionalfilter(component, checkStartDate, newEndDate, recordTypeDeveloperName, null);
	// OPAL Past Dated Activity Submission process
        helper.onStartDateChange(component);
         if( component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
          && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
            
             helper.checkAvailAllocationAmt(component);
        }
        component.set("v.startDate", component.get("v.newPFR.Core_MDF_Start_Date__c"));
        
    } ,
    //Test code start
        
    //Function called for filtering country values---Rishabh
   /* filterCountry: function (component, event, helper) {
        var countryName = component.get("v.CountryPicklistValues");
        var filterCountrySearch = new Array();
        var filterCountryNonSearch = new Array();
        if ( helper.isNotBlank(component.get("v.countryFilter"))) {
            var countrySearch = component.get("v.countryFilter").toUpperCase();
        }
        for (var index = 0; index < countryName.length; index++) {
            if (countryName[index].value.toUpperCase().includes(countrySearch)) {
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
    },*/
    //---Rishabh
      /*filterBrand: function (component, event, helper) {
        var brandName = component.get("v.BrandPicklistValues");
        var filterBrandSearch = new Array();
        var filterBrandNonSearch = new Array();
        if ( helper.isNotBlank(component.get("v.brandFilter"))) {
            var brandSearch = component.get("v.brandFilter").toUpperCase();
        }
     
        for (var index = 0; index < brandName.length; index++) {
            if (brandName[index].value.toUpperCase().includes(brandSearch)) {
                filterBrandSearch.push({
                    label: brandName[index].label,
                    value: brandName[index].value
                });
            } else {
                filterBrandNonSearch.push({
                    label: brandName[index].label,
                    value: brandName[index].value
                });
            }
        }
        component.set("v.AllBrandOptions", filterBrandSearch.concat(filterBrandNonSearch));
    },*/
    //--Rishabh
    /*filterApprover: function (component, event, helper) {
        var approverName = component.get("v.ApproverPicklistValues");
        var filterApproverSearch = new Array();
        var filterApproverNonSearch = new Array();
        if ( helper.isNotBlank(component.get("v.approverFilter"))) {
            var approverSearch = component.get("v.approverFilter").toUpperCase();
        }
        for (var index = 0; index < approverName.length; index++) {
            if (approverName[index].label.toUpperCase().includes(approverSearch)) {
                filterApproverSearch.push({
                    label: approverName[index].label,
                    value: approverName[index].value
                });
            } else {
                filterApproverNonSearch.push({
                    label: approverName[index].label,
                    value: approverName[index].value
                });
            }
        }
        component.set("v.AllApproverOptions", filterApproverSearch);
        
    },*/
    
    //---Rishabh
    /*filterExtActSubmitter: function (component, event, helper) {
        var ExtActSubmitterName = component.get("v.ExtActSubmitterPicklistValues");
        var filterExtActSubmitterSearch = new Array();
        var filterExtActSubmitterNonSearch = new Array();
        if ( helper.isNotBlank(component.get("v.extActSubmitterFilter"))) {
            var extActSubmitterSearch = component.get("v.extActSubmitterFilter").toUpperCase();
        }
        for (var index = 0; index < ExtActSubmitterName.length; index++) {
            if (ExtActSubmitterName[index].label.toUpperCase().includes(extActSubmitterSearch)) {
                filterExtActSubmitterSearch.push({
                    label: ExtActSubmitterName[index].label,
                    value: ExtActSubmitterName[index].value
                });
            } else {
                filterExtActSubmitterNonSearch.push({
                    label: ExtActSubmitterName[index].label,
                    value: ExtActSubmitterName[index].value
                });
            }
        }
        component.set("v.AllExtActSubmitterOptions", filterExtActSubmitterSearch);
        
    },*/
    //Function called on change of End Date to contruct campaign lookup filter
    createNewAdditionalfilter : function(component, event, helper) {
        var newcheckStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var newcheckEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var newrecordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
         if (component.get("v.isActivityCreationOnCampaign") == true || component.get("v.mode")== "" || component.get("v.mode")=='clone' || component.get("v.mode")=='edit'){
            
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && 
              component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false)
            {
                
            }
        }
        helper.constructadditionalfilter(component, newcheckStartDate, newcheckEndDate, newrecordTypeDeveloperName, null);
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
          && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
           
        }
        component.set("v.endDate", component.get("v.newPFR.Core_MDF_End_Date__c"));
    },
    
    
    
    //Function Called On Change of the Budget Amount Local Field to Calculate USD
    calculateBudgetAmount : function(component, event, helper){
        var selCategory = component.get("v.SelCategory");
        var selActiType = component.get("v.SelActivityType");
        var setBudgType = component.get("v.selBudgetType");
        var actSpendingAmount= component.get("v.BudgetLocal");
        var budgetAmount = component.find("BudgetAmount");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var actSpendingAmtDecimalVal;
        component.set("v.ErrorMsgForSpendingLimit", "");        
       if (actSpendingAmount<=0 ||actSpendingAmount=='' || actSpendingAmount==null  ){
            if(recordTypeDeveloperName== $A.get("$Label.c.Core_MDF_IPA_RecordType") ) {
                                                 
                component.set("v.IPAIntelContri", ' ');
            }
        }else{ 
            if(recordTypeDeveloperName== $A.get("$Label.c.Core_MDF_IPA_RecordType")  ){
                if(budgetAmount.length == 1){
                    budgetAmount[0].setCustomValidity("");
                    budgetAmount[0].reportValidity();
                }else{
                    budgetAmount.setCustomValidity("");
                    budgetAmount.reportValidity(); 
                }
            }           
        }
        component.set("v.chkBdgtCpExcd",false);  
        component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
        component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
        if(actSpendingAmount != null && actSpendingAmount.toString().includes('.')){
            var getDecimalVal = actSpendingAmount.toString().indexOf(".");
            actSpendingAmtDecimalVal =  actSpendingAmount.toString().substring(getDecimalVal + 1);
            if (actSpendingAmtDecimalVal != null && actSpendingAmtDecimalVal >= 0 ){
                var alertMsg = $A.get("$Label.c.Core_MDF_Budget_Amount_Error");
                component.set("v.showErrorMsgForSpendingLimit", true);
                component.set("v.ErrorMsgForSpendingLimit", alertMsg);
                helper.enableDisableButtons(component, true, true);
            } else {
                helper.enableDisableButtons(component, false, false);
            }
        } else if(actSpendingAmount == null || actSpendingAmount == '' || actSpendingAmount < 0){
            helper.enableDisableButtons(component, true, true);
        } else {
        component.set("v.isSaveDisable", false);
        if(!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.ipaApproverPer") || (component.get("v.CurrentStatus") == 'Planned' && (component.get("v.accmgrper") || component.get("v.externalper")) ) )  )) {
            if(!component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper") &&
               !component.get("v.auditorper")){
		component.set("v.isSaveandNewDisable", false);
	    }
        }
        }
        component.set("v.message", "");
        component.set("v.messageType", "");
        if (component.get("v.checkCloneAttribute")) {
            component.set("v.newPFR.CreatedDate", null);
        }
        // Calling function for budget check
        if(!$A.util.isEmpty(component.get("v.BudgetLocal")) && !$A.util.isEmpty(component.get("v.budgetCurrency")) 
            && (actSpendingAmtDecimalVal == null || actSpendingAmtDecimalVal == '' || actSpendingAmtDecimalVal == 'undefined')){
            helper.budgetAmountcalculatefunction(component);
        }
        component.set("v.intelContribution",null);
        if((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && selCategory == 'Event' && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) {
                component.set("v.newPFR.Core_MDF_Competitive_Elements__c",null);
            }
        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",null);
        helper.resetHelper(component);
        if(!$A.util.isEmpty(actSpendingAmount) && actSpendingAmtDecimalVal == null){
        }
	
    },
    // Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) &&(component.get("v.isPropBasedCampaign") == true)){
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                recordId: component.get("v.selectedLookUpRecord.Id"),
                slideDevName: "detail"
            });
            homeEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }
        else if (component.get("v.checkCloneAttribute")) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                recordId: component.get("v.checkCloneRecordId"),
                slideDevName: "detail"
            });
            navEvt.fire();
            $A.get("e.force:closeQuickAction").fire();
        }
            else {
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                homeEvent.setParams({
                    scope: "PartnerFundRequest"
                });
                homeEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
         $A.get('e.force:refreshView').fire(); 
    },
   //[IPA MDF] - Campaign - Clone a Proposal - Activity Section fire event on click of save and handle in aura campaign component
    customSaveIPA: function (component, event, helper) {
       
        var actRec = component.get("v.newPFR");
       
         var cmpEvent = component.getEvent("ipaActRecClone"); 
        //Set event attribute value
        cmpEvent.setParams({"detail" : actRec}); 
        cmpEvent.fire(); 
    },
    // Function called on click of Cancel or "X" on the layout
    closeModalClosedActivtiy: function (component, event, helper) {
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                recordId: component.get("v.selectedLookUpRecord.Id"),
                slideDevName: "detail"
            });
            homeEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
        }
        else{
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                scope: "PartnerFundRequest"
            });
            homeEvent.fire();
        }
    },   
    // Function called on click of save button (We set the selected values to the associated field)
    // Check for the validity of the fields before save
    // Also controls the popup on form
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
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")
          && (component.get("v.mode") != 'clone' && !component.get("v.externalper") && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") != true) ){
            var Actreim=component.get("v.ActReimbursementRt");
            
            if(helper.isNotBlank(Actreim)){
             component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",Actreim);
            }
            
            
        }
        // var pfrstatus = component.get("v.CurrentStatus");
        //Add new countries but not remove any
		//Validation Rules while acitvity is created/edited/cancelled/closed
        if((component.get("v.isOpalActivity")) && !component.get("v.checkCloneAttribute") &&
           component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")
          ){
            if(helper.isNotBlank(component.get("v.SelMarketValue"))){
                var existingCountries = [];
                if(helper.isNotBlank(component.get("v.oldPFR.Core_MDF_Country_nm__c"))) {
                 	existingCountries = component.get("v.oldPFR.Core_MDF_Country_nm__c").split(';');   
                }
                var selectedCountries = [];
                selectedCountries = component.get("v.SelMarketValue").split(';');
                for(var i = 0; i < existingCountries.length; i++) {
                    if (!selectedCountries.includes(existingCountries[i])) {
                        localmsg = localmsg + $A.get("$Label.c.Core_MDF_Cannot_Remove_Country");
                        validData = false;
                        break;
                    }
                }
            }
            else
            {
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Cannot_Remove_Country");
                validData = false;
            }
        }
        helper.checkIsApproverActive(component);
        helper.checkIsSubmitterActive(component);
        
        var isExternal = component.get("v.externalper");
        var isInternal = component.get("v.accmgrper");
        var selAppLst = component.get("v.selectedApproverOptions");
        var selSubLst = component.get("v.selectedExtActSubmitterOptions");
        var allAppLst = component.get("v.AllApproverOptions");
        var allSubLst = component.get("v.AllExtActSubmitterOptions");
        var budType = component.get("v.selBudgetType");
        var intelContri = component.get("v.intelContribution");
        var selectedCountry = component.get("v.selectedCountryOptions");
        var actStatus = component.get("v.CurrentStatus");
	component.set("v.existingMemberActivityOwnerId",selSubLst);
        
        if(component.get("v.actReimbRateError")){
             validData = false; 
              localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(!helper.isNotBlank(component.get("v.SelReimbursementRate"))
            && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") 
                 || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))){
             validData = false; 
              localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(!helper.isNotBlank(component.get("v.BudgetLocal"))
            && (!component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") 
                 || !component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))){
             validData = false; 
             localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
        if(component.get("v.showNegativeInputError")){
            validData = false; 
             localmsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        }
       
        if(actStatus == 'Planned'){
        var selAppNull = false;
        for(var i=0;i<=selAppLst.length;i++){
        	if(selAppLst[i]=="" || selAppLst[i]==''){
            	selAppNull = true;
            }
		}
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
			 
        //Industry Partner led IPLed
        //TWC702-184
        if ((component.get("v.isOpalActivity")) 
            && (component.get("v.selBudgetType") != "" || component.get("v.selBudgetType") != null)) {
            if (component.get("v.selectedIndPartnerOptions") == "" || component.get("v.selectedIndPartnerOptions") == null) {
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_CP_ReqError") + '\n';
                validData = false;
            }
            else  if (helper.isNotBlank(component.get("v.selectedIndPartnerOptions")) && component.get("v.selectedIndPartnerOptions").includes('None') && component.get("v.selectedIndPartnerOptions").length > 1) {
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_None_IP_Error") + '\n';
                validData = false;    
            }
            else if ( component.get("v.selectedIndPartnerOptions").includes('Others') &&  
	                 (component.get("v.SelOtherChannelPartner") == "" || component.get("v.SelOtherChannelPartner") == null))
                     
                {   
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Other_CP_Error") + '\n';
                    validData = false;    
                }  
        }
	//OPAL Past Dated Activity Submission process
        var todaysDate = helper.getTodayDateLocalTime();
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
        var pfrStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var endDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var budgetType = component.get("v.selBudgetType");
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var mode = component.get("v.mode");
        var opalActBud = false;
        var diffDate = Date.parse(startDate) - Date.parse(todaysDate);
        var dateDifference = diffDate/(3600*24*1000) ;
        
         if(component.get("v.selectedLookUpRecord.Id") == null || component.get("v.selectedLookUpRecord.Id") =='' )
        {  helper.displaySuccessErrorMsg($A.get("$Label.c.Core_MDF_CampaignErrorMessage"),"Error!","error"); 
            validData = false;}
        
       if( mode == '' || mode == 'clone' || (mode == 'edit' && pfrStatus == 'Draft')){
        if(component.get("v.externalper") && component.get("v.SelCategory") == "Event" 
           &&  dateDifference < $A.get("$Label.c.Core_MDF_60DaysMoreThan_50K") && component.get("v.IPAIntelContri") >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold")) {
            var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Event_60_Days");                                
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
            validData = false;
           }
        } 
        
        
        if (component.get("v.IsStartDateChanged") && !component.get("v.externalper") && (component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == 'None')) {
            localmsg = localmsg + "Select a reason for submitting a Past Dated Activity." + '\n';
            component.set("v.IsPR", true);
            validData = false;
        }
        
        if (mode == 'clone') {
            if (startDate < todaysDate && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper"))) &&
                !component.get("v.externalper") && (component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')) {
                var alertMsg = "Select a reason for submitting a Past Dated Activity";
                helper.displaySuccessErrorMsg(alertMsg, "Error!", "error");
                component.set("v.IsPR", true);
                validData = false;
            }
            else if(startDate < todaysDate && component.get("v.externalper") && opalBudgetTypes.includes(budgetType)) {
                var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                validData = false;
            }
        } else if (mode == 'edit') {
            if (helper.isNotBlank(startDate) && helper.isNotBlank(oldStartDate) && startDate < todaysDate && oldStartDate != startDate && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper"))) &&
                !component.get("v.externalper") && (component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')) {
                var alertMsg = "Select a reason for submitting a Past Dated Activity";
                helper.displaySuccessErrorMsg(alertMsg, "Error!", "error");
                component.set("v.IsPR", true);
                validData = false;
            }
        }
    	var recordTypeName = component.get("v.recordtypeDeveloperName");
        var proposalBasedCamp = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        var campaignBudget =  component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
       
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && proposalBasedCamp == true){
            if(startDate < component.get("v.updatedCampaignObj.StartDate") || endDate > component.get("v.updatedCampaignObj.EndDate")){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Campaign_Date_Check_Error") + '\n';
            }
            if(component.get("v.showKPIError") == true){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_IPA_Others_Selection_Error") + '\n';
            }
        }
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && helper.isNotBlank(component.get("v.newPFR.Core_MDF_Opportunity_id__c")) ){
            if(helper.validateOpportunityId(component)){
               validData = false;
               localmsg = localmsg + $A.get("$Label.c.Core_MDF_OpportunityID_Error") +'\n';
            }
        }
        //POP and Attribution Requirements error message throw if field is empty
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !component.get("v.externalper") && component.get("v.isAttributionReqVisible") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Attribution_Requirements_txt__c"))){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_AttributionrequirementsError") + '\n';
        }
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !component.get("v.externalper") && component.get("v.isPOPReqVisible") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_POP_Requirements_txt__c"))){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_POPrequirementsError") + '\n';
        }
        //When the user selects Outcome based values but the Campaign is Non-Outcome based
        if (recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.SelectedStatus") != $A.get("$Label.c.Core_MDF_Activity_Cancelled_Status") && !component.get('v.showActTactics')) {
            if(component.get('v.outcomeBasedOptInInd')){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_OutcomeBased_Selection_Error") + '\n';
            }else if(helper.validateIPAMetricsValues(component)){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Blank_Metric_Error") + '\n';
            }
        }

        //When the user selects Non-Outcome based values but the Campaign is Outcome based
        var notValidActCatSelection = false;
        if (recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.SelectedStatus") != $A.get("$Label.c.Core_MDF_Activity_Cancelled_Status") && component.get('v.showActTactics') && component.get('v.pfrCloneCheck') && !component.get('v.outcomeBasedOptInInd')) {
            validData = false;
            notValidActCatSelection = true;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Non_OutcomeBased_Selection_Error") + '\n';
        }

        if (recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && ($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory")) && $A.util.isEmpty(component.get("v.SelDomainType")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_DomainTypeError") + '\n';
	    }
        //Ayush - New Category Change
        //Added below code on save to check (if start date in 2025 and old categories selected) then throw error or vice versa. 
        //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && helper.isNotBlank(startDate) && helper.isNotBlank(component.get("v.SelCategory"))) {
            if(new Date(startDate).getUTCFullYear() < $A.get("$Label.c.Core_MDF_NewCategoryDate") && helper.isLatestCategory(component)){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivityNewCategoryError") + '\n';
            }  
            else if(new Date(startDate).getUTCFullYear() >= $A.get("$Label.c.Core_MDF_NewCategoryDate") && !helper.isLatestCategory(component)){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivityNewCategoryError") + '\n';

            }
        }
        //Outcome Based change - Throw error when field is empty and outcome-based is selected as activity category
        if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && $A.util.isEmpty(component.get("v.selectedTacticsOptions")) 
            && (component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"))){
            if(!notValidActCatSelection){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Activity_Tactics_Error") + '\n';
            }
        }
	 //Start
        //Activity in-progress to cancel && IPA Proposal based Planned/In-Progress(Restrict for proposal completed)
        
        var cancelEligibleStatusPFR = $A.get("$Label.c.Core_MDF_PFR_cancel_eligible_status").split(";");
        var pfrStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var pfrSelectedStatus = component.get("v.SelectedStatus");
        var proposalInd = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        var campaignStatus = component.get("v.selectedLookUpRecord.Status");
        var checkForCancellation = false;
        if(pfrSelectedStatus != '' && pfrSelectedStatus != undefined && pfrSelectedStatus != null){
            if(pfrSelectedStatus == $A.get("$Label.c.Core_MDF_Activity_Cancelled_Status") && component.get("v.checkCloneAttribute") != true
              && (((pfrStatus == $A.get("$Label.c.Core_MDF_pfrInprogress") || pfrStatus == $A.get("$Label.c.Core_MDF_PFR_In_Progress_Revision_Required")|| pfrStatus == $A.get("$Label.c.Core_MDF_PFR_Status_Closed")) && proposalInd == false)||
                 (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && proposalInd == true && cancelEligibleStatusPFR.includes(pfrStatus) && validData))){
                
                    var action = component.get("c.cancelActvityForCancelledClaims");
                    action.setParams({
                        newPFR: component.get("v.newPFR"),
                        pfrSelectedStatus: component.get("v.SelectedStatus"),
                        isPfrStatusClosed: component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Closed' ? true:false
                    });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") { 
                            var result = response.getReturnValue(); 
                            if(result != undefined && result != null && result != ''){
                                if(result.isValidActivityCancelUser){
                                    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")); 
                                    helper.saveHelperMethod(component, component.get("v.newPFR"));
                                }
                                else if(!result.isValidActivityCancelUser)
                                {
                                    var toastEventfailure = $A.get("e.force:showToast");
                                    toastEventfailure.setParams({
                                    title: $A.get("$Label.c.Core_MDF_Error"),
                                    message: $A.get("$Label.c.Core_MDF_CloneAccessError"),
                                    type: "Error"
                                    
                                    });  
                                    toastEventfailure.fire(); 
                                    validData = false;
                                }
                            }
                        }
                        else if(state === "ERROR") {
                            var toastEventfailure = $A.get("e.force:showToast");
                            toastEventfailure.setParams({
                                title: $A.get("$Label.c.Core_MDF_Error"),
                                message: $A.get("$Label.c.Core_MDF_ActivityCancelFail"),
                                type: "Error"
                                
                            });
                            if(toastEventfailure != undefined){
                                 toastEventfailure.fire();
                                    }
                                 validData = false;
                        }
                        
                    });
                    $A.enqueueAction(action);
                }
            }
        
        //End
	   
	   //Retail Changes -to send the activity to ATF queue for approval, when RSM creates the past dated activity  
        
        if (startDate < todaysDate && component.get("v.accmgrper") && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") &&
            component.get("v.mode") != 'edit' && !component.get("v.isEMEARegion")){
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            component.set("v.newPFR.Core_MDF_ATF_Approval_Reqd_ind__c", true);           
        }


        //Subtype validation when its mandatory     
        if (component.get("v.activitySubTypeAvailable") == true && component.get("v.pfrRequiredFields.Core_MDF_Activity_SubType_nm__c") && (component.get("v.selActivitySubType") == "" || component.get("v.selActivitySubType") == null) && (component.get("v.selectedSubTypeOptions") == "" || component.get("v.selectedSubTypeOptions") == null)) {
           
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ){                          
		helper.ipsActMultiSubtypeVal(component);
            }
            else{
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivitySubTypeError") + '\n';
            }
            validData = false;
        }
        //Removing the status value in clone condition
        if(component.get("v.SelectedStatus") != "" && component.get("v.checkCloneAttribute")){
            component.set("v.SelectedStatus","");
        }
        //Error For $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") Error
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
		//TWC702-184
        /*if (component.get("v.recordId") != null && 
            component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && 
            component.get("v.checkCloneAttribute") == false && 
            component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail") && 
            !component.get("v.ipaApproverPer") && !component.get("v.priceReviewersPer") &&
            !component.get("v.opalAccountManagers")) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_PendingReviewError") + '\n';
            validData = false;
        }*/
       
        //Error for 'Budget Amount'
        var budgetAmount = component.find("BudgetAmount");
         var actSpendingAmount= component.get("v.BudgetLocal");
        
      var budgetAmount = component.find("BudgetAmount");
         var actSpendingAmount= component.get("v.BudgetLocal");
     
       
     if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") &&(component.get("v.isPropBasedCampaign") == true)) ){
            if ((component.get("v.ipaApproverPer")||component.get("v.ipaL2Approver")) && (component.get("v.selectedLookUpRecord.Core_MDF_Approval_Stage_nm__c") == 'L1 Approval'||
                                                                                          component.get("v.selectedLookUpRecord.Core_MDF_Approval_Stage_nm__c") == 'L2 Regional Marketing'||
                                                                                         component.get("v.selectedLookUpRecord.Core_MDF_Approval_Stage_nm__c") == 'L2 Regional Sales') && component.get("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c") == 0){
              helper.saveHelperMethod(component, component.get("v.newPFR"));
            }else if(actSpendingAmount == null || actSpendingAmount == '' || actSpendingAmount <=0 || 
                     (!$A.util.isEmpty(actSpendingAmount) && actSpendingAmount != undefined && (actSpendingAmount.toString().includes('.')))){
               helper.ipaBudgetValidation(component);
               localmsg = localmsg + $A.get("$Label.c.Core_MDF_Budget_Amount_Error") + '\n';   
                validData = false;                
        }else {  
            if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")&&(component.get("v.isPropBasedCampaign") == true)) ){
                if(budgetAmount.length == 1){
                    budgetAmount[0].setCustomValidity("");
                    budgetAmount[0].reportValidity();
                }else{
                    budgetAmount.setCustomValidity("");
                    budgetAmount.reportValidity(); 
                }
            }           
             
          }             
        }
       
        //Error if not Acc mgr or Submitter or Auditor 
        if(component.get("v.userWithoutAccess") && 
!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
              && helper.isCurrentUsrIsApprover(component)) && !component.get("v.priceReviewersPer") &&!component.get("v.ipaL2Approver")){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_CloneAccessError") + '\n';
            validData = false;
        }
        //Error if mandatory fields are blank in "My Activities" page
        var metrics = component.find("kpiFields");
        if(metrics != null && !metrics.isFormValid()){
            var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
    	    validData = false;
        }
        
         
        if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ){
            if ($A.util.isEmpty(component.get("v.newPFR.Title")) ||
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Activity_Description__c")) || 
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Start_Date__c")) ||
                $A.util.isEmpty(component.get("v.newPFR.Core_MDF_End_Date__c")) ||
                ($A.util.isEmpty(component.get("v.SelCategory")) && component.get("v.pfrRequiredFields.Core_MDF_ActivityCategory__c")) || 
                ($A.util.isEmpty(component.get("v.SelActivityType")) && component.get("v.pfrRequiredFields.Core_MDF_Activity_Types__c"))) { 
                var activityCat = component.find("activityCat");
                if(activityCat !=null && activityCat != undefined)
                {
                if(activityCat.length == 1){
                    activityCat[0].validateErrors();
                
                }else{
                    activityCat.validateErrors();
                }
		}
                var activityType = component.find("activityType");
                 if(activityType !=null && activityType != undefined)
                {
                if(activityType.length == 1){
                    activityType[0].validateErrors();
                
                }else{
                    activityType.validateErrors();
                } 
		}           	
                var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
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
		var spifActivityTypes = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
        // Event Format Data
        
        // Event Format Data Stamping And Error Handling
        
        if(component.get("v.enableEventFormat")){
            if(!$A.util.isEmpty(component.get("v.selectedEventFormat"))){
                component.set("v.newPFR.Core_MDF_Event_Format_Nm__c", component.get("v.selectedEventFormat"));
            }else{
                
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Activity_Event_Form_Error") + '\n';
                validData = false; 
                
            }
        }else{
            component.set("v.newPFR.Core_MDF_Event_Format_Nm__c", null);
            component.set("v.selectedEventFormat", null);
        }
        component.set("v.newPFR.Core_MDF_NEX_Ind__c", component.get("v.nexInd"));
        
        
        //US1106484: [WW44] - [RMF] - [Internal Users] - Approver Notifications
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.recordId") != null && component.get("v.mode") == 'edit'){
            if(component.get("v.accmgrper") && component.get("v.retailgeouserper") && (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required' || component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Planned') && component.get("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c")){
                    component.set("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c",false);                               
                }
            else if(component.get("v.retailgeouserper")){
                component.set("v.newPFR.Core_MDF_UserRole_txt__c", 'Geo Lead');                
            }else if(component.get("v.accmgrper")){
                component.set("v.newPFR.Core_MDF_UserRole_txt__c", 'RSM');
				//Reset ATF ind on Account Manager edit for Revision Required & Planned Activity
                if((component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required' || component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Planned') && component.get("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c")){
                    component.set("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c",false);                               
                }
            }else if(component.get("v.priceReviewersPer")){
                component.set("v.newPFR.Core_MDF_UserRole_txt__c", 'PCT');
            }           
        }
        
        
        //Error for Rejected Retail Activities
        if (helper.isNotBlank(component.get("v.recordId")) && component.get("v.CurrentStatus") == 'Rejected'
            && component.get("v.SelectedStatus") != 'Cancelled'
            && component.get("v.checkCloneAttribute") == false && 
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_RejectedError_Retail") + '\n';
            validData = false;
        }
        
        //Error for Closed Retail Activities
        if (helper.isNotBlank(component.get("v.recordId")) && component.get("v.CurrentStatus")!=null && component.get("v.CurrentStatus") == 'Closed' 
            && component.get("v.checkCloneAttribute") == false && 
            recordTypeDeveloperName.includes($A.get("$Label.c.Core_MDF_Closed_Activity_Program_Wise")) && !component.get("v.retailgeouserper"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Close_Activity_Error") + '\n';
            validData = false;
        }
        
        /*Error when new end date is less than old end date*/
        if ((helper.isNotBlank(edate) && helper.isNotBlank(oldedate)&& edate<oldedate) && accmgrper && oldstatus == 'Planned' &&
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")  && !component.get("v.checkCloneAttribute"))
        {
                localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_End_Date_Mod_Error") + '\n';
            validData = false;
        }
        if ((helper.isNotBlank(stdate) && helper.isNotBlank(oldstdate) && stdate>oldstdate) && accmgrper && oldstatus == 'In-Progress'  && !component.get("v.checkCloneAttribute"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_Date_Mod_Error") + '\n';
            validData = false;
        }
	
        // OPAL changes Start
        // Error when external user create/edit an opal activity and selects DCF SMF Sub type
        if(component.get("v.externalper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") && component.get("v.activitySubTypeAvailable")){
            var selectedsubTypes = component.get("v.selectedSubTypeOptions");
            var subTypeDCFSMF = $A.get("$Label.c.Core_MDF_ActSubType_DCF_SMF");
            var isRecIdNotBlank = helper.isNotBlank(component.get("v.recordId"));
            var existingSubType = component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c");
            if((isRecIdNotBlank == false || component.get("v.checkCloneAttribute")) && selectedsubTypes.includes(subTypeDCFSMF)){	//For create or clone scenarios
                validData = false;
                var errorMSg = $A.get("$Label.c.Core_MDF_ActSubType_ErrMsg");
                helper.displaySuccessErrorMsg(errorMSg,"Error..!!","error");
            } else if((helper.isNotBlank(existingSubType) && !component.get("v.checkCloneAttribute") && ((existingSubType.includes(subTypeDCFSMF) && !selectedsubTypes.includes(subTypeDCFSMF)) || (!existingSubType.includes(subTypeDCFSMF) && selectedsubTypes.includes(subTypeDCFSMF)))) || (!helper.isNotBlank(existingSubType) && selectedsubTypes.includes(subTypeDCFSMF))){
                validData = false;
                var errorMSg = $A.get("$Label.c.Core_MDF_ActSubType_ErrMsg");
                helper.displaySuccessErrorMsg(errorMSg,"Error..!!","error");		
            }
        }       
        //Validation rules while acitvity is created/edited/cancelled/closed
        var budgetTypeArr = component.get("v.budgetTypeVal");
        
        
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.isPropBasedCampaign") == false
    && (component.get("v.selAvailableBudget") == null  || component.get("v.selAvailableBudget") == undefined || component.get("v.selAvailableBudget") ==""))
    {
        validData = false;
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_AvailableBudget_ErrMsg") + '\n';            
    }
        
        // OPAL changes End
	
		//Error when Geo lead is changing an Activty type from Non-SPIF to SPIF or SPIF to Non-SPIF
	    //Update - Geo lead as well as EMEA reviewer will not be able update from Non-SPIF and SPIF to SPIF or SPIF to Non-SPIF
		//Updated condtion to throw error message only when user having Single(Geo Lead) Permission
       
	//opal changes potential winner/number of expected -start 
        var lwcKpiFieldsPotentialWinner = component.find("kpiFields");  
        if (lwcKpiFieldsPotentialWinner != null && lwcKpiFieldsPotentialWinner != '') {
            var potNumValues = lwcKpiFieldsPotentialWinner.checkValidationPotentialWinners();
            if(potNumValues == 'perExceedError'){
                validData = false;
                var alertMsg = $A.get("$Label.c.Core_MDF_Error_Potenial_Winner");
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
            } 
            else if( potNumValues == 'noExpPotCheck'){
                   validData = false;
                var alertMsg = $A.get("$Label.c.Core_Potential_Greater_Error");
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error                
            }
        }
        //opal changes potential winner/number of expected -end 
	/* Checking if Segment Component present and assigning segment string to attribute */
        var activityType =  component.get("v.SelActivityType");
         var activityAmount = component.get("v.activityAmount");
        //Outcome Based changes - Added Or condition to save SPIF/Incentive segment on save of activity
        if(spifActivityTypes.includes(activityType)|| helper.checkSPIFTactics(component)) {
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
                   helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                }
                else if(activityAmount < spifAmount){
                    validData = false;
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                } else { 
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
                    // Ramapriya - ATF Flag to be stamped on edit of In-progress activity
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
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                }
            }
            
        }
        
        //Ayush - Outcome Based changes - saving tactics metrics on click of save

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
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
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
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        if ((((component.get("v.retailgeouserper") && component.get("v.mode") == 'edit' && ((component.get("v.CurrentStatus") == 'Revision Required' && component.get("v.newPFR.Core_MDF_Start_Date__c") < todaysDate) || component.get("v.CurrentStatus") == 'Closed' || component.get("v.CurrentStatus") == 'Planned')))  || (component.get("v.rsmActivityReviewerper") && component.get("v.accmgrper") == false)) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
            var existingActType = component.get("v.oldActivtyType");
			var currActivityType =  component.get("v.SelActivityType");
			 
			if((!spifActivityTypes.includes(currActivityType) && spifActivityTypes.includes(existingActType))
              		   || (spifActivityTypes.includes(currActivityType) && existingActType != currActivityType)){
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_SPIF_Act_Type_Change_Err") + '\n';
            			validData = false;
        		}
             
         
		}
		  //[IPA] BU Mapping - this method is use to check validation of BU split and stored the value
        /*var buSupprtPrg = $A.get("$Label.c.Core_MDF_BU_Split_Supported_Prg").split(";");
        if(buSupprtPrg.includes(recordTypeDeveloperName)){
            if(component.get("v.showBUSPlitMultiselect")  &&   component.get("v.buSplitSelectedList") != undefined &&  component.get("v.buSplitSelectedList") != null && component.get("v.buSplitSelectedList") != ''){
            var  metadataBuSplitData = []; 
            //metadataBuSplitData = component.get("v.metadataBuSplitMap");
            var totalPercentage =0;
            for(let i=0;i<metadataBuSplitData.length;i++){
                var fieldVal = JSON.stringify(metadataBuSplitData[i].Core_MDF_Field_Name__c);
                var mergeField = 'v.newPFR.'+JSON.parse(fieldVal);
		try{
                    if(helper.isNotBlank(component.get(mergeField))/*component.get(mergeField) != null && component.get(mergeField) != '' && (component.get(mergeField) <= 0 || component.get(mergeField).includes(".") || component.get(mergeField).includes("-") || component.get(mergeField).includes("+")) ){
                        component.set("v.buSplitWholeNumError",true);   
                    }  
                }
                catch(e){
                }
                totalPercentage += isNaN(parseInt(component.get(mergeField))) ? 0 : parseInt(component.get(mergeField));
            }
            component.set("v.busplitTotalPercentage",totalPercentage);*/
            /*if(component.get("v.busplitTotalPercentage") == 100){
                component.set("v.newPFR.Core_MDF_BU_Split__c",component.get("v.buSplitSelectedList").join(";")); 
            }
            else{
                validData = false;
                var alertMsg = $A.get("$Label.c.Core_MDF_BuSplit_LessPercentError");
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); 
            }
		 if(component.get("v.buSplitWholeNumError")){
		    validData = false;
		}*/    
            
       // }
       // }
        var actStatus = component.get("v.CurrentStatus");
        var existingOwner = component.get("v.existingIntelOwner");
        var mode = component.get("v.mode");
        
        // If all the Entered Data are valid in terms of text or Number
        if(validData){
            //set PFR record with selected values
            component.set("v.newPFR.CampaignId",component.get("v.selectedLookUpRecord").Id); 
            component.set("v.newPFR.Core_MDF_Event_Name_nm__c",component.get("v.selActivityEventName"));
            component.set("v.newPFR.Core_MDF_Domain_Type_nm__c",component.get("v.SelDomainType"));
            if(helper.isNotBlank(component.get("v.activityOwner")) && !component.get("v.externalper")){
				component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c",component.get("v.activityOwnerId"));
			}
            if(!component.get("v.displayApprovers")){
                component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c",null);
            }
             //Set PFR Record with selected submitter values
            if(helper.isNotBlank(component.get("v.activityExtOwner")) && component.get("v.externalper")){ 
				component.set("v.newPFR.Core_MDF_Member_Acceptor_Id__c",component.get("v.activityExtOwnerId"));
			}
            if(!component.get("v.displayExtActSubmitters")){
                component.set("v.newPFR.Core_MDF_Member_Acceptor_Id__c",null);
            }
            component.set("v.cmpgnStatus", component.get("v.selectedLookUpRecord").Status);
            if(helper.isNotBlank(component.get("v.selectedPartner").Id)){
                component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedPartner").Id);
            }		
            
            if (component.get("v.CPLed") == false)
            {
                component.set("v.SelOtherChannelPartner",'');
                component.set("v.SelChannelPartner",'');
            }
            //POP and Attribution Requirments changes if activity type is not other, pop and attribution requirement field null.
            var activityType = component.get("v.SelActivityType");
            var otherActTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
            if(helper.isNotBlank(activityType) && helper.isNotBlank(otherActTypes) && !otherActTypes.split(",").includes(activityType)){
                component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
            }
            
          component.set("v.newPFR.Core_MDF_Require_Additional_Review_ind__c",component.get("v.isAdditionalReviewReqd"));
          component.set("v.newPFR.Core_MDF_Focus_Area_nm__c",component.get("v.selectedFocusArea"));
          component.set("v.newPFR.Core_MDF_Activity_Classification_nm__c",component.get("v.selActivityClassification"));
          //Outcome Based changes - set the values in tactics field on saved
          if(recordTypeName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !$A.util.isEmpty(component.get("v.selectedTacticsOptions")) 
              && (component.get("v.SelCategory") != $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"))){
                component.set("v.selectedTacticsOptions",'');
          }
          component.set("v.newPFR.Core_MDF_Tactics_nm__c",component.get("v.selectedTacticsOptions"));
    
            
          if (component.get("v.SelChannelPartner") != "Others" && component.get("v.SelOtherChannelPartner") != "" && !component.get("v.isOpalActivity")){
              component.set("v.SelOtherChannelPartner", "");
              }
            component.set("v.newPFR.Core_MDF_ActivityCategory__c",component.get("v.SelCategory"));
            component.set("v.newPFR.Core_MDF_Activity_Types__c",component.get("v.SelActivityType"));
            component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
            component.set("v.newPFR.Core_MDF_Priority_nm__c",component.get("v.SelPriority"));
            component.set("v.newPFR.Core_MDF_TargetAudience__c",component.get("v.SelTargetAudience"));
            component.set("v.newPFR.RecordTypeId",component.get("v.recordtype"));
            component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c",component.get("v.SelOtherChannelPartner"));
            component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",component.get("v.CPLed"));
            
           
	      //OPAL Past Dated Activity Submission process
            if(!component.get("v.externalper")){
                
                    component.set("v.newPFR.Core_MDF_ReasonforPastDatedActivity_Nm__c", null);                  
                 
            }
          
            //set the channel program led value to true if SelChannelPartner != None and set it to false if SelChannelPartner == None for OPAL -- start
          if(component.get("v.isOpalActivity") && !component.get("v.selectedIndPartnerOptions").includes('None') ){
              component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",true);
          }
          if(component.get("v.isOpalActivity") &&component.get("v.selectedIndPartnerOptions").includes('None')){
              component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",false);
          }
            //set the channel program led value to true if SelChannelPartner != None and set it to false if SelChannelPartner == None for OPAL -- end
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.CurrentStatus"));

            component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
            component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
            component.set("v.newPFR.Core_MDF_Joint_Content_ind__c",component.get("v.JointContent"));
            //Country Multi Select           
            //[Tech] - [IPA] Hide Country/Region field in Activity form layout   
            if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
	    	
                // Country values is referring from campaign record.
                if (recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_IPA_RecordType") ){
                component.set("v.newPFR.Core_MDF_Country_nm__c", component.get("v.selectedLookUpRecord").Core_MDF_Market__c);
                }
                
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_pct__c", component.get("v.selectedLookUpRecord").Core_MDF_Reimbursement_Rate__c);
            } else {
                component.set("v.newPFR.Core_MDF_Country_nm__c",component.get("v.SelMarketValue"));             
            }
            
            
            if (!$A.util.isEmpty(component.get("v.incentive")) && parseFloat(component.get("v.incentive")) > 0) {
                if ($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c")) || component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == "No") {
                    component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", "No");
                    component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
                    component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
                }
                 if (component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == "Yes") {
                    if (component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == "Yes") {
                        component.set("v.newPFR.Core_MDF_Incentive_pct__c", component.get("v.incentive"));
                        component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", component.get("v.incentiveCriteriaId"));
                    }	
                    else {
                        component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", "No");
                    }
                }
                    else {
                        component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", null);
                    }
 			//TECH [DCF/SPCF] - [OOC] - 60% RR for Intel Select Solutions
              if (component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == 'Yes') {
                  component.set("v.newPFR.Core_MDF_Incentive_pct__c", component.get("v.incentive"));
                  component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", component.get("v.incentiveCriteriaId"));
              }
              else{
                  component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
                  component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
                  component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", "No");
              }

          }
		  
          if(component.get("v.isOpalActivity")) {
              component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selectedSubTypeOptions"));
			  
			   //[Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
             
              //IPLed
              if (!(component.get("v.selectedIndPartnerOptions").includes("Others"))  && component.get("v.SelOtherChannelPartner") != ""){
                   component.set("v.SelOtherChannelPartner", "");
              }
              //Industry partner Led IPLed
              var selectIndPartnr =component.get("v.selectedIndPartnerOptions");
              component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c", component.get("v.SelOtherChannelPartner") );
              }
             //Added extra condition to fix Defect DE117182  
            if(!component.get("v.isOpalActivity") && component.get("v.selectedSubTypeOptions") == null ) {
                component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c",null);
            }
                
            if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                
		//New Budget Type field changes replaced txt field with new global picklist field
		component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selectedLookUpRecord").Core_MDF_Opal_Budget_Type_Txt__c);
                component.set("v.newPFR.ChannelPartnerId", component.get("v.selectedLookUpRecord").Core_MDF_Account__c);
                //Subtype multiselect
                component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selectedSubTypeOptions"));
            }
            if ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) 
                && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
                if(component.get("v.campriorityValue") == false ){
                    component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.selectedLookUpRecord").Core_MDF_Priority__c); 
                }
                else{
                    component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.campriority"));
                }
				 if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selActivitySubType"));	
                //commenting out as part of Duplicate Field Removal 
                //component.set("v.newPFR.Core_MDF_Budget_Type_txt__c",component.get("v.selectedLookUpRecord").Core_MDF_Budget_Type_txt__c);
		//New Budget Type field changes replaced txt field with new global picklist field
		component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selectedLookUpRecord").Core_MDF_Budget_Type_txt__c);				
                component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedLookUpRecord").Core_MDF_Account__c);  
                
                //Reimbursement Rate - Check if there is a selected value or Not
                if(component.get("v.SelReimbursementRate") == null || component.get("v.SelReimbursementRate") == '')
                {
                    var ratelst = component.get("v.ReimbursementRateVal");
                    
                    if(ratelst.length >0)
                        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_pct__c",ratelst[0].value);            
                }
                else
                {
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_pct__c",component.get("v.SelReimbursementRate"));           
                }
            }
			}
            else
            {
                component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.selectedLookUpRecord").Core_MDF_Priority__c);
            }
            if(component.get("v.SelectedStatus") != "" ){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.SelectedStatus"));
            }
            
            // Making Id null in order to save New Record from clone
            if(component.get("v.checkCloneAttribute")){
			 //[IPA MDF] - Campaign - Clone a Proposal - Activity Section - if its clone from campaign then dont make id null
              if(component.get("v.pfrCloneCheck")){
                  
              }else{
                component.set("v.newPFR.Id", null);
              component.set("v.recordId", null);
              component.set("v.newPFR.CreatedDate", null);
              component.set("v.newPFR.Core_MDF_Activity_Closure_Type__c", '');
              }

                if(!recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !component.get("v.isPropBasedCampaign") == false){
                    component.set("v.newPFR.BudgetId", null);  
                    component.set("v.newPFR.AllocationId", null);   
                } 
            }
              
          if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF")
              || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
              ||  ((recordTypeDeveloperName == 'Core_MDF_Intel_Partner_Alliance')
                   && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false ) )
             &&component.get("v.recordId") == null && (component.get("v.isLoggedInUserLevelOneApprover") || component.get("v.ipaAcctMgr"))){
              
              
              component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",1);                                     
              component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');
          }
            //Enabe Activity type edit for CCF Planned status
            
            var oldedate = component.get("v.oldedate");
            var oldpfrStatus = component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c");
            var newpfrStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
            if ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && component.get("v.isPropBasedCampaign") == true) {
                if ((oldpfrStatus != 'Pending Review' && oldpfrStatus != 'Revision Required' && oldpfrStatus != 'Closed'
                     && component.get("v.cmpgnStatus") == 'Draft')
                    || oldpfrStatus == '') {
                    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", "Draft");
                } else if (component.get("v.cmpgnStatus") == 'Pending Review') {
                if(!component.get("v.ipaL2Approver") && newpfrStatus!= 'Cancelled'){
                    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", "Pending Review");
                }
                   
                }
            }
             
            if (component.get("v.recordId") != null && ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
                                             && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true)){
                if (!component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                    !$A.get("$Label.c.Core_MDF_PFR_Status_Closed").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                    helper.setIPAactivityStatus(component);
                }
            }
            else if(component.get("v.SelectedStatus") != undefined && component.get("v.recordId") != null && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")&&(component.get("v.isPropBasedCampaign") == false))){
               if (!component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                    !$A.get("$Label.c.Core_MDF_PFR_Status_Closed").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                    helper.setIPAAccountBasedActivityStatus(component);
                }  
            }
            
            //[RMF] [WW51] Approval flow when Geo Lead edit Activities
            var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
          //WW19 | QA3 | When Geo Lead edits an Activity,
          //which is in Planned status and changes the start date to 1 day minus today,
          //then Activity re approval is getting triggered
          var today = helper.getTodayDateLocalTime();
	  if(helper.isNotBlank(component.get("v.recordId")) && 
             component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && 
             component.get("v.retailgeouserper")){
              
              if((component.get("v.newPFR.Core_MDF_Start_Date__c") != component.get("v.oldPFR.Core_MDF_Start_Date__c")) && 
                 (startDate >= today) && 
                 $A.get("$Label.c.Core_MDF_PFR_Applicable_StatusForGeoLeadEdit").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))){
                  component.set("v.newPFR.Core_MDF_Activity_Closure_Type__c", '');
                  component.set("v.newPFR.Core_MDF_No_Internal_Close_Date__c", '');
                  helper.callNextLevelApproval(component);
              }
              else if((startDate < today) && component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == "Planned"){
                  var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_FieldsForGeoLeadApproval");              
                  if (helper.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval.split(';'))) {                      
                      helper.callNextLevelApproval(component);
                  } 	
              }
            } 
            
  
            if (helper.isNotBlank(component.get("v.recordId")) && ((component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_IPA_RecordType")))) {
                //Account Manager - - 
                //Activty  Status In cancelled/ In-Progress, Closed , we donot set to Pending Review planned
                //Core_MDF_PFR_RestrictStatusChange - In-Progress, Closed 
                //$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)
                if(helper.isNotBlank(component.get("v.SelectedStatus"))&& !component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                   !$A.get("$Label.c.Core_MDF_PFR_RestrictStatusChange").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                    
                    if(component.get("v.accmgrper") && !component.get("v.opalAccountManagers") && component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
                        var editedFieldRequiresApproval = component.get("v.activityFieldSetList");                        
                            if(helper.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval)){
                                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_CCP_Planned_Status")); 
                            }
                    }else{
                        helper.setfundRequestStatusHelper(component);
                    }
                    //Set the Fund Request Status based on criteria's - ContentCreateActivty or event or Revision Required or Retail  
                    
                }
            }   
            else if(component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status") && component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            }
         //[DCF/SPCF] - Capping of 10% on RR for DCF/SPCF If activity date,technology,brand,Activity type are matching- start
          if (component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == 'Yes' && (component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == 'No' || component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == null)
              && component.get("v.incentive") && component.get("v.SelReimbursementRate") 
              && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_SPCF"))
              && (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                  component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") ||
                  component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0") || component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == null || component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == "" ) ) {
              
              var calIncentive = (parseFloat(component.get("v.SelReimbursementRate")) + parseFloat(component.get("v.incentive")));  
              var newRRPer = (calIncentive > 100? 100: calIncentive);
              var newRRDecValue = parseFloat(newRRPer.toFixed(2));  
              var newRRPerVal = newRRDecValue +"%";
              component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",newRRPerVal); 
          }
          //[DCF/SPCF] - Capping of 10% on RR for DCF/SPCF If activity date,technology,brand,Activity type are matching- end
			//Customer Auto Approval for MDF and MDF+ if no edit done by internal account manager - start
          var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
          var removeFieldNotReqVal = editedFieldRequiresApproval.toString().replace(',Core_MDF_Require_Additional_Review_ind__c', '');
          var convertArrayFieldSet = removeFieldNotReqVal.split(',');  
          if((helper.fieldEligibleForApprovalModified(component, convertArrayFieldSet)
              || component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") == true) && component.get("v.mode") == 'edit' &&
             component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_CCP_Planned_Status") &&
             (component.get("v.opalAccountManagers") || component.get("v.ipaAcctMgr") || component.get("v.ipaL2Approver")) &&
             (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") || 
             component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
             component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")||
              ((
                (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) )
               && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false))) {
             component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
          }
            //Print Media, VR ,Upload File, Event Validation
            helper.checkExtraQuestionAndUploadFile(component);
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
        }//component system validation ends 
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
            }
        }
    },
    
    // Function called on click of negative scenrio(Cancel or close) on the popup
    hidePopup : function(component,event){
        
        var EventData = event.getParam("ButtonClick");
        var popupType = event.getParam("popupName");
        
        if(popupType == 'Event'){
            component.set("v.PopupButtonValue",EventData);
            component.set("v.PopupType",null);
        }
        else{
            component.set("v.ELCPopupButtonValue",EventData);
        }
        component.set("v.ShowEventPopup",false);
        if (EventData== false){
            component.set("v.PopupType",null);
            component.set("v.recordApplicableForActivityRules", true);
        } else if(EventData == true){
            if(popupType == 'Event'){
                //helper.popUpHelper(component,"ELC");
                //[RMF] update the Event ethics popup
                //Mohit - Outcome based updates, removed RMF condition and added check for outcome based and non outcome based
                /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                    component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Event_Ethic"));
                } else {
                    component.set("v.EventMessage",$A.get("$Label.c.Core_MDF_Terms"));
                }*/
                if(component.get("v.SelCategory") != $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
                    component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
                }else{
                    component.set("v.EventMessage", $A.get("$Label.c.core_mdf_terms_tactics_ELC_popup"));
                }
                component.set("v.AgreeButtonLabel",$A.get("$Label.c.Core_MDF_I_Understand"));            
                component.set("v.DisagreeButtonLabel",$A.get("$Label.c.Core_MDF_CancelOption"));
                component.set("v.PopupType","ELC");
                component.set("v.ShowEventPopup",true);
                
            } else if(popupType == 'ELC'){
                component.set("v.ShowEventPopup",false);
            }     
        }
        
    },
    // Function called to store the values from the Upload Component once the file is uploaded
    uploadfile: function(component,event){
        component.set("v.ContentDocumentIds",event.getParam("uploadFilesIds"));
        component.set("v.Uploadfinished",event.getParam("fileUploaded"));
        if (event.getParam("fileUploaded")){
            component.set("v.message","");
            component.set("v.messageType","");
            component.set("v.ChgndAttach",true);
        }    
    },
    questions: function(component,event,helper){
        var pfr = event.getParam("valueOfDynamicQ");
        
        //Variable Reimbursement Rate changes
        
        if (pfr != undefined) {
            if (helper.isNotBlank(pfr.Core_MDF_Competitive_Elements__c)){
                component.set("v.newPFR.Core_MDF_Competitive_Elements__c",pfr.Core_MDF_Competitive_Elements__c);
                component.set("v.competetiveElement",pfr.Core_MDF_Competitive_Elements__c);
            }
            if (helper.isNotBlank(pfr.Core_MDF_Government_Nexus__c))
                component.set("v.newPFR.Core_MDF_Government_Nexus__c",pfr.Core_MDF_Government_Nexus__c);
            if (helper.isNotBlank(pfr.Core_MDF_ofPagesEligible__c ))
                component.set("v.newPFR.Core_MDF_ofPagesEligible__c",pfr.Core_MDF_ofPagesEligible__c);
            if (helper.isNotBlank(pfr.Core_MDF_pagespayingfor__c ))
                component.set("v.newPFR.Core_MDF_pagespayingfor__c",pfr.Core_MDF_pagespayingfor__c);
            if (helper.isNotBlank(pfr.Core_MDF_Incentive_Opted_In_ind__c)){
                component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",pfr.Core_MDF_Incentive_Opted_In_ind__c);
            	component.set("v.incentivePercent",pfr.Core_MDF_Incentive_Opted_In_ind__c);
            }
            if (helper.isNotBlank(pfr.Core_MDF_Incentive_Question_ind__c))
                component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c",pfr.Core_MDF_Incentive_Question_ind__c);  
        }
    },
    
    resetIntelContribution: function(component, event, helper){
        //helper.fetchApprovers(component);
    },
    // Function called on the load of the page 
    // Contains two Part:- Edit scenario (where we set the values to attribute from the record fields )
    // New Scenario (where we create record type filter )
    doInit: function(component, event, helper) {
    	helper.partnerEffortMetricForActivityCreation(component);
        helper.getInitialDataFromServer(component, event);
        helper.onStartDateChange(component);
	      var recordTypeDeveloperName;
	    
        //Ramapriya - on click of edit validate claim status for In-progress activities
        if(component.get("v.mode") == 'edit' && component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress') 
        {
            var activityId = component.get("v.newPFR.Id");
            helper.validateInProgressActivity(component, activityId);
        }
            
        if(component.get("v.mode") == 'edit'){
            helper.getFieldEditabilityMapping(component, event);              
            }
	
        if(component.get("v.apitoLabelConvert") == null){
            var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
            var fieldlist = fields.split(",");
            helper.convertApitoLable(component,fieldlist);
        }
        var getoptionMap = component.get("v.apitoLabelConvert");
        for(var key in getoptionMap ){
            if(key = component.get("v.budgetCurrency")){
                component.set("v.CurrentCurrencyLabel", getoptionMap[key]);
                break;
            }
        }
        helper.fetchPicklistInfo(component,component.get("v.fieldNameCurrency"));
        
        var recordType ="";
        var startdate;
        var enddate;
        var statuslabel = $A.get("$Label.c.Core_MDF_FundRequestStatusLabel");
        var statusArray = [];
        var displayStatus = [];
        statusArray = statuslabel.split(",");
        for(var i=0; i<statusArray.length; i++ ){
            if(i==0){
                displayStatus.push({
                    class: "optionClass",
                    label: statusArray[i],
                    value: "Cancelled"
                });
            }
            else{
                displayStatus.push({
                    class: "optionClass",
                    label: statusArray[i].label(),
                    value: statusArray[i]
                }); 
            }
        }
        var recordTypeDevName;
        component.set("v.StatusLabel",displayStatus);
        if(component.get("v.mode") == 'edit'|| component.get("v.mode") == 'clone'){
          recordTypeDevName=(component.get("v.newPFR.RecordType.DeveloperName"));
        }else{
          recordTypeDevName = component.get("v.recordtypeDeveloperName");  
        }
        
        
       //Start - Check for Activity Creation Permission
        var accessresult;
            var actionCheckCreatePFRAccess = component.get("c.validatePfrCreationAccess");
            
            actionCheckCreatePFRAccess.setParams({
                "recordType": recordTypeDevName
            });
            
            actionCheckCreatePFRAccess.setCallback(this, function (response) {
                accessresult = response.getReturnValue();
                component.set("v.hasCreateAccess", accessresult);
                if(component.get("v.hasCreateAccess") == false && component.get("v.mode") == '' && recordTypeDevName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                    if(component.get("v.isActivityCreationOnCampaign") == true){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error",
                            message: $A.get("$Label.c.Core_MDF_CloneAccessError"),
                            type: "error",
                            mode: 'sticky',
                        });
                        toastEvent.fire();
                        component.find("navService").navigate({
                            "type": "standard__recordPage",
                            "attributes": {
                                "recordId": component.get("v.selectedLookUpRecord.Id"),
                                "objectApiName": "Campaign",
                                "actionName": "view"
                            }
                        });
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: "Error..!!",
                            message: $A.get("$Label.c.Core_MDF_CloneAccessError"),
                            type: "error"
                        });     
                        toastEvent.fire();
                        var homeEvent = $A.get("e.force:navigateToObjectHome");
                        homeEvent.setParams({
                            scope: "PartnerFundRequest"
                        });
                        homeEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                        
                    }
                }
            });
            
            $A.enqueueAction(actionCheckCreatePFRAccess);
        
        
        //end - Check for Activity Creation Permission

        
        
        
        
        if(recordTypeDevName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && 
        (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true 
         || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true)){
            helper.checkCountry(component);
        }
        if(recordTypeDevName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            if(component.get("v.checkCloneAttribute") == true){
                component.set("v.isClearedOnClone",true);
            }
            component.set("v.isDecimalApplicable",true);
        }
        
        //Ayush - Changes for New Activity Category 
        if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true"){
            helper.getNewCategoryValues(component, recordTypeDevName);
        }
        
        
        //Load the metadata Value on the load of the page
        var metadataresult;
        var actionFetchMetadata = component.get("c.fetchMetadataMapping");
        
        
        
        actionFetchMetadata.setCallback(this, function (response) {
            metadataresult = response.getReturnValue();
            component.set("v.metadataMap", metadataresult);
        });
        
        $A.enqueueAction(actionFetchMetadata);
        
        var actionFetchFieldSet = component.get("c.fetchFieldSets");
        
        actionFetchFieldSet.setCallback(this, function (response) {
            if(response.getState() == "SUCCESS"){                
                component.set("v.activityFieldSetList", response.getReturnValue());
            }   
        });
        $A.enqueueAction(actionFetchFieldSet);
         
        // Load users permissions in the attributes
        var userperMap = component.get("v.userperMap");
        var permissionSetName;
        var permissionSets = [];
        
        permissionSetName = $A.get("$Label.c.Core_MDF_Activity_Remainders_Excepted_Roles");
        permissionSets = permissionSetName.split(",");
        userperMap["fileexceptionper"]=permissionSets;
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_ClaimCase_Reviewer_Manager");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["auditorper"]=permissionSets;
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_CCF_DCF");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["externalper"]=permissionSets;
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Account_Manager_CCF_DCF");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["accmgrper"]=permissionSets;
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Retail_Geo_User");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["retailgeouserper"]=permissionSets;
        permissionSetName = $A.get("$Label.c.Core_MDF_Retail_Reviewer_Permission_Set");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["rsmActivityReviewerper"] = permissionSets;
        
         
        
        
        permissionSetName = $A.get("$Label.c.Core_MDF_IPA_Approver");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["ipaApproverPer"] = permissionSets; 
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Internal_IPA_Acct_Mgr_PS");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["ipaAcctMgr"] = permissionSets; 
        permissionSetName = $A.get("$Label.c.Core_MDF_IPA_L2_Approver_PS");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["ipaL2Approver"] = permissionSets;
        
        permissionSetName = $A.get("$Label.c.Core_MDF_PriceReviewers");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["priceReviewersPer"] = permissionSets;
       
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_RMF");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["rmfexternalper"] = permissionSets;
		
        var action = component.get("c.userHasPermissionSet");
        action.setParams({
            "permissionsets": userperMap
        });    
        $A.enqueueAction(action);
        component.set("v.showSpinner", true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
            component.set('v.userperMap','{}');
            component.set('v.userperMap',response.getReturnValue().userPermissions);
            component.set("v.isActivityReviewRequired", response.getReturnValue().isActivityReviewRequired);
            var mapResults = component.get("v.userperMap");

                for(var key in mapResults)
                {
                    component.set("v." + key,mapResults[key]);
                }
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
            //restrict activity creation(RMF External)
            if(component.get("v.isActivityCreationOnCampaign") == true && component.get("v.rmfexternalper") == true && component.get("v.externalper") == false){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: $A.get("$Label.c.Core_MDF_RMFExternalError"),
                        type: "error"
                       
                    });
                    toastEvent.fire();
                    component.find("navService").navigate({
                        "type": "standard__recordPage",
                        "attributes": {
                            "recordId": component.get("v.selectedLookUpRecord.Id"),
                            "objectApiName": "Campaign",
                            "actionName": "view"
                        }
                    });

				}
             if(component.get('v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c') !=null){
            var campReimbursement=component.get('v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c');
	}
        //Ayush - RR changes
           //Code to make 'Activity RR' field default to 50% for Proposal I MDF and 25% for Proposal II MDF if External User is creating an IPA Proposal based Activity
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
                && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true 
                && component.get("v.mode") == ''
              	&& helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c"))){
                    var reimburesmentRate = component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal I MDF' ? '50%' : component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal II MDF' ? '25%' : '';
                    component.set("v.SelReimbursementRate", reimburesmentRate);
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
            }
            
            //createActivityfromcampaign
            var localmsg = "";
       		var validData;
            var mode = component.get("v.mode");
            var budgetType = component.get("v.selBudgetType");
            var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
            var opalActBud = false;
            var alertMsg = $A.get("$Label.c.Core_MDF_No_Available_Budgets_Warning");
            var todayDate = helper.getTodayDateLocalTime();
            var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
            var budgetType = component.get("v.selBudgetType");
            var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
            if (mode == "" && (component.get("v.accmgrper") || component.get("v.externalper")) && component.get("v.isActivityCreationOnCampaign")) {
                      
                
                if(helper.isNotBlank(component.get("v.selectedLookUpRecord.Id"))){
                    
                    var endDate = component.get("v.selectedLookUpRecord.EndDate");
                    var startDate = component.get("v.selectedLookUpRecord.StartDate");
                    component.set("v.newPFR.Core_MDF_End_Date__c", endDate);
                    component.set("v.newPFR.Core_MDF_Start_Date__c", startDate);  
                    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
 						helper.checkAvailAllocationAmt(component);
                    }
                   
                    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") &&
                        component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false)
                    {
                        helper.fetchBudgetInfo(component);//called on loading of activity form
                    }
                    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
           				     helper.updateCountryPickVals(component);
          				}
                        if(component.get("v.priceReviewersPer")){ 
                             helper.hasIUPGMRecord(component);}
                    
                       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
		      			recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                       recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
                       recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") ||
                       recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost") ){
                        helper.activityPicker(component, recordTypeDeveloperName);
                    }
        if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
            var singlePriorityType = [];
            var multiplePriorityType = [];
            if (component.get("v.selectedLookUpRecord.Core_MDF_Priority__c") != null) {
                singlePriorityType.push({
                    key: component.get("v.selectedLookUpRecord.Core_MDF_Priority__c"),
                    value: component.get("v.selectedLookUpRecord.Core_MDF_Priority__c")
                });
            }
            if (helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Priority_2_nm__c")) ) {
                singlePriorityType.push({
                    key: component.get("v.selectedLookUpRecord.Core_MDF_Priority_2_nm__c"),
                    value: component.get("v.selectedLookUpRecord.Core_MDF_Priority_2_nm__c")
                });
            }
            if (helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Priority_3_nm__c"))) {
                singlePriorityType.push({
                    key: component.get("v.selectedLookUpRecord.Core_MDF_Priority_3_nm__c"),
                    value: component.get("v.selectedLookUpRecord.Core_MDF_Priority_3_nm__c")
                });
            }
            if (helper.isNotBlank(singlePriorityType) && singlePriorityType.length == 1) {
                component.set("v.PriorType", singlePriorityType);
                component.set("v.campriorityValue", false);
            } else {
                multiplePriorityType.push({
                    key: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: $A.get("$Label.c.Core_MDF_PFR_None_Translation")
                });
                if (helper.isNotBlank(singlePriorityType )) {
                    for (var i = 0; i < singlePriorityType.length; i++)
                        multiplePriorityType.push({
                            key: singlePriorityType[i].label,
                            value: singlePriorityType[i].value
                        });
                }
                component.set("v.PriorType", multiplePriorityType);
                component.set("v.campriorityValue", true);
            }
                  }
                     else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
                    else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                    }
                    
                }
               
               }
	       //Display Domain Type field only when Activity Category is Digital 2025
        let activityCategory = ($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory")) ? true : false
        if (helper.isNotBlank(activityCategory) && activityCategory){
            component.set("v.isDomainTypeVisible", true);
        } else {
            component.set("v.isDomainTypeVisible", false);
        }
		  if($A.get("$Label.c.Core_MDF_PFR_Retail") == component.get("v.recordtypeDeveloperName") && component.get("v.retailgeouserper") == true && component.get("v.accmgrper") == false && (component.get("v.recordId") == null || component.get("v.checkCloneAttribute")) ){
                if(component.get("v.checkCloneAttribute") == true){
                      var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error..!!",
                        message: $A.get("$Label.c.Core_MDF_CloneAccessError"),
                        type: "error"
                        
                    });
                    toastEvent.fire();
                    component.find("navService").navigate({
                        "type": "standard__recordPage",
                        "attributes": {
                            "recordId": component.get("v.recordId"),
                            "objectApiName": "PartnerFundRequest",
                            "actionName": "view"
                        }
                    });
                    
                }
                else{
                  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error..!!",
                        message: $A.get("$Label.c.Core_MDF_CloneAccessError"),
                        type: "error"
                        
                    });
                    toastEvent.fire();
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        scope: "PartnerFundRequest"
                    });
                    homeEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    
                }
                               
            }
            if(component.get("v.auditorper") || component.get("v.retailgeouserper") || 
              component.get("v.rsmActivityReviewerper")){
                component.set("v.isSaveandNewDisable",true);
            }
            if (!component.get("v.accmgrper") && !component.get("v.auditorper")
                && !component.get("v.externalper") && !component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper") && !component.get("v.ipaApproverPer") && !(component.get("v.priceReviewersPer") && component.get("v.componentAttributes.isLoggedInUserApprover"))) {
                component.set("v.userWithoutAccess",true);
            }
          if(component.get("v.opalAccountManagers")){                
                component.set("v.isLoggedInUserLevelOneApprover", true);
            }
            component.set("v.showSpinner", false);
        });
		//new edit
        if(component.get("v.mode") == 'edit'){
		if((((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") ||
		component.get("v.newPFR.Core_MDF_Program__c") == ($A.get("$Label.c.Core_MDF_IPA_Program_Name"))) &&
		component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) && 
			!helper.isCurrentUsrIsApprover(component) && 
			(component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' || 
			component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Approval' ||
            component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress Pending Review')) || 
   (helper.isCurrentUsrIsApprover(component) && component.get("v.ipaApproverPer") && component.get("v.ipaAcctMgr") == false && 
	component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") != 'Pending Review'))
            {var alertMsg = $A.get("$Label.c.Core_MDF_CloneAccessError");
             helper.displaySuccessErrorMsg(alertMsg, "Error!", "error"); // call common method to display error
             var sObectEvent = $A.get("e.force:navigateToSObject");
             sObectEvent .setParams({
                 "recordId": component.get("v.selectedLookUpRecord.Id"),
                 "slideDevName": "detail"
             });
             sObectEvent.fire(); 
            }
        }
        if(component.get("v.mode") == 'edit'){
		if(((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") ||
		component.get("v.newPFR.Core_MDF_Program__c") == ($A.get("$Label.c.Core_MDF_IPA_Program_Name"))) &&
		component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false) && 
			!helper.isCurrentUsrIsApprover(component) &&  helper.isCurrentUsrIsApprover(component)!= undefined &&
			(component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review'))
			{var alertMsg = $A.get("$Label.c.Core_MDF_CloneAccessError");
             helper.displaySuccessErrorMsg(alertMsg, "Error!", "error"); // call common method to display error
             var sObectEvent = $A.get("e.force:navigateToSObject");
             sObectEvent .setParams({
                 "recordId": component.get("v.newPFR.Id"),
                 "slideDevName": "detail"
             });
             sObectEvent.fire(); 
            }
        }
		   
        //Load the page with record values for Edit scenario
        if(helper.isNotBlank(component.get("v.recordId")) || 
           (component.get("v.checkCommunityAttribute") && helper.isNotBlank(component.get("v.communityRecordId"))) ||
           component.get("v.checkCloneAttribute") && helper.isNotBlank(component.get("v.checkCloneRecordId")))
        {
            component.set("v.showSpinner", true);
            var priorityType = [];
            
            if(component.get("v.checkCommunityAttribute")){
                component.set("v.recordId",component.get("v.communityRecordId"));               
            }
            if(component.get("v.checkCloneAttribute")){
                component.set("v.recordId",component.get("v.checkCloneRecordId"));
		component.set("v.mode", "clone");    
                
            }
            if(component.get("v.checkCloneAttribute")){
                component.set("v.checkStatusAttribute",false);
            }
            if(!component.get("v.checkCloneAttribute")) {
                component.set("v.mode", "edit");    
            }//not in QA
            var result;
            var actionLoadPfr = component.get("c.loadPFRRecord");
            actionLoadPfr.setParams({
                pfrId: component.get("v.recordId")
            });
            actionLoadPfr.setCallback(this, function (response) {
                result = response.getReturnValue();
                var state = response.getState();
                if (state === "SUCCESS") {
             	//[IPA MDF] - Campaign - Clone a Proposal - Activity Section - populate pfr details on edit of activity on ipa clone
                  if(component.get("v.pfrCloneCheck")){
                      var  fetchRec = component.get("v.pfrCloneOnCampaign");
                      for (var key in fetchRec) {
                          component.set("v.newPFR." + key, fetchRec[key]);
                      }
                      //component.set("v.metricCloneVal",component.get("v.newPFR.Core_MDF_Metrics_txt__c") );     //commented as part of IPA KPI Metrics changes  
                      component.set("v.newPFR.Id",component.get("v.recordId") );    
                       result = fetchRec;
                  }else{
                      result = response.getReturnValue();
                      component.set("v.newPFR", result);
                  }
                    if ((result.Core_MDF_Fund_Request_Status__c == 'Pending Review' || result.Core_MDF_Fund_Request_Status__c == 'Closed') && !component.get("v.checkCloneAttribute")) {
                        //alert('In doint 548');
                        helper.validateIfActivityInApproval(component);
                    }
		    var recordTypeDeveloperName = result.RecordType.DeveloperName;
                    component.set("v.showSpinner", false);
		    component.set("v.newPFR.Core_MDF_Metrics_Modified_ind__c",false);
                    component.set("v.newPFR.Core_MDF_SPIF_Modified_ind__c",false);
                    component.set("v.selectedLookUpRecord",result.Campaign);
                    component.set("v.selectedPartner.Id",result.ChannelPartnerId);
                    component.set("v.selectedPartner",result.ChannelPartner);
                    component.set("v.selectedLookUpRecord", result.Campaign);
                    if(helper.isNotBlank(result.Core_MDF_Opportunity_id__c) && component.get("v.externalper")==true && component.get("v.checkCloneAttribute") == true){
                        component.set("v.newPFR.Core_MDF_Opportunity_id__c",null);
                    }else{
                        component.set("v.newPFR.Core_MDF_Opportunity_id__c",result.Core_MDF_Opportunity_id__c);
                    }
                    //Make Attribution fields blank while cloning an activity
                    if (component.get("v.mode") == 'clone') {
              	    	component.set("v.newPFR.Core_MDF_Attribution_Variance_Pos_txt__c", null);
		    	component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
		    	//POP and Attribution Requiremnents Field blank on clone
                        component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                        component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
			}
                    
                    if(helper.isNotBlank(result.Core_MDF_NEX_Ind__c) && component.get("v.checkCloneAttribute") == true && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false ){
                        component.set("v.newPFR.Core_MDF_NEX_Ind__c",false);
                    }else{
                        component.set("v.newPFR.Core_MDF_NEX_Ind__c",result.Core_MDF_NEX_Ind__c);
                        component.set("v.nexInd",result.Core_MDF_NEX_Ind__c);
                    }
                    if(helper.isNotBlank(result.Core_MDF_Metrics_txt__c) && component.get("v.checkCloneAttribute") == true){
                        component.set("v.newPFR.Core_MDF_Metrics_txt__c",null);
                    }
                    

                    if(helper.isNotBlank(result.Core_MDF_Tactics_nm__c) && component.get("v.checkCloneAttribute") == true && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") ){
                        component.set("v.selectedTacticsOptions", Array.isArray(result.Core_MDF_Tactics_nm__c) ? result.Core_MDF_Tactics_nm__c : result.Core_MDF_Tactics_nm__c.split(';'));
					}

                    if(helper.isNotBlank(result.Campaign )){
                    component.set("v.cmpgnStatus", result.Campaign.Status);
                    }
                    component.set("v.BudgetLocal",result.Core_MDF_Budget_Amount_Local_amt__c);
                    component.set("v.budgetCurrency",result.Core_MDF_Budget_Currency_cd__c);
                    if(helper.isNotBlank(result.Core_MDF_Intel_Activity_Owner_Id__c) && helper.isNotBlank(result.Core_MDF_Intel_Activity_Owner_Id__r.Name)){
                    component.set("v.existingIntelOwner",result.Core_MDF_Intel_Activity_Owner_Id__r.Name);
                    }
                    
                    //var result;
                    if(helper.isNotBlank(result.Core_MDF_Member_Acceptor_Id__c) && helper.isNotBlank(result.Core_MDF_Member_Acceptor_Id__r.Name )){ 
					component.set("v.existingMemberActivityOwner", result.Core_MDF_Member_Acceptor_Id__r.Name);
                    component.set("v.existingMemberActivityOwnerId", result.Core_MDF_Member_Acceptor_Id__c);    
					}
                   
                   
                    
                     if(result.Core_MDF_Reimbursement_Rate_txt__c != null && result.Core_MDF_Reimbursement_Rate_txt__c != undefined &&component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                            component.set("v.ActReimbursementRt",result.Core_MDF_Reimbursement_Rate_txt__c);
                           	component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",result.Core_MDF_Reimbursement_Rate_txt__c);
                        }
                   
                     if(result.Core_MDF_Activity_Reimbursement_Amt_nbr__c != null && result.Core_MDF_Activity_Reimbursement_Amt_nbr__c != undefined &&component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                            component.set("v.IPAIntelContri",result.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                          	component.set("v.newPFR.Core_MDF_Activity_Reimbursement_Amt_nbr__c",result.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                        }
                     
                      
                    if(result.Core_MDF_Budget_Type_nm__c != null && ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && !result.Core_MDF_Proposal_Based_Ind__c)){
                        
                        component.set("v.selBudgetType",result.Core_MDF_Budget_Type_nm__c);    
                        //Set  allocation
                        component.set("v.newPFR.AllocationId",result.AllocationId);
                        if(result.Core_MDF_MDFReimbursement_Amt__c != null && result.Core_MDF_MDFReimbursement_Amt__c != undefined){
                            component.set("v.FlexiReimbursementAmt",result.Core_MDF_MDFReimbursement_Amt__c);
                            component.set("v.disableRRPercent",true);
                        }
                        if(helper.isNotBlank(result.BudgetId )){
                            component.set("v.selAvailableBudget",result.BudgetId);                            
                        } else{
                            component.set("v.selBudgetType",null); 
                        }
                      
                    }
                    if(helper.isNotBlank(result.Core_MDF_Exchange_Rate_ptc__c)  && component.get("v.checkCloneAttribute") == false){
                        component.set("v.createdDateClone",false);
                        component.set("v.budgetCurrencyOld",result.Core_MDF_Budget_Currency_cd__c);
                    }else if(component.get("v.checkCloneAttribute") == true || result.Core_MDF_Exchange_Rate_ptc__c == null){
                        component.set("v.createdDateClone",true);
                        helper.calculateBudgetAmount(component,component.get("v.newPFR"));
                    }
                   if(helper.isNotBlank(result.Core_MDF_Activity_Classification_nm__c)){
                         component.set("v.selActivityClassification",result.Core_MDF_Activity_Classification_nm__c);
                   }      
                   component.set("v.SelActivityType",result.Core_MDF_Activity_Types__c);
                    component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", result.Core_MDF_Other_Event_Name_txt__c);
                    component.set("v.selActivityEventName", result.Core_MDF_Event_Name_nm__c);
                    component.set("v.SelCategory",result.Core_MDF_ActivityCategory__c);
                    component.set("v.SelProductType",result.Core_MDF_ProductType__c);
                    component.set("v.SelPriority",result.Core_MDF_Priority_nm__c);
                    component.set("v.selectedFocusArea",result.Core_MDF_Focus_Area_nm__c);
                    component.set("v.SelOtherChannelPartner",result.Core_MDF_Other_Channel_Partner__c);
                    component.set("v.CPLed",result.Core_MDF_Channel_Partner_Led__c);
                    component.set("v.JointContent",result.Core_MDF_Joint_Content_ind__c); 
                    component.set("v.SelMarketValue",result.Core_MDF_Country_nm__c); 
                    component.set("v.SelReimbursementRate",result.Core_MDF_Reimbursement_Rate__c); //Reimbursement Rate assignment
                    component.set("v.SelDomainType",result.Core_MDF_Domain_Type_nm__c);
                    //Outcome Based changes - show classification field on load of component
                    if(!$A.util.isEmpty(component.get("v.selectedTacticsOptions")) && component.get("v.selectedTacticsOptions") != undefined){
                        component.set("v.isShowClassificationField", true);
                    } 
		    //Read only "Strategic Marketing Fund" checkbox inheriting values from Campaign
                  
                      component.set("v.IsStrategicMarketingFundVisible", false);
                   
		    //Read only "Strategic Marketing Fund" checkbox inheriting values from Campaign end
                    var selCategory = component.get("v.SelCategory");
                    var selActiType = component.get("v.SelActivityType");
                    var setBudgType = component.get("v.selBudgetType");
                    if (((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ) && selCategory == 'Event' && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) || ((component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") || component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")) && selActiType != 'Promotion')) {
                        component.set("v.hideCompetitiveQuest", true); 
                    }
                    else{
                        component.set("v.hideCompetitiveQuest", false); 
                    }
		    //OPAL Past Dated Activity Submission process
                    var today = helper.getTodayDateLocalTime();
                    var start_date = component.get("v.newPFR.Core_MDF_Start_Date__c");
                    var budgetType = component.get("v.selBudgetType");
                    var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
					var mode = component.get("v.mode");
                   if(!component.get("v.externalper")){
                       
                            component.set("v.SelPotentialReason", null);
                        
                    }
					//Retail Changes - to show Reason for past dated field when RSM is cloning the past dated activity
                    if(mode == 'clone'){
                        if (start_date < today  && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) {
                            component.set("v.IsPR", true);
                        } else {
                            component.set("v.IsPR", false);                            
                        }
                    }
                    helper.checkIsApproverActive(component);
					
                 //[IPA MDF] - Campaign - Clone a Proposal - Activity Section - warning of spif section
					if(component.get("v.pfrCloneCheck")){
                        var activityTyp =  component.get("v.SelActivityType");
                        if(activityTyp !=  "" && activityTyp != null && activityTyp != undefined){
                        var spifActivityTyps = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
                        //Outcome Based changes - Added Or condition to show warning on proposal clone
                        if(spifActivityTyps.includes(activityTyp) || helper.checkSPIFTactics(component)) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'dismissible',
                               
                               title: "Warning..!!",
                                message: $A.get("$Label.c.Core_MDF_Complete_SPIF_Warning"),
                                type: "warning",
                                duration:' 7000'
                            });
                            toastEvent.fire();
                        }
                    }
                    }
                    
                    if(component.get("v.isOpalActivity")){
                        component.set("v.CPLed", true);
                        component.set("v.SelReimbursementRate",result.Core_MDF_Reimbursement_Rate_txt__c);
                        component.set("v.doInitCheck",true);
                       if (component.get("v.checkCloneAttribute")) {
                            if(component.get("v.externalper") == true){
                                component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
                            }
  						}
						 //[Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
                     
                       component.set("v.SelOtherChannelPartner",result.Core_MDF_Other_Channel_Partner__c);
                     
                    }
                    component.set("v.selectedEventFormat", result.Core_MDF_Event_Format_Nm__c); // Event Format Data
                    if (component.get("v.checkCloneAttribute")) {
                        component.set("v.isAdditionalReviewReqd",false); 
                    }else{
                        component.set("v.isAdditionalReviewReqd",result.Core_MDF_Require_Additional_Review_ind__c); 
                    }
                    //OPAL Budget Type Changes for CCF and DCF Programs starts
		    // New Budget Type field changes replaced txt field with new global picklist field
                    if(helper.isNotBlank(result.Core_MDF_Budget_Type_nm__c) && (helper.isNotBlank(component.get("v.recordtypeDeveloperName"))&&(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF")))){
                       
                  
                  /* OPAL change start - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
                  if(component.get("v.checkCloneAttribute") || helper.isNotBlank(component.get("v.recordId"))) {
                      //helper.populateActCatType(component, event, helper);
                  }
                  
                  /* OPAL change end - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
              }
                    //OPAL Budget Type Changes for CCF and DCF Programs ends
					
					  
                     if (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                        component.set("v.selectedLookUpRecord.Core_MDF_Account__r.Name", result.ChannelPartner.Name);
			//New Budget Type field changes replaced txt field with new global picklist field
                        component.set("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c", result.Core_MDF_Budget_Type_nm__c);
			component.set("v.oldstatus", result.Core_MDF_Fund_Request_Status__c);
                         //BU Split - assign backend values of BU split to fields - start
                      component.set("v.newPFR.Core_MDF_BU1_Split_Percent_nbr__c", result.Core_MDF_BU1_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU2_Split_Percent_nbr__c", result.Core_MDF_BU2_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU3_Split_Percent_nbr__c", result.Core_MDF_BU3_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU4_Split_Percent_nbr__c", result.Core_MDF_BU4_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU5_Split_Percent_nbr__c", result.Core_MDF_BU5_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU6_Split_Percent_nbr__c", result.Core_MDF_BU6_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU7_Split_Percent_nbr__c", result.Core_MDF_BU7_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU8_Split_Percent_nbr__c", result.Core_MDF_BU8_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU9_Split_Percent_nbr__c", result.Core_MDF_BU9_Split_Percent_nbr__c);
                      component.set("v.newPFR.Core_MDF_BU10_Split_Percent_nbr__c", result.Core_MDF_BU10_Split_Percent_nbr__c);
                      var selectedBU = [];
                      var avlList = [];
                      var metaBuList = [];
                      for(let i =0; i<selectedBU.length;i++ ){
                          avlList.push(selectedBU[i]);                           
                      }
                      component.set("v.defaultBU",avlList);
                      component.set("v.buSplitSelectedList",  component.get("v.defaultBU"));
                      //BU Split - assign backend values of BU split to fields -- end          
                        } else if ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") ||component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF")) 
                        && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
                        component.set("v.campriority",result.Core_MDF_Priorities__c);
                        priorityType.push({
                            key  :  result.Core_MDF_Priorities__c,
                            value:  result.Core_MDF_Priorities__c
                        });
                        
                        if( helper.isNotBlank(result.Campaign.Core_MDF_Priority__c)&&
                           result.Campaign.Core_MDF_Priority__c != result.Core_MDF_Priorities__c){
                            priorityType.push({
                                key  : result.Campaign.Core_MDF_Priority__c,
                                value: result.Campaign.Core_MDF_Priority__c
                            });
                        }
                        if( helper.isNotBlank(result.Campaign.Core_MDF_Priority_2_nm__c) &&
                           result.Campaign.Core_MDF_Priority_2_nm__c != result.Core_MDF_Priorities__c){
                            priorityType.push({
                                key  : result.Campaign.Core_MDF_Priority_2_nm__c,
                                value: result.Campaign.Core_MDF_Priority_2_nm__c
                            });
                        }
                        if(helper.isNotBlank(result.Campaign.Core_MDF_Priority_3_nm__c) &&
                           result.Campaign.Core_MDF_Priority_3_nm__c != result.Core_MDF_Priorities__c){
                            priorityType.push({
                                key  : result.Campaign.Core_MDF_Priority_3_nm__c,
                                value: result.Campaign.Core_MDF_Priority_3_nm__c
                            });
                        }
                        component.set("v.PriorType",priorityType);
                        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                        component.set("v.selectedLookUpRecord.Core_MDF_Account__r.Name", result.ChannelPartner.Name);
                        //New Budget Type Field changes
                        component.set("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c", result.Core_MDF_Budget_Type_nm__c);
                        //subtype single select
                        component.set("v.selActivitySubType", result.Core_MDF_Activity_SubType_nm__c);
 						}
                    }else
                    {
                        if(helper.isNotBlank(result.Campaign)){
                        component.set("v.selectedLookUpRecord.Core_MDF_Priority__c",result.Campaign.Core_MDF_Priority__c);
                         //DE119138: WW27 | QA3 | System is throwing Component error when user is trying to edit an Activity, for which user is not having Access for Campaign for CCF 1.0 & DCF 1.0
                          if(result.Campaign.Core_MDF_Priority__c == undefined && (result.Core_MDF_Budget_Type_nm__c == 'CCF 1.0' || result.Core_MDF_Budget_Type_nm__c == 'DCF 1.0') ){ 
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: "Error..!!",
                                message: $A.get("$Label.c.Core_MDF_NoCampaign_Access_Error"),
                                type: "error"
                              
                            });
                            toastEvent.fire();
                            var navLink = component.find("navService");
                            var pageRef = {
                                type: 'standard__recordPage',
                                attributes: {
                                    actionName: 'view',
                                    objectApiName: 'PartnerFundRequest',
                                    recordId : component.get("v.recordId") // change record id. 
                                },
                            };
                            navLink.navigate(pageRef, true);
                        }
                    }
                    }
                    // Make Sure there is no dependencies Status for Clone
                    if(component.get("v.checkCloneAttribute") == false){
                        component.set("v.CurrentStatus",result.Core_MDF_Fund_Request_Status__c);
			//OPAL Changes - Added extra condition not to display Closed Activity Error for OPAL Activities
                        if(component.get("v.CurrentStatus") == 'Closed' && component.get("v.accmgrper") == false && component.get("v.externalper") == false
                          && (component.get("v.retailgeouserper") == false && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_Retail")) && !component.get("v.isOpalActivity")&&(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.isPropBasedCampaign") == true )){
                            component.set("v.isClosedActivity",true);
                            component.set("v.closeError",$A.get("$Label.c.Core_MDF_Close_Activity_Error"));
                        }
                        
                        
                        var getoptionMap = component.get("v.apitoLabelConvert");
                        for(var key in getoptionMap ){
                            if(key = component.get("v.CurrentStatus")){
                                component.set("v.CurrentStatusLabel", getoptionMap[key]);
                                break;
                            }
                        }
                    }
                    else {
                        //Variable Reimbursement Rate changes - handle clone scenario
                        component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
                        component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
                    }
                    
                    
                    if (result.Core_MDF_Channel_Partner_Led__c == true)
                    {
                        component.set("v.IsCP",true);
                        helper.enabledisablecpled(component,false);
                    }
                    else{
                        helper.EnableCPCheckBox(component,event);
                    }
                    
                  if (result.Core_MDF_Channel_Partner__c == "Others" && !component.get("v.isOpalActivity")){
                      component.set("v.IsOtherCP", true);
                   }
                    
                    recordType = result.RecordType.Name;
                    startdate  = result.Core_MDF_Start_Date__c;
                    enddate    = result.Core_MDF_End_Date__c;
                   
                    component.set("v.recordtypeName",recordType);
                    component.set("v.recordtype",result.RecordTypeId);
                    component.set("v.recordtypeDeveloperName",recordTypeDeveloperName);
                 
                    helper.constructadditionalfilter(component, startdate, enddate,recordTypeDeveloperName);
                   if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
                    else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                    }
                    component.set("v.oldbudget", result.RequestedAmount);
                    component.set("v.oldcategory", result.Core_MDF_ActivityCategory__c);
                    component.set("v.oldstatus", result.Core_MDF_Fund_Request_Status__c);
                    component.set("v.oldsdate", result.Core_MDF_Start_Date__c);
                    component.set("v.oldedate", result.Core_MDF_End_Date__c);
                    component.set("v.ChgndAttach",false);
                    component.set("v.oldActivtyType",result.Core_MDF_Activity_Types__c);
                    component.set("v.oldCampaignId",result.CampaignId);
		    component.set("v.approvalStage", result.Core_MDF_Approval_Stage__c);
                    //Variable Reimbursement Rate - stamp old prod type and brand values
                    component.set("v.oldProdType", result.Core_MDF_ProductType__c);
                    component.set("v.oldBrandMulti", result.Core_MDF_Brand_nm__c);
                    component.set("v.activityClosureType",result.Core_MDF_Activity_Closure_Type__c);
                    //Attributes for the Currency validation
					if(helper.isNotBlank(result) && helper.isNotBlank(result.ChannelPartner.Id) && component.get("v.mode") == 'edit'){
                        result.ChannelPartnerId = result.ChannelPartner.Id;
                    }
                    
                    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true){
		               component.set("v.approvalStage", result.Campaign.Core_MDF_Approval_Stage_nm__c);
			         }else{
		    component.set("v.approvalStage", result.Core_MDF_Approval_Stage__c);
			         }
                    //Gayathri-Check if the User has Dual Role(IPA Account Manager+Price reviewer).
                    if (component.get("v.ipaAcctMgr") && component.get("v.priceReviewersPer") && 
                    component.get("v.approvalStage") == "Price Reviewer" &&
                    component.get("v.newPFR.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Program_Name") &&
                    component.get("v.CurrentStatus") == "Pending Review") {
                    helper.setIPADualRoleEditability(component);
                    }
                    var newObject = new Object;
                    //Ayush - added sanitize method for semgrep fix.
                    var mergedObject = Object.assign(newObject, helper.sanitizeResults(result));
                    component.set("v.oldPFR", mergedObject);
//For IPA L2 Approver -To check for IUPGM 
                    var ipaL2Approver = component.get("v.ipaL2Approver");
                    var ipaApproverPer = component.get("v.ipaApproverPer");
                    var status = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
                    
                    if(ipaL2Approver && status == 'Pending Review'){
                       helper.isRecordApprover(component); 
                        
                    }
                    
                    if(component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c") == undefined && component.get("v.isOpalActivity")){
                        component.set("v.oldPFR.Core_MDF_Activity_SubType_nm__c", []);
                    }                    
					//OPAL Changes Start
					 component.set("v.recordtypeDeveloperName",recordTypeDeveloperName);
					if(component.get("v.isOpalActivity") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
						helper.updateCountryPickVals(component);
					}
                    if(component.get("v.priceReviewersPer")){ 
            helper.hasIUPGMRecord(component);}
                    // Set the controls disabled property for edit mode based on the criteris defined
                    if(component.get("v.checkCloneAttribute") == false){
                        
                         if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                            if(!ipaL2Approver && !ipaApproverPer){
                            helper.setSaveBtnVisibility(component); /* [IPA] Disable save & New and Save buttons */
                            //helper.setIPAApproverDisabledState(component);
                            }
                        }  
                        helper.SetAccMgrDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName );
                        helper.SetExternalDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                        //helper.SetAuditorDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                        //To Enable Edit acces for GEO Leads
                        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.retailgeouserper") == true && !(component.get("v.accmgrper") && component.get("v.retailgeouserper"))){
                            helper.checkGeoLeadsEditAccess(component);
                        }
						
						
			
                        helper.setPriceReviewerDisableState(component, event); 
			
                    }
                                  		    
		    
		    //Set opal approver as true if he field & marketing owner & is present in the list of approver 1 to 10 fields
		   
                    if(component.get("v.checkCloneAttribute")){
                        component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
                        component.set("v.newPFR.Core_MDF_Approver_1__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_2__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_3__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_4__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_5__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_6__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_7__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_8__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_9__c", null);
                        component.set("v.newPFR.Core_MDF_Approver_10__c", null);
						//Clear ATF ind, while clone
                        component.set("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c",false);    
                        component.set("v.newPFR.Core_MDF_ATF_Approval_Reqd_ind__c",false);   
                        component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",'');
                    }
		    if(component.get("v.opalAccountManagers") && component.get("v.isOpalActivity") && 
                     component.get("v.recordId") != null && !component.get("v.checkCloneAttribute")){
                      var curUserId = $A.get("$SObjectType.CurrentUser.Id");
                      var usrIsApprover = false;
                      var approverSet = new Set();
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_1__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_2__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_3__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_4__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_5__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_6__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_7__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_8__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_9__c"));
                      approverSet.add(component.get("v.newPFR.Core_MDF_Approver_10__c"));
                      if (approverSet != null && curUserId != null && approverSet.has(curUserId) &&
                         component.get("v.newPFR.Core_MDF_Approval_Step_Completed__c") == 0) {
                          component.set("v.isOPALApprover", true);
                          
                      }
                  }


		    /* OPAL changes for US910496 starts */
                    if(component.get("v.isOpalActivity") && (component.get("v.checkCloneAttribute") || component.get("v.recordId")!=null )){
                        helper.populateActCatType(component, event, helper);
                    }
		    /* OPAL changes for US910496 ends */
                }
                else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
                if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")&& (component.get("v.checkCloneAttribute") || component.get("v.recordId")!=null )){
                    helper.hideOtherActTypeForExternalUser(component, event, helper);
                }
               
            });
            
            $A.enqueueAction(actionLoadPfr);
        } else {
            component.set("v.checkStatusAttribute",false);
            //Render page for new record scenario
            //fetch the selected record type
            
            var disablemap = component.get("v.disabledMap");
            if (disablemap == null)
            {
                var mapVar = [];
                mapVar = {
                    'cpled': true
                };
                component.set("v.disabledMap",mapVar);
            }
            else
            {
                component.set("v.disabledMap.cpled",true);
            }
            
            var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
            recordType = component.get("v.recordtypeName");
            startdate = null;
            enddate = null;
            helper.constructadditionalfilter(component, startdate, enddate, recordTypeDeveloperName);            
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
            else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                    }
             
        }
        
       if(component.get("v.isActivityLayout") && helper.isNotBlank(component.get("v.selectedLookUpRecord"))){
            helper.fetchCampBudgetInfo(component, event, helper, true);
        }
        
        helper.loadFieldsetFields(component);
	
        component.set("v.startDate",component.get("v.newPFR.Core_MDF_Start_Date__c"));
         recordTypeDeveloperName = component.get("v.recordtypeDeveloperName") ;
        
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")|| component.get("v.newPFR.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Program_Name") || component.get("v.newPFR.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_Retail_Program_Name") ){
            component.set("v.checkfileuploadcondition", true);
    }    }, 
    
    resetActivtyType:function(component, event, helper){
        var mode = component.get("v.mode");        
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
	component.set("v.showKPISpinner", true); //onchange of activity category spinner is on
        component.set("v.SelActivityType",null);
        component.set("v.newPFR.Core_MDF_ofPagesEligible__c",'0');
        component.set("v.newPFR.Core_MDF_pagespayingfor__c",'0');
        component.set("v.newPFR.Core_MDF_Government_Nexus__c","No");
        component.set("v.newPFR.Core_MDF_Competitive_Elements__c","No");
        component.set("v.isSPIFSecAvailable",false);
        component.set("v.selActivityEventName", null);
        component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", null);
        component.set("v.isDomainTypeVisible", false);
	component.set("v.SelDomainType",null);
        helper.resetHelper(component);
        helper.fetchActType(component);
        
        if (!($A.util.isEmpty(component.get("v.SelCategory")))) {
        if (($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory"))) {
            component.set("v.isDomainTypeVisible", true);
        }
        //Outcome Based changes - Visibility of tactics multiselect based on category selected
        if(component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
            component.set("v.showActTactics",true); 
        }else{
            component.set("v.showActTactics",false);
            component.set("v.selectedTacticsOptions",null); 
        }
        }
        
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
         else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                    }
        
	//onchange of activity category spinner is off
	
        window.setTimeout(
            $A.getCallback(function() {
               component.set("v.showKPISpinner", false);
            }), 3000
        );
    },
    
    resetBrand:function(component, event, helper){
        //Variable Reimbursement Rate changes
        helper.resetHelper(component);
    },
    
    //Variable Reimbursement Rate changes
    resetonBrandChange: function (component, event, helper) {
        helper.resetHelper(component);
    },
    
    resetActTypeDepAttributes:function(component, event, helper){
        
        //this to reset the activity sub type value on chage of activity type
        var spifActivityTypes = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
        var activityType = component.get("v.SelActivityType");
        //POP and Attribution Requirements changes for visiblity of field
        var otherActTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");  
        if(helper.isNotBlank(activityType) && helper.isNotBlank(otherActTypes) && otherActTypes.split(",").includes(activityType)){
            if(component.get("v.externalper") == true){
                if(component.get("v.mode") != "edit"){
                    component.set("v.isAttributionReqVisible", false);
                    component.set("v.isPOPReqVisible", false);
                }
                else if(component.get("v.mode") == "edit"){
                    if(helper.isNotBlank("v.newPFR.Core_MDF_Attribution_Requirements_txt__c")){
                        component.set("v.isAttributionReqVisible", true);
                    }
                    if(helper.isNotBlank("v.newPFR.Core_MDF_POP_Requirements_txt__c")){
                        component.set("v.isPOPReqVisible", true);
                    }
                }
            }
            else{
                component.set("v.isAttributionReqVisible", true);
                component.set("v.isPOPReqVisible", true);
            }
        }
        else{
            component.set("v.isAttributionReqVisible", false);
            component.set("v.isPOPReqVisible", false);
        }
	component.set("v.popVisible", false);
        component.set("v.isSPIFSecAvailable",false);
      
	component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",false);
      
       
        if(component.get("v.oldPFR")!=undefined && component.get("v.oldPFR")!=null){
         	if(component.get("v.oldActivtyType") != component.get("v.SelActivityType"))
           {
                 component.set("v.isActivityTypeChanged",true);
                 component.set("v.selActivitySubType", null);
                 component.set('v.newPFR.Core_MDF_Activity_SubType_nm__c',null);
                 component.set("v.selActivityEventName", null);
                 component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", null);
                 component.set("v.selectedSubTypeOptions", null);
                 //POP and Attribution Requirements for external need to retain value if we change activity catagory/type, for internal we have to clear out
                 if(component.get("v.externalper") != true){
                    component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                    component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
                 }
           }else{
               if(component.get("v.oldPFR")!=undefined && component.get("v.oldPFR")!=null && component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c") &&
                 component.get("v.newPFR.Core_MDF_Activity_SubType_nm__c") && component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c")!= component.get("v.newPFR.Core_MDF_Activity_SubType_nm__c")){
               	component.set("v.selectedSubTypeOptions", component.get("v.newPFR.Core_MDF_Activity_SubType_nm__c"));
               }else
               {
                   component.set("v.selectedSubTypeOptions", []);
                   if(component.get("v.isActivityTypeChanged")){
                      component.set("v.selActivityEventName", null);
                      component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", null);
                      //POP and Attribution Requirements for external need to retain value if we change activity catagory/type, for internal we have to clear out
                      if(component.get("v.externalper") != true){
                        component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                        component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
                      }
                   }

               }
           }
        }
        else{
            component.set("v.selActivityEventName", null);
            component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", null);
				component.set("v.selActivitySubType", null);
				component.set("v.selectedSubTypeOptions", null);
				component.set('v.newPFR.Core_MDF_Activity_SubType_nm__c',null);
				//POP and Attribution Requirements for external need to retain value if we change activity catagory/type, for internal we have to clear out
                		component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                		component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
			}
        helper.fetchEventFormat(component);
        //this to fetch the activity subtype on the basis of selected act type
        helper.fetchActSubTypeMulti(component);             
        helper.fetchEventName(component);
        helper.fetchActClassification(component);
        helper.resetHelper(component);
        //to check whether to dispaly Segment SPIF Activity Questions section or not
        window.setTimeout(
            $A.getCallback(function() {   
                if($A.get("$Label.c.Core_MDF_POP_RecordTypes").includes(component.get("v.recordtypeDeveloperName"))) {
                    if(component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
                    component.set("v.popVisible", true);    
                }
                    if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && !component.get("v.activitySubTypeAvailable"))){
                    component.set("v.popVisible", true);  
                    }   
                }
                helper.checkSPIFActSecVisible(component);
            }), 100
        );
        // if rectype = RMF OR recType = RMF and no subtype available for selected Type
        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
               && !component.get("v.activitySubTypeAvailable"))) { //changes for KPI Metrics
            //call to KPI component
            if(component.get("v.SelActivityType") != null) {
                component.set("v.showKPISpinner", true);
            }
            helper.getKPIAttributes(component);
        }
        //Mohit - Commented as a part of defect where user was able to submit proposal without SPIF Section
        /*if(component.get("v.mode") == 'edit' && spifActivityTypes.includes(activityType)){
           component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",true);
		}*/
    },
    //Outcome Based Changes - aura handler on change of tactics field
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
            component.set("v.isShowClassificationField", true);
            var marketingTactics = $A.get("$Label.c.Core_MDF_Marketing_Act_Tactis").split(',');
            var actClassificationOptns = $A.get("$Label.c.Core_MDF_PFR_Activity_Classification").split(',');
            var actClassification = [];
            for(var index=0;index<actClassificationOptns.length;index++){
                actClassification.push({
                    class: "optionClass",
                    label: actClassificationOptns[index],
                    value: actClassificationOptns[index]
                }); 
            }
            component.set("v.activityClassificationValues",actClassification);
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

        //Ayush - Tactic Metrics changes
        if(!$A.util.isEmpty(selectedTacticsOptions) && selectedTacticsOptions != undefined) {
            var lwcTacticMetricsComp = component.find("tacticMetrics");        
            var tacticMetricsValues;var isTacticMetricsModified;
            if (lwcTacticMetricsComp != null) {
                if(helper.isNotBlank(lwcTacticMetricsComp[0])){
                    tacticMetricsValues = lwcTacticMetricsComp[0].handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                    //isTacticMetricsModified = lwcTacticMetricsComp[0].isTacticMetricsModified();
                }else{
                    tacticMetricsValues = lwcTacticMetricsComp.handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                    //isTacticMetricsModified = lwcTacticMetricsComp.isTacticMetricsModified();
                }
               
            }
            
        }
        
    },
    //call to KPI component
    getKPIAttributes: function (component, event, helper) {
        // Subtype dependancy only for RMF
        component.set("v.popVisible", false);
        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && ((!$A.util.isEmpty(component.get("v.SelActivityType")) && !component.get("v.activitySubTypeAvailable")) || 
                        (component.get("v.activitySubTypeAvailable") && component.get("v.selectedSubTypeOptions") != '' 
                         && component.get("v.selectedSubTypeOptions") != null && !$A.util.isEmpty(component.get("v.selectedSubTypeOptions"))))) { //changes for KPI Metrics
            if(component.get("{!v.selectedSubTypeOptions}") != null) {
                component.set("v.popVisible", true);
                component.set("v.showKPISpinner", true);
            }
            helper.getKPIAttributes(component);
        }
    },
    
    onEventNameChange: function (component, event, helper) {
        // if Event Name is "Other", then show Other Event field
        var eventName = component.get("v.selActivityEventName");
        if(eventName == $A.get("$Label.c.Core_MDF_Other_Localized")){
            component.set("v.showOtherEventName", true);
        }else{
            component.set("v.showOtherEventName", false);
            component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", null);
        }
    },
    
    handleOtherEvent: function (component, event, helper) {
        var value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", value);
    },
    handleLeadQuantityChange: function (component, event, helper) {
        var value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Lead_Quantity_nbr__c", value);
        if(!$A.util.isEmpty(value) && (value <= 0 || !Number.isInteger(parseFloat(value)))){
           component.set("v.showNegativeInputError", true);
        }
        else{
            component.set("v.showNegativeInputError", false);
        }
    },
    
    handleDeploymentQuantityChange: function (component, event, helper) {
        var value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Deployment_Quantity_nbr__c", value);
          if(!$A.util.isEmpty(value) && (value <= 0 || !Number.isInteger(parseFloat(value)))){
           component.set("v.showNegativeInputError", true);
        }
        else{
            component.set("v.showNegativeInputError", false);
        }
    },
    handleOtherQuantityChange: function (component, event, helper) {
        var value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Other_Quantity_nbr__c", value);
          if(!$A.util.isEmpty(value) && (value <= 0 || !Number.isInteger(parseFloat(value)))){
           component.set("v.showNegativeInputError", true);
        }
        else{
            component.set("v.showNegativeInputError", false);
        }
    },
    // Function called from the change event handler to reset popup and file upload attributes
    //----Rishabh
    /*resetpopupattributes: function(component, event, helper) {
        helper.resetHelper(component);
    },*/
    // Function called on the change Account change
    resetAccountattributes : function(component, event, helper){
        if(component.get("v.selectedPartner") == null || component.get("v.selectedPartner").Id == null){
            
            component.set("v.newPFR.ChannelPartnerId",null);
        } 
        else{
            
            component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedPartner").Id );
        }
        if(component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.isActivityCreationOnCampaign")){
            component.set("v.newPFR.Core_MDF_Start_Date__c",component.get("v.selectedLookUpRecord.StartDate"));
            component.set("v.newPFR.Core_MDF_End_Date__c",component.get("v.selectedLookUpRecord.EndDate"));
        }
        
	 helper.hasIUPGMRecord(component);
	 if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
	 helper.checkAvailAllocationAmt(component);
        }
    },
    // Function called on the picklist fields
    resetPicklistValues:function(component, event, helper){
         helper.loadFieldsetFields(component);
        if(component.get("v.apitoLabelConvert") == null){
            var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
            var fieldlist = fields.split(",");
            helper.convertApitoLable(component,fieldlist);
        }
        if(component.get('v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c') !=null){
            var campReimbursement=component.get('v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c');
            
            
        }
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        if(component.get("v.ActReimbursementRt") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ){
            var actReimbursement=component.get("v.ActReimbursementRt");
            component.set('v.newPFR.Core_MDF_Reimbursement_Rate_txt__c',actReimbursement);
        }
        //Code to make 'Activity RR' field default to 50% for Proposal I MDF and 25% for Proposal II MDF if External User is creating an IPA Proposal based Activity
       /* if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
            && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true 
            && component.get("v.externalper") == true && component.get("v.mode") == ''
            && helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c"))){
                var reimburesmentRate = component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal I MDF' ? '50%' : component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal II MDF' ? '25%' : '';
                component.set("v.SelReimbursementRate", reimburesmentRate);
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
        }*/
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
           && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true 
           && component.get("v.mode") == '' 
           && helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c"))){
                var reimburesmentRate = component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal I MDF' ? '50%' : component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal II MDF' ? '25%' : '';
                component.set("v.SelReimbursementRate", reimburesmentRate);
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
        }
        component.set("v.recordtypeDeveloperName",recordTypeDeveloperName);
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                helper.updateCountryPickVals(component);  
            }
        var selCountry = component.get("v.selectedCountryOptions");
        if((component.get("v.oldCampaignId") != component.get("v.selectedLookUpRecord.Id"))){
            helper.accPropCampType(component);
	    /*OPAL change - start - onchange of campaign - from opal to non opal - updating picklist values */
	    if(component.get("v.oldCampaignId") != null && component.get("v.oldCampaignId") != '') {
           if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.isPropBasedCampaign")==false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
             else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") &&( component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true|| component.get("v.isPropBasedCampaign"))){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                    }
			else {
				helper.activityPicker(component, recordTypeDeveloperName);
			}
         }
          else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
             else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                    }
	    /*OPAL change - end*/
            
        }
        if(   
            ( recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_IPA_RecordType"))
            && (
                (
                    (component.get("v.selectedLookUpRecord.Id") != null && component.get("v.selectedLookUpRecord.Core_MDF_Supports_legacy_program__c") != undefined && component.get("v.selectedLookUpRecord.Core_MDF_Supports_legacy_program__c") != 'Yes')
                    &&
                    (
                        component.get("v.selBudgetType") == null || component.get("v.selBudgetType") == ''
                    ) 
                )
                || component.get("v.selectedLookUpRecord.Id") == undefined
                || component.get("v.selectedLookUpRecord.Id") ==null 
            )
        ){
            //[OPAL CCF/DCF] - Available Budgets Field at Activity
         
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
                        
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    }
            else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                       
                        helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                		
                    }
            
        }
		// OPAL changes end
        if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
            var singlePriorityType = [];
            var multiplePriorityType =[];
            if(component.get("v.selectedLookUpRecord.Core_MDF_Priority__c") != null){
                singlePriorityType.push({
                    key  : component.get("v.selectedLookUpRecord.Core_MDF_Priority__c"),
                    value: component.get("v.selectedLookUpRecord.Core_MDF_Priority__c")
                });
            }
            if(component.get("v.selectedLookUpRecord.Core_MDF_Priority_2_nm__c") != null){
                singlePriorityType.push({
                    key  : component.get("v.selectedLookUpRecord.Core_MDF_Priority_2_nm__c"),
                    value: component.get("v.selectedLookUpRecord.Core_MDF_Priority_2_nm__c")
                });
            }
            if(component.get("v.selectedLookUpRecord.Core_MDF_Priority_3_nm__c") != null){
                singlePriorityType.push({
                    key  : component.get("v.selectedLookUpRecord.Core_MDF_Priority_3_nm__c"),
                    value: component.get("v.selectedLookUpRecord.Core_MDF_Priority_3_nm__c")
                });
            }
            if(singlePriorityType.length==1){
                component.set("v.PriorType",singlePriorityType);
                component.set("v.campriorityValue",false);
                
            }
            else
            {
                multiplePriorityType.push({
                    key : $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value : $A.get("$Label.c.Core_MDF_PFR_None_Translation")
                });
                if (singlePriorityType != null) {
                    for (var i = 0; i < singlePriorityType.length; i++)
                        multiplePriorityType.push({
                            key: singlePriorityType[i].label,
                            value: singlePriorityType[i].value
                        });                
                    
                }
                component.set("v.PriorType",multiplePriorityType);
                component.set("v.campriorityValue",true);
            }
            
            if (component.get("v.selectedLookUpRecord.Core_MDF_Account__c") != null && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                component.set("v.selectedPartner", component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Name"));                
            }
            else if(component.get("v.selectedLookUpRecord.Core_MDF_Account__c") != null && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0'){
                component.set("v.selectedPartner.Name", component.get("v.selectedPartner.Name"));
            }    
        }

        //Read only "Strategic Marketing Fund" checkbox inheriting values from Campaign

            component.set("v.IsStrategicMarketingFundVisible", false);
        
        if (component.get("v.selectedLookUpRecord.Id") != null && component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__c != undefined) {
          
        component.set("v.programName",component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__r.Name);
        var country=component.get("v.SelMarketValue"); 
        helper.getIndustryPartners(component, country);
        }
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){
              helper.checkAvailAllocationAmt(component);  
              helper.fetchBudgetInfo(component);//on reset of picklist
        }
    },
    
    //Method to set selected country values and reset CPLed
    setCtryResetCPLed : function(component,event,helper){
        
        component.set('v.CPLed',false);
        helper.EnableCPCheckBox(component,event);
        
        var selctryLst = component.get("v.selectedCountryOptions");
        var ctryOpts = "";
        for(var i=0; i<selctryLst.length; i++ ){
            if(i!=selctryLst.length-1)
                ctryOpts+=selctryLst[i]+";";
            else
                ctryOpts+=selctryLst[i];            
        }  
        
        component.set("v.SelMarketValue",ctryOpts);
        component.set("v.newPFR.Core_MDF_Country_nm__c",ctryOpts);
		 //[Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
       	var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");  
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && 
        (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true 
         || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true)){
            helper.checkCountry(component);
        }
       
          var country=component.get("v.SelMarketValue");
         helper.getIndustryPartners(component, country);
        var action = component.get("c.checkEMEARegion");
        action.setParams({
         "country" : component.get("v.SelMarketValue")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                if(res == true){
                    component.set("v.isEMEARegion", true);
                }else{
                    component.set("v.isEMEARegion", false);
                     }                  
            }
        });
        $A.enqueueAction(action);
        	
    },
	
    setApprover : function(component,event,helper){
        
        var selAppLst = component.get("v.selectedApproverOptions");
        var isExternal = component.get("v.externalper");
        var allAppLst = component.get("v.AllApproverOptions");
        var budType = component.get("v.selBudgetType");
        var intelContri = component.get("v.intelContribution");
        var selectedCountry = component.get("v.selectedCountryOptions"); 
        if(selAppLst.length != 0 && isExternal){
        if(selAppLst.length >1){
            var toastEvent = $A.get("e.force:showToast");
              			toastEvent.setParams({
                  			title: "Error..!!",
                  			message: $A.get("$Label.c.Core_MDF_Only_One_Intel_Owner"),
                  			type: "error"
                           
              			});
              			toastEvent.fire();
        }
            helper.checkIsApproverActive(component);
        var appOpts = "";
        for(var i=0; i<selAppLst.length; i++ ){
            if(i!=selAppLst.length-1)
                appOpts+=selAppLst[i]+";";
            else
                appOpts+=selAppLst[i];            
        }
        component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c",appOpts);
        }
        },
    //---Rishabh
    /*setExtActSubmitter : function(component,event,helper){
        
        var selSbtLst = component.get("v.selectedExtActSubmitterOptions");
        var isInternal = component.get("v.accmgrper");
        var allSbtLst = component.get("v.AllExtActSubmitterOptions");
        var budType = component.get("v.selBudgetType");
        if(selSbtLst.length != 0 && isInternal){
        if(selSbtLst.length >1){
            var toastEvent = $A.get("e.force:showToast");
              			toastEvent.setParams({
                  			title: "Error..!!",
                  			message: $A.get("$Label.c.Core_MDF_Only_One_Partner_Activity_Owner"),
                  			type: "error"
                           
              			});
              			toastEvent.fire();
           
        }
           helper.checkIsSubmitterActive(component);
        var subOpts = "";
        for(var i=0; i<selSbtLst.length; i++ ){
            if(i!=selSbtLst.length-1)
                subOpts+=selSbtLst[i]+";";
            else
                subOpts+=selSbtLst[i];            
        }
        component.set("v.newPFR.Core_MDF_Member_Acceptor_Id__c",subOpts);
        }
        },*/   
    
    // SS - Handle the behaviour of channel partner related controls picklist, other text box and check box
    SetOtherCPValue : function(component,event,helper){        
        var PicListValue = event.getParam("PicValue");
        var PicFieldName = event.getParam("PicFieldName");
        
        // SS - if other channel partner from picklist then reset the other text box
        if (PicFieldName == 'Core_MDF_Channel_Partner__c' && PicListValue == 'Others')
        {
            component.set("v.SelOtherChannelPartner",'');
            component.set('v.IsOtherCP',true);     
        }
        // SS - if activity type falls any of these 3 then reset the values and enable back the check box
        else if (PicFieldName == 'Core_MDF_Country_nm__c' || PicFieldName == 'Core_MDF_ActivityCategory__c'
                 || PicFieldName == 'Core_MDF_Activity_Types__c' )
        {
            if (PicFieldName == 'Core_MDF_Channel_Partner_Led__c')
            {
                component.set("v.SelOtherChannelPartner",'');
            }
            
            if(!component.get("v.isOpalActivity")){
                component.set("v.CPLed", false);
                helper.EnableCPCheckBox(component, event);
            }
        } else if (PicFieldName == 'Core_MDF_Channel_Partner__c')
            { 
                component.set('v.IsOtherCP',false); 
                component.set("v.SelOtherChannelPartner",'');
            }
        
    },
    //Function called on change of budget currency
    //----Rishabh
    /*resetBudgetAmount : function(component,event,helper){
        component.set("v.budgetCurrency",component.get("v.budgetCurrency")); 
    },*/
    
    handleKPIComp: function (component, event, helper) {
        component.set("v.showKPISpinner", false);
         //DE117182 WW23 | QA3 | 'Demonstration' Subtype value not getting cleared on cloning for opal activity
         if(component.get("v.isOpalActivity") && component.get("v.checkCloneAttribute") && component.get("v.SelActivityType") !=  component.get("v.oldActivtyType")){
            component.set("v.selectedSubTypeOptions", null);
        }
    },
    //Added by Hema for IPA launch
    ////Starts
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
     onKPIChange: function (component, event, helper) {
        var selectedKPI = event.getParam('value');
        var selectedKPIOptions = "";
        var selectKPI = component.get("v.selectedKPIOptions"); 
       
        
        if(!$A.util.isEmpty(selectKPI) && selectKPI != undefined){
            for(var index=0; index<selectKPI.length; index++ ){
                if(index!=selectKPI.length-1)
                selectedKPIOptions+=selectKPI[index]+";";
                else
                selectedKPIOptions+=selectKPI[index];            
            }
        }
        if(!$A.util.isEmpty(selectedKPIOptions) && selectedKPIOptions != undefined){
            component.set("v.newPFR.Core_MDF_Key_Marketing_Indicator_nm__c", selectedKPIOptions);
        }else{
            component.set("v.newPFR.Core_MDF_Key_Marketing_Indicator_nm__c", "");
        }
         //Other value selected along with KPI values
         if(selectedKPIOptions.includes("Others") && selectKPI.length > 1){
            component.set("v.showKPIError", true);
         }
         else{
            component.set("v.showKPIError", false); 
         }
         //Respective quantity fields display
         if(selectedKPIOptions.includes("Leads")){
            component.set("v.showLeadsKPIQuantity", true);
            
         }
         else{
             component.set("v.showLeadsKPIQuantity", false);
             component.set("v.newPFR.Core_MDF_Lead_Quantity_nbr__c",null);
         } 
         if(selectedKPIOptions.includes("Deployments")){
            component.set("v.showDeploymentKPIQuantity", true);
         }
         else{
             component.set("v.showDeploymentKPIQuantity", false);
             component.set("v.newPFR.Core_MDF_Deployment_Quantity_nbr__c",null);
         }
          if(selectedKPIOptions.includes("Others")){
            component.set("v.showOtherKPIQuantity", true);
         }
         else{
             component.set("v.showOtherKPIQuantity", false);
             component.set("v.newPFR.Core_MDF_Other_Quantity_nbr__c",null);
         }
   },
    
     onEcosystemPartnerChange: function (component, event, helper) {
         var selectedEcosystemPartner = event.getParam('value');
         var selectedEcosystemPartnerOptions = "";
             for(var i=0; i<selectedEcosystemPartner.length; i++ ){
                 if(i!=selectedEcosystemPartner.length-1)
                     selectedEcosystemPartnerOptions+=selectedEcosystemPartner[i]+";";
                 else
                     selectedEcosystemPartnerOptions+=selectedEcosystemPartner[i]; 
             }
        //Ayush - Commented empty check and added null check as Ecosystem Partner value was not getting cleared even if we remove all the selected values on UI.     
        //if(!$A.util.isEmpty(selectedEcosystemPartnerOptions) && selectedEcosystemPartnerOptions != undefined){
        if(selectedEcosystemPartnerOptions != undefined && selectedEcosystemPartnerOptions != null){
             component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c", selectedEcosystemPartnerOptions);
        }
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
    },

     onIndustryPartnerChange: function (component, event, helper) {
         var selectedIndustryPartner = event.getParam('value');
         var selectedIndustryPartnerOptions = "";
         if(!$A.util.isEmpty(selectedIndustryPartner) && selectedIndustryPartner != undefined){
                 for(var i=0; i<selectedIndustryPartner.length; i++ ){
                     if(i!=selectedIndustryPartner.length-1)
                         selectedIndustryPartnerOptions+=selectedIndustryPartner[i]+";";
                     else 
                         selectedIndustryPartnerOptions+=selectedIndustryPartner[i];            
                 }
         }
         if(!$A.util.isEmpty(selectedIndustryPartnerOptions) && selectedIndustryPartnerOptions != undefined){
           
             component.set("v.newPFR.Core_MDF_Industry_Multi_nm__c", selectedIndustryPartnerOptions);
         } 
    }, 
    onProductChange: function (component, event, helper) {
        var selectedProduct = event.getParam('value');
        if(!$A.util.isEmpty(selectedProduct) && selectedProduct != undefined){
           
          component.set("v.newPFR.Core_MDF_ProductType__c", selectedProduct);
        }   
    }, 
     onPriorityChange: function (component, event, helper) {
        var selectedPriority = event.getParam('value');
        if(!$A.util.isEmpty(selectedPriority) && selectedPriority != undefined){
            
         component.set("v.newPFR.Core_MDF_Priority_nm__c", selectedPriority);
        }   
    }, 
    //End
    setFocusAreaOnCampchange: function(component, event, helper)
    {
        var selectedCampChange = component.get("v.selectedLookUpRecord.Id"); 
        if($A.util.isEmpty(selectedCampChange) || selectedCampChange == undefined){
            component.set("v.selectedFocusArea", "");
            component.set("v.AllFocusAreaOptions", "[]"); 
        }else{
            component.set("v.BudgetLocal",component.get("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c"));
            } 
    },
    focusAreaChange: function(component, event, helper){
         component.set("v.showSpinner", true);
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){              
        	helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
        } 
        else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){  
	      helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
        }
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.showSpinner", false);
            }), 5000
        );
    },
    //[OPAL CCF/DCF] - Available Budgets Field at Activity
    budgetTypeChangeOPAL : function(component,event,helper){
        //Fetch Budget applicable for the Budget Type
        component.set("v.FlexiReimbursementAmt",'');
        component.set("v.doInitCheck", false);
        helper.getAvailableBudget(component,event,helper);
        helper.loadFieldsetFields(component);
        if (component.get("v.isOpalActivity") && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType")) &&
            (component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")||component.get("v.SelActivityType") == $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) && component.get("v.checkfileuploadcondition") == false) {
            helper.checkFileUploadForOPAL(component);
        } else if (component.get("v.isOpalActivity") && !$A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType")) &&
                   (component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")||component.get("v.SelActivityType") == $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) && component.get("v.checkfileuploadcondition") == true) {
            component.set("v.checkfileuploadcondition", false);
            if (component.get("v.Uploadfinished")) {
                component.set("v.Uploadfinished", false);
                component.set("v.ContentDocumentIds",null);
            }
        }
        var selCategory = component.get("v.SelCategory");
        var selActiType = component.get("v.SelActivityType");
        var setBudgType = component.get("v.selBudgetType");
        if (((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ) && selCategory == 'Event' && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) || ((component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") || component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")) && selActiType != 'Promotion')) {
            component.set("v.hideCompetitiveQuest", true);
            if((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && selCategory == 'Event' && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) {
                component.set("v.newPFR.Core_MDF_Competitive_Elements__c",null);
            }
        }
        else{
            component.set("v.hideCompetitiveQuest", false); 
        }
	//Read only "Strategic Marketing Fund" checkbox inheriting values from Campaign
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
           component.set("v.IsStrategicMarketingFundVisible", false); 
        
	//OPAL Past Dated Activity Submission process
        var todayDate = helper.getTodayDateLocalTime();
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c")
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c"); 
    	var oldBT = component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c");
        var budgetType = component.get("v.selBudgetType");
        component.set("v.newPFR.Core_MDF_Budget_Type_nm__c",budgetType);
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var mode = component.get("v.mode");
        if(oldBT != budgetType){
            component.set("v.selectedApproverOptions","");
        }
        if(mode != 'clone' && mode != 'edit'){
            if(!component.get("v.externalper")){ 
                if(startDate < todayDate && (opalBudgetTypes.includes(budgetType) )){
                    if((component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')){
                        component.set("v.IsStartDateChanged", true);
                        component.set("v.IsPR", true);
                    }
                    component.set("v.IsPR", true);
                }
                else{
                    component.set("v.IsPR", false);
                    component.set("v.IsStartDateChanged", false);
                    component.set("v.SelPotentialReason", null);
                } 
            }          
            else if(startDate < todayDate && component.get("v.externalper") && opalBudgetTypes.includes(budgetType)){
                        var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                        helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                        component.set("v.IsStartDateChanged", true);
                }
                else{
                    component.set("v.IsStartDateChanged", false);
                }
        }
        else{
            if (!component.get("v.externalper")) {
                if(mode == 'clone'){ 
                    if (startDate < todayDate && (opalBudgetTypes.includes(budgetType))) {
                        component.set("v.IsPR", true);
                    } else {
                        component.set("v.IsPR", false);
                        component.set("v.IsStartDateChanged", false);
                        component.set("v.SelPotentialReason", null);
                    }
                }
                if(mode == 'edit'){  
                    if (startDate < todayDate && oldBT != null && oldStartDate != startDate && (opalBudgetTypes.includes(budgetType))) {
                        component.set("v.IsPR", true);
                    } else {
                        component.set("v.IsPR", false);
                        component.set("v.IsStartDateChanged", false);                     
                    }
                }
            }
            else if(component.get("v.externalper")){
                if(mode == 'clone'){
                    if(oldStartDate != null && startDate < todayDate && opalBudgetTypes.includes(budgetType)){
                        var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                        helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); 
                    }
                    else{
                        component.set("v.IsStartDateChanged", false);
                    } 
                }
                else if(mode == 'edit'){
                    if (oldStartDate != null && oldStartDate != startDate && startDate < todayDate && (budgetType ==$A.get("$Label.c.Core_MDF_BudgetType_MDF") || budgetType ==$A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") )) {
                        var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                        helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                        component.set("v.IsStartDateChanged", true);
                    }
                    else{
                        component.set("v.IsStartDateChanged", false);
                    } 
                }
            }
        } 
	
    },
    //[OPAL CCF/DCF] - Available Budgets Field at Activity
    saveBudget :  function(component, event, helper) {
        //Set Allocation Id in Activity
        helper.checkAvailAllocationAmt(component);
        //SAve the selected Budget
        helper.allocationBudgt(component, event, helper);
        
    },
    
    
	// OPAL changes - on change MDF Reimbursement Amount
	// ---Rishabh
   /* calculateFlexibleRR: function(component, event, helper){
        var flexRamt = component.get("v.FlexiReimbursementAmt");
	var budgetAmnt = component.get("v.newPFR.RequestedAmount");
        if(flexRamt != undefined && flexRamt != null && flexRamt != '' && budgetAmnt != undefined && budgetAmnt != null && budgetAmnt != ''){    
            component.set("v.disableRRPercent",true);
            helper.calculateReimbursementRatePercent(component,budgetAmnt,flexRamt);
        }else{        
            var selectedBudget = component.get("v.selBudgetType");    
            var budgetCampRecList = component.get("v.campaignBudgetList");
            var abRR;
            var abudgetId = component.get("v.selAvailableBudget");
            if(budgetCampRecList != null && budgetCampRecList.length > 0){
                for(var i = 0; i < budgetCampRecList.length; i++){
                    if( budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c == selectedBudget){
                        abRR = budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c;
                        
                        break;
                    }
                }
            }
            component.set("v.disableRRPercent",false);
            helper.updateRRPickValues(component,abRR);
        }
    },*/
	 //KS - Handle the behaviour of Industry partner related controls picklist, other text box and check box
    //[Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
      indPartnerChange: function (component, event, helper) {
          var selctryLst = component.get("v.selectedIndPartnerOptions");
          
          if ( selctryLst.includes("Others") && component.get("v.isOpalActivity") ) {
             
             component.set("v.IsOtherCP", true); 
          }
          else if ( !selctryLst.includes("Others")) {
                
              component.set("v.IsOtherCP", false);
          }
          var industryOpts = "";
        for(var i=0; i<selctryLst.length; i++ ){
            if(i!=selctryLst.length-1)
                industryOpts+=selctryLst[i]+";";
            else
                industryOpts+=selctryLst[i];            
        }  
        
        component.set("v.SelIndustryPartner",industryOpts);
      },
      
	      //Technical [IPA] BU Mapping % Splits - Enable BU Splits onchange of multiselect picklist this methd gets called.
   /* busplitOnChange : function (component, event, helper) {
        if(!$A.util.isEmpty(component.get("v.buSplitSelectedList")) && component.get("v.buSplitSelectedList") != undefined && component.get("v.buSplitSelectedList") !=  null ){
            var selBUSpltManual = [];
            var mode = component.get("v.mode");
            selBUSpltManual =  component.get("v.buSplitSelectedList");
            var  metadataBuSplitData = []; 
            var itrBuList = [];
            //metadataBuSplitData = component.get("v.metadataBuSplitMap");
            var avaBUListSetField = [];
            var disableCheck = false;
            let defaultPercnt = 0;
            var fieldName ;
			if(metadataBuSplitData != undefined && metadataBuSplitData != null){
            for(let i=0;i<selBUSpltManual.length;i++){
                let buSplitResult = metadataBuSplitData.filter(metadataBuSplitData => metadataBuSplitData.Core_MDF_BU_Name__c == selBUSpltManual[i]);
                for(let i=0;i<buSplitResult.length;i++){ 
                    disableCheck = component.get("v.disabledMap.buSplitFld"); 
                    //On create
                    //1. Default 100, if only 1 BU split is selected 
                    //2. Blank out split %, if more than 1 is selected
                    if(component.get("v.mode") != 'edit' && buSplitResult[i].Core_MDF_Default_BU__c == false){ //&&
                        if(component.get("v.buSplitSelectedList").length == 1){
                            buSplitResult[i].Core_MDF_Split_Percent__c = 100;
                        }else if(component.get("v.buSplitSelectedList").length > 1){
                            buSplitResult[i].Core_MDF_Split_Percent__c = '';  
                        }
                    }else if(buSplitResult[i].Core_MDF_Default_BU__c){
                        component.set("v.disabledMap.buSplitFld",true);
                        disableCheck =  component.get("v.disabledMap.buSplitFld"); 
                    }
                    var fieldVal = JSON.stringify(buSplitResult[i].Core_MDF_Field_Name__c);
                    var mergeField = 'v.newPFR.'+JSON.parse(fieldVal);
                    if(buSplitResult[i].Core_MDF_Split_Percent__c != undefined && buSplitResult[i].Core_MDF_Split_Percent__c != null){
                        component.set(mergeField,parseInt(buSplitResult[i].Core_MDF_Split_Percent__c)); 
                    }              
                    defaultPercnt =  component.get(mergeField);
                    fieldName = buSplitResult[i].Core_MDF_Field_Name__c;
		    		//On edit 
                    //1. Default 100, if BU split is removed and only one is available 
                    //2. Blank out split %, if more than 1 is selected again
                    if(component.get("v.mode") == 'edit' && buSplitResult[i].Core_MDF_Default_BU__c == false && component.get("v.buSplitSelectedList") != undefined){
                        if(component.get("v.buSplitSelectedList").length == 1){
                            component.set(mergeField,100);
                            defaultPercnt = component.get(mergeField);         
                        }else if(defaultPercnt == 100 && component.get("v.buSplitSelectedList").length > 1){
                            component.set(mergeField,'');
                            defaultPercnt = component.get(mergeField);
                        }
                    }
                    itrBuList.push({
                        name: buSplitResult[i].Core_MDF_BU_Name__c,
                        bupercent: defaultPercnt, 
                        disablecheck:disableCheck,
                        field :fieldName
                    }); 
                } 
              } 
            }
            component.set("v.buSplitList",itrBuList);         
            component.set("v.showBuSplitSection",true);
            helper.updateBuSplitFormula(component);
            
        }
        //set fields to blank on removing it from multiselect picklist
        avaBUListSetField =    component.get("v.buSplitAvaliableList");
        var  metadataBuSplitDataAv = []; 
        //metadataBuSplitDataAv = component.get("v.metadataBuSplitMap");
        if(metadataBuSplitDataAv != undefined && metadataBuSplitDataAv != null && avaBUListSetField != undefined && avaBUListSetField !=  null){
            for(let i=0;i<avaBUListSetField.length;i++){
                if(!component.get("v.buSplitSelectedList").includes(avaBUListSetField[i].label)){ 
                    let buSplitAvabiableResult = metadataBuSplitDataAv.filter(metadataBuSplitDataAv => metadataBuSplitDataAv.Core_MDF_BU_Name__c == avaBUListSetField[i].label);
                    for(let i=0;i<buSplitAvabiableResult.length;i++){ 
                        var fieldVal = JSON.stringify(buSplitAvabiableResult[i].Core_MDF_Field_Name__c);
                        var setFieldtoBlank = 'v.newPFR.'+JSON.parse(fieldVal);
                        component.set(setFieldtoBlank,"");
                        component.set("v.buSplitWholeNumError",false); 

                    }
                }
            }
        }
    },*/
	calcContribution: function (component, event, helper) {

        var ActReimbRt = component.get("v.ActReimbursementRt"); 
        ActReimbRt=ActReimbRt.trim();
        // reset the error state 
        component.set("v.actReimbRateError", false);
        if(helper.isNotBlank(ActReimbRt)){
            if(ActReimbRt<0){
            
                component.set("v.actReimbRateError",true);
                component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_Neg_Val_ActRR_Error" ));
            }else if(!helper.isNotBlank(ActReimbRt)&&
                    (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") 
                    || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))){
                component.set("v.IPAIntelContri", ''); 
            }else  if(ActReimbRt>100){
                
                component.set("v.actReimbRateError",true);
                component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_Neg_Val_ActRR_Error" ));
            
            } else  if(ActReimbRt.includes('.') && ActReimbRt.split('.')[1].length > 2){
                
                component.set("v.actReimbRateError",true);
                component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_ActRR_Restrict_Decimal_Places" ));
            
            }   
            else if( (!ActReimbRt.includes('%') && isNaN(ActReimbRt)) ||ActReimbRt.startsWith('+') || parseFloat(ActReimbRt)==0 || ActReimbRt.endsWith('.') 
                    || ActReimbRt.startsWith('%') || ActReimbRt.includes('%%')
                    || (parseFloat(ActReimbRt)!=0 && !ActReimbRt.includes('.') && ActReimbRt.startsWith('0'))){
                
                component.set("v.actReimbRateError",true);
                component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_CRR_valid_number_message" ));
            }else{
                component.set("v.actReimbRateError",false);
                
            }
            if(helper.isNotBlank(ActReimbRt)){
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",ActReimbRt);
            }
            
            if(helper.isNotBlank(component.get("v.ActReimbursementRt"))){
                helper.updateRRPickValues(component,component.get("v.ActReimbursementRt"));
            }
        }
        
        var campReimbRt = component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c");
        var budgetAmnt = component.get("v.BudgetLocal");
        
        if (ActReimbRt != undefined && ActReimbRt != null && ActReimbRt != ''&& ActReimbRt.replace(/^\s+/g, '').length!=0 && budgetAmnt != undefined && budgetAmnt != null && budgetAmnt != ''&& !(component.get("v.actReimbRateError"))) {
        component.set('v.disableRRPercent',true);
            helper.calcIntelContribution(component, budgetAmnt, ActReimbRt);
            helper.budgetAmountcalculatefunction(component, budgetAmnt, ActReimbRt);
        } else if (campReimbRt != undefined && campReimbRt != null && campReimbRt != ''&& budgetAmnt != undefined && budgetAmnt != null && budgetAmnt != ''){
                    
                var Contri = budgetAmnt* (parseFloat(campReimbRt)/100); 
                component.set("v.IPAIntelContri", Contri);
            helper.getActivityAmount(component);
            helper.budgetAmountcalculatefunction(component, budgetAmnt, ActReimbRt);
        }
        //Ayush - RR changes
        if( component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") && (ActReimbRt == '' || (ActReimbRt != '' && component.get("v.mode") == 'clone' && component.get("v.externalper"))) && helper.isNotBlank(component.get("v.BudgetLocal")) && helper.isNotBlank(component.get("v.SelReimbursementRate")) && !(component.get("v.actReimbRateError"))){
            //component.set("v.SelReimbursementRate",'');
            helper.updateRRPickVals(component);
            component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.SelReimbursementRate"));
            //Ayush - RR Changes
            var selReimRate;
            if(component.get("v.SelReimbursementRate").endsWith("%")){
                selReimRate = component.get("v.SelReimbursementRate").replace("%", "");
            }
            helper.calcIntelContribution(component, component.get("v.BudgetLocal"), selReimRate);
            helper.budgetAmountcalculatefunction(component, component.get("v.BudgetLocal"), selReimRate);
        }
        
    },
    addPercentage: function (component, event, helper) {
        
        var newReimbRate = component.get("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c");
        if(newReimbRate != null && newReimbRate != "" && newReimbRate != undefined && !component.get("v.actReimbRateError")){
			var removedPercent = newReimbRate.substring(0, newReimbRate.length - 1);
			
           if(!newReimbRate.endsWith('%')&& !newReimbRate.replace(/\s/g, '').length==0){
                newReimbRate = newReimbRate.trim()+'%';
            }
			else{
                newReimbRate = newReimbRate.trim();
            }
			
			if(removedPercent<0){
				component.set("v.actReimbRateError",true);
				component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_Neg_Val_ActRR_Error" ));
			}
			else if(removedPercent>100){
				component.set("v.actReimbRateError",true);
				component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_Neg_Val_ActRR_Error" ));
			}
			else if(removedPercent.includes('%')){
				component.set("v.actReimbRateError",true);
				component.set("v.actReimbErrorMsg", $A.get("$Label.c.Core_MDF_CRR_valid_number_message" ));
			}
			else{
               component.set("v.actReimbRateError",false);
			}
            
        }
        if(helper.isNotBlank(component.get("v.ActReimbursementRt"))){
        	component.set("v.ActReimbursementRt",newReimbRate);
        }
        //Ayush - RR Changes
        if(component.get("v.ActReimbursementRt") == "" || (helper.isNotBlank(component.get("v.ActReimbursementRt")) && component.get("v.mode") == 'clone' && component.get("v.externalper"))){
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
                && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true 
                //&& (component.get("v.mode") == '' || (component.get("v.mode") == 'clone' && component.get("v.externalper")))
                //&& helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c"))
                ){
                if(helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c"))){
                    var reimburesmentRate = component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal I MDF' ? '50%' : component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == 'Proposal II MDF' ? '25%' : '';
                    component.set("v.SelReimbursementRate", reimburesmentRate);
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
                }
                else if(helper.isNotBlank(component.get("v.newPFR.Core_MDF_Budget_Type_nm__c"))){
                    var reimburesmentRate = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == 'Proposal I MDF' ? '50%' : component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == 'Proposal II MDF' ? '25%' : '';
                    component.set("v.SelReimbursementRate", reimburesmentRate);
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
                }
            }
        }
        if(helper.isNotBlank(newReimbRate) && helper.isNotBlank(component.get("v.ActReimbursementRt"))){
            component.set('v.disableRRPercent',true);
            }
            else{
                component.set('v.disableRRPercent',false);
            }
        if(helper.isNotBlank(component.get("v.ActReimbursementRt"))){
        	component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",newReimbRate);
        }
        else if(component.get("v.ActReimbursementRt") == "" && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false){
			component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.ActReimbursementRt"));
		}
    },
    removePercentage: function (component, event, helper) {
        
        var newReimbRate = component.get("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c");
        if(newReimbRate != null && newReimbRate != "" && newReimbRate != undefined && component.get("v.externalper")==false && helper.isNotBlank(component.get("v.ActReimbursementRt"))){
            newReimbRate = newReimbRate.replace(/%\s*$/, "");
            component.set("v.ActReimbursementRt",newReimbRate);
        }
    },
   //[IPA] BU Mapping - this method is call onchange of percent 
   //----Rishabh
 /* handlePerChangeBuSplit: function (component, event, helper) {
      var mergeFld = 'v.newPFR.'+ event.getSource().get('v.title');
	var fldVal = event.getSource().get('v.value');
	component.set(mergeFld,event.getSource().get('v.value')); 
      try {
          if(fldVal != undefined &&  (fldVal == null || fldVal == '' || fldVal <= 0 || fldVal.includes(".") || fldVal.includes("-") || fldVal.includes("+"))){
              component.set("v.buSplitWholeNumError",true);
          }else{
              component.set("v.buSplitWholeNumError",false); 
          }
          helper.updateBuSplitFormula(component);
      }
      catch (e) {
      }
    },*/
	/*Added for capturing the Reimburesemnt Rate %*/
    //---Rishabh
    /* selReimbursementRateOnChange: function (component, event, helper) {
        helper.getActivityAmount(component);
	},*/
    validateOppId : function(component, event,helper){
        helper.validateOpportunityId(component);
    },
    handleOpportunityId : function(component, event,helper){
       component.set("v.newPFR.isInvalidOppId",false);
        
        var errMsg = component.get("v.message");
        if(helper.isNotBlank(errMsg) && errMsg.includes($A.get("$Label.c.Core_MDF_OpportunityID_Error"))){
            component.set("v.message",'');
        }
    }
   
});