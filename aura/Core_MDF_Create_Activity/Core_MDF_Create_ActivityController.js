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
    //if ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")) &&
    if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") &&
            !$A.util.isEmpty(component.get("v.selBudgetType")) && !$A.util.isEmpty(component.get("v.selectedLookUpRecord.Id")) &&
            component.get("v.selectedLookUpRecord.Core_MDF_Supports_legacy_program__c") != 'Yes') {
            //US915274 :  [OPAL CCF/DCF] - Available Budgets Field at Activity
            helper.fetchCampBudgetInfo(component,event,helper,true);
        }

    /*  if ((recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_Retail")) &&
        (component.get("v.isActivityCreationOnCampaign") == true || 
        component.get("v.mode")== "" || component.get("v.mode")=='clone' ||component.get("v.mode")=='edit')){
        helper.fetchCampBudgetInfo(component, event, helper, true);
                
            }*/
        helper.constructadditionalfilter(component, checkStartDate, newEndDate, recordTypeDeveloperName, null);
	//US1115938 - OPAL Past Dated Activity Submission process
        helper.onStartDateChange(component);
       component.set("v.startDate", component.get("v.newPFR.Core_MDF_Start_Date__c"));
    } ,
        
    //Function called for filtering country values
   /* filterCountry: function (component, event, helper) {
        var countryName = component.get("v.CountryPicklistValues");
        if(helper.isNotBlank(countryName)){
            var filterCountrySearch = new Array();
            var filterCountryNonSearch = new Array();
            if (helper.isNotBlank(component.get("v.countryFilter"))) {
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
        }
    },*/
    /*filterBrand: function (component, event, helper) {
        var brandName = component.get("v.BrandPicklistValues");
        if(helper.isNotBlank(brandName)){
            var filterBrandSearch = new Array();
            var filterBrandNonSearch = new Array();
            if (/*component.get("v.brandFilter") != null helper.isNotBlank(component.get("v.brandFilter"))) {
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
        }
    },*/
    
    //Ayush - Need to be commented
   /* filterApprover: function (component, event, helper) {
        var approverName = component.get("v.ApproverPicklistValues");
        if(helper.isNotBlank(approverName)){
            var filterApproverSearch = new Array();
            var filterApproverNonSearch = new Array();
            if (/*component.get("v.approverFilter") != null helper.isNotBlank(component.get("v.approverFilter"))) {
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
        }
        
    },*/
    //Ayush - Need to be commented
    /*filterPrimaryApprover: function (component, event, helper) {
        var approverName = component.get("v.PriApproverPicklistValues");
        if(helper.isNotBlank(approverName)){
            var filterApproverSearch = new Array();
            var filterApproverNonSearch = new Array();
            if (/*component.get("v.approverFilter") != null helper.isNotBlank(component.get("v.approverPrimaryFilter"))) {
                var approverSearch = component.get("v.approverPrimaryFilter").toUpperCase();
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
            component.set("v.AllPrimaryApproverOptions", filterApproverSearch);
        }
        
    },*/
    
    
    
    //Ayush - Need to be commented
   /* filterExtActSubmitter: function (component, event, helper) {
        console.log('**inside**');
        var ExtActSubmitterName = component.get("v.ExtActSubmitterPicklistValues");
        if(helper.isNotBlank(ExtActSubmitterName)){
            var filterExtActSubmitterSearch = new Array();
            var filterExtActSubmitterNonSearch = new Array();
            if (/*component.get("v.extActSubmitterFilter") != null helper.isNotBlank(component.get("v.extActSubmitterFilter"))) {
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
            console.log('**filterExtActSubmitterSearch**',filterExtActSubmitterSearch);
            component.set("v.AllExtActSubmitterOptions", filterExtActSubmitterSearch);
        }
        
    },*/
    
    //Ayush - Need to be commented
    /*validateOppId : function(component, event,helper){
        helper.validateOpportunityId(component);
    },
    //Ayush - Need to be commented
    handleOpportunityId : function(component, event,helper){
        // var validateOpp = helper.validateOpportunityId(component);
        component.set("v.newPFR.isInvalidOppId",false);
        
        var errMsg = component.get("v.message");
        if(helper.isNotBlank(errMsg) && errMsg.includes($A.get("$Label.c.Core_MDF_OpportunityID_Error"))){
            component.set("v.message",'');
        }
    },*/
    
    //Function called on change of End Date to contruct campaign lookup filter
    createNewAdditionalfilter : function(component, event, helper) {
        var newcheckStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var newcheckEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var newrecordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
        //added fix - When End date was getting changed available budget was getting auto selected even if multiple budgets are available
        component.set("v.selAvailableBudget",'');
        
    // if ((newrecordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || newrecordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || newrecordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") || newrecordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")) &&
    if (newrecordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") &&
            !$A.util.isEmpty(component.get("v.selBudgetType")) && !$A.util.isEmpty(component.get("v.selectedLookUpRecord.Id")) && component.get("v.selectedLookUpRecord.Core_MDF_Supports_legacy_program__c") != 'Yes') {
            //US915274 :  [OPAL CCF/DCF] - Available Budgets Field at Activity
            helper.fetchCampBudgetInfo(component,event,helper,true);          
        }
         
    /* if ((newrecordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_Retail")) &&
        (component.get("v.isActivityCreationOnCampaign") == true || 
        component.get("v.mode")== "" || component.get("v.mode")=='clone' || component.get("v.mode")=='edit')){
        helper.fetchCampBudgetInfo(component, event, helper, true);
    }*/
        helper.constructadditionalfilter(component, newcheckStartDate, newcheckEndDate, newrecordTypeDeveloperName, null);
        component.set("v.endDate", component.get("v.newPFR.Core_MDF_End_Date__c"));
    },
    
    
    
    //Function Called On Change of the Budget Amount Local Field to Calculate USD
    calculateBudgetAmount : function(component, event, helper){
        if(component.get("v.IsOldBudget")){
           component.set("v.OldBudgetLocal",component.get("v.oldPFR.Core_MDF_Budget_Amount_Local_amt__c"));
	   component.set("v.OldbudgetCurrency",component.get("v.oldPFR.Core_MDF_Budget_Currency_cd__c"));	
           component.set("v.IsOldBudget",false);
        }
        var selCategory = component.get("v.SelCategory");
        var selActiType = component.get("v.SelActivityType");
        var setBudgType = component.get("v.selBudgetType");
        var actSpendingAmount= component.get("v.BudgetLocal");
        
	component.set("v.ErrorMsgForSpendingLimit", ""); 
        var actSpendingAmtDecimalVal;
        if(actSpendingAmount != null && actSpendingAmount.toString().includes('.')){
            var getDecimalVal = actSpendingAmount.toString().indexOf(".");
            actSpendingAmtDecimalVal =  actSpendingAmount.toString().substring(getDecimalVal + 1);
            if (actSpendingAmtDecimalVal != null && actSpendingAmtDecimalVal >= 0){
                var alertMsg = $A.get("$Label.c.Core_MDF_Budget_Amount_Error");
                component.set("v.showErrorMsgForSpendingLimit", true);
                component.set("v.ErrorMsgForSpendingLimit", alertMsg);
                helper.enableDisableButtons(component, true, true);
            } else {
                helper.enableDisableButtons(component, false, false);
            }
        } else if(actSpendingAmount == null || actSpendingAmount == '' || actSpendingAmount < 0){
        /* if(component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            component.set("v.EefIntelContri", '');
            }*/
            helper.enableDisableButtons(component, true, true);
        } else {
        component.set("v.isSaveDisable", false);
    // 
    //  if(!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.ipaApproverPer") || (component.get("v.CurrentStatus") == 'Planned' && (component.get("v.accmgrper") || component.get("v.externalper")) ) )  )) {
    //         if(!component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper") && !component.get("v.auditorper")){
    // }
    // }
        }
        component.set("v.chkBdgtCpExcd",false);  
        component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
        component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
        
        component.set("v.message", "");
        component.set("v.messageType", "");
        if (component.get("v.checkCloneAttribute")) {
            component.set("v.newPFR.CreatedDate", null);
        }
        component.set("v.checkbudgetcondition", false);
        // Calling function for budget check
        if(!$A.util.isEmpty(component.get("v.BudgetLocal")) && !$A.util.isEmpty(component.get("v.budgetCurrency")) 
            && (actSpendingAmtDecimalVal == null || actSpendingAmtDecimalVal == '' || actSpendingAmtDecimalVal == 'undefined')){
            helper.budgetAmountcalculatefunction(component);
        }
        component.set("v.intelContribution",null);
        //New Activity Category Type Change
    //  if((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) /*selCategory == 'Event'*/ && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) {
        //      component.set("v.newPFR.Core_MDF_Competitive_Elements__c",null);
        //  }
    /*  if(component.get("v.externalper") && (setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && ($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory"))  && (component.get("v.SelDomainType") ==$A.get("$Label.c.Core_MDF_Domain_Type_Form_Values")) && component.get("v.BudgetLocal") != component.get("v.OldBudgetLocal")) {
        helper.fetchApprovers(component);
        }*/
        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",null);
	// OPAL Changes start - 25th Jan : Commented as part of RR change
	
	// OPAL Changes End
        helper.resetHelper(component);
        if(!$A.util.isEmpty(actSpendingAmount) && actSpendingAmtDecimalVal == null){
            helper.fetchApprovers(component);
        }
        helper.fetchExternalActSubmitters(component,false);
/*    if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") 
        || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") )) &&
        (component.get("v.BudgetLocal") != component.get("v.OldBudgetLocal") || component.get("v.budgetCurrency") != component.get("v.OldbudgetCurrency") ) ) {
    component.set("v.fileData", null);
    component.set("v.ContentDocumentIds", null);
    component.set("v.Uploadfinished", false);  
    component.set("v.OldBudgetLocal",component.get("v.oldPFR.Core_MDF_Budget_Amount_Local_amt__c"));
    component.set("v.OldbudgetCurrency",component.get("v.oldPFR.Core_MDF_Budget_Currency_cd__c"));
    }*/
        
       component.set("v.OldBudgetLocal",component.get("v.BudgetLocal"));
       component.set("v.OldbudgetCurrency",component.get("v.budgetCurrency"));
    },

    //Function called on change if CSP intel-based revenue
    //Ayush - Need to be commented
/*validateCSPAmt: function(component,event,helper){
    
    var cspAmt = component.get("v.cspIntelRevVal");
    var showErrorMsgForCSPRevAmt = false;
    if(cspAmt!= null){
        if(cspAmt<0){
            component.set("v.showErrorMsgForCSPRevAmt",true);
            component.set("v.ErrorMsgForCSPAmt", $A.get("$Label.c.Core_MDF_Neg_Val_CSPVal_Error" ));
        }else if(cspAmt.includes('.') && cspAmt.split('.')[1].length > 2){
            component.set("v.showErrorMsgForCSPRevAmt",true);
            component.set("v.ErrorMsgForCSPAmt", $A.get("$Label.c.Core_MDF_CSPAmt_Restrict_Decimal_Places" ));
            
        }
            else{
                component.set("v.showErrorMsgForCSPRevAmt",false);
                component.set("v.ErrorMsgForCSPAmt","" );
                
            }
    }
    
    component.set("v.newPFR.Core_MDF_CSP_Intel_Based_Revenue_amt__c",component.get("v.cspIntelRevVal"));
    },*/ //
    // Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        if (component.get("v.checkCloneAttribute")) {
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
   // US1082873: [IPA MDF] - Campaign - Clone a Proposal - Activity Section fire event on click of save and handle in aura campaign component
    customSaveIPA: function (component, event, helper) {
       
        var actRec = component.get("v.newPFR");
       
         var cmpEvent = component.getEvent("ipaActRecClone"); 
        //Set event attribute value
        cmpEvent.setParams({"detail" : actRec}); 
        cmpEvent.fire(); 
    },
    // Function called on click of Cancel or "X" on the layout
    closeModalClosedActivtiy: function (component, event, helper) {
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                scope: "PartnerFundRequest"
            });
            homeEvent.fire();
    },   
    // Function called on click of save button (We set the selected values to the associated field)
    // Check for the validity of the fields before save
    // Also controls the popup on form
    customSave : function(component, event, helper) {
         
        var buttonClicked = event.getSource().getLocalId();
        var mode = component.get("v.mode");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");  
       
        
        component.set("v.showSpinner", false);
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
    /*   if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && mode != 'edit' && validData && $A.get("$Label.c.Core_MDF_RMF_Activity_Creation_Spinner") == 'Yes'){
        component.set("v.showSpinner", true);
    }*/
        var localmsg = "";
	var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
        //US946242 : Add new countries but not remove any
		//TWC702-184
    /* if((component.get("v.isOpalActivity") || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")) && !component.get("v.checkCloneAttribute") &&
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
    }*/
        helper.checkIsApproverActive(component);
        helper.checkIsSubmitterActive(component);
    /*  if(component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                helper.checkIsPrimaryApproverActive(component); 
    } */
        
        var isExternal = component.get("v.externalper");
        var isInternal = component.get("v.accmgrper");
        var isPrimaryaccper = component.get("v.primaryaccper");
        var isActivatingaccper = component.get("v.activatingaccper");
        var selAppLst = component.get("v.selectedApproverOptions");
        var sellPriAppLst = component.get("v.selectedPrimaryApproverOptions");
        var selSubLst = component.get("v.selectedExtActSubmitterOptions");
        var allAppLst = component.get("v.AllApproverOptions");
        var allPriAppLst = component.get("v.AllPrimaryApproverOptions");
        var allSubLst = component.get("v.AllExtActSubmitterOptions");
        var budType = component.get("v.selBudgetType");
        var intelContri = component.get("v.intelContribution");
        var selectedCountry = component.get("v.selectedCountryOptions");
        var actStatus = component.get("v.CurrentStatus");
        var actSelType = component.get("v.SelActivityType");
        var actSelCategory = component.get("v.SelCategory");
        var actDomainType = component.get("v.SelDomainType");
	component.set("v.existingMemberActivityOwnerId",selSubLst);
//    if(( allAppLst.length ==0) && isExternal && helper.isNotBlank(selectedCountry) && selectedCountry.length > 0 && component.get("v.displayApprovers") && helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType"))){
//            if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
            /*|| ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Event" && intelContri >= "50000") || ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Digital Media" && component.get("v.SelActivityType") == $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))*/
    //       || helper.isCMPEligibleApproval(component, budType, actSelType, actSelCategory, intelContri,actDomainType)){
    //          localmsg = localmsg + $A.get("$Label.c.Core_MDF_No_Approvers_Found") +'\n';
    //      validData = false; 
    // 	}
    //  }
    //EEF
    /*   if(( allPriAppLst.length ==0) && (isExternal || isActivatingaccper) && component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")
    && helper.isNotBlank(selectedCountry) && selectedCountry.length > 0 
    && component.get("v.displayApprovers") && helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id")) && helper.isNotBlank(component.get("v.selBudgetType"))){
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_No_Approvers_Found") +'\n';
            validData = false; 
        }
    }*/
    
    /*  if((component.get("v.showErrorMsgForCSPRevAmt") || !helper.isNotBlank(component.get("v.cspIntelRevVal"))) && component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
        
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_Empty_Field_Error");
        validData = false;
        
    }*/
    
    /* if( allSubLst!= null && allSubLst.length ==0 && (isInternal || isActivatingaccper || isPrimaryaccper) && helper.isNotBlank(selectedCountry) && selectedCountry.length > 0 && component.get("v.displayExtActSubmitters") && helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType"))){
        if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
            || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")
            || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_No_Partner_Activity_Owners_Found") + '\n';
        validData = false; 
        }
    }*/
        if(actStatus == 'Planned'){
        var selAppNull = false;
        for(var i=0;i<=selAppLst.length;i++){
        	if(selAppLst[i]=="" || selAppLst[i]==''){
            	selAppNull = true;
            }
		}
            var selPriAppNull = false;
            for(var i=0;i<=allPriAppLst.length;i++){
                if(allPriAppLst[i]=="" || allPriAppLst[i]==''){
                    selPriAppNull = true;
        } 
            }
        } 
        //New Activity Category and Type changes
    /*   if((selAppLst.length ==0 || selAppNull) &&
        (helper.isNotBlank(allAppLst) && allAppLst.length>0) && isExternal && component.get("v.displayApprovers") &&
        helper.isNotBlank(component.get("v.selectedPartner.Id")) &&
        helper.isNotBlank(component.get("v.selBudgetType") ))
    {
        if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || 
            budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
            || helper.isCMPEligibleApproval(component, budType, actSelType, actSelCategory, intelContri,actDomainType)){
        if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Intel_Owner"))){
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Intel_Owner") + '\n';
            validData = false; 
        }
        }
    } */
        if (($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory")) && $A.util.isEmpty(component.get("v.SelDomainType")) ){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_DomainTypeError") + '\n';
	    }
    /*  if((sellPriAppLst.length ==0 || selPriAppNull) &&

        (helper.isNotBlank(allPriAppLst) && allPriAppLst.length>0) 
        && (isActivatingaccper || isExternal) && component.get("v.displayApprovers") &&
        helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id")) &&
        helper.isNotBlank(component.get("v.selBudgetType") ) &&  component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType"))
    {
        if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Pri_Intel_Owner"))){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Pri_Intel_Owner") + '\n';
            validData = false; 
        }
    }*/
    
    /* if((selSubLst.length ==0 ) && (helper.isNotBlank(allSubLst) && allSubLst.length>0) && (isInternal || isActivatingaccper || isPrimaryaccper)  && component.get("v.displayExtActSubmitters") && helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType"))){
        if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
            || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")
            || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) {
            
            
            if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Partner_Activity_Owner"))){
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Partner_Activity_Owner") + '\n';
            validData = false; 
        }
                
            }
        }*/
        var actSelType = component.get("v.SelActivityType");
        var actSelCategory = component.get("v.SelCategory");
    /*if(helper.isNotBlank(selAppLst) && selAppLst.length>1 && isExternal && (helper.isNotBlank(selectedCountry) && selectedCountry.length > 0) && helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType"))){
        if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
            || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")
            /*|| ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Event" && intelContri >= "50000") || ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Digital Media" && component.get("v.SelActivityType") ==  $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))*/
        /*    || helper.isCMPEligibleApproval(component, budType, actSelType, actSelCategory, intelContri,actDomainType)){
        
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Only_One_Intel_Owner") + '\n';
            validData = false;
    }
    }*/
    
    /*if(helper.isNotBlank(sellPriAppLst) && sellPriAppLst.length>1 && (isExternal || isActivatingaccper)
        && (helper.isNotBlank(selectedCountry) && selectedCountry.length > 0) && helper.isNotBlank(component.get("v.selectedPartner.Id"))
        && helper.isNotBlank(component.get("v.selBudgetType")) && (component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
        
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Only_One_Pri_Intel_Owner") + '\n';
            validData = false;
            
        }
    
    if(helper.isNotBlank(selSubLst) && selSubLst.length>1 && (isInternal || isActivatingaccper || isPrimaryaccper || isExternal) && (helper.isNotBlank(selectedCountry) && selectedCountry.length > 0) && helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType") )){
        if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
            || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType"))
            {
        
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Only_One_Partner_Activity_Owner") + '\n';
            validData = false;
    }
    }*/
			 
        //Industry Partner led IPLed
        //TWC702-184
    /* if ((component.get("v.isOpalActivity")) 
        && (component.get("v.selBudgetType") != "" || component.get("v.selBudgetType") != null)) {
        if (component.get("v.selectedIndPartnerOptions") == "" || component.get("v.selectedIndPartnerOptions") == null) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_CP_ReqError") + '\n';
            validData = false;
        }
        else  if ((component.get("v.selectedIndustryOptions") == "" || component.get("v.selectedIndustryOptions") == null)) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Industry_Error_Msg") + '\n';
            validData = false;
        }
        else  if (helper.isNotBlank(component.get("v.selectedIndPartnerOptions")) && component.get("v.selectedIndPartnerOptions").includes('None') && component.get("v.selectedIndPartnerOptions").length > 1) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_None_IP_Error") + '\n';
            validData = false;    
        }
        else if ( component.get("v.selectedIndPartnerOptions").includes('Others') &&  
                    !(component.get("v.SelOtherChannelPartner") != "" 
                    && component.get("v.SelOtherChannelPartner") != null 
                    && component.get("v.SelOtherChannelPartner").trim().length > 0))
                    
            {   
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Other_CP_Error") + '\n';
                validData = false;    
            }  
    }
    
    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
        if ((component.get("v.selectedIndustryOptions") == "" || component.get("v.selectedIndustryOptions") == null)) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Industry_Error_Msg") + '\n';
            validData = false;
        }
    }
    
    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") && helper.isNotBlank(component.get("v.newPFR.Core_MDF_Opportunity_id__c")) ){
        if(helper.validateOpportunityId(component)){
            validData = false;
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_OpportunityID_Error") +'\n';
        }
    }*/
        
	//US1115938 - OPAL Past Dated Activity Submission process
        var todaysDate = helper.getTodayDateLocalTime();
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
        var budgetType = component.get("v.selBudgetType");
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var mode = component.get("v.mode");
        var diffDate = Date.parse(startDate) - Date.parse(todaysDate); //Parse takes a date string (such as "2022-10-10T14:48:00") and returns the number of milliseconds
        var daysDifference = diffDate/(3600*24*1000) ; //To convert into Days
        var opalActBud = false;
        //Reason Field - Akanksha - to throw validation if user enters only space in the text field
        let reasonName = component.get("v.newPFR.Core_MDF_Other_Reason_nm_txt__c");
        if(!helper.isNotBlank(component.get("v.selectedLookUpRecord.Id"))/*component.get("v.selectedLookUpRecord.Id") == undefined || component.get("v.selectedLookUpRecord.Id") == null */)
        { var alertMsg = $A.get("$Label.c.Core_MDF_CampaignErrorMessage");                                
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); 
          	validData = false;
         }
        
        // Throw error to submit event activities 60 days before activity Start date for external Users
       // TWC702-4833 
       // New Activity Category and Type changes 
       // label - Core_MDF_Event_Activity_Category contians values as Event and Event 2025
        if(component.get("v.hideCompetitiveQuest") || component.get("v.renderVRQuestion") || component.get("v.renderGovtQuestion") )
        {
            if( mode == '' || mode == 'clone' )
            {
                //helper.calculateIntelContribution(component);
                if(component.get("v.externalper") && helper.isNotBlank(component.get("v.SelCategory")) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) /*component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")*/ 
                   &&  daysDifference < $A.get("$Label.c.Core_MDF_60DaysMoreThan_50K") && helper.isNotBlank(budgetType) &&
                   (budgetType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budgetType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") || component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_EEF_RecordType") || 
                    ((budgetType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||  budgetType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) &&
                     (component.get("v.SelActivityType") == 'Joint Event' || component.get("v.SelActivityType") == 'Third Party Event'))) 
                   && component.get("v.intelContribution") >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold")) {
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Event_60_Days");                                
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                    validData = false;
                }
            }
        }
        
        /*if (component.get("v.IsStartDateChanged") && !component.get("v.externalper") && !component.get("v.activatingaccper") && (component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == 'None')) {
            localmsg = localmsg + "Select a reason for submitting a Past Dated Activity." + '\n';
            component.set("v.IsPR", true);
            validData = false;
        }*/
        //Adding a check for Other Reason Text Field - Akanksha, while activity creation
        /*if((startDate < todaysDate) && component.get("v.SelPotentialReason") == $A.get("$Label.c.Core_MDF_Other_Localized") && (component.get("v.newPFR.Core_MDF_Other_Reason_nm_txt__c") == null || component.get("v.newPFR.Core_MDF_Other_Reason_nm_txt__c") == "" || component.get("v.newPFR.Core_MDF_Other_Reason_nm_txt__c") == undefined || !reasonName.trim())){
            localmsg = localmsg + "Please enter Other Reason Name." + '\n';
            validData = false;
        }*/
        //POP and Attribution Requirements error message throw if field is empty
        /*if(component.get("v.isAttributionReqVisible") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Attribution_Requirements_txt__c"))){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_AttributionrequirementsError") + '\n';
        }
        if(component.get("v.isPOPReqVisible") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_POP_Requirements_txt__c"))){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_POPrequirementsError") + '\n';
        }*/
        
        /*else if(mode != 'clone' && component.get("v.IsStartDateChanged") && (component.get("v.externalper") || (component.get("v.activatingaccper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || opalBudgetTypes.includes(budgetType))){
            var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
            validData = false;
        }*/
        /*if (mode == 'clone') {
            if (startDate < todaysDate && 
                (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") && component.get("v.primaryaccper")) ||(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper"))) &&
                !component.get("v.externalper") && (component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')) {
                var alertMsg = "Select a reason for submitting a Past Dated Activity";
                helper.displaySuccessErrorMsg(alertMsg, "Error!", "error");
                component.set("v.IsPR", true);
                validData = false;
                 if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                        component.set("v.showSpinner", false);
                    }
            }
            else if(startDate < todaysDate && (component.get("v.externalper") || (component.get("v.activatingaccper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) 
                    && (opalBudgetTypes.includes(budgetType) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) {
                var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                validData = false;
            }
        } else if (mode == 'edit') {
            if (helper.isNotBlank(startDate) && helper.isNotBlank(oldStartDate) && startDate < todaysDate && oldStartDate != startDate && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") && component.get("v.primaryaccper")) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper"))) &&
                !component.get("v.externalper") && (component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')) {
                var alertMsg = "Select a reason for submitting a Past Dated Activity";
                helper.displaySuccessErrorMsg(alertMsg, "Error!", "error");
                component.set("v.IsPR", true);
                validData = false;
            }
        }*/
    	var recordTypeName = component.get("v.recordtypeDeveloperName");
        var proposalBasedCamp = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        var campaignBudget =  component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
        // EOL - commented below code associated with legacy
    //  if((recordTypeName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && campaignBudget != 'CCF 1.0' && campaignBudget != 'DCF 1.0'){
    /*  if(helper.availableBudgetCheck(component)){
                        validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_No_Available_Budgets_Warning") + '\n';
                }  
    }*/
        
        if(component.get("v.SelectedStatus") != ""  && component.get("v.SelectedStatus") != undefined && component.get("v.SelectedStatus") != null){
            if(component.get("v.SelectedStatus") == 'Cancelled' && component.get("v.SelectedStatus") != 'In-Progress' && component.get("v.checkCloneAttribute") != true
               && (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress' || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Closed'))
            {
                component.set("v.isSaveDisable", false); 
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
                      
                        if(helper.isNotBlank(result)/*result != undefined && result != null && result != ''*/){
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
                            }
                        }
                    }
                    else if(state === "ERROR"){
                        var toastEventfailure = $A.get("e.force:showToast");
                        toastEventfailure.setParams({
                            title: $A.get("$Label.c.Core_MDF_Error"),
                            message: $A.get("$Label.c.Core_MDF_ActivityCancelFail"),
                            type: "Error"
                           
                        });
                         toastEventfailure.fire();
                    }
                     
                });
                $A.enqueueAction(action);
            }
        }
	   
	   //Retail Changes -to send the activity to ATF queue for approval, when RSM creates the past dated activity  
        
      /*  if (helper.isNotBlank(startDate) && startDate < todaysDate && component.get("v.accmgrper") && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") &&
            component.get("v.mode") != 'edit' && !component.get("v.isEMEARegion")){
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                      
        }*/


        //Subtype validation when its mandatory     
        /*if (component.get("v.activitySubTypeAvailable") == true && (component.get("v.selActivitySubType") == "" || component.get("v.selActivitySubType") == null) && (component.get("v.selectedSubTypeOptions") == "" || component.get("v.selectedSubTypeOptions") == null)) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivitySubTypeError") + '\n';
            validData = false;
        }*/
        //Removing the status value in clone condition
        if(component.get("v.SelectedStatus") != "" && component.get("v.checkCloneAttribute")){
            component.set("v.SelectedStatus","");
        }
        //Error For $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") Error
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
		//TWC702-184
		if (helper.isNotBlank(component.get("v.recordId"))/*component.get("v.recordId") != null*/ && 
            component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && 
            component.get("v.checkCloneAttribute") == false && 
            component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail") && 
            !component.get("v.ipaApproverPer") && !component.get("v.priceReviewersPer") &&
            !component.get("v.opalAccountManagers") && !component.get("v.activatingaccper") && !component.get("v.primaryaccper")) {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_PendingReviewError") + '\n';
            validData = false;
        } 
		else if((component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF")||
            component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
            component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
			component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))&&
           !component.get("v.opalAccountManagers") && !component.get("v.priceReviewersPer") &&
           component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && !(component.get("v.priceReviewersPer") && component.get("v.componentAttributes.isLoggedInUserApprover")) && !(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.priceReviewersPer") || component.get("v.ipaApproverPer")) && helper.isCurrentUsrIsApprover(component)) ){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_PendingReviewError") + '\n';
            validData = false;
        } 

        //End

        //Ayush - New Category Change
        //Added below code on save to check (if start date in 2025 and old categories selected) then throw error or vice versa. 
        //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
        /*if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && helper.isNotBlank(startDate) && helper.isNotBlank(component.get("v.SelCategory"))) {
            if(new Date(startDate).getUTCFullYear() < $A.get("$Label.c.Core_MDF_NewCategoryDate") && helper.isLatestCategory(component)){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivityNewCategoryError") + '\n';
            }  
            else if(new Date(startDate).getUTCFullYear() >= $A.get("$Label.c.Core_MDF_NewCategoryDate") && !helper.isLatestCategory(component)){
                validData = false;
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivityNewCategoryError") + '\n';

            }
        }*/

    /*  if(component.get("v.userWithoutAccess") && 
        !((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
            && helper.isCurrentUsrIsApprover(component)) && !component.get("v.priceReviewersPer")){
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_CloneAccessError") + '\n';
        validData = false;
    }*/
        //Error if mandatory fields are blank in "My Activities" page
        /*var metrics = component.find("kpiFields");
        if(helper.isNotBlank(metrics)/*metrics != null && !metrics.isFormValid()){
            var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
            helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
    	    validData = false;
        }*/
		
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
        
        /*if(component.get("v.enableEventFormat")){
            if(!$A.util.isEmpty(component.get("v.selectedEventFormat"))){
                component.set("v.newPFR.Core_MDF_Event_Format_Nm__c", component.get("v.selectedEventFormat"));
            }else{
                
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_Activity_Event_Form_Error") + '\n';
                validData = false; 
                
            }
        }else{
            component.set("v.newPFR.Core_MDF_Event_Format_Nm__c", null);
            component.set("v.selectedEventFormat", null);
        }*/
        
        
        //US1106484: [WW44] - [RMF] - [Internal Users] - Approver Notifications
    //  if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && helper.isNotBlank(component.get("v.recordId"))/*component.get("v.recordId") != null*/ && component.get("v.mode") == 'edit'){
        
        /*if(component.get("v.retailgeouserper")){
            component.set("v.newPFR.Core_MDF_UserRole_txt__c", 'Geo Lead');                
        }else if(component.get("v.accmgrper")){
            component.set("v.newPFR.Core_MDF_UserRole_txt__c", 'RSM');
            //Reset ATF ind on Account Manager edit for Revision Required & Planned Activity
            
        } */          
    //  }
    
    
    //Error for Rejected Retail Activities
    //   if (helper.isNotBlank(component.get("v.recordId"))/*component.get("v.recordId") != null*/ && component.get("v.CurrentStatus") == 'Rejected'
        /*   && component.get("v.SelectedStatus") != 'Cancelled'
        && component.get("v.checkCloneAttribute") == false && 
        recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail"))
    {
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_RejectedError_Retail") + '\n';
        validData = false;
    }*/
    
    /*Error when new end date is less than old end date*/
    /*if ((helper.isNotBlank(edate) && helper.isNotBlank(oldedate)&& edate<oldedate) && accmgrper && oldstatus == 'Planned' &&
        recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")  && !component.get("v.checkCloneAttribute"))
    {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_End_Date_Mod_Error") + '\n';
        validData = false;
    }*/
        if ((helper.isNotBlank(stdate) && helper.isNotBlank(oldstdate) && stdate>oldstdate) && accmgrper && oldstatus == 'In-Progress'  && !component.get("v.checkCloneAttribute"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_Date_Mod_Error") + '\n';
            validData = false;
        }
	
        // OPAL changes Start
        // Error when external user create/edit an opal activity and selects DCF SMF Sub type
        /*if(component.get("v.externalper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") && component.get("v.activitySubTypeAvailable")){
            var selectedsubTypes = component.get("v.selectedSubTypeOptions");
            var subTypeDCFSMF = $A.get("$Label.c.Core_MDF_ActSubType_DCF_SMF");
            var isRecIdNotBlank = helper.isNotBlank(component.get("v.recordId"));
            var existingSubType = component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c");
            if(selectedsubTypes!=null){
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
        }  */ 
        //TWC702-184
        var budgetTypeArr = component.get("v.budgetTypeVal");
    //   if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")){
        /*  if ((component.get("v.selBudgetType") == "" || component.get("v.selBudgetType") == null) && component.get("v.isBTSelAtCampaign") && budgetTypeArr.length>0 ) {
            
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_BudgetType_ErrMsg") + '\n';
            validData = false;
        }
            if(helper.isNotBlank(budgetTypeArr) && budgetTypeArr.length>0 && (component.get("v.isOpalActivity") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) && (component.get("v.selAvailableBudget") == null  || component.get("v.selAvailableBudget") == undefined || component.get("v.selAvailableBudget") =="")){
            validData = false;
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_AvailableBudget_ErrMsg") + '\n';
        }
}*/
        
    /*  if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")
            && (component.get("v.selAvailableBudget") == null  || component.get("v.selAvailableBudget") == undefined || component.get("v.selAvailableBudget") ==""))
    {
        validData = false;
        localmsg = localmsg + $A.get("$Label.c.Core_MDF_AvailableBudget_ErrMsg") + '\n';            
    }*/
    // if((((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) && component.get("v.isOpalActivity")) 
        //   )  && helper.isNotBlank(component.get("v.FlexiReimbursementAmt")) && helper.isNotBlank(component.get("v.newRRValue"))){
        /*  if(component.get("v.newRRValue") > 100){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_NewRR_ErrMsg") + '\n';
            validData = false;
        } else if(component.get("v.newRRValue") <= 0){  //US904056 - [Opal] CCF and DCF - Error if RR calculation is 0%
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_ZeroPercentRR_ErrMsg") + '\n';
            validData = false;
        }
    }*/
        

        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") && component.get("v.showOtherEngAct") && component.get("v.isOtherEngActRequired") && component.get("v.SelEngineeringActValue") != null /*$A.get("$Label.c.Core_MDF_Other_Localized")*/ && !helper.isNotBlank(component.get("v.newPFR.Core_MDF_Other_Engineering_Activity_txt__c")) ){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Other_Engineering_Activity_Error") + '\n';
            validData = false;
        }
        
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") && $A.util.isEmpty(component.get("v.SelEngineeringActValue")) ){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Engineering_Activity_Error") + '\n';
            validData = false;
        }

        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") && $A.util.isEmpty(component.get("v.SelPOPRequirementValue")) ){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_POP_Requirement_Error") + '\n';
            validData = false;
        }

        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") && $A.util.isEmpty(component.get("v.selAvailableBudget")) ){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_AvailableBudget_ErrMsg") + '\n';
            validData = false;
        }
        
         //Start
        //Activity in-progress to cancel && IPA Proposal based Planned/In-Progress(Restrict for proposal completed)
        
        var cancelEligibleStatusPFR = $A.get("$Label.c.Core_MDF_PFR_cancel_eligible_status").split(";");
        var pfrStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var pfrSelectedStatus = component.get("v.SelectedStatus");
        var proposalInd = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        if(pfrSelectedStatus != '' && pfrSelectedStatus != undefined && pfrSelectedStatus != null){
            if(pfrSelectedStatus == $A.get("$Label.c.Core_MDF_Activity_Cancelled_Status") && component.get("v.checkCloneAttribute") != true
              && (((pfrStatus == $A.get("$Label.c.Core_MDF_pfrInprogress") || pfrStatus == $A.get("$Label.c.Core_MDF_PFR_Status_Closed")))||
                 (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") && cancelEligibleStatusPFR.includes(pfrStatus) && validData))){
                    
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
        
        // OPAL changes End
	
		//US851183 - Error when Geo lead is changing an Activty type from Non-SPIF to SPIF or SPIF to Non-SPIF
	    //Update - Geo lead as well as EMEA reviewer will not be able update from Non-SPIF and SPIF to SPIF or SPIF to Non-SPIF
		//US1109882 - Updated condtion to throw error message only when user having Single(Geo Lead) Permission
       
	//US917622 - opal changes potential winner/number of expected -start 
        /*var lwcKpiFieldsPotentialWinner = component.find("kpiFields");  
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
        }*/
        //US917622 - opal changes potential winner/number of expected -end 
        //Section to check if EEF Metrics field modified
        /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            var lwccomp = component.find("kpiFields");
            var kpiValues = lwccomp.getKPIValues();
            if (kpiValues != null) {
                var isMetricsFieldModified = lwccomp.isMetricFieldModified(kpiValues);
                if(isMetricsFieldModified){
                component.set("v.isEEFMetricsModified",isMetricsFieldModified);
                }
            }
            
            
        }*/
        
        /* Checking if Segment Component present and assigning segment string to attribute */
        
        var activityType =  component.get("v.SelActivityType");
         var activityAmount = component.get("v.activityAmount");
	    component.set("v.segmentString",'');
        /*if(spifActivityTypes.includes(activityType)) {
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
                if(segmentValues.length == 0) {
		   lwcSegmentcomp.isFormValid();		
                   validData = false;
		   component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",false);
                   var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                   helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                        component.set("v.showSpinner", false);
                    }
                } 
                else if(activityAmount < spifAmount){
                    validData = false;
                    var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                     if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                        component.set("v.showSpinner", false);
                    }
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
                }
            }
                
           }
        }*/
       
                                                   
        /*if ((((component.get("v.retailgeouserper") && component.get("v.mode") == 'edit' && ((component.get("v.CurrentStatus") == 'Revision Required' && component.get("v.newPFR.Core_MDF_Start_Date__c") < todaysDate) || component.get("v.CurrentStatus") == 'Closed' || component.get("v.CurrentStatus") == 'Planned')))  || (component.get("v.rsmActivityReviewerper") && component.get("v.accmgrper") == false)) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
            var existingActType = component.get("v.oldActivtyType");
			var currActivityType =  component.get("v.SelActivityType");
			
			//Commenting as auditors are not allowed to edit Activity in closed status as per existing functionality
			 
             
			if((!spifActivityTypes.includes(currActivityType) && spifActivityTypes.includes(existingActType))
              		   || (spifActivityTypes.includes(currActivityType) && existingActType != currActivityType)){
                localmsg = localmsg + $A.get("$Label.c.Core_MDF_SPIF_Act_Type_Change_Err") + '\n';
            			validData = false;
        		}
             
         
		}*/
		  //US1047178: [IPA] BU Mapping - this method is use to check validation of BU split and stored the value
        /*var buSupprtPrg = $A.get("$Label.c.Core_MDF_BU_Split_Supported_Prg").split(";");
        if(buSupprtPrg.includes(recordTypeDeveloperName)){
            if(component.get("v.showBUSPlitMultiselect")  &&   component.get("v.buSplitSelectedList") != undefined &&  component.get("v.buSplitSelectedList") != null && component.get("v.buSplitSelectedList") != ''){
            var  metadataBuSplitData = []; 
            metadataBuSplitData = component.get("v.metadataBuSplitMap");
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
            component.set("v.busplitTotalPercentage",totalPercentage);    
            
        }
        }*/
        var actStatus = component.get("v.CurrentStatus");
        var existingOwner = component.get("v.existingIntelOwner");
        var mode = component.get("v.mode");
        var selAppLst = component.get("v.selectedApproverOptions");
        var actSelType = component.get("v.SelActivityType");
        var actSelCategory = component.get("v.SelCategory");
        /*if(actStatus != 'Planned' && isExternal && component.get("v.displayApprovers") && helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType") )){
        	if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
               || (component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType") && component.get("v.intelOwnerReq"))
         		/*|| ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Event" && intelContri >= "50000") || ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Digital Media" && component.get("v.SelActivityType") ==  $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))
              || helper.isCMPEligibleApproval(component, budType, actSelType, actSelCategory, intelContri,actDomainType)){
        			for(var i=0;i<=selAppLst.length;i++){
            			if(selAppLst[i]=="" || selAppLst[i]==''){
                            if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Intel_Owner"))){
                            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Intel_Owner") + '\n';
            				validData = false; 
                            }
            			}
        			}
        		}
        	}*/
        /*if(actStatus == 'Planned' && component.get("v.isOwnerInactive") && isExternal){   
            helper.setActwithNewValues(component);
            if(helper.isOpalRevReqActModified(component) || helper.isEEFActivitywithApplicableFieldModified(component)){
            if(helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType") )){
                    if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") || 
                       component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")
                      || helper.isCMPEligibleApproval(component, budType, actSelType, actSelCategory, intelContri,actDomainType)){
                         var newApprover = component.get("v.selectedApproverOptions");
                        var newSelApp = "";
                        for(var j=0;j<newApprover.length;j++){
                            newSelApp=newApprover[j];
                        }
                        component.set("v.selectedApproverOptions","");
                        var allApprovers = component.get("v.AllApproverOptions");
                        var newApproverList = new Array();
                        for(var i=0;i<allApprovers.length;i++){
                            if(allApprovers[i].value != newSelApp){
                                newApproverList.push({
                                    label: allApprovers[i].label,
                                    value: allApprovers[i].value
                                })
                            }
                        }
                        component.set("v.AllApproverOptions",newApproverList);
                        if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Intel_Owner"))){
                            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Intel_Owner") + '\n';
            			validData = false; 
                        }
                        
        			}
            	}
        }
        }*/
        
        //To check Primary Intel Owner in Planned Status
          /*if(actStatus == 'Planned' && component.get("v.isOwnerInactive") && (isExternal || isActivatingaccper)){   
            helper.setActwithNewValues(component);
            if(helper.isEEFActivitywithApplicableFieldModified(component)){
                if(helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id")) && helper.isNotBlank(component.get("v.selBudgetType") ) && component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
       
                        var newApprover = component.get("v.selectedPrimaryApproverOptions");
                        var newSelApp = "";
                        for(var j=0;j<newApprover.length;j++){
                            newSelApp=newApprover[j];
                        }
                        component.set("v.selectedPrimaryApproverOptions","");
                        var allApprovers = component.get("v.AllPrimaryApproverOptions");
                        var newApproverList = new Array();
                        for(var i=0;i<allApprovers.length;i++){
                            if(allApprovers[i].value != newSelApp){
                                newApproverList.push({
                                    label: allApprovers[i].label,
                                    value: allApprovers[i].value
                                })
                            }
                        }
                        component.set("v.AllPrimaryApproverOptions",newApproverList);
                        if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Pri_Intel_Owner"))){
                            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Pri_Intel_Owner") + '\n';
                            validData = false; 
                        }
                        
                    
                }
            }
        }*/
        
        
        /*if(actStatus == 'Planned' && component.get("v.isExtActSubmitterInactive") && (isInternal || isActivatingaccper || isPrimaryaccper )){
            helper.setActwithNewValues(component);
            if(helper.isOpalActivitywithApplicableFieldModified(component) || helper.isEEFActivitywithApplicableFieldModified(component)){
                if(helper.isNotBlank(component.get("v.selectedPartner.Id")) && helper.isNotBlank(component.get("v.selBudgetType") )){
                    if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
                       || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")
                       || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")){
                        var newExtActSubmitter = component.get("v.selectedExtActSubmitterOptions");
                        var newSelSub = "";
                        for(var j=0;j<newExtActSubmitter.length;j++){
                            newSelSub=newExtActSubmitter[j];
                        }
                        component.set("v.selectedExtActSubmitterOptions","");
                        var allExtActSubmitters = component.get("v.AllExtActSubmitterOptions");
                        var newExtActSubmitterList = new Array();
                        for(var i=0;i<allExtActSubmitters.length;i++){
                            if(allExtActSubmitters[i].value != newSelSub){
                                newExtActSubmitterList.push({
                                    label: allExtActSubmitters[i].label,
                                    value: allExtActSubmitters[i].value
                                })
                            }
                        }
                        component.set("v.AllExtActSubmitterOptions",newExtActSubmitterList);
                        if(!localmsg.includes($A.get("$Label.c.Core_MDF_Select_One_Partner_Activity_Owner"))){
                            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Select_One_Partner_Activity_Owner") + '\n';
                            validData = false;
                        }
		}
	    }
	}
       }*/
        // If all the Entered Data are valid in terms of text or Number
        if(validData){
            //set PFR record with selected values
            component.set("v.newPFR.CampaignId",component.get("v.selectedLookUpRecord").Id); 
            component.set("v.newPFR.Core_MDF_Event_Name_nm__c",component.get("v.selActivityEventName"));
            component.set("v.newPFR.Core_MDF_Domain_Type_nm__c",component.get("v.SelDomainType"));
            if(helper.isNotBlank(component.get("v.activityOwner")) && !component.get("v.externalper") && !component.get("v.primaryaccper")){
				component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c",component.get("v.activityOwnerId"));
			}
            if(helper.isNotBlank(component.get("v.activityOwner")) && !component.get("v.externalper") && !component.get("v.activatingaccper")){
                component.set("v.newPFR.Core_MDF_Primary_Intel_Owner_Id__c",component.get("v.activityOwnerId"));
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
            //POP and Attribution Requirments changes if activity type is not other.
            var activityType = component.get("v.SelActivityType");
            var otherActTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
            if(helper.isNotBlank(activityType) && helper.isNotBlank(otherActTypes) && !otherActTypes.includes(activityType)){
                component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
            }
            
          component.set("v.newPFR.Core_MDF_Require_Additional_Review_ind__c",component.get("v.isAdditionalReviewReqd"));
          // OPAL changes starts
    //  if (component.get("v.isBTSelAtCampaign") && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF"))) {
            /*commenting this as part of Duplicate Field Removal Changes*/     
            //component.set("v.newPFR.Core_MDF_Budget_Type_txt__c", component.get("v.selBudgetType"));
        // US949836 : New Budget Type field changes replaced txt field with new global picklist field
        /*  component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selBudgetType"));
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.SelReimbursementRate"));                   
                component.set("v.newPFR.Core_MDF_MDFReimbursement_Amt__c", component.get("v.FlexiReimbursementAmt"));
            //US924033
            if(component.get("v.CPLed") && component.get("v.SelChannelPartner") == ''){
                component.set("v.SelChannelPartner", 'None');
            }
            
        }*/
        //else if(!component.get("v.isOpalActivity") && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF"))){
            /*commenting this as part of Duplicate Field Removal Changes*/
            //component.set("v.newPFR.Core_MDF_Budget_Type_txt__c", $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0"));
    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
    //component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0"));
    //    }
    //	else if(!component.get("v.isOpalActivity") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")){
            /*commenting this as part of Duplicate Field Removal Changes*/ 
            //component.set("v.newPFR.Core_MDF_Budget_Type_txt__c", $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0"));
                // US949836 : New Budget Type field changes replaced txt field with new global picklist field
    //		 component.set("v.newPFR.Core_MDF_Budget_Type_nm__c",  $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0"));
    //	}
        // OPAL changes ends
        //EEF Budget Type Stamp
        /* if ( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")) {
            component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selBudgetType"));
                }*/
	    
            
          if (component.get("v.SelChannelPartner") != "Others" && component.get("v.SelOtherChannelPartner") != "" && !component.get("v.isOpalActivity")){
              component.set("v.SelOtherChannelPartner", "");
              }
            component.set("v.newPFR.Core_MDF_ActivityCategory__c",component.get("v.SelCategory"));
            component.set("v.newPFR.Core_MDF_Activity_Types__c",component.get("v.SelActivityType"));
            component.set("v.newPFR.Core_MDF_Brand_nm__c", component.get("v.selectedBrandOptions"));
            component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
            component.set("v.newPFR.Core_MDF_TargetAudience__c",component.get("v.SelTargetAudience"));
            component.set("v.newPFR.RecordTypeId",component.get("v.recordtype"));
            component.set("v.newPFR.Core_MDF_Channel_Partner__c",component.get("v.SelChannelPartner"));
            component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c",component.get("v.SelOtherChannelPartner"));
            component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",component.get("v.CPLed"));
            component.set("v.newPFR.Core_MDF_Activity_Engineering_Nm__c",component.get("v.SelEngineeringActValue"));
            component.set("v.newPFR.Core_MDF_POP_Requirement_nm__c",component.get("v.SelPOPRequirementValue"));
           /* var multiBrand=component.get("v.selectedBrandOptions");
            var multiBrandList="";*/
          //  if(helper.isNotBlank(multiBrand)/*multiBrand != null && multiBrand != undefined*/){
              /*  for(var i=0;i<multiBrand.length;i++){
                    if (i != multiBrand.length - 1) multiBrandList += multiBrand[i] + ";";
                    else multiBrandList += multiBrand[i];
                }
            }*/
           // component.set("v.newPFR.Core_MDF_Brand_nm__c",multiBrandList );
            var initiativeValues=component.get("v.selectedInitiativeOptions");
            var initiativeValList="";
            if(helper.isNotBlank(initiativeValues)){
                for(var i=0;i<initiativeValues.length;i++){
                    if (i != initiativeValues.length - 1) initiativeValList += initiativeValues[i] + ";";
                    else initiativeValList += initiativeValues[i];
                }
            }
            component.set("v.newPFR.Core_MDF_Initiative_nm__c",initiativeValList );
	      //US1115938 - OPAL Past Dated Activity Submission process
            if(!component.get("v.externalper") && !component.get("v.activatingaccper")){
            //  if ((startDate < todaysDate)  && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && (component.get("v.accmgrper") ||component.get("v.priceReviewersPer") || component.get("v.retailgeouserper") || component.get("v.rsmActivityReviewerper"))) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")) )){
                /*  component.set("v.newPFR.Core_MDF_ReasonforPastDatedActivity_Nm__c", component.get("v.SelPotentialReason"));                 
            }
            else{*/
                component.set("v.newPFR.Core_MDF_ReasonforPastDatedActivity_Nm__c", null); 
                //Reason Name to be set as null - in case, the activity has been edited from a past date to a present or future date 
                component.set("v.newPFR.Core_MDF_Other_Reason_nm_txt__c", null);                 
            //   }  
        }
        /*   else{
            if((startDate >= todaysDate) && (opalBudgetTypes.includes(budgetType) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
                component.set("v.newPFR.Core_MDF_ReasonforPastDatedActivity_Nm__c", null);
                //Reason Name to be set as null - in case, the activity has been edited from a past date to a present or future date 
                component.set("v.newPFR.Core_MDF_Other_Reason_nm_txt__c", null);
            }
        }*/
          
            //US945323 - set the channel program led value to true if SelChannelPartner != None and set it to false if SelChannelPartner == None for OPAL -- start
    /*  if(component.get("v.isOpalActivity") && !component.get("v.selectedIndPartnerOptions").includes('None') ){
            component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",true);
        }
        if((component.get("v.isOpalActivity") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))&&component.get("v.selectedIndPartnerOptions").includes('None')){
            component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",false);
        }*/
            //US945323 - set the channel program led value to true if SelChannelPartner != None and set it to false if SelChannelPartner == None for OPAL -- end
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.CurrentStatus"));
            component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
            component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
            component.set("v.newPFR.Core_MDF_Joint_Content_ind__c",component.get("v.JointContent"));
            //Country Multi Select
            component.set("v.newPFR.Core_MDF_Country_nm__c",component.get("v.SelMarketValue"));  
            component.set("v.newPFR.Core_MDF_Channel_Partner__c",component.get("v.SelChannelPartner"));
            
          
            
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
 			//US964896: TECH [DCF/SPCF] - [OOC] - 60% RR for Intel Select Solutions
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
		  
        /*  if((component.get("v.isOpalActivity") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) {
            component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selectedSubTypeOptions"));
            component.set("v.newPFR.Core_MDF_Industry_Multi_nm__c",component.get("v.selectedIndustryOptions")); //pass industry value to instance
            var multiIndustry=component.get("v.selectedIndustryOptions");
            var multiIndustryList="";
            if(helper.isNotBlank(multiIndustry)){
                for(var index=0;index<multiIndustry.length;index++){
                    if (index != multiIndustry.length - 1) multiIndustryList += multiIndustry[index] + ";";
                    else multiIndustryList += multiIndustry[index];
                }
            }
            component.set("v.newPFR.Core_MDF_Industry_Multi_nm__c",multiIndustryList);

            //US964916: [Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
            
            //IPLed
            if (!(component.get("v.selectedIndPartnerOptions").includes("Others"))  && component.get("v.SelOtherChannelPartner") != ""){
                component.set("v.SelOtherChannelPartner", "");
            }
            //Industry partner Led IPLed
            var selectIndPartnr =component.get("v.selectedIndPartnerOptions");
            component.set("v.newPFR.Core_MDF_Channel_Partner__c", selectIndPartnr.join(";"));
            component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c", component.get("v.SelOtherChannelPartner") );
            }*/
             //Added extra condition to fix Defect DE117182  
            if(!component.get("v.isOpalActivity") && !(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")) && component.get("v.selectedSubTypeOptions") == null ) {
                component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c",null);
            }
            
        /*  if ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")  ||recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) 
            && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
            if(component.get("v.campriorityValue") == false ){
                component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.selectedLookUpRecord").Core_MDF_Priority__c); 
            }
            else{
                component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.campriority"));
            }
                if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
            component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selActivitySubType"));	
            
            /*commenting this as part of Duplicate Field Removal Changes*/
                //component.set("v.newPFR.Core_MDF_Budget_Type_txt__c",component.get("v.selectedLookUpRecord").Core_MDF_Budget_Type_txt__c);
    // US949836 : New Budget Type field changes replaced txt field with new global picklist field
/*	component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selectedLookUpRecord").Core_MDF_Budget_Type_txt__c);				
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
        else*/
        //  {
            component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.selectedLookUpRecord").Core_MDF_Priority__c);
        //  }
            if(component.get("v.SelectedStatus") != "" ){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.SelectedStatus"));
            }
            
            // Making Id null in order to save New Record from clone
            if(component.get("v.checkCloneAttribute")){
 //US1082873: [IPA MDF] - Campaign - Clone a Proposal - Activity Section - if its clone from campaign then dont make id null
              if(component.get("v.pfrCloneCheck")){
                  
              }else{
                component.set("v.newPFR.Id", null);
              component.set("v.recordId", null);
              component.set("v.newPFR.CreatedDate", null);
              component.set("v.newPFR.Core_MDF_Activity_Closure_Type__c", '');
              }

                if(!component.get("v.isOpalActivity") && !component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") && !component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                    component.set("v.newPFR.BudgetId", null);  
                    component.set("v.newPFR.AllocationId", null);   
                } 
            }
        // if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) &&
        /* component.get("v.recordId") == null && component.get("v.isLoggedInUserLevelOneApprover")){
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",1);     
            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');     
        }*/
        
        /*   if(component.get('v.activatingaccper') && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") && component.get("v.mode") != 'edit'){
        component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",1); 
        }
        if(component.get('v.primaryaccper') && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") && component.get("v.mode") != 'edit'){
        component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",2); 
        }*/

          if ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType"))) {
            if ((oldpfrStatus != 'Pending Review' && oldpfrStatus != 'Revision Required' && oldpfrStatus != 'Closed'
                 && component.get("v.cmpgnStatus") == 'Draft')
                || oldpfrStatus == '') {
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", "Draft");
            }
        }
            //Enabe Activity type edit for CCF Planned status
            
            var oldedate = component.get("v.oldedate");
            var oldpfrStatus = component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c");
            
            
            //US824760: [RMF] [WW51] Approval flow when Geo Lead edit Activities
            var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
          //DE115095 : WW19 | DEVINT3 | When Geo Lead edits an Activity,
          //which is in Planned status and changes the start date to 1 day minus today,
          //then Activity re approval is getting triggered
          var today = helper.getTodayDateLocalTime();
                  
          
/*  if(helper.isNotBlank(component.get("v.recordId")) && 
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
        } */

            if (component.get("v.recordId") != null && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType"))){
                if (!component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                    !$A.get("$Label.c.Core_MDF_PFR_RestrictStatusChange").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                    helper.setNREactivityStatus(component);
                }
            }
            
           
            if (helper.isNotBlank(component.get("v.recordId")) && ((component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_IPA_RecordType")))) {
                //Account Manager - - 
                //Activty  Status In cancelled/ In-Progress, Closed , we donot set to Pending Review planned
                //Core_MDF_PFR_RestrictStatusChange - In-Progress, Closed 
                if(component.get("v.SelectedStatus") != undefined && !component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
                   !$A.get("$Label.c.Core_MDF_PFR_RestrictStatusChange").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {
                    
                    /*if(component.get("v.accmgrper") && !component.get("v.opalAccountManagers") && component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
                        var editedFieldRequiresApproval = component.get("v.activityFieldSetList");                        
                            if(helper.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval)){
                                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_CCP_Planned_Status")); 
                            }
                    }else{
                        helper.setfundRequestStatusHelper(component);
                    }*/
                    //Set the Fund Request Status based on criteria's - ContentCreateActivty or event or Revision Required or Retail  
                    
                }
            }
            //Ayush Commented - not needed
            /*else if(component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status") && component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            }*/
         // US945421: [DCF/SPCF] - Capping of 10% on RR for DCF/SPCF If activity date,technology,brand,Activity type are matching- start
         // EOL - commented below code associated with Legacy Program
          if (component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == 'Yes' && (component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == 'No' || component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == null)
              && component.get("v.incentive") && component.get("v.SelReimbursementRate") 
              && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") /*|| component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_SPCF")*/)
              && (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                  component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") ||
				  component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == null || component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == "" ) ) {
              
              var calIncentive = (parseFloat(component.get("v.SelReimbursementRate")) + parseFloat(component.get("v.incentive")));  
              var newRRPer = (calIncentive > 100? 100: calIncentive);
              var newRRDecValue = parseFloat(newRRPer.toFixed(2));  
              var newRRPerVal = newRRDecValue +"%";
              component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",newRRPerVal); 
          }
          //US945421: [DCF/SPCF] - Capping of 10% on RR for DCF/SPCF If activity date,technology,brand,Activity type are matching- end
			//US1011425: Customer Auto Approval for MDF and MDF+ if no edit done by internal account manager - start
          var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
          var removeFieldNotReqVal = editedFieldRequiresApproval.toString().replace(',Core_MDF_Require_Additional_Review_ind__c', '');
          var convertArrayFieldSet = removeFieldNotReqVal.split(',');
          //TO BE COMMENTED - AKANKSHA
          if((helper.fieldEligibleForApprovalModified(component, convertArrayFieldSet) || component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") == true) && component.get("v.mode") == 'edit' &&
             component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_CCP_Planned_Status") && component.get("v.opalAccountManagers") &&
             (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") || 
             component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
             component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") /*|| (((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")))&& component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false)*/)) {
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
	    //Added EEF
            if(!component.get("v.displayApprovers")){
                component.set("v.newPFR.Core_MDF_Intel_Activity_Owner_Id__c",null);
                component.set("v.newPFR.Core_MDF_Primary_Intel_Owner_Id",null);
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
            /* var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                    component.set("v.showSpinner", false);
            }*/
              
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
                //US757352 - [RMF] update the Event ethics popup
            /* if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Event_Ethic"));
            } else {*/
                component.set("v.EventMessage",$A.get("$Label.c.Core_MDF_Terms"));
            //  }
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
                component.set("v.newPFR.Core_MDF_Competitive_Elements__c",pfr.Core_MDF_Competitive_Elements__c);//event.getParam("compCheck"));
                component.set("v.competetiveElement",pfr.Core_MDF_Competitive_Elements__c);
            }
            if (helper.isNotBlank(pfr.Core_MDF_Government_Nexus__c))
                component.set("v.newPFR.Core_MDF_Government_Nexus__c",pfr.Core_MDF_Government_Nexus__c);//event.getParam("govCheck"));
            if (helper.isNotBlank(pfr.Core_MDF_ofPagesEligible__c ))
                component.set("v.newPFR.Core_MDF_ofPagesEligible__c",pfr.Core_MDF_ofPagesEligible__c);// event.getParam("pageEligible"));
            if (helper.isNotBlank(pfr.Core_MDF_pagespayingfor__c ))
                component.set("v.newPFR.Core_MDF_pagespayingfor__c",pfr.Core_MDF_pagespayingfor__c);//event.getParam("pagePaying"));
            if (helper.isNotBlank(pfr.Core_MDF_Incentive_Opted_In_ind__c)/*pfr.Core_MDF_Incentive_Opted_In_ind__c != null && pfr.Core_MDF_Incentive_Opted_In_ind__c != undefined*/){
                component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",pfr.Core_MDF_Incentive_Opted_In_ind__c);
            	component.set("v.incentivePercent",pfr.Core_MDF_Incentive_Opted_In_ind__c);
            }
            if (helper.isNotBlank(pfr.Core_MDF_Incentive_Question_ind__c)/*pfr.Core_MDF_Incentive_Question_ind__c != null && pfr.Core_MDF_Incentive_Question_ind__c != undefined*/)
                component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c",pfr.Core_MDF_Incentive_Question_ind__c);  
        }
    },
    
/* resetIntelContribution: function(component, event, helper){
    helper.fetchApprovers(component);
},*/ 
    // Function called on the load of the page 
    // Contains two Part:- Edit scenario (where we set the values to attribute from the record fields )
    // New Scenario (where we create record type filter )
    doInit: function(component, event, helper) {
        helper.partnerEffortMetricForActivityCreation(component);
        helper.getInitialDataFromServer(component, event);
        helper.onStartDateChange(component);
	var recordTypeDeveloperName;
	
        if(component.get("v.apitoLabelConvert") == null){
            var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
            var fieldlist = fields.split(",");
            helper.convertApitoLable(component,fieldlist);
        }
        //alert('Campaign Account'+component.get("v.selectedLookUpRecord.Core_MDF_Account__c")); 
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
        component.set("v.StatusLabel",displayStatus);
        
        //Load the metadata Value on the load of the pagevar recordTypeDevName;
        var recordTypeDevName;
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
                console.log('**hascreateaccess**',component.get("v.hasCreateAccess"));
                console.log('**mode**',component.get("v.mode"));
                if(component.get("v.hasCreateAccess") == false && component.get("v.mode") == ''){
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
        //Display Domain Type field only when Activity Category is Digital 2025
        let activityCategory = ($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory")) ? true : false
        if (helper.isNotBlank(activityCategory) && activityCategory) {
            component.set("v.isDomainTypeVisible", true);
        } else {
            component.set("v.isDomainTypeVisible", false);
        }
        //label to bypass -> bypassNewCategoryFilter -> New 
        //if label != empty and label.ignorecase = true then bypass
        //Ayush - New Activity Category/Type Changes 
        if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true"){
            helper.getNewCategoryValues(component, recordTypeDevName);
        }
        
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
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_NRE_Account_Manager");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["accmgrper"]=permissionSets;

        //Akash - Added PS to allow external user to edit in planned status
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Co_GTM_Project_Submitter");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["extprojsubmgrper"]=permissionSets;
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Retail_Geo_User");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["retailgeouserper"]=permissionSets;
        permissionSetName = $A.get("$Label.c.Core_MDF_Retail_Reviewer_Permission_Set");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["rsmActivityReviewerper"] = permissionSets;
        
	/*Start - EEF Permission sets */
        permissionSetName = $A.get("$Label.c.Core_MDF_EEF_Int_Primary_Partner");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["primaryaccper"]=permissionSets;
         
        permissionSetName = $A.get("$Label.c.Core_MDF_EEF_Int_Activating_Partner");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["activatingaccper"]=permissionSets;
        
        /*End - EEF Permission sets */
        
        permissionSetName = $A.get("$Label.c.Core_MDF_IPA_Approver");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["ipaApproverPer"] = permissionSets; 
        
        permissionSetName = $A.get("$Label.c.Core_MDF_OpalAccountManagers");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["opalAccountManagers"] = permissionSets;
	
	
        permissionSetName = $A.get("$Label.c.Core_MDF_PriceReviewers");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["priceReviewersPer"] = permissionSets;
        
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_RMF");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["rmfexternalper"] = permissionSets;
        permissionSetName = $A.get("$Label.c.Core_MDF_RMF_USER");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["rmfextuserper"] = permissionSets;
		
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
            
            //Blocking Legacy activities
            helper.handleLegacyActivityCreation(component,event);
            helper.handleLegacyActivityCloneEdit(component,event);
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
            if (mode == "" && (component.get("v.accmgrper") || component.get("v.externalper") ||  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") ) && component.get("v.isActivityCreationOnCampaign")) {
                
                if(helper.isNotBlank(component.get("v.selectedLookUpRecord.Id"))/*component.get("v.selectedLookUpRecord.Id") != null && component.get("v.selectedLookUpRecord.Id") != ''*/){
                    
                    var endDate = component.get("v.selectedLookUpRecord.EndDate");
                    var startDate = component.get("v.selectedLookUpRecord.StartDate");
                    var ultimateAccId = component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c");
                    var strategicMarketingFund = component.get("v.selectedLookUpRecord.Core_MDF_Strategic_Marketing_Fund_Ind__c"); 
                    component.set("v.newPFR.Core_MDF_End_Date__c", endDate);
                    component.set("v.newPFR.Core_MDF_Start_Date__c", startDate);  
                    component.set("v.newPFR.Core_MDF_Strategic_Marketing_Fund_Ind__c ", strategicMarketingFund);
                    
                    if(recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_Retail"))
                    {
                    helper.fetchCampBudgetInfo(component, event, helper, true);
                    }

                /*  if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail"))
                {
                    helper.fetchBudgetInfo(component);//call when activity is getting created
                }*/
                    //TO BE COMMENTED - AKANKSHA
                    if(/*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") ||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost") ||*/
                    /*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ||*/
                    //  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
                    helper.activityPicker(component, recordTypeDeveloperName);
                }
                /*  if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")|| recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
        var singlePriorityType = [];
        var multiplePriorityType = [];
        if (helper.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Priority__c"))) {
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
            var selectedPriority ='';
            if (helper.isNotBlank(singlePriorityType )) {
                for (var i = 0; i < singlePriorityType.length; i++)
                    multiplePriorityType.push({
                        key: singlePriorityType[i].label,
                        value: singlePriorityType[i].value
                    });
                    if(singlePriorityType[0]){
                            selectedPriority = singlePriorityType[0].value ;
                        }
                        }
                    if(component.get("v.mode") == ""){
                    component.set("v.campriority",selectedPriority);
                    }
                    component.set("v.PriorType", multiplePriorityType);
                    component.set("v.campriorityValue", true);
                    }
                }*/
                }
            /*    if ((!component.get("v.externalper"))&& startDate < todayDate && (opalBudgetTypes.includes(budgetType) ||(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) 
        //)) {
                /* if ((component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')) {
                    component.set("v.IsPR", true);
                    component.set("v.IsStartDateChanged", true);
                }       
        }*/
            // EOL - commented below code associated with Channel MDF program
            //   if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") 
                /*|| component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false*/
            //  ){
            /*   if(!helper.availableBudgetCheck(component)){
        helper.displaySuccessErrorMsg(alertMsg, 'Error', 'error');
        
        }
            }*/
               
               }
            if(component.get("v.auditorper") || component.get("v.retailgeouserper") || 
              component.get("v.rsmActivityReviewerper")){
                component.set("v.isSaveandNewDisable",true);
            }
            //Akash - Added extprojsubmgrper to allow external user to edit in planned status
            if (!component.get("v.accmgrper") && !component.get("v.auditorper")
                && !component.get("v.externalper") && !component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper") && !component.get("v.ipaApproverPer") && !(component.get("v.priceReviewersPer") && component.get("v.componentAttributes.isLoggedInUserApprover")) && !component.get("v.activatingaccper")&& !component.get("v.primaryaccper")&& !component.get("v.extprojsubmgrper")) {
                component.set("v.userWithoutAccess",true);
            }
          if(component.get("v.opalAccountManagers")){                
                component.set("v.isLoggedInUserLevelOneApprover", true);
            }
            component.set("v.showSpinner", false);
        });
		//new edit
		   /*if((component.get("v.mode") == 'edit' && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))&&
           (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_PFR_Status_Draft_IPA"))
           && (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired"))
           && (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_CCP_Planned_Status")) 
           && (component.get("v.accmgrper") == true || component.get("v.externalper") == true )) || (component.get("v.mode") == 'edit' && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c")) && 
           (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") =='Cancelled') 
           && (component.get("v.accmgrper") == false || component.get("v.externalper") == false )) ) 
        {
            var alertMsg = $A.get("$Label.c.Core_MDF_IPA_L1_Edit_Error");
            helper.displaySuccessErrorMsg(alertMsg, "Error!", "error"); // call common method to display error
            var sObectEvent = $A.get("e.force:navigateToSObject");
            sObectEvent .setParams({
                "recordId": component.get("v.newPFR.Id"),
                "slideDevName": "detail"
            });
            sObectEvent.fire(); 
        } */
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
                helper.getFieldEditabilityMapping(component, event);  
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
             	//Campaign - Clone a Proposal - Activity Section - populate pfr details on edit of activity on ipa clone
                  if(component.get("v.pfrCloneCheck")){
                      var  fetchRec = component.get("v.pfrCloneOnCampaign");
                      for (var key in fetchRec) {
                          component.set("v.newPFR." + key, fetchRec[key]);
                      }
                      component.set("v.metricCloneVal",component.get("v.newPFR.Core_MDF_Metrics_txt__c") );       
                      component.set("v.newPFR.Id",component.get("v.recordId") );    
                       result = fetchRec;
                  }else{
                      result = response.getReturnValue();
                      component.set("v.newPFR", result);
                  } 
                    console.log('other reason picklist value----',result.Core_MDF_ReasonforPastDatedActivity_Nm__c);
                    console.log('other reason name----',result.Core_MDF_Other_Reason_nm_txt__c);
                    if ((result.Core_MDF_Fund_Request_Status__c == 'Pending Review' || result.Core_MDF_Fund_Request_Status__c == 'Closed') && !component.get("v.checkCloneAttribute")) {
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
                    component.set("v.selAvailableBudget",result.BudgetId);
                    if(helper.isNotBlank(result.Campaign )){
                    component.set("v.cmpgnStatus", result.Campaign.Status);
                    }
                /*  if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                component.set("v.isSPIFSecReadOnly", false);
                }*/
                    component.set("v.BudgetLocal",result.Core_MDF_Budget_Amount_Local_amt__c);
                    component.set("v.budgetCurrency",result.Core_MDF_Budget_Currency_cd__c);
                    if(helper.isNotBlank(result.Core_MDF_Intel_Activity_Owner_Id__c) && helper.isNotBlank(result.Core_MDF_Intel_Activity_Owner_Id__r.Name)){
                    component.set("v.existingIntelOwner",result.Core_MDF_Intel_Activity_Owner_Id__r.Name);
                    }
                     if(helper.isNotBlank(result.Core_MDF_Primary_Intel_Owner_Id__c) && helper.isNotBlank(result.Core_MDF_Primary_Intel_Owner_Id__r.Name)){
                    component.set("v.existingPriIntelOwner",result.Core_MDF_Primary_Intel_Owner_Id__r.Name);
                    }
                    if(helper.isNotBlank(result.Core_MDF_Member_Acceptor_Id__c) && helper.isNotBlank(result.Core_MDF_Member_Acceptor_Id__r.Name )){ 
					component.set("v.existingMemberActivityOwner", result.Core_MDF_Member_Acceptor_Id__r.Name);
                    component.set("v.existingMemberActivityOwnerId", result.Core_MDF_Member_Acceptor_Id__c);    
					}
                    //New Budget Type field changes replaced txt field with new global picklist field
                /*  if(result.Core_MDF_Budget_Type_nm__c == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || result.Core_MDF_Budget_Type_nm__c == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")){
                    component.set("v.isOpalActivity",true);
                    helper.fetchCampBudgetInfo(component,event,helper,true); 
                    component.set("v.isBudgetTypeFlexible",false);
                    component.set("v.disableRRPercent",true);
                }*/
                /*  else if(result.Core_MDF_Budget_Type_nm__c == $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
                            result.Core_MDF_Budget_Type_nm__c == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
                /*  ) {
                    component.set("v.isOpalActivity",true);
                    helper.fetchCampBudgetInfo(component,event,helper,true); 
                    component.set("v.isBudgetTypeFlexible",true);*/
                    //  if(helper.isNotBlank(result.Core_MDF_MDFReimbursement_Amt__c) && !component.get('v.externalper')/*result.Core_MDF_MDFReimbursement_Amt__c != null && result.Core_MDF_MDFReimbursement_Amt__c != undefined*/
                    /*    ){
                        component.set("v.FlexiReimbursementAmt",result.Core_MDF_MDFReimbursement_Amt__c);
                        component.set("v.disableRRPercent",true);
                    }
                }*/
                /*  else if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                    helper.fetchCampBudgetInfo(component, event, helper, true);
                }

                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail"))
                {
                    helper.fetchBudgetInfo(component);//calling for edit scenario
                }*/

                    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
                        helper.fetchCampBudgetInfo(component);//calling for edit scenario
                    }
  
            //  if(result.Core_MDF_Budget_Type_nm__c != null && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") 
                                                                
                                                            /*)){
                    
                    component.set("v.selBudgetType",result.Core_MDF_Budget_Type_nm__c);    
                    //Set  allocation
                    component.set("v.newPFR.AllocationId",result.AllocationId);
                    if(helper.isNotBlank(result.Core_MDF_MDFReimbursement_Amt__c) && !component.get('v.externalper')/*result.Core_MDF_MDFReimbursement_Amt__c != null && result.Core_MDF_MDFReimbursement_Amt__c != undefined*/
                //){
                    /*      component.set("v.FlexiReimbursementAmt",result.Core_MDF_MDFReimbursement_Amt__c);
                        component.set("v.disableRRPercent",true);
                    }
                    else{
                        component.set("v.FlexiReimbursementAmt",'');
                        component.set("v.disableRRPercent",false);
                    }
                    if(helper.isNotBlank(result.Core_MDF_Activity_Reimbursement_Amt_nbr__c)){
                        component.set("v.EefIntelContri",result.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
                    }
                    if(helper.isNotBlank(result.BudgetId )){
                        component.set("v.selAvailableBudget",result.BudgetId);                            
                    } else{
                        component.set("v.selBudgetType",null); 
                    }
                    component.set("v.SelReimbursementRate",result.Core_MDF_Reimbursement_Rate_txt__c);
                }*/
                    if(helper.isNotBlank(result.Core_MDF_Exchange_Rate_ptc__c)  && component.get("v.checkCloneAttribute") == false){
                        component.set("v.createdDateClone",false);
                        component.set("v.budgetCurrencyOld",result.Core_MDF_Budget_Currency_cd__c);
                    }else if(component.get("v.checkCloneAttribute") == true || result.Core_MDF_Exchange_Rate_ptc__c == null){
                        component.set("v.createdDateClone",true);
                        helper.calculateBudgetAmount(component,component.get("v.newPFR"));
                    }
                   
                    
                    component.set("v.SelActivityType",result.Core_MDF_Activity_Types__c);
                    //component.set("v.SelBrand",result.Core_MDF_Brand__c);
                    component.set("v.SelCategory",result.Core_MDF_ActivityCategory__c);
                    component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", result.Core_MDF_Other_Event_Name_txt__c);
                    component.set("v.selActivityEventName", result.Core_MDF_Event_Name_nm__c);
                    component.set("v.SelTargetAudience",result.Core_MDF_TargetAudience__c);
                    component.set("v.SelProductType",result.Core_MDF_ProductType__c);
                    component.set("v.SelDomainType",result.Core_MDF_Domain_Type_nm__c);
                    component.set("v.SelEngineeringActValue",result.Core_MDF_Activity_Engineering_Nm__c);
                    component.set("v.newPFR.Core_MDF_Other_Engineering_Activity_txt__c", result.Core_MDF_Other_Engineering_Activity_txt__c);
                    component.set("v.SelPOPRequirementValue",result.Core_MDF_POP_Requirement_nm__c)
                    component.set("v.cspIntelRevVal",result.Core_MDF_CSP_Intel_Based_Revenue_amt__c);
                /* if(component.get("v.externalper")==true && component.get("v.checkCloneAttribute") == true 
                    && component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                    if(helper.isNotBlank(result.Core_MDF_Opportunity_id__c)){
                            component.set("v.newPFR.Core_MDF_Opportunity_id__c",null);
                    }*/
                        /*if(helper.isNotBlank(result.Core_MDF_Attribution_Variance_Neg_txt__c)){
                            component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
                        }*/
                       
                // }
                //else{
                    component.set("v.newPFR.Core_MDF_Opportunity_id__c",result.Core_MDF_Opportunity_id__c);
                    //component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", result.Core_MDF_Attribution_Variance_Neg_txt__c);
                //  }
                    
                  /*  var brandArr = [];
                    if(result.Core_MDF_Brand_nm__c){
                  		  brandArr = result.Core_MDF_Brand_nm__c.split(";");
                    }
                    component.set("v.selectedBrandOptions",brandArr);*/
                    var industryArr = [];
                    if(result.Core_MDF_Industry_Multi_nm__c){
                        industryArr = result.Core_MDF_Industry_Multi_nm__c.split(";");
                    }
                    component.set("v.selectedIndustryOptions",industryArr);
                    //component.set("v.selectedIndustryOptions",result.Core_MDF_Industry_Multi_nm__c);
                    var initiativeArr = [];
                    if(result.Core_MDF_Initiative_nm__c){
                        initiativeArr = result.Core_MDF_Initiative_nm__c.split(";");
                    }
                    component.set("v.selectedInitiativeOptions",initiativeArr);
		    component.set("v.SelChannelPartner",result.Core_MDF_Channel_Partner__c);
                    component.set("v.SelOtherChannelPartner",result.Core_MDF_Other_Channel_Partner__c);
                    component.set("v.CPLed",result.Core_MDF_Channel_Partner_Led__c);
                    component.set("v.JointContent",result.Core_MDF_Joint_Content_ind__c); 
                    component.set("v.SelMarketValue",result.Core_MDF_Country_nm__c); 
                    component.set("v.SelReimbursementRate",result.Core_MDF_Reimbursement_Rate__c); //Reimbursement Rate assignment
		    
                   //read only "Strategic Marketing Fund" checkbox inheriting values from Campaign
            //    if((component.get("v.accmgrper") || component.get("v.externalper")) && (recordTypeDeveloperName== $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF"))){
            //      component.set("v.IsStrategicMarketingFundVisible", true);
            //  }	
                // else{
                    
                    component.set("v.IsStrategicMarketingFundVisible", false);
                // } 
		            //New Activity Category Type Change
                    var selCategory = component.get("v.SelCategory");
                    var selActiType = component.get("v.SelActivityType");
                    var setBudgType = component.get("v.selBudgetType");
            //    if (((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(selCategory) /*selCategory == 'Event'*/  && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) /*|| ((component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") || component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")) && selActiType != 'Promotion')*/) {
                /*      component.set("v.hideCompetitiveQuest", true); 
                    helper.fetchApprovers(component);
                }
                else{*/
                    component.set("v.hideCompetitiveQuest", false); 
                //   }
		    //OPAL Past Dated Activity Submission process
                    var today = helper.getTodayDateLocalTime();
                    var start_date = component.get("v.newPFR.Core_MDF_Start_Date__c");
                    var budgetType = component.get("v.selBudgetType");
                    var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
					var mode = component.get("v.mode");
                   if(!component.get("v.externalper")){
                //   if ((helper.isNotBlank(start_date) && start_date < today) && (opalBudgetTypes.includes(budgetType) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && (component.get("v.accmgrper") || component.get("v.priceReviewersPer") || component.get("v.retailgeouserper") || component.get("v.rsmActivityReviewerper")))
            //		)) {
                    /*       component.set("v.SelPotentialReason", result.Core_MDF_ReasonforPastDatedActivity_Nm__c);
                    }
                    else{*/
                        component.set("v.SelPotentialReason", null);
                    //  }
                    }
					//Retail Changes - to show Reason for past dated field when RSM is cloning the past dated activity
                    if(mode == 'clone'){
                    /*  if (start_date < today  && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) {
                        component.set("v.IsPR", true);
                    } else {*/
                        component.set("v.IsPR", false);                            
                    //  }
                    }
                    helper.checkIsApproverActive(component);
                /*  if(component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                helper.checkIsPrimaryApproverActive(component); } */
                    
                    //[IPA MDF] - Campaign - Clone a Proposal - Activity Section - warning of spif section
                    if(component.get("v.pfrCloneCheck")){
                        var activityTyp =  component.get("v.SelActivityType");
                        var spifActivityTyps = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
                        if(spifActivityTyps.includes(activityTyp)) {
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
                    
                /* if(component.get("v.isOpalActivity")){
                    component.set("v.CPLed", true);
                    component.set("v.SelReimbursementRate",result.Core_MDF_Reimbursement_Rate_txt__c);
                    component.set("v.doInitCheck",true);
                    
                    
                //[Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
                    
                    component.set("v.SelOtherChannelPartner",result.Core_MDF_Other_Channel_Partner__c);
                    
                }*/
                    //Make Attribution fields blank while cloning an activity
                /*   if((component.get("v.isOpalActivity")) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){ 
                    if (component.get("v.checkCloneAttribute")) {
                        component.set("v.newPFR.Core_MDF_Attribution_Variance_Pos_txt__c", null);
                        component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
                        //POP and Attribution Requiremnents Field blank on clone
                        component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
                        component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
                    }

                }*/
					
                    if (component.get("v.checkCloneAttribute") && (helper.isLatestCategory(component))){
                        component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", null); 
                    }
                    
                    component.set("v.selectedEventFormat", result.Core_MDF_Event_Format_Nm__c); // Event Format Data
                    if (component.get("v.checkCloneAttribute")) {
                        component.set("v.isAdditionalReviewReqd",false); 
                    }else{
                        component.set("v.isAdditionalReviewReqd",result.Core_MDF_Require_Additional_Review_ind__c); 
                        component.set("v.newPFR.Core_MDF_Program_Office_Check_ind__c",result.Core_MDF_Program_Office_Check_ind__c); 
                    }
                    //OPAL Budget Type Changes for CCF and DCF Programs starts
		    		//New Budget Type field changes replaced txt field with new global picklist field
            //     if(result.Core_MDF_Budget_Type_nm__c != null && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF"))){
                    
                /* OPAL change start - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
            //     if(component.get("v.checkCloneAttribute") || helper.isNotBlank(component.get("v.recordId"))) {
        //          }
                
                /* OPAL change end - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
        //     }
            /* if ((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") ||component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") ||component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF")) 
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
                }*/
                //   else{
                        if(helper.isNotBlank(result.Campaign)){
                        component.set("v.selectedLookUpRecord.Core_MDF_Priority__c",result.Campaign.Core_MDF_Priority__c);
                       //WW27 | DEVINT3 | System is throwing Component error when user is trying to edit an Activity, for which user is not having Access for Campaign for CCF 1.0 & DCF 1.0
                       // EOL - commented below code associated with Legacy Budget Type
                          if((result.Campaign.Core_MDF_Priority__c == undefined ) || result.Campaign.Core_MDF_Channel_Program__r == undefined){ 
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
				  //	}
                    // Make Sure there is no dependencies Status for Clone
                    var campaignBudgetType = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
                    if(component.get("v.checkCloneAttribute") == false){
                        component.set("v.CurrentStatus",result.Core_MDF_Fund_Request_Status__c);
			//OPAL Changes- Added extra condition not to display Closed Activity Error for OPAL Activities
                /*    if(component.get("v.CurrentStatus") == 'Closed' && component.get("v.accmgrper") == false
                        && (component.get("v.retailgeouserper") == false && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_Retail")) && !component.get("v.isOpalActivity")
                        && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_SPCF")
                        && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")
                        && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_EEF_RecordType")
                        && campaignBudgetType != $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") 
                        && campaignBudgetType != $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")
                        ){
                        component.set("v.isClosedActivity",true);
                        component.set("v.closeError",$A.get("$Label.c.Core_MDF_Close_Activity_Error"));
                    }*/
                        
                        
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
                   
                    if(result.Campaign.Core_MDF_Channel_Program__c != null){
                    var progName = result.Campaign.Core_MDF_Channel_Program__r.Name;
                    component.set("v.programName",progName);
                    }
                    component.set("v.recordtypeName",recordType);
                    component.set("v.recordtype",result.RecordTypeId);
                    component.set("v.recordtypeDeveloperName",recordTypeDeveloperName);
                    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") ){
                        component.set("v.checkfileuploadcondition", true);
                    }
                    helper.constructadditionalfilter(component, startdate, enddate,recordTypeDeveloperName);
                    var country=component.get("v.SelMarketValue"); 
                    //helper.getIndustryPartners(component, country);
                    // EOL commented below condition for legacy budget type/program
                    //TO BE COMMENTED - AKANKSHA
                if(/*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                    /*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||*/
                //   recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") ||
                    /*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost") ||*/
                    /*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") ||*/
                    //  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
                    helper.activityPicker(component, recordTypeDeveloperName);
                }
                    component.set("v.oldbudget", result.RequestedAmount);
                    component.set("v.oldcategory", result.Core_MDF_ActivityCategory__c);
                    component.set("v.oldstatus", result.Core_MDF_Fund_Request_Status__c);
                    component.set("v.oldsdate", result.Core_MDF_Start_Date__c);
                    component.set("v.oldedate", result.Core_MDF_End_Date__c);
                    component.set("v.ChgndAttach",false);
                    component.set("v.oldActivtyType",result.Core_MDF_Activity_Types__c);
                    component.set("v.oldCampaignId",result.CampaignId);
                    if(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c")){
		               component.set("v.approvalStage", result.Campaign.Core_MDF_Approval_Stage_nm__c);
			         }else{
		    component.set("v.approvalStage", result.Core_MDF_Approval_Stage__c);
			         }
                    //Variable Reimbursement Rate - stamp old prod type and brand values
                    component.set("v.oldProdType", result.Core_MDF_ProductType__c);
		    		// component.set("v.oldBrandMulti", result.Core_MDF_Brand_nm__c);
                    component.set("v.activityClosureType",result.Core_MDF_Activity_Closure_Type__c);
                    //Attributes for the Currency validation
					if(helper.isNotBlank(result) && helper.isNotBlank(result.ChannelPartner.Id) && component.get("v.mode") == 'edit'){
                        result.ChannelPartnerId = result.ChannelPartner.Id;
                    }
                    var newObject = new Object;
                    //Ayush - added sanitize method for semgrep fix.
                    var mergedObject = Object.assign(newObject, helper.sanitizeResults(result));
                    component.set("v.oldPFR", mergedObject);
                  /*  if(component.get("v.oldPFR.Core_MDF_Brand_nm__c") == undefined ){
                        component.set("v.oldPFR.Core_MDF_Brand_nm__c", []);
                    } */ 
                /*  if(component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c") == undefined && component.get("v.isOpalActivity")){
                    component.set("v.oldPFR.Core_MDF_Activity_SubType_nm__c", []);
                } */                   
					//OPAL Changes Start
                /*if(component.get("v.isOpalActivity") || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                    helper.updateCountryPickVals(component);
                }*/
                    // Set the controls disabled property for edit mode based on the criteris defined
                    if(component.get("v.checkCloneAttribute") == false){
                        
                /*    if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.isActivityReviewRequired")) {
                        helper.setRMFReviewerDisabledState(component);
                    }  */
                        helper.SetAccMgrDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName );
                        helper.SetExternalDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                        helper.SetAuditorDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                        //To Enable Edit acces for GEO Leads
                    /*  if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.retailgeouserper") == true && !(component.get("v.accmgrper") && component.get("v.retailgeouserper"))){
                        helper.checkGeoLeadsEditAccess(component);
                    }*/
                    //Allow edits when User has both Account Manager and Geo Lead Roles
                    /*if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.retailgeouserper") == true && component.get("v.accmgrper") == true){
                        helper.setDualRoleEditability(component);
                    }*/
                        
			
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
                           
						component.set("v.newPFR.Core_MDF_ATF_Flag_nm__c",''); //ATF Flag
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

		    
                /* if(component.get("v.isOpalActivity") && (component.get("v.checkCloneAttribute") || component.get("v.recordId")!=null)){
                    console.log('Call to populateActCatType');
                    helper.populateActCatType(component, event, helper);
                }*/
		    
                }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
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
            recordType = component.get("v.recordtypeName");//$A.get("$Label.c.Core_MDF_CCF_RecordType");
            startdate = null;
            enddate = null;
            helper.constructadditionalfilter(component, startdate, enddate, recordTypeDeveloperName); 
            // EOL - Commented below condition associated to Legacy & IPA
        if(/*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
            /*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||*/
            //  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") /*||
            //  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost") ||
            //  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")*/||
            //recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")||
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
            helper.activityPicker(component, recordTypeDeveloperName);
        }
    }
       if(component.get("v.isActivityLayout") && helper.isNotBlank(component.get("v.selectedLookUpRecord"))){
            helper.fetchCampBudgetInfo(component, event, helper, true);
        }
        helper.fetchExternalActSubmitters(component,true);
        helper.checkAvailAllocationAmt(component);
        component.set("v.startDate",component.get("v.newPFR.Core_MDF_Start_Date__c"));
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType") ){
            component.set("v.checkfileuploadcondition", true);
    }
    }, 
    
/*resetActivtyType:function(component, event, helper){
    component.set("v.SelActivityType",null);
    component.set("v.newPFR.Core_MDF_ofPagesEligible__c",'0');
    component.set("v.newPFR.Core_MDF_pagespayingfor__c",'0');
    component.set("v.newPFR.Core_MDF_Government_Nexus__c","No");
    component.set("v.newPFR.Core_MDF_Competitive_Elements__c","No");
    component.set("v.isSPIFSecAvailable",false);
    component.set("v.isDomainTypeVisible", false);
    component.set("v.SelDomainType",null);
    helper.resetHelper(component);
    helper.fetchActType(component);
    helper.fetchApprovers(component);
    
    //if selected category is 'Digital 2025' then fectching values for Domain Type field
    if (!($A.util.isEmpty(component.get("v.SelCategory")))) {
    if (($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory"))) {
        
        helper.fetchDomainTypeOptions(component);
        component.set("v.isDomainTypeVisible", true);   
    }
    }
    var isEventCategory = ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) ? true : false
    component.set("v.eventActCategory", isEventCategory);
//onchange of activity category spinner is off
helper.fetchExternalActSubmitters(component,false);
    window.setTimeout(
        $A.getCallback(function() {
        }), 3000
    );
},*/ 
    //On change of Domain Type value, calling fileUploadMandatoryAndEventFormVisibility for displaying Ecosystem Form Page
    //On change of Domain Type value, calling fetchApprovers to display Intel Owner on form page
/* onDomainTypeChange:function(component, event, helper){
    if (!($A.util.isEmpty(component.get("v.SelCategory")))){
        helper.fileUploadMandatoryAndEventFormVisibility(component);
        helper.fetchApprovers(component);
    }
},*/  
/*  resetBrand:function(component, event, helper){
    //Variable Reimbursement Rate changes
    helper.resetHelper(component);
},*/ //  // 
    
/*resetActTypeDepAttributes:function(component, event, helper){
    
    //this to reset the activity sub type value on chage of activity type
component.set("v.popVisible", false);
    component.set("v.isSPIFSecAvailable",false);
    //POP and Attribution Requirements changes for visiblity of field
    var activityType = component.get("v.SelActivityType");
    var otherActTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
    if(helper.isNotBlank(activityType) && helper.isNotBlank(otherActTypes) && otherActTypes.includes(activityType)){
        if(component.get("v.externalper") == true){
            if(component.get("v.mode") != "edit"){
                component.set("v.isAttributionReqVisible", false);
                component.set("v.isPOPReqVisible", false);
            }
            else if(component.get("v.mode") == "edit" && helper.isNotBlank("v.newPFR.Core_MDF_Attribution_Requirements_txt__c") && helper.isNotBlank("v.newPFR.Core_MDF_POP_Requirements_txt__c")){
                component.set("v.isAttributionReqVisible", true);
                component.set("v.isPOPReqVisible", true);
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
    
component.set("v.newPFR.Core_MDF_SPIF_Segments_Available_ind__c",false);
            if(component.get("v.oldPFR")!=undefined && component.get("v.oldPFR")!=null){
        if(component.get("v.oldActivtyType") != component.get("v.SelActivityType"))
        {
                component.set("v.selActivitySubType", null);
                component.set("v.newPFR.Core_MDF_Runs_per_hour_nbr__c", null);
                component.set('v.newPFR.Core_MDF_Activity_SubType_nm__c',null);
                component.set("v.isActivityTypeChanged",true);
                component.set("v.selActivityEventName", null);
                component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", null);
                component.set("v.selectedSubTypeOptions", null);
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
        component.set("v.selectedSubTypeOptions", []);
        component.set('v.newPFR.Core_MDF_Activity_SubType_nm__c',null);
        component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
        component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
    }
    helper.fetchEventFormat(component);
    //this to fetch the activity subtype on the basis of selected act type
    helper.fetchActSubTypeMulti(component);             
    helper.fetchEventName(component);     
    helper.resetHelper(component);
    helper.fetchApprovers(component);
    helper.fetchExternalActSubmitters(component,false);
    
        /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") 
        || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") ) 
        || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")) { 
    helper.checkFileUploadForOPAL(component);
    helper.fileUploadMandatoryAndEventFormVisibility(component); 
    component.set("v.ContentDocumentIds", null);     
    component.set("v.fileData", null);
    component.set("v.Uploadfinished", false);     
    
}*/
    //to check whether to dispaly Segment SPIF Activity Questions section or not
    // window.setTimeout(
    //     $A.getCallback(function() {
        //      if($A.get("$Label.c.Core_MDF_POP_RecordTypes").includes(component.get("v.recordtypeDeveloperName"))) {
            /*       if(component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
                component.set("v.popVisible", true);    
            }
                if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && !component.get("v.activitySubTypeAvailable"))){
                component.set("v.popVisible", true);  
                }   
            }
            //helper.checkSPIFActSecVisible(component);
        }), 100
    );
    // if rectype = RMF OR recType = RMF and no subtype available for selected Type
    /*  if((component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")) 
        || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") 
            && !component.get("v.activitySubTypeAvailable"))
        ) {
        //call to KPI component
        if(component.get("v.SelActivityType") != null) {
            component.set("v.showKPISpinner", true);
        }
        helper.getKPIAttributes(component);
    }*/
    
    
//   },
    //call to KPI component
/*  getKPIAttributes: function (component, event, helper) {
    // Subtype dependancy only for RMF
    component.set("v.popVisible", false);
    if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail"))) {
        if(component.get("{!v.selActivitySubType}") != null) {
            component.set("v.popVisible", true);
            component.set("v.showKPISpinner", true);
        }
        helper.getKPIAttributes(component);
    }
},*/
    
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
    //Reason Value Name Change - Akanksha
/* onReasonValueChange: function(component, event, helper){
// if Selected Reason is "Other", then show Other Reason Text field 
    let reasonName = component.get("v.SelPotentialReason");
    if(reasonName == $A.get("$Label.c.Core_MDF_Other_Localized")){
        component.set("v.showOtherReasonName", true);
    }else{
        component.set("v.showOtherReasonName", false);
        component.set("v.newPFR.Core_MDF_Other_Reason_nm_txt__c", null);
        console.log('other reason field value---',component.get("v.newPFR.Core_MDF_ReasonforPastDatedActivity_Nm__c"));
    }   
},*/
    onEngineeringActChange: function(component, event, helper){
        //if engineering Activity is "Other", then show Other Event field
    var engActivity = component.get("v.SelEngineeringActValue");
    if(engActivity){//made changes-ALekhya
        component.set("v.showOtherEngAct", true);
       // Check if the selected value starts with any custom label values
        var otherEngValues = $A.get("$Label.c.Core_MDF_Other_Engineering_Activity_Values");
        var hasOtherValue = otherEngValues.split(',').some(function(value) {
            return engActivity.toLowerCase().startsWith(value.trim().toLowerCase());
        });
        
        if(hasOtherValue){
            component.set("v.isOtherEngActRequired", true);
        } else {
            component.set("v.isOtherEngActRequired", false);
        }
    }
    else{
        component.set("v.showOtherEngAct", false);
        component.set("v.newPFR.Core_MDF_Other_Engineering_Activity_txt__c", null);
    }
},

    onPOPRequirementChange: function(component, event, helper){
        
        component.set("v.newPFR.Core_MDF_POP_Requirement_nm__c", component.get("v.SelPOPRequirementValue"));
    },
    
    handleOtherEvent: function (component, event, helper) {
        var value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Other_Event_Name_txt__c", value);
    },
   
	//Function called when Other Value is selected in Reason Field
     handleOtherReason: function (component, event, helper) {
        let value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Other_Reason_nm_txt__c", value);//!inputValue.trim()
    },

    //Function called when Other Value is selected in Reason Field
    handleOtherEngAct: function (component, event, helper) {
        let value = event.detail.value;
        component.set("v.newPFR.Core_MDF_Other_Engineering_Activity_txt__c", value);//!inputValue.trim()
    },

    // Function called from the change event handler to reset popup and file upload attributes
    resetpopupattributes: function(component, event, helper) {
        helper.resetHelper(component);
    },
    // Function called on the change Account change
    resetAccountattributes : function(component, event, helper){
        if(component.get("v.selectedPartner") == null || component.get("v.selectedPartner").Id == null){
            
            component.set("v.newPFR.ChannelPartnerId",null);
            component.set("v.AllExtActSubmitterOptions",[]);
            component.set("v.selectedExtActSubmitterOptions",[]);
        /*  if(component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            component.set("v.AllApproverOptions",[]);
            component.set("v.selectedApproverOptions",[]);
            component.set("v.intelOwnerReq",false);
        }*/
        } 
        else{
            helper.fetchApprovers(component);
            helper.fetchExternalActSubmitters(component,true);
            component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedPartner").Id );
        }
    /*  if(component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.isActivityCreationOnCampaign")){
        component.set("v.newPFR.Core_MDF_Start_Date__c",component.get("v.selectedLookUpRecord.StartDate"));
        component.set("v.newPFR.Core_MDF_End_Date__c",component.get("v.selectedLookUpRecord.EndDate"));
    }*/
	 helper.hasIUPGMRecord(component);
	 helper.checkAvailAllocationAmt(component);//On Account Change
    },
    // Function called on the picklist fields
    resetPicklistValues:function(component, event, helper){
         
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var startdate = component.get("v.newPFR.Core_MDF_Start_Date__c");//Added for EEF
        var enddate = component.get("v.newPFR.Core_MDF_End_Date__c");//Added for EEF
//	if(recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_PFR_Retail")||recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")||recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF")||recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_PFR_CCF")||recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_PFR_DCF")||recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
        if(recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
                helper.checkAvailAllocationAmt(component);
        			helper.setActCatType(component);
            }
        var selCountry = component.get("v.selectedCountryOptions");
        if((component.get("v.oldCampaignId") != component.get("v.selectedLookUpRecord.Id"))){
            helper.accPropCampType(component);

         

	    /*OPAL change - start - onchange of campaign - from opal to non opal - updating picklist values */ //This if contion would not execute for create scenarios/
	    if(component.get("v.oldCampaignId") != null && component.get("v.oldCampaignId") != '') {
				helper.activityPicker(component, recordTypeDeveloperName);
         }
    /*  else{
        //Ayush - Added fix for RMF create scenario - on change of campaign, RR was not resetting to 100%	
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.mode") == ''){
            component.set("v.SelReimbursementRate", '100%');
        }
        }*/
	    /*OPAL change - end*/
        //   if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")){
            //Variable Reimbursement - reset VR on Campaign change
        //    helper.resetHelper(component);
        //  }
        /* else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
                recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            component.set("v.SelTargetAudience",null);
            component.set("v.SelProductType",null);
            component.set("v.SelCategory",null);
            component.set("v.SelActivityType",null);
            component.set("v.CPLed",false);
        }*/
    }
        
		
		 //OPAL Budget Type Changes starts
    //  if(
    //       (recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_PFR_DCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))// && component.get("v.selectedLookUpRecord.Core_MDF_Account_Based_Ind__c") == true))
        /*   && (
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
            
            helper.fetchCampBudgetInfo(component,event,helper,true); 
           // EOL - commented below condition associated to legacy & IPA program
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                    /*recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||*/
                    // recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") /*||
                    //recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost") ||
                    //recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")*/||
            // recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")||
           // recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")){
                //     helper.activityPicker(component, recordTypeDeveloperName);
                // }
        
    //  }
		// OPAL changes end

    /*  if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail"))
    {
        helper.fetchBudgetInfo(component);//called on change of campaign
    }*/

    /*  if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0') {
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
            
            var selectedPriority='';
            if (singlePriorityType != null) {
                for (var i = 0; i < singlePriorityType.length; i++)
                    multiplePriorityType.push({
                        key: singlePriorityType[i].label,
                        value: singlePriorityType[i].value
                    });
                if ( singlePriorityType[0]){
                            selectedPriority = singlePriorityType[0].value;
                    }   
                    }
                    if(component.get("v.mode") == ""){
                    component.set("v.campriority",selectedPriority);
                    }
            component.set("v.PriorType",multiplePriorityType);
            component.set("v.campriorityValue",true);
        }
        
        if (component.get("v.selectedLookUpRecord.Core_MDF_Account__c") != null && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
            component.set("v.selectedPartner", component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Name"));                
        }
        else if(component.get("v.selectedLookUpRecord.Core_MDF_Account__c") != null && ( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") 
                                                                                        || ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'CCF 1.0' && component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") != 'DCF 1.0'))){
            component.set("v.selectedPartner.Name", component.get("v.selectedPartner.Name"));
        }    
    }*/
    //Variable Reimbursement Rate changes - fetch VR questions
    // if (component.get("v.selectedLookUpRecord.Id") != null && recordTypeDeveloperName != null && recordTypeDeveloperName != '' && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__c != undefined) {
    //     helper.fetchVRQuestion(component);
    // }
    // [IPA] BU Mapping - this method fetch the multipicklist values from backend  -end 
    // Read only "Strategic Marketing Fund" checkbox inheriting values from Campaign
    //   if ((component.get("v.accmgrper") || component.get("v.externalper")) && ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) &&
    //        (component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == "DCF 1.0" || component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == "CCF 1.0"))) {
    //    component.set("v.IsStrategicMarketingFundVisible", true);
    // } 
    // else {
        component.set("v.IsStrategicMarketingFundVisible", false);
    // }
        if (component.get("v.selectedLookUpRecord.Id") != null  && component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__c != undefined) {
        
        component.set("v.programName",component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__r.Name);
        var country=component.get("v.SelMarketValue"); 
        //helper.getIndustryPartners(component, country);
        }
    /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
        helper.constructadditionalfilter(component, startdate, enddate,recordTypeDeveloperName);//added for EEF
    }*/
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
        var country=component.get("v.SelMarketValue");
       if(component.get("v.isOldCtry")){
           component.set("v.OldSelCountry",country);
	   component.set("v.isOldCtry",false);
       }
       if(component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__c != undefined){
           component.set("v.programName",component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__r.Name);
        //helper.getIndustryPartners(component, country);   
        }
	   // [Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
        helper.fetchApprovers(component);
        if(helper.isNotBlank(component.get("v.SelMarketValue"))){
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
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
        });
        $A.enqueueAction(action);
        }  	
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
/*  setPrimaryApprover : function(component,event,helper){
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var selAppLst = component.get("v.selectedPrimaryApproverOptions");
    var Isactivatingaccper = component.get("v.activatingaccper");
    var isExternal = component.get("v.externalper");
    var allAppLst = component.get("v.AllPrimaryApproverOptions");
    var budType = component.get("v.selBudgetType");
    //var intelContri = component.get("v.intelContribution");
    var selectedCountry = component.get("v.selectedCountryOptions"); 
    if(selAppLst.length != 0 && (Isactivatingaccper || (isExternal && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")))){
        if(selAppLst.length >1){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error..!!",
                message: $A.get("$Label.c.Core_MDF_Only_One_Pri_Intel_Owner"), 
                type: "error"
            });
            toastEvent.fire();
        }
        helper.checkIsPrimaryApproverActive(component);
        var appOpts = "";
        for(var i=0; i<selAppLst.length; i++ ){
            if(i!=selAppLst.length-1)
                appOpts+=selAppLst[i]+";";
            else
                appOpts+=selAppLst[i];            
        }
        component.set("v.newPFR.Core_MDF_Primary_Intel_Owner_Id__c",appOpts);
    }
},*/

/*  setExtActSubmitter : function(component,event,helper){
    
    var selSbtLst = component.get("v.selectedExtActSubmitterOptions");
    var mode = component.get("v.mode")
    var isExternal = component.get("v.externalper");
    var isInternal = component.get("v.accmgrper");
    var isPrimaryAccMgr = component.get("v.primaryaccper");
    var isActivatingAccMgr = component.get("v.activatingaccper");
    var allSbtLst = component.get("v.AllExtActSubmitterOptions");
    var budType = component.get("v.selBudgetType");
    if(selSbtLst.length != 0 && (isInternal || isPrimaryAccMgr || isActivatingAccMgr || isExternal )){
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
}, */  
    
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
            //US924033
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
    resetBudgetAmount : function(component,event,helper){
        component.set("v.budgetCurrency",component.get("v.budgetCurrency")); 
    },
    
    /*handleKPIComp: function (component, event, helper) {
    component.set("v.showKPISpinner", false);
        //DE117182 WW23 | DEVINT3 | 'Demonstration' Subtype value not getting cleared on cloning for opal activity
        if(component.get("v.isOpalActivity") && component.get("v.checkCloneAttribute") && component.get("v.SelActivityType") !=  component.get("v.oldActivtyType")){
        component.set("v.selectedSubTypeOptions", null);
    }
},*/
    //  [OPAL CCF/DCF] - Available Budgets Field at Activity
    budgetTypeChangeOPAL : function(component,event,helper){
        
        /*if(!component.get("v.doInitCheck") || (component.get("v.doInitCheck") && (component.get("v.mode") == 'edit' || component.get("v.mode") == 'clone'))){
            component.set("v.selAvailableBudget",'');
        }*/
        
        //Added fix - When Budget type was changing Activity Category and type was not getting reset.
        //call this only on Budget type change.
        var oldBT = component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c");
        var budgetType = component.get("v.selBudgetType");
        if (helper.isNotBlank(oldBT) && helper.isNotBlank(budgetType) && oldBT != budgetType){
	        component.set("v.SelCategory","");
	        component.set("v.SelActivityType","");
		}
        
        //Fetch Budget applicable for the Budget Type
        component.set("v.FlexiReimbursementAmt",'');
        component.set("v.doInitCheck", false);
        
        helper.getAvailableBudget(component,event,helper);
        helper.fetchApprovers(component);
        helper.fetchExternalActSubmitters(component,false);
        helper.fileUploadMandatoryAndEventFormVisibility(component);
        //New Activity Category Type Change
    //  if (component.get("v.isOpalActivity") && (helper.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType")))
    //     && (($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) || ($A.get("$Label.c.Core_MDF_CMP_activity_type_eligible_for_approval").split(';')).includes(component.get("v.SelActivityType"))) /*(component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")||component.get("v.SelActivityType") == $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))*/) {
    //    helper.checkFileUploadForOPAL(component);
        
    //  } 
    /*  else if((component.get("v.isOpalActivity") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") )   && $A.get("$Label.c.Core_MDF_AllFileUpload_BudgetType").includes(component.get("v.selBudgetType")))
        {helper.checkFileUploadForOPAL(component);
        
        }*/
    /*  if ((component.get("v.isOpalActivity")||component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_Co_GTM_RecordType")) && $A.get("$Label.c.Core_MDF_AllFileUpload_BudgetType").includes(component.get("v.selBudgetType")) 
                && component.get("v.checkfileuploadcondition") == true) {
        if (component.get("v.Uploadfinished")) {
            component.set("v.Uploadfinished", false);
            component.set("v.ContentDocumentIds", null);
        }
    }*/
        
        var selCategory = component.get("v.SelCategory");
        var selActiType = component.get("v.SelActivityType");
        var setBudgType = component.get("v.selBudgetType");
    //  if (((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(selCategory) /*selCategory == 'Event'*/ && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) /*|| ((component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") || component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")) && selActiType != 'Promotion')*/) {
    //     component.set("v.hideCompetitiveQuest", true);
        //   if((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(selCategory) /*selCategory == 'Event'*/ && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) {
        //      component.set("v.newPFR.Core_MDF_Competitive_Elements__c",null);
        //  }
    //   }
    //  else{
        component.set("v.hideCompetitiveQuest", false); 
    // }
        helper.fetchApprovers(component);
	//Read only "Strategic Marketing Fund" checkbox inheriting values from Campaign
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
//    if ((component.get("v.accmgrper") || component.get("v.externalper")) && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) &&
        /*   component.get("v.selBudgetType") != "") {
        component.set("v.IsStrategicMarketingFundVisible", true);
    }
    else{*/
        component.set("v.IsStrategicMarketingFundVisible", false); 
    //   } 
	// OPAL Past Dated Activity Submission process
        var todayDate = helper.getTodayDateLocalTime();
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
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
            if(!component.get("v.externalper") && !(component.get("v.activatingaccper"))){
            //  if(startDate < todayDate && (opalBudgetTypes.includes(budgetType) ||  component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
            /*     if((component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')){
                    component.set("v.IsStartDateChanged", true);
                    component.set("v.IsPR", true);
                }
                component.set("v.IsPR", true);
            }
            else{*/
                component.set("v.IsPR", false);
                component.set("v.IsStartDateChanged", false);
                component.set("v.SelPotentialReason", null);
            //  } 
            }          
        /*   else if(startDate < todayDate && (component.get("v.externalper") || (component.get("v.activatingaccper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) 
                && (opalBudgetTypes.includes(budgetType) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
                    console.log('ERROR - 3- AKG'); 
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                               
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                    component.set("v.IsStartDateChanged", true);
            }
            else{*/
                component.set("v.IsStartDateChanged", false);
        //    }
        }
        else{
            if (!component.get("v.externalper") && !(component.get("v.activatingaccper"))) {
                if(mode == 'clone'){
            //     if (startDate < todayDate && (opalBudgetTypes.includes(budgetType) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) {
                    // component.set("v.IsPR", true);
                //  } else {
                    
                    component.set("v.IsPR", false);
                    component.set("v.IsStartDateChanged", false);
                    component.set("v.SelPotentialReason", null);
                //  }
                }
                if(mode == 'edit'){
                //   if (startDate < todayDate && oldBT != null && oldStartDate != startDate && (opalBudgetTypes.includes(budgetType) ||component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) {
                    //   component.set("v.IsPR", true);
                //  } else {
                    component.set("v.IsPR", false);
                    component.set("v.IsStartDateChanged", false);                     
                //  }
                }
            }
        /*  else if(component.get("v.externalper") || (component.get("v.activatingaccper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
            if(mode == 'clone'){
                if(oldStartDate != null && startDate < todayDate 
                    && (opalBudgetTypes.includes(budgetType) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
                    console.log('ERROR - 4- AKG');
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error"); 
                }
                else{
                    component.set("v.IsStartDateChanged", false);
                } 
            }
            else if(mode == 'edit'){
                /* if (oldStartDate != null && oldStartDate != startDate && startDate < todayDate 
                    && (budgetType == 'MDF' || budgetType =='MDF+' || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) {
                    console.log('ERROR - 5- AKG'); 
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                               
                    helper.displaySuccessErrorMsg(alertMsg,"Error!","error");
                    component.set("v.IsStartDateChanged", true);
                }
                else{*/
                    component.set("v.IsStartDateChanged", false);
                //  } 
        //      }
        //  }
        } 
	 helper.checkAvailAllocationAmt(component);//on change of budget type
/* if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") 
        || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") )) { 
    component.set("v.fileData", null);
    component.set("v.ContentDocumentIds", null);
    component.set("v.Uploadfinished", false); 
    }*/
    },
    //[OPAL CCF/DCF] - Available Budgets Field at Activity
    saveBudget :  function(component, event, helper) {
        //Set Allocation Id in Activity
        helper.checkAvailAllocationAmt(component);
        //SAve the selected Budget
        helper.allocationBudgt(component, event, helper);
        
    },
    
    
	// OPAL changes - on change MDF Reimbursement Amount
/*calculateFlexibleRR: function(component, event, helper){
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
                    if((component.get('v.mode') == '' &&  abudgetId ==  budgetCampRecList[i].Core_MDF_Budget_Name_Id__c) || (component.get('v.mode') != '' &&  abudgetId ==  budgetCampRecList[i].Core_MDF_Budget_Name_Id__c )){
                    abRR = budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c;
                    break;
                }
            }
        }
        }
        component.set("v.disableRRPercent",false);
        helper.updateRRPickValues(component,abRR);
    }
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") 
        || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") )) { 
    component.set("v.fileData", null);
    component.set("v.ContentDocumentIds", null);
    component.set("v.Uploadfinished", false);     
    }
},*/ 
	 //KS - Handle the behaviour of Industry partner related controls picklist, other text box and check box
    // [Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
    /* indPartnerChange: function (component, event, helper) {
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
        if(component.get("v.selectedIndPartnerOptions").includes('Others')){
            component.set("v.IsOtherCP",true);
            component.set("v.CPLed",true);
        }
    },*/
	
   //[IPA] BU Mapping - this method is call onchange of percent 
  handlePerChangeBuSplit: function (component, event, helper) {
      var mergeFld = 'v.newPFR.'+ event.getSource().get('v.title');
	var fldVal = event.getSource().get('v.value');
	component.set(mergeFld,event.getSource().get('v.value')); 
      try {
          if(fldVal != undefined &&  (fldVal == null || fldVal == '' || fldVal <= 0 || fldVal.includes(".") || fldVal.includes("-") || fldVal.includes("+"))){
              component.set("v.buSplitWholeNumError",true);
          }else{
              component.set("v.buSplitWholeNumError",false); 
          }
      }
      catch (e) {
      }
    },
	/*Added for capturing the Reimburesemnt Rate %*/
    selReimbursementRateOnChange: function (component, event, helper) {
        helper.getActivityAmount(component);
	}
});