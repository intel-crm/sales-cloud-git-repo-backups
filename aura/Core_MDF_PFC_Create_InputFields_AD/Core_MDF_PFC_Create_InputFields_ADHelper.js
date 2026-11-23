({
    //This helper function is used to fetch activity details
    fetchActivityRecord: function (component, event, helper) {
        var action = component.get("c.getActivityFields");
        var requestId = component.get("v.simpleNewClaim.RequestId");
        
        if (!$A.util.isUndefined(requestId) && !$A.util.isEmpty(requestId)) {
            action.setParams({
                'activityId': component.get("v.simpleNewClaim.RequestId")
            });
            action.setCallback(this, function (a) {
                var state = a.getState();
                if (state === "SUCCESS" && a.getReturnValue() != null) {
                    component.set("v.simpleNewClaim.Core_MDF_Activity_Category__c", a.getReturnValue().Core_MDF_ActivityCategory__c);
                    component.set("v.simpleNewClaim.Core_MDF_Activity_Types__c", a.getReturnValue().Core_MDF_Activity_Types__c);
                    component.set("v.simpleNewClaim.Core_MDF_Activity_Start_Date__c", a.getReturnValue().Core_MDF_Start_Date__c);
                    component.set("v.simpleNewClaim.Core_MDF_Activity_End_Date__c", a.getReturnValue().Core_MDF_End_Date__c);
                    component.set("v.simpleNewClaim.Core_MDF_Brand__c", a.getReturnValue().Core_MDF_Brand__c);
                    component.set("v.simpleNewClaim.Core_MDF_Target_Audience__c", a.getReturnValue().Core_MDF_TargetAudience__c);
                    component.set("v.simpleNewClaim.Core_MDF_Reimbursement_Percent__c", a.getReturnValue().Core_MDF_Reimbursement_Rate__c);
                    if (a.getReturnValue().ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r != null) {
                        component.set("v.simpleNewClaim.Core_MDF_AccountCompany__c", a.getReturnValue().ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__r.Name);
                    }
                    component.set("v.simpleNewClaim.ChannelPartner", a.getReturnValue().ChannelPartner.Name);
                    component.set("v.bankAccountId", a.getReturnValue().ChannelPartner.Id);
                    component.set("v.activityRecordTypeDevName", a.getReturnValue().RecordType.DeveloperName);
                    component.set("v.activitySearchString", a.getReturnValue().Core_MDF_Activity_Number__c);      
                    //Multiple country picklist values of activity
                    component.set("v.activityCountries", a.getReturnValue().Core_MDF_Country_nm__c);	
                    this.autoPopulateActivity(component);
                    this.fetchBankRecords(component);
                    this.fetchCountryRecords(component);                    
                }
                else {
                     this.displayErrorMessageEvent(component,event, a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        else {
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
            
            component.set("v.simpleNewClaim.Core_MDF_Bank__c", "");
            component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c", "");
        }
    },
    
    //This helper function is used to autopopulate activity over claim
    autoPopulateActivity: function (component) {
        var activitySearch = component.get('v.activitySearchString');
        if (activitySearch != '' & !$A.util.isUndefinedOrNull(activitySearch)) {
            var activityLookup = component.find('activityId');
            activityLookup.select2();
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
                 this.displayErrorMessageEvent(component,event, a.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    },
    
    //This function is used to fetch country pick list from selected activity
    fetchCountryRecords: function (component) {
        //Hold activity country values
        var countryValList = [];
        //Hold activity country splitted values
        var splittedActCountry;
        if(!$A.util.isUndefinedOrNull(component.get("v.activityCountries"))){
            //exisiting activity countries
            var activityCountries = component.get("v.activityCountries");
            //Split multiple country into array
            splittedActCountry = activityCountries.split(";");
            for(var i=0;i<splittedActCountry.length;i++){
                //Check exisiting country and mark as defaulted selected
                if((splittedActCountry[i] == component.get("v.simpleNewClaim.Core_MDF_Country_Location_nm__c"))
                   || (!component.get("v.isClaimEdit") && splittedActCountry.length == 1)){                    
                    countryValList.push({ value: splittedActCountry[i] , selected:true });
                    component.set("v.isClaimCountryAvailInAct",true);
                    //Setting latest country value
                    component.set("v.simpleNewClaim.Core_MDF_Country_Location_nm__c",splittedActCountry[i]);
                }else{
                    countryValList.push({ value: splittedActCountry[i] , selected:false });
                }  
            }
            //country list null check
            if(countryValList!=null){
                component.set("v.countryList", countryValList);   
            }
        }else{
            //If no country fetched from activity
            component.set("v.isClaimCountryAvailInAct",false);
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
    
    
    //This helper function is used to validate claim form
    validateClaimForm: function (component) {
        // Show error messages if required fields are blank
        var validClaim = true;
        var auraIds = ["claimTitle", "claimActStartDate", "claimActEndDate", "claimMediaVehicle",
                       "claimBank", "claimInvoiceNo", "claimInvoiceDate", "claimCurrency", "claimInvoiceAmntLocal"
                       , "claimOtherCostsNotReimbursableLocal", "claimTaxesLocal", "claimComments","ActCountryLocation"];
        
        if((component.get('v.recordtypeDeveloperName') == $A.get("$Label.c.Core_MDF_Claim_SPCF_Program")) || (component.get('v.activityRecordTypeDevName') == $A.get("$Label.c.Core_MDF_PFR_SPCF"))){
            auraIds.push("claimNoOfImpressions");
            auraIds.push("claimNoOfEngagements");
            auraIds.push("claimNoOfLeads");
            auraIds.push("claimNoOfTrialActivations");
        }
        
        for (var i = 0; i < auraIds.length; i++) {
            if (auraIds[i] != "activityId") {
                var inputCmp = component.find(auraIds[i]);
                var inputCmpValidity = inputCmp.get("v.validity").valid;
                if (inputCmpValidity == false) {
                    inputCmp.showHelpMessageIfInvalid();
                    validClaim = false;
                }
            } else {
                var activityCmp = component.find("activityId");
                if (activityCmp.get("v.value") == '') {
                    validClaim = false;
                    alert($A.get("$Label.c.Core_MDF_ActivityErrorMsg"));
                }
            }
        }
        
        if(validClaim){
            //Check duplicate claim
            this.getDuplicateRecords(component);
        }else{
            component.set("v.currentStep", "1");
        }
        return validClaim; 
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
                //checking user is CCR or CCRM
                component.set("v.isUserClaimCaseReviewerOrManager",a.getReturnValue().isUserClaimCaseReviewerOrManager);
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
                this.setClaimActivityAttributes(component);
            }
            else {  this.displayErrorMessageEvent(component,event, a.getReturnValue());}
        });
        $A.enqueueAction(action);
    },
    
    // This method is to set Claim record type on the basis of Activity Record Type
    setClaimActivityAttributes: function (component) {
        // To get the activity status to create claim
        var activityStatusToCreateClaim = ($A.get("$Label.c.Core_MDF_PFR_Status_CreateClaim")).split(";");
        
        // Closed activity should be available in look up in case if Claim case reveiwer or Manager creates claim
        if(component.get("v.isUserClaimCaseReviewerOrManager")){
            activityStatusToCreateClaim = activityStatusToCreateClaim.concat($A.get("$Label.c.Core_MDF_Claim_Activity_Closed_Status"));
        }
        
        component.set('v.activityStatusList', activityStatusToCreateClaim);
        var activityStatusCommaSeparated = "'" + activityStatusToCreateClaim.join("','") + "'";
        component.set('v.activityStatusCommaSeparated', activityStatusCommaSeparated);
        if (component.get("v.activityRecId") != '' && component.get("v.activityRecId") != undefined) {
            //fetch Activity from Escalation
            var escActId = 	component.get("v.escActivityId");
            var escalationId = component.get("v.escalationId");
            if(escActId !='' && escActId != undefined && escalationId!='' && escalationId !=undefined){
                //Function calls in case, claim create from Escalation
                component.set("v.simpleNewClaim.RequestId",escActId);
                component.set("v.simpleNewClaim.Core_MDF_Escalation_Id__c",escalationId);
                //used in case of clear lookup
                component.set("v.escObjectId",escalationId);
                component.set("v.sObjectId", escActId);
            }
            else{
                //Function calls in case, claim create from activity
                this.getActivityDtlsByRecordId(component);
            }
        } else {
            //Checking for record type
            if(!$A.util.isUndefinedOrNull(component.get("v.simpleNewClaim").RecordType)){
                //to hold claim record type developer name
                var claimRecordType = component.get("v.simpleNewClaim").RecordType.DeveloperName;
                //Setting selected claim record type
                component.set('v.recordtypeDeveloperName',claimRecordType);
            }
            //This is to fetch record type meta data map and set activity record type developer name
            this.fetchRecordTypeMetaData(component);
        }
        var searchCriteria = 'Core_MDF_Fund_Request_Status__c IN (' + activityStatusCommaSeparated + ')';
        component.set('v.activitySearchCriteria', searchCriteria);
    },
    // This function is called from doInit and used when create claim from activity record
    getActivityDtlsByRecordId: function (component) {
        var action = component.get("c.checkClaimFromActivity");
        action.setParams({
            objectName: "PartnerFundClaim",
            activityId: component.get('v.activityRecId')
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS" && response.getReturnValue() != null) {
                var result = response.getReturnValue();
                if (!$A.util.isUndefinedOrNull(result)) {
                    component.set("v.createClaimWrapper", result);
                    if ((component.get('v.activityStatusList').includes(result.activityObj.Core_MDF_Fund_Request_Status__c)) &&
                        result.checkCreate == true) {
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
                 this.displayErrorMessageEvent(component,event, response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    //This helper function called to process Clone claim
    onCloneClaim :function(component){
        //check claim type
        if(($A.get("$Label.c.Core_MDF_Claim_Adjustment_Type"))==(component.get("v.simpleNewClaim.Core_MDF_Type_Txt__c")))
        {
            //wait for 1 sec and set negative claim flag 
            setTimeout(function() {
                component.set("v.isClaimNegativeType", true);
                component.set("v.isClaimEditable", false);
            }, 1000);
        }
        else{
            this.fetchClaimDetails(component);
        }
    },
    
    //This method will fetch claim details
    fetchClaimDetails :function(component){
        if (component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c") != '' 
            && component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c") != undefined) 
        {
            component.set("v.activitySearchString", component.get("v.simpleNewClaim.Request.Core_MDF_Activity_Number__c"));
            this.autoPopulateActivity(component);               
            component.set("v.bankAccountId", component.get("v.simpleNewClaim.ChannelPartner.Id"));
            this.fetchBankRecords(component);
            component.set("v.activityId", component.get("v.simpleNewClaim.RequestId"));
            //hold latest country picklist values from activity, incase of clone and edit
            component.set("v.activityCountries", component.get("v.simpleNewClaim.Request.Core_MDF_Country_nm__c"));
            this.fetchCountryRecords(component);
            component.set("v.isReqEditVisible", true);
            component.set("v.simpleNewClaim.ChannelPartner", component.get("v.simpleNewClaim.ChannelPartner.Name"));
            
            //Escalation- Set Escalation Id - for clear lookup
            component.set("v.escObjectId",
                          component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c"));
            //Claim to be Audited 
            component.set("v.isClaimAudited",
                          component.get("v.simpleNewClaim.Core_MDF_To_Be_Audited_Ind__c"));
        }
    },
    
    //To fetch record type meta data
    fetchRecordTypeMetaData: function (component) {
        var claimRecordType = component.get('v.recordtypeDeveloperName');
        var action = component.get("c.fetchRecordTypeMetaData");
        action.setCallback(this, function (a) {
            var state = a.getState();
            if (state === "SUCCESS" && a.getReturnValue() != null) {
                var recTypeMap = a.getReturnValue();
                //setting activity record type developer name
                component.set('v.activityRecordTypeDevName', recTypeMap[claimRecordType]);
                var activityId = component.get('v.activityId');
                if (!$A.util.isUndefined(activityId) && !$A.util.isEmpty(activityId)) {
                    component.set('v.simpleNewClaim.RequestId', activityId);
                }  
            }
            else {  this.displayErrorMessageEvent(component,event, a.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },
    
    //This helper function is used to fetch bank pick list values
    getDuplicateRecords: function(component){
        var action = component.get("c.duplicateClaimCheck");
        action.setParams({
            newClaim: component.get("v.simpleNewClaim")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null){
                var dupList = response.getReturnValue();
                //If not duplicate record
                if(Object.keys(dupList).length==0 && component.get("v.currentStep") == "1"){                    
                    component.set("v.currentStep", "2");
                }
                
                //if it is duplicate record
                else{
                    //To set duplicate list size according to duplicate claim size
                    if(Object.keys(dupList).length>$A.get("$Label.c.Core_MDF_DuplicateClaimSize")){
                        dupList.length = $A.get("$Label.c.Core_MDF_DuplicateClaimSize");
                    }
                    //In Edit case
                    if (component.get("v.isClaimEdit")) {
                        if (component.get("v.simpleNewClaim.Core_MDF_Duplicate_Claim__c") != undefined
                            && component.get("v.simpleNewClaim.Core_MDF_Duplicate_Claim__c") == true) {
                            //No duplicate check will prompt
                            component.set("v.currentStep", "2");
                        } else {
                            component.set("v.duplicateClaimList", dupList);
                        }
                    } else {
                        component.set("v.duplicateClaimList", dupList);
                    }
                } 
            } else {
                 this.displayErrorMessageEvent(component,event, a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
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
                // Claim edit case - remove duplicate values
                if ((component.get("v.isClaimEdit") || component.get("v.isCloneClaim"))
                    && component.get("v.simpleNewClaim.Core_MDF_Currency__c") != ''
                    && component.get("v.simpleNewClaim.Core_MDF_Currency__c") != undefined) {
                    var currList = currValList;
                    for (let i = 0; i < currList.length; i++) {
                        if (currList[i].key == component.get("v.simpleNewClaim.Core_MDF_Currency__c")) {
                            currList.splice(i, 1);
                            break;
                        }
                    }
                    component.set("v.currList", currList);
                } else {
                    component.set("v.currList", currValList);
                }
                
                //checking if logged in user's type as power partner and setting flag to true
                if (a.getReturnValue().userDtls != '' && a.getReturnValue().userDtls.UserType != '' &&
                    a.getReturnValue().userDtls.UserType == $A.get("$Label.c.Core_MDF_Partner_User_Type")) {
                    component.set("v.isPortal", true);
                }
            }
            else {  this.displayErrorMessageEvent(component,event, a.getReturnValue()); }
        });
        $A.enqueueAction(action);
    },
    
    //This helper function is used to autopopulate esccalation over claim
    autoPopulateEscalation: function (component) {
        var escalationSearch = component.get('v.escalationNoSearchString');
        if (escalationSearch != '' & !$A.util.isUndefinedOrNull(escalationSearch)) {
            var escalationLookup = component.find('escalationId');
            escalationLookup.select2();
        }
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
                }
                else {
                    this.displayErrorMessageEvent(component,event, a.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        else {
            component.set("v.escalationNoSearchString", "");
        }
    },
    
    // This helper function called to process edit claim
    onEditClaim: function (component) {
        this.isClaimEligibleForEdit(component);
        this.fetchClaimDetails(component);
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
                this.displayErrorMessageEvent(component,event, a.getReturnValue());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    //Claim cannot be edit by member if it is on Intel Hold
    IsUserEligibleToEditClaimOnMembHold : function (component) {
        var curretMemHoldStatus =  component.get("v.simpleNewClaim.Core_MDF_Intel_Manual_Hold_Ind__c");       
        var isMember = component.get("v.isPartner");  
        if(curretMemHoldStatus == true && isMember== true ){
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
        else{
            // To ensure that claim with Closed activity OR escalation cannot be edited by any other user except CCR/CCM
            if(!component.get("v.isUserClaimCaseReviewerOrManager") && (component.get("v.simpleNewClaim.Request.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_Claim_Activity_Closed_Status")
                                                                        || component.get("v.simpleNewClaim.Core_MDF_Escalation_Id__c") != null)){
                component.set("v.isClaimEditable", false);
                
            }else{
                if (component.get("v.simpleNewClaim.Core_MDF_Status__c") != ''
                    && component.get("v.simpleNewClaim.Core_MDF_Status__c") != undefined) {
                    var claimStatus = ($A.get("$Label.c.Core_MDF_EditClaimStatusValues")).split(";");
                    if (claimStatus.includes(component.get("v.simpleNewClaim.Core_MDF_Status__c"))) {
                        if(Boolean(flaggedForAudit))
                        {
                           component.set("v.StrightToPayDisabled", true); //If flagForAudit=true, disable STP required for WW50 Release
                            if (component.get("v.isAuditUser") && Boolean(auditHoldFlag) ){ 
                                component.set("v.isClaimEditable", true);
                            }else{ 
                                component.set("v.isClaimEditable", false);
                            }
                        }
                        else if(this.IsUserEligibleToEditClaimOnMembHold(component)){
                            component.set("v.isClaimEditable", false);
                        }
                            else{
                                component.set("v.isClaimEditable", true);
                            }                            
                    } else {
                        component.set("v.isClaimEditable", false);
                    }
                } else {
                    component.set("v.isClaimEditable", false);
                } } }
    },
    
    //This function used to create event and pass to parent component, to display error message
    displayErrorMessageEvent : function(component,event,errorMessage){
        // Create the new event
        var actionEvent = component.getEvent("DisplayErrorMessageEvent");
        // Populate the event with the step
        actionEvent.setParams({
            "errorMsg" : errorMessage
        });
        // Fire the event
        actionEvent.fire();   
    },    
    
})