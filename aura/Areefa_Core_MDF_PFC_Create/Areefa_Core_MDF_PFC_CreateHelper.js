({
    // doInit method to initialize all the required parameters on Page Load. 
    doInit: function(component,event,helper){
        //This is to fetch record type meta data map and set activity record type developer name
        this.fetchRecordTypeMetaData(component);        
        //To identify Partner User
        this.fetchMemberPartnerDetails(component);
		//this.showOrHideclaimMediaVehicle(component);        
        
        //To identify weather its clone or EDit claim process
        if(component.get("v.simpleNewClaim.Id")!='' && component.get("v.simpleNewClaim.Id")!= undefined){
            //Setting simple new caim Id to temporary field, which is used in loadKPIAttributes payload
            component.set('v.clonedClaimId',component.get("v.simpleNewClaim.Id"));
            if(component.get("v.isCloneClaim"))
            {
                component.set("v.isClaimEdit",false);
                this.onCloneClaim(component);
                //It would clean up claim id on Clone Claim 
                this.clearUpClaimIdOnClone(component);
            }
            else{
                component.set("v.isClaimEdit",true);
                this.onEditClaim(component);
            }
        }
        // Vat OptIn PicklistValues	 
        //this.getVatOptInPicklistValues(component,event);  
        // This is to fetch the Invoice Currency Picklist and Logged In User Info
        this.fetchUserAndPicklistInfo(component);
        // This is to fetch page URL to redirect to the list view
        this.getPageUrl(component);
        component.set("v.isError", false);
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
            if(!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim").RecordType)){
                //to hold claim record type developer name
                var claimRecordType = component.get("v.simpleNewClaim").RecordType.DeveloperName;
                //Setting selected claim record type
                component.set('v.recordtypeDeveloperName',claimRecordType);
            }
			// On Create/Edit/Clone
            if(!$A.util.isUndefinedOrNull(component.get('v.recordTypeMap'))){ 
                var claimRecordType = component.get('v.recordtypeDeveloperName');
                if(component.get('v.recordTypeMap').hasOwnProperty(claimRecordType)){
                    component.set('v.activityRecordTypeDevName', (component.get('v.recordTypeMap')[claimRecordType]).Core_MDF_Activity_RecordType_txt__c);  
                    //Assign POPMandatory and swapRetailFields flag
                    this.assignRecordTypeMetaDataValues(component);
                }
            }
        }
    },
	
    //This helper function is used to set activity status filter, whcih is used in activity lookup
	setActivityFilter: function(component){
		// To get the activity status to create claim
        var activityStatusToCreateClaim = ($A.get("$Label.c.Core_MDF_PFR_Status_CreateClaim")).split(";");
        
        //To get Activity Closure Type
        var activityClosureType = ($A.get("$Label.c.Core_MDF_Activity_Closure_Type_to_create_claim")).split(";");
        
        // Closed activity should be available in look up in case if Claim case reveiwer or Manager creates claim
        if(component.get("v.isUserClaimCaseReviewerOrManager")){
            activityStatusToCreateClaim = activityStatusToCreateClaim.concat($A.get("$Label.c.Core_MDF_Claim_Activity_Closed_Status"));
        }
        
        component.set('v.activityStatusList', activityStatusToCreateClaim);
        var activityStatusCommaSeparated = "@quote;" + activityStatusToCreateClaim.join("@quote;,@quote;") + "@quote;";
        component.set('v.activityStatusCommaSeparated', activityStatusCommaSeparated);
		
        component.set('v.activityClosureTypeList', activityClosureType);
        var activityClosureTypeSeparated = "@quote;" + activityClosureType.join("@quote;,@quote;") + "@quote;";
        component.set('v.activityClosureTypeSeparated', activityClosureTypeSeparated);
        
		var searchCriteria = 'Core_MDF_Fund_Request_Status__c IN (' + activityStatusCommaSeparated + ')'+'AND Core_MDF_Activity_Closure_Type__c NOT IN ('+activityClosureTypeSeparated+')';
        component.set('v.activitySearchCriteria', searchCriteria);
        
	},
	
    //This helper function is used to set escalation id and activity id when claim create from escalation
    //and fetch activity details , when claim create from activity
	createClaimFromEscalationOrActivity: function(component){
		//fetch Activity from Escalation
		var escActId = 	component.get("v.escActivityId");
		var escalationId = component.get("v.escalationId");
		// Create Claim from escalation
		if(escActId !='' && !$A.util.isUndefinedOrNull(escActId) && escalationId!='' && !$A.util.isUndefinedOrNull(escalationId)){
            //Function calls in case, claim create from Escalation
            component.set("v.simpleNewClaim.RequestId",escActId);
            component.set("v.sObjectId", escActId);
            //Function calls in case, claim create from Escalation
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",escalationId);
            //used in case of clear lookup
            component.set("v.escObjectId",escalationId);
		}	
		else{ // Create Claim from activity
			//Function calls in case, claim create from activity
			this.getActivityDtlsByRecordId(component);
		}
	},
    
    //This helper function is used to validate claim form
    validateClaimForm: function (component) {
        // Show error messages if required fields are blank
        var validClaim = true;
        var auraIds = [];
         switch(component.get('v.recordtypeDeveloperName').toUpperCase())
        {
            case $A.get("$Label.c.Core_MDF_Claim_SPCF_Program").toUpperCase():
              	auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_SPCF").split(",");  
        		break;
                
            case $A.get("$Label.c.Core_MDF_RetailProgram").toUpperCase(): 
                if(component.get('v.budgetType') == $A.get("$Label.c.Core_MDF_RetailMDF_BudgetType")){
                     auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_RMF_MDF").split(",");
                }
                else{
                    auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_RSA_MD").split(",");
                }
                break;
            case $A.get("$Label.c.Core_MDF_IPA_RecordType").toUpperCase():
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_IPA").split(",");
                break;
                
            default:
                auraIds = $A.get("$Label.c.Core_MDF_Aura_Ids_for_CCF_DCF_Boost").split(",");
        }
                
        for (var i = 0; i < auraIds.length; i++) {
            if (auraIds[i] != "activityId" && auraIds[i] != "activityIdRetail" && auraIds[i] !="ActSubTypes") {
                var inputCmp = component.find(auraIds[i]);
                var inputCmpValidity = inputCmp.get("v.validity").valid;
                if (inputCmpValidity == false) {
                    inputCmp.showHelpMessageIfInvalid();
                    validClaim = false;
                }
            } else {
                var activityCmp;
                if(component.get('v.isClaimActivitySwap')){
                    activityCmp = component.find("activityIdRetail");
                }else{
                    activityCmp = component.find("activityId");
                }
                if (activityCmp.get("v.value") == '') {
                    validClaim = false;
                }
                 if(auraIds[i] =="ActSubTypes") { // Added as part for Acty sub type validation
                     validClaim=component.find('ActSubTypes').isValid();                     
                }
            }
        }
        return validClaim;
    },
    
    // This method clears Claim Id for Clone , since its clone claim and It will create New record
    clearUpClaimIdOnClone: function(component){
        if(component.get("v.isCloneClaim"))
        {
            component.set("v.simpleNewClaim.Id",null);
        }
    },
    
    //This helper function is used to save claim data 
    saveClaim: function (component) {
        if (component.get("v.Spinner") == false) {
            component.set("v.Spinner", true);
        }
        var manageAuditComponent = component.find('manageAudit');
       
        if(this.isPOPMandatory(component)){
            // Documents are Mandatory for Retail Program
            component.set("v.claimErrorMsg",$A.get("$Label.c.Core_MDF_RetailDocMandatoryError") );
            this.populateErrorToastModal(component);
        }else if(manageAuditComponent!=null && !manageAuditComponent.get('v.isSaveEnabled')){
            // Mandatory Document Types for Retail - Proof of Branding;Proof of Execution
            component.set("v.claimErrorMsg",$A.get("$Label.c.Core_MDF_Mandatory_Document_Types_Error_Message"));
            this.populateErrorToastModal(component);
        }else{
            //It would bypass the audit process, in case of claim case review result escalation
            this.populateClaimReviewEscIndicator(component); 
            //This mthod is to merge PFC and KPI values if any , in case of retail
            if(component.get('v.isKpiSectionVisible')){
                this.mergePfcAndKpiValues(component);
            }
            // It would clean up claim id on Clone Claim 
            this.clearUpClaimIdOnClone(component);
            // This method will call server method to save claim
            this.saveClaimResult(component);
        }
    },
    
    isPOPMandatory: function(component){
        var auditdocumentList = component.get("v.auditDocument");
        if(!component.get("v.isClaimEdit") && component.get('v.isPOPMandatory') && 
           auditdocumentList!=null && auditdocumentList.length == 0){
            return true;
        }else{
            return false;
        }
    },
    
    //This function is used to save claim or display error message if claim save fails
    saveClaimResult: function(component){
        var action = component.get("c.saveClaim");
        action.setParams({
            "claim": component.get("v.simpleNewClaim"),
            "auditDocList": component.get("v.auditDocument") //POP
        });
        action.setCallback(this, function (saveResult) {
            if (saveResult.getReturnValue() != null && !saveResult.getReturnValue().startsWith('Exception')) {
                component.set("v.Spinner", false);
                // Success! Prepare a toast UI message
                // Hide error Modal
                var errorToastModal = component.find('errorToast');
                $A.util.addClass(errorToastModal, "slds-hide");
                //changes for EDit claim - start
                var successMessage;
                var successTitle;
                if (component.get("v.isClaimEdit")) {
                    successTitle = $A.get("$Label.c.Core_MDF_SuccessUpdateMsgTitle");
                    successMessage = $A.get("$Label.c.Core_MDF_SuccessUpdateMsg");
                } else {
                    successTitle = $A.get("$Label.c.Core_MDF_SuccessMsgTitle");
                    successMessage = $A.get("$Label.c.Core_MDF_SuccessMsg");
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
                    "recordId": saveResult.getReturnValue()
                });
                navEvt.fire();
                $A.get("e.force:closeQuickAction").fire();
                
                //page reload-only in edit case
                if (component.get("v.isClaimEdit")) {
                    setTimeout(function(){window.location.reload();},2000);
                }
                resultsToast.fire();
                
            }
            else if (saveResult.getState() === "ERROR" || (saveResult.getReturnValue() != null && saveResult.getReturnValue().startsWith('Exception'))) {
                // Call the function to Handle the Server Exceptions
                var error = JSON.stringify(saveResult.getError());
                this.handleServerExceptions(component, saveResult.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //This function is used to show error toast message
    populateErrorToastModal: function(component){
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.isError", true);
        component.set("v.Spinner", false);
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
            else { this.handleServerExceptions(component, a.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },   
    
    //This helper function is used to fetch activity details
    fetchActivityRecord: function (component, event, helper) {
        //Bypass fetch activity details, when we click on save and got any validation error,in case of retail/KPI, 
        //call only once,if KPI loaded
        if(!component.get("v.isKpiLoaded")){   
            var action = component.get("c.getActivityFields");
            var requestId = component.get("v.simpleNewClaim.RequestId");
            
            if (!$A.util.isUndefined(requestId) && !$A.util.isEmpty(requestId)) {
                action.setParams({
                    'activityId': component.get("v.simpleNewClaim.RequestId")
                });
                action.setCallback(this, function (a) {
                    var state = a.getState();
                    if (state === "SUCCESS" && a.getReturnValue() != null) {
						// to set activity values in create claim scree
                        this.setActivityValuesInClaim(a.getReturnValue(),component);
                        // To populate activity lookup on search
                        this.autoPopulateActivity(component);
                        this.fetchBankRecords(component);
                        this.fetchCountryRecords(component);
                        this.assignRecordTypeMetaDataValues(component);
                        //added by Vaishali for owner change to show mapped Claim submitter values of Request's ultimate account
                        this.fetchClaimSubmitters(component);
                        // To copy the Activity Title in claim Title for Retail Claim
                        if(component.get('v.isClaimActivitySwap')){
                            component.set("v.simpleNewClaim.Title", a.getReturnValue().Title);
                        }
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
    },
	
    //This method is used to set activity values
	setActivityValuesInClaim: function(partnerFundRequest,component){
		component.set("v.simpleNewClaim.Core_MDF_Activity_Category__c", partnerFundRequest.Core_MDF_ActivityCategory__c);
		component.set("v.simpleNewClaim.Core_MDF_Activity_Types__c", partnerFundRequest.Core_MDF_Activity_Types__c);
		component.set("v.simpleNewClaim.Core_MDF_Activity_Start_Date__c", partnerFundRequest.Core_MDF_Start_Date__c);
		component.set("v.simpleNewClaim.Core_MDF_Activity_End_Date__c", partnerFundRequest.Core_MDF_End_Date__c);
		component.set("v.simpleNewClaim.Core_MDF_Brand__c", partnerFundRequest.Core_MDF_Brand__c);
		component.set("v.simpleNewClaim.Core_MDF_Target_Audience__c", partnerFundRequest.Core_MDF_TargetAudience__c);
		component.set("v.simpleNewClaim.Core_MDF_Reimbursement_Percent__c", partnerFundRequest.Core_MDF_Reimbursement_Rate__c);
		component.set("v.simpleNewClaim.Core_MDF_Program__c", partnerFundRequest.Core_MDF_Program__c);
        //added by Vaishali for owner change functionality to send this value to server to get its claim submitters
		component.set("v.technicalProgName", partnerFundRequest.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c);//added by VD for owner change
        component.set("v.budgetType", partnerFundRequest.Core_MDF_Budget_Type_txt__c);
        
         if(partnerFundRequest.Core_MDF_Program__c== $A.get("$Label.c.Core_MDF_Retail_Channel_Program_Name")){
             component.set("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c", partnerFundRequest.Core_MDF_Activity_SubType_nm__c);
         }
        component.set("v.simpleNewClaim.LocalizedActivitySubType", partnerFundRequest.LocalizedActivitySubType);
        /*if(!$A.util.isUndefinedOrNull(partnerFundRequest.LocalizedActivitySubType)){
            component.set("v.isActySubTypeFieldRequired",true);
            this.fetchActySubType(component);
        } */this.fetchActySubType(component);       
        component.set("v.simpleNewClaim.Core_MDF_Campaign_Id__c", partnerFundRequest.CampaignId);
		 //IPA
        if(partnerFundRequest.Core_MDF_Program__c== $A.get("$Label.c.Core_MDF_IPA_Program_Name")){
        
        component.set("v.campaignName", partnerFundRequest.Campaign.Name);
        component.set("v.campaignDesc", partnerFundRequest.Campaign.Description);            
        component.set("v.actyPOPDescReq", "true");   
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
		if(!$A.util.isUndefinedOrNull(partnerFundRequest.Core_MDF_Country_nm__c) && !$A.util.isUndefinedOrNull(partnerFundRequest.countryNameLocalized)){
			component.set("v.activityCountriesMap", ({ key:partnerFundRequest.Core_MDF_Country_nm__c, value:partnerFundRequest.countryNameLocalized}));
		}
		var invoiceAmtCmp = component.find('claimInvoiceAmntLocal');
        	
        if(partnerFundRequest.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_Retail_Channel_Program_Name") ||
           partnerFundRequest.Core_MDF_Program__c== $A.get("$Label.c.Core_MDF_IPA_Program_Name"))
		{
			invoiceAmtCmp.set('v.value', partnerFundRequest.RequestedAmount);
			 // Load KPI attributes to display KPI fields to enter value
			this.loadKpiAttributes(component);
		}
		else{
			component.set("v.isCurrDisabled", false);
		}
	},
    
    fetchActySubType: function (component) {
        if(!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.LocalizedActivitySubType"))){
            component.set("v.isActySubTypeFieldRequired",true);
            var actySubTypearray = [];
            var splittedActSubType = component.get("v.simpleNewClaim.LocalizedActivitySubType").split(";");
            for(var index=0;index<splittedActSubType.length;index++){
                actySubTypearray.push({ value: splittedActSubType[index] , 
                                       label: splittedActSubType[index]});
            }
            component.set("v.actySubTypeOptions", actySubTypearray);}
        else{
            component.set("v.isActySubTypeFieldRequired",false);
        }
    } , 
    
    //This method is used to clear activty values, if we clear activity from activity lookup
	resetActivityValuesInClaim: function(component){
        component.set("v.simpleNewClaim.Core_MDF_Activity_Category__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Activity_Types__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Activity_Start_Date__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Activity_End_Date__c", "");
        component.set("v.simpleNewClaim.Core_MDF_Brand__c", "");
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
        component.set('v.spinner', false);
        component.set("v.hideMediaVehicle", false);
        component.set("v.hideBank", false);
        component.set("v.budgetType", "");
        component.set("v.actySubTypeOptions", "");
		component.find('ActSubTypes').unselectList(); 
        //this.uncheckActySubType(component);
	},
    
    //This helper function is used to fetch mapped claim submitters of request's ultimate account
    fetchClaimSubmitters: function (component) {
        //this flag will ensure that it is not getting called if claim submitters are creating claim
        if(!component.get("v.claimSubDisabled"))
        {
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
                for (var i = 0; i < bankList.length; i++) {
                    //Check exisiting bank and mark as defaulted selected
                    if(bankList[i].Core_MDF_Bank__r.Id == component.get("v.simpleNewClaim.Core_MDF_Bank__c")){
                        bankValList.push({ value: bankList[i] , selected:true });
                        component.set("v.isBankMappedWithAcnt",true);
                    }else{
                        bankValList.push({ value: bankList[i] , selected:false });
                    } 
                }
                
                if(bankValList!=null){
                    component.set("v.bankObjectList", bankValList);                       
                }else{
                    //If no bank is mapped with account
                    component.set("v.isBankMappedWithAcnt",false);
                }
                
            } else {
                this.handleServerExceptions(component, a.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    },

       uncheckActySubType :function (component){
        debugger;
        var unselectActySubType =[];
        var ActSubtype = component.get("v.actySubTypeOptions");
        if(!$A.util.isUndefinedOrNull(ActSubtype)){
            for(var index=0;index<ActSubtype.length;index++){
                unselectActySubType.push({ value: ActSubtype[index] , label: ActSubtype[index], selected:false });
            }
        }component.set("v.actySubTypeOptions", unselectActySubType); 
    },

    
        
    
    //This function is used to fetch country pick list from selected activity
    fetchCountryRecords: function (component) {
        //Hold activity country values
        var countryValList = [];
        //Hold activity country splitted values
        var splittedActCountry;
        var splittedLocalActCountry;
        if(!$A.util.isUndefinedOrNull(component.get("v.activityCountriesMap"))){
            //exisiting activity countries
            var activityCountries = component.get("v.activityCountriesMap").key;
            var activityLocalCountries = component.get("v.activityCountriesMap").value;
            //Split multiple country into array
            splittedActCountry = activityCountries.split(";");
            splittedLocalActCountry = activityLocalCountries.split(";");
            for(var index=0;index<splittedActCountry.length;index++){
                //Check exisiting country and mark as defaulted selected
                if((splittedActCountry[index] == component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c"))
                   || (!component.get("v.isClaimEdit") && splittedActCountry.length == 1)){                    
                    countryValList.push({ value: splittedActCountry[index] , label: splittedLocalActCountry[index], selected:true });
                    component.set("v.isClaimCountryAvailInAct",true);
                    //Setting latest country value
                    component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c",splittedActCountry[index]);
                }else{
                    countryValList.push({ value: splittedActCountry[index] , label: splittedLocalActCountry[index],  selected:false });
                }  
            }
            //country list null check
            //if(countryValList!=null){ As part of Major fix,insted of null check we are doing Length check.
            if(countryValList.length > 0){
                component.set("v.countryList", countryValList);   
            }
        }else{
            //If no country fetched from activity
            component.set("v.isClaimCountryAvailInAct",false);
        }
    },
    
    //This helper function is used to autopopulate activity over claim
    autoPopulateActivity: function (component) {
        var activityAuraId;
        if(!$A.util.isUndefinedOrNull(component.get('v.isClaimActivitySwap'))){
            activityAuraId = 'activityIdRetail';
        }else{
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
    closeModel: function (component,docIds) {  // Added docIds for POP
        var homeEvent = $A.get("e.force:navigateToSObject");
        var isPfr = component.get("v.isPfrUrl");
        var isCampaignUrl = component.get("v.isCampaignUrl");
        var objName;
        if (Boolean(isPfr)) {
            homeEvent.setParams({
                "recordId": component.get("v.recordId")
            });
            homeEvent.fire();
        }else if(Boolean(isCampaignUrl)){
        	homeEvent.setParams({
                "recordId": component.get("v.simpleNewClaim.Core_MDF_Campaign_Id__c") 
            });
            homeEvent.fire();
        }else if(!$A.util.isUndefinedOrNull(component.get("v.batchRecordId"))){
            homeEvent.setParams({
                "recordId": component.get("v.batchRecordId")
            });
            homeEvent.fire();            
        } else {            
            if(component.get("v.escalationId")!=null && component.get("v.escalationId")!=''
               && component.get("v.escalationId")!=undefined){
                homeEvent.setParams({
                    "recordId": component.get("v.escalationId")
                });
                homeEvent.fire();
            }else{
                if(!component.get("v.isClaimEdit")){
                    objName = $A.get("$Label.c.Core_MDF_PFCText");
                    var homeEvents = $A.get("e.force:navigateToObjectHome");
                    homeEvents.setParams({
                        "scope": objName
                    });
                    homeEvents.fire();
                }else{
                    homeEvent.setParams({
                        "recordId": component.get("v.simpleNewClaim.Id")
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
        if (urlToLowerCase.includes(pfrText.toLowerCase())) {
            component.set("v.isPfrUrl", true);
        }
        if(urlToLowerCase.includes(campaignText.toLowerCase())){
            component.set("v.isCampaignUrl", true);
        }
    },
    //This helper function is used to fetch bank pick list values
    getDuplicateRecords : function(component){
        var action1 = component.get("c.duplicateClaimCheck");
        action1.setParams({
            'newClaim': component.get("v.simpleNewClaim")
        });
        action1.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null){
                var dupList = a.getReturnValue();	
                
                //If not duplicate record
                if(Object.keys(dupList).length==0){
                    //in case of retail
                    this.navigateToPopAndKpiTab(component);
                }
                
                //if it is duplicate record
                else{
                    component.set("v.Spinner",false);
                    //To set duplicate list size according to duplicate claim size
                    if(Object.keys(dupList).length>$A.get("$Label.c.Core_MDF_DuplicateClaimSize")){
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
    onCloneClaim :function(component){
        //check claim type
        if(($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type"))==(component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c")))
        {
            component.set("v.isClaimNegativeType", true);
            component.set("v.isClaimEditable", false);
        }
        else{
           
            this.fetchClaimDetails(component);
        }
    },
    
    //This method will fetch claim details during clone and edit
    fetchClaimDetails :function(component){
        if (component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c") != '' 
            && component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c") != undefined) 
        {
            component.set("v.activitySearchString", component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c"));
            this.autoPopulateActivity(component);
            component.set("v.bankAccountId", component.get("v.simpleNewClaim.ChannelPartner.Id"));
            this.fetchBankRecords(component);
            this.onEditOrCloneOfClaimShowOrHidevatOptIn(component);
            console.log('selected bank',component.get("v.simpleNewClaim.Core_MDF_Bank__c"));
            console.log('currentoptin',component.get("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c"));
            component.set("v.technicalProgName",component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c"));//added by vaishali for owner change to get claim submitter list
            component.set("v.ultimateAccountId",component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Id"));//added by vaishali for owner change to get claim submitter list
            //added by vaishali // to fetch mapped claim submitter of request's ultimate account
            this.fetchClaimSubmitters(component);
            component.set("v.activityId", component.get("v.simpleNewClaim.RequestId"));
            //hold latest country picklist values from activity, incase of clone and edit
            this.fetchCountryRecords(component);
            //This function used to check for activity lookup to be enabled/disabled, in case on clone/Edit
            this.manageActivityLookup(component);
            //This function used to check for claim submitter lookup to be enabled/disabled, in case on clone/Edit
            this.manageClaimSubmitterLookup(component);
            component.set("v.simpleNewClaim.ChannelPartner", component.get("v.simpleNewClaim.ChannelPartner.Name"));
            if(component.get("v.isClaimEdit") && $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c")) 
               && !$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c"))){
                var claimSubName;
                if(!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Contact.Email")))
                	claimSubName = component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Name") +'-'+ component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Contact.Email");
                else{
                    claimSubName = component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Name") +'-'+ component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__r.Email");
                }
                component.set("v.claimSubSearchString",claimSubName);            
            }
            //Escalation- Set Escalation Id - for clear lookup
            component.set("v.escObjectId",
                          component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c"));
            //Claim to be Audited 
            component.set("v.isClaimAudited",
                          component.get("v.simpleNewClaim.Core_MDF_To_Be_Audited_Ind__c"));
            
            //Set Budget Type
            component.set("v.budgetType", component.get("v.simpleNewClaim.Request.Core_MDF_Budget_Type_txt__c"));            
           
            //This function used to manageClaimFields and hide fields          
            this.manageClaimFields(component);
            this.fetchActySubType(component);
            //IPA
            this.setIPAFields(component);
            
            
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
    fetchMemberPartnerDetails : function (component) {
        var action = component.get("c.fetchUserDetails");       
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) 
            {
                //checking if logged in user's type as power partner and setting flag to true
                if(a.getReturnValue().userInfo!=null && a.getReturnValue().userInfo.UserType != '' && a.getReturnValue().userInfo.UserType == $A.get("$Label.c.Core_MDF_Partner_User_Type")) {
                    component.set("v.isPartner", true);
                }
                //checking user is payment admin
                component.set("v.isUserPaymentAdmin",a.getReturnValue().isUserPaymentAdmin);
                //checking user is retail claim submitter
                component.set("v.isRetailClaimSubmitter",a.getReturnValue().isRetailClaimSubmitter);
                //checking user is CCR or CCRM
                component.set("v.isUserClaimCaseReviewerOrManager",a.getReturnValue().isUserClaimCaseReviewerOrManager);
                //checking user is RMF 
                component.set("v.isUserPRCRMFClaimOperation",a.getReturnValue().isRMFPRCClaimOperation);
                //This function used to check for escalation lookup to be enabled/disabled - on doint
                this.manageEscalationLookup(component);
                //This function used to enable/disable claim submitter lookup
                this.manageClaimSubmitterLookup(component);
                //chekcing user is CCR or CCRM
                if((!(($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type"))==(component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c")))) 
                   && component.get("v.isUserClaimCaseReviewerOrManager")){
                    //onload, removing by default displayed cross icon,If user is CCR or CCRM
                    var escalationLookup = component.find('escalationId');
                    if(escalationLookup!=null && escalationLookup!='' && !$A.util.isUndefinedOrNull(escalationLookup)){
                        escalationLookup.clearLookupPill();
                    }

                    //auto populate escalation in case of edit /clone
                    if (component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__r.Name") != ''
                        && component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__r.Name") != undefined) {
                        component.set("v.escalationNoSearchString", component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__r.Name"));
                        //not in case of edit, just need to set escalation name
                        if(!component.get("v.isClaimEdit")){
                            this.autoPopulateEscalation(component);  
                        }
                    }
                }
                // This method is to set Claim record type on the basis of Activity Record Type
                this.setClaimActivityAttributes(component);
            }
            else { this.handleServerExceptions(component, a.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },
    
    //Claim cannot be edit by member if it is on Intel Hold
    IsUserEligibleToEditClaimOnMembHold : function (component) { 
        var curretMemHoldStatus =  component.get("v.simpleNewClaim.Core_MDF_Intel_Manual_Hold_Ind__c");       
        var isMember = component.get("v.isPartner"); 
        var isMysteryShopperUser = component.get("v.isUserPRCRMFClaimOperation");

        if(curretMemHoldStatus == true && (isMember== true || isMysteryShopperUser==true)){
            return true;
        }else{
            return false;
        }
    },    
    
    // this method checks if user can edit claim depending on claim status, user permissions, type of claim and Activity status
    isClaimEditable: function (component) {
        var auditHoldFlag = component.get("v.simpleNewClaim.Core_MDF_Audit_Hold__c");
        var flaggedForAudit = component.get("v.simpleNewClaim.Core_MDF_FlaggedForAudit__c");
        if(($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type"))==(component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c")))
        {
            component.set("v.isClaimNegativeType", true);
            component.set("v.isClaimEditable", false);
        }
        //if it is a Partner user and it is a Positive Adjustment claim
        else if((component.get("v.isPartner") || component.get("v.isUserPRCRMFClaimOperation")) && component.get("v.simpleNewClaim.Core_MDF_CRR_Positive_Ind__c"))
        {
            component.set("v.isClaimEditable", false);
            component.set("v.restrictCRRClaimEdit", true);
        }
        else{
            // To ensure that claim with Closed activity OR escalation cannot be edited by any other user except CCR/CCM
            if(!component.get("v.isUserClaimCaseReviewerOrManager") && (component.get("v.simpleNewClaim.Request.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_Claim_Activity_Closed_Status")
                                                                        || component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c") != null)){
                component.set("v.isClaimEditable", false);
                
            }else{
                if (component.get("v.simpleNewClaim.Core_MDF_Status__c") != ''
                    && component.get("v.simpleNewClaim.Core_MDF_Status__c") != undefined) {
                    var claimStatus = ($A.get("$Label.c.Core_MDF_EditClaimStatusValues")).split(";");
                    if (claimStatus.includes(component.get("v.simpleNewClaim.Core_MDF_Status__c"))) 
                    {  
                        // function to check if payment admin & can edit claim
                        if(component.get("v.isUserPaymentAdmin"))
                        {
                            this.isPaymentAdminEligibletoEdit(component);
                        } 
                        else{
                            if(Boolean(flaggedForAudit))
                            {
                                component.set("v.StrightToPayDisabled", true); //If flagForAudit=true, disable STP required for WW50 Release
                                if(component.get("v.isAuditUser") && Boolean(auditHoldFlag)){
                                    component.set("v.isClaimEditable", true);
                                }else{
                                    component.set("v.isClaimEditable", false);
                                }
                            }
                            else if(this.IsUserEligibleToEditClaimOnMembHold(component)){
                                component.set("v.isClaimEditable", false);
                            } else{
                                component.set("v.isClaimEditable", true);
                            }
                        }                            
                    } else {
                        component.set("v.isClaimEditable", false);
                    }
                } else {
                    component.set("v.isClaimEditable", false);
                } 
            } 
        }
        if (component.get("v.Spinner")) {
            //Spinner starts
            component.set("v.Spinner", false);
        }
    },
    
    // This function is called from doInit and used when create claim from activity record
    getActivityDtlsByRecordId: function (component) {
        var action = component.get("c.checkClaimFromActivity");
        action.setParams({
            objectName: "PartnerFundClaim",
            activityId: component.get('v.recordId')
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
                        component.set("v.simpleNewClaim.RequestId", result.activityObj.Id);
                        component.set("v.activityRecordTypeDevName", result.activityObj.RecordType.DeveloperName);                      
                        component.set("v.sObjectId", result.activityObj.Id);
                        
                        //lookup cmp will visible ,only if user is CCR/CCRM
                        if(component.get('v.isUserClaimCaseReviewerOrManager')){
                            var escalationLookup = component.find('escalationId');
                            escalationLookup.clearLookupPill();
                        }
                    } else {
                        if(!result.checkCreate){
                            // show error if no permission
                            component.set("v.claimFromActivityErrorMsg",$A.get("$Label.c.Core_MDF_NoClaimCreatePermissionText"));
                        }else{
                            // show error for invalid activity status
                            component.set("v.claimFromActivityErrorMsg",$A.get("$Label.c.Core_MDF_NoClaimCreateOnInvalidStatus"));
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
    
    handleServerExceptions: function(component, returnValue) {
        
        // Error! Show Validation message through a toast UI message
        // Show error Modal
        var errorToastModal = component.find('errorToast');
        $A.util.removeClass(errorToastModal, "slds-hide");
        component.set("v.isError", true);
        component.set("v.Spinner", false);
        var exceptionerrors = returnValue;
        
        // check if exceptionerrors is null or not
        if (exceptionerrors != null && exceptionerrors.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
            // process the error message here
            // if its validation error message
            var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 1);
            var err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
            var errorMsg = err.substring(err.lastIndexOf(',') + 1);
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
            else { this.handleServerExceptions(component, a.getReturnValue()); }
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
        component.set("v.countryList",listOfCountry);
        //Clear bank list
        var listOfbank = component.get("v.bankObjectList");        
        listOfbank.splice(0, listOfbank.length);            
        component.set("v.bankObjectList",listOfbank);
    },
    
    //check if payment admin has edit access
    isPaymentAdminEligibletoEdit: function (component) {
        // To disable POP for Payment Admin 
        component.set("v.isPOPEnabled", false);
        // If Claim is on PAF, PD allow Edit. If Claim on Hold but not Audit Hold, allow Edit.
        if(!component.get("v.simpleNewClaim.Core_MDF_Audit_Hold__c")){
            component.set("v.isClaimEditable", true);
            component.set("v.isEditDisabled", true);
        } else{
            component.set("v.isClaimEditable", false);
        }
    },
    
    
    
     //This helper function is used to manageClaimFields
    manageClaimFields: function (component) {
        var auraIds = [];
         //Find currency field
         var currCmp = component.find('claimCurrency');
        if(!$A.util.isUndefinedOrNull(component.get('v.recordtypeDeveloperName')) && component.get('v.recordtypeDeveloperName')!='' 
           && !component.get("v.isClaimNegativeType")){
            switch(component.get('v.recordtypeDeveloperName').toUpperCase())
            {
                case $A.get("$Label.c.Core_MDF_RetailProgram").toUpperCase():
                    currCmp.set('v.value', $A.get("$Label.c.Core_MDF_PFR_Output_Currency"));                   
                    component.set("v.isCurrDisabled", true);
                    if(component.get('v.budgetType') == $A.get("$Label.c.Core_MDF_Retail_RSA_MD_Budget_Type")){ 
                         auraIds = $A.get("$Label.c.Core_MDF_Hide_RSA_MD_Ids").split(",");			
                    }
                    else{
                        auraIds = $A.get("$Label.c.Core_MDF_Hide_RMF_MDF_Ids").split(",");		
                    }
                    break;
                case $A.get("$Label.c.Core_MDF_IPA_RecordType").toUpperCase():                                                          
                    component.set("v.isIPAFieldRequired",false);  // *manditory field
                    // Create claim : should be default to USD, Clone claim:should pick up from cloning claim Currency, Edit claim : currency Should come as is later user can change 
                    if(!(component.get("v.isClaimEditable")|| component.get("v.isCloneClaim"))){         
                        component.find('claimCurrency').set('v.value', $A.get("$Label.c.Core_MDF_PFR_Output_Currency"));}                
                    auraIds = $A.get("$Label.c.Core_MDF_Hide_IPA_Ids").split(",");
                    break;
                    
                default: //auraIds = $A.get("$Label.c.Core_MDF_Hide_CCF_DCF_SPCF_Boost").split(",");
                    if($A.get("$Label.c.Core_MDF_Claim_CCF_Program").toUpperCase() || $A.get("$Label.c.Core_MDF_Claim_DCF_Program").toUpperCase()){
                       	auraIds = $A.get("$Label.c.Core_MDF_Hide_CCF_Ids").split(",");
                       }else {auraIds = $A.get("$Label.c.Core_MDF_Hide_SPCF_Boost").split(",");}  
					   
            }       
   		 }
			//hide Fields    
			var auraIdsLength = auraIds.length;
            for (var index = 0; index < auraIdsLength ; index++) 
            {	
                var inputCmp = component.find(auraIds[index]);
                if (inputCmp!=null && inputCmp!=''){
                    $A.util.addClass(inputCmp, 'slds-hide');
                }
            }		
    },
    

    
    //set Data for CampaignId,CampaignName,CampaignDescription and POPDescription
    setIPAFields : function(component){ 
        if(component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Program_Name")){            
            component.set("v.campaignName", component.get("v.simpleNewClaim.Request.Campaign.Name"));
            component.set("v.campaignDesc", component.get("v.simpleNewClaim.Request.Campaign.Description"));
            component.set("v.actyPOPDescReq", "true");  
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
        if(!$A.util.isUndefinedOrNull(component.get("v.escalationRecordType")) 
           && component.get("v.escalationRecordType") !='' &&
           component.get("v.escalationRecordType") == $A.get("$Label.c.Core_MDF_ClaimCaseReviewResult_RecordType")){
            component.set("v.simpleNewClaim.Core_MDF_IsClaimReviewEscalation_Ind__c",true);
        } 
    },
    
    //populate POP and claim swap flag from metadata, set claim record type if not exists
    populatePopAndClaimActSwapFlag: function (component) {
        var recordTypesMap = component.get('v.recordTypeMap');
        if(!$A.util.isUndefinedOrNull(recordTypesMap) 
           && Object.keys(recordTypesMap).length >0){ 
            for (let claimRecType of Object.keys(recordTypesMap)) {
                if(recordTypesMap.hasOwnProperty (claimRecType) && 
                   recordTypesMap[claimRecType].Core_MDF_Activity_RecordType_txt__c
                   == component.get('v.activityRecordTypeDevName')){
                    component.set('v.isPOPMandatory',recordTypesMap[claimRecType].Core_MDF_POP_Mandatory_Ind__c);
                    component.set('v.isClaimActivitySwap',recordTypesMap[claimRecType].Core_MDF_Claim_Activity_Name_Swap_Ind__c);                    
                    // To populate recordtypeDeveloperName in case of Create Claim from Escalation and Activity
                    if(component.get('v.recordtypeDeveloperName') == '' || $A.util.isUndefinedOrNull(component.get('v.recordtypeDeveloperName'))){
                        component.set('v.recordtypeDeveloperName',claimRecType);
                    }
                }
            }
        }
    },
    
   //This helper function is used to load KPI attributes
    loadKpiAttributes: function(component){
        
        if (!component.get("v.Spinner")) {
            //Spinner starts
            component.set("v.Spinner", true);
        }
        component.set("v.isKpiLoaded",true);  
        //load and display KPI attributes  corresponding to claim
        var kpiComponent = component.find('kpiDetail');
        if (kpiComponent != null){
            var inputParams = {};
            inputParams.enableKPI = true;
            inputParams.recordId = component.get('v.clonedClaimId');
            inputParams.objName = 'PartnerFundClaim';
            inputParams.activityCategory = component.get("v.simpleNewClaim.Core_MDF_Activity_Category__c");
            inputParams.activityType = component.get("v.simpleNewClaim.Core_MDF_Activity_Types__c");
            inputParams.program = component.get("v.simpleNewClaim.Core_MDF_Program__c");
            inputParams.title = $A.get("$Label.c.Core_MDF_ActualKPILabel");     
            inputParams.activitySubType = component.get("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c");
            kpiComponent.loadKPIAttributes(inputParams);       
        }else{
            component.set("v.Spinner", false);
        }
    },
    
    
    //This helper function is used to merge PFC and KPI values
    mergePfcAndKpiValues: function(component){
        var kpiComp = component.find('kpiDetail');
        if (kpiComp != null){
            var kpiValues = kpiComp.getKPIValues();
            if (kpiValues != null){
                var pfcmain = component.get("v.simpleNewClaim");                
                //Setting temp claim ID in pfcmain object and clearing the same after merge
                pfcmain["Id"] = component.get('v.clonedClaimId');                
                //merging pfc and KPI values, if any
                var mergedObj = Object.assign({},pfcmain, kpiValues);
                component.set("v.simpleNewClaim",mergedObj);
            } 
        }
    },
    
    //This helper function is used to validate KPI fields/check is KPI fields valid or not
    validateKPIFields: function(component){
        window.setTimeout($A.getCallback(function () {
            var kpiComponent = component.find('kpiDetail');
            var kpiReadOnlyComponent = component.find('claimkpiread');
            //check KPI values are valid, if yes go to POP page else KPI section 
            if ((kpiReadOnlyComponent != null) || (kpiComponent != null && kpiComponent.isFormValid())){
                component.set("v.currentStep", "3");
            }
            
            else{
                component.set("v.currentStep", "2");
            }
        }), 1000);
    }, 
    
    //This helper function is uaed to navigate to POP and KPI tab, on click of duplicate OK button and click on Tab
    navigateToPopAndKpiTab: function(component){
        //If we click on POP tab
        if(component.get("v.moveToThirdPage")){
            component.set("v.currentStep", "3"); 
        }else if(component.get('v.isKpiSectionVisible')){
            component.set("v.currentStep", "2");
        }else{
            //In case there are only 2 tabs and if we click on next button of tab 1
            component.set("v.currentStep", "3"); 
        }
    },
    
    /**This helper function is used for Claim manditory fields & duplicate claim validation
     * with navigation to next tab
     **/
    navigationOnNextButton: function(component){
        component.set("v.moveToThirdPage",false);
        //on click on next button [Claim form fields tab]
        if(component.get("v.currentStep")=="1"){
            if(this.validateClaimForm(component)){  
                //calling of validateClaimSubmitterLookup method done by vaishali 
                //to validate claim submitter value is not blank before moving to next button
                if(!this.validateClaimSubmitterLookup(component) && !this.validateVatOptIn(component)){
                    this.getDuplicateRecords(component);
                }              
            }
            else{
                //if valid claim form fails
                component.set("v.currentStep", "1");
            }            
        }
        //on click of tab 2 [KPI section]
        else if(component.get("v.currentStep")=="3"){
            component.set("v.currentStep", "2");
        }
       
    },
    
    validateVatOptIn : function(component) {
       var isOptInFieldBlank = false;
        if(component.get("v.vatOptInPicklistVisible") && 
           component.get("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c")== ""){    
            isOptInFieldBlank = true;
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: $A.get("$Label.c.Core_MDF_VatOptInMandatoryMessage"),
                type: "error"
            });
            toastEvent.fire();
        }
        return isOptInFieldBlank;    
    },
    
    //added by Vaishali to validate claim submitter value is not blank
    validateClaimSubmitterLookup : function(component){
        var isClaimSubValueBlank = false;
        if(component.get("v.isUserClaimCaseReviewerOrManager") && 
           (component.get("v.claimSubValue") == '' || $A.util.isUndefinedOrNull(component.get("v.claimSubValue") )) 
           && !(component.get("v.isClaimEdit")) &&
           !component.get("v.claimSubDisabled")){    
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
    navigateToPreviousTab: function(component){
        // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "2"){
            component.set("v.currentStep", "1");
        }else{
            //If KPI availble , goto KPI(second) page
            component.set("v.moveToThirdPage",false);
            if(component.get("v.isKpiSectionVisible")){
                component.set("v.currentStep", "2"); 
            }else{
                //move to first page
                component.set("v.currentStep", "1");
            }
        }
    },
    // This helper function clears the RequestId and escalationId on change of Activity LookUp
    clearLookupField: function(component,event){
        //Escalation check
        if((event.getParam("instanceId"))== 'escalationId'){
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",'');
            component.set("v.escalationNoSearchString",'');
            this.manageClaimSubmitterLookup(component);
        }
        else if((event.getParam("instanceId"))== 'claimownerId'){
            //added by vaishali to clean up claim submitter lookup field
            component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c",'');
            component.set("v.claimSubSearchString",''); 
            component.set("v.claimSubValue",'');
        }        
        else{
            this.clearActivityLookUpFields(component,event);
        }
    },
    // This method is to clean up the activity related fields during lookup clean
    clearActivityLookUpFields: function(component,event){
        //KPI flag to false on clear activity
        component.set("v.isKpiLoaded",false);
        //set flag to false on clear activity
        component.set("v.isKpiSectionVisible",false);
        //Clear pick list values, country and request ID , on activity clear lookup
        component.set("v.simpleNewClaim.RequestId",'');
        component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c",'');
        component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c",'');//added by vaishali to clean up claim submitter id when clearing up the lookup
        component.set("v.claimSubValue",'');
        this.clearPicklistValues(component);
        //lookup cmp will visible ,only if user is CCR/CCRM
        //It will clear lookup and escalation Id
        if(component.get('v.isUserClaimCaseReviewerOrManager')){
            this.clearEscLookupWithEscId(component);
            //It will clear lookup and claim submitter Id
            this.clearClaimSubLookup(component);
        }
        var bankComponent = component.find('claimBankDiv');
        if (!$A.util.isUndefinedOrNull(bankComponent)){
                $A.util.removeClass(bankComponent, "slds-hide");
        }        
        component.set("v.vatOptInPicklistVisible",false);
        component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c","");
    },
    // This helper function sets the RequestId and escalationId on change of Activity LookUp
    updateLookupField: function(component,event){
        var recordId = event.getParam("sObjectId");
        //Escalation check
        if((event.getParam("instanceId"))== 'escalationId'){
            component.set("v.escObjectId",recordId);  
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",recordId);
        }
        else if((event.getParam("instanceId"))== 'claimownerId'){
            //to store claim submitter lookup value in claim submitter field on claim //added by vaishali
            component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c",recordId);
            component.set("v.claimSubValue",recordId);
        }
        else{
            component.set("v.sObjectId",recordId); 
            component.set("v.simpleNewClaim.RequestId",recordId);
            
            if(component.get('v.isUserClaimCaseReviewerOrManager')){
                var escalationLookup = component.find('escalationId');
                if(!$A.util.isUndefined(escalationLookup)){
                    escalationLookup.clearLookupPill();
                }
            }
        }
    },
    //This helper function is used to clear claim submitter lookup and claim submitter id
    clearClaimSubLookup: function(component){
        var claimSubLookup = component.find('claimownerId');
        //clear lookup pill only if claim submitter lookup is editable 
        if(!$A.util.isUndefinedOrNull(claimSubLookup) && !$A.util.isUndefined(claimSubLookup)){
            //clear claim submitter lookup
            if(claimSubLookup.clearLookupPill){
                claimSubLookup.clearLookupPill();
            }            
        }
        // To clear the claim submitter id Value on clearing Activity Lookup
        if(!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c"))){
            component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c",'');
        }
        // To clear the claim submitter text value
        if(!$A.util.isUndefinedOrNull(component.get("v.claimSubSearchString"))){
            component.set("v.claimSubSearchString",'');
        }       
    },
    
    //This helper function is used to clear escalation lookup and escalation id
    clearEscLookupWithEscId: function(component){
        var escalationLookup = component.find('escalationId');
        //clear lookup pill only if escalation lookup is editable 
        if(!$A.util.isUndefinedOrNull(escalationLookup) && !$A.util.isUndefined(escalationLookup)){
            //clear escalation lookup
            if(escalationLookup.clearLookupPill){
                escalationLookup.clearLookupPill();
            }            
        }
        // To clear the escalation id Value on clearing Activity Lookup
        if(!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c"))){
            component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",'');
        }
        // To clear the escalation text value
        if(!$A.util.isUndefinedOrNull(component.get("v.escalationNoSearchString"))){
            component.set("v.escalationNoSearchString",'');
            //to enable disable claim submitter value based on escalation
            this.manageClaimSubmitterLookup(component);
        }
    },
    
    //Custom logic to load KPI after default renderer function on Claim Clone and Edit
    loadKPIAttributesOnCloneAndEdit: function(component){
       if(((component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_Retail_Channel_Program_Name")) ||
           (component.get("v.simpleNewClaim.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Technical_program_name")))
          && (component.get("v.isCloneClaim") || component.get("v.isClaimEdit"))){
            // helper function to load KPI attributes
            this.loadKpiAttributes(component);
        }
	},
    
    //This helper function is used to navigate on tab click
    navigationOverTab : function(component,event,helper){
        //focused tab value
        var stepValue = event.getSource().get("v.value");
        if(stepValue=="1"){
            component.set("v.currentStep", "1");
            //POP page
            component.set("v.moveToThirdPage",false);
        }else if(stepValue=="2" || stepValue=="3"){
            //If we clicked on KPI tab
            if(stepValue=="2"){
                component.set("v.moveToThirdPage",false);
                //on click of tab 2 [KPI section]
                if(component.get("v.currentStep")=="3"){
                    component.set("v.currentStep", "2");
                }
            }else{
                //If we clicked on POP tab
                component.set("v.moveToThirdPage",true);
                // validate KPI fields using validForm attribute
                if(component.get("v.currentStep")=="2"){
                    //click on KPI page next button
                    this.validateKPIFields(component);
                } 
            }
            
            //If opened tab is claim form and we clicked on KPI/POP tab
            if(component.get("v.currentStep")=="1"){
                if(this.validateClaimForm(component)){  
                    //calling of validateClaimSubmitterLookup method done by vaishali 
                    //to validate claim submitter value is not blank before moving to next button
                    if(!this.validateClaimSubmitterLookup(component) && !this.validateVatOptIn(component)){
                        this.getDuplicateRecords(component);
                    } 
                }
                else{
                    //if valid claim form fails
                    component.set("v.currentStep", "1");
                }
            }
        }
    },
    
    //This helper function is used to move to next tab
    navigateToNextTab: function(component,event,helper){
        //current step
        var getCurrentStep = component.get("v.currentStep");
        if(getCurrentStep == "1"){
            //Navigate to KPI/POP page on click of claim form next button
            this.navigationOnNextButton(component);
        }else{
            //Navigate to POP page  on click of KPI section next button  
            this.validateKPIFields(component);
        }
    },
    
    //This function used to check for escalation lookup to be enabled/disabled
    manageEscalationLookup: function (component) {
        if((component.get("v.isRetailClaimSubmitter") || component.get("v.isUserPRCRMFClaimOperation")) && component.get("v.escalationId")!='' 
           && !$A.util.isUndefinedOrNull(component.get("v.escalationId"))){
            //escalation lookup will be disabled , if retail claim submiter is trying to create claim from escalation
            component.set("v.escalationDisabled",true);  
        }else if(component.get("v.isUserClaimCaseReviewerOrManager")){
            if(component.get("v.isClaimEdit") || $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.RequestId"))
              || component.get("v.simpleNewClaim.RequestId") == ''){
                //escalation lookup will be disabled in case of edit or if activity is not selected
                component.set("v.escalationDisabled",true);
            }else{
                //escalation lookup will be enabled in case of clone or if activity is selected
                component.set("v.escalationDisabled",false); 
            }
        }
    },

    //This function used to check for claim submitter lookup to be enabled/disabled
    //added by vd for owner change
    manageClaimSubmitterLookup: function (component) {
        var isEscPopulated;
        if($A.util.isUndefinedOrNull(component.get("v.escalationNoSearchString")) || component.get("v.escalationNoSearchString") == ''){
            isEscPopulated = false;
        }
        else{
            isEscPopulated = true;
        }
        if(component.get("v.isUserClaimCaseReviewerOrManager") && 
        (component.get("v.isClaimEdit") || component.get("v.simpleNewClaim.RequestId") == ''
        || $A.util.isUndefinedOrNull(component.get("v.simpleNewClaim.RequestId")) ||
        Boolean(isEscPopulated)))
        {
            component.set("v.claimSubDisabled", true);
            if(Boolean(isEscPopulated)){
                component.set("v.claimSubSearchString",'');
                if(!$A.util.isUndefinedOrNull(component.get("v.escalationClaimSubmitter"))){
                	component.set("v.simpleNewClaim.Core_MDF_Claim_Submitter_Id__c",component.get("v.escalationClaimSubmitter"));
                }
            }
        }
        else{
            component.set("v.claimSubDisabled",false);
        }
        
    },
    
    /**This function used to disable activity lookup in case of edit claim, clone claim and
     if retail claim submitter create claim from late claim escalation**/
    manageActivityLookup: function (component) {
        if(!component.get("v.activityDisabled") 
           && (component.get("v.isClaimEdit") || component.get("v.isCloneClaim") ||
               ((component.get("v.isRetailClaimSubmitter") || component.get("v.isUserPRCRMFClaimOperation")) && component.get("v.escalationId")!=''
                && !$A.util.isUndefinedOrNull(component.get("v.escalationId"))))){
            component.set("v.activityDisabled", true);
        }
    },
    
    // Show or Hide Vat Opt In field for selected Bank's legal entity(Edit/Clone) or when its changed
    showOrHideVatOptIn: function(component){
        // On Changing Bank Clear Off the Vat Opt In picklist Value
        component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c","");
        var bankObjectList = component.get("v.bankObjectList");
        var legalEntity;
        var bankId = component.get("v.simpleNewClaim.Core_MDF_Bank__c");
        for(var index =0; index < bankObjectList.length; index++){
            if(bankObjectList[index].value.Core_MDF_Bank__r.Id == bankId){
                legalEntity = bankObjectList[index].value.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c;
                break;
            }
        }
        var program = component.get("v.technicalProgName");
        var action = component.get("c.ckeckProgramLEForVatOptIn");
        action.setParams({
            'legalEntity': legalEntity,
            'channelProgram': program
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null){
                var res = response.getReturnValue();
                if(Boolean(res)){
                    
                    // To Show Picklist field When reponse value is true
                    component.set('v.vatOptInPicklistVisible',true);
                }
                else{
                    // Hide the Picklist field When Response is coming false; by default Set Picklist value as Yes
                    component.set('v.vatOptInPicklistVisible',false);
                    component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c",$A.get("$Label.c.Core_MDF_NonTranslateYes"));                    
                }
            }
            else if(state === "SUCCESS" && response.getReturnValue() == null){
                // If Response is null Hide the Picklist field and nullify Core_MDF_VAT_Opt_In__c
                component.set('v.vatOptInPicklistVisible',false);
                component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c","");
            }
            else { this.handleServerExceptions(component, response.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },

    
    // On Click of Edit of Claim - Show selected previous value of vat Opt In 
    // Or render Picklist field based on the legal Entity and Program
    onEditOrCloneOfClaimShowOrHidevatOptIn: function(component){
        
        if(component.get("v.isCloneClaim")){
            component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c","");
        }   
        var	legalEntity = component.get("v.simpleNewClaim.Core_MDF_Bank__r.Core_MDF_Intel_Company_Code__c");
        var channelProgram = component.get("v.simpleNewClaim.Request.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c"); 
        var action = component.get("c.ckeckProgramLEForVatOptIn");
        action.setParams({
            'legalEntity': legalEntity,
            'channelProgram': channelProgram
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null){
                var res = response.getReturnValue();
                if(Boolean(res)){
                    // To Show Picklist field When reponse value is true it wont override we are not setting the value only hide and show.
                    component.set('v.vatOptInPicklistVisible',true);
                }
                else{
                    // Hide the Picklist field When Response is coming false; by default Set Picklist value as Yes
                    component.set('v.vatOptInPicklistVisible',false);
                    component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c",$A.get("$Label.c.Core_MDF_NonTranslateYes"));                    
                }
            }
            else if(state === "SUCCESS" && response.getReturnValue() == null){
                // If Response is null Hide the Picklist field and nullify Core_MDF_VAT_Opt_In__c
                component.set('v.vatOptInPicklistVisible',false);
                component.set("v.simpleNewClaim.Core_MDF_VAT_Opt_In__c","");
            }
            else { this.handleServerExceptions(component, response.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },
    
    showOrHideclaimMediaVehicle : function(component){
        var action = component.get("c.fetchRecordTypeMetaData"); // fetchMediaVehicalMetaData
        action.setCallback(this, function (a) {           
            if (a.getState() === "SUCCESS" && a.getReturnValue() != null) {
                var res = true; //response.getReturnValue();
                if(Boolean(res)){
                  $A.util.addClass(component.find('claimMediaVehicleDiv'), "slds-hide");                    
                }
            }
            else { this.handleServerExceptions(component, a.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },
})