({
	doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        console.log('pageReference--> ', pageReference);
        if(pageReference != null){
            component.set("v.recordId", pageReference.state.c__recordId);
            component.set("v.campaignCustomClone", true);
        }
        helper.isUserIPAExUser(component);
        console.log('recordId--> ', component.get("v.recordId"));
        helper.fetchRecordInfo(component, event);
        helper.isCommunity(component, event);        
		
        
	},
    fetchFieldSetInfo : function(component, event, helper) {
        if(component.get("v.recordInfoLoaded")) {
        	helper.fetchFieldSetInfo(component, event);
        }
	},
    //US1082871: [IPA MDF] - Campaign - Clone a Proposal - handle event fire from campaign lwc component and store in pfr object and call createeditpfr
    recActDetails :  function(component, event, helper) {
     
        var actID = event.getParam('actId');
        var oldPFRList = event.getParam('oldActivityListClone');
        component.set("v.oldPfrList", oldPFRList);
        if (actID != undefined && actID != null && actID != '') {
            component.set("v.activityRec", actID);
            console.log('activityRec'+JSON.stringify( component.get("v.activityRec")));          
            component.set("v.clonePFRComponent", true);

        }
	},
     closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
       component.set("v.clonePFRComponent", false);
   },

   //IPA-Jegan
   //Handle this event that's firing from Create_Campaign.js LWC Component
   handleOutcomeChange:function(component, event, helper) {
        var boolValue = event.getParam('value');
        component.set('v.outcomeBasedOptInInd', boolValue);
       console.log('outcomeBasedOptInInd::'+component.get('v.outcomeBasedOptInInd'));
        if(!component.get('v.outcomeBasedOptInInd')){
            component.set('v.activityToAttributeList', []);
        }
        helper.activityValidation(component, event);
   },

   //US1082871: [IPA MDF] - Campaign - Clone a Proposal - get record editted through event and update the main list with updated details of activity
    getActivityRecEditted: function(component, event, helper) {
        let pfrData = JSON.parse(JSON.stringify(event.getParam("detail")));
        if(pfrData != undefined && pfrData != null){
             component.set("v.pfrEditRecord", pfrData);
            if(event.getParam("buSplitDetail") != undefined && event.getParam("buSplitDetail") != null){
                //component.get("v.updatedBuSplitFormula",event.getParam("buSplitDetail"));
                component.set("v.pfrEditRecord.Core_MDF_BU_Percent_txt__c",event.getParam("buSplitDetail"));
            }
            if(event.getParam("isMetricsBlank") != undefined && event.getParam("isMetricsBlank") != null){
                component.set("v.pfrEditRecord.isBlankMetrics",event.getParam("isMetricsBlank"));
            }

            //IPA-Jegan
            if(event.getParam("isBlankTacticMetrics") != undefined && event.getParam("isBlankTacticMetrics") != null){
                //var outcomeBased = component.get('v.updatedCampaignObj.Core_MDF_CampOutcomeOpt_In_Ind__c');
                var outcomeBasedOptInInd = component.get('v.outcomeBasedOptInInd');
                component.set("v.pfrEditRecord.isBlankTacticMetrics", (outcomeBasedOptInInd ? event.getParam("isBlankTacticMetrics") : false));
            }

             component.set("v.clonePFRComponent", false);
             component.set("v.callCampaignComp", true);
            component.set("v.isIpaActEdited",true);
            var updatedActivityID ;
            var updatedAct = component.get("v.pfrEditRecord");
            var assActivity = component.get("v.pfrList");
            //Added by VB - to hide/retain the error message on top of the activity during edit of the activity - Campaign Clone
          	let oldPFRList = component.get("v.oldPfrList");
           	oldPFRList && oldPFRList.map(activityRec => {
	    	if(helper.isNotBlank(updatedAct) && activityRec.Id == updatedAct.Id) {
                 if(helper.isNotBlank(updatedAct.activityFieldAPIName) && helper.isNotBlank(updatedAct.removedPicklistValues)) {
                    //let oldValuesOnActivity = activityRec[updatedAct.activityFieldAPIName].split(';');
                    let removedPickListValues = updatedAct.removedPicklistValues
                	let newValuesOnActivity = updatedAct[updatedAct.activityFieldAPIName].split(';');
                		if(helper.isNotBlank(newValuesOnActivity) && helper.isNotBlank(removedPickListValues) && newValuesOnActivity.length > 0 && removedPickListValues.length > 0) {
                			let removedPickValFromActivity = [];
                			removedPickListValues.map(rp => {
                				if(!newValuesOnActivity.includes(rp)) {
                					removedPickValFromActivity.push(rp);
            					}
            				});
            				if(removedPickValFromActivity.length == removedPickListValues.length) {
                				updatedAct.activityReferred = false;
                            } else {
                                updatedAct.activityReferred = updatedAct.activityReferred;
                            }
            			} else {
                   			updatedAct.activityReferred = updatedAct.activityReferred;         
                		}
             		}
               }
               //for removing the mandatory field error on edit of activity fieldListWithEmptyValue
               if(helper.isNotBlank(updatedAct) && helper.isNotBlank(updatedAct.fieldListWithEmptyValue) && updatedAct.fieldListWithEmptyValue.length > 0) {
                    let fieldsWithEmptyVal = updatedAct.fieldListWithEmptyValue;
                    let isEmptyValuePresent = false;
                    fieldsWithEmptyVal.forEach(field => {
                        let picklistValues = updatedAct[field];
                        if((!helper.isNotBlank(picklistValues)) || picklistValues == []) {
                            isEmptyValuePresent = true;
                        }
                    })

                    if(!isEmptyValuePresent) {
                        updatedAct.fieldListWithEmptyValue = [];
                        updatedAct.areMandateFieldsEmpty = false;
                    }
               }
            });
	    assActivity = JSON.parse(JSON.stringify(oldPFRList));
            var holdUpdatedData = [];
            for(let i = 0; i<assActivity.length;i++){
                if(updatedAct.Id == assActivity[i].Id){
                    updatedActivityID = updatedAct.Id ;
                    holdUpdatedData.push(updatedAct);
                }else{
                    holdUpdatedData.push(assActivity[i]);
                }
            }
            component.set("v.pfrList", holdUpdatedData);

            //IPA-Jegan
            if(component.get('v.outcomeBasedOptInInd')){
                helper.formActivityToActivityAttributes(component, event);
            }
            
            if(component.get("v.recordTypeDeveloperName") ==  $A.get('$Label.c.Core_MDF_IPA_RecordType')){
                helper.activityValidation(component, event);
            }
            
               var recordTypeDeveloperName = component.get("v.recordTypeDeveloperName");
                if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && !component.get("v.proposalBasedIndicator")) {
                    helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Account_Based"));
                }
                else if (recordTypeDeveloperName == $A.get("$Label.c.Core_MDF_IPA_RecordType") && component.get("v.proposalBasedIndicator")) {
                    helper.activityPicker(component, $A.get("$Label.c.Core_MDF_IPA_Proposal_Based"));
                }
            

            var findChildComp=component.find('childCampaignCmp');
            findChildComp.callChildMethodCampaign(updatedAct,updatedActivityID);
        }
   },
   closeModalFormCampaign: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var homeEvent = $A.get("e.force:navigateToSObject");
        homeEvent.setParams({
            "recordId": pageReference.state.c__recordId
        });
        homeEvent.fire();
       $A.get("e.force:refreshView").fire();
    },
    picklistValueChangeEvent: function(component, event, helper) {
        var campPickListValues = event.getParam('picklistWrapper');
        if(campPickListValues != undefined && campPickListValues != null && campPickListValues != ''){
            component.set("v.updatedCampPicklistValues", campPickListValues);
        }

    },
    
    budgetTypeChangeEvent: function(component, event, helper) {

        var campBudgetType = event.getParam('budgetTypeChange');
        if(campBudgetType != undefined && campBudgetType != null && campBudgetType != ''){
            console.log('campCountry'+JSON.stringify(campBudgetType));
            component.set("v.updatedCampBudgetType",campBudgetType);
            
        }

    },
    
    activityValidationEvent: function(component, event, helper) {
        var activityList = [];
        var pfrToBeUpdated = event.getParam('pfrToUpdate');
        console.log('pfrToBeUpdated'+JSON.stringify(pfrToBeUpdated));
        if(pfrToBeUpdated != undefined && pfrToBeUpdated != null && pfrToBeUpdated != ''){
            activityList = component.get("v.pfrList");
            for(var i=0;i < activityList.length;i++){
                if(pfrToBeUpdated[0].Id == activityList[i].Id){
                    activityList[i].act60daysValidation = pfrToBeUpdated[0].act60daysValidation;
                    activityList[i].initiativeNoneValidation = pfrToBeUpdated[0].initiativeNoneValidation;
                }
            }
            component.set("v.pfrList",activityList);
        }
    },

    closeModalAndDisplayErrorMsg: function (component, event) {
        let closeModalEvent = component.getEvent("closeModalAndLogErrorMessageEvent");
        closeModalEvent.setParams({ errorLog: event.getParam('errorLog')})
        closeModalEvent.fire();
    },
    
    activityBlankFieldsCheckoxValidation: function(component, event, helper) {
        var activityBlankValuesFieldAPI = event.getParam('blankPFRFieldsAPINames');
        if(!$A.util.isEmpty(activityBlankValuesFieldAPI)){
            var activityBlankFieldValidationLableStr = $A.get("$Label.c.Core_MDF_BlankFieldCheckboxSelection_Error") + '\n';
            activityBlankValuesFieldAPI.forEach(fieldAPI => {
                if(fieldAPI == 'Core_MDF_Country_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Country") + '\n';
            	}
                if(fieldAPI == 'Core_MDF_Focus_Area_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Focus_Area_title") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_Priority_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Priority") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_Industry_Multi_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Industry") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_ProductType__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Product_Type") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_EcosystemPartner_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_EcoSystem_Partner") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_Brand_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Brand") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_TargetAudience_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_TargetAudience") + '\n';
            	}
            	if(fieldAPI == 'Core_MDF_Initiative_nm__c'){
                	activityBlankFieldValidationLableStr += '• ' + $A.get("$Label.c.Core_MDF_Initiatives_label") + '\n';
            	}
            });
        
        if (helper.isNotBlank(activityBlankFieldValidationLableStr))
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": activityBlankFieldValidationLableStr,
                "type" : "error",
                "mode" : "sticky"	
            });
            toastEvent.fire();
        }
    }
},
  campaignAttributeChangeEvt: function(component, event, helper) {
        var campFieldValues = event.getParam('fieldValue');
        if(campFieldValues != undefined && campFieldValues != null && campFieldValues != ''){
            console.log('campFieldValues'+JSON.stringify(campFieldValues));
            component.set("v.updatedCampaignObj", campFieldValues);
        }

    },
   updateActivityListClone: function(component, event, helper) {
        const updatedActList = event.getParam('activityList');//v.pfrList
        let oldActivityList =  component.get('v.pfrList');
        let updatedAct;
        let updatedActivityID;
        updatedActList.forEach(actClone => {
			//global list
			const index = oldActivityList.findIndex(pfrClone => pfrClone.Id === actClone.Id);
			if (index !== -1) {
                updatedAct = actClone;
                updatedActivityID = actClone.Id;
				oldActivityList[index] = actClone;
			}
		});
		component.set('v.pfrList', oldActivityList);
        let findChildComp=component.find('childCampaignCmp');
        findChildComp.callChildMethodCampaign(updatedAct,updatedActivityID);
    },
})