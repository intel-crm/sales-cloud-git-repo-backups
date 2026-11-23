({   
    // Function Called On Change of the date fields on the Form to construct campaign lookup filter
    createAdditionalfilter : function(component, event, helper) {
	//Variable Reimbursement Rate changes
	helper.resetHelper(component);
        var checkStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        component.set("v.newPFR.Core_MDF_End_Date__c",checkStartDate);
        var newEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
    var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
 
        helper.constructadditionalfilter(component, checkStartDate, newEndDate, recordTypeDeveloperName, null);
    } ,
    //Test code start
    
  //Function called for filtering country values
  filterCountry: function (component, event, helper) {
    var countryName = component.get("v.CountryPicklistValues");
    var filterCountrySearch = new Array();
    var filterCountryNonSearch = new Array();
    if (component.get("v.countryFilter") != null) {
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
  },
    //Test code ends
    //Function called on change of End Date to contruct campaign lookup filter
    createNewAdditionalfilter : function(component, event, helper) {
        var newcheckStartDate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var newcheckEndDate = component.get("v.newPFR.Core_MDF_End_Date__c");
    var newrecordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
    //helper.constructadditionalfilter(component, newcheckStartDate, newcheckEndDate, newrecordTypeDeveloperName);
        helper.constructadditionalfilter(component, newcheckStartDate, newcheckEndDate, newrecordTypeDeveloperName, null);
    },
    
    
    
    //Function Called On Change of the Budget Amount Local Field to Calculate USD
    calculateBudgetAmount : function(component, event, helper){
    component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
    component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
    component.set("v.isSaveDisable", false);
    component.set("v.isSaveandNewDisable", false);
    component.set("v.message", "");
    component.set("v.messageType", "");
	if (component.get("v.checkCloneAttribute")) {
      component.set("v.newPFR.CreatedDate", null);
    }
    // Calling function for budget check
    if(!$A.util.isEmpty(component.get("v.BudgetLocal")) && !$A.util.isEmpty(component.get("v.budgetCurrency"))){
      helper.budgetAmountcalculatefunction(component);
        }
    helper.resetHelper(component);
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

	/*	var lwccomp = component.find('kpiFields');
	    if (lwccomp != null && lwccomp.isFormValid()){
		var kpiValues = lwccomp.getKPIValues();
		if (kpiValues != null){
		    var pfrmain = component.get("v.newPFR");
		    var mergedObj = Object.assign({}, pfrmain, kpiValues);
		    component.set("v.newPFR",mergedObj);
		    //alert(mergedObj.Core_MDF_Type_of_Page_txt__c);
		       //alert(mergedObj.Core_MDF_Estimated_Ad_Size_nbr__c);
		    //alert(mergedObj.Core_MDF_Magazine_Newspaper_txt__c);
		}
	    }
	    else if (lwccomp != null && !lwccomp.isFormValid()){
		return;
	    }
	  */  
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
    // var pfrstatus = component.get("v.CurrentStatus");
		//Subtype validation when its mandatory
		if (component.get("v.activitySubTypeAvailable") == true && (component.get("v.selActivitySubType") == "" || component.get("v.selActivitySubType") == null)) {
		  localmsg = localmsg + $A.get("$Label.c.Core_MDF_ActivitySubTypeError");
		  validData = false;
		}
		//Removing the status value in clone condition
        if(component.get("v.SelectedStatus") != "" && component.get("v.checkCloneAttribute")){
            component.set("v.SelectedStatus","");
        }
        //Pending Review Activities cannot be edited except Retail
        if (component.get("v.recordId") != null && component.get("v.CurrentStatus") == 'Pending Review' && component.get("v.checkCloneAttribute") == false  && component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")) 
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_PendingReviewError");
            validData = false;
        }
        //Error for 'Budget Amount'
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
        var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
        var oldstdate = component.get("v.oldsdate");
        var stdate = component.get("v.newPFR.Core_MDF_Start_Date__c");
        var oldstatus = component.get("v.oldstatus");
        var accmgrper = component.get("v.accmgrper");
        var edate = component.get("v.newPFR.Core_MDF_End_Date__c");
        var oldedate = component.get("v.oldedate");
		// Event Format Data
   
    // Event Format Data Stamping And Error Handling
		
		if(component.get("v.enableEventFormat")){
		  if(!$A.util.isEmpty(component.get("v.selectedEventFormat"))){
				component.set("v.newPFR.Core_MDF_Event_Format_Nm__c", component.get("v.selectedEventFormat"));
		  }else{
              //if((component.get("v.CurrentStatus") != "In-Progress" && component.get("v.CurrentStatus") != "Closed")){
				/*if(component.get("v.CurrentStatus") == "Planned" && (DCFBudgetHundredK || SPCFBudgetHundredK)){
					validData = true;
                }else{*/
					localmsg = localmsg + $A.get("$Label.c.Core_MDF_Activity_Event_Form_Error");
					validData = false; 
				//}  
              //}
		  }
		}else{
		  component.set("v.newPFR.Core_MDF_Event_Format_Nm__c", null);
		  component.set("v.selectedEventFormat", null);
		}

        
        
        //Error for Rejected Retail Activities
        if (component.get("v.recordId") != null && component.get("v.CurrentStatus") == 'Rejected'
            && component.get("v.SelectedStatus") != 'Cancelled'
            && component.get("v.checkCloneAttribute") == false && 
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_RejectedError_Retail");
            validData = false;
        }
        
        //Error for Closed Retail Activities
        if (component.get("v.recordId") != null && component.get("v.CurrentStatus") == 'Closed' 
            && component.get("v.checkCloneAttribute") == false && 
            recordTypeDeveloperName.includes($A.get("$Label.c.Core_MDF_Closed_Activity_Program_Wise")))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Close_Activity_Error");
            validData = false;
        }
       
        /*Error when new end date is less than old end date*/
        if ((edate<oldedate) && accmgrper && oldstatus == 'Planned' &&
            recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail")  && !component.get("v.checkCloneAttribute"))
        {
            localmsg = localmsg + $A.get("$Label.c.Core_MDF_Acc_Mgr_End_Date_Mod_Error");
            validData = false;
        }
        if ((stdate>oldstdate) && accmgrper && oldstatus == 'In-Progress'  && !component.get("v.checkCloneAttribute"))
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
            component.set("v.newPFR.Core_MDF_Budget_Currency_cd__c",component.get("v.budgetCurrency"));
            component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c",component.get("v.BudgetLocal"));
            component.set("v.newPFR.Core_MDF_Joint_Content_ind__c",component.get("v.JointContent"));
            //Country Multi Select           
            component.set("v.newPFR.Core_MDF_Country_nm__c",component.get("v.SelMarketValue"));             
            component.set("v.newPFR.Core_MDF_Channel_Partner__c",component.get("v.SelChannelPartner"));
            
			//Variable Reimbursement Rate changes - stamp technology from Campaign
			component.set("v.newPFR.Core_MDF_Technology_txt__c",component.get("v.selectedLookUpRecord").Core_MDF_Technology__c);

	    if (!$A.util.isEmpty(component.get("v.incentive")) && parseFloat(component.get("v.incentive")) > 0) {
			if ($A.util.isEmpty(component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c")) || component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == "No") {
				component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", "No");
				component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", "No");
				component.set("v.newPFR.Core_MDF_Incentive_pct__c", null);
				component.set("v.newPFR.Core_MDF_Incentive_Criteria_Id__c", null);
			}
			else if (component.get("v.newPFR.Core_MDF_Incentive_Question_ind__c") == "Yes") {
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
				component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c", null);
				component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c", null);
			}
	    }
            if(recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_PFR_Retail"))
            {
		//Subtype single select
	       component.set("v.newPFR.Core_MDF_Activity_SubType_nm__c", component.get("v.selActivitySubType"));	
               if(component.get("v.campriorityValue") == false ){
                    component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.selectedLookUpRecord").Core_MDF_Priority__c); 
                }
                else{
                   component.set("v.newPFR.Core_MDF_Priorities__c",component.get("v.campriority"));
                }
                component.set("v.newPFR.Core_MDF_Budget_Type_txt__c",component.get("v.selectedLookUpRecord").Core_MDF_Budget_Type_txt__c);  
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
                
				component.set("v.newPFR.Core_MDF_POP_Requirements_txt__c", component.get("v.autoPopulatePOP"));
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
                component.set("v.newPFR.Id",null);
                component.set("v.recordId",null);
                component.set("v.newPFR.CreatedDate",null);
	 }
            //Enabe Activity type edit for CCF Planned status
            
            var oldedate = component.get("v.oldedate");
  	            if (component.get("v.recordId") != null ){ // In edit mode set the status && ignore clone{                var isstatusset = false;
        //Account Manager - - 
        //Activty  Status In cancelled/ In-Progress, Closed , we donot set to Pending Review planned
        //Core_MDF_PFR_RestrictStatusChange - In-Progress, Closed 
        //$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)
        if(!component.get("v.SelectedStatus").includes($A.get("$Label.c.Core_MDF_Activity_Cancelled_Status")) &&
           !$A.get("$Label.c.Core_MDF_PFR_RestrictStatusChange").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c"))) {

              if(component.get("v.accmgrper") && component.get("v.recordtypeDeveloperName") != $A.get("$Label.c.Core_MDF_PFR_Retail")){
                component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_CCP_Planned_Status"));
              }else{
                helper.setfundRequestStatusHelper(component);
              }
              //Set the Fund Request Status based on criteria's - ContentCreateActivty or event or Revision Required or Retail  
              
        }
      }else if(component.get("v.CurrentStatus") == $A.get("$Label.c.Core_MDF_CCP_Planned_Status")) {
        component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
      }
      //Print Media, VR ,Upload File, Event Validation
      helper.checkExtraQuestionAndUploadFile(component);
            
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
		
		//Variable Reimbursement Rate changes

		if (pfr != undefined) {
			if (pfr.Core_MDF_Competitive_Elements__c != null)
				component.set("v.newPFR.Core_MDF_Competitive_Elements__c",pfr.Core_MDF_Competitive_Elements__c);//event.getParam("compCheck"));
			if (pfr.Core_MDF_Government_Nexus__c != null)
				component.set("v.newPFR.Core_MDF_Government_Nexus__c",pfr.Core_MDF_Government_Nexus__c);//event.getParam("govCheck"));
			if (pfr.Core_MDF_ofPagesEligible__c != null)
				component.set("v.newPFR.Core_MDF_ofPagesEligible__c",pfr.Core_MDF_ofPagesEligible__c);// event.getParam("pageEligible"));
			if (pfr.Core_MDF_pagespayingfor__c != null)
				component.set("v.newPFR.Core_MDF_pagespayingfor__c",pfr.Core_MDF_pagespayingfor__c);//event.getParam("pagePaying"));
			if (pfr.Core_MDF_Incentive_Opted_In_ind__c != null && pfr.Core_MDF_Incentive_Opted_In_ind__c != undefined)
				component.set("v.newPFR.Core_MDF_Incentive_Opted_In_ind__c",pfr.Core_MDF_Incentive_Opted_In_ind__c);
			if (pfr.Core_MDF_Incentive_Question_ind__c != null && pfr.Core_MDF_Incentive_Question_ind__c != undefined)
				component.set("v.newPFR.Core_MDF_Incentive_Question_ind__c",pfr.Core_MDF_Incentive_Question_ind__c);  
			}
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

        //Load the metadata Value on the load of the page
        var metadataresult;
    var actionFetchMetadata = component.get("c.fetchMetadataMapping");

    actionFetchMetadata.setCallback(this, function (response) {
      metadataresult = response.getReturnValue();
      component.set("v.metadataMap", metadataresult);
    });

    $A.enqueueAction(actionFetchMetadata);
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
        
        var action = component.get("c.userHasPermissionSet");
        action.setParams({
            "permissionsets": userperMap
        });    
        $A.enqueueAction(action);
        action.setCallback(this, function(response) {
            component.set('v.userperMap','{}');
            component.set('v.userperMap',response.getReturnValue().userPermissions);
      	    component.set("v.isActivityReviewRequired", response.getReturnValue().isActivityReviewRequired);
      	    var mapResults = component.get("v.userperMap");
            
            for(var key in mapResults)
            {
                component.set("v." + key,mapResults[key]);
            }
            
            if(component.get("v.auditorper")){
                component.set("v.isSaveandNewDisable",true);
            }
      if (!component.get("v.accmgrper") && !component.get("v.auditorper")
        && !component.get("v.externalper") && !component.get("v.retailgeouserper") && !component.get("v.rsmActivityReviewerper")) {
                component.set("v.userWithoutAccess",true);
            }
            
        });
        //Load the page with record values for Edit scenario
        if(component.get("v.recordId") != null || 
           (component.get("v.checkCommunityAttribute") && component.get("v.communityRecordId") != null) ||
           component.get("v.checkCloneAttribute") && component.get("v.checkCloneRecordId") != null)
        {
             var priorityType = [];
                 
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
      var actionLoadPfr = component.get("c.loadPFRRecord");
      actionLoadPfr.setParams({
        pfrId: component.get("v.recordId")
      });
      actionLoadPfr.setCallback(this, function (response) {
                result = response.getReturnValue();
	        var state = response.getState();
	        if (state === "SUCCESS") {
                component.set("v.newPFR",result);
	          console.log('result.Core_MDF_Metrics_txt__c ::: ' + result.Core_MDF_Metrics_txt__c);
	          if (result.Core_MDF_Fund_Request_Status__c == 'Pending Review' && !component.get("v.checkCloneAttribute")) {
	            //alert('In doint 548');
	            helper.validateIfActivityInApproval(component);
	          }
               	component.set("v.showSpinner", false);
                //component.set("v.selectedLookUpRecord.Id",result.CampaignId);
                //component.set("v.selectedLookUpRecord.Id",result.Campaign);
                component.set("v.selectedLookUpRecord",result.Campaign);
                component.set("v.selectedPartner.Id",result.ChannelPartnerId);
                component.set("v.selectedPartner",result.ChannelPartner);
                component.set("v.BudgetLocal",result.Core_MDF_Budget_Amount_Local_amt__c);
                component.set("v.budgetCurrency",result.Core_MDF_Budget_Currency_cd__c);
                if(result.Core_MDF_Exchange_Rate_ptc__c != null  && component.get("v.checkCloneAttribute") == false){
             	    component.set("v.createdDateClone",false);
                    component.set("v.budgetCurrencyOld",result.Core_MDF_Budget_Currency_cd__c);
                }else if(component.get("v.checkCloneAttribute") == true || result.Core_MDF_Exchange_Rate_ptc__c == null){
                    component.set("v.createdDateClone",true);
                    helper.calculateBudgetAmount(component,component.get("v.newPFR"));
                }
                
                //component.set("v.SelMarketValue",result.Core_MDF_Country__c);
                component.set("v.SelActivityType",result.Core_MDF_Activity_Types__c);
                component.set("v.SelBrand",result.Core_MDF_Brand__c);
                component.set("v.SelCategory",result.Core_MDF_ActivityCategory__c);
                component.set("v.SelTargetAudience",result.Core_MDF_TargetAudience__c);
                component.set("v.SelProductType",result.Core_MDF_ProductType__c);
                component.set("v.SelChannelPartner",result.Core_MDF_Channel_Partner__c);
                component.set("v.SelOtherChannelPartner",result.Core_MDF_Other_Channel_Partner__c);
                component.set("v.CPLed",result.Core_MDF_Channel_Partner_Led__c);
                component.set("v.JointContent",result.Core_MDF_Joint_Content_ind__c); 
                component.set("v.SelMarketValue",result.Core_MDF_Country_nm__c); 
                component.set("v.SelReimbursementRate",result.Core_MDF_Reimbursement_Rate__c); //Reimbursement Rate assignment
        	component.set("v.selectedEventFormat", result.Core_MDF_Event_Format_Nm__c); // Event Format Data
              if(component.get("v.recordtypeDeveloperName") ==  $A.get("$Label.c.Core_MDF_PFR_Retail")){
                  
				  component.set("v.autoPopulatePOP", result.Core_MDF_POP_Requirements_txt__c);
                  component.set("v.selectedLookUpRecord.Core_MDF_Account__r.Name", result.ChannelPartner.Name);
                  component.set("v.campriority",result.Core_MDF_Priorities__c);
                  component.set("v.selectedLookUpRecord.Core_MDF_Budget_Type_txt__c",result.Core_MDF_Budget_Type_txt__c);
                  //subtype single select
				  component.set("v.selActivitySubType", result.Core_MDF_Activity_SubType_nm__c);
                  priorityType.push({
                      key  :  result.Core_MDF_Priorities__c,
                      value:  result.Core_MDF_Priorities__c
                  });
                  
                  if( result.Campaign.Core_MDF_Priority__c != null &&
                     result.Campaign.Core_MDF_Priority__c != result.Core_MDF_Priorities__c){
                      priorityType.push({
                          key  : result.Campaign.Core_MDF_Priority__c,
                          value: result.Campaign.Core_MDF_Priority__c
                      });
                  }
                  if( result.Campaign.Core_MDF_Priority_2_nm__c != null &&
                     result.Campaign.Core_MDF_Priority_2_nm__c != result.Core_MDF_Priorities__c){
                      priorityType.push({
                          key  : result.Campaign.Core_MDF_Priority_2_nm__c,
                          value: result.Campaign.Core_MDF_Priority_2_nm__c
                      });
                  }
                  if(result.Campaign.Core_MDF_Priority_3_nm__c != null &&
                     result.Campaign.Core_MDF_Priority_3_nm__c != result.Core_MDF_Priorities__c){
                      priorityType.push({
                          key  : result.Campaign.Core_MDF_Priority_3_nm__c,
                          value: result.Campaign.Core_MDF_Priority_3_nm__c
                      });
                  }
                  component.set("v.PriorType",priorityType);
              }else
              {
                   component.set("v.selectedLookUpRecord.Core_MDF_Priority__c",result.Campaign.Core_MDF_Priority__c);
              }
                // Make Sure there is no dependencies Status for Clone
                if(component.get("v.checkCloneAttribute") == false){
                    component.set("v.CurrentStatus",result.Core_MDF_Fund_Request_Status__c);
                    if(component.get("v.CurrentStatus") == 'Closed' && component.get("v.accmgrper") == false){
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
                
                if (result.Core_MDF_Channel_Partner__c == 'Others')
                    component.set("v.IsOtherCP",true);
                
                recordType = result.RecordType.Name;
                startdate  = result.Core_MDF_Start_Date__c;
                enddate    = result.Core_MDF_End_Date__c;
                
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
                   recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") ||
                   recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")){
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
              	//Variable Reimbursement Rate - stamp old prod type and brand values
        		component.set("v.oldProdType", result.Core_MDF_ProductType__c);
        		component.set("v.oldBrand", result.Core_MDF_Brand__c);
        //Attributes for the Currency validation
        var newObject = new Object;
        var mergedObject = Object.assign(newObject, result);
        component.set("v.oldPFR", mergedObject);
                // Set the controls disabled property for edit mode based on the criteris defined
                if(component.get("v.checkCloneAttribute") == false){
	            	 if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") && component.get("v.isActivityReviewRequired")) {
                        helper.setRMFReviewerDisabledState(component);
                    }
                    helper.SetAccMgrDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName );
                    helper.SetExternalDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                    helper.SetAuditorDisabledState(component, component.get("v.newPFR.RequestedAmount"), recordTypeDeveloperName);
                   
                   } 
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
            //if(recordType == $A.get("$Label.c.Core_MDF_CCF_RecordType") || recordType == $A.get("$Label.c.Core_MDF_DCF_RecordType")){
            if(recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")|| 
               recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF") ||
               recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF") ||
               recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_Retail") ||
               recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")){
                helper.activityPicker(component, recordTypeDeveloperName);
            }
        }
    }, 
    
    resetActivtyType:function(component, event, helper){
        component.set("v.SelActivityType",null);
        component.set("v.newPFR.Core_MDF_ofPagesEligible__c",'0');
        component.set("v.newPFR.Core_MDF_pagespayingfor__c",'0');
        component.set("v.newPFR.Core_MDF_Government_Nexus__c","No");
        component.set("v.newPFR.Core_MDF_Competitive_Elements__c","No");
 
        helper.resetHelper(component);
        helper.fetchActType(component);
        
    }, 
    resetProdType:function(component, event, helper){
        component.set("v.SelProductType",null);
        helper.fetchProdType(component);
    },
    
    resetBrand:function(component, event, helper){
        component.set("v.SelBrand",null);
		//Variable Reimbursement Rate changes
		helper.resetHelper(component);
        helper.fetchBrandType(component);
    },
	
	//Variable Reimbursement Rate changes
	resetonBrandChange: function (component, event, helper) {
		helper.resetHelper(component);
	},
    
    resetActTypeDepAttributes:function(component, event, helper){
            //this to reset the activity sub type value on chage of activity type
            component.set("v.selActivitySubType", null);
	    
	    helper.fetchPOPReqInfo(component);
    	helper.fetchEventFormat(component);
    	//this to fetch the activity subtype on the basis of selected act type
		helper.fetchActSubTypeMulti(component);             
	    helper.resetHelper(component);
	    var kpiComponent = component.find("kpiFields");
	    console.log("kpiComponent->" + kpiComponent);
	    if (kpiComponent != null) {
	      var vprogram = component.get("v.recordtypeName");
	      var vctgry = component.get("v.SelCategory");
	      var vtype = component.get("v.SelActivityType");
	      var inputParams = {}; //kpiComponent.getInputParams();
	      if (vprogram != null) {
		inputParams.recordId = component.get("v.recordId");
		inputParams.objName = "PartnerFundRequest";
		inputParams.activityCategory = vctgry;
		inputParams.activityType = vtype;
		inputParams.program = vprogram;
		inputParams.isRequired = true;
		inputParams.title = $A.get("$Label.c.Core_MDF_KPI_Metrics");
		inputParams.enableKPI = helper.verifyKPIEditability(component);
		//kpiComponent.inputValues = inputParams;
		console.log("initiate call->" + inputParams);
		kpiComponent.loadKPIAttributes(inputParams);
	      }
	    }
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
                //Variable Reimbursement - reset VR on Campaign change
				//component.set("v.renderVRQuestion", false);
				helper.resetHelper(component);
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
        if(recordTypeDeveloperName ==  $A.get("$Label.c.Core_MDF_PFR_Retail"))
        {
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
                  //component.set("v.campriority",null);
            }
            
            if(component.get("v.selectedLookUpRecord.Core_MDF_Account__c") != null){
                component.set("v.selectedPartner", component.get("v.selectedLookUpRecord.Core_MDF_Account__r.Name"));                
           		
            }    
        }
        //Variable Reimbursement Rate changes - fetch VR questions
		if (component.get("v.selectedLookUpRecord.Id") != null) {
		  helper.fetchVRQuestion(component);
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
        else if (PicFieldName == 'Core_MDF_Country_nm__c' || PicFieldName == 'Core_MDF_ActivityCategory__c'
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
        component.set("v.budgetCurrency",component.get("v.budgetCurrency")); 
    }
});