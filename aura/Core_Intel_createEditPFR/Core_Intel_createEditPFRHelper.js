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
        if (recordtype == $A.get("$Label.c.Core_MDF_PFR_DCF")) { //DCF_Label){
            sFilter = "RecordType.DeveloperName = \'Core_MDF_Data_Center_CoMarketing_Fund\'";
            aFilter = "RecordType.DeveloperName= \'Core_MDF_Co_Marketing\' AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c='" + DCF_NonTranslateLabel + "'";

        } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_CCF")) { //CCF_Label){
            sFilter = "RecordType.DeveloperName = \'Core_MDF_Client_CoMarketing_Fund\'";
            aFilter = "RecordType.DeveloperName= \'Core_MDF_Co_Marketing\' AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c='" + CCF_NonTranslateLabel + "'";

        } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_SPCF")) { //SPCF_Label
            sFilter = "RecordType.DeveloperName = \'Core_MDF_Service_Provider_CoMarketing_Fund\'";
            aFilter = "RecordType.DeveloperName= \'Core_MDF_Co_Marketing\' AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c='" + SPCF_NonTranslateLabel + "'";
        } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_Retail")) { //Retail_Label
            
            //sFilter = "RecordType.DeveloperName = \'Core_MDF_Retail_CoMarketing_Fund\'";
            sFilter = "RecordType.DeveloperName = \'Core_MDF_Retail_Marketing_Funds\'";
           
            //aFilter = "RecordType.DeveloperName= \'Core_MDF_Co_Marketing\' AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c='" + Retail_NonTranslateLabel + "'";
             //aFilter = "id = '"+campaignAccount+"'";
        } else if (recordtype == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")) { //CCF Boost_Label
            sFilter = "RecordType.DeveloperName = \'Core_MDF_Client_CoMarketing_Fund_Boost\'";
            aFilter = "RecordType.DeveloperName= \'Core_MDF_Co_Marketing\' AND isPartner=true AND Core_MDF_Active_Ind__c = true AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c='" + CCF_Boost_NonTranslateLabel + "'";
        }
        // constructing the filer -- date
        if (sFilter != null) {
            if ((startdate != null) && (enddate != null) && (enddate >= startdate)) {
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
            	
        })
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
        var metadata = [];
        var metadata = component.get("v.metadataMap");
        var callsave = true;
        var elcpopup = false;
        var checkforloop = true;

        for (var i = 0; i < metadata.length; i++) {

            // Checking the condition for the Question and Pop-up beased on metadata map
            if (metadata[i].Category__c == component.get("v.SelCategory") && metadata[i].Type__c == component.get("v.SelActivityType")
                //&& metadata[i].Budget_Amount__c <= component.get("v.newPFR.RequestedAmount")
                &&
                metadata[i].Record_Type_Picklist__c == component.get("v.recordtypeDeveloperName")) { //metadata[i].RecordType_Name__c == component.get("v.recordtypeName")

                callsave = false;
                if (component.get("v.newPFR.RequestedAmount") >= metadata[i].Budget_Amount__c) {
                    component.set("v.checkbudgetcondition", true);
                }

                if (metadata[i].Print__c || metadata[i].Govt_Nexus_Flag__c || metadata[i].Core_MDF_Enable_File_Upload__c ||
                    metadata[i].Enable_Event_Popup__c || metadata[i].Core_MDF_Enable_ELC_Reminder__c) {

                    if (metadata[i].Print__c && component.get("v.renderPrintQuestion") == false) {
                        component.set("v.renderPrintQuestion", metadata[i].Print__c);
                        component.set("v.renderGovtQuestion", false);

                    }
                    if (metadata[i].Govt_Nexus_Flag__c && component.get("v.renderGovtQuestion") == false) { // Areefa removied :&& component.get("v.checkbudgetcondition") as part of US288852
                        component.set("v.renderGovtQuestion", metadata[i].Govt_Nexus_Flag__c);
                        component.set("v.renderPrintQuestion", false);
                    }
                    if (metadata[i].Core_MDF_Enable_File_Upload__c && component.get("v.checkbudgetcondition") && component.get("v.checkfileuploadcondition") == false) {
                        component.set("v.checkfileuploadcondition", true);

                    }

                    if (metadata[i].Enable_Event_Popup__c && component.get("v.PopupButtonValue") == false) {

                        this.popUpHelper(component, "Event");
                    }

                    if (metadata[i].Core_MDF_Enable_ELC_Reminder__c && component.get("v.ELCPopupButtonValue") == false && component.get("v.PopupButtonValue") == true) {
                        this.popUpHelper(component, "ELC");
                    }
                    /*if(saverecord){
                        component.set("v.PopupType","");
                        this.saveHelperMethod(component,component.get("v.newPFR"));
                    }*/
                    checkforloop = false;
                } else {
                    component.set("v.PopupType", "");
					//Variable Reimbursement Rate changes
					if (goforsave == true) {
                    this.saveHelperMethod(component, component.get("v.newPFR"));
					}
                }

            }
            if (!checkforloop) {
                component.set("v.checkifcondition", false);
                break;
            }
        }
        //end forloop
        //Variable Reimbursement Rate changes
		//if (callsave) {
		if (callsave == true && goforsave == true) {
            component.set("v.PopupType", "");
            this.saveHelperMethod(component, component.get("v.newPFR"));
        }

    },
    // Helper Called from Popup
    popUpHelper: function (component, popuptype) {

        if (popuptype == "Event") { //&& component.get("v.SelectedStatus") != "Cancelled"
            component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_EventReminder1"));
            component.set("v.AgreeButtonLabel", $A.get("$Label.c.Core_MDF_I_Understand"));
            component.set("v.DisagreeButtonLabel", $A.get("$Label.c.Core_MDF_CancelOption"));
            component.set("v.PopupType", popuptype);
            component.set("v.ShowEventPopup", true);
        }
        if (popuptype == "ELC") { //&& component.get("v.SelectedStatus") != "Cancelled"
            component.set("v.EventMessage", $A.get("$Label.c.Core_MDF_Terms"));
            component.set("v.AgreeButtonLabel", $A.get("$Label.c.Core_MDF_I_Understand"));
            component.set("v.DisagreeButtonLabel", $A.get("$Label.c.Core_MDF_CancelOption"));
            component.set("v.PopupType", popuptype);
            component.set("v.ShowEventPopup", true);
        }
    },

    // Functions to enable channel partner
    EnableCPCheckBox: function (component, event) {
        var disablecheck = false;
        var isChannelPartner;
        var seltype = component.get('v.SelActivityType');
        var selcategory = component.get('v.SelCategory');
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
                    } else {
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
           
            for (var i = 0; i < res.length; i++) {
                var keyvalue = res[i].split(":");
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
            if(fldname == "Core_MDF_Country_nm__c")
            {   
                component.set("v.AllCountryOptions",ParPickField);
                component.set("v.CountryPicklistValues",ParPickField)
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
    
    fetchActType: function (component) {

        var key = component.get("v.SelCategory");
        var Mapopts = component.get("v.ActivityTypes");
        var optstorender = new Array();
        var MapVar = new Array();
        if (Mapopts != null) {
            //None to be set at optstorender at index 0
            MapVar = Mapopts[key];
            if (optstorender.length == 0) {
                optstorender.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: ""
                });
            }
            if (MapVar != null) {
                for (var i = 0; i < MapVar.length; i++)
                    optstorender.push({
                        class: "optionClass",
                        label: MapVar[i].label,
                        value: MapVar[i].value
                    });

            }

            component.set("v.ActivityTypeValues", optstorender);

        }
    },
    fetchProdType: function (component) {
        var key = component.get("v.SelTargetAudience");
        var Mapopts = component.get("v.ProductTypes");
        var optstorender = new Array();
        var MapVar = new Array();
        if (Mapopts != null) {
            MapVar = Mapopts[key];
            if (optstorender.length == 0) {
                optstorender.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: ""
                });
            }
            if (MapVar != null) {
                for (var i = 0; i < MapVar.length; i++)
                    optstorender.push(MapVar[i]);
            }
            component.set("v.ProductTypeValues", optstorender);
        }
    },
    fetchBrandType: function (component) {
        var key = component.get("v.SelProductType");
        var Mapopts = component.get("v.BrandTypes");
        var optstorender = new Array();
        var MapVar = new Array();
        if (Mapopts != null) {
            MapVar = Mapopts[key];
            if (optstorender.length == 0) {
                optstorender.push({
                    class: "optionClass",
                    label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                    value: ""
                });
            }
            if (MapVar != null) {
                for (var i = 0; i < MapVar.length; i++)
                    optstorender.push(MapVar[i]);
            }
            component.set("v.BrandValues", optstorender);
            //alert('optstorender'+JSON.stringify(optstorender));
        }
    },
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
      }else{
        component.set("v.enableEventFormat", false);
      }
    }

    if (component.get("v.enableEventFormat") || component.get("v.setEventFormatOptionOnload")) {
      var key = component.get("v.SelActivityType");
      var Mapopts = component.get("v.eventFormats");
      var optstorender = new Array();
      var MapVar = new Array();
      if (Mapopts != null) {
        MapVar = Mapopts[key];
        if (optstorender.length == 0) {
          optstorender.push({
            class: "optionClass",
            label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
            value: ""
          });
        }
        if (MapVar != null) {
          for (var i = 0; i < MapVar.length; i++) optstorender.push(MapVar[i]);
        }
        component.set("v.eventFormatValues", optstorender);
      }
    }
  },
    resetHelper: function (component) {
        //alert("Here1--->");
        component.set("v.Uploadfinished", false);
        component.set("v.PopupButtonValue", false);
        component.set("v.ELCPopupButtonValue", false);
        component.set("v.PopupType", null);
        component.set("v.ContentDocumentIds", null);
        component.set("v.renderPrintQuestion", false);
        component.set("v.renderGovtQuestion", false);
        component.set("v.checkfileuploadcondition", false);
        component.set("v.checkbudgetcondition", false);
        component.set("v.checkifcondition", true);
        //Variable Reimbursement Rate changes
		component.set("v.renderVRQuestion", false);
        
    },
    SetAccMgrDisabledState: function (component, bugamt, recordTypeDeveloperName) {
        var permissionsetArray = [];
        //var permissionSetName = 'Core_MDF_CCP_Internal_Account_Manager';
        //var permissionSetName = $A.get("$Label.c.Core_MDF_CCP_Account_Manager_CCF_DCF");
		var recordTypeDeveloperName = component.get("v.recordtypeDeveloperName");

        var CCFBudgetHundredK = false; // Areefa: created custom label for 100k hardcoded value
        var DCFBudgetHundredK = false;
        var SPCFBudgetHundredK = false;
        var CCFBoostBudgetHundredK = false;

        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_CCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")) {
            CCFBudgetHundredK = true;
        }
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_DCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) {
            DCFBudgetHundredK = true;
        }
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_SPCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF")) {
            SPCFBudgetHundredK = true;
        }
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_CCFB_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")) {
            CCFBoostBudgetHundredK = true;
        }
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
            if (frstatus == 'In-Progress' && actgry == 'Event' &&
                (CCFBudgetHundredK || DCFBudgetHundredK || SPCFBudgetHundredK || CCFBoostBudgetHundredK)) {
                mapVar.attachement = false;
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
                mapVar.edate = false;
                mapVar.questions = true;
                mapVar.jointcontent = true;                
                mapVar.reimbursement = true; //Reimbursement Rate
                mapVar.priority = true; //Priority
				mapVar.vrquestions = true;
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
                    mapVar.jointcontent = true;
                    //component.set("v.cpled",true);
                    mapVar.reimbursement = true; //Reimbursement Rate
                    mapVar.priority = true; //Priority
					mapVar.vrquestions = true;
          mapVar.eventFormat = true;
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
                }
               /*Activity status is planned and program is Retail Marketing Funds */ 
                else if (frstatus == 'Planned') {
                   // alert('here');
                    mapVar.edate = false;
                    mapVar.desc = false;
                    mapVar.budget = false;
                    mapVar.country = false;
                    mapVar.frstatus = false;
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
                    component.set("v.ApprovalException", true);
                }
                /*Activity status is Rejected and program is Retail */ 
                else if (frstatus == 'Rejected') {
               
                    mapVar.frstatus = true;
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
                    mapVar.reimbursement = true; //Reimbursement Rate
                    mapVar.priority = true; //Priority
					mapVar.vrquestions = true;
          mapVar.eventFormat = true;
                    //component.set("v.cpled",true);
                    component.set("v.ApprovalException", true);
                    //component.set("v.SelectedStatus", 'In-Progress');

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
               //Lock the fields during pending Approval status
                    else if (frstatus == 'Pending Approval') {              
                    mapVar.edate = true;
                    mapVar.desc = true;
                    mapVar.budget = true;
                    mapVar.country = true;
                    mapVar.frstatus = false;
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
                    component.set("v.ApprovalException", true);

            }
               
               
        }
            component.set("v.disabledMap", mapVar);
        
    }
        /*action.setCallback(this, function(response) {
            hasPerSet = response.getReturnValue();
            
            
        });  
        */
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
                mapVar.jointcontent = true;
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
        var actgry = component.get("v.SelCategory");

        var CCFBudgetHundredK = false; // Areefa: created custom label for 100k hardcoded value
        var DCFBudgetHundredK = false;
        var SPCFBudgetHundredK = false;
        var CCFBoostBudgetHundredK = false;
        var CCFBudget = false;
        var DCFBudget = false;
        var SPCFBudget = false;
        var CCFBoostBudget = false;
        // CCF Condition
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_CCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")) {
            CCFBudgetHundredK = true;
        } else if (bugamt < parseInt($A.get("$Label.c.Core_MDF_CCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF")) {
            CCFBudget = true;
        }
        //DCF Condition
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_DCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) {
            DCFBudgetHundredK = true;
        } else if (bugamt < parseInt($A.get("$Label.c.Core_MDF_DCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_DCF")) {
            DCFBudget = true;
        }
        //SPCF Condition                                                                   
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_SPCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF")) {
            SPCFBudgetHundredK = true;
        } else if (bugamt < parseInt($A.get("$Label.c.Core_MDF_SPCF_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_SPCF")) {
            SPCFBudget = true;
        }
        //Boost Condition
        if (bugamt >= parseInt($A.get("$Label.c.Core_MDF_CCFB_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")) {
            CCFBoostBudgetHundredK = true;
        } else if (bugamt < parseInt($A.get("$Label.c.Core_MDF_CCFB_100K_Budget_Activity")) && recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_PFR_CCF_Boost")) {
            CCFBoostBudget = true;
        }

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
            } else if (frstatus == 'Revision Required' && actgry == 'Event' &&
                (CCFBudgetHundredK || DCFBudgetHundredK || SPCFBudgetHundredK || CCFBoostBudgetHundredK)) {
                mapVar.attachement = false;
                mapVar.frstatus = false;
                mapVar.name = false;
                mapVar.desc = false;
                mapVar.sdate = false;
                mapVar.budget = false;
                mapVar.cmpgn = false;
                mapVar.acct = true;
                mapVar.country = false;
                mapVar.audience = false;
                mapVar.prodtype = false;
                mapVar.brand = false;
                mapVar.category = false;
                mapVar.type = false;
                mapVar.cpled = false;
                mapVar.cp = false;
                mapVar.ocp = false;
                mapVar.edate = false;
                mapVar.questions = false;
                mapVar.jointcontent = false;
                mapVar.priority = false; //Priority
				mapVar.vrquestions = false;
        mapVar.eventFormat = false;
                component.set("v.fileexceptionper", true);

                component.set("v.ApprovalException", true);
            } else if (frstatus == 'Planned' && actgry == 'Event' &&
                (CCFBudgetHundredK || DCFBudgetHundredK || SPCFBudgetHundredK || CCFBoostBudgetHundredK)) {
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

				component.set("v.fileexceptionper", true);

                component.set("v.ApprovalException", true);
            }
            component.set("v.disabledMap", mapVar);
        }
    },    
    //This helper function is used to fetch Currency picklist values NZ
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
                if (fieldName == component.get("v.fieldNameBudgetType")) {
					component.set("v.currBTMap", currValList);
                } else {
                    var currList = currValList;
                    //Duplicate values from being populated on picklist
                    if (!(!(component.get("v.newPFR.Id")))) {
                        for (let i = 0; i < currList.length; i++) {
                            if (currList[i].key == component.get("v.budgetCurrency")) {
                                currList.splice(i, 1);
                                break;
                            }
                        }
                    }
                    component.set("v.currMap", currList);
                }
            } else if (state === 'ERROR') {

                alert('ERROR OCCURED.');
            }

        });
        $A.enqueueAction(action);
    },
    
    //Helper called on change of Budget Amount Local to Calculate Budget Amount USD
     calculateBudgetAmount: function (component, newPFR) {
            var action = component.get("c.budgetAmountCalculatePFR");
            //pass oldcurrency param
         	action.setParams({
                "createdDateCloneFlag" :component.get("v.createdDateClone"),
                "pfr": newPFR,
                "oldBudgetCurrency": component.get("v.budgetCurrencyOld")
            });
            
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS") {
                    var exchangeRateConvertedAmountWrap = response.getReturnValue();
                    if(exchangeRateConvertedAmountWrap.exchangeRate != null && exchangeRateConvertedAmountWrap.usdBudgetAmount != null){
                        component.set("v.newPFR.Core_MDF_Exchange_Rate_ptc__c", exchangeRateConvertedAmountWrap.exchangeRate);
                        component.set("v.newPFR.RequestedAmount", exchangeRateConvertedAmountWrap.usdBudgetAmount);
                        component.set("v.BudgetException", false);
                       	component.set("v.budgetCurrencyOld",component.get("v.newPFR.Core_MDF_Budget_Currency_cd__c")); 
                        component.set("v.budgetCurrencyExchangeRate",exchangeRateConvertedAmountWrap.exchangeRate);
                    	}else{
                        component.set("v.BudgetException", true); 
                    }
                } else if (response.getState() == "ERROR") {
                    component.set("v.BudgetException", true);
                }
            }),
                
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
            }),
            $A.enqueueAction(action);
    }
})