({
    // Helper function called from Custom Save Function controller js
    // Calls Server Side Controller function which saves the record after performing all the server side validation
    
    saveHelperMethod: function (component, newPFR) {
        
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        this.applyIPAProposalCurrency(component, newPFR);  // Indu IPA Proposal 
        
        //[IPA - Budget CAP]  - [OOC - P8] - Internal Account Manager/External - Validation Reimbursement Amount against Budget CAP
        //Throw a soft pop-up error if Budget Cap Amount Exceeded && component.get("v.isBudgetCapExceeded")
        if(!component.get("v.chkBdgtCpExcd") &&
        ((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true))){   
            //[IPA MDF] - Campaign - Clone a Proposal - Activity Section - fire event and pass edited pfr object to campaign
            if(component.get("v.pfrCloneCheck")){
                var checkValidaProposalActivity = this.validateActivity(component);
                var contentDocId =[];
                var allowPFRSaveInd =true;
                if(component.get("v.ContentDocumentIds") != null){
                    contentDocId = component.get("v.ContentDocumentIds").join(',');
                    if(contentDocId.length >0){
                        if(contentDocId.length > 250){
                            allowPFRSaveInd = false;
                            component.set("v.chkBdgtCpExcd",false);
                            component.set("v.ShowEventPopup",false);
                            var toastEventfailure = $A.get("e.force:showToast");
                            toastEventfailure.setParams({
                                title: $A.get("$Label.c.Core_MDF_Error"),
                                message: $A.get("$Label.c.Core_MDF_Activity_File_Upload_Error"),
                                type: "Error"
                               
                            });
                            toastEventfailure.fire();  
                        }
                    }
                }
                var campignOutComeBasedInd = false;
                if(component.get("v.updatedCampaignObj") != null){
                   var actRec = component.get("v.newPFR");
               	   var updatedCampValues = component.get("v.updatedCampaignObj");
                   var updatedCampStartDate = component.get("v.updatedCampaignObj.StartDate");
                   var updatedCampEndDate = component.get("v.updatedCampaignObj.EndDate");
                   campignOutComeBasedInd = component.get("v.updatedCampaignObj.Core_MDF_CampOutcomeOpt_In_Ind__c");
                   var pfrStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        		   var pfrEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
                   var alertMsg = $A.get("$Label.c.Core_MDF_Campaign_Date_Check_Error");
                if(pfrStartDate < updatedCampStartDate || pfrEndDate > updatedCampEndDate){
					component.set("v.campPfrDateMismatch", true);
                  }
                    else{
                        component.set("v.campPfrDateMismatch", false);
                    }
            }
                if(allowPFRSaveInd == true && checkValidaProposalActivity == false){
                    component.set("v.newPFR.Core_MDF_Content_DocumentIds_txt__c",contentDocId);
                var actRec = component.get("v.newPFR");
	      if(this.isNotBlank(component.get("v.IPAIntelContri"))){
		      actRec.Core_MDF_Activity_Reimbursement_Amt_nbr__c = component.get("v.IPAIntelContri");
	      }
                var updatedBuSplit = component.get("v.updatedBuSplit");
                var cmpEvent = component.getEvent("ipaActRecClone");
                var isBlankMetrics = this.validateIPAMetricsValues(component);
                
                //Capture the event from Core_MDF_Tactics_Form LWC Component to validate the Tactic Metric section
                var outcomeBasedOptInInd = component.get('v.outcomeBasedOptInInd');
                var outcomeBased = component.get('v.showActTactics');
                if(outcomeBased){
                    let childCmp = component.find("tacticMetrics");
                    if (childCmp) {
                        childCmp.handleSave().then((result) => {

                            
                            component.set('v.activityAttributeList', result.records);
                            component.set('v.hasErrorInTacticMetricsSection', result.noError);
                            component.set("v.chkBdgtCpExcd",true);
                            this.chkBudgetCap(component,newPFR); 
                            //activityAttributeList = [{'Core_MDF_Field_Name_nm__c' : 'Digital Media - # of Clicks','Core_MDF_Field_Value_nbr__c': 34, 'Core_MDF_Type_nm__c' : 'KPI', 'Core_MDF_Tactics_nm__c' : 'Digital Media'}, 
                            //                      {'Core_MDF_Field_Name_nm__c' : 'Digital Media Percentage Spend','Core_MDF_Field_Value_nbr__c': 100, 'Core_MDF_Type_nm__c' : 'Percentage', 'Core_MDF_Tactics_nm__c' : 'Digital Media'}];
                            actRec.tacticMetricEdited = true;
                            actRec.kpiMetricEdited = false;
                            var activityToAttrList = {activity : actRec, activityAttribute : result.records};
                            cmpEvent.setParams({"detail" : actRec, "buSplitDetail" : updatedBuSplit, "isMetricsBlank" : (isBlankMetrics && !outcomeBased), 'activityToAttrList' : activityToAttrList, "isBlankTacticMetrics" : !result.noError});
                            cmpEvent.fire();
                        }).catch((error) => {
                            component.set("v.chkBdgtCpExcd",false);
                        });
                    }
                }else{
                    component.set("v.chkBdgtCpExcd",true);
                    this.chkBudgetCap(component,newPFR); 
                    actRec.tacticMetricEdited = false;
                    actRec.kpiMetricEdited = true;
                    cmpEvent.setParams({"detail" : actRec, "buSplitDetail" : updatedBuSplit, "isMetricsBlank" : isBlankMetrics, 'activityToAttrList' : {activity : actRec, activityAttribute : []}, "isBlankTacticMetrics" : outcomeBasedOptInInd ? true : false});
                    cmpEvent.fire(); 
                }   
            }
            }else{
                component.set("v.chkBdgtCpExcd",true);
                this.chkBudgetCap(component,newPFR); 
            }
        }else{
            
            //Fix For Locale Issue
            
            var exchangeRateJSNumFormat = Number(component.get("v.newPFR.Core_MDF_Exchange_Rate_ptc__c")); 
            if(component.get("v.mode") == 'clone'){
                component.set("v.newPFR.Core_MDF_IsCloned_Ind__c", true);
            }
            component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateJSNumFormat);
            if(component.get("v.mode") != 'edit')
               {
                 component.set("v.newPFR.Core_MDF_StartTime_dtm__c", component.get("v.activityCreationStartTime"));
            	}
            
            //Proposal based clone issue fix - Parent activity was getting updated when activity was saved through pencil icon click on cloned proposal
            if((component.get("v.mode") != 'clone' && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true))
                || (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false )) {   
                
                //Ayush - Fix for save button getting disabled on proposal clone whenever an error occured. 
                component.set("v.isSaveDisable", true);
                component.set("v.isSaveandNewDisable", true);
                
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
                    "tacticMetrics": this.isNotBlank(component.get("v.tacticMetricsValues")) ? component.get("v.tacticMetricsValues") : null
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
                            component.set("v.selectedLookUpRecord.Id",null);
                        } 
                        
                        else if ((this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))&& component.get("v.isPropBasedCampaign") == true)){
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
       else if(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false){
           //Budget Types excluded -- proposal based
		    var accountId;
            var selectedbudget;
            var recordTypeDevName;
            
            if(component.get("v.mode")==''){
                recordTypeDevName= component.get("v.recordtypeDeveloperName");
            }
            else if(component.get("v.mode")=='edit'||component.get("v.mode")=='clone'){
                recordTypeDevName=component.get("v.newPFR.RecordType.DeveloperName");
            }
            
            accountId=component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Id");
            selectedbudget=component.get("v.selAvailableBudget");
            component.set("v.newPFR.Core_MDF_Budget_id__c",selectedbudget);
            component.set("v.newPFR.BudgetId",selectedbudget);
            
            //Method call for fetching allocations
            var action = component.get("c.checkAvailableAllocAmt");
            action.setParams({
                pfr: component.get("v.newPFR"),
                recordType:recordTypeDevName,
                accountId:accountId,
                budgetId:selectedbudget
                
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
                    if(amountToBeDisplayed!=$A.get("$Label.c.Core_MDF_ZeroAllocationAmount")){
                        //var returnResult;
                        if(isAutoEnabled==true){//Setting message for 'Auto Enabled'
                       		 component.set("v.showAllocationAmtMsg",$A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg")+" "+
                                            formatter.format(amountToBeDisplayed)+" "+$A.get("$Label.c.Core_MDF_AllocationAmountAutoEnabled"));    
    						 component.set("v.isShowAllocationAmt",true);
                        }
                        else{
                             component.set("v.showAllocationAmtMsg",$A.get("$Label.c.Core_MDF_AllocationAmountAvailableMsg")+" "+formatter.format(amountToBeDisplayed));
                             component.set("v.isShowAllocationAmt",true);
                        }
                        component.set("v.newPFR.AllocationId",allocationId);//Setting Allocation on Budget
                           
                    }
                    else{
                        if(this.isNotBlank(component.get("v.selAvailableBudget")))
                        {
                           component.set("v.isShowAllocationAmt",true);
                           component.set("v.showAllocationAmtMsg",amountToBeDisplayed);
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
        var Draft_Status = $A.get("$Label.c.Core_MDF_PFR_Status_Draft_IPA");
        var RevisionRequired_Status = $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired");
        
        var sFilter = "";
        var aFilter = "";
        
        // constructing the filter  -- RecordType
         if (recordtype == $A.get("$Label.c.Core_MDF_IPA_RecordType")) { //Retail_Label
                    sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Intel_Partner_Alliance@quote; AND (Core_MDF_Proposal_Based_Ind__c = false OR (Core_MDF_Proposal_Based_Ind__c = true AND (Status In (@quote;" +
                    Draft_Status + "@quote;, @quote;" + RevisionRequired_Status + "@quote;))))";
                }
        // constructing the filer -- date
        if (!$A.util.isEmpty(sFilter)) {
            if (startdate != null && enddate != null && enddate >= startdate) {
                sFilter = sFilter + " AND endDate >=" + enddate + " AND startDate <=" + startdate;
            }
        }
        
        component.set("v.additionalFilter", sFilter);
        component.set("v.additionalAccFilter", aFilter);
        
    },
    // Helper Method called from the custom save function in order to display the popups
    activityPicker: function (component, recordType, skipProductTypeRefresh ) {
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
        var action = component.get("c.customPicklistFetcher");
        
        action.setParams({
            "recordTypeName": recType
        });
        action.setCallback(this, function (response) {
            result = response.getReturnValue();
            //Parse response and initalize attributes            
            var state = response.getState();
            if(state === "SUCCESS"){
            for (var i = 0; i < pickListFields.length; i++) {   
                
                if(skipProductTypeRefresh === true && pickListFields[i].trim() == "Core_MDF_ProductType__c"){continue;}           
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
    },
    
    accPropCampType: function (component) {
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
                 this.applyIPAProposalCurrency(component); 
				  if (
    result === "Proposal Based" &&
    this.isNotBlank(
        component.get("v.newPFR.RequestedAmount")
    )
) {
    this.getActivityAmount(component);
}// Indu IPA Proposal
            }else{
               var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
            }
        });
        
        
    },
    //Rishabh
    //Variable Reimbursement Rate changes
    //Server call to fetch VR Question label
    /*fetchVRQuestion: function (component) {
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
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
            });
            
            $A.enqueueAction(action);
        }
        
        component.set(
            "v.vrOptInQuestion",
            $A.getReference("$Label.c.Core_MDF_VRInc_OptIn_Question")
        );
    },*/
    
    //Server call for checking incentive
    checkVariableReimbursement: function (component) {
        if (!component.get("v.renderVRQuestion") == true &&
            (!$A.util.isEmpty(component.get("v.newPFR.Core_MDF_TargetAudience__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_ProductType__c")) &&
             !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Brand_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_ActivityCategory__c")) &&
             !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Activity_Types__c")) && !$A.util.isEmpty(component.get("v.newPFR.CampaignId")) &&
             !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Start_Date__c")))) {
            
            var cpid;
            
            if (((component.get("v.oldActivtyType") != component.get("v.SelActivityType")) || (component.get("v.oldcategory") != component.get("v.SelCategory")) ||
                 (component.get("v.oldProdType") != component.get("v.SelProductType")) || (component.get("v.oldBrandMulti") != component.get("v.selectedBrandOptions"))
                 || (component.get("v.oldsdate") != component.get("v.newPFR.Core_MDF_Start_Date__c")))
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
                           //TECH [DCF/SPCF] - [OOC] - 60% RR for Intel Select Solutions
                           var questionDisplay = [];
                           var pmemIncentive = false; 
                           var otherIncentive = false;
                           var fetchBrandVal = $A.get("$Label.c.Core_MDF_ActivityRR_Brand").split(";");
                           if(fetchBrandVal.includes(result.pfrData[0].Core_MDF_Brand_nm__c)){
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
        //Added check to identify if its opal activity and category event to hide competitive elements -start
        var selCategory = component.get("v.SelCategory");
        var selActiType = component.get("v.SelActivityType");
        var setBudgType = component.get("v.selBudgetType");
        
        //New Activity Category and Type Changes
        if (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.SelCategory"))  || selCategory == 'Tech Exploration')) {
            component.set("v.hideCompetitiveQuest", true);
       }
      
        //Added check to identify  if its opal activity and category event to hide competitive elements - end
        for (var index = 0; index < metadata.length; index++) {
            // Checking the condition for the Question and Pop-up based on metadata map
            if (metadata[index].Core_MDF_Field_7_txt__c == component.get("v.SelCategory") && metadata[index].Core_MDF_Field_9_txt__c == component.get("v.SelActivityType") &&
                metadata[index].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName")){
                
                callsave = false;
                //Check if Amount is above threshold(The Upload of file is manadtory) 
                //Added extra condition for opal as amount should be calculated against Activity Reimbursement Amount
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
    	var ipaExternalUsr = component.get("v.externalper");
        var reimbrsmtRate = component.get("v.ActReimbursementRt");
        if(this.isNotBlank(reimbrsmtRate)){
            reimbrsmtRate=reimbrsmtRate.replace(/\%/g,'');
        }
        
        //Core_MDF_Total_Campaign_Cost_Amt__c
        var CampCost = component.get("v.selectedLookUpRecord").Core_MDF_Reimbursement_Amount_Amt__c;
        
        //Edit Sceanrio
                if(component.get("v.recordId") != null){
            var oldCalculatedInvestment =
                (parseInt(reimbrsmtRate,10) *
                    parseInt(component.get("v.oldPFR.RequestedAmount"))) /
                100;
            CampCost = CampCost - this.getEffectiveIPAIntelInvestment(
                component,
                oldCalculatedInvestment,
                component.get("v.oldPFR")
            );
        }

        var newCalculatedInvestment =
            (parseInt(reimbrsmtRate,10) *
                parseInt(component.get("v.newPFR.RequestedAmount"))) /
            100;
        totalCampAmt = CampCost + this.getEffectiveIPAIntelInvestment(
            component,
            newCalculatedInvestment,
            component.get("v.newPFR")
        );// Indu IPA Proposal
      
        if(((component.get("v.selectedLookUpRecord").Core_MDF_Available_BudgetCap_amt__c-totalCampAmt) < 0 
            || $A.util.isEmpty(component.get("v.selectedLookUpRecord").Core_MDF_Budget_Cap__c)) 
           && !ipaExternalUsr){
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
    },
    isFileUploadSectionVisible : function(component,metadata,index){
        //For selected Category and Type, validate if File Upload applicable based on metadata field Core_MDF_Enable_File_Upload__c
        //Budget Condtion to check if the entered amount is greater than or equal to threshold
        //[File Upload Section to be Visible if Core_MDF_Enable_File_Upload__c is set to true]
        
        if (metadata[index].Core_MDF_Checkbox_Field_6_Ind__c && component.get("v.checkbudgetcondition") && component.get("v.checkfileuploadcondition") == false) {
            component.set("v.checkfileuploadcondition", true);
            //If Event Activity, then Event form links to be visible
            if(this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event"))){
                component.set('v.isEventFormTemplateVisible',true);
            }
            
        }
        else if (metadata[index].Core_MDF_Checkbox_Field_6_Ind__c && component.get("v.checkfileuploadcondition") == false && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType"))&& this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))) {
            component.set("v.checkfileuploadcondition", true);
            if (this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))) {
                component.set('v.isIndustryPartnerFormTemplateVisible', true);
            }
            
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
        //DE115095 : WW19 | QA3 | When Geo Lead edits an Activity,
        //which is in Planned status and changes the start date to 1 day minus today,
        //then Activity re approval is getting triggered
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var today = this.getTodayDateLocalTime();
        
        
        //DE119369 : WW27 | QA3 | Geo Lead is able to edit Future dated Revision Required activities in specific time
        if(($A.get("$Label.c.Core_MDF_IPA_RecordType") == component.get("v.recordtypeDeveloperName")&& component.get("v.isPropBasedCampaign") == true)&& $A.get("$Label.c.Core_MDF_CCP_Planned_Status") == component.get("v.newPFR.Core_MDF_Fund_Request_Status__c")) {
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired"));
        } else if(!(component.get("v.retailgeouserper")) && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")
                  && !($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status").includes(component.get("v.SelectedStatus")))) {
            if($A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequiredOrPlanned").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")); 
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);  
            }  
        }else if(component.get("v.retailgeouserper") && startDate < today && component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") &&
                 component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == "Planned"){
            this.callNextLevelApproval(component);
        } else if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == "Planned" && component.get("v.isOpalActivity")){
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
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
        var todaysDate = this.getTodayDateLocalTime();
       // Check Editiability for New Scenrio
        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
            || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && this.kpiFieldStatusForAccMngr(component))
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
        
        //updated the KPI visibility logic for IPA MDF Manager + PRice reviewer dual review scenario
        if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.accmgrper") && component.get("v.priceReviewersPer"))) {
                if (component.get("v.approvalStage") == "Price Reviewer") {
                     enableKPI = false;  // Disable KPI only in Price Reviewer stage
                } else {
                     enableKPI = true; // Enable KPI in all other stages for dual role user
               }
        }else if((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.priceReviewersPer"))){
            enableKPI = false;
        }
		
        
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.CurrentStatus") == 'Closed' || component.get("v.CurrentStatus") == 'In-Progress')) {
			
            enableKPI = false;
        }
        
        //IPA Acc Based Approval flow- making metrics as not editable for planned past for both ext & int and for future planned for ext
        if((component.get("v.CurrentStatus") == 'Planned') &&
           component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") &&
           (component.get("v.newPFR.Core_MDF_Start_Date__c") < todaysDate && (component.get("v.externalper") || component.get("v.ipaL2Approver") || component.get("v.ipaApproverPer") || component.get("v.ipaAcctMgr")))) {
            enableKPI = false;
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
            //Mohit - Outcome based updates, removed RMF condition and added check for outcome based and non outcome based
            /*if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail")) {
                component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Event_Ethic"));
            } else {
                component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
            }*/
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
        }
        //[IPA - Budget CAP]  - [OOC - P8] - Internal Account Manager/External - Validation Reimbursement Amount against Budget CAP
        //Throw a soft pop-up error if Budget Cap Amount Exceeded
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        
        if (popuptype == "budgetCap" &&( recordTypeDeveloperName==$A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true ) )
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
    },
    
    // Functions to enable channel partner
    EnableCPCheckBox: function (component, event) {
        var disablecheck = false;
        var isChannelPartner;
        var seltype = component.get('v.SelActivityType');
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
                    
                    if (this.isNotBlank(component.get("v.CurrentStatus")) && component.get("v.CurrentStatus") != 'Closed' && (component.get("v.recordId") == null || component.get("v.checkCloneAttribute") == true)) {
                        component.set("v.disabledMap.cpled", !isChannelPartner);
                    } 
                } else {
                    component.set("v.disabledMap.cpled", isChannelPartner);
                }
            }
            component.set("v.IsCP", isChannelPartner);
        });
        $A.enqueueAction(action);
        
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
                    
                    if(fldname != "Core_MDF_Reimbursement_Rate_pct__c" && fldname !="Core_MDF_Country_nm__c" && fldname != "Core_MDF_Key_Marketing_Indicator_nm__c" && fldname != "Core_MDF_Tactics_nm__c"){    //Skip adding --None-- value to Reimbursement Rate picklist    
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
                component.set("v.ActivityCategoriesMain", ParPickField); 
                // OPAL Change
            }
            if (fldname == "Core_MDF_Focus_Area_nm__c") {
                component.set("v.focusArea", ParPickField);
                
            }
            if (fldname == "Core_MDF_Country_nm___c") {
                component.set("v.Countries", ParPickField);               
            }
            if (fldname == "Core_MDF_Brand_nm__c") {
                component.set("v.BrandPicklistValues", ParPickField);
                this.updateBrandPickVals(component);
            }
            if (fldname == "Core_MDF_TargetAudience__c") {
                component.set("v.TargetAudience", ParPickField);
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
                this.updateRRPickVals(component);
            }    
            
          
            //Activity Type as parent field for Event Format
            if (fldname == "Core_MDF_Activity_Types__c") {
                component.set("v.ActivityTypes", ParPickField);
            }
            if(fldname == "Core_MDF_Tactics_nm__c"){
                component.set("v.activityTacticsOptions", ParPickField);
                this.updateTacticsPickVals(component);
            }
			//Product Type Picklist values assignment
            
        } // Child picklist field construction
        else {
            if (fldname == "Core_MDF_Activity_SubType_nm__c") {
                component.set("v.activityMultiSelSubType", childPickField);
                this.dependentPickValAdditionAndRemoval(component, fldname);
                this.fetchActSubTypeMulti(component);
            }
            if (fldname == "Core_MDF_Activity_Classification_nm__c") {
                component.set("v.activitySelClassification", childPickField);
                this.fetchActClassification(component);
            }
            if (fldname == "Core_MDF_Activity_Types__c") {
                component.set("v.ActivityTypes", childPickField);
                this.dependentPickValAdditionAndRemoval(component, fldname);
                this.fetchActType(component);
            }
            if (fldname == "Core_MDF_Event_Name_nm__c") {
                console.log('childPickField-->'+childPickField);
                component.set("v.EventNameMap", childPickField);
                this.dependentPickValAdditionAndRemoval(component, fldname);
                this.fetchEventName(component);
            }
            if(fldname == "Core_MDF_Key_Marketing_Indicator_nm__c"){
                component.set("v.kpiPicklistValues", childPickField);
                this.fetchKPI(component);
            }
             if (fldname == "Core_MDF_Industry_Multi_nm__c") {
                component.set("v.IndustryTypes", childPickField);
                this.fetchIndustryTypes(component);
            }

            if (fldname == "Core_MDF_ProductType__c") {
                component.set("v.ProductTypes", childPickField);               
                this.fetchProdType(component);
            }
            
            if (fldname == "Core_MDF_TargetAudience__c") {
                component.set("v.TargetAudience", childPickField);               
                this.fetchTargetAudience(component);
            }
            if (fldname == "Core_MDF_TargetAudience_nm__c") {
                component.set("v.audiencePicklistValues", childPickField);     
                this.fetchMultiTargetAudience(component);
            }
           if (fldname == "Core_MDF_Priority_nm__c") {
                component.set("v.priority", childPickField);
                this.fetchPriority(component);
            }
            if (fldname == "Core_MDF_Brand_nm__c") {
                component.set("v.MultiBrandTypes", childPickField);
                this.fetchMultiBrandType(component);
            }
            if (fldname == "Core_MDF_Initiative_nm__c" ) {
                component.set("v.initiativePicklistValues", childPickField);
                this.fetchMultiInitiative(component);
            }
            if (fldname == "Core_MDF_EcosystemPartner_nm__c" ) {
                component.set("v.MultiEcoPartnerTypes", childPickField);
                this.fetchMultiEcoPartnerType(component);
            }
            if (fldname == "Core_MDF_Event_Format_Nm__c") {
                component.set("v.eventFormats", childPickField);
                component.set("v.setEventFormatOptionOnload", true);
                this.fetchEventFormat(component);
            }
            if (fldname == "Core_MDF_Reimbursement_Rate_pct__c") {
                component.set("v.RRPercent", childPickField);
                this.fetchRRPercent(component);
            }
            if (fldname == "Core_MDF_ActivityCategory__c") {
                component.set("v.ActivityCategories", childPickField); 
                component.set("v.ActivityCategoriesMain", childPickField);
                this.dependentPickValAdditionAndRemoval(component, fldname);
                this.fetchActCategory(component);
            }
            if (fldname == "Core_MDF_Focus_Area_nm__c") {
                component.set("v.focusArea", childPickField); 
                this.fetchFocusArea(component);
            }
            if (fldname == "Core_MDF_Country_nm__c") {
                component.set("v.CountryPicklistValues", childPickField);
                this.fetchCountry(component);
            }
            if (fldname == "Core_MDF_Domain_Type_nm__c") {
                component.set("v.DomainTypeOptions", childPickField);
                this.fetchDomainTypeOptions(component);
            }
        }
    },

    updateRRPickVals: function (component){

                var flexRR =  component.get("v.SelReimbursementRate");
                flexRR = (flexRR>100)?100:flexRR;
                var rrPickValues = [];
                var pickValues = [];
                //Akash-RR%
                if (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") && ((component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c") && component.get("v.mode") != 'clone') || (component.get("v.mode") == 'clone' && component.get('v.outcomeBasedOptInInd')))) {
                    pickValues = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions100").split(';');
                }
                else{
                    pickValues = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
                }
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
       		if(component.get("v.externalper")){
                component.set("v.disableRRPercent",true);
                if(component.get("v.mode") != 'edit' && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false){
					 component.set("v.ActReimbursementRt", "");
                    component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", component.get("v.ActReimbursementRt"));
				}
            }
        	else {
				if(this.isNotBlank(component.get("v.ActReimbursementRt"))){
                    //Akash-RR%
                    if (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") && component.get("v.SelReimbursementRate") != $A.get("$Label.c.Core_MDF_BudgetType_RRate100") && ((component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c") && component.get("v.mode") != 'clone') || (component.get("v.mode") == 'clone' && component.get("v.outcomeBasedOptInInd")))) {
                        component.set("v.disableRRPercent",false);
                    }
                    else{
                        component.set("v.disableRRPercent",true);
                    }
				}
                else{
                    //Akash-RR%
                    if (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") && ((component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c") && component.get("v.mode") != 'clone') || (component.get("v.mode") == 'clone' && component.get('v.outcomeBasedOptInInd')))) {
                        component.set("v.disableRRPercent",true);
                    }
                    else{
                        component.set("v.disableRRPercent",false);
                    }
				}
			
			}
        //removed code "!this.isNotBlank(component.get("v.SelReimbursementRate"))" from external user check and added only for create scenario
        if(!this.isIPAProposalBased(component) &&
   (component.get("v.ActReimbursementRt") == "" ||
    (this.isNotBlank(component.get("v.ActReimbursementRt")) &&
     component.get("v.mode") == 'clone' &&
     component.get("v.externalper")))){
            if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
               && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true 
               && (component.get("v.mode") == '' && !this.isNotBlank(component.get("v.SelReimbursementRate"))) || (component.get("v.mode") == 'clone' && component.get("v.externalper")))/* && !this.isNotBlank(component.get("v.SelReimbursementRate"))*/{ //commented as for external user clone RR was not defaulting to 50 or 25 
                var reimburesmentRate;
                if( this.isNotBlank(component.get("v.newPFR.Core_MDF_Budget_Type_nm__c"))){
                    //Akash-RR%
                    if((component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c") && component.get("v.mode") != 'clone') || (component.get("v.mode") == 'clone' && component.get('v.outcomeBasedOptInInd'))){
                        var reimburesmentRate = $A.get("$Label.c.Core_MDF_BudgetType_RRate100");
                        component.set("v.SelReimbursementRate", reimburesmentRate);
                        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
                    }
                    else{
                        //Akash - TWC702-14284
                        reimburesmentRate = component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_Proposal_I_Label") ? $A.get("$Label.c.Core_MDF_ReimburesementNum50") : component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_Proposal_II_Label") ? $A.get("$Label.c.Core_MDF_ReimburesementNum25") : '';
                    }
                }
                else if(this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c"))){
                    if((component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c") && component.get("v.mode") != 'clone') || (component.get("v.mode") == 'clone' && component.get('v.outcomeBasedOptInInd'))){
                        var reimburesmentRate = $A.get("$Label.c.Core_MDF_BudgetType_RRate100");
                        component.set("v.SelReimbursementRate", reimburesmentRate);
                        component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
                    }
                    else{
                        //Akash - TWC702-14284
                        reimburesmentRate = component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == $A.get("$Label.c.Core_MDF_Proposal_I_Label") ? $A.get("$Label.c.Core_MDF_ReimburesementNum50") : component.get("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c") == $A.get("$Label.c.Core_MDF_Proposal_II_Label") ? $A.get("$Label.c.Core_MDF_ReimburesementNum25") : '';
                    }
                }
                component.set("v.SelReimbursementRate", reimburesmentRate);
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c", reimburesmentRate);
            }
        }
        this.applyIPAProposalReimbursementRate(
    component,
    this.isNotBlank(component.get("v.ActReimbursementRt"))
        ? component.get("v.ActReimbursementRt")
        : component.get("v.SelReimbursementRate"),
    false
);
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
        //getting the dependent activity type picklist values by passing the controlling Activity Category value 
        var otherActTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");    
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelCategory"), component.get("v.ActivityTypes"));
        if((component.get("v.newPFR.Core_MDF_Program__c") == $A.get("$Label.c.Core_MDF_IPA_Program_Name") 
            || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))&& component.get("v.externalper")){
            
            if(component.get("v.mode") != 'edit' || (component.get("v.mode") == 'edit' 
                                                     && ((component.get("v.oldPFR.Core_MDF_ActivityCategory__c") != null &&
                                                          component.get("v.oldPFR.Core_MDF_ActivityCategory__c") != component.get("v.SelCategory"))
                                                         || (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") =='Draft' 
                                                             && component.get("v.newPFR.Core_MDF_CreatedBy__c") !='Intel System User') ||
                                                     (component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") =='Revision Required' && 
                                                         (!otherActTypes.includes(component.get("v.oldPFR.Core_MDF_Activity_Types__c"))))
                                                         ||(component.get('v.externalper') && !(($A.get("$Label.c.Core_MDF_OtherActivityTypes").split(",")).includes(component.get("v.oldPFR.Core_MDF_Activity_Types__c"))))
                                                         
                                                    ))){
                
                if(childValuesReturn != null && childValuesReturn.length > 0 ){
                    childValuesReturn = this.removePicklistValues(otherActTypes,childValuesReturn);
                }
            }
        }
        if(childValuesReturn != null && childValuesReturn.length > 0 ){
            childValuesReturn.sort(this.case_insensitive_sort);
        }
        component.set("v.ActivityTypeValues", childValuesReturn);
        
    },
    
    //fetching the Focus Area values    
     fetchFocusArea: function (component) {
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.recordtypeName"), component.get("v.focusArea"));
         if(childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1){
             childValuesReturn.sort(this.case_insensitive_sort);
             var localizedval = this.localizeSubType(component, childValuesReturn);
             component.set("v.focusAreaDependent", localizedval);
             this.updatefocusAreaPickVals(component);
         }
    },
    
    fetchActCategory: function (component) {
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.ActivityCategories"));
        if(childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1){
            childValuesReturn.sort(this.case_insensitive_sort);
            var localizedval = this.localizeSubType(component, childValuesReturn);
            component.set("v.ActivityCategoriesValues", localizedval);
        }
    },

    //fetching country values based on Program from field dependency.
    fetchCountry: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var childValuesReturn = [];
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
    
            childValuesReturn = this.setChildPicklistValues(component, component.get("v.recordtypeName"), component.get("v.CountryPicklistValues"));
            if(childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1){
                childValuesReturn.sort(this.case_insensitive_sort);
                component.set("v.CountryPicklistValues", childValuesReturn);
                this.updateCountryPickVals(component);
            }                	
       }
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
    }, 
    
    //method to set event name as 'other' as default when activity type is Other (Event) on edit scenario
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
    
    fetchActCat: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var budType = "";
        var mode = component.get("v.mode");
        var propBased = "";
         if(component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != undefined){
            propBased = component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c");
        }
        else{
            propBased = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        }
        if(mode == 'clone' && component.get("v.updatedCampBudgetType") != undefined && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && propBased){
            budType = component.get("v.updatedCampBudgetType");
        }
        else{
        	if(( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) || component.get("v.selBudgetType") == null){
        		budType = component.get("v.selectedLookUpRecord").Core_MDF_Opal_Budget_Type_Txt__c;
        	}
        	else{
            	budType = component.get("v.selBudgetType");
        	}
        }
        var childValuesReturn = this.setChildPicklistValues(component, budType, component.get("v.ActivityCategories"));
        
        component.set("v.ActivityCategoriesValues",childValuesReturn);
        
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
        
        if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1 && (isIn2025Category!=undefined && !isIn2025Category) ) {
            
            if (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType")) || component.get("v.isOpalActivity")) {
                component.set("v.activitySubTypeAvailable", true);
                //Commented below lines to fix defect DE117307 - Localisation changes
                //childValuesReturn.splice(0, 1);
                //component.set("v.activityMultiSubTypeVal", childValuesReturn);
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
    
    fetchActClassification: function (component) {
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelActivityType"), component.get("v.activitySelClassification"));
        if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1) {
            childValuesReturn.splice(0, 1);  
            component.set("v.isShowClassificationField", true);
            component.set("v.activityClassificationValues", childValuesReturn);
            component.set("v.selActivityClassification",childValuesReturn[0].value);
        }
        else
        {
            if(component.get("v.SelActivityType") != $A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
            component.set("v.isShowClassificationField", false);
            component.set("v.selActivityClassification", null);
                component.set("v.activityClassificationValues", childValuesReturn);
            }  
        }
    },  
    //fetching the product type values    
    fetchProdType: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = []
        var contrlFieldOptions =[]; 
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.ProductTypes"));
       }
         else{var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selBudgetType"), component.get("v.ProductTypes"));
        }
         component.set("v.ProductTypeDependent", childValuesReturn);
        this.updateProductType(component);
    },
    fetchIndustryTypes: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = []
        var contrlFieldOptions =[]; 
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.IndustryTypes"));
       }
         component.set("v.IndustryValues", childValuesReturn);
        this.updatefetchIndustryTypes(component);
    
    },
    fetchTargetAudience: function (component) {
        //getting the dependent product type picklist values by passing the controlling Target Audience value	  
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selBudgetType"), component.get("v.TargetAudience"));
        component.set("v.TargetAudienceValues", childValuesReturn);
    },
    //Rishabh
    //fetching the brand values    
    /*fetchBrandType: function (component) {
        //getting the dependent brand picklist values by passing the controlling Product Type value   	  
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selBudgetType"), component.get("v.BrandTypes"));
        component.set("v.BrandValues", childValuesReturn);
    },*/
    
    fetchMultiBrandType: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            
            
            	var contrlFieldOptions = component.get("v.selectedFocusArea");
              
                    childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.MultiBrandTypes"));
        }
          else{var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selBudgetType"), component.get("v.MultiBrandTypes"));
       }
        component.set("v.MultiBrandValues", childValuesReturn);
        this.updateBrandPickVals(component);
    },
fetchMultiInitiative: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
    
		childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.initiativePicklistValues"));            
            	
       }
        component.set("v.MultiInitiativeValues", childValuesReturn);
       this.updateInitiativePickVals(component);
    },
  fetchKPI: function (component){
       var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.kpiPicklistValues"));
	   if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1) {            	
           	var localizedval = this.localizeSubType(component, childValuesReturn);
           	if(localizedval.length > 0 ){
           		localizedval.splice(0, 1);
           }
           component.set("v.MultiKPIValues", localizedval);
        }
		else{
            var localizedval = this.localizeSubType(component, childValuesReturn);
            if(localizedval.length > 0 ){
            	localizedval.splice(0, 1);
            }
            component.set("v.MultiKPIValues", localizedval);
      	}
      	this.updateKPIPickVals(component);
       
    },
    
    fetchMultiTargetAudience: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            
		childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.audiencePicklistValues"));            
            	
       }
        component.set("v.MultiTargetAudienceValues", childValuesReturn);
       this.updateAudiencePickVals(component);
    },
 fetchMultiEcoPartnerType: function (component) {
       var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            
		childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.MultiEcoPartnerTypes"));            
            	
       }
        component.set("v.MultiEcoPartnerValues", childValuesReturn);
       this.updateEcoPartnerPickVals(component);
   },
    fetchRRPercent: function (component) {
        //getting the dependent brand picklist values by passing the controlling Product Type value   	  
        var childValuesReturn = this.setChildPicklistValues(component, component.get("v.selBudgetType"), component.get("v.RRPercent"));
        component.set("v.ReimbursementRateVal", childValuesReturn);
        this.applyIPAProposalReimbursementRate(
    component,
    this.isNotBlank(component.get("v.ActReimbursementRt"))
        ? component.get("v.ActReimbursementRt")
        : component.get("v.SelReimbursementRate"),
    false
); // Indu IPA Proposal
    },
    
   fetchPriority: function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var contrlField;
        var childValuesReturn = [];
        var string;
        var contrlFieldList;
        var childValues;
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
                    childValuesReturn = this.setChildPicklistValues(component, component.get("v.selectedFocusArea"), component.get("v.priority"));
           }
           component.set("v.priorityDependent", childValuesReturn);
            this.updatePriorityPickVals(component);
   },
    //rishabh
    /*calculateIntelContribution: function(component){
        var reqAmnt = component.get("v.BudgetLocal");
        var reimbursementRate = component.get("v.SelReimbursementRate");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
        var budType = component.get("v.selBudgetType");
        var RR = reimbursementRate.replace('%', '');
        var intelContri = "";
        var incentivePercent = component.get("v.incentive");
        if(component.get("v.hideCompetitiveQuest") || component.get("v.renderVRQuestion")){
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
        console.log('Activity Spending Limit'+reqAmnt);
        console.log('Intel Contribution'+intelContri);
        component.set("v.intelContribution",intelContri);
    },*/
    
    checkIsApproverActive: function(component){
        
        var mode = component.get("v.mode");
        var actStatus = component.get("v.CurrentStatus");
        var intelOwner = component.get("v.selectedApproverOptions");
        var selApp = "";
        if(intelOwner.length ==1){
            for(var i=0;i<intelOwner.length;i++){
                selApp=intelOwner[i];
            }
            if ((mode == 'edit' || mode == 'clone') && selApp != "") {
                if (component.get("v.externalper")) {
                    component.set("v.showIntelOwnerSpinner", true);
                    var actionCheckApprover = component.get("c.checkApproverActive");
                    actionCheckApprover.setParams({
                        accId: component.get("v.selectedPartner.Id"),
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
                if (component.get("v.accmgrper")) {
                    component.set("v.showIntelOwnerSpinner", true);
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
                        component.set("v.showIntelOwnerSpinner", false);
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
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
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

    fetchBudgetInfo : function(component){
        component.set("v.showSpinner",true);
        component.set("v.selAvailableBudget",'');
        var availableBudget = [];
        var action = component.get("c.fetchBudgetInfo");
        var ultimateAccId = component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c");
        var mode = component.get("v.mode"); 
        var currentBudgetIdVal = null;

        if(mode && mode.toLowerCase() === 'edit'){
            var oldPfrRef = component.get("v.oldPFR");
            var newPfrRef = component.get("v.newPFR");

            if (oldPfrRef && oldPfrRef.BudgetId ) {
                currentBudgetIdVal = oldPfrRef.BudgetId ;
            } 
            else if (newPfrRef && newPfrRef.BudgetId ) {
                currentBudgetIdVal = newPfrRef.BudgetId ;
            } 
            else if (component.get("v.selAvailableBudget")) {
                currentBudgetIdVal = component.get("v.selAvailableBudget");
            }
        }
            action.setParams({
                accountId: ultimateAccId,
                startDate: component.get("v.newPFR.Core_MDF_Start_Date__c"),
                endDate: component.get("v.newPFR.Core_MDF_End_Date__c"),
                budgetType: component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c"),
                isIPAAccBased: true,
                currentBudgetId: currentBudgetIdVal
            });
        
            action.setCallback(this, function (response) {
                component.set("v.showSpinner",false);
                var result = response.getReturnValue();
                var status = response.getState();
                if (status == "SUCCESS" && result != null && result.length!=0) {
                    if(result.length > 0){
                        for(var index = 0; index < result.length; index++){
                            //Generating date with forward slash instead of hyphen
                            var startDate = result[index].StartDate.replaceAll('-','/');
                            var endDate = result[index].EndDate.replaceAll('-','/');
                            availableBudget.push(
                                {
                                    key: result[index].Id,
                                    value: result[index].Core_MDF_budget_ref_nbr__c+' : ' +result[index].Title + ' : ' + result[index].Core_MDF_Budget_Type_Txt__c+' : '+startDate + ' - ' + endDate 
                                });
                        }
                    }
                    component.set("v.showBudgetErrorMsg",false);
                    component.set("v.budgetStr", availableBudget);
                    if(availableBudget!= null && availableBudget.length==1)
                    {
                        component.set("v.selAvailableBudget",availableBudget[0].key);
                        this.checkAvailAllocationAmt(component);
                    }
                    
                }else{
                    component.set("v.showBudgetErrorMsg",true);
                    component.set("v.budgetStr",'');
                    component.set("v.selAvailableBudget",'');
                }
                
                
            });
        
    
        $A.enqueueAction(action);
            
        },
    
    
    
    setActCatType : function(component,event, helper,budgetType){
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName"); 
        if(!$A.util.isEmpty(budgetType)){
            
            component.set("v.isBTSelAtCampaign",true);
            component.set("v.isCCFDCFRecType",true);
            
            
            var opalBTs =  budgetType;
            if (opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_CMP")) || opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) || opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_MDF")) || opalBTs.includes($A.get("$Label.c.Core_MDF_BudgetType_MDFPlus"))) {
                component.set("v.isOpalActivity",true);
                
                	component.set("v.CPLed",true);
                
                this.populateActCatType(component, event, helper);
                this.updateCountryPickVals(component);
                 this.updateBrandPickVals(component);
                this.updatefocusAreaPickVals(component);
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
      component.set("v.showBuSplitSection",false);
          component.set("v.showBUSPlitMultiselect",false);
        component.set("v.BudgetLocal",'');
         component.set("v.ActReimbursementRt",'');
        component.set("v.IPAIntelContri",'');
       if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") &&
   (component.get("v.isPropBasedCampaign") === true ||
    component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") === true ||
    component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") === true)){
    component.set("v.maximumIntelInvestment",'');
    component.set("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c",null);
    component.set("v.showErrorMsgForMaxIntelInvest",false);
    component.set("v.ErrorMsgForMaxIntelInvest","");
} //Indu IPA Proposal
  
        
    }
    
},
    resetHelper: function (component) {
        var budType = component.get("v.selBudgetType");
        component.set("v.Uploadfinished", false);
        component.set("v.PopupButtonValue", false);
        component.set("v.ELCPopupButtonValue", false);
        component.set("v.PopupType", null);
        
        component.set("v.renderPrintQuestion", false);
        component.set("v.renderGovtQuestion", false);
        component.set("v.renderTechExplorationQuestSection", false);
       
        component.set("v.recordApplicableForActivityRules", true);
        if(((budType == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || budType == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && component.get("v.SelCategory") == "Event") || component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            component.set("v.hideCompetitiveQuest", false);
        }
        
        component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",null);
        //Variable Reimbursement Rate changes
        component.set("v.renderVRQuestion", false);
        component.set("v.competetiveElement",null);
        component.set("v.incentivePercent",null);
        
        
        
    },
    /*fileUploadMandatoryAndEventFormVisibility : function(component){
        
        if (component.get("v.SelCategory") == (component, $A.get("$Label.c.Core_MDF_Activity_Category_Event"))) 
        {     
            component.set('v.isEventFormTemplateVisible',true);
        } else if(component.get("v.SelActivityType") == (component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")))
        {
            component.set('v.isIndustryPartnerFormTemplateVisible', true);
        }
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
                   ((component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")
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
    },*/
    SetAccMgrDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var hasPerSet = component.get("v.accmgrper");
        var mapVar = [];
        var frstatus = component.get("v.CurrentStatus");
        var actgry = component.get("v.SelCategory");
        
       
      
        if (hasPerSet == true) {
            var cpLed = true;
            var isCP = component.get("v.IsCP");
            if (isCP) {
                cpLed = false;
            }
            
            mapVar = {
                /*'frstatus': false,
                'name': false,
                'desc': false,
                'sdate': false,
                'edate': false,
                'budget': false,*/
                'availableBudget': false,
                /*'cmpgn': false,
                'acct': false,
                'country': false,
                'audience': false,
                'prodtype': false,
                'brand': false,
                'category': false,
                'type': false,
                'cpled': cpLed,
                'cp': false,
                'ocp': false,*/
                'attachement': false,
                'questions': false,
                /*'jointcontent': false,               
                'reimbursement' : false, //Reimbursement Rate
                'priority' : false,*/
                //Variable Reimbursement Rate changes
                'vrquestions': false,
                'eventFormat' : false,
                //[OEM Integration - CCF/DCF] - [Activity] - Two Additional Fields
                /*'Attr_Var_Pos': false,
                'Attr_Var_Neg': false,
                // BU split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                'buSplit' : false,
                'buSplitFld': false,
                'extSubmitter': false,
                memberOwner : false   */            
            };
            
          
            //Fields editable In-Progress Event Activity 
            /*if (
                frstatus == "In-Progress" &&
                actgry == "Event" &&
                this.budgetAmountThresholdCheck(component)
            ) {
                mapVar.attachement = false;
                mapVar.frstatus = false;
                mapVar.name = false;
                mapVar.desc = false;
                mapVar.sdate = false;
                mapVar.budget = false;
                mapVar.availableBudget = false;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.edate = false;
                mapVar.questions = true;
                mapVar.jointcontent = false;                
                mapVar.reimbursement = true; //Reimbursement Rate
                mapVar.priority = true; //Priority
                mapVar.vrquestions = true;
                mapVar.eventFormat = false;
                component.set("v.ApprovalException", true);
              
            } else if(!$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName) && !$A.get("$Label.c.Core_MDF_IPA_RecordType").includes(recordTypeDeveloperName) && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != true){
                if (frstatus == 'In-Progress') {
                    mapVar.edate = false;
                    mapVar.frstatus = false;
                    mapVar.name = false;
                    mapVar.desc = false;
                    mapVar.sdate = false;
                    mapVar.budget = false;
                    mapVar.cmpgn = true;
                    mapVar.acct = true;
                    mapVar.country = true;
                    mapVar.audience = true;
                    mapVar.prodtype = true;
                    mapVar.brand = true;
                    mapVar.category = true;
                    mapVar.type = true;
                    mapVar.cpled = true;
                    mapVar.cp = true;
                    mapVar.ocp = true;
                    mapVar.attachement = true;
                    mapVar.questions = true;
                    mapVar.jointcontent = false;
                    mapVar.reimbursement = true; //Reimbursement Rate
                    mapVar.priority = true; //Priority
                    mapVar.vrquestions = true;
                    mapVar.eventFormat = false;
                    
                    component.set("v.ApprovalException", true);
                    //OPAL Changes Start - To disable editing opal Activities in In-Progress Status
                    if(component.get("v.isOpalActivity")){
                        this.setOPALActDisableState(component,mapVar);
                        //Allow MemberOwner edit for InProgress Status
                        if(frstatus == "In-Progress"){
                            mapVar.memberOwner = false;
                            
                            component.set("v.isSaveDisable", false);
                        }
                    }
                    //OPAL Changes End
                }
                //Activity status is planned and program is opal CCF/DCF
                else if (frstatus == "Planned" && 
                         component.get("v.isOpalActivity")
                        ) {
                    mapVar.edate = false;
                    mapVar.frstatus = false;
                    mapVar.name = false;
                    mapVar.desc = false;
                    mapVar.sdate = false;
                    mapVar.country = false;
                    mapVar.audience = false;
                    mapVar.prodtype = false;
                    mapVar.brand = false;
                    mapVar.category = false;
                    mapVar.type = false;
                    mapVar.cpled = false;
                    mapVar.vrquestions = false;
                    mapVar.budget = false;
                    mapVar.cmpgn = true; 
                    mapVar.acct = true;   
                    mapVar.priority = false;//SP
                    mapVar.memberOwner =false;
                    mapVar.isAdditionalReviewReqd = true;
                    component.set("v.singleBudgetType", true);
                    component.set("v.isSPIFSecReadOnly", false);
                    component.set("v.disableRRPercent", false);
                    
                }
                
                //Activity status is planned and program is CCF/DCF/SPCF/CCFB 
                    else if (frstatus == 'Planned'){ 
                        mapVar.edate = false;
                        mapVar.frstatus = false;
                        mapVar.name = false;
                        mapVar.desc = false;
                        mapVar.sdate = false;
                        mapVar.budget = false;
                        mapVar.cmpgn = false;
                        mapVar.acct = false;
                        mapVar.country = false;
                        mapVar.audience = false;
                        mapVar.prodtype = false;
                        mapVar.brand = false;
                        mapVar.category = false;
                        mapVar.type = false;
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
                        component.set("v.ApprovalException", true);
                        component.set("v.isSPIFSecReadOnly", false);
                    }//Activity status is Closed and program is CCF/DCF/SPCF/CCFB
                        else if (frstatus == 'Closed') {
                            mapVar.frstatus = false;
                            mapVar.edate = true;
                            mapVar.name = true;
                            mapVar.desc = true;
                            mapVar.sdate = true;
                            mapVar.budget = false;
                            mapVar.cmpgn = true;
                            mapVar.acct = true;
                            mapVar.country = true;
                            mapVar.audience = true;
                            mapVar.prodtype = true;
                            mapVar.brand = true;
                            mapVar.category = true;
                            mapVar.type = true;
                            mapVar.cpled = true;
                            mapVar.cp = true;
                            mapVar.ocp = true;
                            mapVar.attachement = true;
                            mapVar.questions = true;
                            mapVar.jointcontent = true;
                            mapVar.reimbursement = true; //Reimbursement Rate
                            mapVar.priority = true; //Priority
                            mapVar.vrquestions = true;
                            mapVar.eventFormat = false;
                            mapVar.memberOwner =true;
                            component.set("v.ApprovalException", true);
                            //OPAL Changes Start- To disable editing opal Activities in In-Progress Status
                            if(component.get("v.isOpalActivity")){
                                this.setOPALActDisableState(component,mapVar);
                            }
                            //OPAL Changes End
                            
                        }
                //OPAL Changes Start - To disable editing opal Activity in Cancelled Status
                            else if (frstatus == "Cancelled" && component.get("v.isOpalActivity")) {
                                this.setOPALActDisableState(component,mapVar);
                            }
                
                //OPAL Changes - To make Account field as Read only and SPIF Sec as editable in Rev Required status for CCF/DCF programs
                                else if (frstatus == "Revision Required" && component.get("v.isOpalActivity")) {
                                    mapVar.acct = true;
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
                                                component.set("v.isSPIFSecReadOnly", false);
                                                component.set("v.isSaveDisable", false);
                                                component.set("v.isSaveandNewDisable", false);
                                               
                                            }else{
                                                
                                                this.setOPALActDisableState(component,mapVar);
                                            }
                                            
                                        }
                //OPAL changes end
            }*/
               if (!component.get("v.isUserCurrentIPAApprover") &&
                    $A.get("$Label.c.Core_MDF_IPA_RecordType").includes(recordTypeDeveloperName)) {
                    if (frstatus == "Revision Required" || frstatus == "Draft") {
                        /*mapVar.edate = false;
                        mapVar.desc = false;
                        mapVar.budget = false;*/
                        mapVar.availableBudget = false;
                        /*mapVar.frstatus = true;
                        mapVar.cmpgn = true;
                        mapVar.acct = true;
                        mapVar.sdate = false;
                        mapVar.name = false;
                        mapVar.category = false;
                        mapVar.type = false;
                        mapVar.attachement = false;*/
                        component.set("v.isSPIFSecReadOnly", false);
                        // BU split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                        /*mapVar.buSplit = false;
                        mapVar.buSplitFld= false;*/
                    }
                    else if (frstatus == "Planned") {
                       /* mapVar.edate = false;
                        mapVar.desc = false;
                        mapVar.budget = false;*/
                        mapVar.availableBudget = false;
                        /*mapVar.frstatus = true;
                        mapVar.cmpgn = true;
                        mapVar.acct = true;
                        mapVar.sdate = false;
                        mapVar.name = false;
                        mapVar.category = false;
                        mapVar.type = false;
                        mapVar.attachement = false;*/
                        component.set("v.isSPIFSecReadOnly", false);//made changes-Alekhya
                        // BU split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                        /*mapVar.buSplit = false;
                        mapVar.buSplitFld= false;*/
                        //New IPA approval process - making spif as not editable for acc manager
                        /*if(component.get("v.newPFR.Core_MDF_ActivityCategory__c")==$A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
                            component.set("v.isSPIFSecReadOnly", false);//allowing the SPIF section to be editable for Outcome-Based activities
                        }*/
                        
                    }
                        else if (frstatus == "Pending Approval" || frstatus == "Pending Review" || frstatus == "In-Progress" || frstatus == "Closed" || frstatus == "Declined" || frstatus == "Cancelled" || frstatus == "In-Progress Revision Required") {
                            if((frstatus == "In-Progress" || frstatus == "In-Progress Revision Required") /*&& component.get("v.newPFR.Core_MDF_ActivityCategory__c")==$A.get("$Label.c.Core_MDF_Outcome_Based_CatType")*/) {//made changes-Alekhya
                                component.set("v.isSPIFSecReadOnly", false);//SPIF to be editable
                            }
                            /*mapVar.edate = true;
                            mapVar.desc = true;
                            mapVar.budget = true;*/
                            mapVar.availableBudget = true;
                            /*mapVar.frstatus = true;
                            mapVar.cmpgn = true;
                            mapVar.acct = true;
                            mapVar.sdate = true;
                            mapVar.name = true;
                            mapVar.category = true;
                            mapVar.type = true;
                            mapVar.attachement = true;*/
                            // BU split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                            /*mapVar.buSplit = true;
                            mapVar.buSplitFld= true;
                            mapVar.country = true;*/
                        }
                    
                }
                   /* else if($A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)){
                        //Activity status is planned and program is Retail Marketing Funds
                        if (frstatus == 'In-Progress') {
                            mapVar.edate = false;
                            mapVar.desc = false;
                            mapVar.budget = false;
                            mapVar.country = true;
                            mapVar.frstatus = false;
                            mapVar.cmpgn = true;
                            mapVar.acct = true;
                            mapVar.sdate = false;
                            mapVar.name = false;
                            mapVar.audience = true;
                            mapVar.prodtype = true;
                            mapVar.brand = true;
                            mapVar.category = true;
                            mapVar.type = true;
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
                        } else if (frstatus == 'Planned') {
                            //Activity status is planned and program is Retail Marketing Funds
                            
                            mapVar.edate = false;
                            mapVar.desc = false;
                            mapVar.budget = false;
                            mapVar.country = false;
                            mapVar.frstatus = false;
                            mapVar.cmpgn = true;
                            mapVar.acct = true;
                            mapVar.sdate = false;
                            mapVar.name = false;
                            mapVar.audience = false;
                            mapVar.prodtype = false;
                            mapVar.brand = false;
                            mapVar.category = true;
                            mapVar.type = true;
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
                            var today = this.getTodayDateLocalTime();
                            // if activty start date passed todays date - diabling all fields on edit.
                            if(component.get("v.newPFR.Core_MDF_Start_Date__c") < today ) {
                                mapVar.edate = true;
                                mapVar.desc = false;
                                mapVar.budget = true;
                                mapVar.country = true;
                                mapVar.frstatus = false;
                                mapVar.cmpgn = false;
                                mapVar.acct = false;
                                mapVar.sdate = true;
                                mapVar.name = false;
                                mapVar.audience = true;
                                mapVar.prodtype = true;
                                mapVar.brand = true;
                                mapVar.category = true;
                                mapVar.type = true;
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
                                component.set("v.disableRSMMetricEditability", true);
                                //Commented below code - To enable edit access for RSM to the fields that don't trigger re-approval   
                                
                                if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")) {
                                    document.querySelector("#pivot").scrollIntoView();
                                } else {
                                    window.scrollTo(0, 0);
                                }
                            }
                        }
                            else if (frstatus == 'Closed') {
                                mapVar.frstatus = false;
                                mapVar.edate = true;
                                mapVar.name = true;
                                mapVar.desc = true;
                                mapVar.sdate = true;
                                mapVar.budget = false;
                                mapVar.cmpgn = true;
                                mapVar.acct = true;
                                mapVar.country = true;
                                mapVar.audience = true;
                                mapVar.prodtype = true;
                                mapVar.brand = true;
                                mapVar.category = true;
                                mapVar.type = true;
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
                                
                            }
                        //Lock the fields during (i)pending Approval status or  (ii) Pending Review with Geo other than Emea
                                else if (frstatus == "Pending Approval" || frstatus == "Pending Review") {
                                    
                                    mapVar.edate = true;
                                    mapVar.desc = true;
                                    mapVar.budget = true;
                                    mapVar.country = true;
                                    mapVar.cmpgn = true;
                                    mapVar.acct = true;
                                    mapVar.sdate = true;
                                    mapVar.name = true;
                                    mapVar.audience = true;
                                    mapVar.prodtype = true;
                                    mapVar.brand = true;
                                    mapVar.category = true;
                                    mapVar.type = true;
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
                                } else if(frstatus == "Revision Required") {
                                    component.set("v.isSPIFSecReadOnly", false);
                                }
                    }*/
            component.set("v.disabledMap", mapVar);
        }
        
    },
    //Rishabh
    /*setIPAApproverDisabledState: function (component) {
        
        var hasPerSet = component.get("v.ipaApproverPer");
        var frstatus = component.get("v.CurrentStatus");
        if((frstatus == "In-Progress" || frstatus == "Closed" || frstatus == "Cancelled" || frstatus == "Pending Approval" || frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")) && !component.get("v.isUserCurrentIPAApprover")) {
         component.set("v.isSPIFSecReadOnly", true);
        }
        //disable the field to not allow to cancel from UI
        var mapVar = [];
        mapVar = {
            edate: true,
            desc: true,
            budget: true,
            frstatus: true,
            cmpgn: true,
            availableBudget: true,
            acct: true,
            sdate: true,
            name: true,
            category: true,
            type: true,
            attachement: true,
            country: true,
            //Bu Split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
            buSplit: true,
            buSplitFld : true
        };
        if (hasPerSet) {
  
            if ((frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && (component.get("v.isUserCurrentIPAApprover")))) {
                
                mapVar.edate = false;//disabled the config records-CC-0212
                mapVar.desc = false;
                mapVar.budget = false;
                mapVar.frstatus = true;
                mapVar.cmpgn = true;
                mapVar.availableBudget = false,
                mapVar.acct = true;
                mapVar.sdate = false;
                mapVar.name = false;
                mapVar.country=false;
                mapVar.category = false;
                mapVar.type = false;
                mapVar.attachement = false;
                
                //Bu Split -[IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                mapVar.buSplit =false;
                mapVar.buSplitFld = false;
            }
            else if (( frstatus == "In-Progress" || frstatus == "Revision Required"
                     || frstatus == "Planned" || frstatus == "Closed" || frstatus == "Cancelled" ||
                     frstatus == "Pending Approval" || frstatus == "Declined" ||
                     (frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") &&
                     !component.get("v.isUserCurrentIPAApprover"))) && !component.get("v.ipaAcctMgr")) {
                mapVar.frstatus = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.availableBudget = true;
                mapVar.edate = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.budget = true;
                mapVar.category = true;
                mapVar.country = true;
                mapVar.type = true;
                mapVar.attachement = true
                //Bu Split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                mapVar.buSplit =true;
                mapVar.buSplitFld = true;
                var error = $A.get("$Label.c.Core_MDF_IPA_L1_Edit_Error");
                if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")) {
                    document.querySelector("#pivot").scrollIntoView();
                } else {
                    window.scrollTo(0, 0);
                }
            } 
            component.set("v.disabledMap", mapVar);
        } 
        this.handleSPIFDataVisibility(component);
    },*/
    handleSPIFDataVisibility: function (component){
        var hasAccBasPerSet = component.get("v.ipaAcctMgr");
        var frstatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
        var spifActTypes = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
		 var hasPerSet = component.get("v.ipaApproverPer");
        if((hasAccBasPerSet||hasPerSet) && frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview")&&
           component.get("v.isUserCurrentIPAApprover") &&
		   ((component.get("v.newPFR.Core_MDF_Approval_Step_Completed__c") == 0 && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)||
		   (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true && component.get("v.newPFR.Campaign.Core_MDF_Approval_Stage_nm__c") == 'L1 Approval'))){
            if(component.get ("v.isSPIFSecAvailable") && ((spifActTypes != null && 
                spifActTypes.includes(component.get("v.SelActivityType")) &&
                component.get("v.oldPFR.Core_MDF_Activity_Types__c") != component.get("v.SelActivityType"))||(this.checkSPIFTactics(component) && !component.get("v.oldPFR.Core_MDF_Tactics_nm__c").includes($A.get("$Label.c.Core_MDF_Spif_Tactics")) && component.get("v.selectedTacticsOptions").includes($A.get("$Label.c.Core_MDF_Spif_Tactics"))))){
                component.set("v.isSPIFSecReadOnly", false);
            }
            else if(component.get ("v.isSPIFSecAvailable") &&
                     ((component.get("v.oldPFR.Core_MDF_Activity_Types__c") == component.get("v.SelActivityType")) || component.get("v.oldPFR.Core_MDF_Tactics_nm__c") == component.get("v.selectedTacticsOptions"))){
                component.set("v.isSPIFSecReadOnly", true);
            }
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
    
    //Disable fields if its an auditor
    SetAuditorDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var permissionsetArray = [];
        var hasPerSet = component.get('v.auditorper');
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
                'cmpgn': false,
                'acct': false,
                'country': false,
                'audience': false,
                'prodtype': false,
                'brand': false,
                'category': false,
                'type': false,
                'cpled': false,
                'cp': false,
                'ocp': false,
                'attachement': false,
                'questions': false,
                'jointcontent': false,
                'priority' : false,
                'vrquestions': false,
                'eventFormat' : true,
                'memberOwner' : false,
                'extSubmitter' : false
            };
            if (frstatus == 'In-Progress') {
                mapVar.edate = false;
                mapVar.frstatus = false;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = false;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;                               
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.attachement = true;
                mapVar.questions = true;
                mapVar.jointcontent = false;
                mapVar.priority = true; //Priority
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                
                component.set("v.ApprovalException", true);
                //OPAL Changes Start - To disable editing opal Activities in In-Progress Status
                if(component.get("v.isOpalActivity")) {
                    mapVar.isAdditionalReviewReqd = true;
                    mapVar.mdfReimbAmnt = true;
                    mapVar.availableBudget = true;
                    mapVar.memberOwner= true;
                     mapVar.extSubmitter= true;
                    component.set("v.singleBudgetType", true);
                    component.set("v.disableRRPercent", true);
                    component.set("v.isSPIFSecReadOnly", true);
                }
                //OPAL Changes End
            } else if (frstatus == "Planned" || frstatus == "Revision Required" || frstatus == "Pending Approval" 
                       || frstatus == "Pending Review") {
                mapVar.attachement = true;
                mapVar.frstatus = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.edate = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.priority = true; //Priority
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                component.set("v.ApprovalException", true);
                component.set("v.isSaveDisable", true);
            }
                else if (frstatus == "Declined") {
                    mapVar.frstatus = true;
                    mapVar.name = true;
                    mapVar.desc = true;
                    mapVar.sdate = true;
                    mapVar.edate = true;
                    mapVar.cmpgn = true;
                    mapVar.acct = true;
                    mapVar.budget = true;
                    mapVar.category = true;
                    mapVar.type = true;
                    mapVar.attachement = true;
                    
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
        var frstatus = component.get("v.CurrentStatus");
        
        
        if (hasPerSet == true) {
            mapVar = {
               /* 'frstatus': false,
                'name': false,
                'desc': false,
                'sdate': false,
                'edate': false,
                'budget': false,*/
                'availableBudget': false,
                /*'cmpgn': false,
                'acct': false,
                'country': false,
                'audience': false,
                'prodtype': false,
                'brand': false,
                'category': false,
                'type': false,
                'cpled': false,
                'cp': false,
                'ocp': false,*/
                'attachement': false,
                'questions': false,
                /*'jointcontent': false,
                'priority' : false,
                'availableBudget' : false,*/
                'vrquestions': false,
                'eventFormat' : false,
                // [OEM Integration - CCF/DCF] - [Activity] - Two Additional Fields
               /* 'Attr_Var_Pos': false,
                'Attr_Var_Neg': false,
                //Bu split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                'buSplit': false,
                'buSplitFld': false,
                'intelOwner': true,
                memberOwner : false*/
            };
            
           
            if (
                $A.get("$Label.c.Core_MDF_IPA_RecordType").includes(recordTypeDeveloperName) ) {
                if (frstatus == "Revision Required" || frstatus == "Draft") {
                    /*mapVar.edate = false;
                    mapVar.desc = false;
                    mapVar.budget = false;
                    mapVar.frstatus = true;
                    mapVar.cmpgn = true;
                    mapVar.acct = true;
                    mapVar.sdate = false;*/
                    mapVar.availableBudget = false;
                    /*mapVar.name = false;
                    mapVar.category = false;
                    mapVar.type = false;
                    mapVar.attachement = false;*/
                    component.set("v.isSPIFSecReadOnly", false);
                    //Bu split  - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                    /*mapVar.buSplit = false;
                    mapVar.buSplitFld = false;*/
                }
                else if (frstatus == "Planned") {
                    /*mapVar.edate = false;
                    mapVar.desc = false;
                    mapVar.budget = false;
                    mapVar.frstatus = true;
                    mapVar.cmpgn = true;
                    mapVar.acct = true;
                    mapVar.sdate = false;*/
                    //mapVar.availableBudget = true;
                    /*mapVar.name = false;
                    mapVar.category = false;
                    mapVar.type = false;
                    mapVar.attachement = false;*/
                    component.set("v.isSPIFSecReadOnly", true);
                    //Bu split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                    /*mapVar.buSplit = false;
                    mapVar.buSplitFld = false;*/
                    //new IPA Acc based approval flow - setting spif as not editable for external user
                    var today = this.getTodayDateLocalTime();
                    var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
                    if(component.get("v.mode")=='edit'&& $A.get("$Label.c.Core_MDF_IPA_RecordType").includes(recordTypeDeveloperName) && startDate > today){
                            component.set("v.isSPIFSecReadOnly", false);
                        }
                    if(component.get("v.newPFR.Core_MDF_ActivityCategory__c")==$A.get("$Label.c.Core_MDF_Outcome_Based_CatType")){
                            component.set("v.isSPIFSecReadOnly", false);//allowing the SPIF section to be editable for Outcome-Based activities
                        }
                }
                    else if (frstatus == "Cancelled" || frstatus == "Pending Approval" || frstatus == "Pending Review" || frstatus == "Declined" || frstatus == "In-Progress" || frstatus == "Closed") {
                        /*mapVar.edate = true;
                        mapVar.desc = true;
                        mapVar.budget = true;
                        mapVar.frstatus = true;
                        mapVar.cmpgn = true;
                        mapVar.acct = true;*/
                        mapVar.availableBudget = true;
                        /*mapVar.sdate = true;
                        mapVar.name = true;
                        mapVar.category = true;
                        mapVar.type = true;
                        mapVar.attachement = true;*/
                       //Bu split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
                        /*mapVar.buSplit = true;
                        mapVar.buSplitFld = true;*/
                    }
            }
           /* else if (frstatus == 'In-Progress') {//not applicable for IPA
                /*mapVar.edate = true;
                mapVar.frstatus = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.availableBudget = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.category = true;
                mapVar.type = true;
                mapVar.cpled = true;
                mapVar.cp = true;
                mapVar.ocp = true;
                mapVar.attachement = true;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.priority = true; //Priority
                mapVar.vrquestions = true;
                mapVar.eventFormat = true;
                mapVar.intelOwner = true;
                component.set("v.ApprovalException", true);
                //OPAL Changes Start - To disable editing opal Activities in In-Progress Status
                if(component.get("v.isOpalActivity")) {
                    this.setOPALActDisableState(component,mapVar);
                    // Allow MemberOwner Field edit for InProgress Status
                    if(frstatus == "In-Progress"){
                        mapVar.memberOwner = false;
                        
                        component.set("v.isSaveDisable", false);
                    }
                }
                //OPAL Changes End
            }*/
             /*else if (
                frstatus == "Revision Required" && 
                ((
                    (((this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) &&
                      this.budgetAmountThresholdCheck(component)) || this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))) && ($A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType"))))
                ) 
                 ||
                 (
                     this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
                 )) 
            ) */ 
            //{
                //If Event or Content Creation Activity is Revision Required enable below fields for edititng
               // mapVar.acct = true;
                //this.setFileUploadForUser(component);
                
            //} 
            // /*else if (
                /*frstatus == "Planned"   && (this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner")) ||
                                            (this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) &&
                                             !this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_Promotion")) &&
                                             this.budgetAmountThresholdCheck(component))) && ($A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType")))
            )*/
            /*{
                //If Event Category edited in Planned status enable below fields as below based on program
                /*mapVar.attachement = true;
                mapVar.frstatus = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.budget = true;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.availableBudget = true;
                mapVar.category = true;
                mapVar.edate = false;
                mapVar.questions = true;
                mapVar.jointcontent = true;
                mapVar.priority = true; //Priority
                if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") ) {//
                    /*mapVar.vrquestions = false;
                    mapVar.prodtype = false;
                    mapVar.brand = false;
                    mapVar.sdate = false;
                    mapVar.type = true;
                    mapVar.eventFormat = false;
                    mapVar.cpled = true;
                    mapVar.cp = true;
                    mapVar.ocp = true;
                } else if (
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")
                ) {
                    /*mapVar.vrquestions = false;
                    mapVar.prodtype = true;
                    mapVar.brand = false;
                    mapVar.sdate = false;
                    mapVar.type = true;
                    mapVar.eventFormat = false;
                    mapVar.cpled = true;
                    mapVar.cp = true;
                    mapVar.ocp = true;
                } else if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")){
                    /*mapVar.vrquestions = true;
                    mapVar.prodtype = true;
                    mapVar.brand = true;
                    mapVar.sdate = true;
                    mapVar.type = true;
                    mapVar.eventFormat = false;
                    mapVar.cpled = true;
                    mapVar.cp = true;
                    mapVar.ocp = true;//
                } else {
                    mapVar.vrquestions = true;
                    mapVar.prodtype = true;
                    mapVar.brand = true;
                    mapVar.sdate = true;
                    mapVar.type = true;
                    mapVar.eventFormat = true;
                    mapVar.cpled = true;
                    mapVar.cp = true;
                    mapVar.ocp = true;
                }
                
                this.setFileUploadForUser(component);
            }*/
                /*else if( 
                    frstatus == "Planned"  &&
                    this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
                ){
                    this.setFileUploadForUser(component);
                }*/
            // OPAL Change start
            /*if (
                $A.get("$Label.c.Core_MDF_PFR_DCF").includes(recordTypeDeveloperName) || $A.get("$Label.c.Core_MDF_PFR_CCF").includes(recordTypeDeveloperName) ) {
                if (frstatus == "Revision Required" || frstatus == "Planned") {
                    component.set("v.isSPIFSecReadOnly", false);
                    mapVar.intelOwner = false;
                    //OPAL Changes - To make Account field as Read only and SPIF Sec as editable in Rev Required status for CCF/DCF programs
                    if(frstatus == "Revision Required" && component.get("v.isOpalActivity")) {
                        mapVar.acct = true;
                    }
                }
            }*/
            /*if( $A.get("$Label.c.Core_MDF_PFR_DCF").includes(recordTypeDeveloperName) || $A.get("$Label.c.Core_MDF_PFR_CCF").includes(recordTypeDeveloperName) ){
                if((frstatus == "Cancelled"  || frstatus == "Closed" || frstatus == "Pending Approval"|| frstatus == 'Pending Review') && component.get("v.isOpalActivity")){
                    this.setOPALActDisableState(component, mapVar);
                }
            }*/
            //disable external user to edit palnned opal activity		
            //OPAL Changes Start - To disable editing opal Activities in Closed/Cancelled/planned Status
            /*if((frstatus == "Cancelled" ||frstatus == "Planned" || frstatus == "Closed" || frstatus == "Pending Approval") && component.get("v.isOpalActivity")) {
                this.setOPALActDisableState(component,mapVar);
                //TWC702-365 :To allow edits for opal planned Activity 
                if(frstatus == "Planned"){
                    /*mapVar.edate = false;                   
                    mapVar.name = false;
                    mapVar.frstatus = false;
                    mapVar.desc = false;
                    mapVar.sdate = false;
                    mapVar.budget = false;                    
                    mapVar.country = false;
                    mapVar.audience = false;
                    mapVar.prodtype = false;
                    mapVar.brand = false;
                    mapVar.category = false;
                    mapVar.type = false;                  
                    mapVar.questions = false;                   
                    mapVar.reimbursement = false; //Reimbursement Rate                    
                    mapVar.priority = false; //Priority
                    mapVar.mdfReimbAmnt = false;
                    mapVar.cp = false;
                    mapVar.ocp = false;
                    mapVar.attachement = false;
                    mapVar.intelOwner = false;
                    mapVar.memberOwner = false;
                    component.set("v.isSPIFSecReadOnly", false);
                    if(component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")){
                        component.set("v.disableRRPercent", false);
                    }else{
                        component.set("v.disableRRPercent", true);
                    }
                    component.set("v.isSaveDisable", false);
                }	
            }*/
            // OPAL Change end
            component.set("v.disabledMap", mapVar);
        }
    },
    //OPAL Changes Start : Reusable helper method to disable editing all fields for OPAL Activities
    setOPALActDisableState: function(component,mapVar) {
        mapVar.edate = true;
        mapVar.frstatus = true;
        mapVar.name = true;
        mapVar.desc = true;
        mapVar.sdate = true;
        mapVar.budget = true;
        mapVar.cmpgn = true;
        mapVar.acct = true;
        mapVar.country = true;
        mapVar.audience = true;
        mapVar.prodtype = true;
        mapVar.brand = true;
        mapVar.category = true;
        mapVar.type = true;
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
        mapVar.isAdditionalReviewReqd = true;
        mapVar.mdfReimbAmnt = true;
        mapVar.availableBudget = true;
        mapVar.intelOwner = true;
        mapVar.extSubmitter = true;		
        //[OEM Integration - CCF/DCF] - [Activity] - Two Additional Fields
        mapVar.Attr_Var_Pos = true;
        mapVar.Attr_Var_Neg = true;
        mapVar.memberOwner =true;
        component.set("v.singleBudgetType", true);
        component.set("v.disableRRPercent", true);
        component.set("v.isSPIFSecReadOnly", true);
        component.set("v.isSaveDisable", true);
        component.set("v.isSaveandNewDisable", true);
    },
    //OPAL Changes End
    //rishabh
    /*setDualRoleEditability: function(component){
        var mapVar = [];
        var frstatus = component.get("v.CurrentStatus");
        var today = this.getTodayDateLocalTime();
        var actClosureType =  component.get("v.activityClosureType");
        var actStartDate = component.get("v.oldsdate");
        var cpLed = true;
        var isCP = component.get("v.IsCP");
        if (isCP) {
            cpLed = false;
        }        
        mapVar = {
            frstatus: false,
            name: false,
            desc: false,
            sdate: false,
            edate: false,
            budget: false,
            cmpgn: false,
            acct: false,
            country: false,
            audience: false,
            prodtype: false,
            brand: false,
            category: false,
            type: false,
            cpled: cpLed,
            cp: false,
            ocp: false,
            attachement: false,
            questions: false,
            jointcontent: false,
            reimbursement: false, //Reimbursement Rate
            priority: false,
            //Variable Reimbursement Rate changes
            vrquestions: false,
            eventFormat: false,
            // [OEM Integration - CCF/DCF] - [Activity] - Two Additional Fields
            Attr_Var_Pos: false,
            Attr_Var_Neg: false,
            // BU split - [IPA] BU Mapping % Splits - Enable BU Splits at Activity - Edit
            buSplit : false,
            buSplitFld: false
        };
        /*Activity status is planned and program is Retail Marketing Funds */ 
       /* if (frstatus == 'In-Progress') {
            mapVar.edate = false;
            mapVar.desc = false;
            mapVar.budget = false;
            mapVar.country = true;
            mapVar.frstatus = false;
            mapVar.cmpgn = true;
            mapVar.acct = true;
            mapVar.sdate = false;
            mapVar.name = false;
            mapVar.audience = true;
            mapVar.prodtype = true;
            mapVar.brand = true;
            mapVar.category = true;
            mapVar.type = true;
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
        } else if (frstatus == 'Planned') {
            
            mapVar.edate = false;
            mapVar.desc = false;
            mapVar.budget = false;
            mapVar.country = false;
            mapVar.frstatus = false;
            mapVar.cmpgn = true;
            mapVar.acct = true;
            mapVar.sdate = false;
            mapVar.name = false;
            mapVar.audience = false;
            mapVar.prodtype = false;
            mapVar.brand = false;
            mapVar.category = true;
            mapVar.type = true;
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
            
            if (actStartDate < today) {
                mapVar.edate = false;
                mapVar.frstatus = false;
                mapVar.desc = false;
                mapVar.budget = false;
                mapVar.country = false;
                mapVar.cmpgn = false;
                mapVar.acct = false;
                mapVar.sdate = false;
                mapVar.name = false;
                mapVar.audience = false;
                mapVar.prodtype = false;
                mapVar.brand = false;
                mapVar.category = false;
                mapVar.type = false;
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
            mapVar.cmpgn = false;
            mapVar.acct = false;
            mapVar.sdate = false;
            mapVar.name = false;
            mapVar.audience = false;
            mapVar.prodtype = false;
            mapVar.brand = false;
            mapVar.category = false;
            mapVar.type = false;
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
                mapVar.frstatus = false;
                mapVar.edate = true;
                mapVar.name = true;
                mapVar.desc = true;
                mapVar.sdate = true;
                mapVar.budget = false;
                mapVar.cmpgn = true;
                mapVar.acct = true;
                mapVar.country = true;
                mapVar.audience = true;
                mapVar.prodtype = true;
                mapVar.brand = true;
                mapVar.category = true;
                mapVar.type = true;
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
                    mapVar.acct = false;
                    mapVar.sdate = false;
                    mapVar.name = false;
                    mapVar.audience = false;
                    mapVar.prodtype = false;
                    mapVar.brand = false;
                    mapVar.category = false;
                    mapVar.type = false;
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
                    
                    mapVar.edate = true;
                    mapVar.desc = true;
                    mapVar.budget = true;
                    mapVar.country = true;
                    mapVar.cmpgn = true;
                    mapVar.acct = true;
                    mapVar.sdate = true;
                    mapVar.name = true;
                    mapVar.audience = true;
                    mapVar.prodtype = true;
                    mapVar.brand = true;
                    mapVar.category = true;
                    mapVar.type = true;
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
    },*/
    
    //Gayathri-IPA Dual Role editability(IPA Account Manager+Price reviewer in Pending review status and Price Reviewer Approval Stage for IPA Activities)
    setIPADualRoleEditability: function(component) {
        //Setting the fields non editable
    var mapVar = {
        Core_MDF_Fund_Request_Status__c: true,
        Title: true,
        Core_MDF_Activity_Description__c: true,
        Core_MDF_Start_Date__c: true,
        Core_MDF_End_Date__c: true,
        Core_MDF_Budget_Type_nm__c: true,
        availableBudget: true,
        CampaignId: true,
        ChannelPartnerId: true,
        Core_MDF_Focus_Area_nm__c: true,
        Core_MDF_Campaign_Reimbursement_Rate_txt__c: true,
        Core_MDF_Activity_Reimbursement_Amt_nbr__c: true,
        Core_MDF_Maximum_Intel_Investment_amt__c: true,
        Core_MDF_Campaign_Reimbursement_Amt__c: true,
        Core_MDF_Reimbursement_Rate_txt__c: true,
        Core_MDF_Budget_Currency_cd__c: true,
        Core_MDF_Budget_Amount_Local_amt__c: true,
        Core_MDF_Country_nm__c: true,
        Core_MDF_TargetAudience_nm__c: true,
        Core_MDF_Priority_nm__c: true,
        Core_MDF_ProductType__c: true,
        Core_MDF_Initiative_nm__c: true,
        Core_MDF_EcosystemPartner_nm__c: true,
        Core_MDF_Industry_Multi_nm__c: true,
        Core_MDF_Brand_nm__c: true,
        Core_MDF_ActivityCategory__c: true,
        Core_MDF_Activity_Types__c: true,
        Core_MDF_Opportunity_id__c: true,
        Core_MDF_Tactics_nm__c: true,
        Core_MDF_Activity_Classification_nm__c: true,
        Core_MDF_Attribution_Variance_Pos_txt__c: true,
        Core_MDF_Attribution_Variance_Neg_txt__c: true,
        attachement: true,
    };
    component.set("v.pfrFieldEditablity", mapVar);
   },
    //Set File Exception
    /*setFileUploadForUser : function(component){
        component.set("v.fileexceptionper", true);
    },*/
    setIPAactivityStatus: function (component) {
        if (this.isPlannedOrRevisionRequiredActivity(component) && this.isIPAActivitywithApplicableFieldModified(component)) {
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Revision_Required"));
             
        }
        // Ramapriya - set status to In-Progress Revision Required when edited in In-Progress status
        else if (component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") =='In-Progress' && this.isIPAActivitywithApplicableFieldModified(component)){
            if(component.get("v.ipaAcctMgr")) {
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_In_Progress_Revision_Required"));
            }
        }
    }, 
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
               this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_DCF")))) ) &&
            (component.get("v.accmgrper") && this.isOpalActivitywithApplicableFieldModified(component) || component.get("v.externalper") && this.isOpalRevReqActModified(component)) &&
            component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")		
           ){
            component.set("v.newPFR.Core_MDF_Is_Field_Modified__c",true); 
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
            if(component.get("v.isLoggedInUserLevelOneApprover")){
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1); 
                component.set("v.newPFR.Core_MDF_Approval_Stage__c",'L1 Approval');
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
            
            
          //If CMP
          if(component.get("v.isLoggedInUserLevelOneApprover") && (component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
                                                                   component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP"))){
              //If Additional review is changed, be in RR
              if(!(this.isOpalRevReqActModified(component)) && (component.get("v.newPFR.Core_MDF_Require_Additional_Review_ind__c") != component.get("v.oldPFR.Core_MDF_Require_Additional_Review_ind__c"))){
                  component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired"));
              }else if(this.isOpalRevReqActModified(component)){
                  component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm"));
              }
          }            
         
          //New: If Budget Type is changed from MDF/MDF+ to CMP, send for Customer Acceptance
          else if(component.get("v.isLoggedInUserLevelOneApprover") &&  this.isOpalRevReqActModified(component) &&
                  this.isNotBlank(component.get("v.newPFR.Core_MDF_Budget_Type_nm__c")) &&
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
        //Added SP CMP check for reapproval
        //New Budget Type field changes replaced txt field with new global picklist field
        if ((!(component.get("v.retailgeouserper")) || (component.get("v.retailgeouserper") && component.get("v.accmgrper") && component.get("v.oldsdate") >= today)) &&
            !(component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || 
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus") ||
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_CMP") ||
              component.get("v.newPFR.Core_MDF_Budget_Type_nm__c") == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) &&
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
            component.set("v.newPFR.Core_MDF_ATF_Approval_Reqd_ind__c", true);           
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
    
    /*setActwithNewValues: function (component) {
        component.set("v.newPFR.CampaignId",component.get("v.selectedLookUpRecord").Id);
        /*commenting out as part of Duplicate Field Removal Changes*/
        //component.set("v.newPFR.Core_MDF_Budget_Type_txt__c", component.get("v.selBudgetType"));
        /*component.set("v.newPFR.Core_MDF_Budget_Type_nm__c", component.get("v.selBudgetType"));
        component.set("v.newPFR.Core_MDF_Require_Additional_Review_ind__c",component.get("v.isAdditionalReviewReqd"));
        component.set("v.newPFR.Core_MDF_TargetAudience__c",component.get("v.SelTargetAudience"));
        component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
        component.set("v.newPFR.Core_MDF_Brand_nm__c",component.get("v.selectedBrandOptions"));
        component.set("v.newPFR.Core_MDF_ActivityCategory__c",component.get("v.SelCategory"));
        component.set("v.newPFR.Core_MDF_Activity_Types__c",component.get("v.SelActivityType"));
        component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
        component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
         
        component.set("v.newPFR.Core_MDF_MDFReimbursement_Amt__c", component.get("v.FlexiReimbursementAmt"));
        component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c",component.get("v.SelOtherChannelPartner"));
        component.set("v.newPFR.Core_MDF_Joint_Content_ind__c",component.get("v.JointContent"));
        component.set("v.newPFR.Core_MDF_Country_nm__c",component.get("v.SelMarketValue"));             
        component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selectedSubTypeOptions"));
        if(component.get("v.ActReimbursementRt") == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
           component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.SelReimbursementRate"));  
        }
        //Ayush - RR changes commented below code
        /*else{
            component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",component.get("v.ActReimbursementRt"));   
        }*/
    //},
    
    //If User modifies  Event Activity Type, Requested Amount above 50000  modifies fields --> Activity Type , 
    //Activity Category , Amount, Start Date or file updated 
    isActivityEventAboveAmountThresholdwithApplicableFieldModified : function(component){
        
        //Core_MDF_Field_Eligble_For_Approval_CcfDcfSpcfCcfb--> Core_MDF_Activity_Types__c,Core_MDF_ActivityCategory__c,RequestedAmount,Core_MDF_Start_Date__c
        var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Eligble_For_Approval_CcfDcfSpcfCcfb");
        var fileUpdated = component.get("v.ChgndAttach"); 
        
        if(this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) && !this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Promotion")) &&  this.budgetAmountThresholdCheck(component) &&
           (this.fieldEligibleForApprovalModified(component,editedFieldRequiresApproval.split(",")) || fileUpdated)){
            return true;
        }
        else{
            return false;
        }
    },
    //Check the Activity Category with value passed in label
    validateActivityType : function(component,activityTypeLabel){
        return (component.get("v.newPFR.Core_MDF_Activity_Types__c") == activityTypeLabel);
    },
    //Check the Activity Category with value passed in label
    validateActivityCategory : function(component,activityCategoryLabel){
        return (component.get("v.newPFR.Core_MDF_ActivityCategory__c") == activityCategoryLabel);
    },
    //Method to check if Activity Type is Event
    isEventActivity : function(component){
        
        ////Core_MDF_Activity_Category_Event - Event
        return (($A.get("$Label.c.Core_MDF_Event_Activity_Category").split(';')).includes(component.get("v.newPFR.Core_MDF_ActivityCategory__c")) )
        
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
            
            
           
               else if(component.get(oldFieldValue) != undefined && component.get(oldFieldValue) != null && 
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
        isIPAProposalBased: function(component) {
    var newPFR = component.get("v.newPFR") || {};
    var campaign =
        component.get("v.selectedLookUpRecord") || {};

    return (
        component.get("v.recordtypeDeveloperName") ===
            $A.get("$Label.c.Core_MDF_IPA_RecordType") &&
        (
            newPFR.Core_MDF_Proposal_Based_Ind__c === true ||
            campaign.Core_MDF_Proposal_Based_Ind__c === true ||
            component.get("v.isPropBasedCampaign") === true
        )
    );
},

    getEffectiveIPAIntelInvestment: function(component, originalAmount, pfr) {
        var sourcePFR = pfr || component.get("v.newPFR") || {};
        var maximumIntelInvestment =
            parseFloat(sourcePFR.Core_MDF_Maximum_Intel_Investment_amt__c);

        return this.isIPAProposalBased(component) &&
    !isNaN(maximumIntelInvestment) &&
    maximumIntelInvestment > 0
        ? maximumIntelInvestment
        : originalAmount;
    },
    applyIPAProposalCurrency: function(component, pfr) {
        var targetPFR = pfr || component.get("v.newPFR");
        var isNewActivity = component.get("v.mode") !== "edit" ||
            component.get("v.checkCloneAttribute") === true ||
            component.get("v.pfrCloneCheck") === true;
        var lockCurrency = this.isIPAProposalBased(component) && isNewActivity;

        component.set("v.lockIPAProposalCurrency", lockCurrency);
        if (lockCurrency && targetPFR) {
            component.set("v.budgetCurrency", "USD");
            targetPFR.Core_MDF_Budget_Currency_cd__c = "USD";
        }
    },

    checkIPAProposalEditWarning: function(component) {
        if (component.get("v.mode") !== "edit" ||
    $A.util.isEmpty(component.get("v.recordId")) ||
    component.get("v.pfrCloneCheck")) {
            component.set("v.showIPAProposalEditWarning", false);
            return;
        }

        var action = component.get("c.shouldShowIPAProposalEditWarning");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            component.set(
                "v.showIPAProposalEditWarning",
                response.getState() === "SUCCESS" &&
                    response.getReturnValue() === true
            );
        });
        $A.enqueueAction(action);
    },
    applyIPAProposalReimbursementRate: function(
    component,
    selectedRate,
    persistRate
) {
    if (!this.isIPAProposalBased(component)) {
        return false;
    }

    var normalizeRate = function(rate) {
        if ($A.util.isEmpty(rate)) {
            return "";
        }

        var normalizedRate = String(rate).trim();

        return normalizedRate.endsWith("%")
            ? normalizedRate
            : normalizedRate + "%";
    };

    var newPFR = component.get("v.newPFR") || {};
    var oldPFR = component.get("v.oldPFR") || {};
    var mode = component.get("v.mode");

    var isClone =
        mode === "clone" ||
        component.get("v.checkCloneAttribute") === true ||
        component.get("v.pfrCloneCheck") === true;

    var isExistingActivity =
        mode === "edit" && !isClone;

    var rate100 = normalizeRate(
        $A.get("$Label.c.Core_MDF_BudgetType_RRate100")
    );

    /*
     * Core_MDF_Reimbursement_Rate__c is only read here
     * as the effective existing value. It is never assigned.
     */
    var existingRate = normalizeRate(
        oldPFR.Core_MDF_Reimbursement_Rate__c ||
        oldPFR.Core_MDF_Reimbursement_Rate_txt__c ||
        newPFR.Core_MDF_Reimbursement_Rate__c ||
        newPFR.Core_MDF_Reimbursement_Rate_txt__c ||
        component.get("v.ActReimbursementRt") ||
        component.get("v.SelReimbursementRate")
    );

    var requestedRate = normalizeRate(selectedRate);

    var allowedRate =
        isExistingActivity && requestedRate !== rate100
            ? existingRate
            : rate100;

    if ($A.util.isEmpty(allowedRate)) {
        allowedRate = rate100;
    }

    var rateOptions = [];

    if (isExistingActivity &&
        this.isNotBlank(existingRate) &&
        existingRate !== rate100) {

        rateOptions.push({
            class: "optionClass",
            label: existingRate,
            value: existingRate
        });
    }

    rateOptions.push({
        class: "optionClass",
        label: rate100,
        value: rate100
    });

    component.set("v.ReimbursementRateVal", rateOptions);
    component.set(
        "v.reimbursementRatePickValues",
        rateOptions
    );

    /*
     * These are existing UI attributes, not database fields.
     */
    component.set("v.ActReimbursementRt", allowedRate);
    component.set("v.SelReimbursementRate", allowedRate);

    if (!isExistingActivity || persistRate === true) {
        component.set(
            "v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",
            allowedRate
        );
    }

    return true;
}, // Indu IPA Proposal
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
                var oldMaximumIntelInvestment = parseFloat(
            component.get("v.oldPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
        ) || 0;
        var newMaximumIntelInvestment = parseFloat(
            component.get("v.newPFR.Core_MDF_Maximum_Intel_Investment_amt__c")
        ) || 0;
        var maximumIntelInvestmentChanged =
            this.isIPAProposalBased(component) &&
            oldMaximumIntelInvestment !== newMaximumIntelInvestment;
                              
        if(this.isPlannedOrRevisionRequiredActivity(component)&&
           (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") 
                                 && component.get("v.isPropBasedCampaign") == false )){
                if (this.validateKPIValues(component)) {
                    this.setKPIValues(component);
                }
            }
        var metricsModified = component.get("v.newPFR.Core_MDF_Metrics_Modified_ind__c");
        if (((this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_IPA_RecordType"))&&(component.get("v.isPropBasedCampaign") == true)))             &&(this.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval.split(",")) || component.get("v.isSPIFSecModified") || maximumIntelInvestmentChanged)) 

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
        var plannedFieldMod= this.fieldEligibleForApprovalModified(component, editedPlannedActivityFieldRequiresApproval.split(";")); 
        var porFieldsMod = this.fieldEligibleForApprovalModified(component, editedPORFieldRequiresApproval.split(","));
        var pctFieldsMod = this.fieldEligibleForApprovalModified(component, editedPCTFieldRequiresApproval.split(","));
        //opal PCT POR edit changes
        var oldSpifEdited =  spifActivityTypes.split(";").includes(component.get("v.oldPFR.Core_MDF_Activity_Types__c"));
        var oldOtherEdited = otherActivityTypes.split(";").includes(component.get("v.oldPFR.Core_MDF_Activity_Types__c")); 
        var spifModified = component.get("v.newPFR.Core_MDF_SPIF_Modified_ind__c") ;
        var metricsModified = component.get("v.newPFR.Core_MDF_Metrics_Modified_ind__c"); 
        var spifEdited = spifActivityTypes.split(";").includes(component.get("v.newPFR.Core_MDF_Activity_Types__c"));
        var otherEdited = otherActivityTypes.split(";").includes(component.get("v.newPFR.Core_MDF_Activity_Types__c")); 
        
        if((pctFieldsMod && spifEdited) ||(!oldSpifEdited && spifEdited)){
            component.set("v.newPFR.Core_MDF_Price_reviewer_check_ind__c", true);
            isApprovalReqd = true;
        } 
        if((porFieldsMod && otherEdited)||(!oldOtherEdited && otherEdited)){
            component.set("v.newPFR.Core_MDF_Program_Office_Check_ind__c", true);
            isApprovalReqd = true;
        } 
        if(plannedFieldMod ||spifModified||metricsModified){
            isApprovalReqd = true;
        }
        
        if(isApprovalReqd){
            component.set("v.isIntEditPlanned",true);
            this.fetchExternalActSubmitters(component);
        }
        return isApprovalReqd;
        
        
    },  
    
    //Print Media, VR ,Upload File, Event Validation
    checkExtraQuestionAndUploadFile : function(component){
        
        var fileUploadMandatoryForUser = false;
        fileUploadMandatoryForUser = component.get("v.fileexceptionper");
        
        //Core_MDF_Activity_Cancelled_In_Progress  - Cancelled, In-Progress
        if (component.get("v.recordApplicableForActivityRules") && component.get("v.PopupType") == null &&
            (!$A.get("$Label.c.Core_MDF_Activity_Cancelled_In_Progress").includes(component.get("v.newPFR.Core_MDF_Fund_Request_Status__c"))))
        {
            this.checkVariableReimbursement(component);
            
        } else if (component.get("v.Uploadfinished") == false && component.get("v.checkfileuploadcondition") == true
                   && !fileUploadMandatoryForUser && (this.checkIfEventOrContentActivity(component))) {
            
            var error = $A.get("$Label.c.Core_MDF_Upload_File_Message");
            component.set("v.message", error);
            component.set("v.messageType", "error");
            
            if (component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")) {
                
                document.querySelector("#pivot").scrollIntoView();
                
            } else {
                
                window.scrollTo(0, 0);
                
            }
            
        } else if (component.get("v.Uploadfinished") == true || 
                 (component.get("v.PopupType") == "" || component.get("v.PopupType") == null || component.get("v.PopupType") == undefined) ||
            component.get("v.checkbudgetcondition") == false || (!component.get("v.recordApplicableForActivityRules") && component.get("v.checkbudgetcondition"))) {
            
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
    
    //Check if Activty is Content Creation or Event
    checkIfEventOrContentActivity : function(component){
        
       if($A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType")) && component.get("v.recordtypeDeveloperName") != 'Core_MDF_Intel_Partner_Alliance'  ){
        if((this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) && component.get("v.isEventFormTemplateVisible") )||
           this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation")) ||
           this.validateActivityType(component, $A.get("$Label.c.Core_MDF_Activity_Type_IndustryPartner"))) {
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
        component.set("v.disableCurrency",true);//making attribute as true for disabling currency field 
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var action = component.get("c.budgetAmountCalculatePFR");
        //pass oldcurrency param
        action.setParams({
            createdDateCloneFlag: component.get("v.createdDateClone"),
            pfr: newPFR
        });
        
        action.setCallback(this, function (response) {
            component.set("v.showSpinner",false);
            component.set("v.disableCurrency",false);//making attribute as false for enabling currency field 
            if (response.getState() == "SUCCESS") {
                var exchangeRateConvertedAmountWrap = response.getReturnValue();
                if (exchangeRateConvertedAmountWrap != null && exchangeRateConvertedAmountWrap.exchangeRate != null && exchangeRateConvertedAmountWrap.usdBudgetAmount != null) {
                    component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateConvertedAmountWrap.exchangeRate);
                    component.set("v.convertedUSDBudgetAmnt", exchangeRateConvertedAmountWrap.usdBudgetAmount); //OPAL Changes related Attribute
                    component.set("v.newPFR.RequestedAmount", exchangeRateConvertedAmountWrap.usdBudgetAmount);
                    component.set("v.BudgetException", false);
                    component.set("v.budgetCurrencyOld",component.get("v.newPFR.Core_MDF_Budget_Currency_cd__c"));
                    // OPAL Changes start to re-calculate new Reimbursement Rate Percentage on Budget Amount change
                    if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF")||component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) 	&& this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                        var budgetAmount = component.get("v.newPFR.RequestedAmount");
                        var flexAmount = component.get("v.FlexiReimbursementAmt");
                        this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
                    } 
                    if((recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c")) 
                       && $A.util.isEmpty(component.get("v.ActReimbursementRt")) && this.isNotBlank(component.get("v.newPFR.RequestedAmount"))
                       && !(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))){
                    var Contri ;
                    var budgetAmount = component.get("v.newPFR.RequestedAmount");            
                    var campReimbRt = component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c");
                   var Contri = budgetAmount* (parseFloat(campReimbRt)/100); 
				component.set("v.IPAIntelContri", Contri);
                } 
             else if (( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (this.isNotBlank(component.get("v.ActReimbursementRt")) && !component.get("v.externalper")) && this.isNotBlank(component.get("v.newPFR.RequestedAmount")) ){
	             var budgetAmount = component.get("v.newPFR.RequestedAmount"); 
	             var ActReimbRt = component.get("v.ActReimbursementRt");
            	 this.calcIntelContribution(component, budgetAmount, ActReimbRt);
	  
	  }
                 else if (( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && this.isNotBlank(component.get("v.SelReimbursementRate")) && this.isNotBlank(component.get("v.newPFR.RequestedAmount"))) {
                     var budgetAmount = component.get("v.newPFR.RequestedAmount"); 
                     var selReimbRt = component.get("v.SelReimbursementRate");
                     this.calcIntelContribution(component, budgetAmount, selReimbRt);
                 }
                    // OPAL Changes End
                    this.getActivityAmount(component);
                }else{
                    component.set("v.BudgetException", true); 
                }
                //component.set("v.showSpinner",false);
                component.set("v.isSaveDisable", false);
                if(!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && (component.get("v.ipaApproverPer") || (component.get("v.CurrentStatus") == 'Planned' && (component.get("v.accmgrper") || component.get("v.externalper")) ) )  )) {
                    component.set("v.isSaveandNewDisable", false);
                }
            } else if (response.getState() == "ERROR") {
                component.set("v.BudgetException", true);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    // Helper called on the load of the picklist component to store all the values 
    convertApitoLable: function (component, fieldlist) {
        var action = component.get("c.getLabelApiMapforPicklistfields");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        action.setParams({
            "objName": 'Core_MDF_Custom_Picklist__c',
            "pfrPiclistField": fieldlist
        });
        
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var optionMap = new Map();
                optionMap = response.getReturnValue();
                component.set("v.apitoLabelConvert", optionMap);
            }
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.apitoLabelConvert") != null){
                this.updatefocusAreaPickVals(component);   
            }
        });
        $A.enqueueAction(action);
    },
    // to calculate the buget amount
    budgetAmountcalculatefunction : function(component){
        var oldLocalAmount = component.get("v.oldPFR.Core_MDF_Budget_Amount_Local_amt__c");
        var oldCurrency = component.get("v.oldPFR.Core_MDF_Budget_Currency_cd__c");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        //Ayush - RR Changes
        var selReimRate;
        var reimRate;
        if(this.isNotBlank(component.get("v.SelReimbursementRate")) && component.get("v.SelReimbursementRate").endsWith("%")){
            selReimRate = component.get("v.SelReimbursementRate").replace("%", "");
        }
        //Ayush - RR Changes
        reimRate = this.isNotBlank(component.get("v.ActReimbursementRt")) && component.get("v.mode") != 'clone' && !component.get("v.externalper") ? component.get("v.ActReimbursementRt") : selReimRate;

        // If : - New and Clone and Local Amount is not call
        if(component.get("v.checkCloneAttribute") || $A.util.isEmpty(component.get("v.newPFR.Id")) || $A.util.isEmpty(component.get("v.recordId"))){
            // If : - Not USD and Not Currency empty
            if(component.get("v.budgetCurrency") != "USD"){
                this.calculateBudgetAmount(component, component.get("v.newPFR"));
            }else{ // Else : - USD Currency //not need to call Server Method // Local Amount is not null 
                component.set("v.disableCurrency",true);
                component.set("v.newPFR.RequestedAmount", component.get("v.BudgetLocal"));
                component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
                component.set("v.disableCurrency",false);
                // OPAL Changes start to re-calculate new Reimbursement Rate Percentage on Budget Amount change : 25th Jan Added as part of RR change
                if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) && this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                    var budgetAmount = component.get("v.newPFR.RequestedAmount");            
                    var flexAmount = component.get("v.FlexiReimbursementAmt");
                    this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
                } 
                // OPAL Changes End
                // IPA changes start
                
                if(( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c")) && $A.util.isEmpty(component.get("v.ActReimbursementRt")) && this.isNotBlank(component.get("v.newPFR.RequestedAmount"))
                    && !(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))){
                    var Contri ;
                    var budgetAmount = component.get("v.newPFR.RequestedAmount");            
                    var campReimbRt = component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c");
                   var Contri = budgetAmount* (parseFloat(campReimbRt)/100); 
				component.set("v.IPAIntelContri", Contri);
                } 
             else if (( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && this.isNotBlank(component.get("v.newPFR.RequestedAmount")) ){
	             var budgetAmount = component.get("v.newPFR.RequestedAmount"); 
	             var ActReimbRt = reimRate;
            	 this.calcIntelContribution(component, budgetAmount, ActReimbRt);
	  
	  }
                //IPA changes end  
                this.getActivityAmount(component);
            }
            // Else: - Edit scenario (change is present in either amount and currency)    
        }else if(this.isNotBlank(component.get("v.oldPFR")) && (parseFloat(oldLocalAmount) != parseFloat(component.get("v.BudgetLocal")) || (oldCurrency != component.get("v.budgetCurrency")))
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
             component.set("v.showSpinner",true);
            var budgetAmount1 = component.get("v.newPFR.RequestedAmount"); 
            component.set("v.showSpinner",false);
             if(( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) &&this.isNotBlank(component.get("v.newPFR.RequestedAmount"))&& this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c")) && $A.util.isEmpty(component.get("v.ActReimbursementRt"))){
                    var Contri ;           
                    var campReimbRt = component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c");
                   var Contri = this.getEffectiveIPAIntelInvestment(
                       component,
                       budgetAmount1 * (parseFloat(campReimbRt) / 100),
                       component.get("v.newPFR")
                   ); // Indu IPA Proposal
				component.set("v.IPAIntelContri", Contri);
                } 
             else if (( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && this.isNotBlank(component.get("v.ActReimbursementRt")) && this.isNotBlank(component.get("v.newPFR.RequestedAmount")) ){
	             var ActReimbRt = component.get("v.ActReimbursementRt");
            	 this.calcIntelContribution(component, budgetAmount1, ActReimbRt);
	  
	  }
            
            this.getActivityAmount(component);
        }
    },
    // Recalculate Budget Amount 
    recalculateBudgetAmount : function (component) {
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var USDAmountCalculation;
        var ipaPFRStatus = component.get("v.newPFR.Core_MDF_Fund_Request_Status__c");
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
            component.set("v.showSpinner",false);
            if (response.getState() == "SUCCESS") {
                
                if(result.Core_MDF_Exchange_Rate_ptc__c != null){ // If Return PFR has exchange rate and USD amuont
                    component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", result.Core_MDF_Exchange_Rate_ptc__c);
                    USDAmountCalculation = component.get("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c") * result.Core_MDF_Exchange_Rate_ptc__c;
                    component.set("v.newPFR.RequestedAmount",USDAmountCalculation);
                    var bud=component.get("v.newPFR.RequestedAmount");
                    // OPAL Changes start to re-calculate new Reimbursement Rate Percentage on Budget Amount change
                    if((component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || component.get("v.selBudgetType") == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")) && this.isNotBlank(component.get("v.FlexiReimbursementAmt")) && this.isNotBlank(component.get("v.BudgetLocal")) && component.get("v.isOpalActivity")){
                       
                        var budgetAmount = component.get("v.newPFR.RequestedAmount");
                         var budgetLocal = component.get("v.BudgetLocal");
                        //alert("Converted USD Amount in edit recalculate => "+budgetAmount);
                        var flexAmount = component.get("v.FlexiReimbursementAmt");
                        this.calculateReimbursementRatePercent(component,budgetAmount,flexAmount);
                    } 
                    var budgetAmt;
                 
                     if(component.get("v.budgetCurrency") == "USD"){
                        budgetAmt = component.get("v.BudgetLocal");
                    }
                    else{
                        budgetAmt = bud;        
                    }
                        if(( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
                           && (!$A.util.isEmpty(component.get("v.BudgetLocal"))
                               && !$A.util.isEmpty(component.get("v.newPFR.RequestedAmount"))
                               && this.isNotBlank(component.get("v.newPFR.RequestedAmount"))) 
                           && this.isNotBlank(component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c")) 
                      && $A.util.isEmpty(component.get("v.ActReimbursementRt"))
                      && !(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c"))){
                            var Contri ;
                               
                            var campReimbRt = component.get("v.selectedLookUpRecord.Core_MDF_ReimbursementRate_pct__c");
                            var Contri = budgetAmt* (parseFloat(campReimbRt)/100); 
                            component.set("v.IPAIntelContri", Contri);
                        } 
                        else if (( recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && this.isNotBlank(component.get("v.ActReimbursementRt")) && this.isNotBlank(component.get("v.BudgetLocal")) ){
                          
                            var ActReimbRt = component.get("v.ActReimbursementRt");
                            this.calcIntelContribution(component, budgetAmt, ActReimbRt);
                            
                        }
                    
                    
                    // OPAL Changes End
                    this.getActivityAmount(component);
                }else{ // Else throw error "System failed to get the Data"
                    exchangeRateError = true; 
                }
            }else{ // Else throw error "System failed to get the Data"
                exchangeRateError = true;
            }
            if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true && ( ipaPFRStatus == "In-Progress" || ipaPFRStatus == "Closed" || ipaPFRStatus == "Cancelled"|| ipaPFRStatus == "Pending Approval" ||(ipaPFRStatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && !component.get("v.isUserCurrentIPAApprover"))) && !component.get("v.ipaAcctMgr") && !component.get("v.externalper")){
               	component.set("v.isSaveDisable", true); 
           }
            else{
            component.set("v.isSaveDisable", false);  
           }
            if(!((component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") ) && ((component.get("v.CurrentStatus") == 'Planned' && (component.get("v.accmgrper") || component.get("v.externalper")) ) )  )) {
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
    
    /* [IPA] Disable save & New and Save buttons*/
    setSaveBtnVisibility: function (component) {
        
        var isSaveBtnDisable = true;
        var isSaveAndNewBtnDisable = true;
        var status = component.get("v.CurrentStatus");
        var accmgrper = component.get("v.accmgrper");
        var ipaApproverPer = component.get("v.ipaApproverPer");
        var externalper = component.get("v.externalper");
        var ipaL2Approver = component.get("v.ipaL2Approver");
        
        if (((status == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired") || status == $A.get("$Label.c.Core_MDF_CCP_Planned_Status") || status == $A.get("$Label.c.Core_MDF_PFR_Status_Draft_IPA")) && (accmgrper || externalper))) {
            isSaveBtnDisable = false;
            isSaveAndNewBtnDisable = false;
        }
        if ((status == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && ipaApproverPer && this.isCurrentUsrIsApprover(component))
           ) {
            isSaveBtnDisable = false;
        }
        //IPA Acc Based Approval flow-Added to enable save button for L1 while he's editing the activity when it's in his queue
         if ((status == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && accmgrper && this.isCurrentUsrIsApprover(component))
           ) {
            isSaveBtnDisable = false;
        }
        //Enabling Edit button to l2 Approver
         if ((status == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") && ipaL2Approver && 
            component.get("v.isUserCurrentIPAApprover")) 
           ) {
            isSaveBtnDisable = false;
        }
        if(status == "Planned" && (accmgrper || externalper)) {
            isSaveAndNewBtnDisable = true;
        }

        if((status == "In-Progress" || status == "Closed")  && (accmgrper || externalper)) {
            isSaveBtnDisable = false;
        }
        if(status == "In-Progress Revision Required"  && accmgrper) {
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
                 && ((component.get("v.ipaAcctMgr") 
                      && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)) 
                 || (component.get("v.ipaApproverPer") 
                     && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true))
                && ((component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'L1 Approval')
                    || component.get("v.newPFR.Campaign.Core_MDF_Approval_Stage_nm__c") == 'L1 Approval' )))) {
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
            if(ipaL2Approver){
                if(component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c")&&
                   (component.get("v.newPFR.Campaign.Core_MDF_Approval_Stage_nm__c") == 'L2 Regional Marketing'||
                    component.get("v.newPFR.Campaign.Core_MDF_Approval_Stage_nm__c") == 'L2 Regional Sales')){
                        usrIsApprover = true;
                    }
                
            else if(!component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c")&&
                     (component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'L2 Regional Marketing' ||
                      component.get("v.newPFR.Core_MDF_Approval_Stage__c") == 'L2 Regional Sales')){
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
            var vprogram = component.get("v.recordtypeName");
            var vctgry = component.get("v.SelCategory");
            var vtype = component.get("v.SelActivityType");
            var vsubType = component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") ? component.get("v.selectedSubTypeOptions") : component.get("v.selActivitySubType"); //changes for KPI Metrics
            var inputParams = {}; //kpiComponent.getInputParams();
            if (vprogram != null) {
                if(component.get("v.mode") =='edit' || component.get("v.mode") == 'clone'){
                inputParams.recordId = component.get("v.recordId");
                }
                else
                {
                  inputParams.recordId = null;  
                }
                inputParams.objName = "PartnerFundRequest";
                inputParams.activityCategory = vctgry;
                inputParams.activityType = vtype;
                inputParams.activitySubType = vsubType;
                inputParams.program = vprogram;
                inputParams.title = $A.get("$Label.c.Core_MDF_KPI_Metrics");
                inputParams.enableKPI = this.verifyKPIEditability(component);
                inputParams.isProposalBased = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");                    
                kpiComponent.loadKPIAttributes(inputParams);
            }
        }
    },
    /*Extra section to check whether to display Segment SPIF activity questions or not*/
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
        this.handleSPIFDataVisibility(component);
    },
    
    /* Geo Lead to edit Activities that have a start date in past 
    This method will be invoked only if the user has Geo Lead Permission*/
    checkGeoLeadsEditAccess: function(component) {
        var activityStatus = component.get("v.oldstatus");
        var actClosureType =  component.get("v.activityClosureType");
        var today = this.getTodayDateLocalTime();
        var actStartDate = component.get("v.oldsdate");
        var mapVar = [];
        mapVar = {
            frstatus: true,
            name: true,
            desc: true,
            sdate: true,
            edate: true,
            budget: true,
            availableBudget: true,
            cmpgn: true,
            acct: true,
            country: true,
            audience: true,
            prodtype: true,
            brand: true,
            category: true,
            type: true,
            cpled: true,
            cp: true,
            ocp: true,
            attachement: true,
            questions: true,
            jointcontent: true,
            reimbursement: true, 
            priority: true,
            vrquestions: true,
            eventFormat: true
        };
        component.set("v.isSaveandNewDisable",true);
        component.set("v.isSaveDisable",true);
        //Block Activity Edits from Mobile for Geo Lead 
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
        else{
            //Activity Start date is in Past and status is any one the of the below allowing Geo Lead to Edit Activities
            if((today > actStartDate) && (activityStatus == 'Planned' || activityStatus == 'Revision Required' || (activityStatus == 'Closed' && actClosureType == 'No Internal Approval'))){
                mapVar.edate = false;
                mapVar.frstatus = false;
                mapVar.desc = false;
                mapVar.budget = false;
                mapVar.availableBudget = false;
                mapVar.country = false;
                mapVar.cmpgn = false;
                mapVar.acct = false;
                mapVar.sdate = false;
                mapVar.name = false;
                mapVar.audience = false;
                mapVar.prodtype = false;
                mapVar.brand = false;
                mapVar.category = false;
                mapVar.type = false;
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
                this.getKPIAttributes(component);
                //[RMF] Geo Lead Edit - No Edit to SPIF Section
                //To disable Edit acccess for geo Lead
               
            }
        }
        component.set("v.disabledMap", mapVar);
    },
    
    //[RMF] [WW51] Approval flow when Geo Lead edit Activities
    callNextLevelApproval: function(component) {
        
        //DE115095 : WW19 | QA3 | When Geo Lead edits an Activity,
        //which is in Planned status and changes the start date to 1 day minus today,
        //then Activity re approval is getting triggered
        var startDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var today = this.getTodayDateLocalTime();
        
        var priceRevChk = component.get("v.newPFR.Core_MDF_Price_reviewer_check_ind__c");
        var reqAmount = component.get("v.newPFR.RequestedAmount");
        
        var spifActivityTypes = $A.get("$Label.c.Core_MDF_SPIF_Activity_Types");
        var newActivityType =  component.get("v.SelActivityType");
        if(component.get("v.retailgeouserper")){
            if(startDate >= today){
                if(reqAmount < 25000){
                    if(spifActivityTypes.includes(newActivityType)){ 
                        //DE121489 Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
                        component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                        
                        if(component.get("v.newPFR.Core_MDF_Region_nm__c") == 'EMEA' && !component.get("v.activityInApproval")){
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);  
                            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
                        }else{
                            if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Closed' && component.get("v.activityClosureType") == 'No Internal Approval'){
                                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
                            }else{
                                //Spif- to trigger to PCT
                                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);  
                                component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
                            } 
                            
                        }  
                    }else{
                        //DE121489 Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
                        component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_Status_Pending_Approval_Nm"));
                        
                        if(component.get("v.newPFR.Core_MDF_Region_nm__c") == 'EMEA' && !component.get("v.activityInApproval")){
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
                        }else{
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); //Non Spif- to trigger to Customer
                        }  
                    }
                }
                
                if((reqAmount >= 25000 && reqAmount < 250000) || (reqAmount >= 250000)){
                    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                    //DE121489 Production Issue: ATF flow still  failing to next step once ATF approver approves from L1 step
                    if(component.get("v.newPFR.Core_MDF_Region_nm__c") == 'EMEA' && !component.get("v.activityInApproval")){
                        component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);  
                        component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
                    }else{
                        if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Closed' && component.get("v.activityClosureType") == 'No Internal Approval'){
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
                        }else{
                            //to trigger to L1
                            component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 1);
                            component.set("v.newPFR.Core_MDF_Approval_Stage__c",'Geo Lead Approval');
                        }
                    }
                    //to trigger to L1 - for ATF approved activity, but rejected by later approvers
                    if(component.get("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c")){
                        component.set("v.newPFR.Core_MDF_After_the_Fact_Approved_ind__c", false);                               
                    }
                }   
            }else if(startDate < today){            
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
                component.set("v.newPFR.Core_MDF_ATF_Approval_Reqd_ind__c", true);
                component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0);
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
            if(isOpalBudgetTypeSelected){
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
                        /* OPAL change start  - [OPAL] CCF and DCF - Hide Activity Type like Other from External user */
                        var otherActivityTypes = '';
                        if(component.get('v.externalper')) {
                            otherActivityTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
                            if(component.get("v.checkCloneAttribute")) { 
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
						
                    }
                });
                $A.enqueueAction(action);    
            }
        } 
    },
    
    // OPAL Changes - on budget amount, mdf reimbursement amount
    calculateReimbursementRatePercent: function(component,budgetAmount,flexAmount){
        var flexRRMap=[];
        var flexRR =(parseFloat(flexAmount) / parseFloat(budgetAmount))*100 ;
        flexRR = (budgetAmount == 0 && flexAmount == 0)?0:flexRR;
        var newRRPercent = parseFloat(flexRR.toFixed(2));
        var flexRRDecValue = newRRPercent +"%";
        component.set("v.newRRValue",newRRPercent);
        if(newRRPercent > 100){
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
        } else if(flexRR <= 0){ // To calculate zero percent or not from formula
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
        }
    },
    
    // OPAL Changes - on MDF Budget type selection
    updateRRPickValues: function(component,defaultRRValue){
       
        var rrPickValues = [];
        var pickValues = [];
        //Akash-RR%
        if (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") && ((component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c") && component.get("v.mode") != 'clone') || (component.get("v.mode") == 'clone' && component.get('v.outcomeBasedOptInInd')))) {
            pickValues = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions100").split(';');
        }
        else{
            pickValues = $A.get("$Label.c.Core_MDF_BudgetType_RRateOptions").split(';');
        }
                                                          
        for(var i = 0; i < pickValues.length; i++){
            var optionValue = pickValues[i]+"%";
            rrPickValues.push({
                class: "optionClass",
                label: optionValue,
                value: optionValue
            });
        }
        //Ayush - RR changes
        if(this.isNotBlank(defaultRRValue) && !defaultRRValue.endsWith("%")){
            defaultRRValue+='%';
        }
        if(this.isNotBlank(defaultRRValue) && !pickValues.includes(defaultRRValue)){
            rrPickValues.push({
                class: "optionClass",
                label: defaultRRValue,
                value: defaultRRValue
            });
        }
        rrPickValues.sort((a, b) => parseFloat(a.value) - parseFloat(b.value));
        if((component.get("v.mode") != 'clone' || (component.get("v.mode") == 'clone' && this.isNotBlank(component.get("v.mode") == 'ActReimbursementRt' ))) && !component.get("v.externalper")){
            //Akash-RR%
            if (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") && ((component.get("v.mode") != 'clone' && component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c")) || (component.get("v.mode") == 'clone' && component.get("v.outcomeBasedOptInInd")))) {
               /* var rRPercentageVal = $A.get("$Label.c.Core_MDF_BudgetType_RRate100");
                component.set("v.SelReimbursementRate", rRPercentageVal);
                component.set("v.ActReimbursementRt", rRPercentageVal);
                component.set("v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",rRPercentageVal);
                component.set("v.isPropBasedOutcomeCampaign",true);*/
                if (this.isIPAProposalBased(component) &&
    component.get("v.mode") === "edit") {

    /*
     * Existing activity must retain its saved/effective RR.
     */
    component.set(
        "v.SelReimbursementRate",
        defaultRRValue
    );
    component.set(
        "v.isPropBasedOutcomeCampaign",
        true
    );
}
else {
    var rRPercentageVal =
        $A.get("$Label.c.Core_MDF_BudgetType_RRate100");

    component.set(
        "v.SelReimbursementRate",
        rRPercentageVal
    );
    component.set(
        "v.ActReimbursementRt",
        rRPercentageVal
    );
    component.set(
        "v.newPFR.Core_MDF_Reimbursement_Rate_txt__c",
        rRPercentageVal
    );
    component.set(
        "v.isPropBasedOutcomeCampaign",
        true
    );
} // Indu IPA Proposal
            }
            else{
                component.set("v.SelReimbursementRate", defaultRRValue);
            }
        }
        component.set("v.ReimbursementRateVal", rrPickValues);
        component.set("v.reimbursementRatePickValues",rrPickValues); 
        this.applyIPAProposalReimbursementRate(
    component,
    defaultRRValue,
    false
); // Indu IPA Proposal
    },
    getDefaultReimbursementRate: function(component){
        var selectedBudget = component.get("v.selBudgetType");    
        var budgetCampRecList = component.get("v.campaignBudgetList");
        var defaultRRate;
        if(budgetCampRecList != null && budgetCampRecList.length > 0){
            for(var i = 0; i < budgetCampRecList.length; i++){
                if( budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c == selectedBudget){
                    defaultRRate = budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c;
                    break;
                }
            }
        }
        
        return defaultRRate;
    },
    
    updateCountryPickVals: function(component){
        var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign"); 
        var countryOptions;
        var fieldName = 'Core_MDF_Country_nm__c';
        var allCountryString="";
        var countryOptionValues;
        var AllCountryOptions = component.get("v.CountryPicklistValues");        
        var countrylocalizedMap = component.get("v.apitoLabelConvert");
        var countryOptionsMap = [];
        var selectedCountryValues = [];
        var oldselectedCountryValues = "";

        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){
                if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Country_nm__c"))){
                    component.set("v.selectedCountryOptions",component.get("v.newPFR.Core_MDF_Country_nm__c").split(';'));
                }
                component.set("v.updateSelected",true);
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                countryOptions = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
        }
        
        //Inheriting the campaign values
        if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
            if((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Market__c")))) && $A.util.isEmpty(countryOptions)){
                countryOptions =  component.get("v.selectedLookUpRecord.Core_MDF_Market__c").split(";");
            }
        }

         //Storing PFR piclist selected values 
         if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Country_nm__c"))){
            selectedCountryValues = component.get("v.newPFR.Core_MDF_Country_nm__c").split(";");
        }

        //Handle Clone Proposal based scenario if a value on country is inactive and is present on activity, when user clicks on pencil icon for edit - the country should get blanked out 
        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
        //fetching Common values of campaign and dependent values 
            if(countryOptions != undefined && !$A.util.isEmpty(countryOptions)){
                if(countryOptions.length > 0){
                    if(AllCountryOptions != undefined && !$A.util.isEmpty(AllCountryOptions)){
                        for(var index=0; index < AllCountryOptions.length;index++){
                            if(countryOptions.includes(AllCountryOptions[index].value)){
                                if(allCountryString == undefined || allCountryString == null || allCountryString == ""){
                                    allCountryString = AllCountryOptions[index].value;
                                }      
                                else{
                                    allCountryString += ";" + AllCountryOptions[index].value;
                                }
                            }
                        }
                        if(allCountryString != undefined && !$A.util.isEmpty(allCountryString)){
                            countryOptionValues = allCountryString.split(";");
                        }  
                    }   
                }
            } 
        }
        if(countryOptions = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? countryOptionValues : countryOptions){
            //Iterating the  over localized values
                if (!$A.util.isEmpty(countryOptions) && countryOptions.length > 0 && countryOptions != undefined) {
                    countryOptions.sort(this.case_insensitive_sort);
                    for (var index = 0; index < countryOptions.length; index++) {
                        for (var key in countrylocalizedMap) {
                            if (key == countryOptions[index]) {
                                countryOptionsMap.push({
                                    "label": countrylocalizedMap[key],
                                    "value": key
                                });
                            }
                        }
                    }
                }
            }

            if(countryOptionsMap.length > 0){
                // On Clone the selected exsisting value is removing if the value is inactivated
                if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                    oldselectedCountryValues = this.picklistValuesRemoval(selectedCountryValues, countryOptionsMap);
                    if(oldselectedCountryValues != undefined && oldselectedCountryValues != null){
                        component.set("v.newPFR.Core_MDF_Country_nm__c", oldselectedCountryValues);
                    }
                }
                //setting all available options of the brand field
                component.set("v.AllCountryOptions", countryOptionsMap);
                var countrySelected = component.get("v.selectedCountryOptions");
                var countrySelectedOptions=[];
                //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
                if(!$A.util.isEmpty(countrySelected) && countrySelected != undefined){
                    if(component.get("v.newPFR.Core_MDF_Program__c") != component.get("v.recordtypeName") && component.get("v.recordtypeName") != ''){
                        //iterating the inherited initiative value over user selected values
                        for(var index=0;index<countryOptionsMap.length;index++){
                            for(var key in countrySelected)
                            {
                                //if any common selected values is present storing in array to set the selected attribute of the field
                                if(countryOptionsMap[index].value == countrySelected[key])
                                {
                                    countrySelectedOptions.push(countrySelected[key]); 
                                }
                            }
                        }  
                        if(countrySelectedOptions.length>0){
                            component.set("v.selectedCountryOptions", countrySelectedOptions);  
                        }

                        else
                        { 
                            //if there is no common selected values making the field to null to mandate the user to fill the field
                            component.set("v.newPFR.Core_MDF_Country_nm__c", null);
                        }

                    }
                }
            }else{
                if(component.get("v.newPFR.Core_MDF_Program__c") != component.get("v.recordtypeName") && component.get("v.recordtypeName") != ''){
                    component.set("v.AllCountryOptions", countryOptionsMap);
                    component.set("v.newPFR.Core_MDF_Country_nm__c", null);
                }
                if(component.get("v.mode") == 'edit'
                       && !$A.util.isEmpty(selectedCountryValues) && selectedCountryValues != undefined){
                            for(var index=0; index < selectedCountryValues.length; index++){
                                countryOptionsMap.push({
                                "label": countrylocalizedMap[selectedCountryValues[index]],
                                "value": selectedCountryValues[index]
                               });
                            }
                       component.set("v.AllCountryOptions", countryOptionsMap);
                    }
            }
    },
                
    updatefocusAreaPickVals: function(component, event){
        var focusArea=[];
        var fieldName = 'Core_MDF_Focus_Area_nm__c';
        var focusAreaMap = [];
        var focusAreaString="";
        var allFocusAreaString="";
        var focusAreaPickval;
        var focusArealocalizedMap = component.get("v.apitoLabelConvert");
        var allFocusAreaValues = component.get("v.focusAreaDependent");
        
        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                focusArea = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
            if(focusArea != undefined && !$A.util.isEmpty(focusArea) && !focusArea.includes(component.get('v.selectedFocusArea'))){
                component.set("v.selectedFocusArea","");
            }
        }
        
        if((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Focus_Area_nm__c")))) && $A.util.isEmpty(focusArea)){
            focusArea =  component.get("v.selectedLookUpRecord.Core_MDF_Focus_Area_nm__c").split(";");
        }
        //Handle Clone Proposal based scenario if a value on focus area is inactive and is present on activity, when user clicks on pencil icon for edit - the focus area should get blanked out 
        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
        //fetching Common values of campaign and dependent values 
            if(focusArea != undefined && !$A.util.isEmpty(focusArea)){
                if(focusArea.length > 0){
                    if(allFocusAreaValues !=null && allFocusAreaValues != '' && allFocusAreaValues != undefined){
                        for(var index=0; index < allFocusAreaValues.length;index++){
                            if(focusArea.includes(allFocusAreaValues[index].value)){
                                if(allFocusAreaString == undefined || allFocusAreaString == null || allFocusAreaString == ""){
                                    allFocusAreaString = allFocusAreaValues[index].value;
                                }      
                                else{
                                    allFocusAreaString += ";" + allFocusAreaValues[index].value;
                                }
                            }
                        }
                        if(allFocusAreaString != undefined && !$A.util.isEmpty(allFocusAreaString)){
                            focusAreaPickval = allFocusAreaString.split(";");
                        }  
                    }   
                }
            } 
        }  

        //If proposal based clone scenaio take values from dependency else take values coming form campaign
        if(focusArea = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? focusAreaPickval : focusArea){

            if(focusArea != undefined && !$A.util.isEmpty(focusArea)){
                if(focusArea.length > 0){
                    if(focusArea.length > 1){
                        focusAreaMap.push({
                            label: "--None--",
                            value: ""
                        });
                    }
                    for (var index = 0; index < focusArea.length;index++) {
                        for (var key in focusArealocalizedMap) {
                            if (key == focusArea[index]) {
                                focusAreaMap.push({
                                    "label": focusArealocalizedMap[key],
                                    "value": key
                                });
                                focusAreaString = key;
                            }
                        }
                    }
                }
                if(focusAreaMap.length == 1){
                    component.set("v.selectedFocusArea", focusAreaString);
                }
            }
            else{
                component.set("v.selectedFocusArea", "");
            }
        }
        if(focusArea == undefined || $A.util.isEmpty(focusArea)){
            component.set("v.selectedFocusArea", "");
        }
        component.set("v.AllFocusAreaOptions", focusAreaMap);
        
 },

   updatePriorityPickVals: function(component, event){
       var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
       var fieldName = 'Core_MDF_Priority_nm__c';
       var priorityPickvalues;
       var priorityPickListMap = [];
       var priorityFromDependent = [];
       var priorityPickListlocalizedMap = component.get("v.apitoLabelConvert");
       var priorityFromCampaign;
       var allPriorityString="";
       var priorityPickval;
       var checkselectedValue=false;
       var allPriorityOptions = component.get("v.priorityDependent");
       var allPriorityOptionsOpt = Object.values(allPriorityOptions);
       var selectedPriorityValues = [];
       var oldselectedPriorityValues = "";
      
       if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                priorityPickvalues = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
            if(priorityPickvalues != undefined && !$A.util.isEmpty(priorityPickvalues) && !priorityPickvalues.includes(component.get('v.SelPriority'))){
                component.set("v.SelPriority","");
            }
        }

     //Inheriting the campaign values
       if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
           if((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_IPA_Priority_nm__c")))) && $A.util.isEmpty(priorityPickvalues)){
               priorityPickvalues =  component.get("v.selectedLookUpRecord.Core_MDF_IPA_Priority_nm__c").split(";");
           }
       }
       if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
       //fetching Common values of campaign and dependent values    
            if(priorityPickvalues != undefined && !$A.util.isEmpty(priorityPickvalues)){
                if(priorityPickvalues.length >0){
                if(allPriorityOptions !=null && allPriorityOptions != '' && allPriorityOptions != undefined){
                    for(var index=0; index < allPriorityOptions.length; index++){
                        var allPriOptions = (allPriorityOptions != null && allPriorityOptions[index].value.includes('&amp;')) ? allPriorityOptions[index].value.replace("&amp;", "&") : allPriorityOptions;
                        if(Array.isArray(allPriOptions)){
                            if(priorityPickvalues.includes(allPriOptions[index].value)){
                            if(allPriorityString == undefined || allPriorityString == null || allPriorityString == ""){
                                    allPriorityString = allPriOptions[index].value;
                            }
                            else{
                                    allPriorityString += ";" + allPriOptions[index].value;
                                }
                            }
                        }
                        else{
                            if(priorityPickvalues.includes(allPriOptions)){
                                if(allPriorityString == undefined || allPriorityString == null || allPriorityString == ""){
                                    allPriorityString = allPriOptions;
                                }      
                                else{
                                    allPriorityString += ";" + allPriOptions;
                                }
                            }
                        }
                    }
                        if(allPriorityString != undefined && !$A.util.isEmpty(allPriorityString)){
                        priorityPickval = allPriorityString.split(";");
                    }
                }

                }
            }
        }

        if(priorityPickvalues = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? priorityPickval : priorityPickvalues){
       //Iterating the  over localized values
            if (!$A.util.isEmpty(priorityPickvalues) && priorityPickvalues.length > 0 && priorityPickvalues != undefined) {
                priorityPickvalues.sort(this.case_insensitive_sort);
                if(priorityPickvalues.length > 1){
                    priorityPickListMap.push({
                        label: "--None--",
                        value: ""
                    });
                }
                for (var index = 0; index < priorityPickvalues.length; index++) {
                    for (var key in priorityPickListlocalizedMap) {
                        if (key == priorityPickvalues[index]) {
                            priorityPickListMap.push({
                                "label": priorityPickListlocalizedMap[key],
                                "value": key
                            });
                            priorityFromCampaign = key;
                        }
                    }
                }
            }
        }
           if(priorityPickListMap.length > 0){
                //Storing PFR piclist selected values 
                if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Priority_nm__c"))){
                    selectedPriorityValues = component.get("v.newPFR.Core_MDF_Priority_nm__c").split(";");
                }
                    // On Clone the selected exsisting value is removing if the value is inactivated
                    if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                        oldselectedPriorityValues = this.picklistValuesRemoval(selectedPriorityValues, priorityPickListMap);
                        if(this.isNotBlank(oldselectedPriorityValues)){
                        	component.set("v.newPFR.Core_MDF_Priority_nm__c", oldselectedPriorityValues);
                        }
                    }
             //setting all available options of the priority field
             component.set("v.priorityValues", priorityPickListMap);  
               var prioritySelected = component.get("v.SelPriority");
               var prioritySelectedOptions ="";
               //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
               if(!$A.util.isEmpty(prioritySelected) && prioritySelected != null){
                   if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                       //iterating the inherited priority value over user selected values
                       for(var index in priorityPickListMap){
                           //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                           if(priorityPickListMap[index].value == prioritySelected)
                           {
                               prioritySelectedOptions =prioritySelected;
                           }  
                       }  
                       if(prioritySelectedOptions != null && prioritySelectedOptions != ""){
                           component.set("v.SelPriority", prioritySelectedOptions); 
                       }
                       else
                       {
                           //if there is no common selected values when user changes to one focus area to another- making the field to null to mandate the user to fill the field
                           if(component.get("v.oldPFR.Core_MDF_Priority_nm__c") != null){
                               component.set("v.newPFR.Core_MDF_Priority_nm__c", null);
                               component.set("v.SelPriority", null); 
                           }
                       }
                   }
                   else
                   {
                       if(component.get("v.oldPFR.Core_MDF_Priority_nm__c") != null){
                           component.set("v.newPFR.Core_MDF_Priority_nm__c", component.get("v.oldPFR.Core_MDF_Priority_nm__c"));
                           component.set("v.SelPriority", component.get("v.oldPFR.Core_MDF_Priority_nm__c")); 
                       }
                   }
               }
           }else{
               if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                   component.set("v.priorityValues", priorityPickListMap);
                   component.set("v.SelPriority", null);
               }
           }
           if(priorityPickListMap.length == 1){
               component.set("v.SelPriority", priorityFromCampaign);
           }
           
           
   },
    
   
   updatefetchIndustryTypes: function(component, event){ 
         var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
         var fieldName = 'Core_MDF_Industry_Multi_nm__c';
         var industryValues;
         var allindustryString="";
         var industryValue;
         var checkselectedValue=false;
         var allindustryValuesOptions = component.get("v.IndustryValues");
         var industryValuestMap = [];
         var allindustryValuesOpt=[];
         var industryValueslocalizedMap = component.get("v.apitoLabelConvert");
         var selectedIndustryValues = [];
         var oldselectedIndustryValues = "";
       
       if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){ 
            if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Industry_Multi_nm__c"))){
                component.set("v.selectedIndPartnerOption",component.get("v.newPFR.Core_MDF_Industry_Multi_nm__c").split(';'));
            }
            component.set("v.updateSelected",true);
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                industryValues = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
        }
       
     //Inheriting the campaign values
       if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
           if((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Industry_Nm__c")))) && $A.util.isEmpty(industryValues)){
               industryValues =  component.get("v.selectedLookUpRecord.Core_MDF_Industry_Nm__c").split(";");
           }
       }
        //Storing PFR piclist selected values 
        if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Industry_Multi_nm__c"))){
            selectedIndustryValues = component.get("v.newPFR.Core_MDF_Industry_Multi_nm__c").split(";");
        }
    
        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
       //fetching Common values of campaign and dependent values  
            if(industryValues != undefined && !$A.util.isEmpty(industryValues)){
                if(industryValues.length >0){
                if(allindustryValuesOptions !=null && allindustryValuesOptions != '' && allindustryValuesOptions != undefined){
                    for(var index=0; index < allindustryValuesOptions.length; index++){
                        if(allindustryValuesOptions[index].value.includes('&amp;')){
                                    var str = allindustryValuesOptions[index].value;
                                    allindustryValuesOptions[index].value = str.replace(/&amp;/g, '&');
                                }
                        if(industryValues.includes(allindustryValuesOptions[index].value)){
                            if(allindustryString == undefined || allindustryString == null || allindustryString == ""){ 
                                allindustryString = allindustryValuesOptions[index].value;
                            }
                            else{
                                allindustryString += ";" + allindustryValuesOptions[index].value;
                            }
                        }
                    }
                }
                }
                if(allindustryString != undefined && !$A.util.isEmpty(allindustryString)){
                    industryValue = allindustryString.split(";");
                }
            }
        }
        if(industryValues = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? industryValue : industryValues){
       //Iterating the  over localized values
            if (!$A.util.isEmpty(industryValues) && industryValues.length > 0 && industryValues != undefined) {
                industryValues.sort(this.case_insensitive_sort);
                for (var index = 0; index < industryValues.length; index++) {
                    for (var key in industryValueslocalizedMap) {
                        if (key == industryValues[index]) {
                            industryValuestMap.push({
                                "label": industryValueslocalizedMap[key],
                                "value": key
                            });
                        }
                    }
                }
            }
        }
           if(industryValuestMap.length>0){
                // On Clone the selected exsisting value is removing if the value is inactivated
                if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                    oldselectedIndustryValues = this.picklistValuesRemoval(selectedIndustryValues, industryValuestMap);
                    //TWC702-11623 - Ayush - changed helper.isBlank method to individual checks of undefined and null as for blank values also it was not going inside, hence blank error was not showing.
                    if(oldselectedIndustryValues != undefined && oldselectedIndustryValues != null){
                    	component.set("v.newPFR.Core_MDF_Industry_Multi_nm__c", oldselectedIndustryValues);
                    }
                }
               //setting all available options of the industry field
               component.set("v.activityMultiIndPartnerVal", industryValuestMap);
               var industrySelected = component.get("v.selectedIndPartnerOption");
               var industrySelectedOptions = [];
               //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
               if(!$A.util.isEmpty(industrySelected) && industrySelected != undefined){
                   if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                       //iterating the inherited industry value over user selected values
                       for(var index=0;index<industryValuestMap.length;index++){
                           for(var key in industrySelected)
                           {
                               //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                               if(industryValuestMap[index].value == industrySelected[key])
                               {
                                   industrySelectedOptions.push(industrySelected[key]);
                               }
                           }
                       }  
                       if(industrySelectedOptions.length>0){
                           component.set("v.selectedIndPartnerOption", industrySelectedOptions);
                
            }
                       else
                       {
                           //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                           component.set("v.newPFR.Core_MDF_Industry_Multi_nm__c", null); 
                       }
                   }
                  
               }
           }else{
               if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                   component.set("v.activityMultiIndPartnerVal", industryValuestMap);
                   component.set("v.newPFR.Core_MDF_Industry_Multi_nm__c", null);
               }
               if(component.get("v.mode") == 'edit'
                   && !$A.util.isEmpty(selectedIndustryValues) && selectedIndustryValues != undefined){
                    for(var index=0; index < selectedIndustryValues.length; index++){
                        industryValuestMap.push({
                         "label": industryValueslocalizedMap[selectedIndustryValues[index]],
                          "value": selectedIndustryValues[index]
                       });
                }
                component.set("v.activityMultiIndPartnerVal", industryValuestMap);
            }
        }
    },
    
    updateProductType: function(component, event){
        var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
        var fieldName = 'Core_MDF_ProductType__c';
        var productTypeValues;
        var allProductTypeString="";
        var productTypeVal;
        var productTypeOptionsOpt = [];
        var allProductTypeOptions = component.get("v.ProductTypeDependent");
        var productTypeValuesMap = [];
        var productTypeValuesMapCampaign;
        var checkselectedValue =false;
        var productTypeValueslocalizedMap = component.get("v.apitoLabelConvert");
        var allProductTypeOptionsOpt = Object.values(allProductTypeOptions);
        var selectedProductTypeValues = [];
        var oldselectedProductTypeValues = ""; 

        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                productTypeValues = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
            if(productTypeValues != undefined && !$A.util.isEmpty(productTypeValues) && !productTypeValues.includes(component.get('v.SelProductType'))){
                component.set("v.SelProductType","");
            }
        }
        
         //Inheriting the campaign values
        if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
            if((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Product_Type__c")))) && $A.util.isEmpty(productTypeValues)){
                productTypeValues =  component.get("v.selectedLookUpRecord.Core_MDF_Product_Type__c").split(";");
            }
        }
        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
        //fetching Common values of campaign and dependent values 
            if(productTypeValues != undefined && !$A.util.isEmpty(productTypeValues)){
                if(productTypeValues.length > 0){
                    if(allProductTypeOptions !=null && allProductTypeOptions != '' && allProductTypeOptions != undefined){
                        for(var index=0; index < allProductTypeOptions.length;index++){
                            var allProdTypeOptions = (allProductTypeOptions != null && allProductTypeOptions[index].value.includes('&amp;')) ? allProductTypeOptions[index].value.replace("&amp;", "&") : allProductTypeOptions;
                            if(Array.isArray(allProdTypeOptions)){
                            if(productTypeValues.includes(allProdTypeOptions[index].value)){
                                if(allProductTypeString == undefined || allProductTypeString == null || allProductTypeString == ""){
                                    allProductTypeString = allProdTypeOptions[index].value;
                                }      
                                else{
                                    allProductTypeString += ";" + allProdTypeOptions[index].value;
                                }
                            }
                            }
                            else{
                            if(productTypeValues.includes(allProdTypeOptions)){
                                if(allProductTypeString == undefined || allProductTypeString == null || allProductTypeString == ""){
                                    allProductTypeString = allProdTypeOptions;
                                }      
                                else{
                                    allProductTypeString += ";" + allProdTypeOptions;
                                }
                            }
                            }
                        }
                        if(allProductTypeString != undefined && !$A.util.isEmpty(allProductTypeString)){
                            productTypeVal = allProductTypeString.split(";");
                        }  
                    }   
                }
            } 
        }
        if(productTypeValues = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? productTypeVal : productTypeValues){
        //Iterating the  over localized values
            if (!$A.util.isEmpty(productTypeValues) && productTypeValues.length > 0 && productTypeValues != undefined) {
                productTypeValues.sort(this.case_insensitive_sort);
                if (!component.get("v.newPFR.Campaign.Core_MDF_CampOutcomeOpt_In_Ind__c")
                    && !component.get("v.selectedLookUpRecord.Core_MDF_CampOutcomeOpt_In_Ind__c")
                    && !component.get("v.clonedCampaignRecord.Core_MDF_CampOutcomeOpt_In_Ind__c")
                   && !component.get("v.updatedCampaignObj.Core_MDF_CampOutcomeOpt_In_Ind__c")) {
                    productTypeValuesMap.push({
                        label: "--None--",
                        value: ""
                    });
                }
                for (var index = 0; index < productTypeValues.length; index++) {
                   // for (var key in productTypeValueslocalizedMap) {
                    var key = productTypeValues[index];
                         if (component.get("v.isMultiPicklist") && (!key || key === "" || key === null || key === undefined)) {
                            continue;
                        }
                    if (!component.get("v.isMultiPicklist") && (!key || key === "")) {
                        continue;
                    }
                        if (productTypeValueslocalizedMap.hasOwnProperty(key)) {
                            productTypeValuesMap.push({
                                label: productTypeValueslocalizedMap[key],
                                value: key
                            });
                            productTypeValuesMapCampaign = key;
                        }
                    //}
                }
            }
        }


            if(productTypeValuesMap.length > 0){
                //Storing PFR piclist selected values 
                if(this.isNotBlank(component.get("v.newPFR.Core_MDF_ProductType__c"))){
                    selectedProductTypeValues = component.get("v.newPFR.Core_MDF_ProductType__c").split(";");
                }
               
                    // On Clone the selected exsisting value is removing if the value is inactivated
                    else if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                        oldselectedProductTypeValues = this.picklistValuesRemoval(selectedProductTypeValues, productTypeValuesMap);
                        if(this.isNotBlank(oldselectedProductTypeValues)){
                            component.set("v.newPFR.Core_MDF_ProductType__c", oldselectedProductTypeValues);
                            component.set("v.oldPFR.Core_MDF_ProductType__c", oldselectedProductTypeValues);
                        }
                    }
               
                //setting all available options of the product type field
                component.set("v.ProductTypeValues", productTypeValuesMap);
                var productSelected = component.get("v.SelProductType");
                var productSelectedOptions="";
                //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
                if(!$A.util.isEmpty(productSelected) && productSelected != undefined){
                    if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                        //iterating the inherited product type value over user selected values
                        for(var index in productTypeValuesMap){
                            for(var selectedValue in productSelected){
                                //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                                if(productTypeValuesMap[index].value == selectedValue.value)
                                {
                                    productSelectedOptions = productSelected;
                                }
                            }
                        }  
                        if(productSelectedOptions != null && productSelectedOptions != ""){
                            component.set("v.SelProductType", productSelectedOptions); 
                        }
                        else
                        {
                            //if there is no common selected values when user changes to one focus area to another- making the field to null to mandate the user to fill the field
                            component.set("v.newPFR.Core_MDF_ProductType__c", null);
                            component.set("v.SelProductType", null); 
                        }
                    }
                    else
                    {
                        if(component.get("v.oldPFR.Core_MDF_ProductType__c") != null && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != true && component.get("v.mode") == 'clone'){
                            component.set("v.newPFR.Core_MDF_ProductType__c", component.get("v.oldPFR.Core_MDF_ProductType__c")); 
                            component.set("v.SelProductType", component.get("v.oldPFR.Core_MDF_ProductType__c"));
                        }
                        else
                        {
                          component.set("v.ProductTypeValues", productTypeValuesMap);   
                        }
                    }
                }
                
            }else{
                if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                    component.set("v.ProductTypeValues", productTypeValuesMap);
                    component.set("v.SelProductType",null);
                }
            }
        if(productTypeValuesMap.length == 1){
            component.set("v.SelProductType", productTypeValuesMapCampaign);
        }
        
    },
    
    
    updateEcoPartnerPickVals: function(component, event){
        var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
        var fieldName = 'Core_MDF_EcosystemPartner_nm__c';
        var EcoPartner;
        var string="";
        var AllEcoSystemOptions = component.get("v.MultiEcoPartnerValues");
        var EcoPartnerValues;
        var checkselectedValue=false;
        var ecoSystemlocalizedMap = component.get("v.apitoLabelConvert");
        var ecoSystemOptionsMap = [];
        var AllEcoSystemOptionsOpt =[];
        var selectedEcosystemPartnerValues = [];
        var oldselectedEcosystemPartnerValues = "";
        
        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){ 
            if(this.isNotBlank(component.get("v.newPFR.Core_MDF_EcosystemPartner_nm__c"))){
                component.set("v.selectedEcosystemPartnerOptions",component.get("v.newPFR.Core_MDF_EcosystemPartner_nm__c").split(';'));
            }
            component.set("v.updateSelected",true);
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                EcoPartner = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
        }
        
        //Inheriting the campaign values
        if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){ 
            if((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Ecosystem_Partner_Nm__c")))) && $A.util.isEmpty(EcoPartner)){
                EcoPartner =  component.get("v.selectedLookUpRecord.Core_MDF_Ecosystem_Partner_Nm__c").split(";");
            }
        }

        //Storing PFR piclist selected values 
        if(this.isNotBlank(component.get("v.newPFR.Core_MDF_EcosystemPartner_nm__c"))){
            selectedEcosystemPartnerValues = component.get("v.newPFR.Core_MDF_EcosystemPartner_nm__c").split(";");
        }

        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
        //fetching Common values of campaign and dependent values 
            if(EcoPartner !=undefined && !$A.util.isEmpty(EcoPartner)){
                if(EcoPartner.length >0){
                    if(AllEcoSystemOptions !=undefined && !$A.util.isEmpty(AllEcoSystemOptions)){
                        for(var index=0; index < AllEcoSystemOptions.length; index++){
                            if(EcoPartner.includes(AllEcoSystemOptions[index].value)){
                                if(string == undefined || string == null || string == ""){
                                    string = AllEcoSystemOptions[index].value;
                                }
                                else{
                                    string += ";" + AllEcoSystemOptions[index].value;
                                }
                            }
                        }
                        if(string != undefined && !$A.util.isEmpty(string)){
                            EcoPartnerValues = string.split(";");
                        }
                    }
                }
            } 
        }
        if(EcoPartner = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? EcoPartnerValues : EcoPartner){
        //Iterating the  over localized values
            if (!$A.util.isEmpty(EcoPartner) && EcoPartner.length > 0 && EcoPartner != undefined) {
                EcoPartner.sort(this.case_insensitive_sort);
                for (var index = 0; index < EcoPartner.length; index++) {
                    for (var key in ecoSystemlocalizedMap) {
                        if (key == EcoPartner[index]) {
                            ecoSystemOptionsMap.push({
                                "label": ecoSystemlocalizedMap[key],
                                "value": key
                            });
                        }
                    } 
                }
            }
        }
            if(ecoSystemOptionsMap.length > 0){
                
                    // On Clone the selected exsisting value is removing if the value is inactivated
                    if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                        oldselectedEcosystemPartnerValues = this.picklistValuesRemoval(selectedEcosystemPartnerValues, ecoSystemOptionsMap);
                        if(this.isNotBlank(oldselectedEcosystemPartnerValues)){
                        	component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c", oldselectedEcosystemPartnerValues);
                        }
                    }
                
                //setting all available options of the Eco System field
                component.set("v.AllEcosystemPartner", ecoSystemOptionsMap); 
                var ecoSelected = component.get("v.selectedEcosystemPartnerOptions");
                var ecoSystemSelectedOptions=[];
                //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
                if(!$A.util.isEmpty(ecoSelected) && ecoSelected != undefined){
                    if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                        //iterating the inherited Eco System value over user selected values
                        for(var index=0;index<ecoSystemOptionsMap.length;index++){
                            for(var key in ecoSelected)
                            {
                                //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                                if(ecoSystemOptionsMap[index].value == ecoSelected[key])
                                {
                                    ecoSystemSelectedOptions.push(ecoSelected[key]); 
                                }
                            }
                        }  
                        if(ecoSystemSelectedOptions.length>0){
                            component.set("v.selectedEcosystemPartnerOptions", ecoSystemSelectedOptions); 
                        }
                        else
                        { //if there is no common selected values when user changes to one focus area to another- making the field to null to mandate the user to fill the field
                            component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c", null); 
                        }
                    }
                  
                   }
                }else{
                    if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                        component.set("v.AllEcosystemPartner", ecoSystemOptionsMap);
                        component.set("v.newPFR.Core_MDF_EcosystemPartner_nm__c", null);
                    }
                    if(component.get("v.mode") == 'edit'
                       && !$A.util.isEmpty(selectedEcosystemPartnerValues) && selectedEcosystemPartnerValues != undefined){
                            for(var index=0; index < selectedEcosystemPartnerValues.length; index++){
                              ecoSystemOptionsMap.push({
                                "label": ecoSystemlocalizedMap[selectedEcosystemPartnerValues[index]],
                                "value": selectedEcosystemPartnerValues[index]
                               });
                            }
                       component.set("v.AllEcosystemPartner", ecoSystemOptionsMap);
                    }
                }
    },
    

    updateBrandPickVals: function (component, event) {
        var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
        var fieldName = 'Core_MDF_Brand_nm__c';
        var brandOptions;
        var string="";
        var brandOptionsValues;
        var AllBrandOptions = component.get("v.MultiBrandValues");        
        var brandlocalizedMap = component.get("v.apitoLabelConvert");
        var brandOptionsMap = [];
        var AllBrandOptionsOpt=[];
        var checkselectedValue=false;
        var selectedBrandValues = [];
        var oldselectedBrandValues = "";
        
        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){
            if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Brand_nm__c"))){
                component.set("v.selectedBrandOptions",component.get("v.newPFR.Core_MDF_Brand_nm__c").split(';'));
            }
            component.set("v.updateSelected",true);
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                brandOptions = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
        }
        
       //Inheriting the campaign values
        if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
            if ((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Brand__c")))) && $A.util.isEmpty(brandOptions)) {
                brandOptions = component.get("v.selectedLookUpRecord.Core_MDF_Brand__c").split(";");
            }
        }

        //Storing PFR piclist selected values 
        if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Brand_nm__c"))){
            selectedBrandValues = component.get("v.newPFR.Core_MDF_Brand_nm__c").split(";");
        }
        
        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
        //fetching Common values of campaign and dependent values 
            if(brandOptions != undefined && !$A.util.isEmpty(brandOptions)){
                if(brandOptions.length >0){
                    if(AllBrandOptions != undefined && !$A.util.isEmpty(AllBrandOptions)){
                        for(var index=0; index < AllBrandOptions.length; index++){
                            if(brandOptions.includes(AllBrandOptions[index].value)){
                                if(string == undefined || string == null || string == ""){
                                    string = AllBrandOptions[index].value;
                                }
                                else{
                                    string += ";" + AllBrandOptions[index].value;
                                }
                            }
                        }
                        if(string != undefined && !$A.util.isEmpty(string)){
                            brandOptionsValues = string.split(";");
                        }
                    }
                }
            }
        }
        if(brandOptions = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? brandOptionsValues : brandOptions){
        //Iterating the  over localized values
            if (!$A.util.isEmpty(brandOptions) && brandOptions.length > 0 && brandOptions != undefined) {
                brandOptions.sort(this.case_insensitive_sort);
                for (var index = 0; index < brandOptions.length; index++) {
                    for (var key in brandlocalizedMap) {
                        if (key == brandOptions[index]) {
                            brandOptionsMap.push({
                                "label": brandlocalizedMap[key],
                                "value": key
                            });
                        }
                    }
                }
            }
        }
            if(brandOptionsMap.length > 0){
               
                    // On Clone the selected exsisting value is removing if the value is inactivated
                    if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                        oldselectedBrandValues = this.picklistValuesRemoval(selectedBrandValues, brandOptionsMap);
                        //TWC702-11623 - Ayush - changed helper.isBlank method to individual checks of undefined and null as for blank values also it was not going inside, hence blank error was not showing.
                        if(oldselectedBrandValues != undefined && oldselectedBrandValues != null){
                        	component.set("v.newPFR.Core_MDF_Brand_nm__c", oldselectedBrandValues);
                        }
                    }
               
                //setting all available options of the brand field
                component.set("v.AllBrandOptions", brandOptionsMap);
                var brandSelected = component.get("v.selectedBrandOptions");
                var brandSelectedOptions=[];
                //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
                if(!$A.util.isEmpty(brandSelected) && brandSelected != undefined){
                    if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                        //iterating the inherited initiative value over user selected values
                        for(var index=0;index<brandOptionsMap.length;index++){
                            for(var key in brandSelected)
                            {
                                //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                                if(brandOptionsMap[index].value == brandSelected[key])
                                {
                                    brandSelectedOptions.push(brandSelected[key]); 
                                }
                            }
                        }  
                        if(brandSelectedOptions.length>0){
                            component.set("v.selectedBrandOptions", brandSelectedOptions);  
            }
        
                        else
                        { 
                            //if there is no common selected values when user changes to one focus area to another- making the field to null to mandate the user to fill the field
                            component.set("v.newPFR.Core_MDF_Brand_nm__c", null);
                        }
                    }
                    
                }
            }else{
                if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                    component.set("v.AllBrandOptions", brandOptionsMap);
                    component.set("v.newPFR.Core_MDF_Brand_nm__c", null);
                }
                if(component.get("v.mode") == 'edit'
                       && !$A.util.isEmpty(selectedBrandValues) && selectedBrandValues != undefined){
                            for(var index=0; index < selectedBrandValues.length; index++){
                                brandOptionsMap.push({
                                "label": brandlocalizedMap[selectedBrandValues[index]],
                                "value": selectedBrandValues[index]
                               });
                            }
                       component.set("v.AllBrandOptions", brandOptionsMap);
                    }
            }
    },
    
    updateTacticsPickVals: function (component) {
        var tacticsOptions = component.get("v.activityTacticsOptions");
        var tacticslocalizeMap = component.get("v.apitoLabelConvert");
        var tacticsOptnsMap = [];
        if (!$A.util.isEmpty(tacticsOptions) && tacticsOptions.length > 0 && tacticsOptions != undefined){
            for (var index = 0; index < tacticsOptions.length;index++){
                for (var key in tacticslocalizeMap) {
                    if (key == tacticsOptions[index].value) {
                        tacticsOptnsMap.push({
                            "label": tacticslocalizeMap[key],
                            "value": key
                        });
                    }
                }
            }
        }
        if (!$A.util.isEmpty(tacticsOptnsMap) && tacticsOptnsMap.length > 0 && tacticsOptnsMap != undefined){
            component.set("v.activityTacticsOptions",tacticsOptnsMap);
        }
       
    },    
        
    updateAudiencePickVals: function (component, event) {
        var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
        var fieldName = 'Core_MDF_TargetAudience_nm__c';   
        var audienceOptions;
        var string="";
        var audienceOptionsValues;
        var AllAudienceOptions = component.get("v.MultiTargetAudienceValues");
        var audiencelocalizedMap = component.get("v.apitoLabelConvert");
        var audienceOptionsMap = [];
        var audienceOptionsString;
        var AllAudienceOptionsOpt=[];
        var checkselectedValue=false;
        var selectedAudienceValues = [];
        var oldselectedAudienceValues = "";
        
        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){
            if(this.isNotBlank(component.get("v.newPFR.Core_MDF_TargetAudience_nm__c"))){
                component.set("v.selectedTargetAudienceOptions",component.get("v.newPFR.Core_MDF_TargetAudience_nm__c").split(';'));
            }
            component.set("v.updateSelected",true);
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                audienceOptions = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
        }
        
       //Inheriting the campaign values
        if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
            if ((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Audience__c")))) && $A.util.isEmpty(audienceOptions)) {
                audienceOptions = component.get("v.selectedLookUpRecord.Core_MDF_Audience__c").split(";");
            }
        }

        //Storing PFR piclist selected values 
        if(this.isNotBlank(component.get("v.newPFR.Core_MDF_TargetAudience_nm__c"))){
            selectedAudienceValues = component.get("v.newPFR.Core_MDF_TargetAudience_nm__c").split(";");
        }

        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
       //fetching Common values of campaign and dependent values 
            if(audienceOptions != undefined && !$A.util.isEmpty(audienceOptions)){
                if(audienceOptions.length >0){
                    if(AllAudienceOptions != undefined && !$A.util.isEmpty(AllAudienceOptions)){
                        for(var index=0; index < AllAudienceOptions.length; index++){
                            if(audienceOptions.includes(AllAudienceOptions[index].value)){
                                if(string == undefined || string == null || string == ""){
                                    string = AllAudienceOptions[index].value;
                                }
                                else{
                                    string += ";" + AllAudienceOptions[index].value;
                                }
                            }
                            if(string != undefined && !$A.util.isEmpty(string)){
                                audienceOptionsValues = string.split(";");
                            }
                        }
                    }
                }
            }
        }
        if(audienceOptions = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? audienceOptionsValues : audienceOptions){
        //Iterating the target audience over localized values
            if (!$A.util.isEmpty(audienceOptions) && audienceOptions.length > 0 && audienceOptions != undefined) {
                audienceOptions.sort(this.case_insensitive_sort);
                for (var index = 0; index < audienceOptions.length;index++) {
                    for (var key in audiencelocalizedMap) {
                        if (key == audienceOptions[index]) {
                            audienceOptionsMap.push({
                                "label": audiencelocalizedMap[key],
                                "value": key
                            });
                        }
                    }
                }
            }
        }
            if(audienceOptionsMap.length > 0){
                
                    // On Clone the selected exsisting value is removing if the value is inactivated
                     if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                        oldselectedAudienceValues = this.picklistValuesRemoval(selectedAudienceValues, audienceOptionsMap);
                        //TWC702-11623 - Ayush - changed helper.isBlank method to individual checks of undefined and null as for blank values also it was not going inside, hence blank error was not showing.
                         if(oldselectedAudienceValues != undefined && oldselectedAudienceValues != null){
                             component.set("v.newPFR.Core_MDF_TargetAudience_nm__c", oldselectedAudienceValues);
                         }
                    }
                
                //setting all available options of the target audience field
                component.set("v.AllTargetAudienceOptions", audienceOptionsMap); 
                var targetSelected = component.get("v.selectedTargetAudienceOptions");
                var audienceSelectedOptions=[];
                //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
                if(!$A.util.isEmpty(targetSelected) && targetSelected != undefined) {
                    if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                        //iterating the inherited value over user selected values
                        for(var index=0;index<audienceOptionsMap.length;index++){
                            for(var key in targetSelected)
                            {
                                //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                                if(audienceOptionsMap[index].value == targetSelected[key])
                                {
                                    audienceSelectedOptions.push(targetSelected[key]); 
                                }
                            }
                        } 
                        if(audienceSelectedOptions.length >0){
                            component.set("v.selectedTargetAudienceOptions", audienceSelectedOptions); 
                        }
                        else
                        {
                            //if there is no common selected values when user changes to one focus area to another- making the field to null to mandate the user to fill the field
                            component.set("v.newPFR.Core_MDF_TargetAudience_nm__c", null); 
                        }
                    }
                    
                }
            }else{
                if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                    component.set("v.AllTargetAudienceOptions", audienceOptionsMap);
                    component.set("v.newPFR.Core_MDF_TargetAudience_nm__c", null);
                }
                if(component.get("v.mode") == 'edit'
                       && !$A.util.isEmpty(selectedAudienceValues) && selectedAudienceValues != undefined){
                            for(var index=0; index < selectedAudienceValues.length; index++){
                                audienceOptionsMap.push({
                                "label": audiencelocalizedMap[selectedAudienceValues[index]],
                                "value": selectedAudienceValues[index]
                               });
                            }
                       component.set("v.AllTargetAudienceOptions", audienceOptionsMap);
                    }
            }
    },
    
   
    updateInitiativePickVals: function (component, event) {
        var FieldValuesFromCampaign = component.get("v.FieldValuesFromCampaign");
        var fieldName = 'Core_MDF_Initiative_nm__c';
        var initiativeOptions;
        var string="";
        var initiativeOptionValue;
        var AllInitiativeOption = component.get("v.MultiInitiativeValues");
        var initiativelocalizedMap = component.get("v.apitoLabelConvert");
        var initiativeOptionsMap = [];
        var AllInitiativeOptionOpt=[];
        var checkselectedValue=false;
        var selectedInitiativeValues = [];
        var oldselectedInitiativeValues = "";
        
        if((component.get("v.recordtypeDeveloperName")== $A.get("$Label.c.Core_MDF_IPA_RecordType")  
            && (component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)) && component.get("v.mode") == 'clone'){ 
            if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Initiative_nm__c"))){
                component.set("v.selectedInitiativeOptions",component.get("v.newPFR.Core_MDF_Initiative_nm__c").split(';'));
            }
            component.set("v.updateSelected",true);
            if(JSON.stringify(component.get("v.updatedCampPicklistValues")) != '"{}"'){
                initiativeOptions = this.getUpdatedCampaignPicklistValues(component,event,component.get("v.updatedCampPicklistValues"),fieldName);
            }
        }
        
        //Inheriting the campaign values    
        if(FieldValuesFromCampaign != null && fieldName in FieldValuesFromCampaign){
            if ((!($A.util.isEmpty(component.get("v.selectedLookUpRecord.Core_MDF_Initiative_nm__c")))) && $A.util.isEmpty(initiativeOptions)) {
                initiativeOptions = component.get("v.selectedLookUpRecord.Core_MDF_Initiative_nm__c").split(";");
            }
        }
        //Storing PFR piclist selected values 
        if(this.isNotBlank(component.get("v.newPFR.Core_MDF_Initiative_nm__c"))){
            selectedInitiativeValues = component.get("v.newPFR.Core_MDF_Initiative_nm__c").split(";");
        }

        if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true){
        //fetching Common values of campaign and dependent values 
            if(initiativeOptions != undefined && !$A.util.isEmpty(initiativeOptions)){
                if(initiativeOptions.length > 0){
                    if(AllInitiativeOption != undefined && !$A.util.isEmpty(AllInitiativeOption)){
                        for(var index=0; index < AllInitiativeOption.length; index++){
                            if(AllInitiativeOption[index].value.includes('&amp;')){
                                var str = AllInitiativeOption[index].value;
                                AllInitiativeOption[index].value = str.replace(/&amp;/g, '&');
                            }
                            if(initiativeOptions.includes(AllInitiativeOption[index].value)){
                                if(string == undefined || string == null || string == ""){
                                    string = AllInitiativeOption[index].value;
                                }
                                else{
                                    string += ";" + AllInitiativeOption[index].value;
                                }
                            } 
                        }
                        if(string != undefined && !$A.util.isEmpty(string)){
                            initiativeOptionValue = string.split(";");
                        }
                    }
                }
            }
        }
        
        if(initiativeOptions = component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true ? initiativeOptionValue : initiativeOptions){
        //Iterating the initiative(initiativeOptionValue) over localized values(initiativelocalizedMap)
            if (!$A.util.isEmpty(initiativeOptions) && initiativeOptions !=undefined) {
                if(initiativeOptions.length > 0){
                    initiativeOptions.sort(this.case_insensitive_sort);
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
                }
            }
        }
            if(initiativeOptionsMap.length > 0){
           
                // On Clone the selected exsisting value is removing if the value is inactivated
                if(component.get("v.mode") == 'clone' && component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true) {
                    oldselectedInitiativeValues = this.picklistValuesRemoval(selectedInitiativeValues, initiativeOptionsMap);
                    //TWC702-11623 - Ayush - changed helper.isBlank method to individual checks of undefined and null as for blank values also it was not going inside, hence blank error was not showing.
                    if(oldselectedInitiativeValues != undefined && oldselectedInitiativeValues != null){
                    	component.set("v.newPFR.Core_MDF_Initiative_nm__c", oldselectedInitiativeValues);
                    }
                }
            
                //setting all available options of the initiatives field
                component.set("v.AllInitiativeOptions", initiativeOptionsMap); 
                var initiativeSelected = component.get("v.selectedInitiativeOptions");
                var initiativeSelectedOptions=[];
                //condition to check on edit and clone scenario -  Checking for selected value along with focus area selected value against saved values
                if(!$A.util.isEmpty(initiativeSelected) && initiativeSelected != undefined){
                    if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
                        //iterating the inherited initiative value over user selected values
                        for(var index=0;index<initiativeOptionsMap.length;index++){
                            for(var key in initiativeSelected)
                            {
                                //if any common selected values for more than one focus area is present storing in array to set the selected attribute of the field
                                if(initiativeOptionsMap[index].value == initiativeSelected[key])
                                {
                                    initiativeSelectedOptions.push(initiativeSelected[key]);    
                                }
                            }
                        }  
                        if(initiativeSelectedOptions.length>0){
                            component.set("v.selectedInitiativeOptions", initiativeSelectedOptions);   
                        } 
                        else
                        {
                            //if there is no common selected values when user change to one focus area to another- making the field to null to mandate the user to fill the field
                            component.set("v.newPFR.Core_MDF_Initiative_nm__c", null); 
                        }
                    }
                    
            }
    }else{
        if(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c") != component.get("v.selectedFocusArea") && component.get("v.selectedFocusArea") != ''){
            component.set("v.AllInitiativeOptions", initiativeOptionsMap);
            component.set("v.newPFR.Core_MDF_Initiative_nm__c", null);
        }
        if(component.get("v.mode") == 'edit'
           && !$A.util.isEmpty(selectedInitiativeValues) && selectedInitiativeValues != undefined){
            for(var index=0; index < selectedInitiativeValues.length; index++){
               initiativeOptionsMap.push({
                "label": initiativelocalizedMap[selectedInitiativeValues[index]],
                "value": selectedInitiativeValues[index]
            });
            }
            component.set("v.AllInitiativeOptions", initiativeOptionsMap);
        }
    }   
    },
    updateKPIPickVals: function (component, event) {
        var KPIlocalizedMap = component.get("v.apitoLabelConvert");
        var allKpiOptions = component.get("v.MultiKPIValues");
        var selectedKPIValues = [];
        var selectedValuesAfteRemoval = [];

        if (!($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Key_Marketing_Indicator_nm__c")))) {
            selectedKPIValues = component.get("v.newPFR.Core_MDF_Key_Marketing_Indicator_nm__c").split(";");
        }
        if(this.isNotBlank(selectedKPIValues) && this.isNotBlank(allKpiOptions)){
            // On Edit the selected exsisting value is added to the picklist if the value is inactivated
            if(component.get("v.mode") == 'edit') {
                console.log('categoryPicklistValuesMap--> ',allKpiOptions);
                allKpiOptions = this.picklistValuesAddition(KPIlocalizedMap, selectedKPIValues, allKpiOptions);
                if(!($A.util.isEmpty(allKpiOptions))){
                    allKpiOptions.sort(this.case_insensitive_sort);
                    component.set("v.MultiKPIValues", allKpiOptions);
                }
            }
            // On Clone the selected exsisting value is removing if the value is inactivated
            else if(component.get("v.mode") == 'clone') {
                selectedValuesAfteRemoval = this.picklistValuesRemoval(selectedKPIValues, allKpiOptions);
                component.set("v.selectedKPIOptions", selectedValuesAfteRemoval);
            }
        }
    },
        
    // Handle inactve values for dependent picklist values
    dependentPickValAdditionAndRemoval: function (component, fldname) {
        var filedslocalizedMap = component.get("v.apitoLabelConvert");
        var childPickField = {};
        var selectedControllingFieldValue = "";
        var selectedSinglePickChildValue = "";
        var selectedMultiPickChildValue = [];
        var selectedValuesAfteRemoval = "";
        var isParentPickValNotChanged = false;
        var isValidControllingPickVal = false;
        var latestCategoryValues = [];
        var childPickFieldArray;
        
        if(fldname == "Core_MDF_Activity_Types__c"){
            if (!($A.util.isEmpty(component.get("v.ActivityTypes")))) {
                childPickField = component.get("v.ActivityTypes"); // contains activity type from dependency
            }
            if (!($A.util.isEmpty(component.get("v.SelCategory")))) {
                selectedControllingFieldValue = component.get("v.SelCategory"); //contains selected activity category on pfr
                isParentPickValNotChanged = selectedControllingFieldValue == component.get("v.oldPFR.Core_MDF_ActivityCategory__c") ? true : false;
            }
            if (!($A.util.isEmpty(component.get("v.oldPFR.Core_MDF_Activity_Types__c")))) {
                selectedSinglePickChildValue = component.get("v.oldPFR.Core_MDF_Activity_Types__c");
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
        else if(fldname == "Core_MDF_ActivityCategory__c"){
            if (!($A.util.isEmpty(component.get("v.ActivityCategories")))) {
                childPickField = component.get("v.ActivityCategories"); // contains Activity Category from dependency
            }
            if (!($A.util.isEmpty(component.get("v.selectedFocusArea")))) {
                selectedControllingFieldValue = component.get("v.selectedFocusArea"); //contains selected Focus Area on pfr
                isParentPickValNotChanged = selectedControllingFieldValue == component.get("v.oldPFR.Core_MDF_Focus_Area_nm__c") ? true : false;
            }
            if (!($A.util.isEmpty(component.get("v.SelCategory")))) {
                selectedSinglePickChildValue = component.get("v.SelCategory");
            }  
            //Ayush - Changes for new Category/Type
            if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true"){
                component.set("v.oldStartDate",component.get("v.newPFR.Core_MDF_Start_Date__c"));
                childPickField = this.filterNewCategoryValues(component, childPickField, selectedControllingFieldValue);
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
                		else if(fldname == "Core_MDF_ActivityCategory__c"){
                        	component.set("v.ActivityCategories", childPickField);
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
                else if(fldname == "Core_MDF_ActivityCategory__c"){
                    component.set("v.SelCategory", selectedValuesAfteRemoval);
                }
                else if(fldname == "Core_MDF_Activity_SubType_nm__c"){
                    
                       var valuesafterRemoval = selectedValuesAfteRemoval.split(";");
                       component.set("v.selectedSubTypeOptions", valuesafterRemoval);
                    
                }
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
                        component.set("v.disableRRPercent",true);
                        component.set("v.isBudgetTypeFlexible",false);
                        component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        
                        
                        
                    }else  if(selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")){
                        
                        component.set("v.disableRRPercent",false);
                        component.set("v.isBudgetTypeFlexible",true);
                        component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        
                        this.updateRRPickValues(component, budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                        
                    }
                    
                }else{
                    // component.set("v.selAvailableBudget",null);
                }
            }
        }
        /*new change 
        var ParPickField = [];
        var flexRR =component.get("v.SelReimbursementRate");
        flexRR = (flexRR>100)?100:flexRR;
        ParPickField.push({
            class: "optionClass",
            label: flexRR,
            value: flexRR
        });
        component.set("v.ReimbursementRateVal", ParPickField);
        component.set("v.reimbursementRatePickValues",ParPickField); 
        component.set("v.SelReimbursementRate", flexRR);
        /*new change */
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
        component.set("v.selAvailableBudget",'');
        
        var isBudgetAvailable = false;
        for(var i = 0; i < budgetCampRecList.length; i++){
            
            if(budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c == selectedBudget){
                availableBudget.push(
                    {
                        key: budgetCampRecList[i].Core_MDF_Budget_Name_Id__c,
                        value: budgetCampRecList[i].Core_MDF_Budget_Name_Id__r.Title + ' \n ' + budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c+' - '+budgetCampRecList[i].Core_MDF_Start_Date_Dt__c + ' - ' + budgetCampRecList[i].Core_MDF_End_Date_Dt__c
                    });     
            }            
            
            
            if(selectedBudget != null && selectedBudget != undefined && selectedBudget != ""){
                
                if((selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_CMP") || selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_SP_CMP")) && selectedBudget == budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c){
                    isBudgetAvailable = true;
                    component.set("v.disableRRPercent",true);
                    component.set("v.isBudgetTypeFlexible",false);
                    component.set("v.SelReimbursementRate", budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                    component.set("v.ReimbursementRateVal", component.get("v.reimbursementRatePickValues"));
                    component.set("v.FlexiReimbursementAmt",'');
                    
                }else if ((selectedBudget == $A.get("$Label.c.Core_MDF_BudgetType_MDF") )&& selectedBudget == budgetCampRecList[i].Core_MDF_Budget_Type_Nm__c) {
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
                        component.set("v.disableRRPercent",false);
                    }
                    if(component.get("v.priceReviewersPer")) {
                        component.set("v.disableRRPercent",true);
                    }
                    component.set("v.isBudgetTypeFlexible",true);
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
                        component.set("v.disableRRPercent",false);
                    } 
                    if(component.get("v.priceReviewersPer")) {
                        component.set("v.disableRRPercent",true);
                    }
                    component.set("v.isBudgetTypeFlexible",true);
                    if(!component.get("v.doInitCheck")) {
                        this.updateRRPickValues(component, budgetCampRecList[i].Core_MDF_Reimbursement_Rate_Pct__c);
                    }
                    
                }
            }
            
        }
        
        if(selectedBudget != null && selectedBudget != undefined && selectedBudget != ""&&component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_IPA_RecordType")){
            /* In Planned status, if user changes start/end date & available budgets are not present then showing error & activity reverting back to previous state*/
            if(availableBudget.length == 0 && component.get("v.oldstatus") == "Planned" && (component.get("v.oldPFR.Core_MDF_Start_Date__c") != component.get("v.newPFR.Core_MDF_Start_Date__c") || component.get("v.oldPFR.Core_MDF_End_Date__c") != component.get("v.newPFR.Core_MDF_End_Date__c"))) {
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
        if(availableBudget.length == 1){
            component.set("v.selAvailableBudget",availableBudget[0].key);
            component.set("v.newPFR.Core_MDF_Budget_id__c",availableBudget[0].key);
            component.set("v.newPFR.BudgetId",availableBudget[0].key);
            //component.set("v.FlexiReimbursementAmt",'');
            component.set("v.isBTSelAtCampaign",true);
            component.set("v.isCCFDCFRecType",true);
        }   
        if(availableBudget.length == 0){
            if(component.get("v.isOpalActivity")) {
                component.set("v.isBTSelAtCampaign",true);
                component.set("v.isCCFDCFRecType",true);    
            }
        }
        if(availableBudget.length>1){
            this.displaySuccessErrorMsg('Activity cannot span multiple budgets','Error','error');
            component.set("v.selBudgetType",null);
            component.set("v.singleBudgetType", false);
            component.set("v.selAvailableBudget", null);
        }
        
        //component.set("v.budgetStr", availableBudget);
        if(availableBudget.length != 0){
            component.set("v.budgetAvailableFlag",true);
        }
    },
    //This Method will return true if opal activity is edited in Rev.Required status
    isOpalRevReqActModified: function(component){
        var isfieldsedited = false;
        var editedFieldRequiresApproval = component.get("v.activityFieldSetList");
        if(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == $A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequired") || component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c") == 'Planned'){
            if(this.fieldEligibleForApprovalModified(component, editedFieldRequiresApproval)) {
                isfieldsedited = true;
            }else if(component.get("v.isSPIFSecModified")) { //If SPIF Sec modified return true
                isfieldsedited = true;
            }else {
                if (this.validateKPIValues(component)) {
                    this.setKPIValues(component);
                }
                if(component.get("v.newPFR.Core_MDF_Metrics_Modified_ind__c")){ // If Metrics modified return true
                    isfieldsedited = true;
                }
            }
            if(isfieldsedited){
                component.set("v.isEditPlanned",true);
                //this.fetchApprovers(component);
                
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
        
        var action = component.get("c.fetchIndPartnerCtryPgmMapping");
        action.setParams({
            "country": country,
             "prgName": component.get("v.programName")
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
                
               // component.set("v.activityMultiIndPartnerVal", opts);
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
    
    //To Display File Upload Section for OPAL Activities
    //This Method will Activity Reimbursement Amount and return true if amount greater than 50k
    checkActivityReimbursementAmount: function(component,metadataBudgetAmount){
        if(component.get("v.isOpalActivity") && $A.get("$Label.c.Core_MDF_FileUpload_BudgetTypes").includes(component.get("v.selBudgetType"))){
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
    
    //DE116354 - File Upload section not visible on Budget Type change 
    //Method to Dispaly file Upload section for OPAL Activities on budget type change
    checkFileUploadForOPAL: function (component) {
        var metadata = component.get("v.metadataMap");
        for (var index = 0; index < metadata.length; index++) {
            
            if (metadata[index].Core_MDF_Field_7_txt__c == component.get("v.SelCategory") &&
                metadata[index].Core_MDF_Field_9_txt__c == component.get("v.SelActivityType") &&
                metadata[index].Core_MDF_Field_4_txt__c == component.get("v.recordtypeDeveloperName")) {
                
                if ((component.get("v.isOpalActivity") && this.checkActivityReimbursementAmount(component, metadata[index].Core_MDF_Number_1_num__c))) {
                    component.set("v.checkbudgetcondition", true);
                }
                if (this.IsSectionToBeVisible(metadata, index)) {
                    this.isFileUploadSectionVisible(component, metadata, index);
                } 
                
            }
        }
    },
    
   
    setPriceReviewerDisableState: function (component, event) { 
       
        var activityStatus = component.get("v.oldstatus");
        var hasPerSet = component.get("v.priceReviewersPer");
       
        if(hasPerSet) {
            var mapVar = [];
            mapVar = {
               /* frstatus: true,
                name: true,
                desc: true,
                sdate: true,
                edate: true,
                budget: true,
                cmpgn: true,
                acct: true,
                country: true,*/
                availableBudget: true,
              /*  audience: true,
                prodtype: true,
                brand: true,
                category: true,
                type: true,
                cpled: true,
                cp: true,
                ocp: true,*/
                attachement: true,
               /* questions: true,
                jointcontent: true,
                reimbursement: true, 
                priority: true,
                vrquestions: true,
                eventFormat: true,
                Attr_Var_Pos: true,
                Attr_Var_Neg: true,
                buSplit: true,
                buSplitFld: true*/
                
            };
            component.set("v.disableRRPercent", true);
            //added for IPAmdf manager & price reviewer dual role scenario
            if(component.get("v.accmgrper")){
                //component.set("v.isSaveandNewDisable",false);
            	component.set("v.isSaveDisable",false);
            }else{
                component.set("v.isSaveandNewDisable",true);
            	component.set("v.isSaveDisable",true);
            }
            
           // this.setOPALActDisableState(component,mapVar)
            if((component.get("v.componentAttributes.isLoggedInUserApprover") || component.get("v.hasIUPGMRecord")) &&  this.isCurrentUsrIsApprover(component)&& component.get("v.newPFR.Core_MDF_Fund_Request_Status__c") == 'Pending Review' ){
                component.set("v.isSaveDisable", false);
                component.set("v.isSPIFSecReadOnly", false);
            }
            component.set("v.disabledMap", mapVar);
        }
    },
    //[IPA] BU Mapping - this method is use to get the default value(BU Name, %split) from metadata -start
    /*getDefaultedValueForBUSplit : function (component,event){
        var recordTypeDeveloperName = "";
        var pfrFieldLabel = [];
        var mode = component.get("v.mode");
        var budgetType = "";
        var propBased = "";
        if(mode == 'edit' || mode == 'clone'){
            recordTypeDeveloperName = component.get("v.newPFR.RecordType.DeveloperName");  
        }
        else{
            recordTypeDeveloperName =  component.get("v.recordtypeDeveloperName");  
        }
         if(component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != undefined){
            propBased = component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c");
        }
        else{
            propBased = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        }
        
        if(mode == 'clone' && component.get("v.updatedCampBudgetType") != undefined && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && propBased){
            budgetType = component.get("v.updatedCampBudgetType");
        }
        else{
            budgetType = component.get("v.selectedLookUpRecord").Core_MDF_Opal_Budget_Type_Txt__c;
        }
        /*if(budgetType != undefined && budgetType != null && component.get("v.buSplitAvaliableList")  ){ 
            var metadataBuResult = [];
            var currAvalValList= [];            
            var actionFetchMetadataBuSplit = component.get("c.fetchMetadataMappingSplitSection");
            actionFetchMetadataBuSplit.setParams({
                'budgetType': budgetType,
                'prgName': component.get("v.recordtypeName")
            });
            actionFetchMetadataBuSplit.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    metadataBuResult = response.getReturnValue();
                    //component.set("v.metadataBuSplitMap",metadataBuResult);
                    var selectedBUDefault = [];
                    var avaBuPicklistValue = [];
                    var sum = 0;
                    if(metadataBuResult.length > 0){    
                        component.set("v.showBUSPlitMultiselect",true);
             	component.set("v.showBuSplitSection",true);
                        for(let i =0;i<metadataBuResult.length;i++){
                            //multiselect avaliable list 
                            avaBuPicklistValue.push({
                                class: "optionClass",
                                label: metadataBuResult[i].Core_MDF_BU_Name__c, 
                                value: metadataBuResult[i].Core_MDF_BU_Name__c
                            });
                            if(metadataBuResult[i].Core_MDF_Default_BU__c){
                                //selected value if BU is defaulted
                                selectedBUDefault.push(metadataBuResult[i].Core_MDF_BU_Name__c);  //set default bu name
                                sum +=isNaN(parseInt(metadataBuResult[i].Core_MDF_Split_Percent__c)) ? 0 : parseInt(metadataBuResult[i].Core_MDF_Split_Percent__c);
                            }                   
                        }
                    }	 
                    component.set("v.buSplitAvaliableList", avaBuPicklistValue);
                    component.set("v.defaultBUPercent",sum) ;
                    if(component.get("v.defaultBU") == null ||  component.get("v.defaultBU") == ''){
                        component.set("v.defaultBU",selectedBUDefault);
                        component.set("v.buSplitSelectedList",component.get("v.defaultBU")); //selected value in multiselect picklist
                    }
                    //if default value is 100, set multiselect picklist to read only
                    if(component.get("v.defaultBUPercent") == '100'){
                        component.set("v.disabledMap.buSplit",true); // make multitselct BU field disable
                    } 
                }else{
               var errorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
                this.displaySuccessErrorMsg(errorMessage, "Error", "error");
                }
            });
            
            $A.enqueueAction(actionFetchMetadataBuSplit);
        } */ 
   // },
    //[IPA] BU Mapping - this method is use to get the default value(BU Name, %split) from metadata -end
    
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
                	helper.displaySuccessErrorMsg(errorMessage, "Error", "error");                }
        });
        $A.enqueueAction(actionGetInitialData);
    },
    
    //Added by Ramapriya - to restrict activity edit in In-Progress status while claim is in approval
    validateInProgressActivity: function(component, activityId) {
        var action = component.get("c.validateApprovalClaimStatus");
        action.setParams({ activityId: activityId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isRestricted = response.getReturnValue();
                if (isRestricted) {
                    var alertMsg = $A.get("$Label.c.Core_MDF_InProgressEdit_Restrict_Error");
                    this.displaySuccessErrorMsg(alertMsg, "Error", "error");

                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": activityId,
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                }
            } else {
                console.error("Failed " + state);
            }
        });

        $A.enqueueAction(action);
    },

     //Added by Hema for field Editability
     getFieldEditabilityMapping : function(component, event)
    {
         component.set("v.showSpinner", true);
        var recordTypeDeveloperName = (component.get("v.newPFR.RecordType.DeveloperName"));
       
        var fieldEditibilityMap = component.get("c.getFieldEditabilityMapping");
        var pfrFieldEditablity = {};
         fieldEditibilityMap.setParams({
             obj: component.get("v.newPFR"),
             contentType: 'Field Editability',
             
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
                }
            }
            else{
                component.set("v.pfrFieldEditablity",null);
            }
          component.set("v.showSpinner", false);
        });
       $A.enqueueAction(fieldEditibilityMap);

        
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
        if(budgetAmount.length == 1){
            budgetAmount[0].setCustomValidity($A.get("$Label.c.Core_MDF_Budget_Amount_Error"));
            budgetAmount[0].reportValidity();
        }else{
			component.set("v.showErrorMsgForSpendingLimit", false);
            budgetAmount.setCustomValidity($A.get("$Label.c.Core_MDF_Budget_Amount_Error"));
            budgetAmount.reportValidity();
        }               
        var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
        this.displaySuccessErrorMsg(alertMsg,"Error!","error");
    },
    
    ipsActMultiSubtypeVal: function(component){
        var activityMultiSubTypeVal = component.find("activityMultiSubTypeVal");         
        if(activityMultiSubTypeVal != undefined){        
        if(activityMultiSubTypeVal.length == 1){
            activityMultiSubTypeVal[0].validateErrors();
        }else{
            activityMultiSubTypeVal.validateErrors();
        }            
        }
        var alertMsg = $A.get("$Label.c.Core_MDF_Empty_Field_Error");                                  
        this.displaySuccessErrorMsg(alertMsg,"Error!","error");
    },
    
    getActivityAmount: function(component){
        var calculatedValue = '';
        var activityBudgetAmount = component.get("v.newPFR.RequestedAmount");
        var rRate = '';
        
        
        if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !component.get("v.isPropBasedCampaign")){ 
            if( $A.util.isEmpty(component.get("v.ActReimbursementRt"))){
                 rRate = component.get("v.selectedLookUpRecord").Core_MDF_ReimbursementRate_pct__c;
            }else{
                var actRR=component.get("v.ActReimbursementRt");
                 if(!actRR.endsWith('%') && !actRR.replace(/\s/g, '').length==0){
                     rRate =actRR.trim()+"%";
                 }else{
                     rRate = actRR.trim();
                 }
            }
        } else {
            rRate = component.get("v.SelReimbursementRate");
        }
        var slicedValue = (rRate == null || $A.util.isEmpty(rRate) || rRate == undefined)?0:rRate.slice(0,-1);
        var actReimbursementAmount = this.getEffectiveIPAIntelInvestment(
            component,
            (activityBudgetAmount * slicedValue) / 100,
            component.get("v.newPFR")
        );// Indu IPA Proposal
        calculatedValue = parseFloat(actReimbursementAmount.toFixed(2));
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
        //return returnValue;
    },
    //OPAL Past Dated Activity Submission process
    onStartDateChange: function(component){
        var todayDate = this.getTodayDateLocalTime();
        var oldStartDate = component.get("v.oldPFR.Core_MDF_Start_Date__c");
        var newStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var startDateBeforeChange =  component.get("v.oldStartDate");
        var mode = component.get("v.mode");
        var oldBT = component.get("v.oldPFR.Core_MDF_Budget_Type_nm__c");
        var budgetType = component.get("v.selBudgetType");
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        if (mode == 'clone' && oldBT != null) {
            if (oldStartDate != null && newStartDate < todayDate && !component.get("v.externalper") && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")) )) {
                component.set("v.IsPR", true);
            } else {
                component.set("v.IsPR", false);
            }
        }
        if ( mode == 'edit' && oldBT != null) {
            if (oldStartDate != newStartDate && newStartDate < todayDate && !component.get("v.externalper") && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")))) {
                component.set("v.IsPR", true);
            } else {
                component.set("v.IsPR", false);
            }
        }
        if (mode != 'clone' && mode != 'edit') {
            if (newStartDate < todayDate && (opalBudgetTypes.includes(budgetType) || (component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.accmgrper")))) {
                if (!component.get("v.externalper")) {
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
            if(component.get("v.externalper")){
                if(newStartDate < todayDate && (opalBudgetTypes.includes(budgetType))){
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");                                
                    this.displaySuccessErrorMsg(alertMsg,"Error!","error"); // call common method to display error
                    component.set("v.IsStartDateChanged", true); 
                }
                else{
                    component.set("v.IsStartDateChanged", false);
                }
            }
        }
        if (component.get("v.externalper")) {
            if (oldStartDate != null && oldStartDate != newStartDate && newStartDate < todayDate) {
                if(
                   (mode == 'clone' && opalBudgetTypes.includes(budgetType)) || (mode == 'edit' && (budgetType == $A.get("$Label.c.Core_MDF_BudgetType_MDF") || budgetType ==$A.get("$Label.c.Core_MDF_BudgetType_MDFPlus")))){
                    var alertMsg = $A.get("$Label.c.Core_MDF_Activity_Retail_14_Days");
                    this.displaySuccessErrorMsg(alertMsg, "Error!", "error"); // call common method to display error
                    component.set("v.IsStartDateChanged", true);
                }
                
            } else {
                component.set("v.IsStartDateChanged", false);
            }
        }

        //Ayush - Changes for new Category/Type
        if($A.get("$Label.c.Core_MDF_BypassNewCategoryFilter").toLowerCase() != "true"){
            if(this.isNotBlank(newStartDate) && this.isNotBlank(startDateBeforeChange)){
                var oldYear = new Date(startDateBeforeChange).getUTCFullYear(); //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI. 
                var newYear = new Date(newStartDate).getUTCFullYear();//Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
                if(oldYear != newYear){
                    this.dependentPickValAdditionAndRemoval(component, "Core_MDF_ActivityCategory__c");
                   // if(component.get("v.mode") != 'clone'){
                        if(component.get("v.mode") == 'edit' || (component.get("v.mode") == 'clone' && component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true)){
                            component.set("v.SelCategory", '');
                        }
                        if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == false || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == false)){    
                            this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                        }
                        else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && (component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c") == true || component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") == true)){
                            this.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                        }
                   // }
                }
            }
            component.set("v.oldStartDate",newStartDate);
        }
    },
    
    loadFieldsetFields: function (component) {
        var recordTypeDeveloperName = "";
        var pfrFieldLabel = [];
        var mode = component.get("v.mode");
        if(mode == 'edit' || mode == 'clone'){
            recordTypeDeveloperName = component.get("v.newPFR.RecordType.DeveloperName");  
        }
        else{
            recordTypeDeveloperName =  component.get("v.recordtypeDeveloperName");  
        }
        var action = component.get("c.loadDynamicFields");
        var pfrFieldVisibility = {};        
        var pfrRequiredField = {};        
        var oldPFRFields = component.get("v.pfrFieldVisibility");
        var budgetType = "";
        var budType = "";
        var propBased = "";
         if(component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != undefined){
            propBased = component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c");
        }
        else{
            propBased = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        }
        if(mode == 'clone' && component.get("v.updatedCampBudgetType") != undefined && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && propBased){
            budgetType = component.get("v.updatedCampBudgetType");
        }
        else{
            budgetType = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
        }
        if(budgetType != null && budgetType != undefined){
            budType = budgetType;
        }
        else{
            budType = 'defaultBudget';
        }
        action.setParams({
            pickListObj: 'Core_MDF_Custom_Picklist__c',
            budType: budType,
            recType: recordTypeDeveloperName,
            isPropBased: propBased,
            objectName: 'PartnerFundRequest'
        });
        $A.enqueueAction(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var result = response.getReturnValue(); 
                if(result != undefined && result != null){  
                    var pfrFields = result;
                    for(let i = 0; i < pfrFields.length; i++){
                    	pfrFieldVisibility[pfrFields[i].fieldAPIName] = true;
                        pfrRequiredField[pfrFields[i].fieldAPIName] = pfrFields[i].isRequired;
                    }
                    
                    component.set("v.pfrFieldVisibility",pfrFieldVisibility);
                    component.set("v.pfrRequiredFields",pfrRequiredField);
                }
            }
            else{
                component.set("v.pfrFieldVisibility",null);
                component.set("v.pfrRequiredFields",null);
            }
        });
        
        this.fetchPicklistFromCampaign(component);
    },
    
    fetchPicklistFromCampaign: function (component) {
        var recordTypeDeveloperName = "";
        var mode = component.get("v.mode");
        if(mode == 'edit' || mode == 'clone'){
            recordTypeDeveloperName = component.get("v.newPFR.RecordType.DeveloperName");  
        }
        else{
            recordTypeDeveloperName =  component.get("v.recordtypeDeveloperName");  
        }
        var budgetType = "";
        var budType = "";
        var propBased = "";
         if(component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c") != undefined){
            propBased = component.get("v.newPFR.Core_MDF_Proposal_Based_Ind__c");
        }
        else{
            propBased = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        }
        if(mode == 'clone' && component.get("v.updatedCampBudgetType") != undefined && (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType")) && propBased){
            budgetType = component.get("v.updatedCampBudgetType");
        }
        else{
            budgetType = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
        }
        if(budgetType != null && budgetType != undefined){
            budType = budgetType;
        }
        else{
            budType = 'defaultBudget';
        }

        var valueFromCampaign = {};        
        var action = component.get("c.fetchPicklistFromCampaign");
        action.setParams({
            pickListObj: 'Core_MDF_Custom_Picklist__c',
            budType: budType,
            recType: recordTypeDeveloperName,
            isPropBased: propBased,
            objectName: 'PartnerFundRequest'
        });
        $A.enqueueAction(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var result = response.getReturnValue(); 
                var picklistFields = result;
                if(result != null){  
                    for(let i = 0; i < picklistFields.length; i++){
                    valueFromCampaign[picklistFields[i]] = true;
                    }
                    component.set("v.FieldValuesFromCampaign",valueFromCampaign);
                }
                
            }
        });
    },
    
   /* correctBUSplitMapping: function (component) {
        var availableFieldsForBudgetType = component.get("v.metadataBuSplitMap");
        var fieldsArr = [];
       if(availableFieldsForBudgetType != null && availableFieldsForBudgetType != '' && availableFieldsForBudgetType != undefined){ 
        for (let p = 0; p < availableFieldsForBudgetType.length; p++) {
            fieldsArr.push(availableFieldsForBudgetType[p].Core_MDF_Field_Name__c);
        }
       }
        for (let n = 1; n <= 10; n++) {
            var BUfield = 'Core_MDF_BU' + n + '_Split_Percent_nbr__c';
            var mergFLD = 'v.newPFR.' +  BUfield ;
            if(!fieldsArr.includes(BUfield) && component.get(mergFLD) != null){
                component.set(mergFLD, '');
            }
        }
    },*/
    updateBuSplitFormula: function(component,event,helper){
        if(!$A.util.isEmpty(component.get("v.buSplitSelectedList")) && component.get("v.buSplitSelectedList") != undefined && component.get("v.buSplitSelectedList") !=  null ){
            var selBUSpltManual = [];
            selBUSpltManual =  component.get("v.buSplitSelectedList");
            var buSplitFormula = "";
            if(selBUSpltManual.includes('CCG') && component.get("v.newPFR.Core_MDF_BU1_Split_Percent_nbr__c") > 0){
                buSplitFormula = buSplitFormula + 'CCG - '+component.get("v.newPFR.Core_MDF_BU1_Split_Percent_nbr__c").toString()+'%; ';
            }
            if(selBUSpltManual.includes('DCG') && component.get("v.newPFR.Core_MDF_BU2_Split_Percent_nbr__c") > 0){
                buSplitFormula = buSplitFormula + 'DCG - '+component.get("v.newPFR.Core_MDF_BU2_Split_Percent_nbr__c").toString()+'%; ';
            }
            if(selBUSpltManual.includes('IOTG') && component.get("v.newPFR.Core_MDF_BU3_Split_Percent_nbr__c") > 0){
                buSplitFormula = buSplitFormula + 'IOTG - '+component.get("v.newPFR.Core_MDF_BU3_Split_Percent_nbr__c").toString()+'%; ';
            }
            if(selBUSpltManual.includes('NSG') && component.get("v.newPFR.Core_MDF_BU4_Split_Percent_nbr__c") > 0){
                buSplitFormula = buSplitFormula + 'NSG - '+component.get("v.newPFR.Core_MDF_BU4_Split_Percent_nbr__c").toString()+'%; ';
            }
            if(selBUSpltManual.includes('PSG') && component.get("v.newPFR.Core_MDF_BU5_Split_Percent_nbr__c") > 0){
                buSplitFormula = buSplitFormula + 'PSG - '+component.get("v.newPFR.Core_MDF_BU5_Split_Percent_nbr__c").toString()+'%; ';
            }
            component.set("v.updatedBuSplit",buSplitFormula);
        }
    },
    //Rishabh
    /*availableBudgetCheck: function (component, event, helper){
        var budgetType = component.get("v.budgetTypeVal");
        var opalBudgetTypes = $A.get("$Label.c.Core_MDF_OPAL_BudgetTypes").split(";");
        var recordTypeName = component.get("v.recordtypeDeveloperName");
        var campaignBudget = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");
        var proposalBasedCamp = component.get("v.selectedLookUpRecord.Core_MDF_Proposal_Based_Ind__c");
        var isMatchingBudgetAvailable = false;
        if (component.get("v.mode") == "" && $A.util.isEmpty(budgetType))
        {
            if ((recordTypeName == $A.get("$Label.c.Core_MDF_PFR_CCF") || recordTypeName == $A.get("$Label.c.Core_MDF_PFR_DCF") ) && (campaignBudget != null && campaignBudget != undefined && campaignBudget != 'CCF 1.0' && campaignBudget != 'DCF 1.0')){                
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
                },*/
calcIntelContribution: function (component, budgetAmount, ActReimbRt) {

if(ActReimbRt != undefined && ActReimbRt != null && ActReimbRt != ''&& budgetAmount != undefined && budgetAmount != null && budgetAmount != ''){
 var intelContri;
 intelContri = this.getEffectiveIPAIntelInvestment(
     component,
     budgetAmount * (parseFloat(ActReimbRt) / 100),
     component.get("v.newPFR")
 );// Indu IPA Proposal
 component.set("v.IPAIntelContri", intelContri);
   this.getActivityAmount(component);  
}
},
                    //added by SS
                    hasIUPGMRecord : function (component){
                        var userID = $A.get("$SObjectType.CurrentUser.Id");
                        if(component.get("v.newPFR.RecordType.DeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType"))
                        {
                        var countryList = component.get("v.newPFR.Core_MDF_Country_nm__c").split(';');
                        }
                        else
                        {
                             var countryList = component.get("v.selectedCountryOptions");
                        }
                       
                        component.set("v.userId", userID);
                        var action = component.get("c.checkCurrentUserIsApprover");
                        console.log('resultpfr',JSON.stringify(component.get("v.oldPFR")));
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
                    },
		removePicklistValues: function( excludedValues, initialPicklistOptions){
            var finalPicklistOptions = new Array();
            initialPicklistOptions.forEach(item => {	
                if(!excludedValues.includes(item.label)){
                    finalPicklistOptions.push(item);
                }
            });
            return finalPicklistOptions;
        },

     validateActivity: function(component)
       {  
         var ipaProposalErrormsg = "";
      if(component.get("v.pfrCloneCheck") == true){
         if($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Focus_Area_Error_Message") + '\n'; 
          }
          if($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Initiative_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Initiative_Error_Msg") + '\n'; 
          }
          if($A.util.isEmpty(component.get("v.newPFR.Core_MDF_TargetAudience_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_TargetAudienceError") + '\n'; 
          }
          if($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Industry_Multi_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Industry_Error_Msg") + '\n';   
          }
          if($A.util.isEmpty(component.get("v.SelPriority")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Priority_Error") + '\n';  
          }
           if($A.util.isEmpty(component.get("v.SelProductType")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_ProductTypeError") + '\n'; 
          }
          if($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Brand_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Focus_Area_nm__c")))
          {
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_BrandError") + '\n'; 
          }
          if(component.get("v.activityEventNameApplicable") && $A.util.isEmpty(component.get("v.selActivityEventName"))){
                ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_EventNameError") + '\n'; 
          }
          if(component.get("v.showOtherEventName") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Other_Event_Name_txt__c"))){
                ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_OtherEventNameError") + '\n'; 
          }
          if($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Country_nm__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Program__c"))){
                ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_MarketError") + '\n'; 
            }
          if (($A.get("$Label.c.Core_MDF_2025_Domain_Type_ActivityCategory").split(';')).includes(component.get("v.SelCategory")) && $A.util.isEmpty(component.get("v.SelDomainType")) ){
            ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_DomainTypeError") + '\n';
	    }
          
          if(component.get("v.showNegativeInputError")){
               ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Empty_Field_Error") + '\n';
          }
          if(component.get("v.countryValidation")==true){
              ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Country_Multiple_Geo_Error") + '\n';
          }
          if(component.get("v.campPfrDateMismatch") == true) {
             ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Campaign_Date_Check_Error") + '\n';
           }
           //POP and Attribution Requirements error message throw if field is empty for proposal based
           if(component.get("v.isAttributionReqVisible") && !component.get("v.externalper") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Attribution_Requirements_txt__c"))){
                ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_AttributionrequirementsError") + '\n'; 
           }
           if(component.get("v.isPOPReqVisible") && !component.get("v.externalper") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_POP_Requirements_txt__c"))){
                ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_POPrequirementsError") + '\n'; 
           }
           if(component.get("v.showActTactics") && $A.util.isEmpty(component.get("v.newPFR.Core_MDF_Tactics_nm__c"))){
                ipaProposalErrormsg = ipaProposalErrormsg + $A.get("$Label.c.Core_MDF_Activity_Tactics_Error") + '\n'; 
           }
          if (ipaProposalErrormsg != "")
            {
                this.displaySuccessErrorMsg(ipaProposalErrormsg,"Error!","error");
                component.set("v.chkBdgtCpExcd",false);
                component.set("v.ShowEventPopup",false);
               return true;
            }
          else
          {
              return false;
          }
          }
       },
     hideOtherActTypeForExternalUser:function(component, event, helper){ 
         if(component.get("v.recordtypeDeveloperName") == $A.get("$Label.c.Core_MDF_IPA_RecordType")) {
              var otherActivityTypes = '';
                        if(component.get('v.externalper')) {
                            otherActivityTypes = $A.get("$Label.c.Core_MDF_OtherActivityTypes");
                            if(component.get("v.checkCloneAttribute")) { 
                                if(otherActivityTypes.includes(component.get("v.SelActivityType"))) {
                                    component.set("v.SelActivityType", '');
                                }
                            }
                           
                        }
         }
     },
     //generic method to fetch camapign values and check if it is present on activity as well. If present on activity retain those values
     getUpdatedCampaignPicklistValues:function(component,event,updatedPicklistValues, activityFiledApiName){
			var returnedCampValue = [];
            var activityFieldOptionsChanged = [];
            returnedCampValue = JSON.parse(JSON.stringify(updatedPicklistValues));
            returnedCampValue = returnedCampValue.campPickListValuesChangedObj;
            if(this.isNotBlank(returnedCampValue)){
                for(var outerIndex = 0; outerIndex < returnedCampValue.length; outerIndex++){
                    if(returnedCampValue[outerIndex].activityFieldAPIName == activityFiledApiName 
                       && this.isNotBlank(returnedCampValue[outerIndex].picklistValuesOnCampaign)){
						
                        for(var innerIndex = 0; innerIndex < returnedCampValue[outerIndex].picklistValuesOnCampaign.length; innerIndex++){
                            activityFieldOptionsChanged.push(returnedCampValue[outerIndex].picklistValuesOnCampaign[innerIndex]);
                            
                        }
                        
                    }
                }
            }
            return activityFieldOptionsChanged;
		}, 
        checkCountry: function(component){
            var check=false;
            
            this.serverCall(component.get("c.restrictMutliGeoCountry"), {
                pfr: component.get("v.newPFR"),
                oldPfr : component.get("v.oldPFR")
            }).then(function (result) {                
                    if(result == true){
                       
                        component.set("v.countryValidation",true);
                    }else{
                        component.set("v.countryValidation",false);
                    }
            }).catch((error) => {
                console.log('Error in loading for QuickAction. Error : ', error);
            });
        },
    serverCall : function(action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if(params){
                action.setParams(params);
            }
            action.setCallback(this, function(a){
                if(a.getState() == "SUCCESS"){
                    resolve(a.getReturnValue());
                } else {
                    reject(a.getError());
                }
           });
           $A.enqueueAction(action);
        }));
    },
       enableDisableButtons : function(component, isSaveDisable, isSaveandNewDisable){
        component.set("v.isSaveDisable", isSaveDisable);
        component.set("v.isSaveandNewDisable", isSaveandNewDisable);
    },
     //capture start time during activity creation               
     partnerEffortMetricForActivityCreation : function(component){
        var currDateTime = new Date();
        const startDateTime = new Date(currDateTime).toISOString();
        component.set("v.activityCreationStartTime",startDateTime);
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
        picklistValuesAddition: function (filedslocalizedMap, selectedFieldsValues, fieldValuesOptionsMap) {
            for(var index = 0; index < selectedFieldsValues.length; index++){
                if(!fieldValuesOptionsMap.find((fieldValues) => fieldValues.value === selectedFieldsValues[index])){
                    fieldValuesOptionsMap.push({
                        "label": filedslocalizedMap[selectedFieldsValues[index]],
                        "value": selectedFieldsValues[index]
                    });
                }
            }
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
      isRecordApprover : function (component){
               
          if( component.get("v.oldPFR")!=null &&  component.get("v.oldPFR")!= undefined){
                var userID = $A.get("$SObjectType.CurrentUser.Id");
                component.set("v.userId", userID);
              
                var action = component.get("c.checkCurrentUserIsApprover");
              
                console.log('resultpfr',JSON.stringify(component.get("v.oldPFR")));
                action.setParams({
                "obj" : component.get("v.oldPFR"),
                "userId" :component.get("v.userId")
            });
            action.setCallback(this, function (response) {
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    if(res == true){
                        component.set("v.isUserCurrentIPAApprover", true);
                                   
                        this.setSaveBtnVisibility(component);

                    }else{
                       
                        
                        var alertMsg = $A.get("$Label.c.Core_MDF_CloneAccessError");
                         console.log('line 1910');
             this.displaySuccessErrorMsg(alertMsg, "Error!", "error"); // call common method to display error
             var sObectEvent = $A.get("e.force:navigateToSObject");
             sObectEvent .setParams({
                 "recordId": component.get("v.newPFR.Id"),
                 "slideDevName": "detail"
             });
             sObectEvent.fire(); 
                    }  
                }
                
            });
            $A.enqueueAction(action);
        }
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

        validateIPAMetricsValues : function (component) {
            var isMetricsBlank = false;
            if(component.get("v.mode") == 'edit' && (this.isNotBlank(component.get("v.oldPFR.Core_MDF_Metrics_txt__c")) 
                                                     || this.isNotBlank(component.get("v.oldPFR.Core_MDF_Key_Marketing_Indicator_nm__c")))){
                isMetricsBlank = false;
            }
            else{
                var lwccomp = component.find("kpiFields");
                if (lwccomp != null) {
                    var kpiValues = lwccomp.getKPIValues();
                    if (kpiValues != null) {
                        for (var key in kpiValues) {
                            if (kpiValues[key] !== null && kpiValues[key] != "" && kpiValues[key] != undefined){
                                isMetricsBlank = false;
                                break;
                            }
                            else{
                                isMetricsBlank = true;
                            }
                        }
                    }
                }
        	}
            return isMetricsBlank;
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
        //Akash Changes
        validateStartDate: function(component, startDate) {
        var accountBased_StartDate = $A.get("$Label.c.Core_MDF_IPA_AccountBased_StartDate");
        var budgetType = component.get("v.selectedLookUpRecord.Core_MDF_Opal_Budget_Type_Txt__c");  
        
        if (startDate && budgetType == "Account Plan") {
            var cutoffDate = new Date(accountBased_StartDate);
            var selectedDate = new Date(startDate);
            
            if (selectedDate >= cutoffDate) {
                    // Show error message
                component.set("v.showStartDateError", true);
            } else {
                    // Hide error message if date is valid
                component.set("v.showStartDateError", false);
            }
            } else {
                component.set("v.showStartDateError", false);
            }
        },

        //Ayush - Changes for new Category/Type
        filterNewCategoryValues : function(component,childPickListField, selectedControllingFieldValue){
            var latestCategoryValues = [];
            var startDateYear = new Date(component.get("v.newPFR.Core_MDF_Start_Date__c")).getUTCFullYear(); //Ayush - changed getFullYear to getUTCFullYear as it was refering user's system's local timezone instead of the selected year on UI.
            var childPickField;
            for(var key in childPickListField){ 
                if(key == selectedControllingFieldValue){
                    if ( startDateYear < $A.get("$Label.c.Core_MDF_NewCategoryDate")){
                        latestCategoryValues = component.get("v.latestCategoryValues");
                        childPickListField[key] = childPickListField[key].filter(item => !latestCategoryValues.some(itemToBeRemoved => itemToBeRemoved.value === item.value));
                    }
                    else if(startDateYear >= $A.get("$Label.c.Core_MDF_NewCategoryDate")){
                        latestCategoryValues = component.get("v.latestCategoryValues");
                        childPickListField[key] = childPickListField[key].filter(item => latestCategoryValues.some(itemToBeRemoved => itemToBeRemoved.value === item.value));
                    }
                }
            }
            return childPickListField;
        },

        //Ayush - Changes for new Category/Type
        getNewCategoryValues : function(component, recordTypeDevName){
            if(recordTypeDevName == $A.get("$Label.c.Core_MDF_IPA_RecordType")){
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
        }

     });