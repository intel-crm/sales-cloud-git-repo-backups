({
    initializeBasicAttributes: function(component) {
        // Initialize default values
        component.set("v.SelCategory", $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.SelActivityType", $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.message", "");
        component.set("v.messageType", "");
        component.set("v.maxIntelInvestment",null);

        var recordType = component.get("v.recordtypeDeveloperName");
        this.setAccountFilter(component, recordType);

        // Initialize status labels
        var statuslabel = $A.get("$Label.c.Core_MDF_FundRequestStatusLabel");
        if(statuslabel) {
            var statusArray = statuslabel.split(",");
            var displayStatus = [];
            
            for(var i = 0; i < statusArray.length; i++){
                if(i == 0){
                    displayStatus.push({
                        class: "optionClass",
                        label: statusArray[i],
                        value: "Cancelled"
                    });
                } else {
                    displayStatus.push({
                        class: "optionClass",
                        label: statusArray[i],
                        value: statusArray[i]
                    }); 
                }
            }
            component.set("v.StatusLabel", displayStatus);
        }
    },

    loadInitialData: function(component) {
        
        var mode = component.get("v.mode");
        
        // Load API to Label conversion first
        if(component.get("v.apitoLabelConvert") == null){
            var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
            if(fields) {
                var fieldlist = fields.split(",");
                this.convertApitoLable(component, fieldlist);
            }
        }
        
        this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
        
        
        this.loadUserPermissions(component);

        /*if(mode === 'edit' || mode === 'clone') {
            this.loadPFR(component);
        }*/
       
        this.partnerEffortMetricForActivityCreation(component);
        this.getInitialDataFromServer(component);
    },
	SetAccMgrDisabledState: function (component) {
        //var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var hasPerSet = component.get("v.accmgrper");
        var mapVar = [];
        var frstatus = component.get("v.CurrentStatus");
        var actgry = component.get("v.SelCategory");
      
        if (hasPerSet == true) {
               if (!component.get("v.isUserCurrentIPAApprover")) {
                    if (frstatus == "Revision Required" || frstatus == "Draft") {
                        
                        component.set("v.isSPIFSecReadOnly", false);
                    }
                    else if (frstatus == "Planned") {
                        component.set("v.isSPIFSecReadOnly", false);
                    }
                     else if(frstatus == "In-Progress" || frstatus == "In-Progress Revision Required") {
                                component.set("v.isSPIFSecReadOnly", false);//SPIF to be editable
                     }
                        
                    
                }
        }
        
    },
    getFieldEditabilityMapping : function(component, event){
        component.set("v.showSpinner", true);
        var recordTypeDeveloperName = (component.get("v.newPFR.RecordType.DeveloperName"));
       
        var fieldEditibilityMap = component.get("c.getFieldEditabilityMapping");
        var pfrFieldEditablity = {};
        fieldEditibilityMap.setParams({
            obj: component.get("v.newPFR"),
            contentType: 'Field Editability'
        });

        fieldEditibilityMap.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") { 
            var result = response.getReturnValue(); 
            if(result != undefined && result != null){  
                var pfrEditFields = result;
                if(pfrEditFields.fieldEditability != null && pfrEditFields.fieldEditability != undefined){                           
                    for (var key in pfrEditFields.fieldEditability) {
                        pfrFieldEditablity[key]=pfrEditFields.fieldEditability[key];
                    }
                }
                component.set("v.pfrFieldEditablity",pfrFieldEditablity);
                var child = component.find("tacticMetrics");
                if (child && component.get("v.pfrFieldEditablity.Core_MDF_Tactics_nm__c")) {
                    child.handleEdit(component.get("v.pfrFieldEditablity.Core_MDF_Tactics_nm__c"));
                }
            }
            
            //this.loadPFR(component);

        }
        else{
            component.set("v.pfrFieldEditablity",null);
        }
        component.set("v.showSpinner", false);
        });
        $A.enqueueAction(fieldEditibilityMap);

        
    },

   
    loadUserPermissions: function(component) {
        var userperMap = {};
        var permissionSetName;
        var permissionSets = [];
        
        // Load permission sets
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_CCF_DCF");
        if(permissionSetName) {
            permissionSets = permissionSetName.split(",");
            userperMap["externalper"] = permissionSets;
        }
        
        permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Internal_IPA_Acct_Mgr_PS");
        if(permissionSetName) {
            permissionSets = permissionSetName.split(",");
            //userperMap["ipaAcctMgr"] = permissionSets;
            userperMap["accmgrper"] = permissionSets;
        }
        
        permissionSetName = $A.get("$Label.c.Core_MDF_IPA_L2_Approver_PS");
        if(permissionSetName) {
            permissionSets = permissionSetName.split(",");
            userperMap["ipaL2Approver"] = permissionSets;
        }
        
        permissionSetName = $A.get("$Label.c.Core_MDF_PriceReviewers");
        if(permissionSetName) {
            permissionSets = permissionSetName.split(",");
            userperMap["priceReviewersPer"] = permissionSets;
        }
        
        // Call server to check permissions
        var action = component.get("c.userHasPermissionSet");
        action.setParams({
            "permissionsets": userperMap
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                if(result && result.userPermissions) {
                    component.set('v.userperMap', result.userPermissions);
                    component.set("v.isActivityReviewRequired", result.isActivityReviewRequired);
                    
                    var mapResults = result.userPermissions;
                    for(var key in mapResults) {
                        component.set("v." + key, mapResults[key]);
                    }
                    
                    //Set ipaAcctMgr based on accmgrper value
                    component.set("v.ipaAcctMgr", component.get("v.accmgrper"));
                    
                    // Check user access
                    if (!component.get("v.accmgrper") 
                        && !component.get("v.externalper") 
                        && !(component.get("v.priceReviewersPer") && component.get("v.componentAttributes.isLoggedInUserApprover"))) {
                        component.set("v.userWithoutAccess", true);
                    }
                }
            } else {
               
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error","dismissible");
            }
            
            
            if(component.get("v.priceReviewersPer")){ 
                this.hasIUPGMRecord(component);
            }
            
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    },

    getInitialDataFromServer: function (component) {
        var inputParams = {};
        inputParams.recordId = component.get("v.recordId");
        inputParams.isClone = component.get("v.checkCloneAttribute");
        
        var actionGetInitialData = component.get("c.getInitialData");
        actionGetInitialData.setParams({
            inputValues: JSON.stringify(inputParams)
        });
        
        actionGetInitialData.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.componentAttributes", result);
            } else if (state === "ERROR") {
                
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error","dismissible");
            }
        });
        
        $A.enqueueAction(actionGetInitialData);
    },

    partnerEffortMetricForActivityCreation: function(component){
        var currDateTime = new Date();
        const startDateTime = new Date(currDateTime).toISOString();
        component.set("v.activityCreationStartTime", startDateTime);
    },

    convertApitoLable: function (component, fieldlist) {
        var action = component.get("c.getLabelApiMapforPicklistfields");
        action.setParams({
            "objName": 'Core_MDF_Custom_Picklist__c',
            "pfrPiclistField": fieldlist
        });
        
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var optionMap = response.getReturnValue();
                component.set("v.apitoLabelConvert", optionMap);

                if(component.get("v.checkCloneAttribute") == false){
                    var getoptionMap = component.get("v.apitoLabelConvert");
                    for(var key in getoptionMap ){
                        if(key = component.get("v.CurrentStatus")){
                            component.set("v.CurrentStatusLabel", getoptionMap[key]);
                            break;
                        }
                    }
                }
                
                var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
                if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && optionMap != null){
                    this.updatefocusAreaPickVals(component);   
                }
            } else {
            }
        });
        
        $A.enqueueAction(action);
    },

  activityPicker: function (component, recordType) {
    var pickLabel = $A.get("$Label.c.Core_MDF_IPA_PFR_UI_Fields");
    
    var pickListFields = pickLabel.split(",");
    var action = component.get("c.customPicklistFetcher");
    
    action.setParams({
        "recordTypeName": recordType
    });
    
    action.setCallback(this, function (response) {
        var state = response.getState();
        if(state === "SUCCESS"){
            var result = response.getReturnValue();
            if(result && result.picklistFieldValues) {
                
                // Process all picklist fields (existing logic unchanged)
                for (var i = 0; i < pickListFields.length; i++) {
                    if(result.picklistFieldValues[pickListFields[i]]) {
                        var sControllingFieldValues = result.picklistFieldValues[pickListFields[i]].controllerValues;
                        var sFieldValues = result.picklistFieldValues[pickListFields[i]].values;
                        this.initActcategoryandType(component, pickListFields[i], sControllingFieldValues, sFieldValues);
                    }
                }
              
            }
            var mode = component.get("v.mode");
            if((mode == 'clone' || mode == 'edit') && !component.get("v.initialLoadCompleted")) {
                this.loadPFR(component);
            }
        } else {
            var errors = response.getError();
            var message = 'Unknown error';
            if (errors && errors[0] && errors[0].message) {
                message = errors[0].message;
            }
            this.displaySuccessErrorMsg('Failed to load picklist values: ' + message, "Error", "error","dismissible");
        }
        component.set("v.showSpinner", false);
    });
    
    $A.enqueueAction(action);
},


    initActcategoryandType: function (component, fldname, scontrolvalues, sfieldcompletevalues) {
        var controllingFieldValues = JSON.stringify(scontrolvalues).slice(1, -1);
        var confieldmap = new Object();
        
        if (controllingFieldValues != '') {
            var res = controllingFieldValues.split(",");
            for (var index = 0; index < res.length; index++) {
                var keyvalue = res[index].split(":");
                confieldmap[keyvalue[1]] = keyvalue[0].slice(1, -1);
            }
        }
        
        var sValues;
        var childPickField = new Object();
        var ParPickField = [];
        
        for (var i = 0; i < sfieldcompletevalues.length; i++) {
            if (sfieldcompletevalues[i].validFor.length > 0) {
                for (var j = 0; j < sfieldcompletevalues[i].validFor.length; j++) {
                    var key = confieldmap[sfieldcompletevalues[i].validFor[j]];
                    
                    if (key in childPickField) {
                        childPickField[key].push({
                            class: "optionClass",
                            label: sfieldcompletevalues[i].label,
                            value: sfieldcompletevalues[i].value
                        });
                    } else {
                        sValues = new Array();
                        sValues.push({
                            class: "optionClass",
                            label: sfieldcompletevalues[i].label,
                            value: sfieldcompletevalues[i].value
                        });
                        childPickField[key] = sValues;
                    }
                }
            } else {
                if (ParPickField.length == 0) {
                    if(fldname != "Core_MDF_Reimbursement_Rate_pct__c" && fldname !="Core_MDF_Country_nm__c" && fldname != "Core_MDF_Tactics_nm__c"){
                        ParPickField.push({
                            class: "optionClass",
                            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                            value: ""
                        });
                    }
                }
                ParPickField.push({
                    class: "optionClass",
                    label: sfieldcompletevalues[i].label,
                    value: sfieldcompletevalues[i].value
                });
            }
        }
        
        // Set picklist values based on field name
        if (ParPickField.length > 0) {
            if (fldname == "Core_MDF_Focus_Area_nm__c") {
                component.set("v.focusArea", ParPickField);
            }
            if(fldname == "Core_MDF_Tactics_nm__c"){
                component.set("v.activityTacticsOptions", ParPickField);
                this.updateTacticsPickVals(component);
            }
            
        } else {
            // Handle dependent picklists
            this.handleDependentPicklists(component, fldname, childPickField);
        }
    },

    handleDependentPicklists: function(component, fldname, childPickField) {
        switch(fldname) {
            case "Core_MDF_ProductType__c":
                component.set("v.ProductTypes", childPickField);               
                this.fetchProdType(component);
                break;
            case "Core_MDF_TargetAudience_nm__c":
                component.set("v.audiencePicklistValues", childPickField);     
                this.fetchMultiTargetAudience(component);
                break;
            case "Core_MDF_Brand_nm__c":
                component.set("v.MultiBrandTypes", childPickField);
                this.fetchMultiBrandType(component);
                break;
            case "Core_MDF_Initiative_nm__c":
                component.set("v.initiativePicklistValues", childPickField);
                this.fetchMultiInitiative(component);
                break;
            case "Core_MDF_EcosystemPartner_nm__c":
                component.set("v.MultiEcoPartnerTypes", childPickField);
                this.fetchMultiEcoPartnerType(component);
                break;
            case "Core_MDF_Focus_Area_nm__c":
                component.set("v.focusArea", childPickField); 
                this.fetchFocusArea(component);
                break;
            case "Core_MDF_Country_nm__c":
                component.set("v.CountryPicklistValues", childPickField);
                this.fetchCountry(component);
                break;
            case "Core_MDF_Priority_nm__c":
                component.set("v.priority", childPickField);
                this.fetchPriority(component);
                break;
            case "Core_MDF_Priority_2_nm__c":
                component.set("v.priority2", childPickField);
                this.fetchSecondPriority(component); 
                break;
            case "Core_MDF_Outcome_Region_nm__c":
                component.set("v.regions", childPickField);
                this.fetchRegion(component);
                break;
            case "Core_MDF_Outcomes_nm__c":
                component.set("v.outcomes", childPickField);
                this.fetchOutcomeMetric(component);
                break;
            case "Core_MDF_Technology__c":
                component.set("v.technologies", childPickField);
                this.fetchTechnologies(component);
                break;
            
        }
    },
    
    
    fetchBudgetInfo: function(component){
        component.set("v.showSpinner", true);
        //component.set("v.selAvailableBudget", '');
        var availableBudget = [];
        var action = component.get("c.fetchBudgetInfo");
        var ultimateAccId = component.get("v.selectedAccount.Core_MDF_CoMarketing_Ultimate_Account__c");
        
        action.setParams({
            accountId: ultimateAccId,
            startDate: component.get("v.newPFR.Core_MDF_Start_Date__c"),
            endDate: component.get("v.newPFR.Core_MDF_End_Date__c"),
            budgetType: 'Account Plan',
            isIPAAccBased: true
        });

        action.setCallback(this, function (response) {
            component.set("v.showSpinner", false);
            var result = response.getReturnValue();
            var status = response.getState();
            
            if (status == "SUCCESS" && result != null && result.length != 0) {
                if(result.length > 0){
                    for(var index = 0; index < result.length; index++){
                        var startDate = result[index].StartDate.replaceAll('-','/');
                        var endDate = result[index].EndDate.replaceAll('-','/');
                        availableBudget.push({
                            key: result[index].Id,
                            value: result[index].Core_MDF_budget_ref_nbr__c+' : ' +result[index].Title + ' : ' + result[index].Core_MDF_Budget_Type_Txt__c+' : '+startDate + ' - ' + endDate 
                        });
                    }
                }
                component.set("v.showBudgetErrorMsg", false);
                component.set("v.budgetStr", availableBudget);
                
                if(availableBudget != null && availableBudget.length == 1) {
                    component.set("v.selAvailableBudget", availableBudget[0].key);
                    this.checkAvailAllocationAmt(component);
                }
            } else {
                component.set("v.showBudgetErrorMsg", true);
                component.set("v.budgetStr", '');
                component.set("v.selAvailableBudget", '');
            }
        });

        $A.enqueueAction(action);
    },

    fetchBudgetTypesBasedOnBenefits: function (component){
        var mode = component.get("v.mode");
        var action = component.get("c.getBudgetType");
        action.setParams({
            accId: component.get('v.selectedAccount').Id,
            operation: component.get('v.mode'),
            isProposalBased: String(component.get("v.isPropBasedCampaign")),
            program: 'Intel Partner Alliance'
        });

        action.setCallback(this, function (response) {
            var status = response.getState();
            
            if (status == "SUCCESS") {
                
                var budgetTypeList = component.get("v.budgetTypeVal");

                if (budgetTypeList && budgetTypeList.length > 1) {
                    return;
                }
                
                var result = response.getReturnValue();
                var budgetTypeOptionList = [];
                budgetTypeOptionList.push({
                    label: "---None---",
                    value: ""
                        });
                    
                for (var key in result) {
                        budgetTypeOptionList.push({ label: result[key], value: key });
                }

                if(result && Object.keys(result).length > 0){
                    component.set('v.showBudgetTypeError', false);
                }else{
                    component.set('v.showBudgetTypeError', true);
                }

                component.set("v.budgetTypeVal", budgetTypeOptionList);
                if(mode != '' && component.get('v.newPFR.Core_MDF_Budget_Type_nm__c')){
                    window.setTimeout($A.getCallback(function() {
                        let val = component.get('v.newPFR.Core_MDF_Budget_Type_nm__c');
                        component.set('v.selBudgetType', val);
                    }), 0);
                }
            } else {
                
            }
        });

        $A.enqueueAction(action);
    },

    checkAvailAllocationAmt: function (component) {
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
        });
        
        var selectedAccount = component.get("v.selectedAccount");
        if (selectedAccount && selectedAccount.Id) {
            var accountId = selectedAccount.Id;
        }
        var selectedbudget = component.get("v.selAvailableBudget");
	
	if((selectedbudget== null 
         || selectedbudget == undefined 
         || selectedbudget ==""))
       {
            //No message shown when no budget is selected
            component.set("v.isShowAllocationAmt",false);
            component.set("v.showAllocationAmtMsg",'');
       }
        var recordTypeDevName;
        
        if(component.get("v.mode") == ''){
            recordTypeDevName = component.get("v.recordtypeDeveloperName");
        } else if(component.get("v.mode") == 'edit' || component.get("v.mode") == 'clone'){
            recordTypeDevName = component.get("v.newPFR.RecordType.DeveloperName");
        }
        
        component.set("v.newPFR.Core_MDF_Budget_id__c", selectedbudget);
        component.set("v.newPFR.BudgetId", selectedbudget);
        
            //Method call for fetching allocations
        var action = component.get("c.checkAvailableAllocAmt");
        action.setParams({
            pfr: component.get("v.newPFR"),
            recordType: recordTypeDevName,
            accountId: accountId,
            budgetId: selectedbudget
        });
            $A.enqueueAction(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var result = response.getReturnValue();
                var amountToBeDisplayed = result.amountToBeDisplayed;
                var allocationId = result.allocationId;
                var isAutoEnabled = result.isAutoEnabled;
                    //Setting Allocation Amount Message 
                if(amountToBeDisplayed != $A.get("$Label.c.Core_MDF_ZeroAllocationAmount")){
                    if(isAutoEnabled == true){
                         component.set("v.showAllocationAmtMsg", $A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg")+" "+
                                        formatter.format(amountToBeDisplayed)+" "+$A.get("$Label.c.Core_MDF_AllocationAmountAutoEnabled"));    
                         component.set("v.isShowAllocationAmt", true);
                    } else {
                         component.set("v.showAllocationAmtMsg", $A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg")+" "+formatter.format(amountToBeDisplayed));
                         component.set("v.isShowAllocationAmt", true);
                    }
                    component.set("v.newPFR.AllocationId", allocationId);
                } else {
                    if(this.isNotBlank(component.get("v.selAvailableBudget"))) {
                       component.set("v.isShowAllocationAmt", true);
                       component.set("v.showAllocationAmtMsg", amountToBeDisplayed);
                   } else {
                       component.set("v.isShowAllocationAmt", false);
                       component.set("v.showAllocationAmtMsg", '');
                   }
                }
            } else {
                /*var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");*/
            }
        });
},

    resetHelper: function (component) {
        component.set("v.Uploadfinished", false);
        component.set("v.PopupButtonValue", false);
        component.set("v.ELCPopupButtonValue", false);
        component.set("v.PopupType", null);
        component.set("v.ShowEventPopup", false);
        component.set("v.goForSave",false);
        component.set("v.renderPrintQuestion", false);
        component.set("v.renderGovtQuestion", false);
        component.set("v.renderTechExplorationQuestSection", false);
        component.set("v.recordApplicableForActivityRules", true);
        component.set("v.hideCompetitiveQuest", false);
        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", null);
    },
	checkEventTactics: function(component) {
	var selectedTactics = component.get("v.selectedTacticsOptions");
	var spifTactics = 'Event';
	if(selectedTactics!=null && selectedTactics!=undefined){
	  for (var index = 0; index < selectedTactics.length; index++) {
		if (spifTactics.includes(selectedTactics[index])) {
			return true;
		}
		}  
	}
	
	return false;
},
    displaySuccessErrorMsg: function(Message, Title, Type, Mode){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: Title,
            message: Message,
            type: Type,
            mode: Mode 
        });
        toastEvent.fire();
    },

    isNotBlank: function(value) {
        return (value !== undefined && value !== null && value !== '');
    },

    hasIUPGMRecord: function(component) {
        if (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' && component.get("v.newPFR.Core_MDF_Approval_Stage__c")=='Price Reviewer'){
            component.set("v.isSPIFSecReadOnly", false);
        }
    },
    

fetchMultiTargetAudience: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var selectedFocusArea = component.get("v.selectedFocusArea");
        var audiencePicklistValues = component.get("v.audiencePicklistValues");
        
        if(selectedFocusArea && audiencePicklistValues) {
            childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, audiencePicklistValues);
        }
    }
    
    component.set("v.MultiTargetAudienceValues", childValuesReturn);
    this.updateAudiencePickVals(component);
},

fetchMultiBrandType: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var selectedFocusArea = component.get("v.selectedFocusArea");
        var multiBrandTypes = component.get("v.MultiBrandTypes");
        
        if(selectedFocusArea && multiBrandTypes) {
            childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, multiBrandTypes);
        }
    }
    
    component.set("v.MultiBrandValues", childValuesReturn);
    this.updateBrandPickVals(component);
},

fetchMultiInitiative: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var selectedFocusArea = component.get("v.selectedFocusArea");
        var initiativePicklistValues = component.get("v.initiativePicklistValues");
        
        if(selectedFocusArea && initiativePicklistValues) {
            childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, initiativePicklistValues);
        }
    }
    
    component.set("v.MultiInitiativeValues", childValuesReturn);
    this.updateInitiativePickVals(component);
},

fetchMultiEcoPartnerType: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var selectedFocusArea = component.get("v.selectedFocusArea");
        var multiEcoPartnerTypes = component.get("v.MultiEcoPartnerTypes");
        
        if(selectedFocusArea && multiEcoPartnerTypes) {
            childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, multiEcoPartnerTypes);
        }
    }
    
    component.set("v.MultiEcoPartnerValues", childValuesReturn);
    this.updateEcoPartnerPickVals(component);
},

fetchFocusArea: function (component) {
    var recordTypeName = component.get("v.recordtypeName");
    var focusAreaOptions = component.get("v.focusArea");
    
    if(recordTypeName && focusAreaOptions) {
        var childValuesReturn = this.setChildPicklistValues(component, recordTypeName, focusAreaOptions);
        
        if(childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1){
            childValuesReturn.sort(this.case_insensitive_sort);
            var localizedval = this.localizeSubType(component, childValuesReturn);
            component.set("v.focusAreaDependent", localizedval);
            this.updatefocusAreaPickVals(component);
        }
    }
},

fetchCountry: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    var recordTypeName = component.get("v.recordtypeName");
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var countryPicklistValues = component.get("v.CountryPicklistValues");
        
       // if(selectedRegion && countryPicklistValues) {
            childValuesReturn = this.setChildPicklistValues(component, recordTypeName, countryPicklistValues);
        //}
    }
    
    component.set("v.CountryDependants", childValuesReturn);
    this.updateCountryPickVals(component);
},

fetchProdType: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var selectedFocusArea = component.get("v.selectedFocusArea");
        var productTypes = component.get("v.ProductTypes");
        
        if(selectedFocusArea && productTypes) {
            childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, productTypes);
        }
    }
    
    component.set("v.ProductTypeDependent", childValuesReturn);
    this.updateProductTypePickVals(component);
},

updatefocusAreaPickVals: function(component) {
    var focusAreaOptions = component.get("v.focusAreaDependent");
    var localizedMap = component.get("v.apitoLabelConvert");
    var focusAreaMap = [];
    var focusAreaString = "";
    
    if(focusAreaOptions && focusAreaOptions.length > 0) {
        // Add "None" option if multiple options available
        if(focusAreaOptions.length > 1) {
            focusAreaMap.push({
                label: "---None---",
                value: ""
            });
        }
        
        for (var index = 0; index < focusAreaOptions.length; index++) {
            var option = focusAreaOptions[index];
            var label = this.decodeHtmlEntities(option.label);  
            var value = this.decodeHtmlEntities(option.value);  
            
            // Apply localization if available
            if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);
            }
            
            focusAreaMap.push({
                "label": label,
                "value": value
            });
            
            if(focusAreaOptions.length == 1) {
                focusAreaString = value;  
            }
        }
        
        // Auto-select if only one option
        if(focusAreaMap.length == 1 || (focusAreaMap.length == 2 && focusAreaMap[0].value === "")) {
            component.set("v.selectedFocusArea", focusAreaString);
        }
    }

    var focusAreaList = component.get("v.AllFocusAreaOptions");
    if (!focusAreaList || focusAreaList.length == 0) {
        component.set("v.AllFocusAreaOptions", focusAreaMap);
    }
},

updateAudiencePickVals: function(component) {
    var audienceOptions = component.get("v.MultiTargetAudienceValues") ;
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    if(audienceOptions && audienceOptions.length > 0) {
        for(var i = 0; i < audienceOptions.length; i++) {
            var option = audienceOptions[i];
            var label = option.label;
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value];
            }
            
            processedOptions.push({
                "label": label,
                "value": option.value
            });
        }
    }
    
    component.set("v.AllTargetAudienceOptions", processedOptions);
},

updateBrandPickVals: function(component) {
    var brandOptions = component.get("v.MultiBrandValues") ;
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    if(brandOptions && brandOptions.length > 0) {
        for(var i = 0; i < brandOptions.length; i++) {
            var option = brandOptions[i];
            var label = option.label;
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value];
            }
            
            processedOptions.push({
                "label": label,
                "value": option.value
            });
        }
    }
    
    component.set("v.AllBrandOptions", processedOptions);
},

updateInitiativePickVals: function(component) {
    var initiativeOptions = component.get("v.MultiInitiativeValues") ;
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    if(initiativeOptions && initiativeOptions.length > 0) {
        for(var i = 0; i < initiativeOptions.length; i++) {
            var option = initiativeOptions[i];
             var label = option.label ? option.label.replace("&amp;", "&") : "";
             var value = option.value ? option.value.replace("&amp;", "&") : "";
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value].replace("&amp;", "&");
            }
            
            processedOptions.push({
                "label": label,
                "value": value
            });
        }
    }
    
    component.set("v.AllInitiativeOptions", processedOptions);
},

updateEcoPartnerPickVals: function(component) {
    var ecoPartnerOptions = component.get("v.MultiEcoPartnerValues") ;
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    if(ecoPartnerOptions && ecoPartnerOptions.length > 0) {
        for(var i = 0; i < ecoPartnerOptions.length; i++) {
            var option = ecoPartnerOptions[i];
            var label = option.label;
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value];
            }
            
            processedOptions.push({
                "label": label,
                "value": option.value
            });
        }
    }
    
    component.set("v.AllEcosystemPartner", processedOptions);
},

updateProductTypePickVals: function(component) {
    var productTypeOptions = component.get("v.ProductTypeDependent") ;
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];

    processedOptions.push({
    label: "---None---",
    value: ""
        });
    
    if(productTypeOptions && productTypeOptions.length > 0) {
        for(var i = 0; i < productTypeOptions.length; i++) {
            var option = productTypeOptions[i];
            var label = this.decodeHtmlEntities(option.label);
            var value = this.decodeHtmlEntities(option.value);
            
            if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);
            }
            
            processedOptions.push({
                "label": label,
                "value": value
            });
        }
    }
    
    component.set("v.ProductTypeValues", processedOptions);
},

setChildPicklistValues : function(component, controllingValues, dependentValues){
        var childPicklistValue = new Array();
        var childValueOptionsMap = new Array();
        if (dependentValues != null) {
            childValueOptionsMap = dependentValues[controllingValues];
            if (childValueOptionsMap != null) {
                for (var index = 0; index < childValueOptionsMap.length; index++){
                    childPicklistValue.push(childValueOptionsMap[index]);
                }	
            }
        }
        return childPicklistValue;
    },

// Helper method for case insensitive sorting
case_insensitive_sort: function(a, b) {
    return a.label.toLowerCase().localeCompare(b.label.toLowerCase());
},

// Helper method for localization
localizeSubType: function(component, options) {
    var localizedMap = component.get("v.apitoLabelConvert");
    var localizedOptions = [];
    
    if(options && options.length > 0) {
        for(var i = 0; i < options.length; i++) {
            var option = options[i];
            var label = option.label;
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value];
            }
            
            localizedOptions.push({
                label: label,
                value: option.value,
                class: option.class || "optionClass"
            });
        }
    }
    
    return localizedOptions;
},

updateTacticsPickVals: function(component) {
    var tacticsOptions = component.get("v.activityTacticsOptions");
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    if(tacticsOptions && tacticsOptions.length > 0) {
        for(var i = 0; i < tacticsOptions.length; i++) {
            var option = tacticsOptions[i];
            var label = option.label;
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value];
            }
            
            processedOptions.push({
                "label": label,
                "value": option.value
            });
        }
    }
    
    component.set("v.activityTacticsOptions", processedOptions);
},

updateOutcomeMetricValues: function(component) {
    var outcomeMetricOptions = component.get("v.outcomesDependants") ;
    var outcomemetriclocalizedMap = component.get("v.apitoLabelConvert");
    var outcomeMetricOptionsMap = [];

    // Process outcome metric options with localization (dependent values already filtered in fetchOutcomeMetric)
    if(outcomeMetricOptions && outcomeMetricOptions.length > 0) {
        for (var index = 0; index < outcomeMetricOptions.length; index++) {
            var outcomeValue = outcomeMetricOptions[index].value;
            var outcomeLabel = outcomeMetricOptions[index].label;
            
            //localizedval[index].value == 'Other'
            if(outcomeValue ==='Other' || outcomeLabel==='Other'){
            continue; // Skip the rest of the loop for this iteration
        	}
            // Check if localized label exists
            if(outcomemetriclocalizedMap && outcomemetriclocalizedMap[outcomeValue]) {
                outcomeLabel = outcomemetriclocalizedMap[outcomeValue];
            }
            
            outcomeMetricOptionsMap.push({
                "label": outcomeLabel,
                "value": outcomeValue
            });
        }
        
        // Set processed options with localization
        component.set("v.outcomeMetricOptions", outcomeMetricOptionsMap);
    }
},


updateCountryPickVals: function(component) {
    var countryOptions = component.get("v.CountryDependants") ;
    var countrylocalizedMap = component.get("v.apitoLabelConvert");
    var countryOptionsMap = [];

    if(countryOptions && countryOptions.length > 0) {
        for (var index = 0; index < countryOptions.length; index++) {
            var countryLabel = countryOptions[index].label;
            var countryValue = countryOptions[index].value;
            
            // Check if localized label exists
            if(countrylocalizedMap && countrylocalizedMap[countryValue]) {
                countryLabel = countrylocalizedMap[countryValue];
            }
            
            countryOptionsMap.push({
                "label": countryLabel,
                "value": countryValue
            });
        }
        
        // Set processed options with localization
        component.set("v.AllCountryOptions", countryOptionsMap);
        component.set("v.AllCountryOptionsMain", countryOptionsMap);

        if(component.get("v.SelRegion")){
            this.fetchCountriesByRegionUsingAllOptions(component, component.get("v.SelRegion"));
        }
    }
},

fetchCountriesByRegionUsingAllOptions: function(component, region) {
    var masterList = component.get("v.AllCountryOptionsMain") || [];
    if(masterList.length == 0){
        return;
    }
    component.set("v.showSpinner", true);


    // Extract labels/values into plain string list
    var allowedLabels = masterList.map(function(c) {
        return c.label;
    });

    var action = component.get("c.getCountryLabelsByRegion");
    action.setParams({
        region: region,
        allowedCountryLabels: allowedLabels
    });

    //var self = this;
    action.setCallback(this, function(response) {
        component.set("v.showSpinner", false);
        var state = response.getState();

        if (state === "SUCCESS") {
            var serverList = response.getReturnValue() || [];
            serverList.sort();

            var options = [];
            for (var j = 0; j < serverList.length; j++) {
                options.push({
                    label: serverList[j],
                    value: serverList[j]
                });
            }

            component.set("v.AllCountryOptions", options);

        } else {
            var errs = response.getError();
            var msg = 'Error fetching countries';
            if (errs && errs[0] && errs[0].message) msg = errs[0].message;

            try {
                this.displaySuccessErrorMsg(component, msg, "Error", "error");
            } catch (e) {
                var toast = $A.get("e.force:showToast");
                if (toast) {
                    toast.setParams({
                        title: "Error",
                        message: msg,
                        type: "error",
                        mode: "dismissible"
                    });
                    toast.fire();
                }
					
            }
        }
    });

    $A.enqueueAction(action);
},

updatePriorityPickVals: function(component) {
    var priorityOptions = component.get("v.priorityDependent");
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];

    processedOptions.push({
    label: "---None---",
    value: ""
        });
    
    if(priorityOptions && priorityOptions.length > 0) {
        for(var i = 0; i < priorityOptions.length; i++) {
            var option = priorityOptions[i];
            var label = this.decodeHtmlEntities(option.label);
            var value = this.decodeHtmlEntities(option.value);
            
            if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);
            }
            
            processedOptions.push({
                "label": label,
                "value": value
            });
        }
    }
    
    component.set("v.priorityValues", processedOptions);
    var originalPriority = component.get("v.SelPriority");
    component.set('v.SelPriority','');
    component.set('v.SelPriority',originalPriority);
},

 updateTechnologyPickVals: function(component) {
        var priorityOptions = component.get("v.technologiesDependant");
        var localizedMap = component.get("v.apitoLabelConvert");
        var processedOptions = [];
        
        if(priorityOptions && priorityOptions.length > 0) {
            for (var i = 0; i < priorityOptions.length; i++) {
                var option = priorityOptions[i];
                var label = option.label ? option.label.replace("&amp;", "&") : "";
                var value = option.value ? option.value.replace("&amp;", "&") : "";
                if (localizedMap && localizedMap[option.value]) {
                    label = localizedMap[option.value].replace("&amp;", "&");
                }
                
                processedOptions.push({
                    "label": label,
                    "value": value
                });
            }
            
        }
        
        component.set("v.AllTechnologyOptions", processedOptions);
    },


updateSecondPriorityPickVals: function(component) {
    var priority2Options = component.get("v.priority2Dependants");
    var selectedPriority = component.get("v.SelPriority"); // Filter out Priority selection
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    processedOptions.push({
    label: "---None---",
    value: ""
        });
    
    if(priority2Options && priority2Options.length > 0) {
        for(var i = 0; i < priority2Options.length; i++) {
            var option = priority2Options[i];
            var label = this.decodeHtmlEntities(option.label);
            var value = this.decodeHtmlEntities(option.value);
            
            // Skip if this value is selected in Priority field
            if(value === selectedPriority) {
                continue;
            }
            
            if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);
            }
            
            processedOptions.push({
                "label": label,
                "value": value
            });
        }
    }
    
    component.set("v.priorityValues2", processedOptions);
},

fetchPriority: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
       childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.priority"));
           component.set("v.priorityDependent", childValuesReturn);
            this.updatePriorityPickVals(component);
            //var self = this;
    setTimeout(function() {
        this.fetchSecondPriority(component);
    }, 100);
            
   },


fetchTechnologies: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
        childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.technologies"));
           component.set("v.technologiesDependant", childValuesReturn);
            this.updateTechnologyPickVals(component);
   },

fetchSecondPriority: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var selectedFocusArea = component.get("v.selectedFocusArea");
    var selectedPriority = component.get("v.SelPriority");   
   
    var childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, component.get("v.priority2"));
  
    
    component.set("v.priority2Dependants", childValuesReturn);
    this.setPriority2AllValues(component);
    this.filterPriority2BasedOnPriority(component);
},

setPriority2AllValues: function(component) {
    var priority2Options = component.get("v.priority2Dependants");
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    

    
    processedOptions.push({
        label: "--None--",
        value: ""
    });
    
    if(priority2Options && priority2Options.length > 0) {
        for(var i = 0; i < priority2Options.length; i++) {
            var option = priority2Options[i];
            var label = this.decodeHtmlEntities(option.label);  
            var value = this.decodeHtmlEntities(option.value);  
            if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);  
            }
            
            processedOptions.push({
                "label": label,  
                "value": value   
            });
        }
    }
    
  
    
    component.set("v.allPriority2Values", processedOptions);
},

filterPriority2BasedOnPriority: function(component) {
    var allPriority2Values = component.get("v.allPriority2Values");
    var selectedPriority = component.get("v.SelPriority");
    var filteredOptions = [];
    var helper = this; // Reference to helper
    
    // ↓ ADD "None" as default option (always add it first)
    filteredOptions.push({
        label: "--None--",
        value: ""
    });
    // ↑ END of "None" option addition
    
    if(allPriority2Values && allPriority2Values.length > 0) {
        for(var i = 0; i < allPriority2Values.length; i++) {
            var option = allPriority2Values[i];
            
            if(option.value !== "" && option.value !== selectedPriority) {
                // Ensure labels and values are decoded (in case they weren't processed through setPriority2AllValues)
                var decodedLabel = this.decodeHtmlEntities(option.label);
                var decodedValue = this.decodeHtmlEntities(option.value);
                
                filteredOptions.push({
                    "label": decodedLabel,
                    "value": decodedValue
                });
            }
        }
    }
    

    component.set("v.priorityValues2", filteredOptions);
    
    // Clear Priority #2 if it matches Priority selection
    var currentPriority2 = component.get("v.SelPriority2");
    if(currentPriority2 === selectedPriority) {
        component.set("v.SelPriority2", "");
    }
    
    // ↑ END of auto-select logic
},

fetchRegion: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
         childValuesReturn = this.setChildPicklistValues(component, component.get("v.recordtypeName"), component.get("v.regions"));
          component.set("v.regionDependants", childValuesReturn);
            this.updateRegionPickVals(component);
   },

fetchOutcomeMetric: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
         childValuesReturn = this.setChildPicklistValues(component, component.get("v.recordtypeName"), component.get("v.outcomes"));
          if(childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1){
                childValuesReturn.sort(this.case_insensitive_sort);
                component.set("v.outcomesDependants", childValuesReturn);
                this.updateOutcomeMetricValues(component);
            } 
   },

updateRegionPickVals: function(component) {
    var regionOptions = component.get("v.regionDependants") ;
    var regionlocalizedMap = component.get("v.apitoLabelConvert");
    var regionOptionsMap = [];

    regionOptionsMap.push({
        label: "--None--",
        value: ""
    });
    // Process region options with localization (dependent values already filtered in fetchRegion)
    if(regionOptions && regionOptions.length > 0) {
        for (var index = 0; index < regionOptions.length; index++) {
            var regionValue = regionOptions[index].value;
            var regionLabel = regionOptions[index].label;
            
            // Check if localized label exists
            if(regionlocalizedMap && regionlocalizedMap[regionValue]) {
                regionLabel = regionlocalizedMap[regionValue];
            }
            
            regionOptionsMap.push({
                "label": regionLabel,
                "value": regionValue
            });
        }
        
        // Set processed options with localization
        component.set("v.regionvalues", regionOptionsMap);
    }
},

loadPFR: function(component) {
    if (!component.get("v.recordId")) {
        return; // No record to load
    }

    component.set("v.showSpinner", true);
    var mode = component.get("v.mode");
    
    var actionLoadPfr = component.get("c.loadPFRRecord");
    actionLoadPfr.setParams({
        pfrId: component.get("v.recordId")
    });
    
    actionLoadPfr.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            
            if (result) {
                // Set the core PFR object
                component.set("v.newPFR", result);
                
                // Set record type information
                if (result.RecordType) {
                    component.set("v.recordtypeName", result.RecordType.Name);
                    component.set("v.recordtype", result.RecordTypeId);
                    component.set("v.recordtypeDeveloperName", result.RecordType.DeveloperName);
                }
                
                // Set selected account if available
                if (result.ChannelPartner) {
                    component.set("v.selectedAccount", result.ChannelPartner);
                }
                
                // Set budget information for IPA
                if (result.RecordType.DeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
                    /*if (result.Core_MDF_Budget_Type_nm__c) {
                        component.set("v.selBudgetType", result.Core_MDF_Budget_Type_nm__c);
                    }*/
                    if (result.BudgetId) {
                        component.set("v.selAvailableBudget", result.BudgetId);
                    }
                    if (result.AllocationId) {
                        component.set("v.newPFR.AllocationId", result.AllocationId);
                    }
                }

                // Set multi-select picklist values
                this.setMultiSelectValues(component, result);
                
                // Set other essential fields
                this.setEssentialFields(component, result);
                
                // Set focus area and other essential picklist values
                if (result.Core_MDF_Focus_Area_nm__c) {
                    component.set("v.initialFocusAreaLoaded", true);
                    component.set("v.selectedFocusArea", result.Core_MDF_Focus_Area_nm__c);

                    //this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                    component.set("v.showDependentFields", true);
                    
                }
                
                component.set("v.initialLoadCompleted", true);

                if(mode == 'edit'){
                    this.getFieldEditabilityMapping(component);
                }
                
                // Set status information
                if (result.Core_MDF_Fund_Request_Status__c && !component.get("v.checkCloneAttribute")) {
                    component.set("v.CurrentStatus", result.Core_MDF_Fund_Request_Status__c);
                    // Load API to Label conversion first
                    var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
                    if(fields) {
                        var fieldlist = fields.split(",");
                        this.convertApitoLable(component, fieldlist);
                    }
                    component.set("v.checkStatusAttribute", true);
                }
                //set the spifreadonly
                this.SetAccMgrDisabledState(component);
                // Handle clone scenario
                if (component.get("v.checkCloneAttribute")) {
                    this.handleCloneScenario(component, result);
                }
                
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                    this.fetchBudgetInfo(component);
                }
                
                var newObject = new Object;
                var mergedObject = Object.assign(newObject, this.sanitizeResults(result));
                component.set("v.oldPFR", mergedObject);

                //new edit validation 
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
                        {
                            var alertMsg = $A.get("$Label.c.Core_MDF_CloneAccessError");
                            helper.displaySuccessErrorMsg(alertMsg, "Error!", "error", 'dismissible');
                            var sObectEvent = $A.get("e.force:navigateToSObject");
                            sObectEvent .setParams({
                                "recordId": component.get("v.recordId"),
                                "slideDevName": "detail"
                            });
                            sObectEvent.fire(); 
                        }
                }
                
            } else {

                this.displaySuccessErrorMsg('No record data found', "Error", "error","dismissible");
            }
        } else {
            
            var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
            this.displaySuccessErrorMsg(errorMessage, "Error", "error","dismissible");
        }
        
        if(mode != 'edit'){
            component.set("v.showSpinner", false);
        }
        
    });
    
    $A.enqueueAction(actionLoadPfr);
},

setMultiSelectValues: function(component, result) {
    // Set Country values
    if (result.Core_MDF_Country_nm__c) {
        var countryValues = result.Core_MDF_Country_nm__c.split(';');
        component.set("v.selectedCountryOptions", countryValues);
    }
    
    // Set Brand values
    if (result.Core_MDF_Brand_nm__c) {
        var brandValues = result.Core_MDF_Brand_nm__c.split(';');
        component.set("v.selectedBrandOptions", brandValues);
    }
    
    // Set Target Audience values
    if (result.Core_MDF_TargetAudience_nm__c) {
        var audienceValues = result.Core_MDF_TargetAudience_nm__c.split(';');
        component.set("v.selectedTargetAudienceOptions", audienceValues);
    }
    
    // Set Tactics values
    if (result.Core_MDF_Tactics_nm__c) {
        var tacticsValues = result.Core_MDF_Tactics_nm__c.split(';');
        component.set("v.selectedTacticsOptions", tacticsValues);
    }
    
    // Set Outcome Metric values
    if (result.Core_MDF_Outcomes_nm__c) {
        var outcomeValues = result.Core_MDF_Outcomes_nm__c.split(';');
        component.set("v.selectedOutcomeMetricOptions", outcomeValues);
    }
    
    // Set Technology values
    if (result.Core_MDF_Technology_txt__c) {
        var technologyValues = result.Core_MDF_Technology_txt__c.split(';');
        component.set("v.selectedTechnologyOptions", technologyValues);
    }
    
    // Set Initiative values
    if (result.Core_MDF_Initiative_nm__c) {
        var initiativeValues = result.Core_MDF_Initiative_nm__c.split(';');
        component.set("v.selectedInitiativeOptions", initiativeValues);
    }
    
    // Set Ecosystem Partner values
    if (result.Core_MDF_EcosystemPartner_nm__c) {
        var ecoPartnerValues = result.Core_MDF_EcosystemPartner_nm__c.split(';');
        component.set("v.selectedEcosystemPartnerOptions", ecoPartnerValues);
    }
},

setEssentialFields: function(component, result) {
    // Set budget amount
    if (result.Core_MDF_Budget_Amount_Local_amt__c) {
        component.set("v.BudgetLocal", result.Core_MDF_Budget_Amount_Local_amt__c);
    }
    
    // Set reimbursement rate
    if (result.Core_MDF_Reimbursement_Rate_pct__c) {
        component.set("v.SelReimbursementRate", result.Core_MDF_Reimbursement_Rate_pct__c);
    }
    
    // Set priority values
    if (result.Core_MDF_Priority_nm__c) {
        component.set("v.SelPriority", result.Core_MDF_Priority_nm__c);
    }
    
    if (result.Core_MDF_Priority_2_nm__c) {
        component.set("v.SelPriority2", result.Core_MDF_Priority_2_nm__c);
    }
    
    // Set region
    if (result.Core_MDF_Outcome_Region_nm__c && component.get("v.mode") == 'edit') {
        component.set("v.SelRegion", result.Core_MDF_Outcome_Region_nm__c);
    }
    
    // Set product type
    if (result.Core_MDF_ProductType__c) {
        component.set("v.SelProductType", result.Core_MDF_ProductType__c);
    }
    
    // Set Intel contribution for IPA
    if (result.Core_MDF_Activity_Reimbursement_Amt_nbr__c) {
        component.set("v.IPAIntelContri", result.Core_MDF_Activity_Reimbursement_Amt_nbr__c);
        component.set("v.maxIntelInvestment", result.Core_MDF_Maximum_Intel_Investment_amt__c);
    }
},

handleCloneScenario: function(component, result) {
    // Clear fields that shouldn't be cloned
    component.set("v.newPFR.Id", null);
    component.set("v.newPFR.Name", '');
    
    // Clear approval fields
    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", 'Draft');
    component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
    
    // Clear approver fields
    for (var i = 1; i <= 10; i++) {
        component.set("v.newPFR.Core_MDF_Approver_" + i + "__c", null);
    }
    
    // Clear other fields that shouldn't be cloned
    component.set("v.newPFR.Core_MDF_Attribution_Variance_Pos_txt__c", null);
    component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
    component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
    component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
    component.set("v.newPFR.Core_MDF_Internal_Tracking_txt__c", null);
    component.set("v.newPFR.Core_MDF_Metrics_txt__c", null);
},


validatePriorityFieldsImmediate: function(component) {
    
    var priority1 = component.get("v.SelPriority");
    var priority2 = component.get("v.SelPriority2");
    
    // Clear existing errors
    component.set("v.showPriority1Error", false);
    component.set("v.showPriority2Error", false);
    component.set("v.priority1Error", "");
    component.set("v.priority2Error", "");
    
    // Check for duplicate values and throw error
    if(priority1 && priority2 && priority1 === priority2 && priority1 !== '' && priority2 !== '') {
        component.set("v.showPriority1Error", true);
        component.set("v.priority1Error", $A.get("$Label.c.Core_MDF_Priority_error_msg2"));
        
        component.set("v.showPriority2Error", true);
        component.set("v.priority2Error", $A.get("$Label.c.Core_MDF_Priority_error_msg"));
        
        return false;
    }
    
    return true;
},
onRegionChange: function(component, event, helper) {
        var selectedRegion = null;
        if (event && event.getParam) 
            {selectedRegion = event.getParam('value');
            }
        if (!selectedRegion) {selectedRegion = component.get("v.SelRegion");}

        component.set("v.SelRegion", selectedRegion);

        // Fetch list filtered by region using allowed list from AllCountryOptions
        this.fetchCountriesByRegionUsingAllOptions(component, selectedRegion);
    },
calculateReimbursementRate: function(component, budgetAmount, maxIntelContribution,spifCheck) {
    var calculatedPercentage = 0;

    if (budgetAmount > 0 && maxIntelContribution >= 0) {
        calculatedPercentage = (maxIntelContribution / budgetAmount) * 100;
        calculatedPercentage = Math.min(100, Math.max(0, Math.round(calculatedPercentage * 100) / 100));
    }

    component.set("v.SelReimbursementRate", calculatedPercentage + '%');
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", component.get("v.SelReimbursementRate"));


    if(spifCheck){
            this.getActivityAmount(component);
    }

},
 getActivityAmount: function(component){
     	var activityAmount = component.get("v.maxIntelInvestment");
          var segComp = component.find("segmentComp");
          var segDisplayComp = component.find("displaySegment");  
            if(segComp){
                if(segComp[0] != null && segComp[0] != '' && segComp[0] != undefined){
                    segComp[0].checkSPIFAmountExceedsActivityAmount();
                }else{
                    segComp.checkSPIFAmountExceedsActivityAmount();
                }
            }
            if(segDisplayComp){
                segDisplayComp.checkSPIFAmountExceedsActivityAmount();
            }
        
        //return returnValue;
    },
/*hasIUPGMRecord : function (component){
	var userID = $A.get("$SObjectType.CurrentUser.Id");
	var countryList = component.get("v.newPFR.Core_MDF_Country_nm__c").split(';');
	
	component.set("v.userId", userID);
	var action = component.get("c.checkCurrentUserIsApprover");
	action.setParams({
	   "obj" : component.get("v.oldPFR"),
		"userId" :component.get("v.userId")
	});
	action.setCallback(this, function (response) {
		var state = response.getState();
		if (state === "SUCCESS") {
			var res = response.getReturnValue();
			if(res == true){
				component.set("v.hasIUPGMRecord", true);
				//this.setPriceReviewerDisableState(component);
			}else{
				component.set("v.hasIUPGMRecord", false);
			}                  
		}
	});
	$A.enqueueAction(action);
},*/

/*setPriceReviewerDisableState: function (component, event) { 
       
	var activityStatus = component.get("v.oldstatus");
	var hasPerSet = component.get("v.priceReviewersPer");
   
	if(hasPerSet) {
		var mapVar = [];
		mapVar = {
		  availableBudget: true,
		  attachement: true,                
		};
		component.set("v.disableRRPercent", true);
		//added for IPA mdf manager & price reviewer dual role scenario
		if(component.get("v.accmgrper")){
			if(component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Planned' || 
				 component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required') {
				 mapVar.attachement = false;
				 }
			component.set("v.isSaveDisable",false);
		}else{
			component.set("v.isSaveandNewDisable",true);
			component.set("v.isSaveDisable",true);
		}
		
		if((component.get("v.componentAttributes.isLoggedInUserApprover") || component.get("v.hasIUPGMRecord")) &&  this.isCurrentUsrIsApprover(component)&& component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' ){
			component.set("v.isSaveDisable", false);
			component.set("v.isSPIFSecReadOnly", false);
		}
		component.set("v.disabledMap", mapVar);
	}
},*/

/*loadPicklists: function(component) {
    if(component.get("v.apitoLabelConvert") == null){
        var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
        if(fields) {
            var fieldlist = fields.split(",");
            this.convertApitoLable(component, fieldlist);
        }
    }
    
    this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
    
    this.loadPFR(component);
    
    this.getFieldEditabilityMapping(component);
    this.loadUserPermissions(component);
    this.partnerEffortMetricForActivityCreation(component);
    this.getInitialDataFromServer(component);
},*/

/* method returns true if logged in user is approver for IPA activities*/
isCurrentUsrIsApprover: function (component) {
	var curUserId = $A.get("$SObjectType.CurrentUser.Id");
	var usrIsApprover = false;
	var approverSet = new Set();
	var ipaL2Approver = component.get("v.ipaL2Approver");
	
	component.set("v.recordtypeDeveloperName",'Core_MDF_Intel_Partner_Alliance');
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_1_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_2_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_3_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_4_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_5_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_6_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_7_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_8_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_9_id__c"));
	approverSet.add(component.get("v.newPFR.Campaign.Core_MDF_Approver_10_id__c"));
	 if (approverSet != null && curUserId != null 
		 && ((approverSet.has(curUserId)) 
		|| (((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
			  || component.get("v.newPFR.Core_MDF_Program__c") == ($A.get("$Label.c.Core_MDF_IPA_Program_Name")))
			 && (component.get("v.ipaAcctMgr"))
			&& (component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'L1 Approval'
				 ))))) {
		usrIsApprover = true;
		component.set("v.isUserCurrentIPAApprover", true);
	}else {
		if(component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'Price Reviewer' && component.get("v.priceReviewersPer")){
				usrIsApprover = true;
		} 
		if(ipaL2Approver){
			if((component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'L2 Regional Marketing' ||
				  component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'L2 Regional Sales')){
			usrIsApprover = true;
		}
    }
}
	return usrIsApprover;
},

//Method to check if selected tactics is spif/incentive eligible
checkSPIFTactics: function(component) {
	var selectedTactics = component.get("v.selectedTacticsOptions");
	var spifTactics = $A.get("$Label.c.Core_MDF_Spif_Tactics");
	if(selectedTactics!=null && selectedTactics!=undefined){
	  for (var index = 0; index < selectedTactics.length; index++) {
		if (spifTactics.includes(selectedTactics[index])) {
			return true;
		}
		}  
	}
	
	return false;
},

//Method returns true when Activity Status is Planned / Revision Required
isPlannedOrRevisionRequiredActivity: function (component) {
    //Core_MDF_PFR_Status_RevisionRequiredOrPendingReview - Planned, Revision Required
        
    return ($A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequiredOrPlanned").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c")));
},
//Check the Record type 
checkRecordTypeSelected : function(component , recordTypeDeveloperLabel){
	return(recordTypeDeveloperLabel.includes(component.get("v.recordtypeDeveloperName")));
},

//Method to check if field modified needs to trigger Approval
fieldEligibleForApprovalModified: function (component, editedFieldRequiresApproval) {
	
	for (var fieldName in editedFieldRequiresApproval){																		
		
		var oldFieldValue = "v.oldPFR." + editedFieldRequiresApproval[fieldName];
		var newFieldValue = "v.newPFR." + editedFieldRequiresApproval[fieldName];
		if(editedFieldRequiresApproval[fieldName] == 'Core_MDF_Activity_SubType_nm__c' && 
		   component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
			if(!$A.util.isEmpty(component.get(oldFieldValue))){
				var oldToArray = component.get(oldFieldValue).toString().split(';'); 
				var fieldMod = false;
				var result = 0;
				if(component.get(newFieldValue) != null && component.get(newFieldValue) != undefined && oldToArray != null){
				if(oldToArray.length != component.get(newFieldValue).length){
					fieldMod = true;
				}else{
					for(var i=0; i<oldToArray.length;i++){                        
						if(component.get(newFieldValue).includes(oldToArray[i])){
							result ++; 
						}
					}
					if(result != oldToArray.length){
						fieldMod = true; 
					}
				} 
			}         
			}         
			
		}
		
		
		    if(component.get(oldFieldValue) != undefined && component.get(oldFieldValue) != null && 
				!$A.util.isEmpty(component.get(oldFieldValue))){
			
			let isSameMultiplicklist = false;
			if(!$A.util.isEmpty(component.get(newFieldValue)) && newFieldValue == 'v.newPFR.Core_MDF_Tactics_nm__c'){
				let stringVal = component.get(oldFieldValue);
				let arrayVal = component.get(newFieldValue);
			
				if (!stringVal || !arrayVal) return;
			
				let strArray = stringVal.split(';').map(s => s.trim());
				let sortedStr = strArray.slice().sort();
				let sortedArr = arrayVal.slice().sort();
			
				isSameMultiplicklist = JSON.stringify(sortedStr) === JSON.stringify(sortedArr);
			}

			var isChanged = false;
			if(!$A.util.isEmpty(component.get(newFieldValue)) && 
			   ((component.get(oldFieldValue) != component.get(newFieldValue) && newFieldValue != 'v.newPFR.Core_MDF_Tactics_nm__c') || (newFieldValue == 'v.newPFR.Core_MDF_Tactics_nm__c' && !isSameMultiplicklist))){
				isChanged = true;
				if((typeof component.get(oldFieldValue) ==="string" && typeof component.get(newFieldValue) ==="string") && 
				   (component.get(oldFieldValue).includes(';') || component.get(newFieldValue).includes(';'))){
					var oldValue = [];
					var newValue = [];
					oldValue = component.get(oldFieldValue).split(';');
					newValue = component.get(newFieldValue).split(';');
					if(oldValue.length == newValue.length){
						const changedValues = oldValue.filter(element => !newValue.includes(element));
						if($A.util.isEmpty(changedValues)){
							isChanged = false;
						}
					}
					
				}
			}
			if ((isChanged  
				 || ((this.isNotBlank(component.get(oldFieldValue)) && !this.isNotBlank(component.get(newFieldValue))) || (!this.isNotBlank(component.get(oldFieldValue)) && this.isNotBlank(component.get(newFieldValue)))))
				&& editedFieldRequiresApproval[fieldName] != 'Core_MDF_Competitive_Elements__c' && editedFieldRequiresApproval[fieldName] != 'Core_MDF_Incentive_Opted_In_ind__c') {
				var res=true;
				var oldValue=component.get(oldFieldValue);
				if( component.get(newFieldValue)&&component.get(oldFieldValue)&&typeof component.get(newFieldValue) ==="string"&&typeof component.get(oldFieldValue) ==="string" && component.get(newFieldValue).trim()==component.get(oldFieldValue).trim()){
					res=false;
				}
				return res;
		}
		}
		
		
		
		 if(  (component.get(oldFieldValue) == undefined || component.get(oldFieldValue) == null || $A.util.isEmpty(component.get(oldFieldValue)))
		   && (component.get(newFieldValue) != undefined && component.get(newFieldValue) != null && !$A.util.isEmpty(component.get(newFieldValue)))
		   && editedFieldRequiresApproval[fieldName] != 'Core_MDF_Competitive_Elements__c' && editedFieldRequiresApproval[fieldName] != 'Core_MDF_Incentive_Opted_In_ind__c'){
			return true;   
		}
		
		
	}
	return false;
},
 //Fetch date in w.r.t to Local time zone
    getTodayDateLocalTime : function(){
        var timezone = $A.get("$Locale.timezone");          
        var today = new Date().toLocaleString("fr-CA", {timeZone: timezone}).slice(0,10);
        return today;
    },
 isIPAActivitywithApplicableFieldModified: function (component) {
        var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Editable_IPA");
        var IPAAccEditedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Editable_IPA_AccountBased");
        var IPAEditFieldAccPropBasedPlannedFuture= $A.get("$Label.c.Core_MDF_FieldEditable_IPA_AccBas_planned_Future_int");
        var IPAEditFieldAccPropBasedPlannedExt= $A.get("$Label.c.Core_MDF_FieldEditable_IPA_AccBas_planned_Ext");
        var IPAEditFieldAccBasedPlannedPastDated = $A.get("$Label.c.Core_MDF_FieldEditable_IPA_AccBas_planned_PastDated_int");
        var IPAEditFieldAccBasedPlannedPastDatedL2 = $A.get("$Label.c.Core_MDF_FieldEditable_IPA_AccBas_planned_PastDated_L2Approver");
        var IPAEditFieldAccBasedInProgress= $A.get("$Label.c.Core_MDF_FieldEditable_IPA_AccBas_inprogress");
        var spifModified = component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") ;
        var todaysDate = this.getTodayDateLocalTime();
        var isModified = false;
                              
        var metricsModified = component.get("v.newPFR.Core_MDF_Metrics_Modified_ind__c");
        if (((this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))&&(component.get("v.isPropBasedCampaign") == true))) 
            &&(this.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval.split(",")) || component.get("v.isSPIFSecModified"))) 
        {
            isModified = true;
            
        }
               else if(this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))
                 ){
                              
            if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
                //Approval triggering for Planned - future dated activities
                if((component.get("v.ipaAcctMgr")|| component.get("v.ipaApproverPer")) && component.get("v.oldPFR.Core_MDF_Start_Date__c") >= todaysDate && IPAEditFieldAccPropBasedPlannedFuture!= null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccPropBasedPlannedFuture.split(","))||metricsModified  ){
                    isModified = true;
                    
                }
                //Approval triggering for Planned - Past dated activities
                else if((component.get("v.ipaAcctMgr"))&& component.get("v.oldPFR.Core_MDF_Start_Date__c") < todaysDate && IPAEditFieldAccBasedPlannedPastDated!= null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccBasedPlannedPastDated.split(","))){
                    isModified = true;
                    
                }else if(component.get("v.externalper") && IPAEditFieldAccPropBasedPlannedExt != null && (this.fieldEligibleForApprovalModified(component, IPAEditFieldAccPropBasedPlannedExt.split(",")) ||component.get("v.isSPIFSecModified"))){
                    isModified = true;
                }
                    else if(component.get("v.ipaL2Approver") && IPAEditFieldAccBasedPlannedPastDatedL2 != null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccBasedPlannedPastDatedL2.split(","))){
                       isModified = true; 
                    }
                
            }
            else if((component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required') && ((IPAAccEditedFieldRequiresApproval!= null && this.fieldEligibleForApprovalModified(component, IPAAccEditedFieldRequiresApproval.split(","))) || component.get("v.isSPIFSecModified")||spifModified||metricsModified)) {
                isModified = true;
            }
          //Ramapriya - retrigger approval in In-Progress and In-Progress Revision required status          
           else if(component.get("v.ipaAcctMgr") &&  (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress' && (IPAEditFieldAccBasedInProgress!=null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccBasedInProgress.split(",")) || component.get("v.isSPIFSecModified")||spifModified||metricsModified))){
                isModified = true;
            }

           else if(component.get("v.ipaAcctMgr") &&  (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress Revision Required' && (IPAEditFieldAccBasedInProgress!=null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccBasedInProgress.split(",")) || component.get("v.isSPIFSecModified")||spifModified||metricsModified))){
                isModified = true;
            }
                    }
        //When file is uploaded on edit - to re-trigger the approval// Added by Ramapriya (WW05'2025)- TWC702-11335
        if (component.get("v.Uploadfinished")==true){
            isModified = true;
        }
            return isModified;
    },

//Method to trigger reapproval
setIPAAccountBasedActivityStatus: function (component) {
        if (this.isPlannedOrRevisionRequiredActivity(component) && this.isIPAActivitywithApplicableFieldModified(component)) {
            if(component.get("v.ipaAcctMgr") || component.get("v.ipaL2Approver") ){
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);//Retriggers approval if RR and planned actvitiy is edited by Acc Man
            }else{
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
	     }
	     component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
	     component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true);
	     }
	     else if(this.isPlannedOrRevisionRequiredActivity(component) &&(!(this.isIPAActivitywithApplicableFieldModified(component))))
	     {
            
            if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired")){
                
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired"));
            }
            else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")){
                
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_CCP_Planned_Status"));
            }
        }

        // Ramapriya - set status to In-Progress Pending Review when edited in In-Progress/In-Progress Revision Required status

        else if (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") =='In-Progress' && this.isIPAActivitywithApplicableFieldModified(component)){
             if(component.get("v.ipaAcctMgr")) {
                 component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
             }
             component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_InProgress_PendingReview"));
	     	 component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true);
             
             }
        else if (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") =='In-Progress Revision Required' && this.isIPAActivitywithApplicableFieldModified(component)){
             if(component.get("v.ipaAcctMgr")) {
                 component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
             }
              component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_InProgress_PendingReview"));
	     	  component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true);
             
             }
    }, 
	//Outcome Based changes - to show Event Popup when selected tactics is Event
    isTacticsEventPopUpVisible : function(component){
        if (component.get("v.PopupButtonValue") == false) {
            this.popUpHelper(component, "Event");
        }
    },
    //Outcome Based changes - to show govt question when selected tactics is Event
    isTacticsGovtEventQuesSecVisible : function(component){
        if (!component.get("v.renderGovtQuestion")) {
            this.showQuestion(component,false,true,false);
        }
    },
     //Outcome Based changes - to show ELC Popup when selected tactics is Event
    isTacticsELCPopUpVisible : function(component){
        if (component.get("v.ELCPopupButtonValue") == false && component.get("v.PopupButtonValue") == true) {
            this.popUpHelper(component, "ELC");
        }
    },
	showQuestion : function(component,showPrintQuestion,showGovtQuest,showTechExplorationQuest){
        //Method which enables as which section to be visible 
        component.set("v.renderPrintQuestion", showPrintQuestion);
        component.set("v.renderGovtQuestion", showGovtQuest);
        component.set("v.renderTechExplorationQuestSection",showTechExplorationQuest);
        
        //if(component.get("v.renderPrintQuestion") || component.get("v.renderGovtQuestion") || component.get("v.renderTechExplorationQuestSection")){
            component.set("v.goForSave", true);
        //}        
    },
    // Helper Called from Popup
    popUpHelper: function (component, popuptype) {
        if (popuptype == "Event") {
            component.set(
                "v.EventMessage",
                $A.get("$Label.c.Core_MDF_EventReminder1")
            );
            component.set(
                "v.AgreeButtonLabel",
                $A.get("$Label.c.Core_MDF_I_Understand")
            );
            component.set(
                "v.DisagreeButtonLabel",
                $A.get("$Label.c.Core_MDF_CancelOption")
            );
            component.set("v.PopupType", popuptype);
            component.set("v.ShowEventPopup", true);
            component.set("v.goForSave", true);
        }
        if (popuptype == "ELC") {
            if(component.get("v.SelCategory") != $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
                component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
            }else{
                component.set("v.EventMessage", $A.get("$Label.c.core_mdf_terms_tactics_ELC_popup"));
            }
            component.set(
                "v.AgreeButtonLabel",
                $A.get("$Label.c.Core_MDF_I_Understand")
            );
            component.set(
                "v.DisagreeButtonLabel",
                $A.get("$Label.c.Core_MDF_CancelOption")
            );
            component.set("v.PopupType", popuptype);
            component.set("v.ShowEventPopup", true);
            component.set("v.goForSave", true);
        }
    },
    saveHelperMethod: function (component, newPFR) {
        
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");  
        //var exchangeRateJSNumFormat = Number(component.get("v.newPFR.Core_MDF_Exchange_Rate_ptc__c")); 
            if(component.get("v.mode") == 'clone'){
                component.set("v.newPFR.Core_MDF_IsCloned_Ind__c", true);
            }
            //component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateJSNumFormat);
            if(component.get("v.mode") != 'edit')
               {
                 component.set("v.newPFR.Core_MDF_StartTime_dtm__c", component.get("v.activityCreationStartTime"));
            	}
            this.multiselectfieldvaluesStringConversion(component);
            if(component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false) {   
                
				component.set("v.isSaveDisable", true);
                component.set("v.isSaveandNewDisable", true);
                var newPFR= component.get("v.newPFR");
                var action = component.get("c.savenSendRecordId");
                action.setParams({
                    "pfr": newPFR,
                    "contentdocumentids": component.get("v.ContentDocumentIds"),
                    "budgetException": false,
                    "recType": component.get("v.recordtypeDeveloperName"),
                    "segmentAndProduct": component.get("v.segmentString"),
                    "BudId": component.get("v.selAvailableBudget"),
                    "isPropIndicator":component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"),
                    "mdfReimbursement":newPFR.Core_MDF_MDFReimbursement_Amt__c ?''+newPFR.Core_MDF_MDFReimbursement_Amt__c:'',
                    "tacticMetrics": this.isNotBlank(component.get("v.tacticMetricsValues")) ? component.get("v.tacticMetricsValues") : null,
                    "outcomeActivity": this.isNotBlank(component.get("v.outcomeActivityValues")) ? component.get("v.outcomeActivityValues") : null,
                });
                
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    
                    
                    if (state === "SUCCESS") {
                        
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: $A.get("$Label.c.Core_MDF_SuccessToastTitle"),
                            type: 'success',
                            message: newPFR.Title + ' ' + $A.get("$Label.c.Core_MDF_SuccessfullToastMessage")
                            
                        });
                        toastEvent.fire();
                        
                        
                        if (component.get("v.isSaveandNew")) {
                            component.set("v.checkSaveComplete", true);
                         
                        } 
                        
                            else {
                                
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": response.getReturnValue(),
                                    "slideDevName": "detail"
                                });
                                navEvt.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                
                                if (component.get("v.recordId") != null) {
                                
                                    setTimeout(function () {
                                        window.location.reload();
                                    }, 2000);
                                }
                                
                            }
                    } else {
                        // Disable Save button
                        component.set("v.isSaveDisable", false);
                        if(!component.get("v.auditorper") && !component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper"))	{
                            component.set("v.isSaveandNewDisable", false);
                        }
                        var err = action.getError();
                        var fieldErrors = JSON.stringify(err[0].fieldErrors);
                        var pageErrors = err[0].pageErrors; //array
                        var message = err[0].message;
                        var error;
                        if (message == null) {
                            var fieldErrorMessage = fieldErrors.split("message");
                            var fieldErrorSplitMessage = fieldErrorMessage[1];
                            if (pageErrors != null && pageErrors != undefined && pageErrors.length > 0) {
                                if(pageErrors[0].statusCode == 'FIELD_CUSTOM_VALIDATION_EXCEPTION'){
                                error = JSON.stringify(pageErrors[0].message);  
                                }
                                else{
                                    error = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"); 
                                }
                            } else if (fieldErrors.length > 0) {
                                error = fieldErrorSplitMessage.slice(3, -4);
                                
                            }
                        } else {
                            error = message;
                            if(error == 'Unable to read SObject'){
                                error = $A.get("$Label.c.Core_MDF_NoCampaign_Access_Error");
                            }
                        }
                        component.set("v.message", error);
                        component.set("v.messageType", 'error');
                        if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") ||
                            component.get("v.checkCloneAttribute")) {
                            document.querySelector('#pivot').scrollIntoView();
                        } else {
                            window.scrollTo(0, 0);
                        }
                        // Disable Save button
                        component.set("v.isSaveDisable", false);
                        if(!component.get("v.auditorper") && !component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper")){
                            component.set("v.isSaveandNewDisable", false);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        
    },

    multiselectfieldvaluesStringConversion: function(component){
        var newPFR = component.get ("v.newPFR");

        var multiSelectFields = [
        "Core_MDF_Tactics_nm__c",
        "Core_MDF_Country_nm__c",
        "Core_MDF_TargetAudience_nm__c",
        "Core_MDF_Brand_nm__c",
        "Core_MDF_Outcomes_nm__c",
        "Core_MDF_Initiative_nm__c",
        "Core_MDF_EcosystemPartner_nm__c",
        "Core_MDF_Technology_txt__c"
    ];

        multiSelectFields.forEach(function(field) {
        var val = newPFR[field];
        if (Array.isArray(val)) {
            newPFR[field] = val.join(';');
        }
    });
            
        component.set("v.newPFR", newPFR);
    },

    checkSPIFActSecVisible: function(component) {
        
        if( !$A.util.isEmpty(component.get("v.selectedTacticsOptions"))){
           if(this.checkSPIFTactics(component)){
                    component.set("v.isSPIFSecAvailable",true);
            }else{
                    component.set("v.isSPIFSecAvailable",false);
            }
         }
        
        this.handleSPIFDataVisibility(component);
    },

    handleSPIFDataVisibility: function (component){
        var hasAccBasPerSet = component.get("v.ipaAcctMgr");
        var frstatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var hasPerSet = component.get("v.ipaApproverPer");

        if((hasAccBasPerSet||hasPerSet) && frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")&&
           component.get("v.isUserCurrentIPAApprover") &&
		   ((component.get("v.newPFR.Core_MDF_Approval_Step_Completed__c") == 0 && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false))){
            if(component.get ("v.isSPIFSecAvailable") && ((this.checkSPIFTactics(component) && !component.get("v.oldPFR.Core_MDF_Tactics_nm__c").includes($A.get("$Label.c.Core_MDF_Spif_Tactics")) && component.get("v.selectedTacticsOptions").includes($A.get("$Label.c.Core_MDF_Spif_Tactics"))))){
                component.set("v.isSPIFSecReadOnly", false);
            }
            else if(component.get ("v.isSPIFSecAvailable") &&
                     (component.get("v.oldPFR.Core_MDF_Tactics_nm__c") == component.get("v.selectedTacticsOptions"))){
                component.set("v.isSPIFSecReadOnly", true);
            }
        }
    },

    setAccountFilter: function(component, recordtype){
    
    var IPA_NonTranslateLabel = $A.get("$Label.c.Core_MDF_IPA_Technical_program_name"); 
    
    var aFilter = ""; 
    
    if (recordtype == $A.get("$Label.c.Core_MDF_IPA_RecordType")) { 
        aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote; AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
            IPA_NonTranslateLabel + "@quote;";
    }
    
    component.set("v.additionalAccFilter", aFilter);    
},

clearDependentFieldSelections: function(component) {
    try {
        
        var multiSelectFields = [
            { attr: "selectedTargetAudienceOptions", pfrField: "Core_MDF_TargetAudience_nm__c" },
            { attr: "selectedBrandOptions", pfrField: "Core_MDF_Brand_nm__c" },
            { attr: "selectedInitiativeOptions", pfrField: "Core_MDF_Initiative_nm__c" },
            { attr: "selectedEcosystemPartnerOptions", pfrField: "Core_MDF_EcosystemPartner_nm__c" },
            { attr: "selectedTechnologyOptions", pfrField: "Core_MDF_Technology_txt__c" }
        ];
        
        multiSelectFields.forEach(function(field) {
            component.set("v." + field.attr, []);
            component.set("v.newPFR." + field.pfrField, "");
        });
        
        var singleSelectFields = [
            { attr: "SelPriority", pfrField: "Core_MDF_Priority_nm__c" },
            { attr: "SelPriority2", pfrField: "Core_MDF_Priority_2_nm__c" },
            { attr: "SelProductType", pfrField: "Core_MDF_ProductType__c" }
        ];
        
        singleSelectFields.forEach(function(field) {
            component.set("v." + field.attr, "");
            component.set("v.newPFR." + field.pfrField, "");
        });
        
        
        component.set("v.showPriority1Error", false);
        component.set("v.showPriority2Error", false);
        component.set("v.priority1Error", "");
        component.set("v.priority2Error", "");
        
    } catch (error) {
        
    }
},

    decodeHtmlEntities: function(str) {
        if (!str || typeof str !== 'string') return str;
        return str.replace(/&amp;/g, '&');
                 
    },
    
    sanitizeResults : function(result){
        if(result != null && result != undefined && result != {} && Object.keys(result).length > 0){
            return result;
        }
        else{
            return null;
        }
    }


})