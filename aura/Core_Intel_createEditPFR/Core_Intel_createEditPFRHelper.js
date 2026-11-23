({
    // Helper function called from Custom Save Function controller js
    // Calls Server Side Controller function which saves the record after performing all the server side validation
    
    saveHelperMethod: function (component, newPFR) {

        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");  
        
        //[IPA - Budget CAP]  - [OOC - P8] - Internal Account Manager/External - Validation Reimbursement Amount against Budget CAP
        //Throw a soft pop-up error if Budget Cap Amount Exceeded && component.get("v.isBudgetCapExceeded")
        if(!component.get("v.chkBdgtCpExcd") &&
           (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType"))){
            component.set("v.chkBdgtCpExcd",true);
            this.chkBudgetCap(component,newPFR);    
            // [IPA MDF] - Campaign - Clone a Proposal - Activity Section - fire event and pass edited pfr object to campaign
            if(component.get("v.pfrCloneCheck")){
                var actRec = component.get("v.newPFR");
                var cmpEvent = component.getEvent("ipaActRecClone"); 
                cmpEvent.setParams({"detail" : actRec}); 
                cmpEvent.fire();   
            }
        }else
         {
            //Disable Save button
            component.set("v.isSaveDisable", true);
            component.set("v.isSaveandNewDisable", true);
            //Fix For Locale Issue
            var exchangeRateJSNumFormat = Number(component.get("v.newPFR.Core_MDF_Exchange_Rate_ptc__c")); 
            component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateJSNumFormat);

            if(component.get("v.mode") == 'clone'){
                component.set("v.newPFR.Core_MDF_IsCloned_Ind__c", true);
            }
             if(component.get("v.mode") != 'edit'){
                 
                 component.set("v.newPFR.Core_MDF_StartTime_dtm__c", component.get("v.activityCreationStartTime"));
            }
             
            //Avoid calling DML operation on click of Save or Save and New multiple times at the same time.
            //Issue happened for Retail MDF. Because of multiple click Approval Stage not populating.
            if(!component.get('v.isSaveButtonClicked')){
                component.set("v.isSaveButtonClicked", true);
            }else{
                return;
            }
            
            var action = component.get("c.savenSendRecordId");

            action.setParams({
                "pfr": newPFR,
                "contentdocumentids": component.get("v.ContentDocumentIds"),
                "BudgetException": component.get("v.BudgetException"),
                "recType": component.get("v.recordtypeDeveloperName"),
                "segmentAndProduct": component.get("v.segmentString"),
                //Technical: [OEM Integration - CCF/DCF] - Impact analysis on the removal of the Record / object access to external users
                "BudId": component.get("v.selAvailableBudget"),
                "isPropIndicator":component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c"),
                "mdfReimbursement":newPFR.Core_MDF_MDFReimbursement_Amt__c,
                "tacticMetrics": this.isNotBlank(component.get("v.tacticMetricsValues")) ? component.get("v.tacticMetricsValues") : null,
                "ecosystemPartner": this.isNotBlank(component.get("v.ecosystemAllocations")) ? component.get("v.ecosystemAllocations") : null
            });
            
            
            action.setCallback(this, function (response) {
                var state = response.getState();
               var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
                if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                      component.set("v.showSpinner", false);
                }
                if (state === "SUCCESS") {
                    
                    component.set("v.isSaveButtonClicked", false);
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
                    else if (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            recordId: component.get("v.selectedLookUpRecord.Id"),
                            slideDevName: "detail"
                        });
                        navEvt.fire();
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        if (component.get("v.recordId") != null) {
                            setTimeout(function () {
                                window.location.reload();
                            }, 2000);
                        }
                        
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
                    component.set("v.isSaveButtonClicked", false);
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
                            	error = JSON.stringify(pageErrors[0].message); //JSON.stringify(pageErrors[0].statusCode) + ":" + JSON.stringify(pageErrors[0].message);  
                            }else if(pageErrors[0].statusCode == 'DUPLICATE_VALUE'){//In case of duplicate Allocation show the custom error message to the user.
                                error = $A.get("$Label.c.Core_MDF_Allocation_DuplicateErrMsg");
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
   
    checkAvailAllocationAmt: function (component) {
        var formatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
            		 currency: 'USD',
        });
        
       if((component.get("v.selAvailableBudget")== null 
         || component.get("v.selAvailableBudget") == undefined 
         || component.get("v.selAvailableBudget") ==""))
       {
            //No message shown when no budget is selected
     component.set("v.isShowAllocationAmt",false);
     component.set("v.showAllocationAmtMsg",''); 
     }
     else if((component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")!=null &&(component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_PFR_CCF")||component.get("v.recordtypeDeveloperName")==$A.get("$Label.c.Core_MDF_PFR_DCF"))
        &&component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")!='CCF 1.0'&&component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")!='DCF 1.0' &&	
           component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") != 'OEM CMP' && 
           component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") != 'Service Provider CMP' &&   
		component.get("v.newPFR.Core_MDF_Start_Date__c")!=null && component.get("v.newPFR.Core_MDF_End_Date__c")!=null && component.get("v.newPFR.ChannelPartnerId")!=null &&component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")!='')  ||
        (component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_PFR_Retail")
        && component.get("v.newPFR.Core_MDF_Start_Date__c")!=null && component.get("v.newPFR.Core_MDF_End_Date__c")!=null &&
       this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id")) )) {
           //Budget Types excluded -- legacy,OEM CMP, SP CMP and RSA MD
		var channelId;
            var selectedbudget;
         
         if(component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_PFR_Retail")){
             channelId=component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id");
         }
         else if(component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_PFR_CCF")||component.get("v.recordtypeDeveloperName")==$A.get("$Label.c.Core_MDF_PFR_DCF")){
             channelId=component.get("v.newPFR.ChannelPartnerId");
         }
            selectedbudget=component.get("v.selAvailableBudget");
            component.set("v.newPFR.Core_MDF_Budget_id__c",selectedbudget);
            component.set("v.newPFR.BudgetId",selectedbudget);
      
            //Method call for fetching allocations
            var action = component.get("c.checkAvailableAllocAmt");
            action.setParams({
                pfr: component.get("v.newPFR"),
                recordType:component.get("v.recordtypeDeveloperName"),
                accountId:channelId,
                budgetId:selectedbudget
                
            });
            
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var result = response.getReturnValue();
                    var amountToBeDisplayed = result.amountToBeDisplayed;
                    var allocationId = result.allocationId;
                    var isAutoEnabled = result.isAutoEnabled;
                    //Setting Allocation Amount Message 
                    if(amountToBeDisplayed!=$A.get("$Label.c.Core_MDF_ZeroAllocationAmount")){
                        if(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c")!='RSA MD')
                        {
                            if(isAutoEnabled==true){//Setting message for 'Auto Enabled'
                             component.set("v.showAllocationAmtMsg",$A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg")+" "+
                                            formatter.format(amountToBeDisplayed)+" "+$A.get("$Label.c.Core_MDF_AllocationAmountAutoEnabled"));    
    						component.set("v.isShowAllocationAmt",true);
                        }
                        
                        else{
                             component.set("v.showAllocationAmtMsg",$A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg")+" "+formatter.format(amountToBeDisplayed));
                            	component.set("v.isShowAllocationAmt",true);
                        }
                        }
                        component.set("v.newPFR.AllocationId",allocationId);//Setting Allocation on Budget
                           
                    }else{
                        if(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c")!='RSA MD')
                        {
                            component.set("v.isShowAllocationAmt",true);
                            component.set("v.showAllocationAmtMsg",amountToBeDisplayed);
                             component.set("v.newPFR.AllocationId",allocationId);
                        }
                        else
                        {
                            component.set("v.isShowAllocationAmt",false);
                            component.set("v.showAllocationAmtMsg",'');
                        }
                    }
                
                }else{
                    var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                    this.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
            });
             $A.enqueueAction(action);
           } 
       
      

    },
    
    // Helper Method Called from the additionalfilter and doinit fuction to construct the filter
    constructadditionalfilter: function(component,startdate, enddate,recordtype, campaignAccount){
        
        // Stores label name
        var DCF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateDCFRecordType");
        var CCF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateCCFRecordType");
        var SPCF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateSPCFRecordType");
        var Retail_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateRetailRecordType");
        var CCF_Boost_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateCCFBoostRecordType");
        var EEF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateEEFRecordType");
        
        var sFilter = "";
        var aFilter = "";
        if(component.get("v.selectedLookUpRecord.Id") != null && component.get("v.selectedLookUpRecord.Id") != undefined && recordtype == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            var campId = component.get("v.selectedLookUpRecord.Id");//EEF
        }
        // constructing the filter  -- RecordType
        if (recordtype == $A.get("$Label.c.Core_MDF_PFR_DCF")) { //DCF_Label      
        sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Data_Center_CoMarketing_Fund@quote;";
        
        // DCF - Restrict accounts to Campaign Account hierarchy
        var dcfCampId = component.get("v.selectedLookUpRecord.Id");
        
        if(this.isNotBlank(dcfCampId)) {
            var actionfetchDCFHierarchyAccts = component.get("c.getHierarchyAccountIds");
            actionfetchDCFHierarchyAccts.setParams({
                "campId": dcfCampId
            });
            
            actionfetchDCFHierarchyAccts.setCallback(this, $A.getCallback(function(response) {
                var result = response.getReturnValue();
                var status = response.getState();
                
                if(result != null && status == "SUCCESS" && result.length > 0) {
                    component.set("v.hierarchyAcctList", result);
                    let hierAccList = "(@quote;" + 
                                      component.get("v.hierarchyAcctList").join("@quote;,@quote;") + 
                                      "@quote;)";
                    var dcfAFilter = "Id IN " + hierAccList +
                                    " AND RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
                                    " AND isPartner=true" +
                                    " AND Core_MDF_Active_Ind__c = true" +
                                    " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                                    DCF_NonTranslateLabel + "@quote;";
                    component.set("v.additionalAccFilter", dcfAFilter);
                } else {
                    // Fallback - if no hierarchy accounts found use original filter
                    var dcfAFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
                                    " AND isPartner=true" +
                                    " AND Core_MDF_Active_Ind__c = true" +
                                    " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                                    DCF_NonTranslateLabel + "@quote;";
                    component.set("v.additionalAccFilter", dcfAFilter);
                }
            }));
            $A.enqueueAction(actionfetchDCFHierarchyAccts);
        } else {
            // No Campaign selected yet - use original filter
            aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
                      " AND isPartner=true" +
                      " AND Core_MDF_Active_Ind__c = true" +
                      " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                      DCF_NonTranslateLabel + "@quote;";
        }
    } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_CCF")) { // CCF_Label
        sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Client_CoMarketing_Fund@quote;";
        
        // CCF - Restrict accounts to Campaign Account hierarchy
        var ccfCampId = component.get("v.selectedLookUpRecord.Id");
        
        if(this.isNotBlank(ccfCampId)) {
            var actionfetchCCFHierarchyAccts = component.get("c.getHierarchyAccountIds");
            actionfetchCCFHierarchyAccts.setParams({
                "campId": ccfCampId
            });
            
            actionfetchCCFHierarchyAccts.setCallback(this, $A.getCallback(function(response) {
                var result = response.getReturnValue();
                var status = response.getState();
                
                if(result != null && status == "SUCCESS" && result.length > 0) {
                    component.set("v.hierarchyAcctList", result);
                    let hierAccList = "(@quote;" + 
                                      component.get("v.hierarchyAcctList").join("@quote;,@quote;") + 
                                      "@quote;)";
                    var ccfAFilter = "Id IN " + hierAccList +
                                    " AND RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
                                    " AND isPartner=true" +
                                    " AND Core_MDF_Active_Ind__c = true" +
                                    " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                                    CCF_NonTranslateLabel + "@quote;";
                    component.set("v.additionalAccFilter", ccfAFilter);
                } else {
                    // Fallback - if no hierarchy accounts found use original filter
                    var ccfAFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
                                    " AND isPartner=true" +
                                    " AND Core_MDF_Active_Ind__c = true" +
                                    " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                                    CCF_NonTranslateLabel + "@quote;";
                    component.set("v.additionalAccFilter", ccfAFilter);
                }
            }));
            $A.enqueueAction(actionfetchCCFHierarchyAccts);
        } else {
            // No Campaign selected yet - use original filter
            aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;" +
                      " AND isPartner=true" +
                      " AND Core_MDF_Active_Ind__c = true" +
                      " AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                      CCF_NonTranslateLabel + "@quote;";
        }
        } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_Retail")) { //Retail_Label
                sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Retail_Marketing_Funds@quote;";
            } 
        //EEF Changes for campaign & Account Additional Filter
                    else if (recordtype == $A.get("$Label.c.Core_MDF_EEF_RecordType")) { 
                        sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Ecosystem_Extension_Fund@quote;";
                        if(campId != null){
                            var actionfetchUltimateAccts = component.get("c.getUltimateAccountIds");
                            actionfetchUltimateAccts.setParams({
                                "campId":campId
                            });
                            
                            actionfetchUltimateAccts.setCallback(this, $A.getCallback( function (response) {
                                var result = response.getReturnValue();
                                var status = response.getState();
                                
                                if(result != null && status == "SUCCESS"){
                                    component.set("v.ultimateAcctList", result);
                                    let ultAccList = "(@quote;"+ component.get("v.ultimateAcctList").join("@quote;,@quote;") + "@quote;)";
                                    aFilter = "Core_MDF_CoMarketing_Ultimate_Account__c IN "+ ultAccList + "AND RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote;"+
                                        " AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
                                        EEF_NonTranslateLabel + "@quote;";
                                    component.set("v.additionalAccFilter", aFilter);
                                    console.log('afilter-->',aFilter);
                                    
                                }
                                else{
                                    var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                                    this.displaySuccessErrorMsg(errorMessage, "Error", "error");
                                }
                            }));
                            $A.enqueueAction(actionfetchUltimateAccts); 
                            console.log('UltimateAcctList-->',component.get("v.ultimateAcctList"));
                            
                        }
                    }
        // constructing the filer -- date
        if (!$A.util.isEmpty(sFilter)) {
            if (startdate != null && enddate != null && enddate >= startdate) {
                sFilter = sFilter + " AND endDate >=" + enddate + " AND startDate <=" + startdate;
            }
        }
        
        component.set("v.additionalFilter", sFilter);
        // For CCF, DCF and EEF - additionalAccFilter is set inside async callbacks above
        // For Retail and other record types - set it here
        if (recordtype != $A.get("$Label.c.Core_MDF_EEF_RecordType") && 
            recordtype != $A.get("$Label.c.Core_MDF_PFR_CCF") && 
            recordtype != $A.get("$Label.c.Core_MDF_PFR_DCF")) {
            component.set("v.additionalAccFilter", aFilter);
            }
    },
    // Helper Method called from the custom save function in order to display the popups
    activityPicker: function (component, recordType) {
        //if the record type is IPA, we have Activity Category, Type and SubType in the picklist fields
        ////making call to server side to invoke UI API
        
        this.accPropCampType(component);
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            var pickLabel = $A.get("$Label.c.Core_MDF_IPA_PFR_UI_Fields");
        }
        //making call to server side to invoke UI API
        else{
            var pickLabel = $A.get("$Label.c.Core_MDF_ActvityCategoryAndType");
        }
        var pickListFields = pickLabel.split(",");
        
        var result;
        var recType = recordType;
        if(this.isNotBlank(recType)){
        var action = component.get("c.mainPicklistFetcher");
        
        action.setParams({
            "recordTypeName": recType
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
          
            var state = response.getState();
           if (state === "SUCCESS") {             
            for (var i = 0; i < pickListFields.length; i++) {              
                //Gets value from parent picklist field
                var sControllingFieldValues = result.picklistFieldValues[pickListFields[i]].controllerValues;
                //Gets value from dependent picklist field 
                var sFieldValues = result.picklistFieldValues[pickListFields[i]].values;
                // Constructing the Options for the picklist field
                this.initActcategoryandType(component, pickListFields[i], sControllingFieldValues, sFieldValues);
                }
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
            
        });
        $A.enqueueAction(action);
        }
    },
    
    accPropCampType: function (component) {
        if(this.isNotBlank(component.get("v.recordtypeDeveloperName")) && this.isNotBlank(component.get("v.selectedLookUpRecord")) ){
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var action = component.get("c.fetchAccPropCampaign");
        var campRec = component.get("v.selectedLookUpRecord");
        action.setParams({
            camp: campRec
        });
        $A.enqueueAction(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
                
            if (state === "SUCCESS") { 
                var result = response.getReturnValue();
                if(result == 'Proposal Based'){
                    
                    component.set("v.isPropBasedCampaign",true);
                }
                else{
                    component.set("v.isPropBasedCampaign",false);
                }
                
                this.setCampaignOutcomeBasedOptIn(component);
            }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
        });
        
        } 
    },
    
    //Variable Reimbursement Rate changes
    //Server call to fetch VR Question label
    fetchVRQuestion: function (component) {
        var techchannelProgram = component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
        
        if (techchannelProgram != null) {
            var action = component.get("c.fetchVRMetadataMapping");
            
            action.setParams({
                channelProgram: techchannelProgram
            });
            
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                var status = response.getState();
                
                if (status == "SUCCESS" && result != null) {
                    if (
                        result.Core_MDF_InctQuest_Label_Ref__c != null &&
                        result.Core_MDF_InctQuest_Label_Ref__c != undefined
                    ) {
                         component.set(
                            "v.vrQuestion",
                            $A.getReference(result.Core_MDF_InctQuest_Label_Ref__c)
                        );
                    }
                }else{
                var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                helper.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
            });
            
            $A.enqueueAction(action);
        }
        
        component.set(
            "v.vrOptInQuestion",
            $A.getReference("$Label.c.Core_MDF_VRInc_OptIn_Question")
        );
    },
    
    //Server call for checking incentive
    checkVariableReimbursement: function (component) {
        if (!component.get("v.renderVRQuestion") == true &&
            (!$A.util.isEmpty(component.get("v.newPFR.Core_MDF_TargetAudience__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_ProductType__c")) &&
             !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Brand_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_ActivityCategory__c")) &&
             !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Activity_Types__c")) && !$A.util.isEmpty(component.get("v.newPFR.CampaignId")) &&
             !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Start_Date__c")))) {
            
            var cpid;
            
            if (((this.isNotBlank(component.get("v.oldActivtyType")) && this.isNotBlank(component.get("v.SelActivityType")) && component.get("v.oldActivtyType") != component.get("v.SelActivityType")) || (component.get("v.oldcategory") != component.get("v.SelCategory")) ||
                 (component.get("v.oldProdType") != component.get("v.SelProductType")) || (component.get("v.oldBrand") != component.get("v.SelBrand"))
                 || (this.isNotBlank(component.get("v.oldsdate")) && this.isNotBlank(component.get("v.newPFR.Core_MDF_Start_Date__c")) && component.get("v.oldsdate") != component.get("v.newPFR.Core_MDF_Start_Date__c")))
                || !$A.util.isEmpty(component.get("v.incentive"))) {
                component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", null);
                component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", null);
            }
            
            component.set("v.incentive", null);
            component.set("v.incentiveCriteriaId", null);
            component.set("v.renderVRQuestion", false);
            component.set("v.vrdata", null);
            component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
            component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
            component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",null);
            
            if (!$A.util.isEmpty(component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__c)) {
                cpid = component.get("v.selectedLookUpRecord").Core_MDF_Channel_Program__c;
            }
            
            var action = component.get("c.calculateIncentiveForActivity");
            
            action.setParams({
                pfr: component.get("v.newPFR"),
                camptechnology : component.get("v.selectedLookUpRecord").Core_MDF_Technology__c,
                channelProgramId: cpid
            });
            
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                var status = response.getState();
                
                if (status == "SUCCESS" && result != null) {
                    if (result.pfrData.length > 0) {
                        component.set("v.vrdata", result.pfrData);
                        
                        if (!$A.util.isEmpty(component.get("v.vrdata[0].Core_MDF_Incentive_pct__c"))
                            &&
                            parseFloat(
                                component.get("v.vrdata[0].Core_MDF_Incentive_pct__c")
                            ) > 0
                           ) {
                            //US964896: TECH [DCF/SPCF] - [OOC] - 60% RR for Intel Select Solutions
                            var questionDisplay = [];
                            var pmemIncentive = false; 
                            var otherIncentive = false;
                            var fetchBrandVal = $A.get("$Label.c.Core_MDF_ActivityRR_Brand").split(";");
                            if (fetchBrandVal.includes(result.pfrData[0].Core_MDF_Brand_nm__c)) {
                                otherIncentive = true; 
                            }else{
                                pmemIncentive = true;
                            }
                            questionDisplay.push({
                                question:$A.get(result.questionLabel), 	
                                answer:result.questionAns,
                                pmemIncentive:pmemIncentive,
                                otherIncentive:otherIncentive
                            });
                            
                            component.set("v.vrQuestionList",questionDisplay);
                            component.set("v.renderVRQuestion", true);
                            component.set(
                                "v.incentive",
                                component.get("v.vrdata[0].Core_MDF_Incentive_pct__c")
                            );
                            component.set(
                                "v.incentiveCriteriaId",
                                component.get("v.vrdata[0].Core_MDF_Incentive_Criteria_Id__c")
                            );
                        }
                    }
                }
                
                if (component.get("v.renderVRQuestion") == true) {
                    this.checkRemindersandFileUpload(component, false);
                } else {
                    component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", null);
                    component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", null);
                    component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
                    component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
                    
                    this.checkRemindersandFileUpload(component, true);
                    this.fetchApprovers(component);
                }
            });
            
            $A.enqueueAction(action);
            
        }
        else {
            this.checkRemindersandFileUpload(component, true);
        }
    },
    
    // Function used for showing the Questions and Pop-ups based on metadata
    checkRemindersandFileUpload: function (component, goforsave) {
        
        var metadata = component.get("v.metadataMap");
        //Directly save record, if none of additional functionality reuired
        var callsave = true;
        //Check if for loop to be looped again
        var checkforloop = true;
        // Added check to identify if its opal activity and category event to hide competitive elements -start
        var selCategory = component.get("v.SelCategory");
        var selActiType = component.get("v.SelActivityType");
        var setBudgType = component.get("v.selBudgetType");
        //New Activity Category Type Change - Replaced hard coded values with label
        if(($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(selCategory)  && (component.get("v.isOpalActivity") || component.get("v.recordTypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
            component.set("v.hideCompetitiveQuest",false);
        }
         if (((this.isNotBlank(setBudgType)&&(setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") )) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(selCategory) /*selCategory == 'Event'*/ && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) || ((component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") || component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c") == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")) && selActiType != 'Promotion')) {
            component.set("v.hideCompetitiveQuest", true);
            if((setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || setBudgType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(selCategory) /*selCategory == 'Event'*/ && (selActiType == 'Joint Event' || selActiType == 'Third Party Event')) {
                component.set("v.newPFR.Core_MDF_Competitive_Elements__c",null);
            }
        }
        this.fetchApprovers(component);
        //Added check to identify  if its opal activity and category event to hide competitive elements - end
        for (var index = 0; index < metadata.length; index++) {
            // Checking the condition for the Question and Pop-up based on metadata map
            if (metadata[index].Core_MDF_Field_7_txt__c == component.get("v.SelCategory") && metadata[index].Core_MDF_Field_9_txt__c == component.get("v.SelActivityType") &&
                metadata[index].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName")){
                
                callsave = false;
                //Check if Amount is above threshold(The Upload of file is manadtory) 
                // Added extra condition for opal as amount should be calculated against Activity Reimbursement Amount
                if ((component.get("v.newPFR.RequestedAmount") >= metadata[index].Core_MDF_Number_1_num__c && !component.get("v.isOpalActivity")) ||
                    (component.get("v.isOpalActivity") && this.checkActivityReimbursementAmount(component, metadata[index].Core_MDF_Number_1_num__c))) {
                    component.set("v.checkbudgetcondition", true);
                }
                //Compare with Metadata records, check if
                //1. Print Media Questions to be Visible
                //2. Tech Exploration Questions to be Visible
                //3. Event Govt Questions to be Visible
                //4. File Upload Section to be Visible
                //5. Event Pop Up Rendered
                //5. ELC Pop Up Rendered
                if (this.IsSectionToBeVisible(metadata,index)){
                    
                    this.isPrintMediaSectionVisible(component,metadata,index);
                    this.isGovtEventQuestionSectionVisible(component,metadata,index);
                    this.isTechExplorationPopUpVisible(component,metadata,index);
                    this.isFileUploadSectionVisible(component,metadata,index); 
                    this.isEventPopUpVisible(component,metadata,index);
                    this.isELCPopUpVisible(component,metadata,index);
                    
                    checkforloop = false;
                    
                } else {
                    component.set("v.PopupType", "");
                    //Variable Reimbursement Rate changes
                    if (goforsave == true) {
                        if (this.validateKPIValues(component)) {
                            this.setKPIValues(component);
                            this.saveHelperMethod(component, component.get("v.newPFR"));
                            break;
                        }
                    }
                }
                
            }
            if (!checkforloop) {
                component.set("v.recordApplicableForActivityRules", false);
                break;
            }
        }

        //Outcome Based changes - to show govt question, Event, ELC Popup when selected tactics is Event
        if(!$A.util.isEmpty(component.get("v.selectedTacticsOptions")) && component.get("v.selectedTacticsOptions").includes('Event')){
            callsave = false;
            this.isTacticsGovtEventQuesSecVisible(component);
	        this.isTacticsEventPopUpVisible(component);
            this.isTacticsELCPopUpVisible(component);
        }

        //end forloop
        //Variable Reimbursement Rate changes
        if (callsave == true && goforsave == true) {
            
            component.set("v.PopupType", "");
            if (this.validateKPIValues(component)) {
                this.setKPIValues(component);
                this.saveHelperMethod(component, component.get("v.newPFR"));
            }
            
        }
    },

    //Outcome Based changes - to show govt question when selected tactics is Event
    isTacticsGovtEventQuesSecVisible : function(component){
        if (!component.get("v.renderGovtQuestion")) {
            this.showQuestion(component,false,true,false);
        }
    },

    //Outcome Based changes - to show Event Popup when selected tactics is Event
    isTacticsEventPopUpVisible : function(component){
        if (component.get("v.PopupButtonValue") == false) {
            this.popUpHelper(component, "Event");
        }
    },
    //Outcome Based changes - to show ELC Popup when selected tactics is Event
    isTacticsELCPopUpVisible : function(component){
        if (component.get("v.ELCPopupButtonValue") == false && component.get("v.PopupButtonValue") == true) {
            this.popUpHelper(component, "ELC");
        }
    },
    
    //[IPA - Budget CAP]  - [OOC - P8] - Internal Account Manager/External - Validation Reimbursement Amount against Budget CAP
    //Throw a soft pop-up error if Budget Cap Amount Exceeded
    
    chkBudgetCap : function(component,newPFR){
        //Calculate Campaign Reimburesmt Amount
        var totalCampAmt = 0.0;
        var reimbrsmtRate=component.get("v.selectedLookUpRecord").Core_MDF_Reimbursement_Rate__c;
        if(this.isNotBlank(reimbrsmtRate)/*reimbrsmtRate != undefined*/){
            reimbrsmtRate=reimbrsmtRate.replace(/\%/g,'');
        }
        
        //Core_MDF_Total_Campaign_Cost_Amt__c
        var CampCost = component.get("v.selectedLookUpRecord").Core_MDF_Reimbursement_Amount_Amt__c;
        
        //Edit Sceanrio
        if(component.get("v.recordId") != null){           
            CampCost = CampCost - ((parseInt(reimbrsmtRate,10)*parseInt(component.get("v.oldPFR.RequestedAmount")))/100);  
        }
        
        totalCampAmt=(CampCost + ((parseInt(reimbrsmtRate,10)*parseInt(component.get("v.newPFR.RequestedAmount")))/100));
        if((component.get("v.selectedLookUpRecord").Core_MDF_Available_BudgetCap_amt__c-totalCampAmt) < 0 || $A.util.isEmpty(component.get("v.selectedLookUpRecord").Core_MDF_Budget_Cap__c)){
            this.popUpHelper(component,"budgetCap");
        }else{
            this.saveHelperMethod(component,newPFR);
        }
    },
    IsSectionToBeVisible : function(metadata,index){
        //Check if the Addtional Section to be viisible based on Metadata values w.r.t to selected category and type
        return (metadata[index].Core_MDF_Checkbox_Field_9_Ind__c || metadata[index].Core_MDF_Checkbox_Field_8_Ind__c || 
                metadata[index].Core_MDF_Checkbox_Field_6_Ind__c || metadata[index].Core_MDF_Checkbox_Field_5_Ind__c ||
                metadata[index].Core_MDF_Checkbox_Field_3_Ind__c || metadata[index].Core_MDF_Checkbox_Field_7_Ind__c);
    },
    isPrintMediaSectionVisible : function(component,metadata,index){
        //For selected Category and Type, validate if Print Media Questions applicable based on metadata field Print__c[Print MEdia Section to be Visible if Print__c is set to true]
        if (metadata[index].Core_MDF_Checkbox_Field_9_Ind__c && !component.get("v.renderPrintQuestion")) {
            this.showQuestion(component,true,false,false);
        }
        
    },
    isGovtEventQuestionSectionVisible : function(component,metadata,index){
        //For selected Category and Type, validate if Government Questions applicable based on metadata field Govt_Nexus_Flag__c [Government Question Section to be Visible if Govt_Nexus_Flag__c is set to true]
        if (metadata[index].Core_MDF_Checkbox_Field_8_Ind__c && !component.get("v.renderGovtQuestion")) {
            this.showQuestion(component,false,true,false);
        }
    },
    isTechExplorationPopUpVisible : function(component,metadata,index){
        //For selected Category and Type, validate if Tech Exploration Questions applicable based on metadata field Core_MDF_Enable_Question__c[Tech Exploration Section to be Visible if Core_MDF_Enable_Question__c is set to true]
        if (metadata[index].Core_MDF_Checkbox_Field_7_Ind__c) {
            this.showQuestion(component,false,false,true);
        }
    },
    showQuestion : function(component,showPrintQuestion,showGovtQuest,showTechExplorationQuest){
        //Method which enables as which section to be visible 
        component.set("v.renderPrintQuestion", showPrintQuestion);
        component.set("v.renderGovtQuestion", showGovtQuest);
        component.set("v.renderTechExplorationQuestSection",showTechExplorationQuest);
        if(this.isNotBlank(component.get("v.recordtypeDeveloperName")) && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") 
            && component.get("v.mode") != 'edit'){
        	component.set("v.showSpinner", false);
        }
    },
    isFileUploadSectionVisible : function(component,metadata,index){
        //For selected Category and Type, validate if File Upload applicable based on metadata field Core_MDF_Enable_File_Upload__c
        //Budget Condtion to check if the entered amount is greater than or equal to threshold
        //[File Upload Section to be Visible if Core_MDF_Enable_File_Upload__c is set to true]
       
        if ((metadata[index].Core_MDF_Checkbox_Field_6_Ind__c && component.get("v.checkbudgetcondition") && this.validateActivityCategory(component, $A.get("$Label.c.Core_MDF_Event_Activity_Category")) && component.get("v.checkfileuploadcondition") == false && (this.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType")))) ) {
            component.set("v.checkfileuploadcondition", true);
            component.set('v.isEventFormTemplateVisible', true);
        }
        else if (metadata[index].Core_MDF_Checkbox_Field_6_Ind__c && component.get("v.checkfileuploadcondition") == false && (this.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType"))) && this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))) {
            component.set("v.checkfileuploadcondition", true);
            if (this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))) {
                component.set('v.isIndustryPartnerFormTemplateVisible', true);
            }
        }
            else if(metadata[index].Core_MDF_Checkbox_Field_6_Ind__c && component.get("v.checkfileuploadcondition") == false && $A.get("$Label.c.Core_MDF_AllFileUpload_BudgetType").includes(component.get("v.selBudgetType"))){
                component.set("v.checkfileuploadcondition", true);
                
			}
    },
    isEventPopUpVisible : function(component,metadata,index){
        //For selected Category and Type, validate if Event Pop to be shown based on metadata field Enable_Event_Popup__c
        //[ Event Pop to be shown if Enable_Event_Popup__c is set to true]
        
        if (metadata[index].Core_MDF_Checkbox_Field_5_Ind__c && component.get("v.PopupButtonValue") == false) {
            this.popUpHelper(component, "Event");
        }
    },
    isELCPopUpVisible : function(component,metadata,index){
        //For selected Category and Type, validate if ELC Pop to be shown based on metadata field Core_MDF_Enable_ELC_Reminder__c
        //[ ELC Pop to be shown if Core_MDF_Enable_ELC_Reminder__c is set to true]
        if (metadata[index].Core_MDF_Checkbox_Field_3_Ind__c && component.get("v.ELCPopupButtonValue") == false && component.get("v.PopupButtonValue") == true) {
            this.popUpHelper(component, "ELC");
        }
    },
    validateKPIValues: function (component) {
        var lwccomp = component.find("kpiFields");
        if (lwccomp != null && lwccomp.isFormValid()) {
            return true;
        } else if (lwccomp != null && !lwccomp.isFormValid()) {
            var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
            this.displaySuccessErrorMsg(alertMsg,"Error!","error");
            return false;
        } else {
            return true;
        }
    },
    
    setKPIValues: function (component) {
        var lwccomp = component.find("kpiFields");
        if (lwccomp != null) {
            var kpiValues = lwccomp.getKPIValues();
            if (kpiValues != null) {
                var isMetricsFieldModified = lwccomp.isMetricFieldModified(kpiValues); //kpiValues - new metrics values
                var pfrmain = component.get("v.newPFR");
                var docIds = component.get("v.ContentDocumentIds");
                var mergedObj = Object.assign(pfrmain, kpiValues);
                component.set("v.newPFR", mergedObj);
                component.set("v.ContentDocumentIds",docIds);
                if(isMetricsFieldModified) { // if metrics field modified retrigger approval process
                    component.set("v.newPFR.Core_MDF_Metrics_Modified_ind__c", true);
                    this.retriggerApprovalIfMetricModified(component); // Planned Activity to go back to Pending Review if metrics field is edited
                }
            }
        }
    },
    retriggerApprovalIfMetricModified: function (component) {
        // RMF - Planned Activity/Revision Required to go back to Pending Review if metrics field is edited
        // IPA - Planned Activity to go back to Revision Required if metrics field is edited
        //DE115095 : WW19 | DEVINT3 | When Geo Lead edits an Activity,
        //which is in Planned status and changes the start date to 1 day minus today,
        //then Activity re approval is getting triggered
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var today = this.getTodayDateLocalTime();
        
        
        //DE119369 : WW27 | DEVINT3 | Geo Lead is able to edit Future dated Revision Required activities in specific time
        if($A.get("$Label.c.Core_MDF_IPA_RecordType") == component.get("v.recordtypeDeveloperName") && $A.get("$Label.c.Core_MDF_CCP_Planned_Status") == component.get("v.newPFR.Core_MDF_Fund_Request_Status__c")) {
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired"));
        } else if((!(component.get("v.retailgeouserper")) || (component.get("v.retailgeouserper") && component.get("v.accmgrper"))) && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")
                  && component.get("v.SelectedStatus") != $A.get("$Label.c.Core_MDF_Activity_Cancelled_Status") 
                  && $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequiredOrPlanned").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))/* && !($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status").includes(component.get("v.SelectedStatus")))*/) {
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            if(component.get("v.retailgeouserper") && component.get("v.accmgrper") && startDate < today &&
               component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") != $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired")
               && component.get("v.mode") == 'edit'){
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1); 
                component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
            } else {
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
            } 
        }else if(component.get("v.retailgeouserper") && startDate < today && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") &&
                 component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == "Planned"){
            this.callNextLevelApproval(component);
        } else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == "Planned" && component.get("v.isOpalActivity")){
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            if(!component.get("v.isLoggedInUserLevelOneApprover")){
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
        } 	
        } 	
    },
    
    kpiFieldStatusForAccMngr: function (component) {
        var accmgrper = component.get("v.accmgrper");
        var status = component.get("v.CurrentStatus");
        return ((status == null || status == 'Revision Required' || status == 'Planned' || component.get("v.checkCloneAttribute")) && accmgrper);
    },
    kpiFieldStatusForAuditor: function (component) {
        var auditorper = component.get("v.auditorper");
        var status = component.get("v.CurrentStatus");
        //As part of WW04 release, auditor, will be able to edit metrics in Closed status only
        //return (status == 'In-Progress' && auditorper);
        return (status == 'Closed' && auditorper);
    },
    kpiFieldStatusForrsmReviewer: function (component) {
        var rsmActivityReviewerper = component.get("v.rsmActivityReviewerper");
        var status = component.get("v.CurrentStatus");
        return (status == 'Pending Review' && rsmActivityReviewerper && !component.get("v.activityInApproval"));
    },
    // KPI enable/disable fields
    verifyKPIEditability: function (component) {
        var enableKPI = false; // False --> Field Disable and True --> Field Enable
        
        // Check Editiability for New Scenrio
        if(( (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && this.kpiFieldStatusForAccMngr(component))
            || this.kpiFieldStatusForAuditor(component) ||
            this.kpiFieldStatusForrsmReviewer(component)) && !component.get("v.disableRSMMetricEditability")){
            enableKPI = true;
        }else if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && 
                 component.get("v.checkGeoLeadMetricSecEditability")){  
            enableKPI = true; // New Scenario for Geo leads to edit the fields
            // CCF/DCF opal check to make KPI fields editable
        }else if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_DCF_Program") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_CCF_Program")) && component.get("v.isOpalActivity") ){
            var status = component.get("v.CurrentStatus");
            //KPI enable for planned opal activity
            //Allowed metric editability if status is pending review and field/marketing owner is editing in level 1 step
            if(status == null || status == 'Revision Required'|| status == 'Planned' || component.get("v.checkCloneAttribute") || 
               (status == 'Pending Review' && component.get("v.isOPALApprover") && component.get("v.newPFR.Core_MDF_Approval_Step_Completed__c") == 0)) {
                enableKPI = true;   
            } 
        }
        else if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){ 
                if(component.get("v.mode") == 'edit'){
                    var disabledMap = component.get("v.disabledMap") != null ? component.get("v.disabledMap") : [];   
                    enableKPI = disabledMap.hasOwnProperty('KPIFields') ? !disabledMap.KPIFields : false;
                }else{
                    enableKPI = true;  
                }
            }
        return enableKPI;
    },
    
    // end KPI field disability code
    
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
        }
        if (popuptype == "ELC") {
            //[RMF] update the Event ethics popup
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Event_Ethic"));
            } else {
                component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
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
        }
        //[IPA - Budget CAP]  - [OOC - P8] - Internal Account Manager/External - Validation Reimbursement Amount against Budget CAP
        //Throw a soft pop-up error if Budget Cap Amount Exceeded
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
        if (popuptype == "budgetCap" && recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_IPA_RecordType")) 
        {	
            component.set(
                "v.EventMessage",
                $A.get("$Label.c.Core_MDF_BudgetCapErrorActivity")
            );
            component.set(
                "v.AgreeButtonLabel",
                'OK'
            ); 
            component.set("v.PopupType", popuptype);
            component.set("v.ShowEventPopup", true);
        }
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
             component.set("v.showSpinner", false);
        }
       
    },
    
    // Functions to enable channel partner
    EnableCPCheckBox: function (component, event) {
        var disablecheck = false;
        var isChannelPartner;
        var seltype = component.get('v.SelActivityType');
        if(this.isNotBlank(component.get("v.SelCategory")) && this.isNotBlank(component.get("v.SelActivityType")) 
           && this.isNotBlank(component.get("v.recordtypeDeveloperName"))){
            var action = component.get("c.ischannelpartner");
            
            action.setParams({
                "activityCategory": component.get("v.SelCategory"),
                "activityType": component.get("v.SelActivityType"),
                "recordType": component.get("v.recordtypeDeveloperName")
            });
            action.setCallback(this, function (response) {
                isChannelPartner = response.getReturnValue();
                component.set("v.IsCP", isChannelPartner);
                
                if(component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                   component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
                   component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
                   component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") ||
                   component.get("v.isOpalActivity")){
                    component.set("v.IsCP", true);
                    component.set("v.CPLed", true);
                    component.set("v.SelChannelPartner", "");
                    component.set("v.SelOtherChannelPartner", "");
                    component.set("v.IsOtherCP", false);
                }
                else if (
                    isChannelPartner == true && 
                    (seltype == $A.get("$Label.c.Core_MDF_Channel_Partner_Website_Online_Ad") ||
                     seltype == $A.get("$Label.c.Core_MDF_Channel_Partner_Owned_Event") ||
                     seltype == $A.get("$Label.c.Core_MDF_Channel_Partner_Participation_in_Third_Party_Event"))) {
                    component.set("v.IsCP", true);
                    component.set("v.CPLed", true);
                    component.set("v.SelChannelPartner", '');
                    component.set("v.SelOtherChannelPartner", '');
                    component.set("v.IsOtherCP", false);
                    
                } else if (isChannelPartner == true) {
                    component.set("v.IsCP", true);
                    component.set("v.CPLed", false);
                    component.set("v.SelChannelPartner", '');
                    component.set("v.SelOtherChannelPartner", '');
                    component.set("v.IsOtherCP", false);
                    disablecheck = true;
                } else {
                    component.set("v.IsCP", false);
                    component.set("v.CPLed", false);
                    component.set("v.SelChannelPartner", '');
                    component.set("v.SelOtherChannelPartner", '');
                    component.set("v.IsOtherCP", false);
                    disablecheck = true;
                }
                
                var disablemap = component.get("v.disabledMap");
                if (disablemap == null) {
                    var mapVar = [];
                    mapVar = {
                        'cpled': !isChannelPartner
                    };
                    component.set("v.disabledMap", mapVar);
                } else {
                    
                    if (disablecheck) {
                        
                        if (component.get("v.CurrentStatus") != 'Closed' && (component.get("v.recordId") == null || component.get("v.checkCloneAttribute") == true)) {
                            component.set("v.disabledMap.cpled", !isChannelPartner);
                        } 
                    } else {
                        component.set("v.disabledMap.cpled", isChannelPartner);
                    }
                }
                component.set("v.IsCP", isChannelPartner);
            });
            $A.enqueueAction(action);
        } 
    },
    
    enabledisablecpled: function (component, isChannelPartner) {
        var disablemap = component.get("v.disabledMap");
        if (disablemap == null) {
            var mapVar = [];
            mapVar = {
                'cpled': isChannelPartner
            };
            component.set("v.disabledMap", mapVar);
        } else {
            component.set("v.disabledMap.cpled", isChannelPartner);
        }
    },
    // Constunting Options for parent picklist field
    initActcategoryandType: function (component, fldname, scontrolvalues, sfieldcompletevalues) {
        
        var controllingFieldValues = JSON.stringify(scontrolvalues).slice(1, -1);
        var confieldmap = new Object();
        if (controllingFieldValues != '') {
            var res = controllingFieldValues.split(",");
            
            for (var index = 0; index < res.length; index++) {
                var keyvalue = res[index].split(":");
                confieldmap[keyvalue[1]] = keyvalue[0].slice(1, -1);
                
            }
        } //controlling field value construct	
        var sValues;
        var childPickField = new Object();
        var ParPickField = []; //new Array();
        for (var i = 0; i < sfieldcompletevalues.length; i++) {
            if (sfieldcompletevalues[i].validFor.length > 0) { //condition to check for dependent field                   
                
                for (var j = 0; j < sfieldcompletevalues[i].validFor.length; j++) {
                    var key = confieldmap[sfieldcompletevalues[i].validFor[j]];
                    
                    
                    if (key in childPickField) { //initializing structure of parent and child values
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
                } //map creation
            } //end parent value loop
            else { 
                
                if (ParPickField.length == 0) {
                    
                    if(fldname != "Core_MDF_Reimbursement_Rate_pct__c" && fldname !="Core_MDF_Country_nm__c"){    //Skip adding --None-- value to Reimbursement Rate picklist    
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
        } //entire value loop
        
        // Parent picklist field options construction
        if (ParPickField.length > 0) {
            
            if (fldname == "Core_MDF_ActivityCategory__c") {
                component.set("v.ActivityCategories", ParPickField); 
                component.set("v.ActivityCategoriesMain", ParPickField);    // OPAL Change
                this.updateCategoryPickVals(component);
            }
            if (fldname == "Core_MDF_Country_nm___c") {
                component.set("v.Countries", ParPickField);               
            }
            if (fldname == "Core_MDF_TargetAudience__c") {
                component.set("v.TargetAudience", ParPickField);
            }
            //Country Multi Select All Options
            if (fldname == "Core_MDF_Country_nm__c") {
                component.set("v.CountryPicklistValues", ParPickField);
                this.localizeCountry(component, ParPickField);
                this.updateCountryPickVals(component);
            }
            if (fldname == "Core_MDF_Brand_nm__c") {
                component.set("v.BrandPicklistValues", ParPickField);
                this.updateBrandPickVals(component);
            }
            if(fldname == "Core_MDF_Initiative_nm__c"){
                component.set("v.InitiativesPicklistValues", ParPickField);
                this.updateInitiativesVals(component);
            }
            if(fldname == "Core_MDF_Industry_Multi_nm__c"){
                component.set("v.IndustryPicklistValues", ParPickField);
                this.updateIndustryPickVals(component);
            }
            //OPAL Past Dated Activity Submission process
            if (fldname == "Core_MDF_ReasonforPastDatedActivity_Nm__c") {
                component.set("v.OptPotentialReason", ParPickField);
            } 
            //Reimbursement Rate picklist values assignment
            if(fldname == "Core_MDF_Reimbursement_Rate_pct__c"){        
                component.set("v.ReimbursementRateVal",ParPickField);
                
                // OPAL changes start
                component.set("v.reimbursementRatePickValues",ParPickField);
                
                if(component.get("v.isOpalActivity")) {
                    var RR = component.get("v.SelReimbursementRate").replace('%', '');
					 var pickVals = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
					var defaultRR;
					 if(component.get("v.mode") == 'clone' && component.get("v.FlexiReimbursementAmt") == '' && !pickVals.includes(RR)){
						defaultRR = this.getDefaultReimbursementRate(component);
						
					} 
                    var flexRR = this.isNotBlank(defaultRR) && component.get("v.mode") != 'clone' ? defaultRR : this.isNotBlank(defaultRR) && component.get("v.mode") == 'clone' && component.get("v.externalper") ? defaultRR : component.get("v.SelReimbursementRate");
                    flexRR = (flexRR>100)?100:flexRR;
                    var rrPickValues = [];
                    var pickValues = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
                    rrPickValues.push({
                        class: "optionClass",
                        label: flexRR,
                        value: flexRR
                    });
                    for(var i = 0; i < pickValues.length; i++){
                        var optionValue = pickValues[i]+"%";
                        if(flexRR != optionValue){
                            rrPickValues.push({
                                class: "optionClass",
                                label: optionValue,
                                value: optionValue
                            });   
                        }
                    }
                    
                    rrPickValues.sort((a, b) => parseFloat(a.value) - parseFloat(b.value));
                    component.set("v.ReimbursementRateVal", rrPickValues);
                    component.set("v.reimbursementRatePickValues",rrPickValues); 
                    component.set("v.SelReimbursementRate", flexRR);
                    //Ayush - RR changes
                    if(this.isNotBlank(component.get("v.selBudgetType")) && (component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))){
						this.getAvailableBudget(component);
						
					} 
                }
                // OPAL changes end
                //Ayush - RR change - RMF defaulting to 100% only on create
                //Ayush - RR change - Added mode != edit for defect fix - to default 100% RR both on create and clone for RMF
                else if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.mode") != 'edit'){
                    //Akash - TWC702-14284
					component.set("v.SelReimbursementRate", $A.get("$Label.c.Core_MDF_BudgetType_RRate100"));
				}
            }    
            
            else if (fldname == "Core_MDF_ProductType__c") {
                component.set("v.ProductTypes", ParPickField);  
                
            }
            //Activity Type as parent field for Event Format
            if (fldname == "Core_MDF_Activity_Types__c") {
                component.set("v.ActivityTypes", ParPickField);
            }
            //Product Type Picklist values assignment
            if (fldname == "Core_MDF_ProductType__c") {
                component.set("v.ProductTypeValues", ParPickField);
            }
            //Tactic Multi-Picklist values assignment
            if(fldname == "Core_MDF_Tactics_nm__c"){//CCF/DCF - Outcome
                component.set("v.activityTacticsOptionsStored", ParPickField);  
                component.set("v.activityTacticsOptions", ParPickField);
                this.updateTacticsPickVals(component);           
            }
         
            
        } // Child picklist field construction
        else {
            if (fldname == "Core_MDF_Activity_SubType_nm__c") {
                component.set("v.activityMultiSelSubType", childPickField);
                this.dependentPickValAdditionAndRemoval(component, fldname);
                this.fetchActSubTypeMulti(component);
            }
            if (fldname == "Core_MDF_Activity_Types__c") {
                component.set("v.ActivityTypes", childPickField);
                if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") ||
                   component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                    this.dependentPickValAdditionAndRemoval(component, fldname);
                }
                this.fetchActType(component);
            }
            if (fldname == "Core_MDF_Event_Name_nm__c") {
                console.log('childPickField-->'+childPickField);
                component.set("v.EventNameMap", childPickField);
                this.dependentPickValAdditionAndRemoval(component, fldname);
                this.fetchEventName(component);
            }
            if (fldname == "Core_MDF_Domain_Type_nm__c") {
                component.set("v.DomainTypeOptions", childPickField);
                this.fetchDomainTypeOptions(component);
            }
            //Commented below lines- To remove Field Dependencies b/w Audiences,Product Type and Brand
            //And Inherit the Picklist values from Campaign
            
            if (fldname == "Core_MDF_Event_Format_Nm__c") {
                component.set("v.eventFormats", childPickField);
                component.set("v.setEventFormatOptionOnload", true);
                this.fetchEventFormat(component);
            }
            
        }
    },

    //CCF/DCF - Outcome
    //Function to update and set Tactic picklist values
    updateTacticsPickVals: function (component) {
        var tacticsOptions = component.get("v.activityTacticsOptionsStored") || component.get("v.activityTacticsOptions");
        var tacticslocalizeMap = component.get("v.apitoLabelConvert");
        var selectedBudgetType = component.get("v.selBudgetType"); 
        var tacticsOptnsMap = [];
        var cmpBudgetTypes = $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';');
        if (!$A.util.isEmpty(tacticsOptions) && tacticsOptions.length > 0 && tacticsOptions != undefined){
            for (var index = 0; index < tacticsOptions.length;index++){
                for (var key in tacticslocalizeMap) {
                    if (key == tacticsOptions[index].value) {
                        var shouldIncludeOption = true;
                    
                        if (cmpBudgetTypes.includes(selectedBudgetType)) {
                            if (key.toLowerCase().includes('incentive') || 
                            tacticslocalizeMap[key].toLowerCase().includes('incentive')) {
                            shouldIncludeOption = false;
                        }
                    }
                    
                    if (shouldIncludeOption) {
                    tacticsOptnsMap.push({
                            "label": tacticslocalizeMap[key],
                            "value": key
                        });
                    }
                }
            }
        }
    }
        if (!$A.util.isEmpty(tacticsOptnsMap) && tacticsOptnsMap.length > 0 && tacticsOptnsMap != undefined){
            component.set("v.activityTacticsOptions",tacticsOptnsMap);
        }
        
        if (cmpBudgetTypes.includes(selectedBudgetType)) {
            this.clearIncentiveSelectedTactics(component);
        }
       
    },
    
    //Function to remove selected 'Incentive' Tactic for CMP Budget Types on edit /clone
    clearIncentiveSelectedTactics: function(component) {
        var selectedTactics = component.get("v.selectedTacticsOptions");
        
        if (!$A.util.isEmpty(selectedTactics)) {
            var validSelectedTactics = selectedTactics.filter(function(selectedValue) {
                return selectedValue !== 'Incentive';
            });
            
            if (validSelectedTactics.length !== selectedTactics.length) {
                component.set("v.selectedTacticsOptions", validSelectedTactics);
                this.checkSPIFActSecVisible(component);

        var selectedTactics = component.get("v.selectedTacticsOptions");
        var selectedTacticsOptions = "";
        if(!$A.util.isEmpty(selectedTactics) && selectedTactics != undefined){
                for(var i=0; i<selectedTactics.length; i++ ){
                    if(i != selectedTactics.length - 1)
                        selectedTacticsOptions += selectedTactics[i]+";";
                    else 
                    selectedTacticsOptions += selectedTactics[i];            
                }
        }
        
        if(!$A.util.isEmpty(selectedTacticsOptions) && selectedTacticsOptions != undefined) {
            var lwcTacticMetricsComp = component.find("tacticMetrics");        
            var tacticMetricsValues;
            if (lwcTacticMetricsComp != null) {
                if(helper.isNotBlank(lwcTacticMetricsComp[0])){
                    tacticMetricsValues = lwcTacticMetricsComp[0].handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                }else{
                    tacticMetricsValues = lwcTacticMetricsComp.handleTacticChange({selectedTactics: component.get("v.selectedTacticsOptions")});
                }
            }
        }
            }
        }
    },

    
    //Function to localize all the country values
    localizeCountry: function (component, allCountriesOptions) {
        var labelapimap = [];
        var countrylocalizedMap = component.get("v.apitoLabelConvert");
        var countryOptions = allCountriesOptions;
        
        for (var index = 0; index < countryOptions.length; index++) {
            for (var key in countrylocalizedMap) {
                if (key == countryOptions[index].value) {
                    labelapimap.push({
                        "label": countrylocalizedMap[key],
                        "value": key
                    });
                    break;
                }
            }
        }
        component.set("v.AllCountryOptions", labelapimap);
        component.set("v.CountryPicklistValues", labelapimap);
        component.set("v.AllCountryOptionsMain", labelapimap);
        
    },
    
    //Subtype localization
    localizeSubType: function (component, allSubtypeOptions) {
        var labelapimap = [];
        var subTypelocalizedMap = [];
        var subTypelocalizedMap = component.get("v.apitoLabelConvert");
        var subTypeOptions = [];
        var subTypeOptions = allSubtypeOptions;
        
        labelapimap.push({
            class: "optionClass",
            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
            value: ""
        });
        
        for (var index = 0; index < subTypeOptions.length; index++) {
           var picklistValue = subTypeOptions[index].value;
           var optionValue = (picklistValue != null && picklistValue.includes('&amp;')) ? picklistValue.replace("&amp;", "&") : picklistValue;
            for (var key in subTypelocalizedMap) {
                if (key == optionValue) {
                    labelapimap.push({
                        "label": subTypelocalizedMap[key],
                        "value": key
                    });
                    break;
                }
            }
        }
        
        return labelapimap;
        
    },
    
    //fetching the activity type values
    //Called upon on change of Activity Type and from activity picker function on load of the activity page
    fetchActType: function (component) {
        var picValuelocalizedMap = component.get("v.apitoLabelConvert");
        var selectedSinglePickChildValue = [];
        var recordTypeDevName = component.get("v.recordtypeDeveloperName");
        //getting the dependent activity type picklist values by passing the controlling Activity Category value     
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelCategory"), component.get("v.ActivityTypes"));
	// [IPA] - Hide "Other" Activity Types from External User
	if(recordTypeDevName == $A.get("$Label.c.Core_MDF_EEF_RecordType") && component.get("v.externalper")){
            if(childValuesReturn != null && childValuesReturn.length > 0 ){
                var otherActTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
             if(component.get("v.checkCloneAttribute")) { 
                                if(otherActTypes.includes(component.get("v.SelActivityType"))) {
                                    component.set("v.SelActivityType", '');
                                }
                            }
		childValuesReturn = this.removePicklistValues(otherActTypes,childValuesReturn);
            }
        }
        if(component.get("v.mode") == 'edit' 
            && (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") )
            && component.get("v.SelCategory") == component.get("v.oldPFR.Core_MDF_ActivityCategory__c")) {
                if (!($A.util.isEmpty(component.get("v.oldPFR.Core_MDF_Activity_Types__c")))) {
                    selectedSinglePickChildValue = component.get("v.oldPFR.Core_MDF_Activity_Types__c").split(';');
                }     
                childValuesReturn = this.picklistValuesAddition(picValuelocalizedMap, selectedSinglePickChildValue, childValuesReturn);
                component.set("v.SelActivityType", component.get("v.oldPFR.Core_MDF_Activity_Types__c"));
        }
        if(childValuesReturn != null && childValuesReturn.length > 0 ){
            childValuesReturn.sort(this.case_insensitive_sort);
        }
        component.set("v.ActivityTypeValues", childValuesReturn);
        
    },
	//getting the dependent Domain Type picklist values by passing the controlling Activity Category value 
    fetchDomainTypeOptions: function(component) {
        if(component.get("v.DomainTypeOptions") != undefined && !$A.util.isEmpty(component.get("v.DomainTypeOptions")) && component.get("v.DomainTypeOptions").length > 0){
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelCategory"), component.get("v.DomainTypeOptions")[0]);
            if(childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1){
                childValuesReturn.sort(this.case_insensitive_sort);
                var localizedval = this.localizeSubType(component, childValuesReturn);
                component.set("v.DomainTypeOptions", localizedval);
            } 
        }      
    },

    fetchEventName: function (component) {
        //getting the dependent event name picklist values by passing the controlling Activity type value 
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var budType = component.get("v.selBudgetType");
        
        
        if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
        || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")
           ||  recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")  || recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_RetailProgram")){
            
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelActivityType"), component.get("v.EventNameMap"));
        if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1) {      
            	childValuesReturn.sort(this.case_insensitive_sort);
                var localizedval = this.localizeSubType(component, childValuesReturn);                      
                if((component.get("v.mode") != 'edit' && component.get("v.SelActivityType") == 'Other (Event)') ||
                       this.isOtherEventDefaultOnEdit(component) ){
                    for(var index = 0 ; index < localizedval.length; index++){
                        if(localizedval[index].value == 'Other'){
                            component.set("v.activityEventNameOptions", localizedval[index]);
                            component.set("v.selActivityEventName", localizedval[index].value);
                            component.set("v.showOtherEventName", true);
                            break;
                        }
                    }         
                }else{
                component.set("v.activityEventNameOptions", localizedval);
                }
                component.set("v.activityEventNameApplicable", true);
        }
        else {
            component.set("v.activityEventNameApplicable", false);
        }
    }
    },
    
    
    isOtherEventDefaultOnEdit: function (component) {
        
        var isOtherValueDefaulted = false;
        
        if((component.get("v.SelActivityType") != component.get("v.oldPFR.Core_MDF_Activity_Types__c") &&
            component.get("v.SelActivityType") == 'Other (Event)' && component.get("v.mode") == 'edit')
            || (component.get("v.SelActivityType") == 'Other (Event)' &&  (component.get("v.selActivityEventName") == 'Other' || component.get("v.oldPFR.Core_MDF_Event_Name_nm__c") == 'Other') 
                && component.get("v.mode") == 'edit')){
            isOtherValueDefaulted = true;
        }
        return isOtherValueDefaulted;
        
    },		
    //Method returns true if selected category belongs to 2025 Category values
    isLatestCategory: function (component) {
        var latestCategoryValues = component.get("v.latestCategoryValues");
        if(latestCategoryValues!=null && latestCategoryValues!='' && latestCategoryValues.length >0){
            return latestCategoryValues.some(item => item.value === component.get("v.SelCategory"));
        }
        return false;
    },
    //fetching the activity sub type values 
    //Called upon on change of Activity Type and from activity picker function
    fetchActSubTypeMulti: function (component) {
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelActivityType"), component.get("v.activityMultiSelSubType"));
        var isIn2025Category = this.isLatestCategory(component);
        
        if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1 && (isIn2025Category!=undefined && !isIn2025Category)) {
            if (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_Retail"))) {
                component.set("v.activitySubTypeAvailable", true);
                var localizedval = this.localizeSubType(component, childValuesReturn);
                component.set("v.activitySubTypeValues", localizedval);
            }
            
            if (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType")) || this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_EEF_RecordType")) || component.get("v.isOpalActivity") ) {
                component.set("v.activitySubTypeAvailable", true);
                //Commented below lines to fix defect DE117307 - Localisation changes
                //childValuesReturn.splice(0, 1);
                //DE117307 - Added below lines to display Subtype in localised text         
                 childValuesReturn.sort(this.case_insensitive_sort);       
                var localizedval = this.localizeSubType(component, childValuesReturn);                
                localizedval.splice(0, 1);               
                component.set("v.activityMultiSubTypeVal", localizedval);
            }
        }
        else {
            component.set("v.activitySubTypeAvailable", false);
        }
    },  
    
    //fetching the product type values    
    fetchProdType: function (component) {
        //getting the dependent product type picklist values by passing the controlling Target Audience value	  
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelTargetAudience"), component.get("v.ProductTypes"));
        component.set("v.ProductTypeValues", childValuesReturn);
    },
    
    //fetching the brand values    
    fetchBrandType: function (component) {
        //getting the dependent brand picklist values by passing the controlling Product Type value   	  
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelProductType"), component.get("v.BrandTypes"));
        component.set("v.BrandValues", childValuesReturn);
    },
    
    fetchApprovers: function(component){
        var mode = component.get("v.mode");        
        var budType = component.get("v.selBudgetType");
        var existingOwner = component.get("v.existingIntelOwner");
        var existingPrimaryOwner = component.get("v.existingPriIntelOwner");
        var selectedCountry = component.get("v.selectedCountryOptions");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
        var dispActiveOnly = true;
        var isPlannedEditLoaded = component.get("v.isEditPlanned");
        var actStatus = component.get("v.CurrentStatus");
        if(mode == 'edit' && !isPlannedEditLoaded && actStatus == 'Planned'){
            dispActiveOnly = false;
        }
        if ((this.isNotBlank(budType) && 
             (budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
              budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") ||
              budType == 'MDF' ||
              budType == 'MDF+')) ||
            (this.isNotBlank(recordTypeDeveloperName) && 
             recordTypeDeveloperName == 'Core_MDF_Retail_Marketing_Funds')) {
            this.calculateIntelContribution(component);
        }	
        var intelContri = component.get("v.intelContribution");
        //New Activity Category Type Change - replaced hard coded values with labels
        //For CMP Budget Types, display Intel owner only when Activity Category is Event/Event 2025 or Domain Type is EcosystemPartner.com with Intel Contribution >=50k (or) Activity Type is EcosystemPartner.com
        if(selectedCountry.length > 0 && this.isNotBlank(selectedCountry)  && this.isNotBlank(component.get("v.selectedPartner.Id")) && this.isNotBlank(component.get("v.selBudgetType")) ){
            if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
               || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")
               || ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))
                   && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) /*component.get("v.SelCategory") == "Event"*/ && (component.get("v.hideCompetitiveQuest") || component.get("v.renderVRQuestion")) 
&& intelContri >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold")) || ((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) 
                                                  && ((($A.get("$Label.c.Core_MDF_CMP_activity_type_eligible_for_approval").split(';')).includes(component.get("v.SelActivityType"))) && (component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Digital_Media") || (component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory") && component.get("v.SelDomainType") ==$A.get("$Label.c.Core_MDF_Domain_Type_Form_Values") && intelContri >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold")))))){
                                                  
                component.set("v.displayApprovers",true);
                var actionfetchActivityOwner = component.get("c.fetchActivityOwner");
                actionfetchActivityOwner.setCallback(this, $A.getCallback(function (response) {
                    var status = response.getState();
                    if(status==='SUCCESS'){
                        var result = response.getReturnValue();
                        if(result){
                            if(mode != 'edit'){
                                component.set("v.activityOwner", result.userName);
                                component.set("v.activityOwnerId", result.userId); 
                            }
                            else{
                                if(component.get("v.activatingaccper")){
                                component.set("v.activityOwner", existingOwner);
                                component.set("v.activityOwnerId", component.get("v.oldPFR.Core_MDF_Intel_Activity_Owner_Id__c")); 
                                }else if(component.get("v.primaryaccper")){
                                    component.set("v.activityOwner", existingPrimaryOwner);
                                    component.set("v.activityOwnerId", component.get("v.oldPFR.Core_MDF_Primary_Intel_Owner_Id__c"));
                                }else{
                                    component.set("v.activityOwner", existingOwner);
                                    component.set("v.activityOwnerId", component.get("v.oldPFR.Core_MDF_Intel_Activity_Owner_Id__c"));
                                }
                                 
                            }
                        }
                    }
                }))
                $A.enqueueAction(actionfetchActivityOwner);
                var selAppLst = component.get("v.selectedApproverOptions");
                if(this.isNotBlank(component.get("v.selectedPartner.Id")) && this.isNotBlank(component.get("v.recordtypeDeveloperName"))
                   && this.isNotBlank(component.get("v.selectedCountryOptions")) && this.isNotBlank(component.get("v.selBudgetType"))){
                    var actionfetchApprover = component.get("c.getIntelActivityOwners");
                    actionfetchApprover.setParams({
                        accId: component.get("v.selectedPartner.Id"),
                        primaryAcctId:component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id"),
                        program: component.get("v.recordtypeDeveloperName"),
                        country: component.get("v.selectedCountryOptions"),
                        budgetType: component.get("v.selBudgetType"),
                        isActEdit: dispActiveOnly
                    });
                    actionfetchApprover.setCallback(this, $A.getCallback(function (response) {
                        var result = response.getReturnValue();
                        var state = response.getState();
                        if(state === "SUCCESS" && result != null){
                            if(result.intelActivityOwnerList != null && result.intelActivityOwnerList.length >0){//intelActivityOwnerList :list of Intel Owners
                            var ownerValues = [];
                            var ownerList = "";
                                    for(var index = 0 ; index< result.intelActivityOwnerList.length; index++){
                                    ownerValues.push({
                                            label: result.intelActivityOwnerList[index].fullName,
                                            value: result.intelActivityOwnerList[index].userId                          
                                    });
                                        console.log('ownervalues-->',ownerValues);
                                        ownerList = ownerList+result.intelActivityOwnerList[index].userId;
                                        if (mode == 'edit' && recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_EEF_RecordType")) {
                                            if($A.get("$SObjectType.CurrentUser.Id") == ownerValues[index].value && component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")){
                                            component.set("v.isOPALApprover", true);
                                            this.SetAccMgrDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName );  
                                        }
                                    } 
                                }
                                component.set("v.AllApproverOptions",ownerValues);   
                                    console.log('intelOwnerApproveroptions-->',component.get("v.AllApproverOptions"));
                                    var intelAppList = component.get("v.AllApproverOptions");
                                    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                                        component.set("v.intelOwnerReq",true);                                    }
                                component.set("v.ApproverPicklistValues",ownerValues);  
                                if(selAppLst != null && selAppLst != "" && selAppLst != '' && !isPlannedEditLoaded){
                                    if(!ownerList.includes(selAppLst)){
                                        component.set("v.selectedApproverOptions","");
                                    }
                                }
                                    if(ownerValues != null && ownerValues.length == 1){
                                        component.set("v.selectedApproverOptions",ownerValues[0].value);   
                                    }
                                
                            }
                           
                            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") && (component.get("v.externalper") ||component.get("v.activatingaccper")))
                            {
                                if(result.intelPrimaryOwnerList != null && result.intelPrimaryOwnerList.length>0){ //intelPrimaryOwnerList :list of Primary Intel Owners
                                    var ownerValues = [];
                                    for(var index = 0 ; index< result.intelPrimaryOwnerList.length; index++){
                                        ownerValues.push({
                                            label: result.intelPrimaryOwnerList[index].fullName,
                                            value: result.intelPrimaryOwnerList[index].userId                          
                                        });
                                    }
                                    component.set("v.AllPrimaryApproverOptions",ownerValues);  
                                    component.set("v.PriApproverPicklistValues",ownerValues);  
                                    
                                    if(ownerValues != null && ownerValues.length == 1){
                                        component.set("v.selectedPrimaryApproverOptions",ownerValues[0].value);   
                                    }
                                }
                            }
                        }
                    }))  
                    $A.enqueueAction(actionfetchApprover);
                }
            }
            else{
                component.set("v.displayApprovers",false);
            }
        }
    },
    
    fetchExternalActSubmitters: function(component,resetUserSelection){
        //resetUserSelection parameter used to default to logged-in user on External Clone
        var mode = component.get("v.mode");
        var budType = component.get("v.selBudgetType");
        var isPlannedEditLoaded = component.get("v.isIntEditPlanned");
        var existingMAOwner = component.get("v.existingMemberActivityOwner");
        var selExtSubmitter = component.get("v.existingMemberActivityOwnerId");
        var dispActiveOnly = true;
        var isExternal = component.get("v.externalper");
        var actStatus = component.get("v.CurrentStatus");
        if(mode == 'edit' && !isPlannedEditLoaded && actStatus == 'Planned'){
            dispActiveOnly = false;
        }
	//Added by Ramapriya as part of TWC702 - 11331
        // Logged-in External Activity Submitter selected as default value for Member Acceptor for Opal Budget Types
        if(component.get("v.recordtypeDeveloperName") !=$A.get("$Label.c.Core_MDF_Retail_Program_Name") && isExternal && mode != 'edit'){
            var currentUserId = $A.get("$SObjectType.CurrentUser.Id");

            if(mode=='clone' && resetUserSelection){
                component.set("v.selectedExtActSubmitterOptions",[]);
            }
            if(component.get("v.selectedExtActSubmitterOptions")=='' && component.get("v.selectedExtActSubmitterOptions").length==0 && !component.get("v.selectedExtActSubmitterOptions").includes(currentUserId)){
                component.get("v.selectedExtActSubmitterOptions").push(currentUserId);
            }
    
            component.set("v.selectedExtActSubmitterOptions", component.get("v.selectedExtActSubmitterOptions"));
        }
        if(this.isNotBlank(component.get("v.selectedPartner.Id")) ){
            if(budType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budType == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
               || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")
              ){ 
                component.set("v.displayExtActSubmitters",true);
                component.set("v.showSpinner",true);
                var actionfetchActivityOwner = component.get("c.fetchActivityOwner");
                //setparams
                actionfetchActivityOwner.setCallback(this, $A.getCallback(function (response) {
                    var status = response.getState();
                    if(status==='SUCCESS'){
                        var result = response.getReturnValue();
                        component.set("v.showSpinner",false);
                        if(result){
                            if(mode != 'edit'){
                                component.set("v.activityExtOwner", result.userName); 
                                component.set("v.activityExtOwnerId", result.userId); 
                            }
                            else {
                                component.set("v.activityExtOwner", existingMAOwner);
                                component.set("v.activityExtOwnerId", component.get("v.oldPFR.Core_MDF_Member_Acceptor_Id__c")); 
                            }
                        }
                    }
                }))
                $A.enqueueAction(actionfetchActivityOwner);
                var selSubLst = component.get("v.selectedExtActSubmitterOptions");               
                var actionfetchExtActSubmitter = component.get("c.getMemberactivityOwners");
                actionfetchExtActSubmitter.setParams({
                    accId:component.get("v.selectedPartner.Id"),
                    isPlannedEdit: dispActiveOnly
                    
                });
                actionfetchExtActSubmitter.setCallback(this, $A.getCallback(function (response) {
                    var result = response.getReturnValue();
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var ownerValues = [];
                        var ownerList = "";
                        if(result.length>0){
                            for(var i = 0 ; i< result.length; i++){
                                ownerValues.push({
                                    label: result[i].fullName,
                                    value: result[i].userId
                                }); 
                                ownerList = ownerList+result[i].userId;
                                
                            }
                            component.set("v.AllExtActSubmitterOptions",ownerValues);   
                            component.set("v.ExtActSubmitterPicklistValues",ownerValues);  
                            if(selExtSubmitter != null && selExtSubmitter != "" && selExtSubmitter != '' && !isPlannedEditLoaded){
                                if(!ownerList.includes(selExtSubmitter)){
                                    component.set("v.selectedExtActSubmitterOptions",[]);
                                    component.set("v.isExtActSubmitterInactive",true);
                                }
                            }
                            
                        }
                    }
                }))  
                $A.enqueueAction(actionfetchExtActSubmitter);
            }
            else{
                component.set("v.displayExtActSubmitters",false);
            }
        }
    },
    calculateIntelContribution: function(component){
        var reqAmnt = component.get("v.newPFR.RequestedAmount");
        var reimbursementRate = component.get("v.SelReimbursementRate");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
        var budType = component.get("v.selBudgetType");
        var RR = reimbursementRate.replace('%', '');
        var intelContri = "";
        var incentivePercent = component.get("v.incentive");
        var mdfReimbursementAmtUsd = component.get("v.FlexiReimbursementAmt"); // Rishabh
        
        if((component.get("v.selBudgetType") == 'OEM CMP' || component.get("v.selBudgetType") == 'Service Provider CMP') && component.get("v.hideCompetitiveQuest") || component.get("v.renderVRQuestion")){
            if(component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == 'Yes' && component.get("v.newPFR.Core_MDF_Competitive_Elements__c") == 'Yes'){
                intelContri = (((reqAmnt * (+RR + +incentivePercent)/2))/100);   
            }
            else if(component.get("v.newPFR.Core_MDF_Competitive_Elements__c") == 'Yes' && (component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == 'No' || component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == null)){
                intelContri = ((reqAmnt * (RR/2))/100);   
            }
                else if((component.get("v.newPFR.Core_MDF_Competitive_Elements__c") == 'No' || component.get("v.newPFR.Core_MDF_Competitive_Elements__c") == null) && component.get("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c") == 'Yes'){
                    intelContri = ((reqAmnt * (+RR + +incentivePercent))/100);   
                }
                    else{
                        intelContri = ((reqAmnt * RR)/100);
                    }
        }
        else 
        {
		intelContri = ((reqAmnt * RR)/100);
        }
        
        if((budType == "MDF" || budType == "MDF+") &&  (mdfReimbursementAmtUsd !== null && mdfReimbursementAmtUsd !== undefined && mdfReimbursementAmtUsd.toString().trim() !== "" && !isNaN(mdfReimbursementAmtUsd))){
            component.set("v.intelContribution",mdfReimbursementAmtUsd);
        }else{
            component.set("v.intelContribution",intelContri);
        }
    },
    
    checkIsApproverActive: function(component){
        
        var mode = component.get("v.mode");
        var actStatus = component.get("v.CurrentStatus");
        var intelOwner = component.get("v.selectedApproverOptions");
        var selApp = "";
        if(intelOwner.length ==1){
            for(var i=0;i<intelOwner.length;i++){
                selApp=intelOwner[i];
            }
        }
        if ((mode == 'edit' || mode == 'clone') && (selApp != "") && this.isNotBlank(component.get("v.selectedPartner.Id") 
               && this.isNotBlank(component.get("v.recordtypeDeveloperName")) && this.isNotBlank(component.get("v.selectedCountryOptions"))
                                                                                                       && this.isNotBlank(component.get("v.selBudgetType")))) {
            if (component.get("v.externalper") ||component.get("v.activatingaccper")) {
                    component.set("v.showIntelOwnerSpinner", true);
                    var actionCheckApprover = component.get("c.checkApproverActive");
                    actionCheckApprover.setParams({
                        accId: component.get("v.selectedPartner.Id"),
                    primaryAcctId:'',
                        program: component.get("v.recordtypeDeveloperName"),
                        country: component.get("v.selectedCountryOptions"),
                        budgetType: component.get("v.selBudgetType"),
                        userId : selApp
                    });
                    
                    actionCheckApprover.setCallback(this, $A.getCallback(function (response) {
                        var result = response.getReturnValue();
                        var state = response.getState();
                        if(state === "SUCCESS"){
                            if(result == false){
                                component.set("v.isOwnerInactive",true);
                                if(actStatus != 'Planned'){
                                    component.set("v.selectedApproverOptions","");
                                }
                            }
                            else{
                                component.set("v.isOwnerInactive",false);
                            }
                        }
                        component.set("v.showIntelOwnerSpinner", false);
                    }))  
                    
                    $A.enqueueAction(actionCheckApprover);
                }
            }
    },
    
    checkIsPrimaryApproverActive: function(component){
        
        var mode = component.get("v.mode");
        var actStatus = component.get("v.CurrentStatus");
        var intelPriOwner = component.get("v.selectedPrimaryApproverOptions");
        var selPriApp = "";
        if(intelPriOwner.length ==1){
            for(var i=0;i<intelPriOwner.length;i++){
                selPriApp=intelPriOwner[i];
            }
        }
        if ((mode == 'edit' || mode == 'clone') && selPriApp!= "" && this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id"))
                                                                                                       && this.isNotBlank(component.get("v.recordtypeDeveloperName")) && this.isNotBlank(component.get("v.selectedCountryOptions"))
                                                                                                       && this.isNotBlank(component.get("v.selBudgetType"))) {
            if (component.get("v.externalper") ||component.get("v.activatingaccper")) {
                component.set("v.showIntelOwnerSpinner", true);
                var actionCheckApprover = component.get("c.checkApproverActive");
                actionCheckApprover.setParams({
                    accId:'',
                    primaryAcctId:component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id"),
                    program: component.get("v.recordtypeDeveloperName"),
                    country: component.get("v.selectedCountryOptions"),
                    budgetType: component.get("v.selBudgetType"),
                    userId : selPriApp
                });
                
                actionCheckApprover.setCallback(this, $A.getCallback(function (response) {
                    var result = response.getReturnValue();
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        if(result == false){
                            component.set("v.isOwnerInactive",true);
                            if(actStatus != 'Planned'){
                                component.set("v.selectedPrimaryApproverOptions","");
                            }
                        }
                        else{
                            component.set("v.isOwnerInactive",false);
                        }
                    }
                    component.set("v.showIntelOwnerSpinner", false);
                }))  
                
                $A.enqueueAction(actionCheckApprover);
            }
        }
    },
    
    
    
    checkIsSubmitterActive: function(component){
        
        var mode = component.get("v.mode");
        var actStatus = component.get("v.CurrentStatus");
        var extSumbmitter = component.get("v.selectedExtActSubmitterOptions");
        var selSub = "";
        if(extSumbmitter.length ==1){
            for(var i=0;i<extSumbmitter.length;i++){
                selSub=extSumbmitter[i];
            }
            if ((mode == 'edit' || mode == 'clone') && selSub != "") {
                if (component.get("v.accmgrper") ||  component.get("v.activatingaccper") || component.get("v.primaryaccper") ) {
                    component.set("v.showSpinner", true);
                    var actionCheckSubmitter = component.get("c.checkSubmitterActive"); 
                    actionCheckSubmitter.setParams({
                        accId: component.get("v.selectedPartner.Id"),
                        userId : selSub
                    });
                    
                    actionCheckSubmitter.setCallback(this, $A.getCallback(function (response) {
                        var result = response.getReturnValue();
                        var state = response.getState();
                        if(state === "SUCCESS"){
                            if(result == false){
                                component.set("v.isExtActSubmitterInactive",true);
                                if(actStatus != 'Planned'){
                                    component.set("v.selectedExtActSubmitterOptions",[]);
                                }
                            }
                            else{
                                component.set("v.isExtActSubmitterInactive",false);
                            }
                        }
                        component.set("v.showSpinner", false);
                    }))
                    
                    $A.enqueueAction(actionCheckSubmitter);
                }
            }
            
            
        }
    },
    //fetching the event format values    
    fetchEventFormat: function (component) {
        var metadata = [];
        var metadata = component.get("v.metadataMap");
        component.set("v.enableEventFormat", false);
        if(metadata){
            for (var index = 0; index < metadata.length; index++) {
                // Checking the condition for the Question and Pop-up beased on metadata map
                if (metadata[index].Core_MDF_Field_7_txt__c == component.get("v.SelCategory") && metadata[index].Core_MDF_Field_9_txt__c == component.get("v.SelActivityType") &&
                    metadata[index].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName") && metadata[index].Core_MDF_Checkbox_Field_4_Ind__c) {
                    component.set("v.enableEventFormat", true);
                    break;
                } else {
                    component.set("v.enableEventFormat", false);
                }
            }
        }
        if (component.get("v.enableEventFormat") || component.get("v.setEventFormatOptionOnload")) {
            //getting the dependent event format picklist values by passing the controlling Activity Type value
            var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelActivityType"), component.get("v.eventFormats"));
            component.set("v.eventFormatValues", childValuesReturn);
        }
    },
    fetchCampBudgetInfo : function(component,event,helper, loadbudget ){
        component.set("v.showSpinner",true);
        var budgetType = '';
        var isBudgetTypeAvailable = false;
        component.set("v.isBTSelAtCampaign",false);
        component.set("v.isCCFDCFRecType",false);
        component.set("v.showBudgetTypeFields", false);
        //Fetch Cmapaign Budget Records with Campaign Id, start and end date between Actiivty Date Range
       
            var action = component.get("c.fetchCampBudgetInfo");
            action.setParams({
                campRecordId: component.get("v.selectedLookUpRecord.Id"),
                startDate: component.get("v.newPFR.Core_MDF_Start_Date__c"),
                endDate: component.get("v.newPFR.Core_MDF_End_Date__c")
            });
            
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                var status = response.getState();
                if (status == "SUCCESS" && result != null) {
                    component.set("v.campaignBudgetList",result);   
                    component.set("v.showSpinner",false);
                    var BType= [];
                    if(result.length > 0){
                        for(var i = 0; i < result.length; i++){
                            //Form budget Type Picklist
                            if(component.get("v.selBudgetType") == result[i].Core_MDF_Budget_Type_Nm__c){
                                isBudgetTypeAvailable = true;
                            }
                            component.set("v.showBudgetErrorMsg",false);
                            if(!budgetType.includes(result[i].Core_MDF_Budget_Type_Nm__c)){
                                var budgetTypeLabel = this.getBudgetTypeLabel(component,result[i].Core_MDF_Budget_Type_Nm__c);	
                                BType.push({
                                    key: result[i].Core_MDF_Budget_Type_Nm__c,  
                                    value: budgetTypeLabel
                                    
                                });
                            }                 
                            
                            
                            if($A.util.isEmpty(budgetType)){
                                budgetType = result[i].Core_MDF_Budget_Type_Nm__c+';';
                            }else{
                                budgetType = budgetType + result[i].Core_MDF_Budget_Type_Nm__c+';';
                            }
                            component.set("v.isBTSelAtCampaign",true);
                        }
                        
                        if(!isBudgetTypeAvailable){
                            component.set("v.selBudgetType",null);
                        }
                    }else{
                        if(component.get("v.selectedLookUpRecord").Core_MDF_Opal_Budget_Type_Txt__c != 'CCF 1.0' && component.get("v.selectedLookUpRecord").Core_MDF_Opal_Budget_Type_Txt__c != 'DCF 1.0'){
                            
                            component.set("v.showBudgetErrorMsg",true);
                            component.set("v.showBudgetTypeFields", true);
                        }
                    }
                    if (BType.length > 1) {
                        
                        //Added extra condition to disable Budget Type field in Edit scenarios
                        //Condition to disable Budget Type field in Edit scenarios
                        if(component.get("v.mode") == "clone"){
                            component.set("v.singleBudgetType", false);
                        }
                        if(!component.get("v.checkCloneAttribute") && 
                           (((component.get("v.oldstatus") == "Pending Review" ||
                              component.get("v.oldstatus") == "Pending Approval") && 
                             component.get("v.opalAccountManagers") &&  
                             !component.get("v.isOPALApprover"))
                            || (component.get("v.externalper") && (component.get("v.oldstatus") == "Planned" || component.get("v.oldstatus") == "Pending Approval")))
                          ){
                            component.set("v.singleBudgetType",true); 
                        }
                        else if(!component.get("v.checkCloneAttribute") && component.get("v.oldstatus") != "Cancelled" && component.get("v.oldstatus") != "Planned" &&component.get("v.oldstatus") != "In-Progress" && component.get("v.oldstatus") != "Closed"){
                            component.set("v.singleBudgetType", false);
                        }
                    }else{
                        if(!$A.util.isEmpty(BType)){
                            component.set("v.selBudgetType",BType[0].key);
                        }
                        component.set("v.singleBudgetType", true);
                    }
                    component.set("v.budgetTypeVal", BType);
                    if(component.get("v.priceReviewersPer")) {
                        component.set("v.singleBudgetType", true);
                    }
                    
                    this.getAvailableBudget(component,event,null);
                    
                    this.setActCatType(component,event, helper,budgetType);
                    
                }else{
                    component.set("v.showSpinner",false);
                }
            });
            $A.enqueueAction(action);
        
    },
    
    //Fetching budget data for RMF Activities
    fetchBudgetInfo : function(component){
        component.set("v.showSpinner",true);
        var availableBudget = [];
        
        var campaign = component.get("v.selectedLookUpRecord");
        var ultimateAccId = component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c");
        console.log(ultimateAccId);

        var mode = component.get("v.mode");
        var currentBudgetIdVal = null;

        // Only include current selected Budget if in EDIT mode
        if(mode && mode.toLowerCase() === 'edit') {
            var oldPfrRef = component.get("v.oldPFR");
            var newPfrRef = component.get("v.newPFR");

            if (oldPfrRef && oldPfrRef.BudgetId ) {
                currentBudgetIdVal = oldPfrRef.BudgetId ;
            } else if (newPfrRef && newPfrRef.BudgetId) {
                currentBudgetIdVal = newPfrRef.BudgetId ;
            } else if (component.get("v.selAvailableBudget")) {
                currentBudgetIdVal = component.get("v.selAvailableBudget");
            }
        }

        var action = component.get("c.fetchBudgetInfo");
            action.setParams({
                accountId: ultimateAccId,
                startDate: component.get("v.newPFR.Core_MDF_Start_Date__c"),
                endDate: component.get("v.newPFR.Core_MDF_End_Date__c"),
                budgetType: component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c"),
                isIPAAccBased: false,
                currentBudgetId: currentBudgetIdVal
            });
    
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                var status = response.getState();
                if (status == "SUCCESS"){
                    if (result != null && result.length!=0) {
                        if(result.length > 0){
                            for(var index = 0; index < result.length; index++){
                                var startDate = result[index].StartDate.replaceAll('-','/');
                                var endDate = result[index].EndDate.replaceAll('-','/');
                                    availableBudget.push(
                                    {
                                        key: result[index].Id,
                                        value: result[index].Core_MDF_budget_ref_nbr__c +' : ' +result[index].Title + ' : ' + result[index].Core_MDF_Budget_Type_Txt__c+' : '+startDate + ' - ' + endDate 
                                    });
                            }
                        }
                        component.set("v.showBudgetErrorMsg",false);
                        component.set("v.budgetStr", availableBudget);
                        if(availableBudget!= null && availableBudget.length==1)
                        {
                            component.set("v.selAvailableBudget",availableBudget[0].key);
                        }
                        
                    }else{
                        component.set("v.showBudgetErrorMsg",true);
                        component.set("v.budgetStr",'');
                        component.set("v.selAvailableBudget",'');
                    }
                }else{
                    var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                    this.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
                this.checkAvailAllocationAmt(component);
                component.set("v.showSpinner",false);
            });
        
    
        $A.enqueueAction(action);
            
        },
    
    
    
    setActCatType : function(component,event, helper,budgetType){
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")||recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_PFR_CCF")||recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_PFR_DCF")
          ||  recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            this.updateCountryPickVals(component);
            this.updateBrandPickVals(component);
        }
        
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")){
            this.updateInitiativesVals(component);
        }
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){ //for industry values in EEF
            this.updateIndustryPickVals(component);
        }
        
        
        if(!$A.util.isEmpty(budgetType)){
            
            component.set("v.isBTSelAtCampaign",true);
            
            if(recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                component.set("v.isCCFDCFRecType",true);
            }            
            
            var opalBTs =  budgetType;
            if (opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_CMP")) ||
                opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) ||
                opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_MDF")) || 
                opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_MDFPlus"))) {
                component.set("v.isOpalActivity",true);
               
                 component.set("v.CPLed",true);
                 
                 this.populateActCatType(component, event, helper);
                 this.updateCountryPickVals(component);
		 this.updateBrandPickVals(component);
                this.updateIndustryPickVals(component);
             }else{
                 component.set("v.isOpalActivity",false);
             }
      
  }
    if(component.get("v.selectedLookUpRecord.Id") == undefined || component.get("v.selectedLookUpRecord.Id") ==null){
        //Resetting attribute values on Campaign selection modification
        component.set("v.isBTSelAtCampaign",false);
        component.set("v.isOpalActivity",false); 
        component.set("v.showBudgetTypeFields", false);
        component.set("v.isBudgetTypeFlexible",false);
        component.set("v.selBudgetType",'');
        component.set("v.singleBudgetType", false);
        component.set("v.SelReimbursementRate",'');
        component.set("v.FlexiReimbursementAmt",'');
        component.set("v.selectedCountryOptions",'');
        component.set("v.disableRRPercent",false);
        component.set("v.AllCountryOptions",component.get("v.AllCountryOptionsMain"));
        component.set("v.CountryPicklistValues",component.get("v.AllCountryOptionsMain"));
        component.set("v.newPFR.BudgetId", null);  
        component.set("v.newPFR.AllocationId", null);  
        component.set("v.newPFR.Core_MDF_Budget_id__c",null);
        component.set("v.selAvailableBudget",null);      
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                component.set("v.showBudgetErrorMsg",false);
                component.set("v.selectedPrimaryApproverOptions",[]);
                component.set("v.AllPrimaryApproverOptions",[]);
                component.set("v.AllApproverOptions",[]);
                component.set("v.selectedApproverOptions",[]);
                component.set("v.intelOwnerReq",false);
                      }
        
    }
    
},
    resetHelper: function (component) {
        var budType = component.get("v.selBudgetType");
        component.set("v.PopupButtonValue", false);
        component.set("v.ELCPopupButtonValue", false);
        component.set("v.PopupType", null);
        component.set("v.renderPrintQuestion", false);
        component.set("v.renderGovtQuestion", false);
        component.set("v.renderTechExplorationQuestSection", false);
        component.set("v.checkbudgetcondition", false);
        component.set("v.recordApplicableForActivityRules", true);
        if(((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory"))) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            component.set("v.hideCompetitiveQuest", false);
        }
        if((budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP")) && ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory"))  && (component.get("v.SelActivityType") == 'Joint Event' || component.get("v.SelActivityType") == 'Third Party Event')) {
            component.set("v.newPFR.Core_MDF_Competitive_Elements__c",null);
        }
        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",null);
        //Variable Reimbursement Rate changes
        component.set("v.renderVRQuestion", false);
        component.set("v.competetiveElement",null);
        component.set("v.incentivePercent",null);
        
        
    },
    //Rs
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
fileUploadMandatoryAndEventFormVisibility : function(component){
    
    if(this.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType"))){
        //New Activity Category Type Change
        if ( ($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) /*(component.get("v.SelCategory") == (component, $A.get("$Label.c.Core_MDF_Activity_Category_Event")))*/ && component.get("v.checkbudgetcondition"))
        {     
            component.set('v.isEventFormTemplateVisible',true);
            component.set('v.isIndustryPartnerFormTemplateVisible', false);
        } else if(component.get("v.SelActivityType") == (component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) || ($A.get("$Label.c.Core_MDF_Domain_Type_Form_Values").split(';')).includes(component.get("v.SelDomainType")) )
        {
            component.set('v.isIndustryPartnerFormTemplateVisible', true);
            component.set('v.isEventFormTemplateVisible',false);
        }
         else{
	       component.set('v.isEventFormTemplateVisible',false);
           component.set('v.isIndustryPartnerFormTemplateVisible', false);
	   }
	 }
    else{component.set('v.isEventFormTemplateVisible', false);
        component.set('v.isIndustryPartnerFormTemplateVisible', false);}
        //Check if External User is editing Activity
        if(component.get("v.externalper")){
            //Upload of file mandatory 
            //Category -- Event, Activity Type not promotion 
            //Activity Type -- content Creation - move component.get("v.oldPFR.Core_MDF_Activity_Types__c") == $A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation") in 1st 
            //Validate if Old Activity Type -- Content Creation 
            if(component.get("v.oldPFR.Core_MDF_Activity_Types__c") == $A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation")){
                //Validate if Selected Activity Category Event or
                //Activity Type Content Creation and Activity Type not Promotion and Content Creation
                if(component.get("v.SelActivityType") != $A.get("$Label.c.Core_MDF_Activity_Type_Promotion") && 
                   ((($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory")) /*(component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")*/
                     || component.get("v.SelActivityType") == $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) ||
                    !(component.get("v.SelActivityType") == $A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
                   )
                  ){
                    component.set("v.fileexceptionper",false);
                }
            }else{
                //component.set("v.fileexceptionper",true);
            }
        }
    },
    SetAccMgrDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var hasPerSet = component.get("v.accmgrper");
        var mapVar = [];
        var mapVar = component.get("v.disabledMap");
        var frstatus = component.get("v.CurrentStatus");
        var actgry = component.get("v.SelCategory");
        
        if (hasPerSet == true ) {
            //Fields editable In-Progress Event Activity 
            if (
                frstatus == "In-Progress" &&
                actgry == "Event" &&
                this.budgetAmountThresholdCheck(component)
            ) {
                mapVar.attachement = false;
                mapVar.frstatus = false;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.availableBudget= true;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.initiative = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.EventOtherName = true;
                mapVar.EventName = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.edate = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;                
                mapVar.reimbursement = true; //Reimbursement Rate
                mapVar.priority = true; //Priority
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                component.set("v.ApprovalException", true);
            } 
            else if(!$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName) && !$A.get("$Label.c.Core_MDF_IPA_RecordType").includes(recordTypeDeveloperName) && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != true){
                if (frstatus == 'In-Progress') {// user can edit not sure on theh fields
                    component.set("v.ApprovalException", true);
                   //OPAL Changes Start-To disable editing opal Activities in In-Progress Status
                    if(component.get("v.isOpalActivity")){
                        this.setOPALActDisableState(component,mapVar);
                        //Allow MemberOwner edit for InProgress Status
                        if(frstatus == "In-Progress"){
                            
                            
                            component.set("v.isSaveDisable", false);
                        }
                    }
                    //OPAL Changes End
                }
                //Activity status is planned and program is opal CCF/DCF
                else if (frstatus == "Planned" && 
                         component.get("v.isOpalActivity")
                        ) {
                    component.set("v.singleBudgetType", true);
                    component.set("v.isSPIFSecReadOnly", false);
                    component.set("v.disableRRPercent", false);
                    
                }
                
                // else if(!$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)){
                /*Activity status is planned and program is CCF/DCF/SPCF/CCFB */ 
                    else if (frstatus == 'Planned'){ 
                        component.set("v.ApprovalException", true);
                        component.set("v.isSPIFSecReadOnly", false);
                    }/*Activity status is Closed and program is CCF/DCF/SPCF/CCFB */ 
                        else if (frstatus == 'Closed') {
                            component.set("v.ApprovalException", true);
                            //OPAL Changes Start - To disable editing opal Activities in In-Progress Status
                            if(component.get("v.isOpalActivity")){
                                this.setOPALActDisableState(component,mapVar);
                            }
                            //OPAL Changes End
                            
                        }
                /* OPAL Changes Start - To disable editing opal Activity in Cancelled Status*/ 
                            else if (frstatus == "Cancelled" && component.get("v.isOpalActivity")) {
                                this.setOPALActDisableState(component,mapVar);
                            }
                
                //OPAL Changes - To make Account field as Read only and SPIF Sec as editable in Rev Required status for CCF/DCF programs
                                else if (frstatus == "Revision Required" && component.get("v.isOpalActivity")) {
                                    mapVar.acct = true;
                                    mapVar.cmpgn = true;
                                    component.set("v.isSPIFSecReadOnly", false);
                                }
                                    else if (frstatus == "Pending Approval" && component.get("v.isOpalActivity")) {
                                        mapVar.acct = true;
                                        component.set("v.isSPIFSecReadOnly", false);
                                        this.setOPALActDisableState(component,mapVar);
                                    }
                //Edit in pending review status
                
                                        else if (frstatus == "Pending Review" && component.get("v.isOpalActivity")){
                                         
                                            if(component.get("v.newPFR.Core_MDF_Approval_Step_Completed__c") == 0 && component.get("v.isOPALApprover")){
                                                mapVar.acct = true;
                                                mapVar.memberOwner =false;
                                                mapVar.cmpgn = true;
                                                component.set("v.isSPIFSecReadOnly", false);
                                                component.set("v.isSaveDisable", false);
                                                component.set("v.isSaveandNewDisable", false);
                                               
                                            }else{
                                               
                                                this.setOPALActDisableState(component,mapVar);
                                            }
                                            
                                        }
                //OPAL changes end
            }
                else if($A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)){
                    /*Activity status is planned and program is Retail Marketing Funds */ 
                    if (frstatus == 'In-Progress') {
                        component.set("v.ApprovalException", true);
                        } else if (frstatus == 'Planned') {
                            /*Activity status is planned and program is Retail Marketing Funds */
                            var today = this.getTodayDateLocalTime();
                            // if activty start date passed todays date - diabling all fields on edit.
                            if(component.get("v.newPFR.Core_MDF_Start_Date__c") < today ) {
                                component.set("v.disableRSMMetricEditability", true);
                                //Commented below code -To enable edit access for RSM to the fields that don't trigger re-approval   
                                if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")) {
                                    document.querySelector("#pivot").scrollIntoView();
                                } else {
                                    window.scrollTo(0, 0);
                                }
                            }
                        }
                            else if (frstatus == 'Closed') {
                                component.set("v.ApprovalException", true);
                                
                            }
                        //Lock the fields during (i)pending Approval status or  (ii) Pending Review with Geo other than Emea
                                else if (frstatus == "Pending Approval" || frstatus == "Pending Review") {
                                    component.set("v.isSaveDisable", false);
                                } else if(frstatus == "Revision Required") {
                                    component.set("v.isSPIFSecReadOnly", false);
                                    mapVar.cmpgn = true;
                                }
                    }
            component.set("v.disabledMap", mapVar);
        }
    },
  
    setRMFReviewerDisabledState: function (component) {
        //Emea Geo Activity is editable in Pending Review, which is not in Approval Queue
        //Check if User has RMF Reviewer permission 
        var hasPerSet = component.get("v.rsmActivityReviewerper");
        var isInApprovalQueue = false;
        var frstatus = component.get("v.CurrentStatus");
        if (hasPerSet) {
            var mapVar = component.get("v.disabledMap");
            component.set("v.isSaveDisable", true);
            //If User is RMF Reviewer, then validate if Emea Activity is already in Approval Queue,If in Approval Queue no fields are editable else all fields are ditable
            isInApprovalQueue = component.get("v.activityInApproval");
            if (!isInApprovalQueue && frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") &&
                $A.get("$Label.c.Core_MDF_ActReviewRequiredGeos").includes(component.get("v.oldPFR.Core_MDF_Region_nm__c"))) { 
                mapVar.edate = false;
                mapVar.frstatus = false;
                mapVar.desc = false;
                mapVar.budget = false;
                mapVar.country = false;
                mapVar.cmpgn = true;
                mapVar.availableBudget = false;
                mapVar.acct = false;
                mapVar.sdate = false;
                mapVar.name = false;
                mapVar.audience = false;
                mapVar.prodtype = false;
                mapVar.brand = false;
                mapVar.initiative = false;
                mapVar.category = false;
                mapVar.type = false;
                mapVar.EventOtherName = false;
                mapVar.EventName = false;
                mapVar.cpled = false;
                mapVar.cp = false;
                mapVar.ocp = false;
                mapVar.attachement = false;
                mapVar.questions = false;
                mapVar.jointcontent = false;
                mapVar.reimbursement = false; //Reimbursement Rate
                mapVar.priority = false;
                mapVar.vrquestions = false;
                mapVar.eventFormat = false;
                component.set("v.isSaveDisable", false);
            }
            component.set("v.disabledMap", mapVar);
        }
    },
    validateIfActivityInApproval: function (component) {
        var action = component.get("c.validateIfInApprvlQue");
        action.setParams({
            pfrId: component.get("v.recordId")
        });  
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.activityInApproval", response.getReturnValue())
            }
        });
        $A.enqueueAction(action);
    },
    //Disable fields if its an Geo Approver
    SetGeoApproverDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var permissionsetArray = [];
        var hasPerSet = component.get('v.retailgeouserper');
        var mapVar = [];
        var frstatus = component.get("v.CurrentStatus");
        if (hasPerSet == true) {
            mapVar = {
                'frstatus': false,
                'name': false,
                'desc': false,
                'sdate': false,
                'edate': false,
                'budget': false,
                'initiative' : false,
                'cmpgn': false,
                'acct': false,
                'availableBudget': false,
                'country': false,
                'audience': false,
                'prodtype': false,
                'brand': false,
                'category': false,
                'type': false,
                'EventName' : false,
                'EventOtherName' : false,
                'cpled': false,
                'cp': false,
                'ocp': false,
                'attachement': false,
                'questions': false,
                'jointcontent': false,
                'priority' : false,
                'reimbursement':false,
                'vrquestions': false,
                'eventFormat' : false
            };
            if (frstatus == 'Rejected') {
                mapVar.frstatus = false;
                mapVar.edate = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.availableBudget= true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.initiative = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.EventOtherName = true;
                mapVar.EventName = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.attachement = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.priority = true; //Priority
                mapVar.reimbursement = true;
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                component.set("v.ApprovalException", true);
            } else {
                mapVar.attachement = true;
                mapVar.frstatus = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.budget = true;
                mapVar.availableBudget= true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.initiative = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.EventOtherName = true;
                mapVar.EventName = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.edate = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.priority = true; //Priority
                mapVar.reimbursement = true;
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                component.set("v.ApprovalException", true);
            }
            component.set("v.disabledMap", mapVar);
            
        }
       
    },
    /*Test code end*/
    //Disable fields if its an auditor
    SetAuditorDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var permissionsetArray = [];
        var hasPerSet = component.get('v.auditorper');
        var mapVar = [];
        var frstatus = component.get("v.CurrentStatus");
        var mapVar = component.get("v.disabledMap");
       
        
        if (hasPerSet == true) {
            if (frstatus == 'In-Progress') {
                component.set("v.ApprovalException", true);
                //OPAL Changes Start - To disable editing opal Activities in In-Progress Status
                if(component.get("v.isOpalActivity")) {
                    component.set("v.singleBudgetType", true);
                    component.set("v.disableRRPercent", true);
                    component.set("v.isSPIFSecReadOnly", true);
                      }
                //OPAL Changes End
            }
            //OPAL Changes Start - To disable editing opal Activities in Closed/Cancelled Status
                    else if((frstatus == "Cancelled" || frstatus == "Closed") && component.get("v.isOpalActivity")) {
                        this.setOPALActDisableState(component,mapVar);
                    }
            // OPAL Change end
            
            component.set("v.disabledMap", mapVar);
        }
        
       
    },
    
    // Function to control External users edit scenarios.
    SetExternalDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var permissionsetArray = [];
        var hasPerSet = component.get('v.externalper');
        var mapVar = [];
        if(component.get("v.disabledMap") != null){
            mapVar = component.get("v.disabledMap");
        }
        var frstatus = component.get("v.CurrentStatus");
        
        
        if (hasPerSet == true) {
            
            if (frstatus == 'In-Progress') {
                component.set("v.ApprovalException", true);
                //OPAL Changes Start- To disable editing opal Activities in In-Progress Status
                if(component.get("v.isOpalActivity")) {
                    this.setOPALActDisableState(component,mapVar);
                    // Allow MemberOwner Field edit for InProgress Status
                    if(frstatus == "In-Progress"){
                        component.set("v.isSaveDisable", false);
                    }
                }
                //OPAL Changes End
            } else if (
                frstatus == "Revision Required" && 
                ((  // Included Activity Category, Type check for Digital 2025 and Event 2025 to disable file upload error on edit
                    (((this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Event_Activity_Category")) &&
                      this.budgetAmountThresholdCheck(component)) || (this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) || ((($A.get("$Label.c.Core_MDF_Domain_Type_Form_Values").split(';')).includes(component.get("v.SelDomainType"))) && this.budgetAmountThresholdCheck(component) ))) && (this.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType"))))
                ) 
                 ||
                 (
                     this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
                 )) 
            )  
            {
                //If Event or Content Creation Activity is Revision Required enable below fields for edititng
                mapVar.acct = true;
                mapVar.cmpgn = true;
                this.setFileUploadForUser(component);
                
            }else if (// Included Activity Category, Type check for Digital 2025 and Event 2025 to disable file upload error on edit
                frstatus == "Planned"   && ((this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) || ((($A.get("$Label.c.Core_MDF_Domain_Type_Form_Values").split(';')).includes(component.get("v.SelDomainType"))) && this.budgetAmountThresholdCheck(component)))||
                                            (this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Event_Activity_Category")) &&
                                            !this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_Promotion")) &&
                                            this.budgetAmountThresholdCheck(component)))
            ){
                
                this.setFileUploadForUser(component);
            }
                
                
                
                else if( 
                    frstatus == "Planned"  &&
                    this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
                ){
                    this.setFileUploadForUser(component);
                }
            // OPAL Change start
            if (
                $A.get("$Label.c.Core_MDF_PFR_DCF").includes(recordTypeDeveloperName) || $A.get("$Label.c.Core_MDF_PFR_CCF").includes(recordTypeDeveloperName)) {
                if (frstatus == "Revision Required" || frstatus == "Planned") {
                    component.set("v.isSPIFSecReadOnly", false);
                }
            }
            if( $A.get("$Label.c.Core_MDF_PFR_DCF").includes(recordTypeDeveloperName) || $A.get("$Label.c.Core_MDF_PFR_CCF").includes(recordTypeDeveloperName) ){
                if((frstatus == "Cancelled"  || frstatus == "Closed" || frstatus == "Pending Approval"|| frstatus == 'Pending Review') && component.get("v.isOpalActivity")){
                    this.setOPALActDisableState(component, mapVar);
                }
            }
            //disable external user to edit palnned opal activity		
            //OPAL Changes Start - To disable editing opal Activities in Closed/Cancelled/planned Status
            if((frstatus == "Cancelled" ||frstatus == "Planned" || frstatus == "Closed" || frstatus == "Pending Approval") && component.get("v.isOpalActivity")) {
                this.setOPALActDisableState(component,mapVar);
                //TWC702-365 :To allow edits for opal planned Activity 
                if(frstatus == "Planned"){
                   component.set("v.isSPIFSecReadOnly", false);
                    if(component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")){
                        component.set("v.disableRRPercent", false);
                    }else{
                        component.set("v.disableRRPercent", true);
                    }
                    component.set("v.isSaveDisable", false);
                }	
            }
            // OPAL Change end
            component.set("v.disabledMap", mapVar);
        }
        var userPermission = component.get("v.userperMap");
        if (frstatus == "Pending Review" && userPermission!={} && (userPermission["externalper"] || userPermission["rmfexternalper"])
           ){
            	mapVar.type = true;
                mapVar.EventOtherName = true;
                mapVar.EventName = true;
            	mapVar.prodtype = true;
            	mapVar.category = true;
                mapVar.frstatus= true;
                mapVar.name = true;
                mapVar.availableBudget = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.edate = true;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.industry= true;
                mapVar.brand = true;
            	mapVar.initiative = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.attachement = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.priority = true;
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
            	component.set("v.disabledMap", mapVar);
        }
        
        
        
    },
    //OPAL Changes Start - Reusable helper method to disable editing all fields for OPAL Activities
    setOPALActDisableState: function(component,mapVar) {
        component.set("v.singleBudgetType", true);
        component.set("v.disableRRPercent", true);
        component.set("v.isSPIFSecReadOnly", true);
        component.set("v.isSaveDisable", false);
        component.set("v.isSaveandNewDisable", true);
    },
    //OPAL Changes End
    //US1109882 - changes start
    setDualRoleEditability: function(component){
        
        var mapVar = component.get("v.disabledMap");
        var frstatus = component.get("v.CurrentStatus");
        var today = this.getTodayDateLocalTime();
        var actClosureType =  component.get("v.activityClosureType");
        var actStartDate = component.get("v.oldsdate");
        var cpLed = true;
        var isCP = component.get("v.IsCP");
        if (isCP) {
            cpLed = false;
        }        
        
        mapVar.frstatus = false;
        mapVar.name= false;
        mapVar.desc= false;
        mapVar.sdate= false;
        mapVar.edate= false;
        mapVar.budget = false;
        mapVar.cmpgn= false;
        mapVar.acct= false;
        mapVar.country= false;
        mapVar.audience= false;
        mapVar.availableBudget= false;
        mapVar.prodtype= false;
        mapVar.brand= false;
        mapVar.initiative = false;
        mapVar.category =false;
        mapVar.type= false;
        mapVar.tactics =false;
        mapVar.cpled= cpLed;
        mapVar.cp= false;
        mapVar.ocp= false;
        mapVar.attachement= false;
        mapVar.questions= false;
        mapVar.jointcontent= false;
        mapVar.reimbursement= false; //Reimbursement Rate
        mapVar.priority= false;
        //Variable Reimbursement Rate changes
        mapVar.vrquestions= false;
        mapVar.eventFormat= false;
        // [OEM Integration - CCF/DCF] - [Activity] - Two Additional Fields
        mapVar.Attr_Var_Pos= false;
        mapVar.Attr_Var_Neg= false;
        // BU split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
        mapVar.buSplit = false;
        mapVar.buSplitFld= false;
        
        /*Activity status is planned and program is Retail Marketing Funds */ 
        if (frstatus == 'In-Progress') {
            mapVar.edate = false;
            mapVar.desc = false;
            mapVar.budget = false;
            mapVar.availableBudget = false;
            mapVar.country = true;
            mapVar.frstatus = false;
            mapVar.cmpgn = true;
            mapVar.acct = true;
            mapVar.sdate = false;
            mapVar.name = false;
            mapVar.audience = true;
            mapVar.prodtype = true;
            mapVar.brand = true;
            mapVar.initiative = true;
            mapVar.category = true;
            mapVar.type = true;
            mapVar.tactics = true;
            mapVar.EventOtherName = true;
            mapVar.EventName = true;
            mapVar.cpled = true;
            mapVar.cp = true;
            mapVar.ocp = true;
            mapVar.attachement = true;
            mapVar.questions = true;
            mapVar.jointcontent = true;
            mapVar.reimbursement = true; //Reimbursement Rate
            mapVar.priority = true; //Priority
            mapVar.vrquestions = true;
            mapVar.eventFormat = true;
            mapVar.Attr_Var_Pos = true;
            mapVar.Attr_Var_Neg = true;
            component.set("v.ApprovalException", true);
        } else if (frstatus == 'Planned') {
            
            mapVar.edate = false;
            mapVar.desc = false;
            mapVar.budget = false;
            mapVar.country = false;
            mapVar.frstatus = false;
            mapVar.availableBudget = false;
            mapVar.cmpgn = true;
            mapVar.acct = true;
            mapVar.sdate = false;
            mapVar.name = false;
            mapVar.audience = false;
            mapVar.prodtype = false;
            mapVar.brand = false;
            mapVar.initiative = false;
            mapVar.category = true;
            mapVar.type = true;
            mapVar.tactics = true;
            mapVar.EventOtherName = true;
            mapVar.EventName = true;
            mapVar.cpled = true;
            mapVar.cp = true;
            mapVar.ocp = true;
            mapVar.attachement = false;
            mapVar.questions = true;
            mapVar.jointcontent = true;
            mapVar.reimbursement = true; //Reimbursement Rate
            mapVar.priority = true; //Priority
            mapVar.vrquestions = true;
            mapVar.eventFormat = true;
            
            if (actStartDate < today) {
                mapVar.edate = false;
                mapVar.frstatus = false;
                mapVar.desc = false;
                mapVar.budget = false;
                mapVar.country = false;
                mapVar.cmpgn = true;
                mapVar.acct = false;
                mapVar.sdate = false;
                mapVar.availableBudget = false;
                mapVar.name = false;
                mapVar.audience = false;
                mapVar.prodtype = false;
                mapVar.brand = false;
                mapVar.initiative = false;
                mapVar.category = false;
                mapVar.type = false;
                mapVar.tactics = false;
                mapVar.EventOtherName = false;
                mapVar.EventName = false;
                mapVar.cpled = false;
                mapVar.cp = false;
                mapVar.ocp = false;
                mapVar.attachement = false;
                mapVar.questions = false;
                mapVar.jointcontent = false;
                mapVar.reimbursement = false; //Reimbursement Rate
                mapVar.priority = false; //Priority
                mapVar.vrquestions = false;
                mapVar.eventFormat = false;
                component.set("v.checkGeoLeadMetricSecEditability",true);
                component.set("v.isSaveandNewDisable",false);
                component.set("v.isSaveDisable",false);
                if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")) {
                    document.querySelector("#pivot").scrollIntoView();
                } else {
                    window.scrollTo(0, 0);
                }
            }
        } else if(frstatus == 'Revision Required'){
            mapVar.edate = false;
            mapVar.frstatus = false;
            mapVar.desc = false;
            mapVar.budget = false;
            mapVar.country = false;
            mapVar.cmpgn = true;
            mapVar.acct = false;
            mapVar.availableBudget = false;
            mapVar.sdate = false;
            mapVar.name = false;
            mapVar.audience = false;
            mapVar.prodtype = false;
            mapVar.brand = false;
            mapVar.initiative = false;
            mapVar.category = false;
            mapVar.type = false;
            mapVar.tactics = false;
            mapVar.EventOtherName = false;
            mapVar.EventName = false;
            mapVar.cpled = false;
            mapVar.cp = false;
            mapVar.ocp = false;
            mapVar.attachement = false;
            mapVar.questions = false;
            mapVar.jointcontent = false;
            mapVar.reimbursement = false; //Reimbursement Rate
            mapVar.priority = false; //Priority
            mapVar.vrquestions = false;
            mapVar.eventFormat = false;
            component.set("v.checkGeoLeadMetricSecEditability",true);
            component.set("v.isSaveandNewDisable",false);
            component.set("v.isSaveDisable",false);
        }
            else if (frstatus == 'Closed') {
	        mapVar.Attr_Var_Pos= true;
                mapVar.Attr_Var_Neg= true;
                mapVar.frstatus = false;
                mapVar.edate = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.budget = false;
                mapVar.availableBudget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.initiative = true
                mapVar.category = true;
                mapVar.type = true;
                mapVar.tactics = true;
                mapVar.EventOtherName = true;
                mapVar.EventName = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.attachement = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.reimbursement = true; //Reimbursement Rate
                mapVar.priority = true; //Priority
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                component.set("v.ApprovalException", true);
                if(actClosureType == 'No Internal Approval'){
                    mapVar.edate = false;
                    mapVar.frstatus = false;
                    mapVar.desc = false;
                    mapVar.budget = false;
                    mapVar.country = false;
                    mapVar.cmpgn = false;
                    mapVar.availableBudget = false; 
                    mapVar.acct = false;
                    mapVar.sdate = false;
                    mapVar.name = false;
                    mapVar.audience = false;
                    mapVar.prodtype = false;
                    mapVar.brand = false;
                    mapVar.initiative = false;
                    mapVar.category = false;
                    mapVar.type = false;
                    mapVar.tactics = false;
                    mapVar.EventOtherName = false;
                    mapVar.EventName = false;
                    mapVar.cpled = false;
                    mapVar.cp = false;
                    mapVar.ocp = false;
                    mapVar.attachement = false;
                    mapVar.questions = false;
                    mapVar.jointcontent = false;
                    mapVar.reimbursement = false; //Reimbursement Rate
                    mapVar.priority = false; //Priority
                    mapVar.vrquestions = false;
                    mapVar.eventFormat = false;
                    component.set("v.checkGeoLeadMetricSecEditability",true);
                    component.set("v.isSaveandNewDisable",true);
                    component.set("v.isSaveDisable",false);
                }
            }
        //Lock the fields during (i)pending Approval status or  (ii) Pending Review with Geo other than Emea
                else if (frstatus == "Pending Approval" || frstatus == "Pending Review") {
                    mapVar.Attr_Var_Pos= true;
                    mapVar.Attr_Var_Neg= true;
                    mapVar.edate = true;
                    mapVar.desc = true;
                    mapVar.budget = true;
                    mapVar.country = true;
                    mapVar.cmpgn = true;
                    mapVar.acct = true;
                    mapVar.sdate = true;
                    mapVar.name = true;
                    mapVar.audience = true;
                    mapVar.availableBudget = true; 
                    mapVar.prodtype = true;
                    mapVar.brand = true;
                    mapVar.initiative = true;
                    mapVar.category = true;
                    mapVar.type = true;
                    mapVar.tactics = true;
                    mapVar.EventOtherName = true;
                    mapVar.EventName = true;
                    mapVar.cpled = true;
                    mapVar.cp = true;
                    mapVar.ocp = true;
                    mapVar.attachement = true;
                    mapVar.questions = true;
                    mapVar.jointcontent = true;
                    mapVar.reimbursement = true; //Reimbursement Rate
                    mapVar.priority = true; //Priority
                    mapVar.vrquestions = true;
                    mapVar.eventFormat = true;
                }
        component.set("v.disabledMap", mapVar);
    },
    //Set File Exception
    setFileUploadForUser : function(component){
        component.set("v.fileexceptionper", true);
    },
    
    //Method to check if Status need to be set as Pending Review as to trigger approval
    setfundRequestStatusHelper : function(component){
        //Check whether Activity Status to be set to Pending Review if any of below conditions are satisfied
        //Is Retail Activity field Edited for applicabe fields 
        //IsActivty Type selected as Content Creation for applicable program
        //Is Activty Status is Pending Review or Revision Required for applicable program
        //Is Event Activity, fields  Edited applicabe,  above 50000 for applicable program
        
        //Opal changes@@@     
        // New Budget Type field changes replaced txt field with new global picklist field
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
        if ((((component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) &&
              
              (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_CCF")) ||
               this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_DCF"))))) &&
            (component.get("v.accmgrper") && this.isOpalActivitywithApplicableFieldModified(component) || component.get("v.externalper") && this.isOpalRevReqActModified(component)) &&
            component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")		
           ){
            component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            if(component.get("v.isLoggedInUserLevelOneApprover")){
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1); 
                component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');     
                component.set("v.newPFR.Core_MDF_Activity_First_Approver_txt__c","");
            }else{
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); 
            }
            
            
        }
        
        if((component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
            component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))&& 
           (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_CCF")) ||
            this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_DCF"))) &&
           (this.isOpalActivitywithApplicableFieldModified(component)) &&
           component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")){            
            //sneha commented as when internal user edits activity should remain in planned status
            if(component.get("v.isLoggedInUserLevelOneApprover")){
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1); 
                component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');     
            }else{
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); 
            }
        }
        //Opal changes@@@   
        /*Trigger Approval when Opal Revision Required Activity is edited
		  Updated below condition to trigger approval if fields are edited*/
        // New Budget Type field changes replaced txt field with new global picklist field
        // Added condition to retrigger approval when Internal AM edits Revision Required Fields
        if ((((component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") ||
               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) &&
              (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_CCF")) || this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_DCF"))))) &&
            component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired") &&
            (this.isOpalRevReqActModified(component) ||
             component.get("v.newPFR.Core_MDF_Require_Additional_Review_ind__c") != component.get("v.oldPFR.Core_MDF_Require_Additional_Review_ind__c"))
           ){
            
            
              if(component.get("v.isLoggedInUserLevelOneApprover") && (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == 'Service Provider CMP')&&
               component.get("v.newPFR.Core_MDF_Require_Additional_Review_ind__c")) {
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1); 
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")); 
                
            }
          
          //If CMP
          if(component.get("v.isLoggedInUserLevelOneApprover") && (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                                                                   component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))){
              //If Additional review is changed, be in RR
              if(!(this.isOpalRevReqActModified(component)) && (component.get("v.newPFR.Core_MDF_Require_Additional_Review_ind__c") != component.get("v.oldPFR.Core_MDF_Require_Additional_Review_ind__c"))){
                  component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired"));
              }else if(this.isOpalRevReqActModified(component) && (component.get("v.newPFR.Core_MDF_Require_Additional_Review_ind__c") == false) && (component.get("v.newPFR.Core_MDF_Program_Office_Check_ind__c") == false)){
                  component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm"));
              }
              else if(this.isOpalRevReqActModified(component) && (component.get("v.newPFR.Core_MDF_Program_Office_Check_ind__c") == true)){
                  component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                  component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                  component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');     
              }
          }            
         
          //New: If Budget Type is changed from MDF/MDF+ to CMP, send for Customer Acceptance
          else if(component.get("v.isLoggedInUserLevelOneApprover") &&  this.isOpalRevReqActModified(component) &&
                  component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") != component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") &&
                  ((component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || 
                    component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) &&
                   (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                    component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")))
                 ){					
              component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm"));
              
          }
          //New: If Budget Type is changed from CMP to MDF/MDF+, normal flow
              else if(component.get("v.isLoggedInUserLevelOneApprover") && this.isOpalRevReqActModified(component) &&
                      (
                          (
                              this.isNotBlank(component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")) &&
                              (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || 
                               component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus"))
                          ) ||
                          (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") != component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") &&
                           ((component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                             component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) &&
                            (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || 
                             component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")
                            )
                           )
                          )
                      )
                     ){
                 
                  component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                  component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');     
                  component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));                        
              }else{
                  if(!component.get("v.isLoggedInUserLevelOneApprover")){
                      component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); 
                      component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));                            
                  }
              }
      }   
        
        
        
        
        
        var today = this.getTodayDateLocalTime();
        // Added SP CMP check for reapproval
        // New Budget Type field changes replaced txt field with new global picklist field
        if ((!(component.get("v.retailgeouserper")) || (component.get("v.retailgeouserper") && component.get("v.accmgrper") && component.get("v.oldsdate") >= today)) &&
            !(component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || 
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")||
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") ||
              recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")) &&
            (this.isRetailActivitywithApplicableFieldModified(component) ||
             this.isPendingReviewOrRevisionRequiredActivity(component) ||
             ((this.isContentCreationActivity(component) ||
               this.isActivityEventAboveAmountThresholdwithApplicableFieldModified(component)) &&
              !this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_Retail")))
            )){
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); 
            
        }
        //if RSM edits the SPIF Section in Revision Required status trigger the approval flow
        if(component.get("v.accmgrper") && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && 
           component.get("v.isSPIFSecModified") && component.get("v.oldstatus") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired")){
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
        }
        //Retail Changes -to send the activity to ATF queue for approval, when RSM edits the past dated revision required activity
        var today = this.getTodayDateLocalTime();
        var start_date = component.get("v.newPFR.Core_MDF_Start_Date__c");
        if (start_date < today && component.get("v.accmgrper") && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") &&
            this.isPendingReviewOrRevisionRequiredActivity(component) && component.get("v.mode") == 'edit' && component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired")) {
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                      
        }
        //EEF Program changes to retrigger apporval and set status to pending review && for pending review update indicator to true for reapproval
        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") && 
          (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired") || 
           component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")) &&
        (this.isEEFActivitywithApplicableFieldModified(component) || component.get("v.isSPIFSecModified"))){
        component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
        if(component.get("v.activatingaccper")){
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",1);
            component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
        }
        else if(component.get("v.primaryaccper")){
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",2);
            component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
        }
		else if(component.get("v.externalper")){
		    component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c",0);
		}
        }else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") &&
		component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") &&
		(this.isEEFActivitywithApplicableFieldModified(component) || component.get("v.isSPIFSecModified"))){
		      component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
		}    
        
    },
    //Method to Check if Activity Type is Content Creation  and value is modified for Content Creation
    isContentCreationActivity : function(component){
        
        //Check if User edits record and selectsActivity Type as Content Creation 
        //Core_MDF_Activity_Type_Content_Creation --> Content Creation
        
        var lblContentCreation = $A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation");
        
        return(component.get("v.oldPFR.Core_MDF_Activity_Types__c") != component.get("v.newPFR.Core_MDF_Activity_Types__c") &&
               this.validateActivityType(component,lblContentCreation));
    },
    isPlannedOrRevisionRequiredActivity: function (component) {
        
        //Check if IPA User edits a Revision Required or Planned Activity
        //Core_MDF_PFR_Status_RevisionRequiredOrPendingReview - Planned, Revision Required
        
        return ($A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequiredOrPlanned").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c")));
    },
    //Method to Check if Activity Status is Pending Review or Revision Required
    isPendingReviewOrRevisionRequiredActivity: function (component) {
        var activityReqApproval = false;
        var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
        if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Revision_Required")){
            activityReqApproval = this.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval);
        }
        return activityReqApproval;
    },
    
    //Method to Re-trigger approval for EEF program activity
    isEEFActivitywithApplicableFieldModified: function (component) {
    var activityReqApproval = false;
    var eEFExternalRevisionRequiredReApproval = $A.get("$Label.c.Core_MDF_EEF_External_RevisionRequired_Edits_Reapproval"); //same for external planned for EEF
	var eEFActivatingRevisionRequiredReApproval = $A.get("$Label.c.Core_MDF_EEF_Activating_RevisionReq_Reapproval");
	var eEFPrimaryRevisionRequiredReApproval = $A.get("$Label.c.Core_MDF_EEF_Primary_RevisionReq_Reapproval");
	var eEFActivatingPlannedReApproval = $A.get("$Label.c.Core_MDF_EEF_Activating_Planned_Reapproval");
	var eEFPrimaryPlannedReApproval = $A.get("$Label.c.Core_MDF_EEF_Primary_Planned_Reapproval");
	
    if(component.get("v.isEEFMetricsModified")){
        return true;
    }
        
    if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Revision_Required")){
		    if(component.get("v.externalper")){
                activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFExternalRevisionRequiredReApproval.split(","));
            }else if(component.get("v.activatingaccper")){
			    activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFActivatingRevisionRequiredReApproval.split(","));    
			}else if(component.get("v.primaryaccper")){
			    activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFPrimaryRevisionRequiredReApproval.split(",")); 
			}
	} 
	if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")){
		    if(component.get("v.externalper")){
                activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFExternalRevisionRequiredReApproval.split(","));
            }else if(component.get("v.activatingaccper")){
			    activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFActivatingPlannedReApproval.split(","));    
			}else if(component.get("v.primaryaccper")){
			    activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFPrimaryPlannedReApproval.split(",")); 
			}
	}
    //to update field modified when activity is edited in L1 edits to trigger approval to customer
    if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")){
            if(component.get("v.activatingaccper")){
			    activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFActivatingRevisionRequiredReApproval.split(","));    
			}else if(component.get("v.primaryaccper")){
			    activityReqApproval = this.fieldEligibleForApprovalModified(component, eEFPrimaryRevisionRequiredReApproval.split(",")); 
			}
    }			    
	
    return activityReqApproval;
},
    
    setActwithNewValues: function (component) {
        component.set("v.newPFR.CampaignId",component.get("v.selectedLookUpRecord").Id);
        component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selBudgetType"));
        component.set("v.newPFR.Core_MDF_Require_Additional_Review_ind__c",component.get("v.isAdditionalReviewReqd"));
        component.set("v.newPFR.Core_MDF_TargetAudience__c",component.get("v.SelTargetAudience"));
        component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
        component.set("v.newPFR.Core_MDF_Brand_nm__c",component.get("v.selectedBrandOptions"));
        component.set("v.newPFR.Core_MDF_ActivityCategory__c",component.get("v.SelCategory"));
        component.set("v.newPFR.Core_MDF_Activity_Types__c",component.get("v.SelActivityType"));
        component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
        component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.SelReimbursementRate"));  
        component.set("v.newPFR.Core_MDF_MDFReimbursement_Amt__c", component.get("v.FlexiReimbursementAmt"));
        component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c",component.get("v.SelOtherChannelPartner"));
        component.set("v.newPFR.Core_MDF_Channel_Partner__c",component.get("v.SelIndustryPartner"));
        component.set("v.newPFR.Core_MDF_Joint_Content_ind__c",component.get("v.JointContent"));
        component.set("v.newPFR.Core_MDF_Country_nm__c",component.get("v.SelMarketValue"));             
        component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selectedSubTypeOptions"));
    },
    
    //If User modifies  Event Activity Type, Requested Amount above 50000  modifies fields --> Activity Type , 
    //Activity Category , Amount, Start Date or file updated 
    isActivityEventAboveAmountThresholdwithApplicableFieldModified : function(component){
        
        //Core_MDF_Field_Eligble_For_Approval_CcfDcfSpcfCcfb--> Core_MDF_Activity_Types__c,Core_MDF_ActivityCategory__c,RequestedAmount,Core_MDF_Start_Date__c
        var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Eligble_For_Approval_CcfDcfSpcfCcfb");
        var fileUpdated = component.get("v.ChgndAttach"); 
        
        if(this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Event_Activity_Category")) && !this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Promotion")) &&  this.budgetAmountThresholdCheck(component) &&
           (this.fieldEligibleForApprovalModified(component,editedFieldRequiresApproval.split(",")) || fileUpdated)){
            return true;
        }
        else{
            return false;
        }
    },
    //Check the Activity Type with value passed in label
    validateActivityType : function(component,activityTypeLabel){
        return (activityTypeLabel.split(';').includes(component.get("v.newPFR.Core_MDF_Activity_Types__c")));
    },
    //Check the Activity Category with value passed in label
    validateActivityCategory : function(component,activityCategoryLabel){
        return (activityCategoryLabel.split(';').includes(component.get("v.newPFR.Core_MDF_ActivityCategory__c")));
    },
    //Method to check if Activity Type is Event
    isEventActivity : function(component){
        
        ////Core_MDF_Event_Activity_Category - Event;Event 2025
        //New Activity Category Type Change
        return (($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.newPFR.Core_MDF_ActivityCategory__c")));
        
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
            
            
            
            if(editedFieldRequiresApproval[fieldName] == 'Core_MDF_Activity_SubType_nm__c' && !$A.util.isEmpty(component.get(oldFieldValue)) &&
               component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
                if(fieldMod){
                    return true;
                }
            }
            
            else if(editedFieldRequiresApproval[fieldName] == 'Core_MDF_Industry_Multi_nm__c' && component.get(oldFieldValue) != undefined && component.get(oldFieldValue) != null && 
                    !$A.util.isEmpty(component.get(oldFieldValue))){
                
                var isChanged = false;
                if(!$A.util.isEmpty(component.get(newFieldValue)) && 
                   (component.get(oldFieldValue) != component.get(newFieldValue))){
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
                if (isChanged){
                    return true;
                } 
                
            } 
            
            
            else if (((!$A.util.isEmpty(component.get(oldFieldValue)) && !$A.util.isEmpty(component.get(newFieldValue)) && (component.get(oldFieldValue) != component.get(newFieldValue))) 
                      || ((this.isNotBlank(component.get(oldFieldValue)) && !this.isNotBlank(component.get(newFieldValue))) || (!this.isNotBlank(component.get(oldFieldValue)) && this.isNotBlank(component.get(newFieldValue)))))
                         && editedFieldRequiresApproval[fieldName] != 'Core_MDF_Competitive_Elements__c' && editedFieldRequiresApproval[fieldName] != 'Core_MDF_Incentive_Opted_In_ind__c' && editedFieldRequiresApproval[fieldName] != 'Core_MDF_Industry_Multi_nm__c' ) {
                return true;
            }
            
            
            
            
            
        }
        //When file is uploaded on edit - to re-trigger the approval// Added by Ramapriya (WW05'2025)- TWC702-11335
        if (component.get("v.Uploadfinished")==true){
            return true;
        }
        return false;
    },
    
    //Method to check USD - Requested Amount greater than 50,000(50k) 
    budgetAmountThresholdCheck : function(component){
        
        var bugamt = component.get("v.newPFR.RequestedAmount");
        
        if ((parseFloat(bugamt) >= parseFloat($A.get("$Label.c.Core_MDF_CCF_BudgetAmountThreshold")) && this.checkRecordTypeSelected(component,$A.get("$Label.c.Core_MDF_PFR_CCF")))
            || (parseFloat(bugamt) >= parseFloat($A.get("$Label.c.Core_MDF_DCF_BudgetAmountThreshold")) && this.checkRecordTypeSelected(component,$A.get("$Label.c.Core_MDF_PFR_DCF")))
            || (parseFloat(bugamt) >= parseFloat($A.get("$Label.c.Core_MDF_SPCF_BudgetAmountThreshold")) && this.checkRecordTypeSelected(component,$A.get("$Label.c.Core_MDF_PFR_SPCF")))
            || (parseFloat(bugamt) >= parseFloat($A.get("$Label.c.Core_MDF_CCFB_BudgetAmountThreshold")) && this.checkRecordTypeSelected(component,$A.get("$Label.c.Core_MDF_PFR_CCF_Boost")))) {
            
            return true;
        }else{
            return false;
        }
    },
    //Check the Record type 
    checkRecordTypeSelected : function(component , recordTypeDeveloperLabel){
        return(recordTypeDeveloperLabel.includes(component.get("v.recordtypeDeveloperName")));
    },
    //Check if Activity is Retail
    isRetailActivitywithApplicableFieldModified : function(component){
        // Also refer retriggerApprovalIfMetricModified method for Metrics field
        //Returns true when User   
        //Core_MDF_Field_Editable_Retail-->RequestedAmount,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Country_nm__c,Core_MDF_ProductType__c,Core_MDF_Brand__c,Core_MDF_TargetAudience__c
        var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Editable_Retail");
        
        if(this.checkRecordTypeSelected(component,$A.get("$Label.c.Core_MDF_PFR_Retail")) && 
           this.fieldEligibleForApprovalModified(component,editedFieldRequiresApproval.split(","))){
            return true;
        }else{
            return false;
        }
    },
    
    
    //Opal changes@@  
    //reapproval for planned opal activity
    isOpalActivitywithApplicableFieldModified: function (component) {
        var isApprovalReqd = false;
        var editedPlannedActivityFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Planned_Activity_ApprovalReqdFields");    
        var editedPORFieldRequiresApproval = $A.get("$Label.c.Core_MDF_POR_ApprovalReqdFields");
        var editedPCTFieldRequiresApproval = $A.get("$Label.c.Core_MDF_PCT_ApprovalReqdFields");
        var spifActivityTypes = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
        var otherActivityTypes = $A.get("$Label.c.Core_MDF_Other_Activity_Types");
        if (this.validateKPIValues(component)) {
                    this.setKPIValues(component);
		}
        var plannedFieldMod= this.fieldEligibleForApprovalModified(component, editedPlannedActivityFieldRequiresApproval.split(";")); 
        var porFieldsMod = this.fieldEligibleForApprovalModified(component, editedPORFieldRequiresApproval.split(","));
        var pctFieldsMod = this.fieldEligibleForApprovalModified(component, editedPCTFieldRequiresApproval.split(","));
        //opal PCT POR edit changes
        var oldSpifEdited =  spifActivityTypes.split(";").includes(component.get("v.oldPFR.Core_MDF_Activity_Types__c"));
        var oldOtherEdited = otherActivityTypes.split(";").includes(component.get("v.oldPFR.Core_MDF_Activity_Types__c")); 
        var spifModified = component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") ;
        var metricsModified = component.get("v.newPFR.Core_MDF_Metrics_Modified_ind__c") 
        var spifEdited = spifActivityTypes.split(";").includes(component.get("v.newPFR.Core_MDF_Activity_Types__c"));
        var otherEdited = otherActivityTypes.split(";").includes(component.get("v.newPFR.Core_MDF_Activity_Types__c"));
        //Akash - ecosystem 
        var ecosystemModified = component.get("v.newPFR.Core_MDF_Ecosystem_Modified_Ind__c"); 
        
        if((pctFieldsMod && spifEdited) ||(!oldSpifEdited && spifEdited)){
            component.set("v.newPFR.Core_MDF_Price_reviewer_check_ind__c", true);
            isApprovalReqd = true;
        } 
        if((porFieldsMod && otherEdited)||(!oldOtherEdited && otherEdited)){
            component.set("v.newPFR.Core_MDF_Program_Office_Check_ind__c", true);
            isApprovalReqd = true;
        } 
        if(plannedFieldMod ||spifModified||metricsModified ||ecosystemModified){
            isApprovalReqd = true;
        }
        
        if(isApprovalReqd){
            component.set("v.isIntEditPlanned",true);
            this.fetchExternalActSubmitters(component,false);
        }
        return isApprovalReqd;
        
        
    },  
    
    //Print Media, VR ,Upload File, Event Validation
     checkExtraQuestionAndUploadFile: function (component) {
       
        var isError = false;
        var fileUploadMandatoryForUser = false;
         fileUploadMandatoryForUser = component.get("v.fileexceptionper");
     //Core_MDF_Activity_Cancelled_In_Progress  - Cancelled, In-Progress
      if ( component.get("v.Uploadfinished") == false && component.get("v.checkfileuploadcondition") == true &&
                   !fileUploadMandatoryForUser  && (this.checkIfEventOrContentActivity(component))) {
            
            var error = $A.get("$Label.c.Core_MDF_Upload_File_Message");
            component.set("v.message", error);
            component.set("v.messageType", "error");
            isError = true;
            if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")) {
                
                document.querySelector("#pivot").scrollIntoView();
                
            } else {
                
                window.scrollTo(0, 0);
                
            }
           
         }
     
         if ((component.get("v.recordApplicableForActivityRules") && component.get("v.PopupType") == null &&
            (!$A.get("$Label.c.Core_MDF_Activity_Cancelled_In_Progress").includes(component.get("v.newPFR.Core_MDF_Fund_Request_Status__c"))))  && isError == false  ){
            this.checkVariableReimbursement(component);
      } 
      
       else if ((component.get("v.Uploadfinished") == true || 
         (component.get("v.PopupType") == "" || component.get("v.PopupType") == null || component.get("v.PopupType") == undefined) ||
         component.get("v.checkbudgetcondition") == false ||
         (!component.get("v.recordApplicableForActivityRules") && component.get("v.checkbudgetcondition"))) && isError == false ) {
            
         if(component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") != 'Cancelled' || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned' 
            || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Revision Required' || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' 
            || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Approval' )
              {
            if (this.validateKPIValues(component)) {
                this.setKPIValues(component);
                 this.saveHelperMethod(component, component.get("v.newPFR"));
            }
           }
        } 
    },
   
    //Check if Activity is Content Creation or Event/Event 2025 or Digital Media/Digital 2025 to mandate file upload
    checkIfEventOrContentActivity : function(component){
        
        //Core_MDF_Event_Activity_Category - Event,Event 2025
        //Core_MDF_Activity_Category_Digital_Media - Digital Media
	//Core_MDF_2025_Domain_Type_ActivityCategory - Digital 2025
	//Core_MDF_Domain_Type_Form_Values - EcosystemPartner.com
        //Core_MDF_Activity_Type_Content_Creation - Content Creation isEventActivity
        //Ramapriya - Fix for Screen Stuck on Loading for RMF Program when Activity Type is Email or Domain Type is Ecosystempartner.com
        var intelContri = component.get("v.intelContribution");
        if(this.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType"))){
        if((this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Event_Activity_Category")) && component.get("v.isEventFormTemplateVisible") )||
           this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation")) ||
           (this.validateActivityType(component, $A.get("$Label.c.Core_MDF_CMP_activity_type_eligible_for_approval")) && 
           (this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Digital_Media")) || 
           (this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory")) && 
           ($A.get("$Label.c.Core_MDF_Domain_Type_Form_Values").split(';')).includes(component.get("v.SelDomainType")) && intelContri >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold"))))) {
            return true;
        }else{
            return false;
        }
        }
    },
    
    //function to set child picklist values based upon controlling parent value.
    //This is a generic function called upon on change of Activity Type, SubType, Product Type, Brand and Event format and on load of the activity page
    setChildPicklistValues : function(component, controllingValues, dependentValues){
        var childPicklistValue = new Array();
        var childValueOptionsMap = new Array();
        if (dependentValues != null) {
            childValueOptionsMap = dependentValues[controllingValues];
            if (childPicklistValue.length == 0) {
                //setting the first value of the dependent picklist as translated None value
                childPicklistValue.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: ""
                });
            }
            if (childValueOptionsMap != null) {
                for (var index = 0; index < childValueOptionsMap.length; index++){
                    childPicklistValue.push(childValueOptionsMap[index]);
                }	
            }
        }
        return childPicklistValue;
    },
    //This helper function is used to fetch Currency picklist values
    fetchPicklistInfo: function (component, fieldName) {
        var action = component.get("c.getLabelApiMapforPicklistfields");
        action.setParams({
            'objName': "PartnerFundRequest",
            'pfrPiclistField': fieldName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var currValList = [];
                var mapResp = response.getReturnValue();
                for (var key in mapResp) {
                    currValList.push({
                        value: mapResp[key],
                        key: key
                    });
                }
                var currList = currValList;
                component.set("v.currMap", currList);
            } else if (state === 'ERROR') {
               var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
               	 this.displaySuccessErrorMsg(errorMessage, "Error", "error"); 
            }
        });
        $A.enqueueAction(action);
    },
    
    //Helper called on change of Budget Amount Local to Calculate Budget Amount USD
    calculateBudgetAmount: function (component, newPFR) {
        component.set("v.showSpinner",true);
        component.set("v.isSaveDisable", true);
        component.set("v.isSaveandNewDisable", true);
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        component.set("v.disableCurrency",true);//making attribute as true for disabling currency field 
        var action = component.get("c.budgetAmountCalculatePFR");
        //pass oldcurrency param
        action.setParams({
            createdDateCloneFlag: component.get("v.createdDateClone"),
            pfr: newPFR
        });
        
        action.setCallback(this, function (response) {
            component.set("v.disableCurrency",false);//making attribute as false for enabling currency field
            component.set("v.showSpinner",false);
            if (response.getState() == "SUCCESS") {
                var exchangeRateConvertedAmountWrap = response.getReturnValue();
                if (exchangeRateConvertedAmountWrap != null && exchangeRateConvertedAmountWrap.exchangeRate != null && exchangeRateConvertedAmountWrap.usdBudgetAmount != null) {
                    component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateConvertedAmountWrap.exchangeRate);
                    //OPAL Changes related Attribute
                    component.set("v.newPFR.RequestedAmount", exchangeRateConvertedAmountWrap.usdBudgetAmount);
                    component.set("v.BudgetException", false);
                    component.set("v.budgetCurrencyOld",component.get("v.newPFR.Core_MDF_Budget_Currency_cd__c"));
                    if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF")||component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) 	&& this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                        var budgetAmount = component.get("v.newPFR.RequestedAmount");
                        var flexAmount = component.get("v.FlexiReimbursementAmt");
                        this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
                    } 
                    if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                        var Contri ;
                        var budgetAmount = component.get("v.newPFR.RequestedAmount");    
                        // var ReimbRt = component.get("v.EefReimbursementRate");
                        // var Contri = budgetAmount* (parseFloat(ReimbRt)/100); 
                        //To show intel contribution as blank for negative values for EEF
                        if (budgetAmount<=0 ||budgetAmount=='' || budgetAmount==null){
                                component.set("v.EefIntelContri", '');
                            
                        }else{
                            var Contri = budgetAmount;
                            component.set("v.EefIntelContri", Contri);
                        }
                        
                    } 
                    // OPAL Changes End
                    this.getActivityAmount(component);
                }else{
                    component.set("v.BudgetException", true); 
                }
                component.set("v.isSaveDisable", false);
                if(!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.ipaApproverPer") || (component.get("v.CurrentStatus") == 'Planned' && (component.get("v.accmgrper") || component.get("v.externalper")) ) )  )) {
                    component.set("v.isSaveandNewDisable", false);
                }
            } else if (response.getState() == "ERROR") {
                component.set("v.BudgetException", true);
            }
            this.checkFileUploadForOPAL(component);
            this.fileUploadMandatoryAndEventFormVisibility(component);
           
        });
        
        $A.enqueueAction(action);
    },
    
    // Helper called on the load of the picklist component to store all the values 
    convertApitoLable: function (component, fieldlist) {
        var action = component.get("c.getLabelApiMapforPicklistfields");
        action.setParams({
            "objName": 'PartnerFundRequest',
            "pfrPiclistField": fieldlist
        });
        
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var optionMap = new Map();
                optionMap = response.getReturnValue();
                component.set("v.apitoLabelConvert", optionMap);
            }
        });
        $A.enqueueAction(action);
    },
    // to calculate the buget amount
    budgetAmountcalculatefunction : function(component){
        var oldLocalAmount = component.get("v.oldPFR.Core_MDF_Budget_Amount_Local_amt__c");
        var oldCurrency = component.get("v.oldPFR.Core_MDF_Budget_Currency_cd__c");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
        // If : - New and Clone and Local Amount is not call
        if(component.get("v.checkCloneAttribute") || $A.util.isEmpty(component.get("v.newPFR.Id")) || $A.util.isEmpty(component.get("v.recordId"))){
            // If : - Not USD and Not Currency empty
            if(component.get("v.budgetCurrency") != "USD"){
                this.calculateBudgetAmount(component, component.get("v.newPFR"));
            }else{ // Else : - USD Currency //not need to call Server Method // Local Amount is not null 
                component.set("v.disableCurrency",true);//making it as true for disabling currency field
                component.set("v.newPFR.RequestedAmount", component.get("v.BudgetLocal"));
                component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
                component.set("v.disableCurrency",false);//enabling the currency field
                // OPAL Changes start to re-calculate new Reimbursement Rate Percentage on Budget Amount change : 25th Jan Added as part of RR change
                if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) && this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                    var budgetAmount = component.get("v.newPFR.RequestedAmount");            
                    var flexAmount = component.get("v.FlexiReimbursementAmt");
                    this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
                } 
                if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                    var Contri ;
                    var budgetAmount = component.get("v.newPFR.RequestedAmount");
                    //To show intel contribution as blank for negative values for EEF
                        if (budgetAmount<=0 ||budgetAmount=='' || budgetAmount==null){
                                component.set("v.EefIntelContri", '');
                          }else{
                            var Contri = budgetAmount;
                            component.set("v.EefIntelContri", Contri);
                        }
                }
                // OPAL Changes End
                this.getActivityAmount(component);
                this.checkFileUploadForOPAL(component);
                  this.fileUploadMandatoryAndEventFormVisibility(component);
            }
            // Else: - Edit scenario (change is present in either amount and currency)    
        }else if(parseFloat(oldLocalAmount) != parseFloat(component.get("v.BudgetLocal")) || (oldCurrency != component.get("v.budgetCurrency"))
                ){
            this.recalculateBudgetAmount(component);
        }else if(parseFloat(oldLocalAmount) == parseFloat(component.get("v.BudgetLocal")) && (oldCurrency == component.get("v.budgetCurrency"))){
            component.set("v.newPFR.RequestedAmount", component.get("v.oldPFR.RequestedAmount"));
            component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", component.get("v.oldPFR.Core_MDF_Exchange_Rate_ptc__c"));
            component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", component.get("v.oldPFR.Core_MDF_Budget_Amount_Local_amt__c"));
            if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) && this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                var budgetAmount = component.get("v.newPFR.RequestedAmount");            
                var flexAmount = component.get("v.FlexiReimbursementAmt");
                this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
            }
            this.getActivityAmount(component);
            this.checkFileUploadForOPAL(component);
            this.fileUploadMandatoryAndEventFormVisibility(component);
        }
    },
    // Recalculate Budget Amount 
    recalculateBudgetAmount : function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        component.set("v.showSpinner",true);
        component.set("v.isSaveDisable", true);
        component.set("v.isSaveandNewDisable", true);
        // Return of the method is PartnerFundRequest
        var action = component.get("c.recalculatebudgetAmountOnPFR");
        action.setParams({
            newPFR: component.get("v.newPFR"),
            oldPFR : component.get("v.oldPFR")
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            var exchangeRateError = false;
            if (response.getState() == "SUCCESS") {
                if(result.Core_MDF_Exchange_Rate_ptc__c != null && result.RequestedAmount != null ){ // If Return PFR has exchange rate and USD amuont
                    component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", result.Core_MDF_Exchange_Rate_ptc__c);
                    component.set("v.newPFR.RequestedAmount", result.RequestedAmount);
                    if(component.get('v.mode') == 'edit' && component.get("v.newPFR.RequestedAmount") != component.get("v.oldPFR.RequestedAmount")){ // Rishabh
                        this.calculateIntelContribution(component);
                    }
                    if(component.get('v.mode') == 'edit' && component.get("v.externalper") && (component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && (component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory") && component.get("v.SelDomainType") ==$A.get("$Label.c.Core_MDF_Domain_Type_Form_Values"))){
                        this.fetchApprovers(component);
                    }            
                    // OPAL Changes start to re-calculate new Reimbursement Rate Percentage on Budget Amount change
                    if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) && this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                        var budgetAmount = component.get("v.newPFR.RequestedAmount");
                        var flexAmount = component.get("v.FlexiReimbursementAmt");
                        this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
                    } 
                    // OPAL Changes End
                    //EEF Changes
                    if(this.isNotBlank(component.get("v.BudgetLocal")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType") ){
                        var eefcontri = component.get("v.newPFR.RequestedAmount");     
                        if (eefcontri <= 0 || eefcontri == '' || eefcontri == null){
                            component.set("v.EefIntelContri",''); //display intel contri as blank for negative values
                        }else{
                            component.set("v.EefIntelContri",eefcontri);
                        }
                        
                    }
                    this.getActivityAmount(component);
                    
                }else{ // Else throw error "System failed to get the Data"
                    exchangeRateError = true; 
                }
               this.checkFileUploadForOPAL(component);
            this.fileUploadMandatoryAndEventFormVisibility(component); 
            }else{ // Else throw error "System failed to get the Data"
                exchangeRateError = true;
            }
            component.set("v.showSpinner",false);
            component.set("v.isSaveDisable", false);
            if(!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") ) && (component.get("v.ipaApproverPer") || (component.get("v.CurrentStatus") == 'Planned' && (component.get("v.accmgrper") || component.get("v.externalper")) ) )  )) {
                if(!component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper") &&
                   !component.get("v.auditorper")){
                    component.set("v.isSaveandNewDisable", false);
                }
            }
            if(exchangeRateError){
                component.set("v.isSaveDisable", true);
                component.set("v.isSaveandNewDisable", true);
                component.set("v.message", $A.get("$Label.c.Core_MDF_Currency_Error"));
                component.set("v.messageType", "error");
                if(component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")){
                    document.querySelector("#pivot").scrollIntoView();
                } else {
                    document.querySelector("#pivot").scrollIntoView();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    /*[IPA] Disable save & New and Save buttons*/
    setSaveBtnVisibility: function (component) {
        
        var isSaveBtnDisable = true;
        var isSaveAndNewBtnDisable = true;
        var status = component.get("v.CurrentStatus");
        var accmgrper = component.get("v.accmgrper");
        var ipaApproverPer = component.get("v.ipaApproverPer");
        var externalper = component.get("v.externalper");
        
        if (((status == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired") || status == $A.get("$Label.c.Core_MDF_CCP_Planned_Status") || status == $A.get("$Label.c.Core_MDF_PFR_Status_Draft_IPA")) && (accmgrper || externalper))) {
            isSaveBtnDisable = false;
            isSaveAndNewBtnDisable = false;
        }
        if ((status == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && ipaApproverPer && this.isCurrentUsrIsApprover(component))
           ) {
            isSaveBtnDisable = false;
        }
        if(status == "Planned" && (accmgrper || externalper)) {
            isSaveAndNewBtnDisable = true;
        }
        if(status == "In-Progress" && (accmgrper || externalper)) {
            isSaveBtnDisable = false;
        }
        component.set("v.isSaveDisable", isSaveBtnDisable);
        component.set("v.isSaveandNewDisable", isSaveAndNewBtnDisable);
    },
    
    /* method returns true if logged in user is approver for IPA activities campaign*/
    isCurrentUsrIsApprover: function (component) {
        var curUserId = $A.get("$SObjectType.CurrentUser.Id");
        var usrIsApprover = false;
        var approverSet = new Set();
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
        if (approverSet != null && curUserId != null && approverSet.has(curUserId)) {
            usrIsApprover = true;
            component.set("v.isUserCurrentIPAApprover", true);
	}else {
            if(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c")){
                  if(component.get("v.newPFR.Campaign.Core_MDF_Approval_Stage_nm__c") == 'Price Reviewer' && component.get("v.priceReviewersPer")){
            		usrIsApprover = true;
                  }
            } else{
                if(component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'Price Reviewer' && component.get("v.priceReviewersPer")){
                    usrIsApprover = true;
                }  
            } 
        }
        return usrIsApprover;
    },
    
    //call to KPI component
    getKPIAttributes: function (component) {
        var kpiComponent = component.find("kpiFields");
        if (kpiComponent != null) {
            var vprogram = component.get("v.programName");
            var vctgry = component.get("v.SelCategory");
            var vtype = component.get("v.SelActivityType");
            var vsubType = component.get("v.selActivitySubType"); 
            var inputParams = {}; //kpiComponent.getInputParams();
            if (vprogram != null) {
                inputParams.recordId = component.get("v.recordId");
                inputParams.objName = "PartnerFundRequest";
                inputParams.activityCategory = vctgry;
                inputParams.activityType = vtype;
                inputParams.activitySubType = vsubType;
                inputParams.program = vprogram;
               inputParams.title = $A.get("$Label.c.Core_MDF_KPI_Metrics");
                inputParams.enableKPI = this.verifyKPIEditability(component);
                kpiComponent.loadKPIAttributes(inputParams);
            }
        }
    },

    //Outcome Based changes - method to check if selected tactics is spif/incentive eligible
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
    
    /* Extra section to check whether to display Segment SPIF activity questions or not*/
    checkSPIFActSecVisible: function(component) {
        var metaDataRecs = component.get("v.metadataMap");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        if(component.get("v.SelCategory") != null && component.get("v.SelActivityType") != null && component.get("v.recordtypeDeveloperName") != null){
            for(var i = 0; i < metaDataRecs.length; i++){
                if (metaDataRecs[i].Core_MDF_Field_7_txt__c == component.get("v.SelCategory") && metaDataRecs[i].Core_MDF_Field_9_txt__c == component.get("v.SelActivityType") &&
                    metaDataRecs[i].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName") && metaDataRecs[i].Core_MDF_Checkbox_Field_10_Ind__c) {
                    component.set("v.isSPIFSecAvailable",true);
                    break;
                }
            }
        }
        //Outcome based changes - show spif/incentive section based on the selected tactics
        if(component.get("v.showActTactics") && !$A.util.isEmpty(component.get("v.selectedTacticsOptions"))){
           if(this.checkSPIFTactics(component)){
                    component.set("v.isSPIFSecAvailable",true);
            }else{
                    component.set("v.isSPIFSecAvailable",false);
            }
        }
        //  OPAL CCF/DCF - if budget type selected then only SPIF section will be available
        if((component.get("v.recordtypeName") == $A.get("$Label.c.Core_MDF_CCF_RecordType") || component.get("v.recordtypeName") == $A.get("$Label.c.Core_MDF_DCF_RecordType")) && (!component.get("v.isOpalActivity") ) ) {
            component.set("v.isSPIFSecAvailable",false);
        }
    },
    
    /*  Geo Lead to edit Activities that have a start date in past 
    This method will be invoked only if the user has Geo Lead Permission*/
    checkGeoLeadsEditAccess: function(component) {
        var activityStatus = component.get("v.oldstatus");
        var actClosureType =  component.get("v.activityClosureType");
        var today = this.getTodayDateLocalTime();
        var actStartDate = component.get("v.oldsdate");
        
        var mapVar = component.get("v.disabledMap");
        
        component.set("v.isSaveandNewDisable",true);
        component.set("v.isSaveDisable",true);
        // Block Activity Edits from Mobile for Geo Lead 
        var device = $A.get("$Browser.formFactor");
        if(device == 'PHONE'){
            if(component.get("v.stopMethodExecution") == false) {
                component.set("v.stopMethodExecution",true);	
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error..!!",
                    message: $A.get("$Label.c.Core_MDF_Activity_Edit_ErrMsg"),
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
        else if(activityStatus =='In-Progress' || activityStatus == 'Closed')
        {
            component.set("v.checkGeoLeadMetricSecEditability", false);
            component.set("v.isSaveandNewDisable", true);
            component.set("v.isSaveDisable", false);
        }
        
            else{
                //Activity Start date is in Past and status is any one the of the below allowing Geo Lead to Edit Activities
                if((today > actStartDate) && (activityStatus == 'Planned' || activityStatus == 'Revision Required' )){
                    component.set("v.checkGeoLeadMetricSecEditability",true);
                    component.set("v.isSaveandNewDisable",true);
                    component.set("v.isSaveDisable",false);
                    this.getKPIAttributes(component);
                    //[RMF] Geo Lead Edit - No Edit to SPIF Section
                    //To disable Edit acccess for geo Lead
                    
                }
            }
        component.set("v.disabledMap", mapVar);//handled
    },
    
    //[RMF] [WW51] Approval flow when Geo Lead edit Activities
    callNextLevelApproval: function(component) {
        
        //DE115095 : WW19 | DEVINT3 | When Geo Lead edits an Activity,
        //which is in Planned status and changes the start date to 1 day minus today,
        //then Activity re approval is getting triggered
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var today = this.getTodayDateLocalTime();
        //Akash - TWC702-14284
        var reqAmt250K = parseFloat($A.get("$Label.c.Core_MDF_PFR_ReqAmount_250K"));
        var reqAmt1000K = parseFloat($A.get("$Label.c.Core_MDF_PFR_ReqAmount_1000K"));
        var priceRevChk = component.get("v.newPFR.Core_MDF_Price_reviewer_check_ind__c");
        var reqAmount = component.get("v.newPFR.RequestedAmount");
        
        var spifActivityTypes = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
        var newActivityType =  component.get("v.SelActivityType");
        if(component.get("v.retailgeouserper")){
            //Akash - TWC702-14284
                if(reqAmount < reqAmt250K){
                    if(spifActivityTypes.includes(newActivityType)){ 
                        //Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
                        component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                        
                        if(component.get("v.newPFR.Core_MDF_Region_nm__c") == 'EMEA' && !component.get("v.activityInApproval")){
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');     
                        }else{
                                //Spif- to trigger to PCT
                                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                                component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
                            } 
                            
                          
                    }else{
                        // Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
                        component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm"));
                        
                        if(component.get("v.newPFR.Core_MDF_Region_nm__c") == 'EMEA' && !component.get("v.activityInApproval")){
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');     
                        }else{
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); //Non Spif- to trigger to Customer
                        }  
                    }
                }
                //Akash - TWC702-14284
                if((reqAmount >= reqAmt250K && reqAmount < reqAmt1000K) || (reqAmount >= reqAmt1000K)){
                    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                    //Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
                    if(component.get("v.newPFR.Core_MDF_Region_nm__c") == 'EMEA' && !component.get("v.activityInApproval")){
                        component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                        component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');     
                    }else{
                            //to trigger to L1
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');     
                        }
                    }
                    
                   
            
        }
        
    },
    
    // invoked on budget type change 
    populateActCatType:function(component, event, helper){
        
        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF")) && this.isNotBlank(component.get("v.selBudgetType"))) {
            var queryFilterStr = '';
            var isOpalBudgetTypeSelected = false;            
            if(component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF")
               || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP") || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false) {
                component.set("v.isOpalActivity",true);
            }
            if(component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || 
               component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) {
                queryFilterStr += ' AND Core_MDF_Checkbox_Field_1_Ind__c = true';
                isOpalBudgetTypeSelected = true;
            } else if(component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false ||
                      component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) {
                isOpalBudgetTypeSelected = true;                                      
            }
            queryFilterStr += ' AND Core_MDF_Field_3_txt__c = \''+component.get("v.recordtypeDeveloperName")+'\'';
            if(isOpalBudgetTypeSelected || component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                var selectedActType = component.get("v.SelActivityType");                                
                var selectedActTypeNotPresentFlag = false;
                var action = component.get("c.fetchOpalMetadataMapping");
                action.setParams({
                    "queryFilterStr": queryFilterStr
                });
                action.setCallback(this, function (response) {
                    var result = response.getReturnValue();
                    if (response.getState() == "SUCCESS") {
                         var categoryTypeMap = {};
                        var categoryList = [];
                        /* OPAL change start - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
                        var otherActivityTypes = '';
                        if(component.get('v.externalper')) {
                            otherActivityTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
                            if(component.get("v.checkCloneAttribute")) { // || component.get("v.recordId")!=null
                                if(otherActivityTypes.includes(component.get("v.SelActivityType"))) {
                                    component.set("v.SelActivityType", '');
                                }
                            }
                            if(!component.get("v.checkCloneAttribute") && this.isNotBlank(component.get("v.recordId"))) {
                                var selActType = component.get("v.SelActivityType");
                                otherActivityTypes = otherActivityTypes.replace(selActType+",", "");
                            }
                        }
                        
                        
                        /* OPAL change end - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
                        for(let i=0;i<result.length;i++) {
                            categoryTypeMap[result[i].Core_MDF_Field_1_txt__c] = categoryTypeMap[result[i].Core_MDF_Field_1_txt__c] || [];
                             if(!otherActivityTypes.includes(result[i].Core_MDF_Field_2_txt__c)) { 
                                
                                categoryTypeMap[result[i].Core_MDF_Field_1_txt__c].push(result[i].Core_MDF_Field_2_txt__c);
                            }
                        }
                        var tempActivityCategories = component.get("v.ActivityCategoriesMain");
                        var newActivityCategories = [];
                        var newActivityTypes = {};
                        newActivityCategories.push({
                            class: "optionClass",
                            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                            value: ""
                        });
                        for(let i=0;i<tempActivityCategories.length;i++) {                            
                            newActivityTypes[tempActivityCategories[i].value] = newActivityTypes[tempActivityCategories[i].value] || [];
                            var actTypeArr = [];
                            if(categoryTypeMap.hasOwnProperty(tempActivityCategories[i].value)) {
                                newActivityCategories.push({
                                    class: "optionClass",
                                    label: tempActivityCategories[i].label,
                                    value: tempActivityCategories[i].value
                                });
                                if(categoryTypeMap[tempActivityCategories[i].value] != undefined && categoryTypeMap[tempActivityCategories[i].value] != null) {
                                    for(let j=0;j<categoryTypeMap[tempActivityCategories[i].value].length;j++) {                                    
                                       
                                        if(selectedActType == categoryTypeMap[tempActivityCategories[i].value][j]) {                                        	
                                            selectedActTypeNotPresentFlag = true;
                                          
                                        }
                                        actTypeArr.push({
                                            class: "optionClass",
                                            label: categoryTypeMap[tempActivityCategories[i].value][j],
                                            value: categoryTypeMap[tempActivityCategories[i].value][j]
                                        });
                                    }}
                            }
                            newActivityTypes[tempActivityCategories[i].value] = actTypeArr;
                          
                            
                        }
                        
                        if(selectedActType != null && !selectedActTypeNotPresentFlag ){
                            component.set("v.SelActivityType", '');
                        }
                        component.set("v.ActivityCategories",newActivityCategories);
                        component.set("v.ActivityTypes", newActivityTypes);
                        this.fetchActType(component); 
                        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_DCF") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_CCF"))) {
                            this.dependentPickValAdditionAndRemoval(component, 'Core_MDF_Activity_Types__c'); 
                        }
                    }
                });
                $A.enqueueAction(action);    
            }
        } 
    },
    
    // OPAL Changes - on budget amount, mdf reimbursement amount
    calculateReimbursementRatePercent: function(component,budgetAmount,flexAmount){
        var flexRRMap=[];
        //Akash - TWC702-14284
        var maxActReimbRate = parseFloat($A.get("$Label.c.Core_MDF_ReimburesementNum"));
        var maxActReimbRatezero = parseFloat($A.get("$Label.c.Core_MDF_ReimburesementNumzero"));
        var flexRR =(parseFloat(flexAmount) / parseFloat(budgetAmount))*100 ;
        flexRR = (budgetAmount == 0 && flexAmount == 0)?0:flexRR;
        var newRRPercent = parseFloat(flexRR.toFixed(2));
        var flexRRDecValue = newRRPercent +"%";
        component.set("v.newRRValue",newRRPercent);
        //Akash - TWC702-14284
        if(newRRPercent > maxActReimbRate){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error..!!",
                message: $A.get("$Label.c.Core_MDF_NewRR_ErrMsg"),
                type: "error"
              
            });
            toastEvent.fire();
            component.set("v.FlexiReimbursementAmt","");
            component.set("v.disableRRPercent",false);
            this.updateRRPickValues(component,this.getDefaultReimbursementRate(component));
            //Akash - TWC702-14284
        } else if(flexRR <= maxActReimbRatezero){ // To calculate zero percent or not from formula
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error..!!",
                message: $A.get("$Label.c.Core_MDF_ZeroPercentRR_ErrMsg"),
                type: "error"
                
            });
            toastEvent.fire();
            component.set("v.FlexiReimbursementAmt","");
            component.set("v.disableRRPercent",false);
            this.updateRRPickValues(component,this.getDefaultReimbursementRate(component));
        } else{
            flexRRMap.push({
                class: "optionClass",
                label: flexRRDecValue,
                value: flexRRDecValue
            });
            component.set("v.ReimbursementRateVal", flexRRMap);
            component.set("v.SelReimbursementRate", flexRRDecValue);
            if(component.get("v.disableRRPercent") == false && this.isNotBlank(budgetAmount) && this.isNotBlank(flexAmount)){
                component.set("v.disableRRPercent", true);
            } 
            this.getActivityAmount(component);
            this.calculateIntelContribution(component); // Rishabh
        }
    },
    
    // OPAL Changes - on MDF Budget type selection
    updateRRPickValues: function(component,defaultRRValue){
        var rrPickValues = [];
        var pickValues = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
        //Ayush - RR changes
        var defaultRRwithoutPercentage;
		if(this.isNotBlank(defaultRRValue) && defaultRRValue.endsWith("%")){
            defaultRRwithoutPercentage = defaultRRValue.replace("%", "");
        }
        
        for(var i = 0; i < pickValues.length; i++){
            var optionValue = pickValues[i]+"%";
            rrPickValues.push({
                class: "optionClass",
                label: optionValue,
                value: optionValue
            });
        }
        if(this.isNotBlank(defaultRRValue) && this.isNotBlank(defaultRRwithoutPercentage) && !pickValues.includes(defaultRRwithoutPercentage)){
            rrPickValues.push({
                class: "optionClass",
                label: defaultRRValue,
                value: defaultRRValue
            });
        }
        rrPickValues.sort((a, b) => parseFloat(a.value) - parseFloat(b.value));
        //Ayush - Added if condition for defect fix where we are setting default value only if MDF Reimbursement Amount(USD) is blank. 
        if(!this.isNotBlank(component.get("v.FlexiReimbursementAmt"))){
        component.set("v.SelReimbursementRate", defaultRRValue);
        component.set("v.ReimbursementRateVal", rrPickValues);
        component.set("v.reimbursementRatePickValues",rrPickValues); 
        }
    },
    getDefaultReimbursementRate: function(component){
        var selectedBudget = component.get("v.selBudgetType");    
        var budgetCampRecList = component.get("v.campaignBudgetList");
        var defaultRRate;
        if(budgetCampRecList != null && budgetCampRecList.length > 0){
            for(var i = 0; i < budgetCampRecList.length; i++){
                if((budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c == selectedBudget && component.get('v.mode') == '') || (component.get('v.mode') != '' &&  component.get('v.newPFR.BudgetId') ==  budgetCampRecList[i].Core_MDF_Budget_Name_Id__c )){
                    defaultRRate = budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c;
                    break;
                }
            }
        }
        
        return defaultRRate;
    },
    
    //OPAL Changes - to update Country picklsit values that were selected at Campaign
    // [OPAL CCF/DCF] - Campaign and Activity inheritance
    updateCountryPickVals: function(component){
        var selectedcountryValues = [];
        var isPickValNotChanged = false;
        var countryOptionsMap = [];
        var countrylocalizedMap = component.get("v.apitoLabelConvert");
            var countryOptions;
		var selectedValuesAfteRemoval = "";
            
            if(!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Market__c")))){
                countryOptions =  component.get("v.selectedLookUpRecord.Core_MDF_Market__c").split(";");
            }
            if(this.isNotBlank(countryOptions)){ //condition for programs which has country populated on campaign
                for(var index = 0; index < countryOptions.length; index++){
                    for(var key in countrylocalizedMap){
                        if (key == countryOptions[index]) {
                            countryOptionsMap.push({
                                class: "optionClass",
                                label: countrylocalizedMap[key],
                                value: countryOptions[index]
                            });
                        }
                    }
                }               
            }
            else{ //fetching country from dependency for RMF program as it is not present on campaign
                countryOptionsMap = component.get("v.CountryPicklistValues");
            }
            if (!($A.util.isEmpty(component.get("v.selectedCountryOptions")))) {
                selectedcountryValues = Object.values(component.get("v.selectedCountryOptions"));
                isPickValNotChanged = selectedcountryValues == component.get("v.oldPFR.Core_MDF_Country_nm__c") ? true : false;
            }

            if (this.isNotBlank(countryOptionsMap)) {
                // On Edit the selected exsisting value is added to the picklist if the value is inactivated
                if(component.get("v.mode") == 'edit' && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                    console.log('countryOptionsMap--> ',countryOptionsMap);
                    countryOptionsMap = this.picklistValuesAddition(countrylocalizedMap, selectedcountryValues, countryOptionsMap);
                }
                // On Clone the selected exsisting value is removing if the value is inactivated
                else if(component.get("v.mode") == 'clone' && isPickValNotChanged) {
                    selectedValuesAfteRemoval = this.picklistValuesRemoval(selectedcountryValues, countryOptionsMap);
                    component.set("v.selectedCountryOptions", selectedValuesAfteRemoval);
                }
                countryOptionsMap.sort(this.case_insensitive_sort);
                component.set("v.AllCountryOptions",countryOptionsMap);
                component.set("v.CountryPicklistValues", countryOptionsMap);
            }
    },

    

    
	updateCategoryPickVals: function (component) {
        var categorylocalizedMap = component.get("v.apitoLabelConvert");
        var categoryPicklistValuesMap = [];
        var selectedcategoryValues = [];
        var selectedValuesAfteRemoval = "";
        var isPickValNotChanged = false;
        var actCategoryCampOptions;
        var latestCategoryValues = [];
        
        if (this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Activity_Category__c"))) {
            actCategoryCampOptions = component.get("v.selectedLookUpRecord.Core_MDF_Activity_Category__c").split(";"); //storing Activity Category campaign values 
        }
        
        if(this.isNotBlank(actCategoryCampOptions)){ //condition for programs which has activity category populated on campaign
            if(actCategoryCampOptions.length >=1){
                categoryPicklistValuesMap.push({
                    class: "optionClass",
                    label: "--None--",
                    value: ""
                });
            }
            for(var index = 0; index < actCategoryCampOptions.length; index++){
                for (var key in categorylocalizedMap) {
                    if (key == actCategoryCampOptions[index]) {
                        categoryPicklistValuesMap.push({
                            class: "optionClass",
                            label: categorylocalizedMap[key],
                            value: actCategoryCampOptions[index]
                        });
                    }
                }
            }
        }
        else{ //fetching activity categories from dependency for RMF program as it is not present on campaign
            categoryPicklistValuesMap = component.get("v.ActivityCategories");
        }
        if (!($A.util.isEmpty(component.get("v.SelCategory")))) {
            selectedcategoryValues = component.get("v.SelCategory").split(";");
            isPickValNotChanged = component.get("v.SelCategory") == component.get("v.oldPFR.Core_MDF_ActivityCategory__c") ? true : false;
        }
        
        if (this.isNotBlank(categoryPicklistValuesMap)) {

            if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true" && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")
              && this.isNotBlank(component.get("v.newPFR.Core_MDF_Start_Date__c"))){
                component.set("v.oldStartDate",component.get("v.newPFR.Core_MDF_Start_Date__c"));
                categoryPicklistValuesMap = this.filterNewCategoryValues(component, categoryPicklistValuesMap);
            }

            // On Edit the selected exsisting value is added to the picklist if the value is inactivated
            if(component.get("v.mode") == 'edit' && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                console.log('categoryPicklistValuesMap--> ',categoryPicklistValuesMap);
                categoryPicklistValuesMap = this.picklistValuesAddition(categorylocalizedMap, selectedcategoryValues, categoryPicklistValuesMap);
            }
            // On Clone the selected exsisting value is removing if the value is inactivated
            else if(component.get("v.mode") == 'clone' && isPickValNotChanged) {
                selectedValuesAfteRemoval = this.picklistValuesRemoval(selectedcategoryValues, categoryPicklistValuesMap);
                component.set("v.SelCategory", selectedValuesAfteRemoval);
            }
            categoryPicklistValuesMap.sort(this.case_insensitive_sort);
            component.set("v.ActivityCategories", categoryPicklistValuesMap);
            component.set("v.ActivityCategoriesMain", categoryPicklistValuesMap); 
        }
    },
    dependentPickValAdditionAndRemoval: function (component, fldname) {
        var filedslocalizedMap = component.get("v.apitoLabelConvert");
        var childPickField = {};
        var selectedControllingFieldValue = "";
        var selectedSinglePickChildValue = "";
        var selectedMultiPickChildValue = [];
        var selectedValuesAfteRemoval = "";
        var isParentPickValNotChanged = false;
        var isValidControllingPickVal = false;
        
        if(fldname == "Core_MDF_Activity_Types__c"){
            
            var actTypeCampOptions;
            var typeCampaignOptionsMap = new Object();
            var accTypeFromCampValues = [];
            var sValues;
            if (this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Activity_Category_Type__c"))) {
                actTypeCampOptions = component.get("v.selectedLookUpRecord.Core_MDF_Activity_Category_Type__c").split(";");	//storing Activity type campaign values
            }
            if(!($A.util.isEmpty(actTypeCampOptions))){ //condition for programs which has activity type populated on campaign
                for(var i = 0; i < actTypeCampOptions.length; i++){
                    var typeAndCategorySplit = actTypeCampOptions[i].split('->'); //splitting values based from "->"
                    console.log('typeAndCategorySplit -> ',typeAndCategorySplit);
                    var key = typeAndCategorySplit[0];
                    //Hide Other when external user is editing activity - Defect Fix TWC702-11632
                    if(!component.get('v.externalper') || (component.get('v.externalper') && !(($A.get("$Label.c.Core_MDF_OtherActivityTypes").split(",")).includes(typeAndCategorySplit[1])))){
                    if (key in typeCampaignOptionsMap) { //initializing structure of parent and child values
                        typeCampaignOptionsMap[key].push({
                            class: "optionClass",
                            label: typeAndCategorySplit[1],
                            value: typeAndCategorySplit[1]
                        });
                    } else {
                        sValues = new Array();
                        sValues.push({
                            class: "optionClass",
                            label: typeAndCategorySplit[1],
                            value: typeAndCategorySplit[1]
                        });
                        typeCampaignOptionsMap[key] = sValues;
                    }
                }
                }
                console.log('@@typeCampaignOptionsMap -->', typeCampaignOptionsMap);
                if(!($A.util.isEmpty(typeCampaignOptionsMap))){ //Map will contain Key as controlling values and Value as dependent values
                    if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                        component.set("v.ActivityTypes",typeCampaignOptionsMap);
                    }
                    childPickField = typeCampaignOptionsMap;
                }
            }
            //fetching activity type from dependency for RMF program as it is not present on campaign
            else { 
                if (!($A.util.isEmpty(component.get("v.ActivityTypes")))) {
                    childPickField = component.get("v.ActivityTypes"); // contains activity type from dependency
                }
            }
            if (!($A.util.isEmpty(component.get("v.SelCategory")))) {
                selectedControllingFieldValue = component.get("v.SelCategory"); //contains selected activity category on pfr
                isParentPickValNotChanged = selectedControllingFieldValue == component.get("v.oldPFR.Core_MDF_ActivityCategory__c") ? true : false;
            }
            if (!($A.util.isEmpty(component.get("v.oldPFR.Core_MDF_Activity_Types__c")))) {
                selectedSinglePickChildValue = component.get("v.oldPFR.Core_MDF_Activity_Types__c");
                component.set("v.SelActivityType",component.get("v.oldPFR.Core_MDF_Activity_Types__c"));
            }  
        } 
        else if(fldname == "Core_MDF_Event_Name_nm__c"){
            if (!($A.util.isEmpty(component.get("v.EventNameMap")))) {
                childPickField = component.get("v.EventNameMap"); // contains Event Name from dependency
            }
            if (!($A.util.isEmpty(component.get("v.SelActivityType")))) {
                selectedControllingFieldValue = component.get("v.SelActivityType"); //contains selected activity type on pfr
                isParentPickValNotChanged = selectedControllingFieldValue == component.get("v.oldPFR.Core_MDF_Activity_Types__c") ? true : false;
            }
            if (!($A.util.isEmpty(component.get("v.selActivityEventName")))) {
                selectedSinglePickChildValue = component.get("v.selActivityEventName");
            }  
        } 
            else if(fldname == "Core_MDF_Activity_SubType_nm__c"){
                if (!($A.util.isEmpty(component.get("v.activityMultiSelSubType")))) {
                    childPickField = component.get("v.activityMultiSelSubType"); // contains activity subtype from dependency
                }
                if (!($A.util.isEmpty(component.get("v.SelActivityType")))) {
                    selectedControllingFieldValue = component.get("v.SelActivityType"); //contains selected activity type on pfr
                    isParentPickValNotChanged = selectedControllingFieldValue == component.get("v.oldPFR.Core_MDF_Activity_Types__c") ? true : false;
                }
                if (!($A.util.isEmpty(component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c")))) {
                    if(!Array.isArray(component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c"))){
                        selectedMultiPickChildValue = component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c").split(";");
                    } else {
                        selectedMultiPickChildValue = component.get("v.oldPFR.Core_MDF_Activity_SubType_nm__c");
                    }
                    
                } 
            }
        
        if(this.isNotBlank(selectedControllingFieldValue) && isParentPickValNotChanged){
            for(var key in childPickField){ //contains values from dependencies and key will contain the controlling values
                if(key == selectedControllingFieldValue){
                    isValidControllingPickVal = true;
                    var selChildPicTypeValues = [];
                    selChildPicTypeValues = childPickField[key]; //this will give all the dependent values for corresponding controlling values 
                    
                    if(this.isNotBlank(selectedSinglePickChildValue)){ //for all the single select picklist value fields
                        // On Edit the selected exsisting value is added to the picklist if the value is inactivated
                        if(component.get("v.mode") == 'edit'){
                            if(!selChildPicTypeValues.find((fieldValues) => fieldValues.value === selectedSinglePickChildValue)) {
                                childPickField[selectedControllingFieldValue].push({
                                    class: "optionClass",
                                    label: filedslocalizedMap[selectedSinglePickChildValue],
                                    value: selectedSinglePickChildValue
                                });
                            }
                        }
                        // On Clone the selected exsisting value is removing if the value is inactivated
                        else if(component.get("v.mode") == 'clone') {
                            selectedValuesAfteRemoval = this.picklistValuesRemoval(selectedSinglePickChildValue.split(";"), selChildPicTypeValues);
                        }
                    }
                    else if (this.isNotBlank(selectedMultiPickChildValue)){ //for all the multi select picklist value fields
                        // On Edit the selected exsisting value is added to the picklist if the value is inactivated
                        if(component.get("v.mode") == 'edit') {
                            childPickField[selectedControllingFieldValue] = this.picklistValuesAddition(filedslocalizedMap, selectedMultiPickChildValue, selChildPicTypeValues);
                        }
                        // On Clone the selected exsisting value is removing if the value is inactivated
                        else if(component.get("v.mode") == 'clone') {
                            selectedValuesAfteRemoval = this.picklistValuesRemoval(selectedMultiPickChildValue, selChildPicTypeValues);
                        }
                    }
                }
            }
            if(component.get("v.mode") == 'edit' && !isValidControllingPickVal && this.isNotBlank(selectedSinglePickChildValue)){
                childPickField[selectedControllingFieldValue] = [];
                childPickField[selectedControllingFieldValue].push({
                    class: "optionClass",
                    label: filedslocalizedMap[selectedSinglePickChildValue],
                    value: selectedSinglePickChildValue
                });
            }
            //Assigning values for specific fields with values formed above on childPickField for edit scenarios
            if(component.get("v.mode") == 'edit') {
                if(fldname == "Core_MDF_Activity_Types__c"){
                    component.set("v.ActivityTypes", childPickField);
                }
                else if(fldname == "Core_MDF_Event_Name_nm__c"){
                    component.set("v.EventNameMap", childPickField);
                }
                    else if(fldname == "Core_MDF_Activity_SubType_nm__c"){
                        component.set("v.activityMultiSelSubType", childPickField);
                    }
            }
            //Assigning values for specific fields with values formed above on selectedValuesAfteRemoval for clone scenarios
            else if(component.get("v.mode") == 'clone') {
                if(fldname == "Core_MDF_Activity_Types__c"){
                    component.set("v.SelActivityType", selectedValuesAfteRemoval);
                }
                else if(fldname == "Core_MDF_Event_Name_nm__c"){
                    component.set("v.selActivityEventName", selectedValuesAfteRemoval);
                }
                    else if(fldname == "Core_MDF_Activity_SubType_nm__c"){
                        if(selectedValuesAfteRemoval != ""){
                            var valuesafterRemoval = selectedValuesAfteRemoval.split(";");
                            component.set("v.selectedSubTypeOptions", valuesafterRemoval);
                        } else {
                            component.set("v.selectedSubTypeOptions", []);
                        }
                    }
            }
        }
    },
    updateBrandPickVals: function (component) {
        
            var brandOptions;
        var selectedBrandValues = [];
        var oldselectedBrandValues = "";
            if (!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Brand__c")))) {
                brandOptions = component.get("v.selectedLookUpRecord.Core_MDF_Brand__c").split(";");
            }
        if (!($A.util.isEmpty(component.get("v.selectedBrandOptions")))) {
            selectedBrandValues = component.get("v.selectedBrandOptions");
        }
        var brandlocalizedMap = component.get("v.apitoLabelConvert");
        var brandPicklistValuesMap = [];
        brandPicklistValuesMap = component.get("v.BrandPicklistValues");
        var brandOptionsMap = [];
        
        if (brandOptions != null && brandOptions.length > 0 /*&& this.isNotBlank(brandPicklistValuesMap)*/) {
            brandOptions.sort(this.case_insensitive_sort);
            for (var i = 0; i < brandOptions.length; i++) {
                for (var key in brandlocalizedMap) {
                    if (key == brandOptions[i]) {
                        brandOptionsMap.push({
                            "label": brandlocalizedMap[key],
                            "value": key
                        });
                    }
                }
            }
        
            component.set("v.AllBrandOptions", brandOptionsMap);
            component.set("v.BrandPicklistValues", brandOptionsMap);
            component.set("v.selectedBrandOptions", selectedBrandValues);
        }
        
    },
     updateInitiativesVals: function (component) {
        
         	var initiativeOptions;
            var selectedInitiativeValues = [];
            var oldselectedInitiativeValues = "";
        	if (!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Initiative_nm__c")))) {
                initiativeOptions = component.get("v.selectedLookUpRecord.Core_MDF_Initiative_nm__c").split(";");
            }
            if (!($A.util.isEmpty(component.get("v.selectedInitiativeOptions")))) {
                selectedInitiativeValues = component.get("v.selectedInitiativeOptions");
            }
            var initiativelocalizedMap = component.get("v.apitoLabelConvert");
            var initiativePicklistValuesMap = [];
            initiativePicklistValuesMap = component.get("v.InitiativesPicklistValues");
            var initiativeOptionsMap = [];
         	var initiativeOptionVal = [];
         
         
         	

            console.log('initiativelocalizedMap->'+initiativelocalizedMap);
            if (initiativeOptions != null && initiativeOptions.length > 0 /*&& this.isNotBlank(initiativePicklistValuesMap)*/) {
                initiativeOptions.sort(this.case_insensitive_sort);
               	for(var index=0; index < initiativeOptions.length; index++){
                        var initiativeValue="";
                        initiativeValue=initiativeOptions[index];
                    	//value.includes('&amp;')
                    	if(initiativeValue.includes('&amp;')){
                            var str = initiativeValue;
                            initiativeOptions[index] =  str.replace(/&amp;/g, '&');
                        }
             	}
                
                
                for (var index = 0; index < initiativeOptions.length; index++) {
                    for (var key in initiativelocalizedMap) {
                        if (key == initiativeOptions[index]) {
                            initiativeOptionsMap.push({
                                "label": initiativelocalizedMap[key],
                                "value": key
                            });
                        }
                    }
                }
                
                component.set("v.AllInitiativeOptions", initiativeOptionsMap);
                component.set("v.selectedInitiativeOptions", selectedInitiativeValues);
            }
            
    },
    //Fetch Industry PicklistValues from Campaign 
    updateIndustryPickVals: function (component) {
        var industryOptions;
        var selectedindustryValues = [];
        var oldselectedindustryValues = "";

        if (!($A.util.isEmpty(component.get("v.selectedIndustryOptions")))) {
            selectedindustryValues = component.get("v.selectedIndustryOptions");
        }

        var industryValuesMap = [];
        industryValuesMap = component.get("v.IndustryPicklistValues");
        
        if (!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Industry_Nm__c"))) && this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Industry_Nm__c"))) {
            industryOptions = component.get("v.selectedLookUpRecord.Core_MDF_Industry_Nm__c").split(";");
            var industrylocalizedMap = component.get("v.apitoLabelConvert");
            var industryOptionsMap = [];
            
            if (industryOptions != null && industryOptions.length > 0 /*&& this.isNotBlank(industryValuesMap)*/) {
                industryOptions.sort(this.case_insensitive_sort);
                for (var index = 0; index < industryOptions.length; index++) {
                    for (var industrykey in industrylocalizedMap) {
                        if (industrykey == industryOptions[index]) {
                            industryOptionsMap.push({
                                "label": industrylocalizedMap[industrykey],
                                "value": industrykey
                            });
                        }
                    }
                }
                
                component.set("v.allIndustryOptions", industryOptionsMap);
                component.set("v.selectedIndustryOptions", selectedindustryValues);
            }
        }
        
        
    },
    //Commom method to display success/error
    displaySuccessErrorMsg: function(Message,Title,Type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: Title,
            message:Message,
            type: Type
           
        });
        toastEvent.fire();
    },
    //Fetch Allocation w.r.t to Budget
    allocationBudgt: function(component,event,helper){
        //Ayush -  Issue fix for MDF RR Amount(USD) not clearing out when Budget/Campaign/Budget Type was changed - Setting MDF RR Amount(USD) to blank whenever the selected budget is changed.
        component.set("v.FlexiReimbursementAmt",'');
        var budgetId = component.get("v.selAvailableBudget");
        
        var selectedBudget = component.get("v.selBudgetType");
        component.set("v.isBTSelAtCampaign",false);
        component.set("v.isCCFDCFRecType",false);
        
        var budgetCampRecList = component.get("v.campaignBudgetList");
        component.set("v.newPFR.Core_MDF_Budget_id__c",budgetId);
        component.set("v.newPFR.BudgetId",budgetId);
        if(budgetCampRecList !=null && budgetCampRecList.length>0){
            for(var i = 0; i < budgetCampRecList.length; i++){
                if( budgetCampRecList[i].Core_MDF_Budget_Name_Id__c == budgetId){
                    if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")){
                        if(component.get("v.externalper")){
                            component.set("v.disableRRPercent",true);
                        }
                        else{
                            component.set("v.disableRRPercent",false);
                        }
                        component.set("v.isBudgetTypeFlexible",false);
                        component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        
                        var reimbursementRatePickValues = [];
					reimbursementRatePickValues.push({
	                    class: "optionClass",
	                    label: budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c,
	                    value: budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c
	                });
                    //Ayush - added below piece of code for CMP budget Type to fetch all the applicable RR% values
                    var rrValueCMP = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
                    var rrAdditionalValueCMP = $A.get("$Label.c.Core_MDF_CMP_RR_Values").split(';'); //Ayush - added below piece of code for CMP budget type to include additional RR as well along with other applicable RR%.
						rrValueCMP = rrValueCMP.concat(rrAdditionalValueCMP);

                    if(this.isNotBlank(rrValueCMP)){
                        for(var index = 0; index < rrValueCMP.length; index++){
								var rrValueCMPInPercent = rrValueCMP[index]+"%";
                                if(reimbursementRatePickValues.some(v => !rrValueCMPInPercent.includes(budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c))){
                                reimbursementRatePickValues.push({
                                    class: "optionClass",
                                        label: rrValueCMPInPercent,
                                        value: rrValueCMPInPercent
                                });
                            }
                        }
                    }
					reimbursementRatePickValues.sort((a, b) => parseFloat(a.value) - parseFloat(b.value));
                    component.set("v.ReimbursementRateVal", reimbursementRatePickValues);
                        
                    }else  if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")){
                        
                        if(component.get("v.externalper")){
                            component.set("v.disableRRPercent",true);
                            
                        }
                        else{
                            component.set("v.disableRRPercent",false);
                        }
                        component.set("v.isBudgetTypeFlexible",true);
                        component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        
                        this.updateRRPickValues(component, budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        
                    }
                    
                }else{
                    // component.set("v.selAvailableBudget",null);
                }
            }
        }
       
        component.set("v.isBTSelAtCampaign",true);
        component.set("v.isCCFDCFRecType",true);
    },
    
    getAvailableBudget : function(component,event,helper){
        var budgetCampRecList = component.get("v.campaignBudgetList");
        var selectedBudget = component.get("v.selBudgetType");
        var selectedBudgetID;
        var availableBudget = [];
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        component.set("v.isBTSelAtCampaign",false);
        component.set("v.isCCFDCFRecType",false);
        //Fetch Available budget w.r.t to selected budget type
         //component.set("v.selAvailableBudget",'');
        
        var isBudgetAvailable = false;
        for(var i = 0; i < budgetCampRecList.length; i++){
            
            if(budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c == selectedBudget){
                var startDate = budgetCampRecList[i].Core_MDF_Start_Date_Dt__c.replaceAll('-','/');
                var endDate = budgetCampRecList[i].Core_MDF_End_Date_Dt__c.replaceAll('-','/');
                availableBudget.push(
                    {
                        key: budgetCampRecList[i].Core_MDF_Budget_Name_Id__c,
                        value: budgetCampRecList[i].Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c+' : '+budgetCampRecList[i].Core_MDF_Budget_Name_Id__r.Title + ' : ' + budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c+' : '+startDate+ ' - ' +endDate
                    });     
            }            
            
            
            if(selectedBudget != null && selectedBudget != undefined && selectedBudget != ""){
                
                if((selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && selectedBudget == budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c){
                    isBudgetAvailable = true;
                    //Ayush - RR changes added if condition for external user disable
                    if(this.isNotBlank(component.get("v.externalper")) && component.get("v.externalper")){
                    component.set("v.disableRRPercent",true);
                    }
                    else{
                        component.set("v.disableRRPercent",false);
                    }
                   
                    component.set("v.isBudgetTypeFlexible",false);
                    //Ayush RR changes
                    /*if(component.get("v.mode") == ''){
                    	component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                    }
                    if(component.get('v.mode') == '' || (component.get('v.mode') != '' &&  component.get('v.newPFR.BudgetId') ==  budgetCampRecList[i].Core_MDF_Budget_Name_Id__c )){
                        var reimbursementRatePickValues = [];
                        reimbursementRatePickValues.push({
                            class: "optionClass",
                            label: budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c,
                            value: budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c
                        });
                        var rrValueCMP = $A.get("$Label.c.Core_MDF_CMP_RR_Values").split(';');
                        if(this.isNotBlank(rrValueCMP)){
                            for(var index = 0; index < rrValueCMP.length; index++){
                                if(reimbursementRatePickValues.some(v => !rrValueCMP.includes(v.value))){
                                    reimbursementRatePickValues.push({
                                        class: "optionClass",
                                        label: rrValueCMP[index],
                                        value: rrValueCMP[index]
                                    });
                                }
                            }
                        }
                        component.set("v.ReimbursementRateVal", reimbursementRatePickValues);
                        component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                    }*/
                    //component.set("v.ReimbursementRateVal", component.get("v.reimbursementRatePickValues"));
                    component.set("v.FlexiReimbursementAmt",'');
                    
                }else if ((selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDF"))&& selectedBudget == budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c) {
                    isBudgetAvailable = true;
                    // Added extra condition to disable Reimbursement Rate field in Edit scenarios
                    if(!component.get("v.checkCloneAttribute") 
                       && (((component.get("v.oldstatus") == "Pending Review" 
                             ||  component.get("v.oldstatus") == "Pending Approval") 
                            && component.get("v.opalAccountManagers") 
                            && !component.get("v.isOPALApprover")) 
                           || (component.get("v.externalper") && (component.get("v.oldstatus") == "Pending Approval"))
                           || (component.get("v.FlexiReimbursementAmt") != null 
                               && component.get("v.FlexiReimbursementAmt") > 0))
                      ){
                        component.set("v.disableRRPercent",true); 
                    } else if(
                        (!component.get("v.checkCloneAttribute") 
                         && component.get("v.oldstatus") != "Cancelled" 
                         && component.get("v.oldstatus") != "In-Progress" 
                         && component.get("v.oldstatus") != "Closed"
                        ) || (component.get("v.checkCloneAttribute") && $A.util.isEmpty(component.get("v.FlexiReimbursementAmt")))
                    ){
                        //Ayush - RR changes added if condition for external user disable
                        if(this.isNotBlank(component.get("v.externalper")) && component.get("v.externalper")){
                            component.set("v.disableRRPercent",true);
                        }
                        else{
                        component.set("v.disableRRPercent",false);
                    }
                    }
                    if(component.get("v.priceReviewersPer")) {
                        component.set("v.disableRRPercent",true);
                    }
                    component.set("v.isBudgetTypeFlexible",true);
                    //component.set("v.FlexiReimbursementAmt", budgetCampRecList[i].Core_MDF_Reimbursement_Amt__c);
                    if(!component.get("v.doInitCheck")) {
                        this.updateRRPickValues(component, budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                    }
                    
                }else if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") && selectedBudget == budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c) {
                    isBudgetAvailable = true;
                    //Added extra condition to disable Reimbursement Rate field in Edit scenarios
                    if(!component.get("v.checkCloneAttribute") 
                       && (((component.get("v.oldstatus") == "Pending Review" 
                             ||  component.get("v.oldstatus") == "Pending Approval") 
                            && component.get("v.opalAccountManagers") 
                            && !component.get("v.isOPALApprover")) 
                           || (component.get("v.externalper") && (component.get("v.oldstatus") == "Pending Approval"))
                           || (component.get("v.FlexiReimbursementAmt") != null 
                               && component.get("v.FlexiReimbursementAmt") > 0))
                      ){
                        component.set("v.disableRRPercent",true); 
                    } else if(
                        (!component.get("v.checkCloneAttribute") 
                         && component.get("v.oldstatus") != "Cancelled" 
                         && component.get("v.oldstatus") != "In-Progress" 
                         && component.get("v.oldstatus") != "Closed"
                        ) || (component.get("v.checkCloneAttribute") && $A.util.isEmpty(component.get("v.FlexiReimbursementAmt")))
                    ){
                        //Ayush - RR changes added if condition for external user disable
                        if(this.isNotBlank(component.get("v.externalper")) && component.get("v.externalper")){
                            component.set("v.disableRRPercent",true);
                        }
                        else{
                        component.set("v.disableRRPercent",false);
                    } 
                    } 
                    if(component.get("v.priceReviewersPer")) {
                        component.set("v.disableRRPercent",true);
                    }
                    component.set("v.isBudgetTypeFlexible",true);
                    if(!component.get("v.doInitCheck")) {
                        this.updateRRPickValues(component, budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                    }
                    
                    
                }
                //Added to disable RR% field on In-Progress edit
                if(component.get("v.CurrentStatus") == 'In-Progress'){
                         component.set("v.disableRRPercent",true);
                }
            }
            
        }
        
        if(selectedBudget != null && selectedBudget != undefined && selectedBudget != ""){
            /* In Planned status, if user changes start/end date & available budgets are not present then showing error & activity reverting back to previous state*/
            if((availableBudget!=null && availableBudget.length == 0) && component.get("v.oldstatus") == "Planned" && (component.get("v.oldPFR.Core_MDF_Start_Date__c") != component.get("v.newPFR.Core_MDF_Start_Date__c") || component.get("v.oldPFR.Core_MDF_End_Date__c") != component.get("v.newPFR.Core_MDF_End_Date__c"))) {
                var alertMsg = $A.get("$Label.c.Core_MDF_No_Available_Budgets_Warning");
                this.displaySuccessErrorMsg(alertMsg,'Error','error');
                component.set("v.newPFR.Core_MDF_Start_Date__c",component.get("v.oldPFR.Core_MDF_Start_Date__c"));
                component.set("v.newPFR.Core_MDF_End_Date__c",component.get("v.oldPFR.Core_MDF_End_Date__c"));
                this.fetchCampBudgetInfo(component,event,null,true);   
            }
            if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")){
                this.populateActCatType(component, event, null);
            }else  if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDF")){
                
                this.populateActCatType(component, event, null);
                
            }else if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) {
                
                this.populateActCatType(component, event, null);
                
            }
            component.set("v.budgetStr", availableBudget);
            
        } 
        component.set("v.budgetStr", availableBudget);
        if(availableBudget!=null && availableBudget.length == 1){
            component.set("v.selAvailableBudget",availableBudget[0].key);
            component.set("v.newPFR.Core_MDF_Budget_id__c",availableBudget[0].key);
            component.set("v.newPFR.BudgetId",availableBudget[0].key);
            component.set("v.isBTSelAtCampaign",true);
            if(recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_EEF_RecordType")){
            component.set("v.isCCFDCFRecType",true);
        }   
            
        }
        
        //Ayush RR change OEM CMP/SP CMP
        for(var i = 0; i < budgetCampRecList.length; i++){
            if(selectedBudget != null && selectedBudget != undefined && selectedBudget != ""){
                if((selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && selectedBudget == budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c){
                    if(component.get('v.mode') == '' || (component.get('v.mode') != '' &&  component.get('v.newPFR.BudgetId') ==  budgetCampRecList[i].Core_MDF_Budget_Name_Id__c )){
                        var reimbursementRatePickValues = [];
                        reimbursementRatePickValues.push({
                            class: "optionClass",
                            label: budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c,
                            value: budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c
                        });
                        //Ayush - added below piece of code for CMP budget Type to fetch all the applicable RR% values
                        var rrValueCMP = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
                        var rrAdditionalValueCMP = $A.get("$Label.c.Core_MDF_CMP_RR_Values").split(';'); //Ayush - added below piece of code for CMP budget type to include additional RR as well along with other applicable RR%.
                        rrValueCMP = rrValueCMP.concat(rrAdditionalValueCMP);
                        
                        if(this.isNotBlank(rrValueCMP)){
                            for(var index = 0; index < rrValueCMP.length; index++){
                                var rrValueCMPInPercent = rrValueCMP[index]+"%";
                                if(reimbursementRatePickValues.some(v => !rrValueCMPInPercent.includes(budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c))){
                                    reimbursementRatePickValues.push({
                                        class: "optionClass",
                                        label: rrValueCMPInPercent,
                                        value: rrValueCMPInPercent
                                    });
                                }
                            }
                        }
                        reimbursementRatePickValues.sort((a, b) => parseFloat(a.value) - parseFloat(b.value));
                        component.set("v.ReimbursementRateVal", reimbursementRatePickValues);
                        if(component.get('v.mode') == '' || (component.get('v.mode') != '' &&  component.get('v.newPFR.BudgetId') !=  component.get('v.oldPFR.BudgetId'))) {
                            component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        }
                        //Ayush - For CMP budget type activities, on edit and clone making RR as double of the OLD RR selected on activity when Competitive element = 'yes'   
                        else if(component.get('v.mode') != '' && component.get('v.oldCompetitiveElement') != "" && component.get('v.oldCompetitiveElement') == 'Yes'){
                            var oldRR = component.get("v.oldPFR.Core_MDF_Reimbursement_Rate_txt__c").replace(/\%/g,'');
                            oldRR = oldRR*2;
                            oldRR = oldRR+"%";
                            component.set("v.SelReimbursementRate", oldRR);

                        }
                    }
                }
            }
        }
        
        if(availableBudget.length == 0){
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                component.set("v.isBTSelAtCampaign",true);
            }
            
            if(component.get("v.isOpalActivity")) {
                component.set("v.isBTSelAtCampaign",true);
                component.set("v.isCCFDCFRecType",true);    
            }
        }

        //Allowing duplicate budget selection as part of WW44
        
        if(availableBudget.length != 0){
            component.set("v.budgetAvailableFlag",true);
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
                component.set("v.isBTSelAtCampaign",true);
            }
            
            if(component.get("v.isOpalActivity")) {
                component.set("v.isBTSelAtCampaign",true);
                component.set("v.isCCFDCFRecType",true);
            }
            
        }
	 if(recordTypeDeveloperName != $A.get("$Label.c.Core_MDF_EEF_RecordType"))
        {
        this.checkAvailAllocationAmt(component);
	}
    },
    // This Method will return true if opal activity is edited in Rev.Required status
    isOpalRevReqActModified: function(component){
        var isfieldsedited = false;
        var selectedBudget = component.get("v.selBudgetType");
        var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
        if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired") || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
            if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")
               && (component.get("v.newPFR.Core_MDF_Priorities__c") != component.get("v.oldPFR.Core_MDF_Priorities__c"))){
			    var fields = [];
                for (var fieldName in editedFieldRequiresApproval){
                    if(editedFieldRequiresApproval[fieldName] != 'Core_MDF_Priorities__c') {
                    	fields.push(editedFieldRequiresApproval[fieldName]);
                    	
                      }
                   }
                    if(fields){
                        editedFieldRequiresApproval = fields;
                    }
           		 }
            if(this.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval)) {
                isfieldsedited = true;
            }
            else if(component.get("v.isSPIFSecModified")) { //If SPIF Sec modified return true
                isfieldsedited = true;
            }else {
                if (this.validateKPIValues(component)) {
                    this.setKPIValues(component);
                }
                if(component.get("v.newPFR.Core_MDF_Metrics_Modified_ind__c")){ // If Metrics modified return true
                    isfieldsedited = true;
                }
                //Akash - ecosystem
                if(component.get("v.newPFR.Core_MDF_Ecosystem_Modified_Ind__c")){ // If Metrics modified return true
                    isfieldsedited = true;
                }
            }
            if(isfieldsedited){
                component.set("v.isEditPlanned",true);
                this.fetchApprovers(component);
                }
           
            }
        return isfieldsedited;
    },
    
    isNotBlank : function(value) {
        return (value !== undefined && value !== null && value !== '');
    },
    //[Opal - CCF/DCF] - [OOC - P6] - Replace "Channel Partner" with "Industry Partner"
    // KS - Read Industry partners list for the country from custom meta data
    getIndustryPartners: function (component, country) {
        var industryParts;
        var opts = [];
        var existingSelectedOption=[] ;
        var selectedValues = component.get("v.selectedIndPartnerOptions");
        var programName = component.get("v.programName");
        var programNameToPass = (programName === 'Datacenter') ? 'Data Center' : programName;
      
        var action = component.get("c.fetchIndPartnerCtryPgmMapping");
        action.setParams({
            "country": country,
            "prgName": programNameToPass
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                industryParts = response.getReturnValue();
                opts.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_None_Label"),
                    value: $A.get("$Label.c.Core_MDF_None_Label")                    
                }); 
                
                
                
                if (industryParts != undefined && industryParts != null && industryParts.length > 0) { //null check
                    for (var i = 0; i < industryParts.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: industryParts[i],
                            value: industryParts[i]
                        });
                        //restore selected value 			
                        if(selectedValues!= null && selectedValues.includes(industryParts[i])){
                            
                            existingSelectedOption.push(industryParts[i]);
                        }
                    }
                }
                opts.push({
                    class: "optionClass",
                    label: "Others",
                    value: "Others"
                });
                //restore selected "other" value 	
                if(selectedValues!= null && selectedValues.includes("Others")){
                    
                    existingSelectedOption.push("Others");
                }
                else if (selectedValues!= null && selectedValues == 'None' && 
                         (component.get("v.OldSelCountry") == component.get("v.SelMarketValue")))
                {
                   existingSelectedOption.push("None");
                   
                }
                component.set("v.OldSelCountry",component.get("v.SelMarketValue")); 
                console.log("success");
                component.set("v.activityMultiIndPartnerVal", opts);
                component.set("v.selectedIndPartnerOptions", existingSelectedOption);     
                
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +  errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    // To Display File Upload Section for OPAL Activities
    //This Method will Activity Reimbursement Amount and return true if amount greater than 50k
    checkActivityReimbursementAmount: function(component,metadataBudgetAmount){
        if(component.get("v.isOpalActivity") && (this.isNotBlank(component.get("v.selBudgetType")) && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").split(';').includes(component.get("v.selBudgetType")))){
            var activityBudgetAmount = component.get("v.newPFR.RequestedAmount");
            var rRate = (component.get("v.SelReimbursementRate") == null || $A.util.isEmpty(component.get("v.SelReimbursementRate")) || component.get("v.SelReimbursementRate") == undefined)?0:component.get("v.SelReimbursementRate").slice(0,-1);
            var actReimbursementAmount = (activityBudgetAmount*rRate)/100;
            if(actReimbursementAmount >= metadataBudgetAmount){
                return true;
            }else{
                return false;
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
    

    
    
  // File Upload section not visible on Budget Type change 
    //Method to Dispaly file Upload section for OPAL Activities on budget type change
    checkFileUploadForOPAL: function (component) {
        var metadata = component.get("v.metadataMap");
        if(metadata){
        for (var index = 0; index < metadata.length; index++) {
            
            if (metadata[index].Core_MDF_Field_7_txt__c == component.get("v.SelCategory") &&
                metadata[index].Core_MDF_Field_9_txt__c == component.get("v.SelActivityType") &&
                metadata[index].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName")) {
                
                if ((component.get("v.isOpalActivity") && this.checkActivityReimbursementAmount(component, metadata[index].Core_MDF_Number_1_num__c))) {
                    component.set("v.checkbudgetcondition", true);
                }
	      }
          }
                
                for (var index = 0; index < metadata.length; index++) {
            if (metadata[index].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName")) {
               
                if (metadata[index].Core_MDF_Checkbox_Field_6_Ind__c) {
                    this.isFileUploadSectionVisible(component, metadata, index);
		            this.fileUploadMandatoryAndEventFormVisibility(component);
                } 
                
            }
        }
      }
    },
    
    /* start - US1025269 */
    setPriceReviewerDisableState: function (component, event) { 
      
        var activityStatus = component.get("v.oldstatus");
        var hasPerSet = component.get("v.priceReviewersPer");
        
        if(hasPerSet) {
            var mapVar = component.get("v.disabledMap");
            component.set("v.disableRRPercent", true);
            component.set("v.isSaveandNewDisable",true);
            component.set("v.isSaveDisable",true);
            this.setOPALActDisableState(component,mapVar)
            
	    
	    
if((component.get("v.componentAttributes.isLoggedInUserApprover") || component.get("v.hasIUPGMRecord")) &&  this.isCurrentUsrIsApprover(component)&& component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' ){
                component.set("v.isSaveDisable", false);
                component.set("v.isSPIFSecReadOnly", false);
            }
        }
    },
    
    /* start - US1025269 */
    getInitialDataFromServer : function (component, event) {
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
            }
            else if (state === "INCOMPLETE") {
            
            }
                else if (state === "ERROR") {

                    var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                	helper.displaySuccessErrorMsg(errorMessage, "Error", "error"); 

                }
        });
        $A.enqueueAction(actionGetInitialData);
    },
    
    //This Method will return the localised value for opal Budget Types
    getBudgetTypeLabel : function(component,budgetType){
        var budgetTypeLabel;
        var budgetTypelocalizedMap = component.get("v.apitoLabelConvert");
        for(var key in budgetTypelocalizedMap){
            if(key == budgetType){
                budgetTypeLabel = budgetTypelocalizedMap[key];
                break;
            }
        }
        return budgetTypeLabel;
    },
    
 
    
    ipaBudgetValidation: function(component){
        var budgetAmount = component.find("BudgetAmount");
        if(budgetAmount!=null && budgetAmount.length == 1){
            budgetAmount[0].setCustomValidity($A.get("$Label.c.Core_MDF_Budget_Amount_Error"));
            budgetAmount[0].reportValidity();
        }else{
            budgetAmount.setCustomValidity($A.get("$Label.c.Core_MDF_Budget_Amount_Error"));
            budgetAmount.reportValidity();
        }               
        //isBudgetAmountBlank = true;
        var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
        this.displaySuccessErrorMsg(alertMsg,"Error!","error");
    },
    
    ipsActMultiSubtypeVal: function(component){
        var activityMultiSubTypeVal = component.find("activityMultiSubTypeVal");         
        if(activityMultiSubTypeVal!=null && activityMultiSubTypeVal.length == 1){
            activityMultiSubTypeVal[0].validateErrors();
        }else{
            activityMultiSubTypeVal.validateErrors();
        }            
        var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
        this.displaySuccessErrorMsg(alertMsg,"Error!","error");
    },
    
    getActivityAmount: function(component){
        var calculatedValue = '';
        var activityBudgetAmount = component.get("v.newPFR.RequestedAmount");
        var rRate = '';
        
        
        
         if (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_RetailProgram") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType")) {
            //Akash - TWC702-14284
            rRate = $A.get("$Label.c.Core_MDF_BudgetType_RRate100");
        } else {
            rRate = component.get("v.SelReimbursementRate");
        }
        if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF")
            ||component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus"))
           && this.isNotBlank(component.get("v.FlexiReimbursementAmt"))&& component.get("v.FlexiReimbursementAmt")>0){
            
             calculatedValue =component.get("v.FlexiReimbursementAmt");
            
        }else{
        var slicedValue = (rRate == null || $A.util.isEmpty(rRate) || rRate == undefined)?0:rRate.slice(0,-1);
        var actReimbursementAmount = (activityBudgetAmount*slicedValue)/100;
        calculatedValue = parseFloat(actReimbursementAmount.toFixed(2));
       }
        component.set("v.activityAmount",calculatedValue);
        if( this.isNotBlank(component.get("v.activityAmount"))){
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
        }
        
    },
    //OPAL Past Dated Activity Submission process
    onStartDateChange: function(component){
        var todayDate = this.getTodayDateLocalTime();
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
        var newStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var startDateBeforeChange =  component.get("v.oldStartDate"); //use ternary operator
        var mode = component.get("v.mode");
        var oldBT = component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c");
        var budgetType = component.get("v.selBudgetType");
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
        //added fix - When Start date was getting changed available budget was getting auto selected even if multiple budgets are available
        component.set("v.selAvailableBudget",'');

        if (mode == 'clone' && oldBT != null) {
            if (oldStartDate != null && newStartDate < todayDate && !component.get("v.externalper") && !component.get("v.activatingaccper") && (opalBudgetTypes.includes(budgetType) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) )) {
                component.set("v.IsPR", true);
            } else {
                component.set("v.IsPR", false);
            }
        }
        if ( mode == 'edit' && oldBT != null) {
            if (oldStartDate != newStartDate && newStartDate < todayDate && !component.get("v.externalper") && !component.get("v.activatingaccper") && (opalBudgetTypes.includes(budgetType) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) )) {
                component.set("v.IsPR", true);
            } else {
                component.set("v.IsPR", false);
            }
        }
        if (mode != 'clone' && mode != 'edit') {
           
            if (newStartDate < todayDate && (opalBudgetTypes.includes(budgetType) || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_EEF_RecordType") || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) )) {
                if (!component.get("v.externalper") && !component.get("v.activatingaccper")) {
                    if ((component.get("v.SelPotentialReason") == "" || component.get("v.SelPotentialReason") == null || component.get("v.SelPotentialReason") == 'None')) {
                        component.set("v.IsPR", true);
                        component.set("v.IsStartDateChanged", true);
                    }
                    else{
                        component.set("v.IsPR", true);
                    }
                }
            }
            else{
                component.set("v.IsPR", false);
                component.set("v.IsStartDateChanged", false);
            } 
            if(component.get("v.externalper") || (component.get("v.activatingaccper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
                if(newStartDate < todayDate && (opalBudgetTypes.includes(budgetType) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))){
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                    this.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                    component.set("v.IsStartDateChanged", true); 
                }
                else{
                    component.set("v.IsStartDateChanged", false);
                }
            }
        }
        if (component.get("v.externalper") || (component.get("v.activatingaccper") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType"))) {
            if (oldStartDate != null && oldStartDate != newStartDate && newStartDate < todayDate) {
                if(
                   (mode == 'clone' && (opalBudgetTypes.includes(budgetType) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")))
                   || (mode == 'edit' && (opalBudgetTypes.includes(budgetType) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")))){
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");
                    this.displaySuccessErrorMsg(alertMsg, "Error!", "error"); // call common method to display error
                    component.set("v.IsStartDateChanged", true);
                }
                
            } else if(newStartDate >= todayDate && (opalBudgetTypes.includes(budgetType)) || recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_EEF_RecordType")){
              component.set("v.IsStartDateChanged", false);
            }
        }
        
        if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true" && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.mode") == ''){
            this.activityPicker(component, recordTypeDeveloperName);
        }
        
        if(this.isNotBlank(newStartDate) && this.isNotBlank(startDateBeforeChange)){
            var oldYear = new Date(startDateBeforeChange).getUTCFullYear(); //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
            var newYear = new Date(newStartDate).getUTCFullYear(); //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
            if(oldYear != newYear){
                if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true" && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                    this.activityPicker(component, recordTypeDeveloperName);
                
                    if(component.get("v.mode") == 'edit'){
                        component.set("v.SelCategory", '');
                    }
                }
            }
        }
        component.set("v.oldStartDate",newStartDate);
       
    },
    
  
    availableBudgetCheck: function (component, event, helper){
        var budgetType = component.get("v.budgetTypeVal");
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var recordTypeName = component.get("v.recordtypeDeveloperName");
        var campaignBudget = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
        var proposalBasedCamp = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        var isMatchingBudgetAvailable = false;
        if (component.get("v.mode") == "" && $A.util.isEmpty(budgetType))
        {
            if ((recordTypeName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeName == $A.get("$Label.c.Core_MDF_PFR_DCF")) && (campaignBudget != null && campaignBudget != undefined && campaignBudget != 'CCF 1.0' && campaignBudget != 'DCF 1.0')){                
                var campBudget = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c").split(";");   
                campBudget.forEach(value =>{ 
                    isMatchingBudgetAvailable = opalBudgetTypes.includes(value);
                }); 
                }
                    else{
                    isMatchingBudgetAvailable = true;
                }
                }
                    return isMatchingBudgetAvailable;
                },
                    //added by SS
                    hasIUPGMRecord : function (component){
                        var userID = $A.get("$SObjectType.CurrentUser.Id");
                        component.set("v.userId", userID);
                        if(this.isNotBlank(component.get("v.selectedPartner.Id"))&&this.isNotBlank(component.get("v.recordtypeDeveloperName"))
                           && this.isNotBlank(component.get("v.selectedCountryOptions")) && this.isNotBlank(component.get("v.approvalStage"))
                           && this.isNotBlank(component.get("v.userId"))){
                        
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
                                    this.setPriceReviewerDisableState(component);
                                }else{
                                    component.set("v.hasIUPGMRecord", false);
                                }                  
                            } 
                        });
                        $A.enqueueAction(action);
                        }
                    },
		       // This function removes the excluded Picklist values from the Array of initialPicklistOptions                
       removePicklistValues: function( excludedValues, initialPicklistOptions){
            var finalPicklistOptions = new Array();
            initialPicklistOptions.forEach(item => {	
                if(!excludedValues.includes(item.label)){
                    finalPicklistOptions.push(item);
                }
            });
            return finalPicklistOptions;
        },
      	handleLegacyActivityCreation:function(component,event){
            
             var campaignBudgetType = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
            if(component.get("v.isActivityCreationOnCampaign") == true 
              && (campaignBudgetType == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") 
                 	|| campaignBudgetType == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")
                 	||component.get("v.recordtypeDeveloperName")==$A.get("$Label.c.Core_MDF_PFR_SPCF")
                    ||component.get("v.recordtypeDeveloperName")==$A.get("$Label.c.Core_MDF_PFR_CCF_Boost")) ){
                 var toastEvent= $A.get("e.force:showToast");
                toastEvent.setParams({
                    title:"Error",
                    message:$A.get("$Label.c.Core_MDF_ActivityCreationError"),
                    type: "error",
                    duration:20000
                    
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
                    
    	} , 
                    
        handleLegacyActivityCloneEdit:function(component,event){
            
            var campaignBudgetType = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
            if( (component.get("v.mode") == "clone" || component.get("v.mode") == "edit") 
               && (campaignBudgetType == $A.get("$Label.c.Core_MDF_BudgetType_CCF1_0") 
               		|| campaignBudgetType == $A.get("$Label.c.Core_MDF_BudgetType_DCF1_0")
                    ||component.get("v.recordtypeDeveloperName")==$A.get("$Label.c.Core_MDF_PFR_SPCF")
                    ||component.get("v.recordtypeDeveloperName")==$A.get("$Label.c.Core_MDF_PFR_CCF_Boost"))){
                var toastEvent= $A.get("e.force:showToast");
                toastEvent.setParams({
                    title:"Error",
                    message:$A.get("$Label.c.Core_MDF_ActivityCloneEditError"),
                    type: "error",
                   duration:20000
                });
                toastEvent.fire();
                 

                	component.find("navService").navigate({
                       type: 'standard__recordPage',
                        attributes: {
                            actionName: 'view',
                            objectApiName: 'PartnerFundRequest',
                            recordId : component.get("v.recordId")
                            
                        },
                    });
               
            }
                        
        },
    enableDisableButtons : function(component, isSaveDisable, isSaveandNewDisable){
        component.set("v.isSaveDisable", isSaveDisable);
        component.set("v.isSaveandNewDisable", isSaveandNewDisable);
    },

    picklistValuesAddition: function (filedslocalizedMap, selectedFieldsValues, fieldValuesOptionsMap) {
        console.log('filedslocalizedMap--> ',filedslocalizedMap);
        for(var index = 0; index < selectedFieldsValues.length; index++){
            if(!fieldValuesOptionsMap.find((fieldValues) => fieldValues.value === selectedFieldsValues[index])){
                fieldValuesOptionsMap.push({
                    "label": filedslocalizedMap[selectedFieldsValues[index]],
                    "value": selectedFieldsValues[index]
                });
            }
        }
        console.log('fieldValuesOptionsMap--> ',fieldValuesOptionsMap);
        return fieldValuesOptionsMap;
    },

    picklistValuesRemoval: function (selectedFieldsValues, fieldValuesOptionsMap) {
        var fieldValues = "";
        for(var index = 0; index < selectedFieldsValues.length; index++){
            if(fieldValuesOptionsMap.find((fieldValues) => fieldValues.value === selectedFieldsValues[index])){
                if(fieldValues == undefined || fieldValues == null || fieldValues == ""){
                    fieldValues = selectedFieldsValues[index];
                }
                else{
                    fieldValues += ";" + selectedFieldsValues[index];
                }
            }
        }
        return fieldValues;
    },
                    validateOpportunityId : function(component,event,helper){
                        var oppId = component.get("v.newPFR.Core_MDF_Opportunity_id__c");
                        if(this.isNotBlank(oppId) && (oppId.length != 18 || !(/^[a-zA-Z0-9]{18}$/.test(oppId))) && !oppId.startsWith(" "))
                        {
                            component.set("v.isInvalidOppId",true );
                        }else{
                            component.set("v.isInvalidOppId",false );
                        }
                        return component.get("v.isInvalidOppId");
                    },
     //capture start time during activity creation               
     partnerEffortMetricForActivityCreation : function(component){
        var currDateTime = new Date();
        const startDateTime = new Date(currDateTime).toISOString();
        component.set("v.activityCreationStartTime",startDateTime); 
        },
                    
       case_insensitive_sort : function (picklistValue1, picklistValue2) {
	        if((picklistValue1 instanceof Object) && (picklistValue2 instanceof Object)){
	            if(picklistValue1.value != "" && picklistValue1.value != undefined && picklistValue2.value != "" && picklistValue2.value != undefined){
	                return picklistValue1.value.toLowerCase().localeCompare(picklistValue2.value.toLowerCase());
	            }
	        }
	        else{
		    return picklistValue1.toLowerCase().localeCompare(picklistValue2.toLowerCase());
	        }
	    },
        getFieldEditabilityMapping : function(component, event){
            component.set("v.showSpinner", true);
            var fieldEditibilityMap = component.get("c.getFieldEditabilityMapping");
            fieldEditibilityMap.setParams({
                obj: component.get("v.newPFR"),
                contentType: 'Field Editability'
            });
            
            fieldEditibilityMap.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var result = response.getReturnValue(); 
                    if(result != undefined && result != null){ 
                        console.log('Editability Expected Record-->',JSON.stringify(result.confiqRecord));
                        
                        if(result.fieldEditability != null && Object.keys(result.fieldEditability).length > 0){
                            component.set("v.disabledMap",result.fieldEditability);
                            var child = component.find("tacticMetrics");
                            if (child && component.get("v.disabledMap.tactics")) {
                                  child.handleEdit(component.get("v.disabledMap.tactics"));
                            }
                            //Akash - Ecosystem
                            var child = component.find("ecosystemAllocation");
                            if (child && component.get("v.disabledMap.cp")) {
                                child.handleEdit(component.get("v.disabledMap.cp"));
                            }
                            console.log('Editability Confiq-->',JSON.stringify(result.fieldEditability));
                            
                        }else{
                            this.displaySuccessErrorMsg($A.get("$Label.c.Core_MDF_CloneAccessError"),'Error','error');
                            component.find("navService").navigate({
                                "type": "standard__recordPage",
                                "attributes": {
                                    "recordId": component.get("v.recordId"),
                                    "objectApiName": "PartnerFundRequest",
                                    "actionName": "view"
                                }
                            });
                        }
                        
                    }else{
                        component.set("v.disabledMap",[]);
                    }
                }else{
                    component.set("v.disabledMap",[]);
                }
                component.set("v.showSpinner", false);
            });
            $A.enqueueAction(fieldEditibilityMap);
        },
             
        isCMPEligibleApproval : function(component, budType, actSelType, actSelCategory, intelContri,actDomainType){
             if(budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")){
                if((($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(actSelCategory) && intelContri >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold"))
                  || ((($A.get("$Label.c.Core_MDF_CMP_activity_type_eligible_for_approval").split(';')).includes(actSelType)) && (actSelCategory == $A.get("$Label.c.Core_MDF_Activity_Category_Digital_Media") || (actSelCategory == $A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory") && this.isNotBlank(actDomainType) && actDomainType ==$A.get("$Label.c.Core_MDF_Domain_Type_Form_Values") && intelContri >= $A.get("$Label.c.Core_MDF_ManagerApprovalThreshold"))))){				
                            return true;
                   }
              }
         },

         filterNewCategoryValues : function(component,categoryValuesMap){
            var latestCategoryValues = [];
            var startDateYear = new Date(component.get("v.newPFR.Core_MDF_Start_Date__c")).getUTCFullYear(); //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
            var categoryPicklistValuesMap;
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                if ( startDateYear < $A.get("$Label.c.Core_MDF_NewCategoryDate")){
                    latestCategoryValues = component.get("v.latestCategoryValues");
                    categoryPicklistValuesMap = categoryValuesMap.filter(item => !latestCategoryValues.some(itemToBeRemoved => itemToBeRemoved.value === item.value));
                }
                else if(startDateYear >= $A.get("$Label.c.Core_MDF_NewCategoryDate")){
                    latestCategoryValues = component.get("v.latestCategoryValues");       
                    //commenting below code as it was pushing none value everytime and was causing issue in case if we change to 2024.      
                    /*if(latestCategoryValues.length >=1){
                        latestCategoryValues.push({
                            class: "optionClass",
                            label: "--None--",
                            value: ""
                        });
                    }*/
                    categoryPicklistValuesMap = categoryValuesMap.filter(item => latestCategoryValues.some(itemToBeRemoved => itemToBeRemoved.value === item.value));
                }
                //Ayush - adding None on the 0th index as when changing date from 2025 to (2024 or before) the first value was getting selected as none was not present in the options.
                if(!categoryPicklistValuesMap.some(item => item.label === $A.get("$Label.c.Core_MDF_PFR_None_Translation")) && categoryPicklistValuesMap.length >=1){
                    categoryPicklistValuesMap.splice(0, 0, {class: "optionClass", label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"), value: ""});
                }
            }
            return categoryPicklistValuesMap;
        },

        getNewCategoryValues : function(component, recordTypeDevName){
            if(recordTypeDevName != $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                var newValues = [];
                var action = component.get("c.getNewCategoryValues");
                action.setParams({
                    "program": recordTypeDevName,
                });
                //component.set("v.showSpinner", true);
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    
                    if (state === "SUCCESS"){
                        var result = response.getReturnValue();
                        for(var index = 0; index < result.length; index++){ 
                            newValues.push({
                                class: "optionClass",
                                label: result[index],
                                value: result[index]
                            }); 
                        }
                        component.set("v.latestCategoryValues",newValues);
                    }
                    else{
                        var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                        this.displaySuccessErrorMsg(errorMessage, "Error", "error");
                    }
                });
                $A.enqueueAction(action);
            }
        },

         //Ayush - added sanitize method for semgrep fix.
         sanitizeResults : function(result){
            if(result != null && result != undefined && result != {} && Object.keys(result).length > 0){
                return result;
            }
            else{
                return null;
            }
        },
                    
    setCampaignOutcomeBasedOptIn: function(component) {
    // Set outcome based opt-in from Campaign
    if(this.isNotBlank(component.get("v.selectedLookUpRecord")) && 
       this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c"))){
        component.set("v.outcomeBasedOptInInd", component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c"));
    } 
		},

    // Akash CCF DCF - Apply the Account Plan start date validation
    validateStartDate: function(component, startDate) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var isCCFOrDCF = recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") ||
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF");
        var CCFDCFOBCStartDate = $A.get("$Label.c.Core_MDF_CCF_DCF_BlockCampaign_StartDate");

        if (isCCFOrDCF && startDate) {
            component.set("v.showStartDateError", new Date(startDate) >= new Date(CCFDCFOBCStartDate));
        } else {
            component.set("v.showStartDateError", false);
        }
    }

    });