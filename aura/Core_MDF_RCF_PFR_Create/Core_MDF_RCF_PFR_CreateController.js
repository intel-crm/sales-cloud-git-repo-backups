({   
    // Function Called On Change of the date fields on the Form to construct campaign lookup filter
   createAdditionalfilter : function(component, event, helper) {
		var checkEndDate;
        var checkStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        component.set("v.newPFR.Core_MDF_End_Date__c",checkStartDate);
        var newEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var recordtype = component.get("v.recordtypeName");
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
		 if(!(component.get("v.disabledMap.edate"))){
            
            checkEndDate   = component.set("v.newPFR.Core_MDF_End_Date__c",checkStartDate);
            
        }
        helper.constructadditionalfilter(component, checkStartDate, newEndDate, recordTypeDeveloperName);
	} ,
    
    //Function called on change of End Date to contruct campaign lookup filter
    createNewAdditionalfilter : function(component, event, helper) {
        var newcheckStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var newcheckEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var newrecordtype = component.get("v.recordtypeName");
        var newrecordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        helper.constructadditionalfilter(component, newcheckStartDate, newcheckEndDate, newrecordTypeDeveloperName);
    },
    
    
    
    //NZ Function Called On Change of the Budget Amount Local Field to Calculate USD
    calculateBudgetAmount : function(component, event, helper){
        var checkBudgetAmountLocal = component.get("v.BudgetLocal");
        var checkBudgetCurrency = component.get("v.BudgetCurrency");
        component.set("v.message",'');
        component.set("v.messageType",'');
        if((component.get("v.BudgetCurrency") == 'USD' || component.get("v.BudgetCurrency") == null)){
            //alert('BudgetisUSD--' +component.get("v.BudgetLocal"));
            component.set("v.newPFR.RequestedAmount",checkBudgetAmountLocal);
        }
        else if(($A.util.isEmpty(component.get("v.BudgetLocal")))==false){
            //alert('BudgetisLocal--' +component.get("v.BudgetLocal"));
            helper.calculateBudgetAmount(component, checkBudgetAmountLocal, checkBudgetCurrency);
        }
    },
    // Function called on click of Cancel or "X" on the layout 
    closeModal: function(component, event, helper) {
        if(component.get("v.checkCloneAttribute")){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.checkCloneRecordId"),
                "slideDevName": "detail"
            });
            navEvt.fire();
        }else{
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "PartnerFundRequest"
            });
            homeEvent.fire();
        }
    },
    // Function called on click of Cancel or "X" on the layout 
    closeModalClosedActivtiy: function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "PartnerFundRequest"
        });
        homeEvent.fire();
    },
    // Function called on click of save button (We set the selected values to the associated field)
    // Check for the validity of the fields before save
    // Also controls the popup on form
    customSave : function(component, event, helper) {
        //check for Event Popup and File upload
        //Component required validation
        var validData = component.find('NewForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        var localmsg = "";
        var pfrstatus = component.get("v.CurrentStatus");
        //Removing the status value in clone condition
        if(component.get("v.SelectedStatus") != "" && component.get("v.checkCloneAttribute")){
            component.set("v.SelectedStatus","");
        }
        //Error For "Pending Review" Error
        if (component.get("v.recordId") != null && component.get("v.CurrentStatus") == 'Pending Review' && component.get("v.checkCloneAttribute") == false)
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_PendingReviewError");
            validData = false;
        }
        //NZ Error for 'Budget Amount'
        if (component.get("v.newPFR.RequestedAmount") == null || 
            component.get("v.newPFR.RequestedAmount") == 0 ||
            component.get("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c") == 0)
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Budget_Amount_Error");
            validData = false;
        }
        //Error if not Acc mgr or Submitter or Auditor
        if(component.get("v.userWithoutAccess")){
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_CloneAccessError");
            validData = false;
        }
        
        var oldstdate = component.get("v.oldsdate");
        var stdate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldstatus = component.get("v.oldstatus");
        var accmgrper = component.get("v.accmgrper");
        //NZ
        if (stdate>oldstdate && accmgrper && oldstatus == 'In-Progress')
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_Date_Mod_Error");
            validData = false;
        }
        // If all the Entered Data are valid in terms of text or Number
        if(validData){
            //set PFR record with selected values
            component.set("v.newPFR.CampaignId",component.get("v.selectedLookUpRecord").Id);       
            if(component.get("v.selectedPartner").Id != null){
                component.set("v.newPFR.ChannelPartnerId",component.get("v.selectedPartner").Id);
            }		
            
            if (component.get("v.CPLed") == false)
            {
                component.set("v.SelOtherChannelPartner",'');
                component.set("v.SelChannelPartner",'');
            }
            
            if (component.get("v.SelChannelPartner") != 'Others' && component.get("v.SelOtherChannelPartner") != '')
                component.set("v.SelOtherChannelPartner",'');
            
            component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.selectedLookUpRecord").Core_MDF_Priority__c);
            component.set("v.newPFR.Core_MDF_Country__c",component.get("v.SelMarketValue"));
            component.set("v.newPFR.Core_MDF_ActivityCategory__c",component.get("v.SelCategory"));
            component.set("v.newPFR.Core_MDF_Activity_Types__c",component.get("v.SelActivityType"));
            component.set("v.newPFR.Core_MDF_Brand__c",component.get("v.SelBrand"));
            component.set("v.newPFR.Core_MDF_ProductType__c",component.get("v.SelProductType"));
            component.set("v.newPFR.Core_MDF_TargetAudience__c",component.get("v.SelTargetAudience"));
            component.set("v.newPFR.RecordTypeId",component.get("v.recordtype"));
            component.set("v.newPFR.Core_MDF_Channel_Partner__c",component.get("v.SelChannelPartner"));
            component.set("v.newPFR.Core_MDF_Other_Channel_Partner__c",component.get("v.SelOtherChannelPartner"));
            component.set("v.newPFR.Core_MDF_Channel_Partner_Led__c",component.get("v.CPLed"));
            component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.CurrentStatus"));
            //component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.CurrentStatus"));
            component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.BudgetCurrency"));
            component.set("v.newPFR.Core_MDF_Budget_Type_nm__c",component.get("v.BudgetType"));
            component.set("v.newPFR.BudgetId",component.get("v.Budget"));
            component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
            component.set("v.newPFR.Core_MDF_Joint_Content_ind__c",component.get("v.JointContent"));
            if(component.get("v.SelectedStatus") != "" ){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",component.get("v.SelectedStatus"));
            }
            // Making Id null in order to save New Record from clone
            if(component.get("v.checkCloneAttribute")){
                component.set("v.newPFR.Id",null);
                component.set("v.recordId",null);
            }
            
            var CCFBudgetHundredK = false; // Areefa: created custom label for 100k hardcoded value
            var DCFBudgetHundredK = false;
            var SPCFBudgetHundredK = false;
            // Variable Assigned for comparing old and new value on PFR
            var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
            var actgry = component.get("v.SelCategory");
            var bugamt = component.get("v.newPFR.RequestedAmount");
            var sdate = component.get("v.newPFR.Core_MDF_Start_Date__c");
            var edate = component.get("v.newPFR.Core_MDF_End_Date__c");
            var actstatus = "";
            
            var oldbudget =  component.get("v.oldbudget");
            var oldcategory = component.get("v.oldcategory");
            var oldstatus = component.get("v.oldstatus");
            var oldsdate = component.get("v.oldsdate");
            var oldedate = component.get("v.oldedate");
            var fileupd = component.get("v.ChgndAttach");
            var accmgrper = component.get("v.accmgrper");
            
            
            if(bugamt >= $A.get("$Label.c.Core_MDF_CCF_100K_Budget_Activity") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")){
                CCFBudgetHundredK = true;	                                                                    
            }
            if(bugamt >= $A.get("$Label.c.Core_MDF_DCF_100K_Budget_Activity") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")){
                DCFBudgetHundredK = true;	                                                                    
            }                                                                    
            if(bugamt >= $A.get("$Label.c.Core_MDF_SPCF_100K_Budget_Activity") && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF")){
                SPCFBudgetHundredK = true;	                                                                    
            }
            
            if (component.get("v.recordId") != null ) // In edit mode set the status && ignore clone
            {
                var isstatusset = false;
                if (oldstatus == "Pending Review" || oldstatus == "Revision Required")
                {
                    actstatus = "Pending Review";
                    isstatusset = true;
                }
                else if (oldstatus == "Planned"
                         && actgry == 'Event' && (CCFBudgetHundredK || DCFBudgetHundredK || SPCFBudgetHundredK) 
                         && (actgry != oldcategory || bugamt != oldbudget
                             || oldsdate != sdate || fileupd))
                {	
                    actstatus = "Pending Review";
                    isstatusset = true;
                }
                    else if((component.get("v.SelectedStatus") != "Cancelled") && (oldstatus == "Planned"))
                    {
                        actstatus = "Planned";
                        isstatusset = true;
                    }
                if (isstatusset == true)
                {
                    component.set("v.newPFR.Core_MDF_Fund_Request_Status__c",actstatus);
                }
                
            }
            else if(component.get("v.CurrentStatus") == "Planned"){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c","Pending Review");
            }
            
            var fileException = false;
            fileException = component.get('v.fileexceptionper');
            
            if (component.get("v.checkifcondition") && component.get("v.PopupType") == null && 
                component.get("v.SelectedStatus") != "Cancelled" && component.get("v.CurrentStatus") != "Cancelled" && 
                component.get("v.SelectedStatus") != "In-Progress" && component.get("v.CurrentStatus") != "In-Progress")
            {
                helper.checkRemindersandFileUpload(component);
            }     
            else if (component.get("v.Uploadfinished") == false && component.get("v.checkfileuploadcondition") == true
                     && !fileException){
                var error = $A.get("$Label.c.Core_MDF_Upload_File_Message");
                component.set("v.message",error);
                component.set("v.messageType","error");
                if(component.get("v.checkCommunityAttribute") || component.get("v.checkNewCommunityAttribute") || component.get("v.checkCloneAttribute")){
                    document.querySelector('#pivot').scrollIntoView();
                }
                else{
                    window.scrollTo(0,0);
                }
            }            
                else if ((component.get("v.Uploadfinished") == true || component.get("v.PopupType") == ""
                          || component.get("v.checkbudgetcondition") == false || 
                          (!component.get("v.checkifcondition") && component.get("v.checkbudgetcondition"))))
                {
                    helper.saveHelperMethod(component,component.get("v.newPFR"));
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
    
    //Function called on click of Save and New button
    customSaveandNew : function(component, event, helper) {
        component.set("v.isSaveandNew",true);
        var a = component.get('c.customSave');
        $A.enqueueAction(a)
        
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
            component.set("v.checkifcondition", true);
        } else if(EventData == true){
            if(popupType == 'Event'){
                //helper.popUpHelper(component,"ELC");
                component.set("v.EventMessage",$A.get("$Label.c.Core_MDF_Terms"));
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
    questions: function(component,event){
        var pfr = event.getParam("valueOfDynamicQ");
        if (pfr.Core_MDF_Competitive_Elements__c != null)
            component.set("v.newPFR.Core_MDF_Competitive_Elements__c",pfr.Core_MDF_Competitive_Elements__c);//event.getParam("compCheck"));
        if (pfr.Core_MDF_Government_Nexus__c != null)
            component.set("v.newPFR.Core_MDF_Government_Nexus__c",pfr.Core_MDF_Government_Nexus__c);//event.getParam("govCheck"));
        if (pfr.Core_MDF_ofPagesEligible__c != null)
            component.set("v.newPFR.Core_MDF_ofPagesEligible__c",pfr.Core_MDF_ofPagesEligible__c);// event.getParam("pageEligible"));
        if (pfr.Core_MDF_pagespayingfor__c != null)
            component.set("v.newPFR.Core_MDF_pagespayingfor__c",pfr.Core_MDF_pagespayingfor__c);//event.getParam("pagePaying"));
    },
    
    // Function called on the load of the page 
    // Contains two Part:- Edit scenario (where we set the values to attribute from the record fields )
    // New Scenario (where we create record type filter )
    doInit: function(component, event, helper) {
        if(component.get("v.apitoLabelConvert") == null){
            //var fields = "Core_MDF_ActivityCategory__c,Core_MDF_Activity_Types__c,Core_MDF_Country__c";
            var fields = $A.get("$Label.c.Core_MDF_PFRPicklistField");
            var fieldlist = fields.split(",");
            helper.convertApitoLable(component,fieldlist);
        }
        
        var getoptionMap = component.get("v.apitoLabelConvert");
        for(var key in getoptionMap ){
            if(key = component.get("v.BudgetCurrency")){
                component.set("v.CurrentCurrencyLabel", getoptionMap[key]);
                break;
            }
        }

        helper.fetchPicklistInfo(component,component.get("v.fieldNameCurrency"));
       
        helper.fetchPicklistInfo(component,component.get("v.fieldNameBudgetType"));        
        
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
        component.set("v.renderGovtQuestion",false);
        component.set("v.renderPrintQuestion",false);
        //Load the metadata Value on the load of the page
        var metadataresult;
        var action = component.get("c.fetchMetadataMapping");
        action.setCallback(this, function(response) {
            metadataresult = response.getReturnValue(); 
            component.set("v.metadataMap",metadataresult);
        });
        
        $A.enqueueAction(action);
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
        
        var action = component.get("c.userHasPermissionSet");
        action.setParams({
            "permissionsets": userperMap
        });    
        $A.enqueueAction(action);
        action.setCallback(this, function(response) {
            component.set('v.userperMap','{}');
            component.set('v.userperMap',response.getReturnValue().userPermissions);
            // alert('userMap---' + JSON.stringify(component.get('v.userperMap')));
            var mapResults = component.get('v.userperMap');
            
            for(var key in mapResults)
            {
                component.set("v." + key,mapResults[key]);
            }
            
            if((!component.get("v.accmgrper") && !component.get("v.auditorper") && !component.get("v.externalper"))){
                component.set("v.userWithoutAccess",true);
            }
            
        });
        
        //Load the page with record values for Edit scenario
        if(component.get("v.recordId") != null || 
           (component.get("v.checkCommunityAttribute") && component.get("v.communityRecordId") != null) ||
           component.get("v.checkCloneAttribute") && component.get("v.checkCloneRecordId") != null)
        {//NZ
            if(component.get("v.checkCommunityAttribute")){
                component.set("v.recordId",component.get("v.communityRecordId"));
            }
            if(component.get("v.checkCloneAttribute")){
                component.set("v.recordId",component.get("v.checkCloneRecordId"));
            }
            if(component.get("v.checkCloneAttribute")){
                component.set("v.checkStatusAttribute",false);
            }
            var result;
            var action = component.get("c.loadPFRRecord");
            action.setParams({
                "pfrId" : component.get("v.recordId")                
            });
            action.setCallback(this, function(response) {
                result = response.getReturnValue();
                component.set("v.newPFR",result);
                //component.set("v.selectedLookUpRecord.Id",result.CampaignId);
                component.set("v.selectedLookUpRecord",result.Campaign);
                component.set("v.selectedLookUpRecord.Core_MDF_Priority__c",result.Campaign.Core_MDF_Priority__c);
                component.set("v.selectedPartner.Id",result.ChannelPartnerId);
                component.set("v.selectedPartner",result.ChannelPartner);
                component.set("v.BudgetLocal",result.Core_MDF_Budget_Amount_Local_amt__c);
                component.set("v.BudgetCurrency",result.Core_MDF_Budget_Currency_cd__c);
                component.set("v.BudgetType", result.Core_MDF_Budget_Type_nm__c);
                component.set("v.Budget",result.BudgetId);
                component.set("v.SelMarketValue",result.Core_MDF_Country__c);
                component.set("v.SelActivityType",result.Core_MDF_Activity_Types__c);
                component.set("v.SelBrand",result.Core_MDF_Brand__c);
                component.set("v.SelCategory",result.Core_MDF_ActivityCategory__c);
                component.set("v.SelTargetAudience",result.Core_MDF_TargetAudience__c);
                component.set("v.SelProductType",result.Core_MDF_ProductType__c);
                component.set("v.SelChannelPartner",result.Core_MDF_Channel_Partner__c);
                component.set("v.SelOtherChannelPartner",result.Core_MDF_Other_Channel_Partner__c);
                component.set("v.CPLed",result.Core_MDF_Channel_Partner_Led__c);
                component.set("v.JointContent",result.Core_MDF_Joint_Content_ind__c); 
                // Make Sure there is no dependencies Status for Clone
                if(component.get("v.checkCloneAttribute") == false){
                    component.set("v.CurrentStatus",result.Core_MDF_Fund_Request_Status__c);
                    if(component.get("v.CurrentStatus") == 'Closed'){
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
                
                
                if (result.Core_MDF_Channel_Partner_Led__c == true)
                {
                    component.set("v.IsCP",true);
                    helper.enabledisablecpled(component,false);
                }
                else{
                    helper.EnableCPCheckBox(component,event);
                }
                
                if (result.Core_MDF_Channel_Partner__c == 'Others')
                    component.set("v.IsOtherCP",true);
                
                recordType = result.RecordType.Name;
                startdate  = result.Core_MDF_Start_Date__c;
                enddate    = result.Core_MDF_End_Date__c;
                //NZ
               // component.set("v.oldsdate",startdate);
                var recordTypeDeveloperName = result.RecordType.DeveloperName;
                //console.log("Response"+ JSON.stringify(response.getReturnValue()));
                component.set("v.recordtypeName",recordType);
                component.set("v.recordtype",result.RecordTypeId);
                component.set("v.recordtypeDeveloperName",recordTypeDeveloperName);
                
                helper.constructadditionalfilter(component, startdate, enddate,recordTypeDeveloperName);
                //if(recordType == $A.get("$Label.c.Core_MDF_CCF_RecordType") || recordType == $A.get("$Label.c.Core_MDF_DCF_RecordType")){
                if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
                   recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                   recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
                   recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
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
                // Set the controls disabled property for edit mode based on the criteris defined
                if(component.get("v.checkCloneAttribute") == false){
                    helper.SetAccMgrDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName );
                    helper.SetExternalDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                    helper.SetAuditorDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                }
            });
            
            $A.enqueueAction(action);
        }
        else{
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
            //if(recordType == $A.get("$Label.c.Core_MDF_CCF_RecordType") || recordType == $A.get("$Label.c.Core_MDF_DCF_RecordType")){
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
               recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
               recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
              recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")){
                helper.activityPicker(component, recordTypeDeveloperName);
            }
        }
    }, 
    
    resetActivtyType:function(component, event, helper){
        component.set("v.SelActivityType",null);
        component.set("v.newPFR.Core_MDF_ofPagesEligible__c",'0');
        component.set("v.newPFR.Core_MDF_pagespayingfor__c",'0');
        component.set("v.newPFR.Core_MDF_Government_Nexus__c",$A.get("$Label.c.Core_MDF_DQNo"));
        component.set("v.newPFR.Core_MDF_Competitive_Elements__c",$A.get("$Label.c.Core_MDF_DQNo"));
        helper.resetHelper(component);
        helper.fetchActType(component);
        
    }, 
    resetProdType:function(component, event, helper){
        component.set("v.SelProductType",null);
        helper.fetchProdType(component);
    },
    
    resetBrand:function(component, event, helper){
        component.set("v.SelBrand",null);
        helper.fetchBrandType(component);
    },
    
    resetActTypeDepAttributes:function(component, event, helper){
        helper.resetHelper(component);
    },
    
    // Function called from the change event handler to reset popup and file upload attributes
    resetpopupattributes: function(component, event, helper) {
        helper.resetHelper(component);
    },
    // Function called on the change Account change
    resetAccountattributes : function(component, event, helper){
        if(component.get("v.selectedPartner") == null || component.get("v.selectedPartner").Id == null){
            
            component.set("v.newPFR.ChannelPartnerId",null);
        }
    },
    // Function called on the picklist fields
    resetPicklistValues:function(component, event, helper){
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        if((component.get("v.oldCampaignId") != component.get("v.selectedLookUpRecord.Id"))){
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF") ){
                component.set("v.SelTargetAudience",null);
                component.set("v.SelProductType",null);
                component.set("v.SelBrand",null);
            }
            else if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
                    recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF")){
                component.set("v.SelTargetAudience",null);
                component.set("v.SelProductType",null);
                component.set("v.SelBrand",null);
                component.set("v.SelCategory",null);
                component.set("v.SelActivityType",null);
                component.set("v.CPLed",false);
            }
        }
        
    },
    
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
        else if (PicFieldName == 'Core_MDF_Country__c' || PicFieldName == 'Core_MDF_ActivityCategory__c'
                 || PicFieldName == 'Core_MDF_Activity_Types__c' )
        {
            if (PicFieldName == 'Core_MDF_Channel_Partner_Led__c')
            {
                component.set("v.SelOtherChannelPartner",'');
            }
            component.set('v.CPLed',false);
            helper.EnableCPCheckBox(component,event);
        }
            else if (PicFieldName == 'Core_MDF_Channel_Partner__c')
            { 
                component.set('v.IsOtherCP',false); 
                component.set("v.SelOtherChannelPartner",'');
            }
        
    },
    //Function called on change of budget currency
    resetBudgetAmount : function(component,event,helper){
        component.set("v.BudgetCurrency",component.get("v.BudgetCurrency")); 
    }
})