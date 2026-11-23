({
    initializeBasicAttributes: function(component) {
        // Initialize default values
        component.set("v.SelCategory", $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.SelActivityType", $A.get("$Label.c.Core_MDF_Outcome_Based_CatType"));
        component.set("v.message", "");
        component.set("v.messageType", "");
        component.set("v.maxIntelInvestment",null);
        // Set default reimbursement rate to 100% for new activities
        var mode = component.get("v.mode");
        if(mode === 'clone' || mode ==='create' || mode ==='') {
    component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));        
}
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
        // Set default reimbursement rate to 100% for new activities and clones
        if(mode === 'clone' || mode === 'create' || mode ==='') {
            
            component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
            component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
            component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
       
        }
       
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
                //Akash
                var child = component.find("activityAccNode");
                if (child && component.get("v.pfrFieldEditablity.Core_MDF_Maximum_Intel_Investment_amt__c")) {
                    child.handleEdit(component.get("v.pfrFieldEditablity.Core_MDF_Maximum_Intel_Investment_amt__c"));
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
    // Anjali changes - Add Measurement Approach field to the list of fields to fetch picklist values from server
    if (pickListFields.indexOf("Core_MDF_Measurement_Approach_nm__c") === -1) {
        pickListFields.push("Core_MDF_Measurement_Approach_nm__c");
    }
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
            // Anjali changes - Set Measurement Approach initial options during parent picklist loading
            if(fldname == "Core_MDF_Measurement_Approach_nm__c"){
                component.set("v.measurementApproachOptions", ParPickField);
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
            // Anjali changes - Handle Measurement Approach dependent picklist - filters based on Focus Area
            case "Core_MDF_Measurement_Approach_nm__c":
               component.set("v.measurementApproachPicklistValues", childPickField);
               this.fetchMultiMeasurementApproach(component);
               break;
            
        }
    },
    
    
    fetchBudgetInfo: function(component){
        component.set("v.showSpinner", true);
        //component.set("v.selAvailableBudget", '');
        var availableBudget = [];
        var action = component.get("c.fetchBudgetInfo");
        var ultimateAccId = component.get("v.selectedAccount.Core_MDF_CoMarketing_Ultimate_Account__c");
        var mode = component.get("v.mode"); // create, edit, clone
        var currentBudgetIdVal = null;

        if(mode && mode.toLowerCase() === 'edit') {
            var oldPfrRef = component.get("v.oldPFR");
            var newPfrRef = component.get("v.newPFR");

            if (oldPfrRef && oldPfrRef.BudgetId) {
                currentBudgetIdVal = oldPfrRef.BudgetId ;
            } 
            else if (newPfrRef && newPfrRef.BudgetId) {
                currentBudgetIdVal = newPfrRef.BudgetId;
            } 
            else if (component.get("v.selAvailableBudget")) {
                currentBudgetIdVal = component.get("v.selAvailableBudget");
            }
        }
        
        action.setParams({
            accountId: ultimateAccId,
            startDate: component.get("v.newPFR.Core_MDF_Start_Date__c"),
            endDate: component.get("v.newPFR.Core_MDF_End_Date__c"),
            budgetType: 'Account Plan',
            isIPAAccBased: true,
            currentBudgetId: currentBudgetIdVal
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
            //Show only Account Plan as Budget Type  
            for (var key in result) {
                    if (result[key] && key.toLowerCase() === 'account plan') {
                        budgetTypeOptionList.push({ label: result[key], value: key});
            }
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
            if (mode === '' && budgetTypeOptionList.length > 1) {
                var selectedValue = budgetTypeOptionList[1].value;
                var selectedLabel = budgetTypeOptionList[1].label;
                setTimeout($A.getCallback(function() {
                    component.set('v.selBudgetType', selectedValue);
                    component.set('v.newPFR.Core_MDF_Budget_Type_nm__c', selectedValue);
                }), 50);
            }
        } else {
            console.error('[Budget Type] Apex call failed with state: ' + response.getState());
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
             var mode = component.get("v.mode");
    if (mode === 'create' || mode === 'clone' || mode === '') {
        component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
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

    resetPartnerContactValidation: function(component) {
        component.set("v.showPartnerContactError", false);
        component.set("v.partnerContactErrorMsg", "");
    },

   /* getPartnerContactDomainErrorMessage: function(component) {
        return $A.get("$Label.c.Core_MDF_No_ApprovedDomain_Error");
    },

    getIntelPartnerContactDomainErrorMessage: function() {
        return $A.get("$Label.c.Core_MDF_IntelDomainError");
    },

    isUnsupportedPartnerContactDomain: function(value) {
        if (!value) {
            return false;
        }

        var normalizedValue = String(value).trim().toLowerCase().replace(/^@/, "");
        var domainValue = normalizedValue.indexOf("@") !== -1 ? normalizedValue.split("@").pop() : normalizedValue;
        domainValue = domainValue.replace(/^\*\./, "");

        return domainValue === "intel.com" || domainValue.endsWith(".intel.com");
    },

    getPartnerContactAccountId: function(component) {
        var selectedAccount = component.get("v.selectedAccount");
        if (selectedAccount && selectedAccount.Id) {
            return selectedAccount.Id;
        }

        return component.get("v.newPFR.ChannelPartnerId");
    },

    loadPartnerContactDomains: function(component, callback) {
        var accountId = this.getPartnerContactAccountId(component);

        if (!accountId) {
            component.set("v.allowedPartnerContactDomains", []);
            component.set("v.partnerContactDomainsLoaded", false);
            this.resetPartnerContactValidation(component);
            if (callback) {
                callback();
            }
            return;
        }

        var action = component.get("c.getDomainsForAccount");
        action.setParams({
            accountId: accountId
        });

        var helper = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var domainMappings = response.getReturnValue() || [];
                var allowedValues = [];

                for (var index = 0; index < domainMappings.length; index++) {
                    var mappingName = domainMappings[index] && domainMappings[index].Name;
                    if (mappingName) {
                        mappingName.split(/[;\n\r,]+/).forEach(function(value) {
                            var normalizedValue = String(value).trim().toLowerCase();
                            if (normalizedValue && !helper.isUnsupportedPartnerContactDomain(normalizedValue) && allowedValues.indexOf(normalizedValue) === -1) {
                                allowedValues.push(normalizedValue);
                            }
                        });
                    }
                }

                component.set("v.allowedPartnerContactDomains", allowedValues);
                component.set("v.partnerContactDomainsLoaded", true);
                this.resetPartnerContactValidation(component);

                if (callback) {
                    callback();
                }
            } else {
                component.set("v.allowedPartnerContactDomains", []);
                component.set("v.partnerContactDomainsLoaded", true);
                if (callback) {
                    callback();
                } else if (component.get("v.newPFR.Core_MDF_Partner_Contact_txt__c")) {
                    this.validatePartnerContactEmails(component);
                }
            }
        });

        $A.enqueueAction(action);
    },

    isAllowedPartnerContactEmail: function(email, allowedValues) {
        var normalizedEmail = String(email).trim().toLowerCase();
        var emailParts = normalizedEmail.split("@");

        if (emailParts.length !== 2 || !emailParts[0] || !emailParts[1]) {
            return false;
        }

        var emailDomain = emailParts[1];

        if (this.isUnsupportedPartnerContactDomain(emailDomain)) {
            return false;
        }

        return allowedValues.some(function(allowedValue) {
            if (!allowedValue) {
                return false;
            }

            if (allowedValue === normalizedEmail) {
                return true;
            }

            if (allowedValue.indexOf("@") !== -1) {
                return false;
            }

            var allowedDomain = allowedValue.replace(/^@/, "");
            if (allowedDomain.indexOf("*.") === 0) {
                return emailDomain === allowedDomain.substring(2) || emailDomain.endsWith(allowedDomain.substring(1));
            }

            return emailDomain === allowedDomain;
        });
    },*/

    validatePartnerContactEmails: function(component) {
        var partnerContactValue = component.get("v.newPFR.Core_MDF_Partner_Contact_txt__c");

        if (!partnerContactValue || !String(partnerContactValue).trim()) {
            this.resetPartnerContactValidation(component);
            return true;
        }

        var emailString = String(partnerContactValue);

        // Reject commas and display the existing invalid email error message
        if (emailString.indexOf(',') !== -1) {
            component.set("v.showPartnerContactError", true);
            component.set("v.partnerContactErrorMsg",$A.get("$Label.c.Core_MDF_InvalidEmailError"));
            return false;
        }
        
        // Allow semicolons and newlines as separators
        var emailValues = emailString.split(/[;\n\r]+/).map(function(value) {
            return value.trim();
        }).filter(function(value) {
            return value !== "";
        });
        
        var emailPattern = /^[^\s@]+@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$/;
        for (var index = 0; index < emailValues.length; index++) {
            if (!emailPattern.test(emailValues[index])) {
                component.set("v.showPartnerContactError", true);
                component.set("v.partnerContactErrorMsg", $A.get("$Label.c.Core_MDF_InvalidEmailError") || "Invalid email address. Please enter a valid email address.");
                return false;
            }
        }

        /*Ramapriya - Commented as part of TWC702-16422
        for (var unsupportedIndex = 0; unsupportedIndex < emailValues.length; unsupportedIndex++) {
            if (this.isUnsupportedPartnerContactDomain(emailValues[unsupportedIndex])) {
                component.set("v.showPartnerContactError", true);
                component.set("v.partnerContactErrorMsg", this.getIntelPartnerContactDomainErrorMessage());
                return false;
            }
        }

        var accountId = this.getPartnerContactAccountId(component);
        if (!accountId) {
            component.set("v.showPartnerContactError", true);
            component.set("v.partnerContactErrorMsg", $A.get("$Label.c.Core_MDF_No_ApprovedDomain_Error"));
            return false;
        }

        if (!component.get("v.partnerContactDomainsLoaded")) {
            component.set("v.showPartnerContactError", true);
            component.set("v.partnerContactErrorMsg", this.getPartnerContactDomainErrorMessage(component));
            return false;
        }

        var allowedValues = component.get("v.allowedPartnerContactDomains") || [];

        if (allowedValues.length === 0) {
            component.set("v.showPartnerContactError", true);
            component.set("v.partnerContactErrorMsg",this.getPartnerContactDomainErrorMessage(component));
            return false;
        }
        for (var allowedIndex = 0; allowedIndex < emailValues.length; allowedIndex++) {
            if (!this.isAllowedPartnerContactEmail(emailValues[allowedIndex], allowedValues)) {
                component.set("v.showPartnerContactError", true);
                component.set("v.partnerContactErrorMsg", ($A.get("$Label.c.Core_MDF_UnsupportedDomain_Error") || '') + ' ' + allowedValues.join(", "));
                return false;
            }
        }*/

        this.resetPartnerContactValidation(component);
        return true;
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
    
    // Gayathri-Get current value for edit mode support
    var currentValue = component.get("v.newPFR.Core_MDF_Brand_nm__c");
    var mode = component.get("v.mode");
    
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
    
    // Gayathri-Add old value support for edit mode - multi-select brand
    if(mode === 'edit' && currentValue) {
        var currentValues = [];
        
        // Handle multi-select values (semicolon-separated string)
        if(typeof currentValue === 'string' && currentValue.includes(';')) {
            currentValues = currentValue.split(';').map(function(val) {
                return val.trim();
            });
        } else if(currentValue) {
            currentValues = [currentValue];
        }
        
        // Add any missing values to the options
        for(var valueIndex = 0; valueIndex < currentValues.length; valueIndex++) {
            var valueToCheck = currentValues[valueIndex];
            if(valueToCheck && !processedOptions.some(opt => opt.value === valueToCheck)) {
                var currentLabel = valueToCheck;
                if(localizedMap && localizedMap[valueToCheck]) {
                    currentLabel = localizedMap[valueToCheck];
                }
                
                // Add legacy value to the options
                processedOptions.push({
                    label: currentLabel,
                    value: valueToCheck
                });
            }
        }
    }
    
    component.set("v.AllBrandOptions", processedOptions);
},

updateInitiativePickVals: function(component) {
    var initiativeOptions = component.get("v.MultiInitiativeValues") ;
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    // Get current value for edit mode support
    var currentValue = component.get("v.newPFR.Core_MDF_Initiative_nm__c");
    var mode = component.get("v.mode");
    
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
    
    // Add old value support for edit mode - multi-select initiative
    // This ensures previously selected values still appear in the selected side even if field dependency has removed them from available options
    if(mode === 'edit' && currentValue) {
        var currentValues = [];
        
        // Handle multi-select values
        if(typeof currentValue === 'string' && currentValue.includes(';')) {
            currentValues = currentValue.split(';').map(function(val) {
                return val.trim();
            });
        } else if(currentValue) {
            currentValues = [currentValue.trim()];
        }
        
        // Add any missing values to the options so they show on the selected side
        for(var valueIndex = 0; valueIndex < currentValues.length; valueIndex++) {
            var valueToCheck = currentValues[valueIndex];
            if(valueToCheck && !processedOptions.some(function(opt) { 
                return opt.value === valueToCheck; 
            })) {
                var currentLabel = valueToCheck;
                if(localizedMap && localizedMap[valueToCheck]) {
                    currentLabel = localizedMap[valueToCheck].replace("&amp;", "&");
                }
                
                // Add legacy/removed value to the options so it remains visible
                processedOptions.push({
                    label: currentLabel,
                    value: valueToCheck
                });
            }
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
    // Gayathri - for old PRODUCT TYPE
    var currentValue = component.get("v.newPFR.Core_MDF_ProductType__c");
    var mode = component.get("v.mode");

    /*processedOptions.push({
    label: "---None---",
    value: ""
        });*/
    
    if(productTypeOptions && productTypeOptions.length > 0) {
        for(var i = 0; i < productTypeOptions.length; i++) {
            var option = productTypeOptions[i];
            var label = this.decodeHtmlEntities(option.label);
            var value = this.decodeHtmlEntities(option.value);
            
            if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);
            }
            
            processedOptions.push({
                label: label,
                value: value
            });
        }
    }
    
    // Gayathri - ADD OLD VALUE SUPPORT FOR EDIT MODE - MULTI-SELECT PRODUCT TYPE
    if(mode === 'edit' && currentValue) {
        var currentValues = [];
        
        // Handle multi-select values (semicolon-separated string)
        if(typeof currentValue === 'string' && currentValue.includes(';')) {
            currentValues = currentValue.split(';').map(function(val) {
                return val.trim();
            });
        } else if(currentValue) {
            currentValues = [currentValue];
        }
        
        // Add any missing values to the options
        for(var valueIndex = 0; valueIndex < currentValues.length; valueIndex++) {
            var valueToCheck = currentValues[valueIndex];
            if(valueToCheck && !processedOptions.some(opt => opt.value === valueToCheck)) {
                var currentLabel = valueToCheck;
                if(localizedMap && localizedMap[valueToCheck]) {
                    currentLabel = this.decodeHtmlEntities(localizedMap[valueToCheck]);
                }
                
                // Add legacy value to the options
                processedOptions.push({
                    label: currentLabel,
                    value: valueToCheck
                });
            }
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
            var picklistValue = options[i].value;
            var optionValue = (picklistValue != null && picklistValue.includes('&amp;')) ? picklistValue.replace("&amp;", "&") : picklistValue;
            
            if(localizedMap && localizedMap[option.value]) {
                label = localizedMap[option.value];
            }
            
            localizedOptions.push({
                label: label,
                value: optionValue,
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
            
            /*if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);
            }*/
            if(localizedMap) {
                var translatedLabel = localizedMap[option.value] || localizedMap[value];
                if(translatedLabel) {
                    label = this.decodeHtmlEntities(translatedLabel);
                }
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
        
        //Gayathri- Get current value for edit mode support
        var currentValue = component.get("v.newPFR.Core_MDF_Technology_txt__c");
        var mode = component.get("v.mode");
        
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
        
        // Anjali changes - Add old value support for edit/clone mode - multi-select technology (allows clone to show previously selected values)
        if((mode === 'edit' || mode === 'clone') && currentValue) {
            var currentValues = [];
            
            // Handle multi-select values (semicolon-separated string)
            if(typeof currentValue === 'string' && currentValue.includes(';')) {
                currentValues = currentValue.split(';').map(function(val) {
                    return val.trim();
                });
            } else if(currentValue) {
                currentValues = [currentValue];
            }
            
            // Add any missing values to the options
            for(var valueIndex = 0; valueIndex < currentValues.length; valueIndex++) {
                var valueToCheck = currentValues[valueIndex];
                if(valueToCheck && !processedOptions.some(opt => opt.value === valueToCheck)) {
                    var currentLabel = valueToCheck;
                    if(localizedMap && localizedMap[valueToCheck]) {
                        currentLabel = localizedMap[valueToCheck].replace("&amp;", "&");
                    }
                    
                    // Add legacy value to the options
                    processedOptions.push({
                        label: currentLabel,
                        value: valueToCheck
                    });
                }
            }
        }
        
        component.set("v.AllTechnologyOptions", processedOptions);
    },

// Anjali changes - Process and display filtered Measurement Approach picklist options with support for edit/clone mode value display
updateMeasurementApproachPickVals: function(component) {
    var measurementApproachOptions = component.get("v.measurementApproachValues");
    var localizedMap = component.get("v.apitoLabelConvert");
    var processedOptions = [];
    
    // Anjali changes - Get current value for edit mode support
    var currentValue = component.get("v.newPFR.Core_MDF_Measurement_Approach_nm__c");
    var mode = component.get("v.mode");
    
    if(measurementApproachOptions && measurementApproachOptions.length > 0) {
        for (var i = 0; i < measurementApproachOptions.length; i++) {
            var option = measurementApproachOptions[i];
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
    
    // Anjali changes - Add old value support for edit/clone mode - multi-select measurement approach
    if((mode === 'edit' || mode === 'clone') && currentValue) {
        var currentValues = [];
        
        // Handle multi-select values (semicolon-separated string)
        if(typeof currentValue === 'string' && currentValue.includes(';')) {
            currentValues = currentValue.split(';').map(function(val) {
                return val.trim();
            });
        } else if(currentValue) {
            currentValues = [currentValue];
        }
        
        // Anjali changes - Add any missing values to the options for multi-select backward compatibility
        for(var valueIndex = 0; valueIndex < currentValues.length; valueIndex++) {
            var valueToCheck = currentValues[valueIndex];
            if(valueToCheck && !processedOptions.some(opt => opt.value === valueToCheck)) {
                var currentLabel = valueToCheck;
                if(localizedMap && localizedMap[valueToCheck]) {
                    currentLabel = localizedMap[valueToCheck].replace("&amp;", "&");
                }
                
                // Add legacy value to the options
                processedOptions.push({
                    label: currentLabel,
                    value: valueToCheck
                });
            }
        }
    }
    
    component.set("v.measurementApproachOptions", processedOptions);
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

// Anjali changes - Fetch and filter Measurement Approach values based on selected Focus Area (dependent picklist logic)
fetchMultiMeasurementApproach: function (component) {
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    var childValuesReturn = [];
    
    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
        var selectedFocusArea = component.get("v.selectedFocusArea");
        var measurementApproachPicklistValues = component.get("v.measurementApproachPicklistValues");
        
        // Filter Measurement Approach values based on selected Focus Area
        if(selectedFocusArea && measurementApproachPicklistValues) {
            childValuesReturn = this.setChildPicklistValues(component, selectedFocusArea, measurementApproachPicklistValues);
        }
    }
    
    component.set("v.measurementApproachValues", childValuesReturn);
    this.updateMeasurementApproachPickVals(component);
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
            /*if(localizedMap && localizedMap[option.value]) {
                label = this.decodeHtmlEntities(localizedMap[option.value]);  
            }*/
            if(localizedMap) {
                var translatedLabel = localizedMap[option.value] || localizedMap[value];
                if(translatedLabel) {
                    label = this.decodeHtmlEntities(translatedLabel);
                }
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
    var helper = this;
    
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
                
                // Immediately blank Partner Contact for clone right after newPFR is set
                if (component.get("v.checkCloneAttribute")) {
                    component.set("v.newPFR.Core_MDF_Partner_Contact_txt__c", "");
                }
                
                // Set record type information
                if (result.RecordType) {
                    component.set("v.recordtypeName", result.RecordType.Name);
                    component.set("v.recordtype", result.RecordTypeId);
                    component.set("v.recordtypeDeveloperName", result.RecordType.DeveloperName);
                }
                
                // Set selected account if available
                if (result.ChannelPartner) {
                    component.set("v.selectedAccount", result.ChannelPartner);
                   // this.loadPartnerContactDomains(component);
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
                     
                    // Anjali changes - Re-fetch dependent picklists when Focus Area is loaded (for clone/edit mode) to filter values correctly
                    if(component.get("v.measurementApproachPicklistValues")) {
                        this.fetchMultiMeasurementApproach(component);
                    }
                    if(component.get("v.MultiBrandTypes")) {
                        this.fetchMultiBrandType(component);
                    }
                    if(component.get("v.audiencePicklistValues")) {
                        this.fetchMultiTargetAudience(component);
                    }
                    if(component.get("v.initiativePicklistValues")) {
                        this.fetchMultiInitiative(component);
                    }
                    if(component.get("v.ProductTypes")) {
                        this.fetchProdType(component);
                    }
                    if(component.get("v.technologies")) {
                        this.fetchTechnologies(component);
                    }
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
                //indu RR Banner
                if(component.get("v.mode") === 'edit') {
                    this.checkRRBanner(component);
                }
                //Gayathri-Added as part of Account Manager edit defect
                if(mode == 'edit'){
                    var ipaL2Approver = component.get("v.ipaL2Approver");
                    var status = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
                    if(ipaL2Approver && status == 'Pending Review'){
                        // For L2 approvers, check IUPGM first, then call dependent methods in callback
                        this.isRecordApproverWithCallback(component);
                    } else {
                        // For non-L2 scenarios, call methods normally
                        this.getFieldEditabilityMapping(component);
                    }
                } 
                //Gayathri-Added as part of Account Manager edit defect
                //Enhanced edit validation - blocking users when activity is not in their queue
                if(component.get("v.mode") == 'edit'){
    if((((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") ||
    component.get("v.newPFR.Core_MDF_Program__c") == ($A.get("$Label.c.Core_MDF_IPA_Program_Name"))) &&
    component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false) && 
        !helper.isCurrentUsrIsApprover(component) && 
        (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' || 
        component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Approval' ||
        component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress Pending Review')))
    {
                        // NOTE: This check will be handled in the L2 callback for L2 approvers
                        if(!ipaL2Approver || status != 'Pending Review') {
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

// Gayathri - New method to handle L2 approver IUPGM check with proper callback sequencing
isRecordApproverWithCallback: function(component) {
    if(component.get("v.newPFR") != null && component.get("v.newPFR") != undefined) {
        var userID = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userID);
        var action = component.get("c.checkCurrentUserIsApprover");
        
        action.setParams({
            "obj": component.get("v.newPFR"),
            "userId": component.get("v.userId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == true) {
                    // User has IUPGM record with correct classification for current stage
                    component.set("v.hasIUPGMRecord", true);
                    component.set("v.isUserCurrentIPAApprover", true);
                    
                    // Now call methods that depend on these flags
                    this.getFieldEditabilityMapping(component);
                    
                } else {
                    // User doesn't have IUPGM record OR has wrong classification for current stage
                    component.set("v.hasIUPGMRecord", false);
                    component.set("v.isUserCurrentIPAApprover", false);
                    // Show error and redirect for edit mode
                    if(component.get("v.mode") == 'edit') {
                        var alertMsg = $A.get("$Label.c.Core_MDF_CloneAccessError");
                        this.displaySuccessErrorMsg(alertMsg, "Error!", "error", 'dismissible');
                        
                        var sObjectEvent = $A.get("e.force:navigateToSObject");
                        sObjectEvent.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "detail"
                        });
                        sObjectEvent.fire();
                    }
                }
            } else {
                // Error in Apex call - treat as no access
                component.set("v.hasIUPGMRecord", false);
                component.set("v.isUserCurrentIPAApprover", false);
                if(component.get("v.mode") == 'edit') {
                    var alertMsg = $A.get("$Label.c.Core_MDF_CloneAccessError");
                    this.displaySuccessErrorMsg(alertMsg, "Error!", "error", 'dismissible');
                    
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                }
            }
            
            // Hide spinner after L2 check is complete
            component.set("v.showSpinner", false);
        });
        
        $A.enqueueAction(action);
    }
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
    
    // Anjali changes - Set Measurement Approach values for edit/clone mode and manage conditional field visibility
    if (result.Core_MDF_Measurement_Approach_nm__c) {
        var measurementApproachValues = result.Core_MDF_Measurement_Approach_nm__c.split(';');
        component.set("v.selectedMeasurementApproachOptions", measurementApproachValues);
        
        // Anjali changes - Check if "Other (Specify)" is selected to show/hide the Other Measurement Approach text field
        var showOtherField = result.Core_MDF_Measurement_Approach_nm__c.includes('Other (Specify)');
        component.set("v.showOtherMeasurementApproachField", showOtherField);
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
    // Gayathri-ADD PRODUCT TYPE VALUES - NEW
    if (result.Core_MDF_ProductType__c) {
        var productTypeValues = result.Core_MDF_ProductType__c.split(';').map(function(val) {
            return val.trim();
        });
        component.set("v.selectedProductTypeOptions", productTypeValues);
    }
},

setEssentialFields: function(component, result) {
    // Set budget amount
    if (result.Core_MDF_Budget_Amount_Local_amt__c) {
        component.set("v.BudgetLocal", result.Core_MDF_Budget_Amount_Local_amt__c);
    }
    
    // Set reimbursement rate
   /* if (result.Core_MDF_Reimbursement_Rate_pct__c) {
        component.set("v.SelReimbursementRate", result.Core_MDF_Reimbursement_Rate_pct__c);
    }*/
    // Set reimbursement rate - always 100% for edit mode
   // Set reimbursement rate
var mode = component.get("v.mode");
if (mode === 'create' || mode === 'clone' || mode ==='') {
    // For new activities, set default 100%
    component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
} else if (mode === 'edit') {
    // For edit mode, preserve existing reimbursement rate
    if (result.Core_MDF_Reimbursement_Rate__c !== null && result.Core_MDF_Reimbursement_Rate__c !== undefined) {
        component.set("v.SelReimbursementRate", result.Core_MDF_Reimbursement_Rate__c);
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", result.Core_MDF_Reimbursement_Rate__c);
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", result.Core_MDF_Reimbursement_Rate__c);
    }
    // If text field exists, use that for display
    if (result.Core_MDF_Reimbursement_Rate_txt__c) {
        component.set("v.SelReimbursementRate", result.Core_MDF_Reimbursement_Rate_txt__c);
    }
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
    
    // Set product type - Gayathri UPDATED FOR MULTI-SELECT
    if (result.Core_MDF_ProductType__c) {
        // For multi-select, convert semicolon-separated string to array
        var productTypeValues = result.Core_MDF_ProductType__c.split(';').map(function(val) {
            return val.trim();
        });
        component.set("v.selectedProductTypeOptions", productTypeValues);
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
     // Set reimbursement rate to 100% for cloned activities
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
    component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
    
    // Clear other fields that shouldn't be cloned
    component.set("v.newPFR.Core_MDF_Attribution_Variance_Pos_txt__c", null);
    component.set("v.newPFR.Core_MDF_Attribution_Variance_Neg_txt__c", null);
    component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", null);
    component.set("v.newPFR.Core_MDF_Attribution_Requirements_txt__c", null);
    component.set("v.newPFR.Core_MDF_Internal_Tracking_txt__c", null);
    component.set("v.newPFR.Core_MDF_Metrics_txt__c", null);
    //Skip PCT Approval
    component.set("v.newPFR.Core_MDF_Skip_PCT_Approval_ind__c", false);
    // Clear Partner Contact — should not be copied from source record on clone
    component.set("v.newPFR.Core_MDF_Partner_Contact_txt__c", "");
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
	 var mode = component.get("v.mode");
    
    // For create or clone mode, ALWAYS set to 100% - don't calculate
    if (mode === 'create' || mode === 'clone' || mode ==='') {
        component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
        
        if(spifCheck){
            this.getActivityAmount(component);
        }
        return; // Exit immediately - don't do any calculations
    }
    
    // For edit mode, preserve existing value - don't recalculate
    if (mode === 'edit') {
        if(spifCheck){
            this.getActivityAmount(component);
        }
        return; // Exit immediately - don't recalculate
    }
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
		
		//Gayathri-Added as part of Account Manager edit defect,For L2 Approvers, use the flag set by isRecordApprover
         if(ipaL2Approver) {
            var currentStage = component.get("v.newPFR.Core_MDF_Approval_Stage__c");
            var isUserCurrentIPAApprover = component.get("v.isUserCurrentIPAApprover");
            if((currentStage == 'L2 Regional Marketing' || currentStage == 'L2 Regional Sales') && isUserCurrentIPAApprover) {
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
        //Akash - changes
        var outcomeModified = component.get("v.newPFR.Core_MDF_Node_Acc_Map_Modified_ind__c");
        if (((this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))&&(component.get("v.isPropBasedCampaign") == true))) 
            &&(this.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval.split(",")) || component.get("v.isSPIFSecModified"))) 
        {
            isModified = true;
            
        }
               else if(this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))
                 ){
                              
            if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
                //Approval triggering for Planned - future dated activities
                if((component.get("v.ipaAcctMgr")|| component.get("v.ipaApproverPer")) && component.get("v.oldPFR.Core_MDF_Start_Date__c") >= todaysDate && IPAEditFieldAccPropBasedPlannedFuture!= null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccPropBasedPlannedFuture.split(","))||metricsModified || outcomeModified ){
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
            else if((component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required') && ((IPAAccEditedFieldRequiresApproval!= null && this.fieldEligibleForApprovalModified(component, IPAAccEditedFieldRequiresApproval.split(","))) || component.get("v.isSPIFSecModified")||spifModified||metricsModified || outcomeModified)) {
                isModified = true;
            }
          //Ramapriya - retrigger approval in In-Progress and In-Progress Revision required status          
           else if(component.get("v.ipaAcctMgr") &&  (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress' && (IPAEditFieldAccBasedInProgress!=null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccBasedInProgress.split(",")) || component.get("v.isSPIFSecModified")||spifModified||metricsModified || outcomeModified))){
                isModified = true;
            }

           else if(component.get("v.ipaAcctMgr") &&  (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'In-Progress Revision Required' && (IPAEditFieldAccBasedInProgress!=null && this.fieldEligibleForApprovalModified(component, IPAEditFieldAccBasedInProgress.split(",")) || component.get("v.isSPIFSecModified")||spifModified||metricsModified || outcomeModified))){
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
        	// FORCE 100% for create/clone before saving
    var mode = component.get("v.mode");
    if (mode === 'create' || mode === 'clone' || mode ==='') {
        component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", parseInt($A.get("$Label.c.Core_MDF_ReimburesementNum")));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", $A.get("$Label.c.Core_MDF_ReimburementVal"));
    }
        	 // Fix reimbursement rate data type before saving
                var reimbursementRate = component.get("v.SelReimbursementRate");
                if (reimbursementRate && typeof reimbursementRate === $A.get("$Label.c.Core_MDF_ReimbursementRateString")) {
                    var numericValue = parseFloat(reimbursementRate.replace('%', ''));
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate__c", numericValue);
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
                    "outcomeAccountNode": this.isNotBlank(component.get("v.ActivityNodeAccValues")) ? component.get("v.ActivityNodeAccValues") : null
                });
                
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    
                    
                    if (state === "SUCCESS") {
                        
                        // Reimbursement rate display 
                        if (component.get("v.mode") === 'create' || component.get("v.mode") === 'clone' || component.get("v.mode") === '' ) {
                            component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_ReimburementVal"));
                        }
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
                                
                               /* var navEvt = $A.get("e.force:navigateToSObject");
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
                                }*/
                                var navService = component.find("navService");
                                var communityUrl = component.get("v.externalper");
                                var recordId = response.getReturnValue();
                                var communityBaseUrl = $A.get("$Label.c.Core_MDF_PFRCommunityLink");
                                
                                // Finalize and persist AI tracking records if they exist
                                // Finalize and persist AI tracking records if they exist
                                var aiTrackingEntries = component.get("v.aiTrackingEntries");
                                
                                if (aiTrackingEntries && aiTrackingEntries.length > 0) {
                                    var finalizedEntries = this.finalizeAiTrackingEntries(component);
                                    if (finalizedEntries && finalizedEntries.length > 0) {
                                        this.persistAiTrackingRecords(component, recordId, finalizedEntries);
                                    } else {
                                    }
                                } else {
                                }


                                var pageReference;
                                
                                if (communityUrl) {
                                    
                                    pageReference = {
                                        type: 'comm__namedPage',
                                        attributes: {
                                            name: 'Outcome_based_Campaign_Details__c'
                                        },
                                        state: {
                                            c__recordId: recordId
                                        }
                                    };
                                } else {
                                    
                                    pageReference = {
                                        type: 'standard__navItemPage',
                                        attributes: {
                                            apiName: 'Core_MDF_Outcome_Based_Campaign_Detail'
                                        },
                                        state: {
                                            recordId: recordId
                                        }
                                    };
                                }
                                
                                
                                try {
                                    navService.navigate(pageReference, true);
                                    
                                } catch (e) {
                                    var url = communityUrl
                                    ? communityBaseUrl + 's/outcome-based-campaign-details?recordId=' + recordId
                                    : '/lightning/n/Core_MDF_Outcome_Based_Campaign_Detail?c__recordId=' + recordId;
                                    window.location.href = url;
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
    getFilteredPicklistValues: function(component) {
    var picklistValues = {};
    
    try {
        // Focus Area
        var focusAreaOptions = component.get("v.focusAreaDependent") || [];
        picklistValues.focusArea = focusAreaOptions.map(function(option) {
            return option.value;
        });
        
        // Priority
        var priorityOptions = component.get("v.priorityDependent") || [];
        picklistValues.priority = priorityOptions.map(function(option) {
            return option.value;
        }).filter(function(value) {
            return value !== ""; // Remove empty values
        });
        
        // Country
        var countryOptions = component.get("v.CountryDependants") || [];
        picklistValues.country = countryOptions.map(function(option) {
            return option.value;
        });
        
        // Target Audience
        var audienceOptions = component.get("v.MultiTargetAudienceValues") || [];
        picklistValues.targetAudience = audienceOptions.map(function(option) {
            return option.value;
        });
        
        // Brands
        var brandOptions = component.get("v.MultiBrandValues") || [];
        picklistValues.brands = brandOptions.map(function(option) {
            return option.value;
        });
        
        // Technologies
        var technologyOptions = component.get("v.technologiesDependant") || [];
        picklistValues.technologies = technologyOptions.map(function(option) {
            return option.value;
        });
        
        // Initiatives
        var initiativeOptions = component.get("v.MultiInitiativeValues") || [];
        picklistValues.initiatives = initiativeOptions.map(function(option) {
            return option.value;
        });
        
        // Ecosystem Partners
        var ecoPartnerOptions = component.get("v.MultiEcoPartnerValues") || [];
        picklistValues.ecosystemPartners = ecoPartnerOptions.map(function(option) {
            return option.value;
        });
        
        // Product Types
        var productTypeOptions = component.get("v.ProductTypeDependent") || [];
        picklistValues.productTypes = productTypeOptions.map(function(option) {
            return option.value;
        });
        
        // Tactics
        var tacticsOptions = component.get("v.activityTacticsOptions") || [];
        picklistValues.tactics = tacticsOptions.map(function(option) {
            return option.value;
        });
        
        // Outcome Metrics
        var outcomeOptions = component.get("v.outcomesDependants") || [];
        picklistValues.outcomeMetrics = outcomeOptions.map(function(option) {
            return option.value;
        });

        // Account context for AI suggestion matching
        var selectedAccount = component.get("v.selectedAccount");
        if (selectedAccount && selectedAccount.Name) {
            picklistValues.account = {
                name: selectedAccount.Name,
                id: selectedAccount.Id || null
            };
        }

        // Include current spending values to guide AI for spending-related suggestions.
        var totalInvestment = component.get("v.BudgetLocal");
        if (totalInvestment !== null && totalInvestment !== undefined && totalInvestment !== '') {
            picklistValues.spendingAmount = totalInvestment;
        }

        var reimbursementRate = component.get("v.newPFR.Core_MDF_Reimbursement_Rate__c");
        if (reimbursementRate !== null && reimbursementRate !== undefined && reimbursementRate !== '') {
            picklistValues.spendingPercentage = reimbursementRate;
        }

        // Include tactic metric context if available in the child component.
        var lwcTacticMetricsComp = component.find("tacticMetrics");
        if (lwcTacticMetricsComp != null) {
            try {
                var tacticMetricsValues;
                if (this.isNotBlank(lwcTacticMetricsComp[0])) {
                    tacticMetricsValues = lwcTacticMetricsComp[0].getTacticMetricsValues();
                } else if (lwcTacticMetricsComp.getTacticMetricsValues) {
                    tacticMetricsValues = lwcTacticMetricsComp.getTacticMetricsValues();
                }
                if (tacticMetricsValues) {
                    picklistValues.tacticMetrics = tacticMetricsValues;
                    picklistValues.goalValues = tacticMetricsValues;
                }
            } catch (metricError) {
                console.warn('Unable to read tactic metric values for AI context:', metricError);
            }
        }
        
    } catch (error) {
        console.error('Error collecting picklist values:', error);
    }
    
    return picklistValues;
},
performSmartAIAnalysis: function(component, description, uploadedIds, recordTypeDeveloperName) {
    var hasDescription = description && description.trim() !== '';
    var hasFiles = uploadedIds && uploadedIds.length > 0;
    
    if (hasDescription && hasFiles) {
        // Both description and files - call combined analysis
        this.performCombinedAnalysis(component, description, uploadedIds, recordTypeDeveloperName);
    } else if (hasDescription) {
        // Description only
        this.analyzeDescriptionOnly(component, description, recordTypeDeveloperName);
    } else if (hasFiles) {
        // Files only
        this.analyzeFilesOnly(component, uploadedIds, recordTypeDeveloperName);
    }
},

performCombinedAnalysis: function(component, description, uploadedIds, recordTypeDeveloperName) {
    // Call the new combined analysis Apex method
    var picklistValues = this.getFilteredPicklistValues(component);
    var action = component.get("c.analyzeCombinedContent");
    action.setParams({
        description: description,
        contentDocumentIds: uploadedIds,
        recordTypeDeveloperName: recordTypeDeveloperName,
        picklistValues: picklistValues
    });
    
    action.setCallback(this, function(response) {
        component.set("v.isLoadingAI", false);
        var state = response.getState();
        
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if (result && result.success) {
                this.openAISuggestionsModal(component, result, recordTypeDeveloperName);
            } else {
                this.displaySuccessErrorMsg(result.error || 'Failed to analyze content', 'Error', 'error', 'dismissible');
            }
        } else {
            this.displaySuccessErrorMsg('Error occurred during AI analysis', 'Error', 'error', 'dismissible');
        }
    });
    
    $A.enqueueAction(action);
},

analyzeDescriptionOnly: function(component, description, recordTypeDeveloperName) {
    var picklistValues = this.getFilteredPicklistValues(component);
    var action = component.get("c.analyzeDescriptionWithAI");
    action.setParams({
        description: description,
        recordTypeDeveloperName: recordTypeDeveloperName,
        picklistValues: picklistValues
    });
    
    action.setCallback(this, function(response) {
        component.set("v.isLoadingAI", false);
        var state = response.getState();
        
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if (result && result.success) {
                this.openAISuggestionsModal(component, result, recordTypeDeveloperName);
            } else {
                this.displaySuccessErrorMsg(result.error || 'Failed to analyze description', 'Error', 'error', 'dismissible');
            }
        } else {
            this.displaySuccessErrorMsg('Error occurred during description analysis', 'Error', 'error', 'dismissible');
        }
    });
    
    $A.enqueueAction(action);
},
checkUserEmailForAIAccess: function(component) {
    var action = component.get("c.checkCurrentUserEmailForAI");
    
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var hasAccess = response.getReturnValue();
            component.set("v.showAISuggestions", hasAccess);
        } else {
            console.error('Error checking user email for AI access:', response.getError());
            component.set("v.showAISuggestions", false);
        }
    });
    
    $A.enqueueAction(action);
},

analyzeFilesOnly: function(component, uploadedIds, recordTypeDeveloperName) {
    var picklistValues = this.getFilteredPicklistValues(component);
    var action = component.get("c.analyzeFileWithAI");
    action.setParams({
        contentDocumentIds: uploadedIds,
        recordTypeDeveloperName: recordTypeDeveloperName,
        picklistValues: picklistValues
    });
    
    action.setCallback(this, function(response) {
        component.set("v.isLoadingAI", false);
        var state = response.getState();
        
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if (result && result.success) {
                this.openAISuggestionsModal(component, result, recordTypeDeveloperName);
            } else {
                this.displaySuccessErrorMsg(result.error || 'Failed to analyze files', 'Error', 'error', 'dismissible');
            }
        } else {
            this.displaySuccessErrorMsg('Error occurred during file analysis', 'Error', 'error', 'dismissible');
        }
    });
    
    $A.enqueueAction(action);
},

openAISuggestionsModal: function(component, result, recordTypeDeveloperName) {
    var aiComponent = component.find("aiSuggestionsComponent");
    
    // Create a combined result object
    var combinedResult = {
        suggestions: result.data,
        rawData: result.rawData,
        analysisMode: component.get("v.smartAnalysisMode"),
        filesAnalyzed: result.filesAnalyzed || [],
        description: component.get("v.newPFR.Core_MDF_Activity_Description__c") || ''
    };
    
    // Open modal with combined results
    aiComponent.openModalWithResults(combinedResult, recordTypeDeveloperName);
},
determineFocusAreaFromDescription: function(description) {
    if (!description || typeof description !== 'string') {
        return 'Client Computing'; // Default value
    }
    
    // Use regex with whole-word boundaries (\b) to avoid false positives
    // e.g. "knowledge" must not match "edge", "datacenter" must not match "data center"
    var focusAreaPatterns = [
        {
            name: 'Client Computing',
            patterns: [/\bclient\s+computing\b/i]
        },
        {
            name: 'Data Center',
            patterns: [/\bdata\s+center\b/i, /\bdatacenter\b/i, /\bdata-center\b/i]
        },
        {
            name: 'Networking & Telco',
            patterns: [/\bnetworking\s*&\s*telco\b/i, /\bnetworking\s+and\s+telco\b/i]
        },
        {
            name: 'Edge',
            patterns: [/\bedge\b/i]
        }
    ];
    
    // Check each focus area for pattern matches
    for (var i = 0; i < focusAreaPatterns.length; i++) {
        var focusArea = focusAreaPatterns[i];
        
        for (var j = 0; j < focusArea.patterns.length; j++) {
            if (focusArea.patterns[j].test(description)) {
                return focusArea.name;
            }
        }
    }
    
    // If no patterns matched, return default
    return 'Client Computing';
},

// Helper method to check if focus area exists in available options
validateFocusAreaOption: function(component, focusAreaValue) {
    var availableOptions = component.get("v.AllFocusAreaOptions") || [];
    
    for (var i = 0; i < availableOptions.length; i++) {
        if (availableOptions[i].value === focusAreaValue) {
            return focusAreaValue;
        }
    }
    
    // If not found in available options, try to find Edge as fallback
    for (var i = 0; i < availableOptions.length; i++) {
        if (availableOptions[i].value === 'Client Computing') {
            return 'Client Computing';
        }
    }
    
    // If Edge not found either, return first available option or empty
    return availableOptions.length > 0 ? availableOptions[0].value : '';
},
detectFocusAreaFromUploadedFile: function(component, contentDocumentIds) {
    component.set("v.showSpinner", true);
    
    var action = component.get("c.detectFocusAreaFromFile");
    action.setParams({
        contentDocumentIds: contentDocumentIds
    });
    
    action.setCallback(this, function(response) {
        component.set("v.showSpinner", false);
        var state = response.getState();
        
        if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if (result && result.success) {
                var detectedFocusArea = result.focusArea;
                
                // Check current focus area and its source
                var currentFocusArea = component.get("v.selectedFocusArea");
                var detectionSource = component.get("v.focusAreaDetectionSource");
                
                // Only update if:
                // 1. No focus area is set, OR
                // 2. Current focus area is default "Client Computing" and wasn't manually set or set by description, OR
                // 3. Focus area was previously set by file (allow file updates)
                var shouldUpdate = !currentFocusArea || 
                                  currentFocusArea === '' || 
                                  (currentFocusArea === 'Client Computing' && detectionSource !== 'manual' && detectionSource !== 'description') ||
                                  detectionSource === 'file';
                
                if (shouldUpdate && detectedFocusArea) {
                    // Validate against available options
                    var validatedFocusArea = this.validateFocusAreaOption(component, detectedFocusArea);
                    
                    if (validatedFocusArea) {
                        // Set the focus area
                        component.set("v.selectedFocusArea", validatedFocusArea);
                        component.set("v.newPFR.Core_MDF_Focus_Area_nm__c", validatedFocusArea);
                        
                        // Mark source as file
                        component.set("v.focusAreaDetectionSource", "file");
                        
                        // Trigger focus area change to load dependent fields
                        if (!component.get("v.initialFocusAreaLoaded")) {
                            this.clearDependentFieldSelections(component);
                        } else {
                            component.set("v.initialFocusAreaLoaded", false);
                        }
                        
                        this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                        component.set("v.showDependentFields", true);
                        
                    }
                } else {
                }
            } else {
            }
        } else {
        }
    });
    
    $A.enqueueAction(action);
},

// RR Banner Dynamic Date - Start
checkRRBanner : function(component) {
    var action = component.get("c.shouldShowRRBanner");

    action.setParams({
        recordId : component.get("v.recordId")
    });

    action.setCallback(this, function(response) {
        if(response.getState() === "SUCCESS") {
            var showBanner = response.getReturnValue();

            if(showBanner) {
                var dateAction = component.get("c.getRRBannerDate");

                dateAction.setCallback(this, function(dateResponse) {
                    if(dateResponse.getState() === "SUCCESS") {
                        component.set("v.rrBannerDate", dateResponse.getReturnValue());
                        component.set("v.showBanner", true);
                    }
                });

                $A.enqueueAction(dateAction);
            } else {
                component.set("v.showBanner", false);
            }
        }
    });

    $A.enqueueAction(action);
},
// RR Banner Dynamic Date - End Indu

/*checkRRBanner : function(component) {

    var action = component.get("c.shouldShowRRBanner");

    action.setParams({
        recordId : component.get("v.recordId")
    });

    action.setCallback(this, function(response) {

        if(response.getState() === "SUCCESS") {

            component.set(
                "v.showBanner",
                response.getReturnValue()
            );

            var today = new Date();
            var aug5 = new Date(2026, 7, 5); // Aug 5, 2026

            component.set(
                "v.rrBannerDate",
                today <= aug5
                    ? ' July 24, 2026.'
                    : ' October 23, 2026.'
            );


        }
    });

    $A.enqueueAction(action);
},*/

    sanitizeResults : function(result){
        if(result != null && result != undefined && result != {} && Object.keys(result).length > 0){
            return result;
        }
        else{
            return null;
        }
    },

    // Helper to apply deferred country suggestions after region filtering completes
    // This ensures country values are resolved against region-filtered options
    fetchCountriesByRegionWithCallback: function(component, region, countryValues, countryMapping, resolveFunction, normalizeTokenFunc) {
        var self = this;
        var masterList = component.get("v.AllCountryOptionsMain") || [];
        
        if (!region || masterList.length === 0 || !Array.isArray(countryValues) || countryValues.length === 0) {
            return;
        }

        // Extract labels/values into plain string list
        var allowedLabels = masterList.map(function(c) {
            return c.label;
        });

        var action = component.get("c.getCountryLabelsByRegion");
        action.setParams({
            region: region,
            allowedCountryLabels: allowedLabels
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var serverList = response.getReturnValue() || [];
                var filteredOptions = [];
                
                for (var j = 0; j < serverList.length; j++) {
                    filteredOptions.push({
                        label: serverList[j],
                        value: serverList[j]
                    });
                }

                // Temporarily update component with filtered options
                component.set("v.AllCountryOptions", filteredOptions);

                // Now resolve the country values against filtered options
                var normalizedCountries = countryValues;
                if (Array.isArray(countryValues) && countryValues.length > 0) {
                    normalizedCountries = countryValues.map(function(value) {
                        var normalizedInput = normalizeTokenFunc(value);
                        var match = filteredOptions.find(function(option) {
                            return normalizeTokenFunc(option.value) === normalizedInput || normalizeTokenFunc(option.label) === normalizedInput;
                        });

                        // If no exact match, try fuzzy matching
                        if (!match) {
                            match = filteredOptions.find(function(option) {
                                var optionValueNorm = normalizeTokenFunc(option.value);
                                var optionLabelNorm = normalizeTokenFunc(option.label);
                                return (optionValueNorm && normalizedInput.indexOf(optionValueNorm) >= 0) ||
                                    (optionLabelNorm && normalizedInput.indexOf(optionLabelNorm) >= 0) ||
                                    (optionValueNorm && optionValueNorm.indexOf(normalizedInput) >= 0) ||
                                    (optionLabelNorm && optionLabelNorm.indexOf(normalizedInput) >= 0);
                            });
                        }

                        return match ? match.value : value;
                    });
                }

                // Apply resolved countries
                if (normalizedCountries.length > 0) {
                    component.set("v." + countryMapping.component, normalizedCountries);
                    component.set("v.newPFR." + countryMapping.pfr, normalizedCountries.join(';'));
                }
            } else {
                var errs = response.getError();
                var msg = 'Error fetching countries for region';
                if (errs && errs[0] && errs[0].message) msg = errs[0].message;
                console.error('Error in fetchCountriesByRegionWithCallback:', msg);
            }
        });

        $A.enqueueAction(action);
    },

    // ═══════════════════════════════════════════════════════════════════════════════
    // AI RECOMMENDATION TRACKING METHODS
    // ═══════════════════════════════════════════════════════════════════════════════

    initializeAiTracking: function(component, suggestions, selectedFields, userInputs, analysisType, filesAnalyzed, aiRequestGroupId) {
        var self = this;
        
        // Store pre-AI values (current form values before applying suggestions)
        var preAiValues = this.captureCurrentFieldValues(component);
        component.set('v.preAiFieldValues', preAiValues);
        
        // Store AI source metadata
        var sourceType = analysisType || 'Description';
        if (sourceType === 'description') sourceType = 'Description';
        if (sourceType === 'files') sourceType = 'File';
        if (sourceType === 'combined') sourceType = 'Combined';
        
        component.set('v.aiSourceType', sourceType);
        component.set('v.aiSourceFiles', Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : (filesAnalyzed || ''));
        
        // Build tracking entries for ALL suggested fields (selected and unselected)
        var trackingEntries = [];
        var fieldMappings = this.getAiFieldMappings();
        
        // Get all suggested field names from the suggestions object
        var allSuggestedFields = suggestions ? Object.keys(suggestions) : [];
        
        allSuggestedFields.forEach(function(fieldName) {
            // Skip complex nested objects that are handled separately
            if (fieldName === 'tacticMetrics' || fieldName === 'outcomeActivityValues' || fieldName === 'goalValues' || fieldName === 'spendingPercentage') {
                return;
            }
            
            var aiSuggestedValue = suggestions[fieldName];
            // For account field the AI returns an object {name: "..."} — extract just the name string
            if (fieldName === 'account' && aiSuggestedValue && typeof aiSuggestedValue === 'object') {
                aiSuggestedValue = aiSuggestedValue.name || aiSuggestedValue.Name || '';
            }
            // Skip null/undefined/empty suggestions
            if (aiSuggestedValue === null || aiSuggestedValue === undefined || aiSuggestedValue === '') {
                return;
            }
            
            var isSelected = selectedFields && selectedFields[fieldName] === true;
            var mapping = fieldMappings[fieldName] || { apiName: fieldName, label: fieldName, targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.' + fieldName };
            
            var appliedValue = '';
            var modificationType = 'Not Applied';
            var recommendationUsed = false;
            
            if (isSelected) {
                appliedValue = (userInputs && userInputs[fieldName] !== undefined) 
                    ? userInputs[fieldName] 
                    : aiSuggestedValue;
                modificationType = 'Accepted As-Is';
                recommendationUsed = true;
            }
            
            var entry = {
                groupId: aiRequestGroupId,
                sourceType: sourceType,
                sourceFiles: Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : (filesAnalyzed || ''),
                fieldApiName: mapping.apiName,
                fieldLabel: mapping.label,
                targetObject: mapping.targetObject || 'PartnerFundRequest',
                targetRecordKey: mapping.targetRecordKey || null,
                fieldPath: mapping.fieldPath || ('PartnerFundRequest.' + mapping.apiName),
                preAiValue: preAiValues[fieldName] !== undefined ? self.serializeTrackingValue(preAiValues[fieldName]) : '',
                aiSuggestedValue: self.serializeTrackingValue(aiSuggestedValue),
                appliedValue: self.serializeTrackingValue(appliedValue),
                finalSavedValue: null,
                isModifiedAfterApply: false,
                modificationType: modificationType,
                recommendationUsed: recommendationUsed,
                userDecision: modificationType
            };
            
            trackingEntries.push(entry);
        });
        

        // Handle tactic metrics (child rows) if selected.
        // The "Tactics" checkbox uses data-field="tactics" → selectedFields.tactics.
        // AI may return goal values in suggestions.goalValues (flat: {tacticName: {goalValue:N}})
        // and/or in suggestions.tacticMetrics (may be flat OR nested under .metrics sub-object).
        // Spending amounts only come from tacticMetrics.
        // Strategy: collect tactic names from BOTH sources; resolve goal value with multiple fallbacks.
        var tacticMetricsData = (suggestions && suggestions.tacticMetrics && typeof suggestions.tacticMetrics === 'object' && Object.keys(suggestions.tacticMetrics).length > 0)
            ? suggestions.tacticMetrics : {};
        var goalValuesData = (suggestions && suggestions.goalValues && typeof suggestions.goalValues === 'object' && Object.keys(suggestions.goalValues).length > 0)
            ? suggestions.goalValues : {};

        var allTacticNames = {};
        Object.keys(tacticMetricsData).forEach(function(k) { allTacticNames[k] = true; });
        Object.keys(goalValuesData).forEach(function(k) { allTacticNames[k] = true; });

        if (selectedFields && (selectedFields.tactics || selectedFields.tacticMetrics || selectedFields.goalValues) && Object.keys(allTacticNames).length > 0) {
            Object.keys(allTacticNames).forEach(function(tacticName) {
                var tm = tacticMetricsData[tacticName];
                var gv = goalValuesData[tacticName];

                // Normalize plain numbers to objects
                if (typeof tm === 'number') { tm = { goalValue: tm }; }
                if (typeof gv === 'number') { gv = { goalValue: gv }; }
                if (!tm || typeof tm !== 'object') { tm = {}; }
                if (!gv || typeof gv !== 'object') { gv = {}; }

                // Resolve goal value with cascading fallbacks:
                // 1. goalValues[tacticName].goalValue (cleanest flat format)
                // 2. tacticMetrics[tacticName].goalValue (flat format)
                // 3. tacticMetrics[tacticName].metrics[*].goalValue (nested format)
                var resolvedGoalValue = null;
                if (gv.goalValue !== undefined && gv.goalValue !== null && gv.goalValue !== '') {
                    resolvedGoalValue = gv.goalValue;
                } else if (tm.goalValue !== undefined && tm.goalValue !== null && tm.goalValue !== '') {
                    resolvedGoalValue = tm.goalValue;
                } else if (tm.metrics && typeof tm.metrics === 'object') {
                    var mKeys = Object.keys(tm.metrics);
                    for (var mi = 0; mi < mKeys.length; mi++) {
                        var me = tm.metrics[mKeys[mi]];
                        var mg = (me && typeof me === 'object')
                            ? (me.goalValue !== undefined ? me.goalValue : (me.firstKpiValue !== undefined ? me.firstKpiValue : null))
                            : me;
                        if (mg !== undefined && mg !== null && mg !== '') {
                            resolvedGoalValue = mg;
                            break;
                        }
                    }
                }

                if (resolvedGoalValue !== null) {
                    trackingEntries.push({
                        groupId: aiRequestGroupId,
                        sourceType: sourceType,
                        sourceFiles: Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : '',
                        fieldApiName: 'Core_MDF_Goal_Value__c',
                        fieldLabel: 'Tactic Goal Value - ' + tacticName,
                        targetObject: 'Core_MDF_Tactic_KPI__c',
                        targetRecordKey: tacticName,
                        fieldPath: 'Core_MDF_Tactic_KPI__c.' + tacticName + '.Goal_Value__c',
                        preAiValue: '',
                        aiSuggestedValue: String(resolvedGoalValue),
                        appliedValue: String(resolvedGoalValue),
                        finalSavedValue: null,
                        isModifiedAfterApply: false,
                        modificationType: 'Accepted As-Is',
                        recommendationUsed: true,
                        userDecision: 'Accepted As-Is'
                    });
                }

                // Spending amount comes from tacticMetrics only
                if (tm.spendingAmount !== undefined && tm.spendingAmount !== null && tm.spendingAmount !== '') {
                    trackingEntries.push({
                        groupId: aiRequestGroupId,
                        sourceType: sourceType,
                        sourceFiles: Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : '',
                        fieldApiName: 'Core_MDF_Spending_Amount_amt__c',
                        fieldLabel: 'Tactic Spending Amount - ' + tacticName,
                        targetObject: 'Core_MDF_Tactic_KPI__c',
                        targetRecordKey: tacticName,
                        fieldPath: 'Core_MDF_Tactic_KPI__c.' + tacticName + '.Spending_Amount_amt__c',
                        preAiValue: '',
                        aiSuggestedValue: String(tm.spendingAmount),
                        appliedValue: String(tm.spendingAmount),
                        finalSavedValue: null,
                        isModifiedAfterApply: false,
                        modificationType: 'Accepted As-Is',
                        recommendationUsed: true,
                        userDecision: 'Accepted As-Is'
                    });
                }
            });
        }
        
        // Akash changes AI start
        // Handle outcomeActivityValues (child record) if selected.
        // The LWC breaks outcomeActivityValues into three individual checkboxes and deletes
        // selectedFields.outcomeActivityValues, so gate on the individual component keys.
        var hasAnyOutcomeField = selectedFields && (selectedFields.outcomeBaselineValue || selectedFields.outcomeGoalValue || selectedFields.outcomeBaselinePeriod);
        if (hasAnyOutcomeField && suggestions && suggestions.outcomeActivityValues && typeof suggestions.outcomeActivityValues === 'object') {
            var outcomeData = suggestions.outcomeActivityValues;
            var outcomeMetricKey = outcomeData.outcomeMetric || 'Primary';
            
            if (selectedFields.outcomeBaselineValue && outcomeData.baselineValue !== undefined && outcomeData.baselineValue !== null) {
                trackingEntries.push({
                    groupId: aiRequestGroupId,
                    sourceType: sourceType,
                    sourceFiles: Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : '',
                    fieldApiName: 'Core_MDF_Baseline_Value_nbr__c',
                    fieldLabel: 'Baseline Value',
                    targetObject: 'Core_MDF_Outcome_Activity__c',
                    targetRecordKey: outcomeMetricKey,
                    fieldPath: 'Core_MDF_Activity_Outcome__c.Core_MDF_Baseline_Value_nbr__c',
                    preAiValue: '',
                    aiSuggestedValue: String(outcomeData.baselineValue),
                    appliedValue: String(outcomeData.baselineValue),
                    finalSavedValue: null,
                    isModifiedAfterApply: false,
                    modificationType: 'Accepted As-Is',
                    recommendationUsed: true,
                    userDecision: 'Accepted As-Is'
                });
            }
            
            if (selectedFields.outcomeGoalValue && outcomeData.goalValue !== undefined && outcomeData.goalValue !== null) {
                trackingEntries.push({
                    groupId: aiRequestGroupId,
                    sourceType: sourceType,
                    sourceFiles: Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : '',
                    fieldApiName: 'Core_MDF_Goal_Value_nbr__c',
                    fieldLabel: 'Goal Value',
                    targetObject: 'Core_MDF_Outcome_Activity__c',
                    targetRecordKey: outcomeMetricKey,
                    fieldPath: 'Core_MDF_Activity_Outcome__c.Core_MDF_Goal_Value_nbr__c',
                    preAiValue: '',
                    aiSuggestedValue: String(outcomeData.goalValue),
                    appliedValue: String(outcomeData.goalValue),
                    finalSavedValue: null,
                    isModifiedAfterApply: false,
                    modificationType: 'Accepted As-Is',
                    recommendationUsed: true,
                    userDecision: 'Accepted As-Is'
                });
            }
            
            if (selectedFields.outcomeBaselinePeriod && outcomeData.baselinePeriod) {
                trackingEntries.push({
                    groupId: aiRequestGroupId,
                    sourceType: sourceType,
                    sourceFiles: Array.isArray(filesAnalyzed) ? filesAnalyzed.join(', ') : '',
                    fieldApiName: 'Core_MDF_Baseline_Period_nm__c',
                    fieldLabel: 'Baseline Period',
                    targetObject: 'Core_MDF_Outcome_Activity__c',
                    targetRecordKey: outcomeMetricKey,
                    fieldPath: 'Core_MDF_Activity_Outcome__c.Core_MDF_Baseline_Period_nm__c',
                    preAiValue: '',
                    aiSuggestedValue: String(outcomeData.baselinePeriod),
                    appliedValue: String(outcomeData.baselinePeriod),
                    finalSavedValue: null,
                    isModifiedAfterApply: false,
                    modificationType: 'Accepted As-Is',
                    recommendationUsed: true,
                    userDecision: 'Accepted As-Is'
                });
            }
        }
        
        // Store applied AI values for comparison at save time
        var appliedValues = {};
        trackingEntries.forEach(function(entry) {
            var key = entry.targetObject + '.' + entry.fieldApiName + (entry.targetRecordKey ? '.' + entry.targetRecordKey : '');
            appliedValues[key] = entry.appliedValue;
        });
        component.set('v.appliedAiFieldValues', appliedValues);
        
        component.set('v.aiTrackingEntries', trackingEntries);
    },

    captureCurrentFieldValues: function(component) {
        var newPFR = component.get('v.newPFR') || {};
        return {
            campaignName: newPFR.Title || '',
            campaignDescription: newPFR.Core_MDF_Activity_Description__c || '',
            startDate: newPFR.Core_MDF_Start_Date__c || '',
            endDate: newPFR.Core_MDF_End_Date__c || '',
            totalInvestment: component.get('v.BudgetLocal') || '',
            maxIntelInvestment: component.get('v.maxIntelInvestment') || '',
            focusArea: component.get('v.selectedFocusArea') || '',
            priority: component.get('v.SelPriority') || '',
            region: component.get('v.selectedRegion') || '',
            country: (component.get('v.selectedCountryOptions') || []).join(';'),
            targetAudience: (component.get('v.selectedTargetAudienceOptions') || []).join(';'),
            brands: (component.get('v.selectedBrandOptions') || []).join(';'),
            technologies: (component.get('v.selectedTechnologyOptions') || []).join(';'),
            initiatives: (component.get('v.selectedInitiativeOptions') || []).join(';'),
            ecosystemPartners: (component.get('v.selectedEcosystemPartnerOptions') || []).join(';'),
            productTypes: (component.get('v.selectedProductTypeOptions') || []).join(';'),
            tactics: (component.get('v.selectedTacticsOptions') || []).join(';'),
            outcomeMetrics: (component.get('v.selectedOutcomeMetricOptions') || []).join(';'),
            account: component.get('v.selectedAccount') ? (component.get('v.selectedAccount').Name || component.get('v.selectedAccount').Id || '') : ''
        };
    },

    getAiFieldMappings: function() {
        return {
            campaignName: { apiName: 'Title', label: 'Campaign Name', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Title' },
            campaignDescription: { apiName: 'Core_MDF_Activity_Description__c', label: 'Activity Description', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Activity_Description__c' },
            startDate: { apiName: 'Core_MDF_Start_Date__c', label: 'Start Date', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Start_Date__c' },
            endDate: { apiName: 'Core_MDF_End_Date__c', label: 'End Date', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_End_Date__c' },
            totalInvestment: { apiName: 'Core_MDF_Budget_Amount_Local_amt__c', label: 'Total Investment', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Budget_Amount_Local_amt__c' },
            maxIntelInvestment: { apiName: 'Core_MDF_Maximum_Intel_Investment_amt__c', label: 'Max Intel Investment', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Maximum_Intel_Investment_amt__c' },
            focusArea: { apiName: 'Core_MDF_Focus_Area_nm__c', label: 'Focus Area', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Focus_Area_nm__c' },
            priority: { apiName: 'Core_MDF_Priority__c', label: 'Priority', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Priority__c' },
            region: { apiName: 'Core_MDF_Geo__c', label: 'Region', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Geo__c' },
            country: { apiName: 'Core_MDF_Country_nm__c', label: 'Country', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Country_nm__c' },
            targetAudience: { apiName: 'Core_MDF_TargetAudience_nm__c', label: 'Target Audience', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_TargetAudience_nm__c' },
            brands: { apiName: 'Core_MDF_Brand_nm__c', label: 'Brands', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Brand_nm__c' },
            technologies: { apiName: 'Core_MDF_Technology_txt__c', label: 'Technologies', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Technology_txt__c' },
            initiatives: { apiName: 'Core_MDF_Initiative_nm__c', label: 'Initiatives', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Initiative_nm__c' },
            ecosystemPartners: { apiName: 'Core_MDF_EcosystemPartner_nm__c', label: 'Ecosystem Partners', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_EcosystemPartner_nm__c' },
            productTypes: { apiName: 'Core_MDF_Product_Type__c', label: 'Product Types', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Product_Type__c' },
            tactics: { apiName: 'Core_MDF_Tactics_nm__c', label: 'Tactics', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Tactics_nm__c' },
            outcomeMetrics: { apiName: 'Core_MDF_Outcomes_nm__c', label: 'Outcome Metrics', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Outcomes_nm__c' },
            account: { apiName: 'ChannelPartnerId', label: 'Account', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.ChannelPartnerId' },
            spendingAmount: { apiName: 'Core_MDF_Spending_Amount__c', label: 'Spending Amount', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Spending_Amount__c' },
            spendingPercentage: { apiName: 'Core_MDF_Spending_Percentage__c', label: 'Spending Percentage', targetObject: 'PartnerFundRequest', fieldPath: 'PartnerFundRequest.Core_MDF_Spending_Percentage__c' },
            tacticMetrics: { apiName: 'tacticMetrics', label: 'Tactic Metrics', targetObject: 'Core_MDF_Tactic_KPI__c', targetRecordKey: null, fieldPath: 'Core_MDF_Tactic_KPI__c' },
            goalValues: { apiName: 'goalValues', label: 'Goal Values', targetObject: 'Core_MDF_Tactic_KPI__c', targetRecordKey: null, fieldPath: 'Core_MDF_Tactic_KPI__c.goalValues' },
            outcomeActivityValues: { apiName: 'outcomeActivityValues', label: 'Outcome Values', targetObject: 'Core_MDF_Outcome_Activity__c', targetRecordKey: null, fieldPath: 'Core_MDF_Outcome_Activity__c' }
        };
    },

    serializeTrackingValue: function(value) {
        if (value === null || value === undefined) {
            return '';
        }
        if (typeof value === 'string') {
            return value;
        }
        if (typeof value === 'number' || typeof value === 'boolean') {
            return String(value);
        }
        if (Array.isArray(value)) {
            return value.join(';');
        }
        if (typeof value === 'object') {
            try {
                return JSON.stringify(value);
            } catch (e) {
                return String(value);
            }
        }
        return String(value);
    },

    finalizeAiTrackingEntries: function(component) {
        var self = this;
        var trackingEntries = component.get('v.aiTrackingEntries') || [];
        if (trackingEntries.length === 0) {
            return [];
        }
        
        var currentValues = this.captureCurrentFieldValues(component);
        var fieldMappings = this.getAiFieldMappings();
        
        // Create reverse lookup: API name -> JS field name
        var apiToJsField = {};
        Object.keys(fieldMappings).forEach(function(jsField) {
            apiToJsField[fieldMappings[jsField].apiName] = jsField;
        });
        
        // Pre-fetch live values from child components so final saved values reflect user edits
        var currentTacticRows = null;
        var lwcTacticComp = component.find('tacticMetrics');
        if (lwcTacticComp) {
            var tComp = Array.isArray(lwcTacticComp) ? lwcTacticComp[0] : lwcTacticComp;
            if (tComp && tComp.getTacticMetricsValues) {
                try { currentTacticRows = tComp.getTacticMetricsValues(); } catch(e) {}
            }
        }

        var currentOutcomeRows = null;
        var lwcOutcomeComp = component.find('activityOutcomeCmp');
        if (lwcOutcomeComp) {
            var oComp = Array.isArray(lwcOutcomeComp) ? lwcOutcomeComp[0] : lwcOutcomeComp;
            if (oComp && oComp.getAllActivityOutcomesDetails) {
                try { currentOutcomeRows = oComp.getAllActivityOutcomesDetails(); } catch(e) {}
            }
        }

        trackingEntries.forEach(function(entry) {
            // Skip "Not Applied" entries - they already have correct state
            if (entry.modificationType === 'Not Applied') {
                entry.finalSavedValue = entry.preAiValue || '';
                return;
            }
            
            var finalValue = '';
            
            // For main PFR fields
            if (entry.targetObject === 'PartnerFundRequest') {
                var jsFieldName = apiToJsField[entry.fieldApiName];
                if (jsFieldName && currentValues[jsFieldName] !== undefined) {
                    finalValue = self.serializeTrackingValue(currentValues[jsFieldName]);
                }
            } else if (entry.targetObject === 'Core_MDF_Tactic_KPI__c' && currentTacticRows && entry.targetRecordKey) {
                var tacticFinal = self.extractTacticFinalValue(currentTacticRows, entry);
                finalValue = tacticFinal !== '' ? tacticFinal : (entry.appliedValue || '');
            } else if (entry.targetObject === 'Core_MDF_Outcome_Activity__c' && currentOutcomeRows && entry.targetRecordKey) {
                var outcomeFinal = self.extractOutcomeFinalValue(currentOutcomeRows, entry);
                finalValue = outcomeFinal !== '' ? outcomeFinal : (entry.appliedValue || '');
            } else {
                finalValue = entry.appliedValue || '';
            }
            
            entry.finalSavedValue = finalValue;
            var appliedValue = entry.appliedValue || '';
            
            // Determine modification type (only for applied suggestions)
            if (finalValue === appliedValue || self.trackingValuesAreEquivalent(finalValue, appliedValue)) {
                entry.isModifiedAfterApply = false;
                entry.modificationType = 'Accepted As-Is';
                entry.userDecision = 'Accepted As-Is';
            } else if (finalValue === '' || finalValue === null || finalValue === 'null' || finalValue === '""') {
                entry.isModifiedAfterApply = true;
                entry.modificationType = 'Cleared After Apply';
                entry.userDecision = 'Cleared After Apply';
            } else {
                entry.isModifiedAfterApply = true;
                entry.modificationType = 'Modified After Apply';
                entry.userDecision = 'Modified After Apply';
            }
        });
        
        component.set('v.aiTrackingEntries', trackingEntries);
        return trackingEntries;
    },

    trackingValuesAreEquivalent: function(val1, val2) {
        var normalize = function(v) {
            if (v === null || v === undefined) return '';
            var str = String(v).trim();
            // Sort semicolon-separated values for comparison
            if (str.indexOf(';') > -1) {
                return str.split(';').map(function(s) { return s.trim().toLowerCase(); }).sort().join(';');
            }
            return str.toLowerCase();
        };
        return normalize(val1) === normalize(val2);
    },

    extractTacticFinalValue: function(tacticRows, entry) {
        if (!Array.isArray(tacticRows) || !entry.targetRecordKey) {
            return '';
        }
        var normalizeToken = function(v) {
            return v ? String(v).toLowerCase().replace(/[^a-z0-9]/g, '') : '';
        };
        var normKey = normalizeToken(entry.targetRecordKey);
        for (var i = 0; i < tacticRows.length; i++) {
            var r = tacticRows[i];
            var rowApi = r.tactic && r.tactic.api ? r.tactic.api : String(r.tactic || '');
            var rowLabel = r.tactic && r.tactic.label ? r.tactic.label : '';
            if (normalizeToken(rowApi) === normKey || normalizeToken(rowLabel) === normKey) {
                if (entry.fieldApiName === 'Core_MDF_Goal_Value__c') {
                    var kv = r.firstKpi && r.firstKpi.value !== undefined && r.firstKpi.value !== null && r.firstKpi.value !== '' ? r.firstKpi.value : null;
                    return kv !== null ? String(kv) : '';
                }
                if (entry.fieldApiName === 'Core_MDF_Spending_Amount_amt__c') {
                    var sv = r.intelContri !== undefined && r.intelContri !== null && r.intelContri !== '' ? r.intelContri : null;
                    return sv !== null ? String(sv) : '';
                }
                return '';
            }
        }
        return '';
    },

    extractOutcomeFinalValue: function(outcomeRows, entry) {
        if (!Array.isArray(outcomeRows) || !entry.targetRecordKey) {
            return '';
        }
        var normalizeToken = function(v) {
            return v ? String(v).toLowerCase().replace(/[^a-z0-9]/g, '') : '';
        };
        var normKey = normalizeToken(entry.targetRecordKey);
        for (var i = 0; i < outcomeRows.length; i++) {
            var r = outcomeRows[i];
            var rowMetric = r.outcomeMetric ? String(r.outcomeMetric) : '';
            if (normalizeToken(rowMetric) === normKey || normKey === normalizeToken('Primary')) {
                if (entry.fieldApiName === 'Core_MDF_Baseline_Value_nbr__c') {
                    return r.baselineValue !== undefined && r.baselineValue !== null && r.baselineValue !== '' ? String(r.baselineValue) : '';
                }
                if (entry.fieldApiName === 'Core_MDF_Goal_Value_nbr__c') {
                    return r.goalValue !== undefined && r.goalValue !== null && r.goalValue !== '' ? String(r.goalValue) : '';
                }
                if (entry.fieldApiName === 'Core_MDF_Baseline_Period_nm__c') {
                    // getAllActivityOutcomesDetails returns baseLinePeriod (capital L)
                    var period = r.baseLinePeriod !== undefined ? r.baseLinePeriod : (r.baselinePeriod !== undefined ? r.baselinePeriod : '');
                    return period !== null && period !== undefined ? String(period) : '';
                }
                return '';
            }
        }
        return '';
    },

    persistAiTrackingRecords: function(component, recordId, trackingEntries) {
        if (!trackingEntries || trackingEntries.length === 0) {
            return;
        }
        
        var action = component.get('c.saveAiTrackingRecords');
        action.setParams({
            activityId: recordId,
            trackingEntriesJson: JSON.stringify(trackingEntries)
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                // Clear tracking entries after successful save
                component.set('v.aiTrackingEntries', []);
                component.set('v.aiRequestGroupId', '');
                component.set('v.preAiFieldValues', {});
                component.set('v.appliedAiFieldValues', {});
            } else {
                var errors = response.getError();
                var errorMsg = errors && errors[0] && errors[0].message ? errors[0].message : 'Unknown error';
                console.error('[AI Tracking] Failed to persist tracking records:', errorMsg);
            }
        });
        
        $A.enqueueAction(action);
    }

})