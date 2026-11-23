({
  // Helper function called from Custom Save Function controller js
  // Calls Server Side Controller function which saves the record after performing all the server side validation
 
  saveHelperMethod: function (component, newPFR) {
      //Disable Save button
      component.set("v.isSaveDisable", true);
      component.set("v.isSaveandNewDisable", true);
      var action = component.get("c.savenSendRecordId");
      action.setParams({
          "pfr": newPFR,
          "contentdocumentids": component.get("v.ContentDocumentIds"),
          "BudgetException": component.get("v.BudgetException")
      });

      action.setCallback(this, function (response) {
          var state = response.getState();
         
          var fundRequestRecId;
          if (state === "SUCCESS") {
             
              fundRequestRecId = response.getReturnValue();
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                  title: $A.get("$Label.c.Core_MDF_SuccessToastTitle"),
                  type: 'success',
                  message: newPFR.Title + ' ' + $A.get("$Label.c.Core_MDF_SuccessfullToastMessage")
              });
              toastEvent.fire();

              if (component.get("v.isSaveandNew")) {
                  component.set("v.checkSaveComplete", true);
              } else {

                  var navEvt = $A.get("e.force:navigateToSObject");
                  navEvt.setParams({
                      "recordId": response.getReturnValue(),
                      "slideDevName": "detail"
                  });
                  navEvt.fire();

                  if (component.get("v.recordId") != null) {
                      //window.location.reload();
                      setTimeout(function () {
                          window.location.reload();
                      }, 2000);
                  }

              }
          } else {
              // Disable Save button
              component.set("v.isSaveDisable", false);
              component.set("v.isSaveandNewDisable", false);
              var err = action.getError();
              var fieldErrors = JSON.stringify(err[0].fieldErrors);
              var pageErrors = err[0].pageErrors; //array
              var message = err[0].message;
              var error;
              if (message == null) {
                  var fieldErrorMessage = fieldErrors.split("message");
                  var fieldErrorSplitMessage = fieldErrorMessage[1];
                  if (pageErrors.length > 0) {
                      error = JSON.stringify(pageErrors[0].message); //JSON.stringify(pageErrors[0].statusCode) + ":" + JSON.stringify(pageErrors[0].message);  

                  } else if (fieldErrors.length > 0) {
                      error = fieldErrorSplitMessage.slice(3, -4);

                  }
              } else {
                  error = message;
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
              component.set("v.isSaveandNewDisable", false);
          }
      });
      $A.enqueueAction(action);
      //$A.get('e.force:refreshView').fire();
  },
  
  // Helper Method Called from the additionalfilter and doinit fuction to construct the filter
  constructadditionalfilter: function(component,startdate, enddate,recordtype, campaignAccount){

      // Stores label name
      var DCF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateDCFRecordType");
      var CCF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateCCFRecordType");
      var SPCF_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateSPCFRecordType");
      var Retail_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateRetailRecordType");
      var CCF_Boost_NonTranslateLabel = $A.get("$Label.c.Core_MDF_NonTranslateCCFBoostRecordType");

      var sFilter = "";
      var aFilter = "";

      // constructing the filter  -- RecordType
  if (recordtype == $A.get("$Label.c.Core_MDF_PFR_DCF")) { //DCF_Label      
      sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Data_Center_CoMarketing_Fund@quote;";
      aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote; AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
      DCF_NonTranslateLabel + "@quote;";
  } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_CCF")) { //CCF_Label
      sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Client_CoMarketing_Fund@quote;";
      aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote; AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
      CCF_NonTranslateLabel + "@quote;";
  } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_SPCF")) {//SPCF_Label
      sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Service_Provider_CoMarketing_Fund@quote;";
      aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote; AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
      SPCF_NonTranslateLabel + "@quote;";
  } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_Retail")) { //Retail_Label
      sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Retail_Marketing_Funds@quote;";
      //aFilter = "RecordType.DeveloperName= \@quote;Core_MDF_Co_Marketing\@quote; AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" + Retail_NonTranslateLabel + "@quote;";
      //aFilter = "id = @quote;"+campaignAccount+"@quote;";
  } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")) {//CCF Boost_Label      
      sFilter = "RecordType.DeveloperName = @quote;Core_MDF_Client_CoMarketing_Fund_Boost@quote;";
      aFilter = "RecordType.DeveloperName= @quote;Core_MDF_Co_Marketing@quote; AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c=@quote;" +
      CCF_Boost_NonTranslateLabel + "@quote;";
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
  activityPicker: function (component, recordType) {
      //making call to server side to invoke UI API
      var pickListFields = [];
      var pickLabel = $A.get("$Label.c.Core_MDF_ActvityCategoryAndType");
      var pickListFields = pickLabel.split(",");
  
      var result;
      var recType = recordType;
      var action = component.get("c.mainPicklistFetcher");
      
      action.setParams({
          "recordTypeName": recType
      });
      action.setCallback(this, function (response) {
          result = response.getReturnValue();
          //Parse response and initalize attributes            
          
              for (var i = 0; i < pickListFields.length; i++) {              
              //Gets value from parent picklist field
              var sControllingFieldValues = result.picklistFieldValues[pickListFields[i]].controllerValues;
              //Gets value from dependent picklist field 
              var sFieldValues = result.picklistFieldValues[pickListFields[i]].values;
              // Constructing the Options for the picklist field
              this.initActcategoryandType(component, pickListFields[i], sControllingFieldValues, sFieldValues);
              
           }
            
  });
  $A.enqueueAction(action);
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
      //alert($A.get("$Label.c.Core_MDF_CCF_VRInc_Question"));
      //alert($A.get("$Label.c.Core_MDF_DCF_VRInc_Question"));
      //alert($A.get("$Label.c.Core_MDF_SPCF_VRInc_Question"));
      component.set(
        "v.vrQuestion",
        //$A.get(result.Core_MDF_InctQuest_Label_Ref__c)
        $A.getReference(result.Core_MDF_InctQuest_Label_Ref__c)
      );
      }
    }
    });

    $A.enqueueAction(action);
  }

  component.set(
    "v.vrOptInQuestion",
    //$A.get("$Label.c.Core_MDF_VRInc_OptIn_Question")
    $A.getReference("$Label.c.Core_MDF_VRInc_OptIn_Question")
  );
  },

  //Server call for checking incentive
  checkVariableReimbursement: function (component) {
  if (!component.get("v.renderVRQuestion") == true &&
    (!$A.util.isEmpty(component.get("v.newPFR.Core_MDF_TargetAudience__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_ProductType__c")) &&
    !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Brand__c")) && !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_ActivityCategory__c")) &&
    !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Activity_Types__c")) && !$A.util.isEmpty(component.get("v.newPFR.CampaignId")) &&
    !$A.util.isEmpty(component.get("v.newPFR.Core_MDF_Start_Date__c")))) {

    var cpid;
          
      if (((component.get("v.oldActivtyType") != component.get("v.SelActivityType")) || (component.get("v.oldcategory") != component.get("v.SelCategory")) ||
          (component.get("v.oldProdType") != component.get("v.SelProductType")) || (component.get("v.oldBrand") != component.get("v.SelBrand"))
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
      if (result.length > 0) {
      component.set("v.vrdata", result);

              if (!$A.util.isEmpty(component.get("v.vrdata[0].Core_MDF_Incentive_pct__c"))
                // component.get("v.vrdata[0].Core_MDF_Incentive_pct__c") != null &&
                // component.get("v.vrdata[0].Core_MDF_Incentive_pct__c") !=
                // undefined 
                &&
        parseFloat(
        component.get("v.vrdata[0].Core_MDF_Incentive_pct__c")
        ) > 0
      ) {
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
  //checkRemindersandFileUpload: function(component) {

      var metadata = component.get("v.metadataMap");
  //Directly save record, if none of additional functionality reuired
  var callsave = true;
  //Check if for loop to be looped again
  var checkforloop = true;
  for (var index = 0; index < metadata.length; index++) {
    // Checking the condition for the Question and Pop-up based on metadata map
    if (metadata[index].Category__c == component.get("v.SelCategory") && metadata[index].Type__c == component.get("v.SelActivityType") &&
         metadata[index].Record_Type_Picklist__c == component.get("v.recordtypeDeveloperName") && ( $A.util.isEmpty(component.get("v.selActivitySubType")) || metadata[index].Activity_Sub_Type__c == component.get("v.selActivitySubType"))){

      callsave = false;
      //Check if Amount is above threshold(The Upload of file is manadtory) 
      if (component.get("v.newPFR.RequestedAmount") >= metadata[index].Budget_Amount__c) {
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
        //this.checkVariableReimbursement(component);
      } else {
        component.set("v.PopupType", "");
        //Variable Reimbursement Rate changes
        if (goforsave == true) {
          if (this.validateKPIValues(component)) {
            this.setKPIValues(component);
            this.saveHelperMethod(component, component.get("v.newPFR"));
          }
        }
      }
    }
    if (!checkforloop) {
      component.set("v.recordApplicableForActivityRules", false);
      break;
    }
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
IsSectionToBeVisible : function(metadata,index){
  //Check if the Addtional Section to be viisible based on Metadata values w.r.t to selected category and type
  return (metadata[index].Print__c || metadata[index].Govt_Nexus_Flag__c || 
     metadata[index].Core_MDF_Enable_File_Upload__c || metadata[index].Enable_Event_Popup__c ||
     metadata[index].Core_MDF_Enable_ELC_Reminder__c || metadata[index].Core_MDF_Enable_Question__c);
},
isPrintMediaSectionVisible : function(component,metadata,index){
  //For selected Category and Type, validate if Print Media Questions applicable based on metadata field Print__c[Print MEdia Section to be Visible if Print__c is set to true]
  if (metadata[index].Print__c && !component.get("v.renderPrintQuestion")) {
    this.showQuestion(component,true,false,false);
  }

},
isGovtEventQuestionSectionVisible : function(component,metadata,index){
  //For selected Category and Type, validate if Government Questions applicable based on metadata field Govt_Nexus_Flag__c [Government Question Section to be Visible if Govt_Nexus_Flag__c is set to true]
  if (metadata[index].Govt_Nexus_Flag__c && !component.get("v.renderGovtQuestion")) {
    // Areefa removied :&& component.get("v.checkbudgetcondition") as part of US288852
    this.showQuestion(component,false,true,false);
  }
},
isTechExplorationPopUpVisible : function(component,metadata,index){
  //For selected Category and Type, validate if Tech Exploration Questions applicable based on metadata field Core_MDF_Enable_Question__c[Tech Exploration Section to be Visible if Core_MDF_Enable_Question__c is set to true]
  if (metadata[index].Core_MDF_Enable_Question__c) {
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
 
  if (metadata[index].Core_MDF_Enable_File_Upload__c && component.get("v.checkbudgetcondition") && component.get("v.checkfileuploadcondition") == false) {
    component.set("v.checkfileuploadcondition", true);
    //If Event Activity, then Event form links to be visible
    if(this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event"))){
      component.set('v.isEventFormTemplateVisible',true);
    }
  }
},
isEventPopUpVisible : function(component,metadata,index){
  //For selected Category and Type, validate if Event Pop to be shown based on metadata field Enable_Event_Popup__c
  //[ Event Pop to be shown if Enable_Event_Popup__c is set to true]
  
  if (metadata[index].Enable_Event_Popup__c && component.get("v.PopupButtonValue") == false) {
    this.popUpHelper(component, "Event");
  }
},
isELCPopUpVisible : function(component,metadata,index){
  //For selected Category and Type, validate if ELC Pop to be shown based on metadata field Core_MDF_Enable_ELC_Reminder__c
  //[ ELC Pop to be shown if Core_MDF_Enable_ELC_Reminder__c is set to true]
  if (metadata[index].Core_MDF_Enable_ELC_Reminder__c && component.get("v.ELCPopupButtonValue") == false && component.get("v.PopupButtonValue") == true) {
    this.popUpHelper(component, "ELC");
  }
},
  validateKPIValues: function (component) {
  var lwccomp = component.find("kpiFields");
  if (lwccomp != null && lwccomp.isFormValid()) {
    return true;
  } else if (lwccomp != null && !lwccomp.isFormValid()) {
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
      component.set("v.isKPISet", true);
        if(isMetricsFieldModified) { // if metrics field modified retrigger approval process
          this.retriggerApprovalIfMetricModified(component); // Planned Activity to go back to Pending Review if metrics field is edited
        }
    }
  }
},
  retriggerApprovalIfMetricModified: function (component) {
    // Planned Activity to go back to Pending Review if metrics field is edited
    if ($A.get("$Label.c.Core_MDF_CCP_Planned_Status") == component.get("v.newPFR.Core_MDF_Fund_Request_Status__c")) {
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
    return (status == 'In-Progress' && auditorper);
  },
  kpiFieldStatusForrsmReviewer: function (component) {
    var rsmActivityReviewerper = component.get("v.rsmActivityReviewerper");
    var status = component.get("v.CurrentStatus");
    return (status == 'Pending Review' && rsmActivityReviewerper && !component.get("v.activityInApproval"));
  },
  // KPI enable/disable fields
verifyKPIEditability: function (component) {
    var enableKPI = false; // False --> Field Disable and True --> Field Enable
    if (this.kpiFieldStatusForAccMngr(component) || this.kpiFieldStatusForAuditor(component) || this.kpiFieldStatusForrsmReviewer(component)) {
      enableKPI = true;
    }
  return enableKPI;
},

// end KPI field disability code

// Helper Called from Popup
popUpHelper: function (component, popuptype) {
  if (popuptype == "Event") {
    //&& component.get("v.SelectedStatus") != "Cancelled"
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
    //&& component.get("v.SelectedStatus") != "Cancelled"
    component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
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
          if (isChannelPartner == true && (seltype == $A.get("$Label.c.Core_MDF_Channel_Partner_Website_Online_Ad") ||
                  seltype == $A.get("$Label.c.Core_MDF_Channel_Partner_Owned_Event") ||
                  seltype == $A.get("$Label.c.Core_MDF_Channel_Partner_Participation_in_Third_Party_Event"))) {
              component.set("v.IsCP", true);
              component.set("v.CPLed", true);
              component.set("v.SelChannelPartner", '');
              component.set("v.SelOtherChannelPartner", '');
              component.set("v.IsOtherCP", false);
              //disablecheck =true;
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
              /*if(component.get("v.recordId") != null && component.get("v.checkCloneAttribute") == false && !disablecheck){
                      component.set("v.disabledMap.cpled",isChannelPartner);
                  }else{
                      component.set("v.disabledMap.cpled",!isChannelPartner);
                  }*/
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
          else { //if (fldname == pickListFields[0]){
              
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
          }
          if (fldname == "Core_MDF_Country_nm___c") {
              component.set("v.Countries", ParPickField);               
          }
          if (fldname == "Core_MDF_TargetAudience__c") {
              component.set("v.TargetAudience", ParPickField);
          }
         //Country Multi Select All Options
          if (fldname == "Core_MDF_Country_nm__c") {
            //component.set("v.AllCountryOptions", ParPickField);
             component.set("v.CountryPicklistValues", ParPickField);
            this.localizeCountry(component, ParPickField);
          }
          //Reimbursement Rate picklist values assignment
          if(fldname == "Core_MDF_Reimbursement_Rate_pct__c"){        
              component.set("v.ReimbursementRateVal",ParPickField);
          }    
                     
           else if (fldname == "Core_MDF_ProductType__c") {
              component.set("v.ProductTypes", ParPickField);  
               
          }
          //Activity Type as parent field for Event Format
    if (fldname == "Core_MDF_Activity_Types__c") {
      component.set("v.ActivityTypes", ParPickField);
    }


      } // Child picklist field construction
      else {
          
          if (fldname == "Core_MDF_Activity_Types__c") {
              component.set("v.ActivityTypes", childPickField);
              this.fetchActType(component);          
		  }
          if (fldname == "Core_MDF_Activity_SubType_nm__c") {
			component.set("v.activityMultiSelSubType", childPickField);
			this.fetchActSubTypeMulti(component);
		  }

          if (fldname == "Core_MDF_ProductType__c") {
              component.set("v.ProductTypes", childPickField);               
              this.fetchProdType(component);
          }

          if (fldname == "Core_MDF_Brand__c") {
              component.set("v.BrandTypes", childPickField);
              this.fetchBrandType(component);
          }
    if (fldname == "Core_MDF_Event_Format_Nm__c") {
        component.set("v.eventFormats", childPickField);
        component.set("v.setEventFormatOptionOnload", true);
        this.fetchEventFormat(component);
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
      for (var key in subTypelocalizedMap) {
        if (key == subTypeOptions[index].value) {
          labelapimap.push({
            "label": subTypelocalizedMap[key],
            "value": key
          });
          break;
        }
      }
    }

    return labelapimap;
    //component.set("v.activitySubTypeValues", labelapimap);

},
  
//fetching the activity type values
//Called upon on change of Activity Type and from activity picker function on load of the activity page
fetchActType: function (component) {
  //getting the dependent activity type picklist values by passing the controlling Activity Category value     
  var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelCategory"), component.get("v.ActivityTypes"));
  component.set("v.ActivityTypeValues", childValuesReturn);

},

//fetching the activity sub type values 
//Called upon on change of Activity Type and from activity picker function
fetchActSubTypeMulti: function (component) {
    var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelActivityType"), component.get("v.activityMultiSelSubType"));
    if (childValuesReturn != undefined && !$A.util.isEmpty(childValuesReturn) && childValuesReturn.length > 1) {
      if (this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_Retail"))) {
        component.set("v.activitySubTypeAvailable", true);
        var localizedval = this.localizeSubType(component, childValuesReturn);
        component.set("v.activitySubTypeValues", localizedval);
        // component.set("v.activityMultiSubTypeVal", childValuesReturn);
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
  
//fetching the event format values    
fetchEventFormat: function (component) {
  var metadata = [];
  var metadata = component.get("v.metadataMap");
  component.set("v.enableEventFormat", false);
  //component.set("v.selectedEventFormat", null);
  for (var index = 0; index < metadata.length; index++) {
    // Checking the condition for the Question and Pop-up beased on metadata map
    if (metadata[index].Category__c == component.get("v.SelCategory") && metadata[index].Type__c == component.get("v.SelActivityType") &&
      metadata[index].Record_Type_Picklist__c == component.get("v.recordtypeDeveloperName") && metadata[index].Core_MDF_Enable_Event_Format_Ind__c) {
      component.set("v.enableEventFormat", true);
      //component.set("v.selectedEventFormat", null);
      break;
    } else {
      component.set("v.enableEventFormat", false);
    }
  }

  if (component.get("v.enableEventFormat") || component.get("v.setEventFormatOptionOnload")) {
     //getting the dependent event format picklist values by passing the controlling Activity Type value
    var childValuesReturn = this.setChildPicklistValues(component, component.get("v.SelActivityType"), component.get("v.eventFormats"));
    component.set("v.eventFormatValues", childValuesReturn);
  }
},
 
  fetchPOPReqInfo: function (component) {
    var popMetadata = [];
    component.set("v.autoPopulatePOP", "");
    popMetadata = component.get("v.metadataMap");
    if (popMetadata.length != null && !$A.util.isEmpty(popMetadata)) {
      for (var index = 0; index < popMetadata.length; index++) {
        if (component.get("v.SelCategory") != null && component.get("v.SelActivityType") != null &&
          component.get("v.recordtypeDeveloperName") == popMetadata[index].Record_Type_Picklist__c &&
          popMetadata[index].Category__c == component.get("v.SelCategory") && popMetadata[index].Type__c == component.get("v.SelActivityType") &&
          (popMetadata[index].Core_MDF_POP_Requirements_txt__c != undefined || popMetadata[index].Core_MDF_POP_Requirements_txt__c != null)) {
          var labelPOP = popMetadata[index].Core_MDF_POP_Requirements_txt__c;
          var label2 = $A.getReference("$Label.c." + labelPOP);
          component.set("v.autoPopulatePOP", label2);
        }
      }
    }
  },
  
  resetHelper: function (component) {
     // alert("Here1--->");
      component.set("v.Uploadfinished", false);
      component.set("v.PopupButtonValue", false);
      component.set("v.ELCPopupButtonValue", false);
      component.set("v.PopupType", null);
      component.set("v.ContentDocumentIds", null);
      component.set("v.renderPrintQuestion", false);
      component.set("v.renderGovtQuestion", false);
component.set("v.renderTechExplorationQuestSection", false);
      component.set("v.checkfileuploadcondition", false);
      component.set("v.checkbudgetcondition", false);
      component.set("v.recordApplicableForActivityRules", true);
      //Variable Reimbursement Rate changes
  component.set("v.renderVRQuestion", false);
      this.fileUploadMandatoryAndEventFormVisibility(component);
      
  },
  fileUploadMandatoryAndEventFormVisibility : function(component){
    if(component.get("v.SelCategory") == (component,$A.get("$Label.c.Core_MDF_Activity_Category_Event"))){
        component.set('v.isEventFormTemplateVisible',true);
    }else{
        component.set('v.isEventFormTemplateVisible',false);
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
            ((component.get("v.SelCategory") == $A.get("$Label.c.Core_MDF_Activity_Category_Event")) || 
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
  //var permissionSetName = 'Core_MDF_CCP_Internal_Account_Manager';
      //var permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Account_Manager_CCF_DCF");
  var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");
  //permissionsetArray = permissionSetName.split(",");
      var hasPerSet = component.get("v.accmgrper");
      var mapVar = [];
      var frstatus = component.get("v.CurrentStatus");
      var actgry = component.get("v.SelCategory");

      /*var action = component.get("c.userHasPermissionSet");
      action.setParams({
              "perset": permissionsetArray
          });    
      $A.enqueueAction(action);
      */

      if (hasPerSet == true) {
          var cpLed = true;
          var isCP = component.get("v.IsCP");
          if (isCP) {
              cpLed = false;
          }

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
              'cpled': cpLed,
              'cp': false,
              'ocp': false,
              'attachement': false,
              'questions': false,
              'jointcontent': false,               
              'reimbursement' : false, //Reimbursement Rate
              'priority' : false,
      //Variable Reimbursement Rate changes
      'vrquestions': false,
      'eventFormat' : false
          };

          /*if ((frstatus == 'Pending Review' || frstatus == 'Planned' || frstatus == 'Revision Required')
            && actgry == 'Event' && bugamt >= 100000)
         {
            mapVar.sdate = false;
            mapVar.edate = false;
            mapVar.budget = false;
            mapVar.attachement = false;
            component.set("v.ApprovalException", false);
         }
         else*/
//Fields editable In-Progress Event Activity 
    if (
      frstatus == "In-Progress" &&
      actgry == "Event" &&
      this.budgetAmountThresholdCheck(component)
    ) {
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
              mapVar.edate = false;
              mapVar.questions = true;
              mapVar.jointcontent = false;                
              mapVar.reimbursement = true; //Reimbursement Rate
              mapVar.priority = true; //Priority
  mapVar.vrquestions = true;
  mapVar.eventFormat = false;
              component.set("v.ApprovalException", true);
              //component.set("v.SelectedStatus", 'In-Progress');
          } else if(!$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)){
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
                  //component.set("v.cpled",true);
                  mapVar.reimbursement = true; //Reimbursement Rate
                  mapVar.priority = true; //Priority
      mapVar.vrquestions = true;
              mapVar.eventFormat = false;
                  component.set("v.ApprovalException", true);
                  //component.set("v.SelectedStatus", 'In-Progress');
          }
         // else if(!$A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)){
          /*Activity status is planned and program is CCF/DCF/SPCF/CCFB */ 
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
              }/*Activity status is Closed and program is CCF/DCF/SPCF/CCFB */ 
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
                  //component.set("v.cpled",true);
                  component.set("v.ApprovalException", true);
                  //component.set("v.SelectedStatus", 'In-Progress');
  
              }
         }else if($A.get("$Label.c.Core_MDF_PFR_Retail").includes(recordTypeDeveloperName)){
               /*Activity status is planned and program is Retail Marketing Funds */ 
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
                  mapVar.type = false;
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
        /*Activity status is planned and program is Retail Marketing Funds */
              
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
                  component.set("v.ApprovalException", true);
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
                  //component.set("v.cpled",true);
                  component.set("v.ApprovalException", true);
                  //component.set("v.SelectedStatus", 'In-Progress');
  
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
      var mapVar = [];
      mapVar = {
        frstatus: true,
        name: true,
        desc: true,
        sdate: true,
        edate: true,
        budget: true,
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
        reimbursement: true, //Reimbursement Rate
        priority: true,
        //Variable Reimbursement Rate changes
        vrquestions: true,
        eventFormat: true
      };
        
      //If User is RMF Reviewer, then validate if Emea Activity is already in Approval Queue,If in Approval Queue no fields are editable else all fields are ditable
      isInApprovalQueue = component.get("v.activityInApproval");
      if (!isInApprovalQueue && frstatus == $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview") &&
          $A.get("$Label.c.Core_MDF_ActReviewRequiredGeos").includes(component.get("v.oldPFR.Core_MDF_Region_cd__c"))) { 
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
                  mapVar.reimbursement = true;
        mapVar.vrquestions = true;
      mapVar.eventFormat = true;
                  component.set("v.ApprovalException", true);
              }
              component.set("v.disabledMap", mapVar);
          
          }
          /*action.setCallback(this, function(response) {
              hasPerSet = response.getReturnValue();
  
              
          });  
          */
      },
  /*Test code end*/
  //Disable fields if its an auditor
  SetAuditorDisabledState: function (component, bugamt, recordTypeDeveloperName) {
      var permissionsetArray = [];
      //var permissionSetName = $A.get("$Label.c.Core_MDF_CCP_ClaimCase_Reviewer_Manager");
      //permissionsetArray = permissionSetName.split(",");
      var hasPerSet = component.get('v.auditorper');
      var mapVar = [];
      var frstatus = component.get("v.CurrentStatus");

      /*var action = component.get("c.userHasPermissionSet");
      action.setParams({
              "perset": permissionsetArray
          });    
      $A.enqueueAction(action);
      */

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
      'eventFormat' : true
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
          } else if (frstatus == 'Planned') {
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
          }
          component.set("v.disabledMap", mapVar);
      }

      /*action.setCallback(this, function(response) {
          hasPerSet = response.getReturnValue();
          
      });  
      */
  },

  // Function to control External users edit scenarios.
  SetExternalDisabledState: function (component, bugamt, recordTypeDeveloperName) {
      var permissionsetArray = [];
      //var permissionSetName = 'Core_MDF_CCP_External_Activity_Submitter';
      //var permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_CCF_DCF");
      //permissionsetArray = permissionSetName.split(",");
      var hasPerSet = component.get('v.externalper');
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
      'eventFormat' : false
          };

          /*if ((frstatus == 'Pending Review' || frstatus == 'Planned' || frstatus == 'Revision Required')
            && actgry == 'Event' && bugamt >= 100000)
         {
            mapVar.sdate = false;
            mapVar.edate = false;
            mapVar.budget = false;
            mapVar.attachement = false;
            component.set("v.ApprovalException", false);
         }
         else*/
          if (frstatus == 'In-Progress') {
              mapVar.edate = false;
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
      mapVar.priority = true; //Priority
      mapVar.vrquestions = true;
      mapVar.eventFormat = true;
              component.set("v.ApprovalException", true);
              //component.set("v.SelectedStatus", 'In-Progress');
    } else if (
                frstatus == "Revision Required" && 
                ((
                  this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) &&
                  this.budgetAmountThresholdCheck(component)
                ) 
                ||
                (
                  this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
                )) 
              )  
      {
      //If Event or Content Creation Activity is Revision Required enable below fields for edititng
      mapVar.acct = true;
      this.setFileUploadForUser(component);

    } else if (
                frstatus == "Planned" &&
                this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) &&
                this.budgetAmountThresholdCheck(component)
              )
      {
      //If Event Category edited in Planned status enable below fields as below based on program
              mapVar.attachement = true;
      mapVar.frstatus = true;
      mapVar.name = true;
      mapVar.desc = true;
      //mapVar.sdate = true;
      mapVar.budget = true;
      mapVar.cmpgn = true;
      mapVar.acct = true;
      mapVar.country = true;
      mapVar.audience = true;
      //mapVar.prodtype = true;
      //mapVar.brand = true;
      mapVar.category = true;
      //mapVar.type = true;
      //mapVar.cpled = true;
      //mapVar.cp = true;
      //mapVar.ocp = true;
      mapVar.edate = false;
      mapVar.questions = true;
      mapVar.jointcontent = true;
      mapVar.priority = true; //Priority
      if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")) {
        mapVar.vrquestions = false;
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
        mapVar.vrquestions = false;
        mapVar.prodtype = true;
        mapVar.brand = false;
        mapVar.sdate = false;
        mapVar.type = true;
        mapVar.eventFormat = false;
        mapVar.cpled = true;
        mapVar.cp = true;
        mapVar.ocp = true;
      } else if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")){
        mapVar.vrquestions = true;
        mapVar.prodtype = true;
        mapVar.brand = true;
        mapVar.sdate = true;
        mapVar.type = true;
        mapVar.eventFormat = false;
        mapVar.cpled = true;
        mapVar.cp = true;
        mapVar.ocp = true;
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
    }
    else if( 
              frstatus == "Planned"  &&
              this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))
            ){
              this.setFileUploadForUser(component);
           }
    component.set("v.disabledMap", mapVar);
  }
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

  if(this.isRetailActivitywithApplicableFieldModified(component) ||
      this.isPendingReviewOrRevisionRequiredActivity(component) ||
    ((this.isContentCreationActivity(component) ||
        this.isActivityEventAboveAmountThresholdwithApplicableFieldModified(component)) &&
     !this.checkRecordTypeSelected(component, $A.get("$Label.c.Core_MDF_PFR_Retail")))){ 
      
      component.set("v.newPFR.Core_MDF_Fund_Request_Status__c", $A.get("$Label.c.Core_MDF_PFR_Status_PendingReview"));
      component.set("v.newPFR.Core_MDF_Approval_Step_Completed__c", 0); 

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
//Method to Check if Activity Status is Pending Review or Revision Required
isPendingReviewOrRevisionRequiredActivity : function(component){ 
  
  //Check if User edits a Revision Required or Pending Review Activity
  //Core_MDF_PFR_Status_RevisionRequiredOrPendingReview - Pending Review, Revision Required

  return($A.get("$Label.c.Core_MDF_PFR_Status_RevisionRequiredOrPendingReview").includes(component.get("v.oldPFR.Core_MDF_Fund_Request_Status__c")));
},

//If User modifies  Event Activity Type, Requested Amount above 50000  modifies fields --> Activity Type , 
//Activity Category , Amount, Start Date or file updated 
isActivityEventAboveAmountThresholdwithApplicableFieldModified : function(component){
  
  //Core_MDF_Field_Eligble_For_Approval_CcfDcfSpcfCcfb--> Core_MDF_Activity_Types__c,Core_MDF_ActivityCategory__c,RequestedAmount,Core_MDF_Start_Date__c
  var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Eligble_For_Approval_CcfDcfSpcfCcfb");
  var fileUpdated = component.get("v.ChgndAttach"); 
  
  if(this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) && !this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Promotion")) &&  this.budgetAmountThresholdCheck(component) &&
     (this.fieldEligibleForApprovalModified(component,editedFieldRequiresApproval) || fileUpdated)){
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
  return (component.get("v.newPFR.Core_MDF_ActivityCategory__c") ==  $A.get("$Label.c.Core_MDF_Activity_Category_Event"));

},
//Method to check if field modified needs to trigger Approval
fieldEligibleForApprovalModified : function(component,editedFieldRequiresApproval){
  
  var editableField = editedFieldRequiresApproval.split(',');

  for(var fieldName  in  editableField){

    var oldFieldValue = "v.oldPFR."+editableField[fieldName]; 
    var newFieldValue = "v.newPFR."+editableField[fieldName];
    
    if(component.get(oldFieldValue) != component.get(newFieldValue)){
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
//Check if Activity is Retail
isRetailActivitywithApplicableFieldModified : function(component){
  //Returns true when User   
  //Core_MDF_Field_Editable_Retail-->RequestedAmount,Core_MDF_Start_Date__c,Core_MDF_End_Date__c,Core_MDF_Country_nm__c,Core_MDF_ProductType__c,Core_MDF_Brand__c,Core_MDF_TargetAudience__c
  var editedFieldRequiresApproval = $A.get("$Label.c.Core_MDF_Field_Editable_Retail");

  if(this.checkRecordTypeSelected(component,$A.get("$Label.c.Core_MDF_PFR_Retail")) && 
     this.fieldEligibleForApprovalModified(component,editedFieldRequiresApproval)){
      return true;
    }else{
      return false;
    }
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

    } else if (component.get("v.Uploadfinished") == true || component.get("v.PopupType") == "" || component.get("v.checkbudgetcondition") == false ||       (!component.get("v.recordApplicableForActivityRules") && component.get("v.checkbudgetcondition"))) {

      if (this.validateKPIValues(component)) {

        this.setKPIValues(component);
        this.saveHelperMethod(component, component.get("v.newPFR"));

    }
  }
},

//Check if Activty is Content Creation or Event
checkIfEventOrContentActivity : function(component){

  //Core_MDF_Activity_Category_Event - Event 
  //Core_MDF_Activity_Category_Digital_Media - Digital Media
  //Core_MDF_Activity_Type_Content_Creation - Content Creation isEventActivity
  if(this.validateActivityCategory(component,$A.get("$Label.c.Core_MDF_Activity_Category_Event")) ||
      this.validateActivityType(component,$A.get("$Label.c.Core_MDF_Activity_Type_Content_Creation"))){
      return true;
    }else{
      return false;
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
      alert('ERROR OCCURED.');
    }
  });
  $A.enqueueAction(action);
},
  
  //Helper called on change of Budget Amount Local to Calculate Budget Amount USD
   calculateBudgetAmount: function (component, newPFR) {
  component.set("v.showSpinner",true);
  component.set("v.isSaveDisable", true);
  component.set("v.isSaveandNewDisable", true);
  var action = component.get("c.budgetAmountCalculatePFR");
          //pass oldcurrency param
  action.setParams({
    createdDateCloneFlag: component.get("v.createdDateClone"),
    pfr: newPFR
  });
          
          action.setCallback(this, function (response) {
              if (response.getState() == "SUCCESS") {
                  var exchangeRateConvertedAmountWrap = response.getReturnValue();
      if (exchangeRateConvertedAmountWrap != null && exchangeRateConvertedAmountWrap.exchangeRate != null && exchangeRateConvertedAmountWrap.usdBudgetAmount != null) {
          component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateConvertedAmountWrap.exchangeRate);
                      component.set("v.newPFR.RequestedAmount", exchangeRateConvertedAmountWrap.usdBudgetAmount);
                      component.set("v.BudgetException", false);
                       component.set("v.budgetCurrencyOld",component.get("v.newPFR.Core_MDF_Budget_Currency_cd__c")); 
          			}else{
                      component.set("v.BudgetException", true); 
                  }
     component.set("v.showSpinner",false);
                 component.set("v.isSaveDisable", false);
                 component.set("v.isSaveandNewDisable", false);
              } else if (response.getState() == "ERROR") {
                  component.set("v.BudgetException", true);
              }
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
  // If : - New and Clone and Local Amount is not call
  if(component.get("v.checkCloneAttribute") || $A.util.isEmpty(component.get("v.newPFR.Id")) || $A.util.isEmpty(component.get("v.recordId"))){
    // If : - Not USD and Not Currency empty
    if(component.get("v.budgetCurrency") != "USD"){
      this.calculateBudgetAmount(component, component.get("v.newPFR"));
    }else{ // Else : - USD Currency //not need to call Server Method // Local Amount is not null 
        component.set("v.newPFR.RequestedAmount", component.get("v.BudgetLocal"));
        component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", 1);
    }
  // Else: - Edit scenario (change is present in either amount and currency)    
  }else if(parseFloat(oldLocalAmount) != parseFloat(component.get("v.BudgetLocal")) || (oldCurrency != component.get("v.budgetCurrency"))
  ){
    this.recalculateBudgetAmount(component);
  }else if(parseFloat(oldLocalAmount) == parseFloat(component.get("v.BudgetLocal")) && (oldCurrency == component.get("v.budgetCurrency"))){
    component.set("v.newPFR.RequestedAmount", component.get("v.oldPFR.RequestedAmount"));
    component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", component.get("v.oldPFR.Core_MDF_Exchange_Rate_ptc__c"));
    component.set("v.newPFR.Core_MDF_Budget_Amount_Local_amt__c", component.get("v.oldPFR.Core_MDF_Budget_Amount_Local_amt__c"));
  }
},
// Recalculate Budget Amount 
recalculateBudgetAmount : function (component) {
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
          }else{ // Else throw error "System failed to get the Data"
             exchangeRateError = true; 
          }
  }else{ // Else throw error "System failed to get the Data"
          exchangeRateError = true;
  }
component.set("v.showSpinner",false);
      component.set("v.isSaveDisable", false);
      component.set("v.isSaveandNewDisable", false);
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
}
})