//IPA2.0: US-TWC729-7976
({
	helperMethod : function() {
		
	}
})
// ({
//     /*Get Admin Details on init*/
//     getAdminDetails : function(component,helper) {
//        var action = component.get('c.getAdminDetails'); 
//        action.setParams({"surveyId": component.get('v.SurveyId'),
//                               });
//       /* helper.callServer(component,
//                           "getAdminDetails",
//                           {"surveyId": component.get('v.SurveyId'),
//                           }).then(*/ 
//             action.setCallback(this, function(response){
                
//                var state = response.getState(); // get the response state
//                 if(state === 'SUCCESS' && response.getReturnValue() && response.getReturnValue().objectData!=undefined){
//                 //if(response && response.objectData!=undefined){
                
//                     var responseValue = response.getReturnValue();
//                     component.set("v.loggedInAdmin",responseValue.objectData.loggedInUser.Name);
                    
                    
//                     //List of Admins from the public group
//                     if(responseValue.objectData.adminUsers!=undefined){
//                         component.set("v.admins",responseValue.objectData.adminUsers);                        
//                     } 
                    
//                     if(responseValue.objectData.surveyResult!=undefined){
//                         component.set("v.Survey",responseValue.objectData.surveyResult);
//                     }
                    
//                     if(component.get("v.Survey.PSS_System_Suggested_Benefit_Level__r.Name")){
//                         component.set("v.systemSuggestedBenefit",component.get("v.Survey.PSS_System_Suggested_Benefit_Level__r.Name"));
//                     }
                    
//                     if(responseValue.objectData.plValues!=undefined){
//                         var result = responseValue.objectData.plValues;
//                         var plValues = [];
//                         var selValues = [];
//                         for (var i = 0; i < result.length; i++) {
//                             if(responseValue.objectData.surveyResult.PSS_Programs_Applicable_Nm__c  && responseValue.objectData.surveyResult.PSS_Programs_Applicable_Nm__c
//                                 .includes(result[i])){
//                                 selValues.push(result[i]);
//                             }
//                             plValues.push({
//                                 label: result[i],
//                                 value: result[i]
//                             });                            
                            
//                         }
//                         component.set("v.GenreList", plValues);
//                         component.set("v.selectedGenreList", selValues);
                        
//                     } 
                    
//                     if(responseValue.objectData.plValues2!=undefined){
//                         var result = responseValue.objectData.plValues2;
//                         var plValues = [];
//                        var selValues = [];
                        
//                         for (var i = 0; i < result.length; i++) {
//                            if(responseValue.objectData.surveyResult.PSS_Strategic_Attributes_Nm__c && responseValue.objectData.surveyResult.PSS_Strategic_Attributes_Nm__c.includes(result[i])){
                                
//                                selValues.push(result[i]);
//                             }
//                             plValues.push({
//                                 label: result[i],
//                                 value: result[i]
//                             });
//                         }                        
//                         component.set("v.attributeList", plValues);
//                         component.set("v.selectedAttributeList", selValues);
//                     } 
                    
//                     if(responseValue.objectData.pickListValuesMap){
//                         var offeringStatus=[];
//                        var map1 = new Map();
//                         map1 = responseValue.objectData.pickListValuesMap;
//                         Object.keys(map1).forEach(function(key) {
//                                 var offeringStatusObject=new Object(); 
//                                 offeringStatusObject.label = key;
//                                 offeringStatusObject.value = map1[key];
//                                 offeringStatusObject.selected=map1[key]==responseValue.objectData.surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c ? true : false;
//                                 if(offeringStatusObject.selected){
//                                     component.set('v.selectedOfferingStatus',map1[key]);
//                                 }
//                                 offeringStatus.push(offeringStatusObject)                                                                
                            
//                         }); 
//                         component.set("v.offerinStatusList",offeringStatus); 
                        
//                     }
                    
//                     if(responseValue.objectData.pickListValuesMap2){
                        
//                         var offeringStatus=[];
//                         var map1 = new Map();
//                         var adminBenefit = component.get("v.Survey.PSS_Admin_Suggested_Benefit_Level__r.Name");
//                         map1 = responseValue.objectData.pickListValuesMap2;
                        
//                        var defaultEmptyValue=new Object(); 
//                         defaultEmptyValue.label = $A.get("$Label.c.PMP_Search_Choose_One");
//                         defaultEmptyValue.value ="";
//                         offeringStatus.push(defaultEmptyValue); //Added default empty value in the dropdown
                        
//                         Object.keys(map1).forEach(function(key) {
                            
//                             var offeringStatusObject=new Object(); 
//                             offeringStatusObject.label = key;
//                             offeringStatusObject.value = map1[key];
//                             offeringStatusObject.selected=map1[key]== adminBenefit ? true : false;
//                             if(offeringStatusObject.selected){
//                                 component.set('v.selectedBenefitStatus',map1[key]);
                                
//                             }
     
//                         offeringStatus.push(offeringStatusObject) 
                                                       
//                         }); 
//                         component.set("v.benefitsList",offeringStatus); 
                        
//                     }
//               }
                
//             }
//         )
//         $A.enqueueAction(action);
        
//     },
    
//     /*Show/Hide Modal*/
//     handlerToggleModal:function(component,helper){
//         component.set("v.isOpen",!component.get("v.isOpen")); 
//         helper.getAdminDetails();
//     },
    
//     /*Update changed details to offering (OfferingStatus, Admin)*/
//     handlerSaveAdminChanges:function(component,event, helper){
//         console.log('**');
//         component.set('v.showSpinner', true);//Added for US535344,making showSpinner attribute as true to display the spinner when submit button is clicked.
//         let saveMap = new Map();
//         var strageticAttributes = component.get('v.attributeList');
//         var isChanged = component.get('v.isTouched');
//         saveMap['PSS_Partner_Solution_Lifecycle_Status_Nm__c'] = component.get("v.selectedOfferingStatus");
//         console.log('123',saveMap['PSS_Partner_Solution_Lifecycle_Status_Nm__c']);
//         console.log('*',component.get("v.selectedOfferingStatus"));
//         saveMap['PSS_Cancel_Reason_Txt__c'] = component.get("v.Survey.PSS_Cancel_Reason_Txt__c");
//         //Rejection Reason to be modified when status is Rejected
//         saveMap['PSS_Rejection_Reason_Txt__c'] = component.get("v.Survey.PSS_Rejection_Reason_Txt__c");
//         saveMap['PSS_Follow_up_Date_Dt__c'] = component.get("v.Survey.PSS_Follow_up_Date_Dt__c");
//         saveMap['ArdiraSurvey__Score_Raw__c'] = component.get("v.Survey.ArdiraSurvey__Score_Raw__c");
//         saveMap['PSS_Review_Scheduled_Date_dt__c'] = component.get("v.Survey.PSS_Review_Scheduled_Date_dt__c");
//         saveMap['PSS_System_Suggested_Benefit_Level__c'] = component.get("v.systemSuggestedBenefit");//added by krishna ch for system benefit fix.
        
//         saveMap['PSS_Admin_Suggested_Benefit_Level__c'] = component.get("v.selectedBenefitStatus");
//         if(isChanged){
//             saveMap['PSS_Strategic_Attributes_Nm__c'] = component.get("v.finalAttribute")?component.get("v.finalAttribute"):null
//         }
//         else{
//            saveMap['PSS_Strategic_Attributes_Nm__c'] = component.get("v.finalAttribute")?component.get("v.finalAttribute"):component.get("v.Survey").PSS_Strategic_Attributes_Nm__c; 
//         }        
//         saveMap['PSS_Programs_Applicable_Nm__c'] = component.get("v.finalGenre")?component.get("v.finalGenre"):component.get("v.Survey").PSS_Programs_Applicable_Nm__c;
//         saveMap['PSS_Conversion_Admin_Log_Details_Txt__c'] = component.get("v.errorLogDetail");
//         saveMap['PSS_Intel_Admin_Id__c'] = component.get("v.selectedAdmin");
//         console.log('saveMap**',saveMap);
//         var solApplicableString = component.get("v.selectedGenreList").toString();
//         console.log('solApplicableString',solApplicableString);
//         var programApplicable = solApplicableString ?solApplicableString :null;
//         if(component.get("v.Survey.PSS_Partner_Solution_Lifecycle_Status_Nm__c") == 'Cancelled' && component.get("v.Survey.PSS_Cancel_Reason_Txt__c") == null){
//             var toastEvent = $A.get("e.force:showToast");
//             if(toastEvent){
//                 toastEvent.setParams({
//                     title: 'Cancel Reason cannot be blank.',
//                     message: 'Please enter a reason for changing the status to Cancel.',
//                     type : 'error',
//                     mode: 'dismissible',
//                 });
//                 toastEvent.fire();
//             }
//             component.set('v.showSpinner', false);
//             Break;
//         }
//         else if(component.get("v.Survey.PSS_Partner_Solution_Lifecycle_Status_Nm__c") == 'Approved' && programApplicable == null){
//             var toastEvent = $A.get("e.force:showToast");
//             if(toastEvent){
//                 toastEvent.setParams({
//                     "title":'Solution Applicable cannot be blank.',
//                     "message":'Please select atleast one value for solution applicable.',
//                     "type":"error",
//                     "mode": 'dismissible'
//                 });
//                 toastEvent.fire();
//             }
//             component.set('v.showSpinner', false);
//             Break;
//         }
// 		else{
//             var action = component.get('c.saveAdminDetails');
//             action.setParams({"surveyId": component.get('v.SurveyId'),
//                                "saveMap":saveMap,
//                               });
//             console.log('******',component.get('v.SurveyId'));
//             console.log('saveMap',saveMap);
//             /*helper.callServer(component,
//                               "saveAdminDetails",
//                               {"surveyId": component.get('v.SurveyId'),
//                                "saveMap":saveMap
//                               }).then( */
//                 action.setCallback(this, function(response){
//                     //If some error while updating the survey result record then showing the error message in toast event
//                      var response = response.getReturnValue();
//                     if(response == 'ValidationError'){
//                             var toastEvent = $A.get("e.force:showToast");
//                             if(toastEvent){
//                                 toastEvent.setParams({
//                                     "title": $A.get("$Label.c.PSS_Status_Validation_Error_Title"),
//                                     "message": $A.get("$Label.c.PSS_Status_Validation_Error_Message"),
//                                     "type":"error",
//                                     "mode":'dismissible' 
//                                 });
//                                 toastEvent.fire();
//                             }
//                         //setting the spinner to false
//                         component.set('v.showSpinner', false);
//                     }else if(response == 'Exception'){
//                         var toastEvent = $A.get("e.force:showToast");
//                             if(toastEvent){
//                                 toastEvent.setParams({
//                                     "title": $A.get("$Label.c.PSS_Status_Validation_Error_Title"),
//                                     "message": $A.get("$Label.c.PSS_Solution_Submit_Exception_Message"),
//                                     "type":"error",
//                                     "mode":'dismissible'
//                                 });
//                                 toastEvent.fire();
//                             }
//                         //setting the spinner to false
//                         component.set('v.showSpinner', false);
//                     }
//                     else{
//                         /*Added as aprt of US941484 - By Manjula*/
//                     	/*If the response is false, show the benefit not tagged warning message*/
//                         if(response == 'no'){
//                         	var toastEvent = $A.get("e.force:showToast");
//                         	if(toastEvent){
//                             	toastEvent.setParams({
//                                 	"title":$A.get("$Label.c.PSS_Select_Benefit_Validation_Toast_Title"),
//                                     "message":$A.get("$Label.c.PSS_Select_Benefit_Validation_Toast_Message"),
//                                     "type":"warning",
//                                     "mode": 'dismissible'
//                             	});
//                             toastEvent.fire();
//                         	}
//                     	}
                                            	
//                         //Toast event to show the record successfully saved message
//                     	var toastEvent = $A.get("e.force:showToast");
//                     	if(toastEvent){
//                         	toastEvent.setParams({
//                             	"title":$A.get("$Label.c.PMP_Success"),
//                             	"message": $A.get("$Label.c.PSS_Solution_Save_Success"),
//                             	"type":"success",
//                             	"mode":'pester'
//                         	});
//                             toastEvent.fire();
//                     	}
						
//                         //If status is approved and convertToOffering flag is true then call the method for solution to offering conversion
//                         if(component.get("v.convertToOffering") && component.get("v.Survey.PSS_Partner_Solution_Lifecycle_Status_Nm__c") == 'Approved'){
//                             if(component.get('v.aiipWarning') === true){
//                                 var toastEvent = $A.get("e.force:showToast");
//                                 if(toastEvent){
//                                     toastEvent.setParams({
//                                         "title": "Warning", 
//                                         "message": $A.get("$Label.c.PSS_AIIP_Solution_Conversion_Warning"),
//                                         "type":"warning",
//                                         "mode":'dismissible' 
//                                     });
//                                     toastEvent.fire();
//                                 }
//                             }
//                             helper.convertSolution(component,helper);
//                     	}
//                         //else redirect the user to solution detail page -the updated records values are saved already
//                     	else{
//                         	helper.urlRedirectLogic(component,helper);
//                     	}
//                     }
//                 });
                
//                 $A.enqueueAction(action);
//         }            
//     },
    
//     /*auto populate followup date to 5th working day from system date*/
//     autoPopulateFollowUpDate:function(component,event, helper){
//         var startDate = new Date();
//         var days= $A.get("$Label.c.PSS_FollowUpDate_NoOfDays");
//         // Get the day of the week as a number (0 = Sunday, 1 = Monday, .... 6 = Saturday)
//         var dow = startDate.getDay();
//         var daysToAdd = parseInt(days);
//         // If the current day is Sunday add one day
//         if (dow == 0)
//             daysToAdd++;
//         // If the start date plus the additional days falls on or after the closest Saturday calculate weekends
//         if (dow + daysToAdd >= 6) {
//             //Subtract days in current working week from work days
//             var remainingWorkDays = daysToAdd - (5 - dow);
//             //Add current working week's weekend
//             daysToAdd += 2;
//             if (remainingWorkDays > 5) {
//                 //Add two days for each working week by calculating how many weeks are included
//                 daysToAdd += 2 * Math.floor(remainingWorkDays / 5);
//                 //Exclude final weekend if remainingWorkDays resolves to an exact number of weeks
//                 if (remainingWorkDays % 5 == 0)
//                     daysToAdd -= 2;
//             }
//         }
//         startDate.setDate(startDate.getDate() + daysToAdd);
//         component.set('v.Survey.Follow_up_Date__c',startDate.toISOString());
//     },
    
//     //added by priyanka  -- US912153
//     updateAdminChanges:function(component,event, helper){
//        var action = component.get('c.isDuplicateOffering');
//         action.setParams({"surveyId": component.get('v.SurveyId'),
//                            "solutionStatus":component.get('v.selectedOfferingStatus'),
//                               });
//         /*helper.callServer(component,
//                           "isDuplicateOffering",
//                           {"surveyId": component.get('v.SurveyId'),
//                            "solutionStatus":component.get('v.selectedOfferingStatus'),
//                           }).then(*/ 
//             action.setCallback(this, function(response){
//                // Changes as part of US985766 to display OfferingConversionWarningMessage
//                 var response = response.getReturnValue();
//                 if(response == 2){                   
//                     var toastEvent = $A.get("e.force:showToast");
//                     if(toastEvent){
//                         toastEvent.setParams({
//                             "title":'Warning',
//                             "message": $A.get("$Label.c.PSS_OfferingConversionWarningMessage"),
//                             "type":"warning",
//                             "mode": 'dismissible'
                            
//                         });
//                         toastEvent.fire();
//                         component.set("v.convertToOffering",false);
//                         var errorLogDetail = $A.get("$Label.c.PSS_Conversion_MPI_Record_Validation_Error");
//                         component.set("v.errorLogDetail",errorLogDetail);
//                     }
                    
//                     helper.handlerSaveAdminChanges(component,event, helper);                    
                    
//                 }
//                 else if(response == 0){
//                     var retVal = confirm($A.get("$Label.c.PSS_DuplicateOfferingWarningMessage"));

//                     if(retVal==true){
//                         component.set("v.convertToOffering",true);
//                         helper.handlerSaveAdminChanges(component,event, helper);
//                     }
//                 }
//                 else if (response == -1){
//                     var toastEvent = $A.get("e.force:showToast");
//                     if(toastEvent){
//                         toastEvent.setParams({
//                             "title":$A.get("$Label.c.PSS_DuplicateOfferingValidationMessage"),
//                             "message":'cant save the updates',
//                             "type":"error",
//                             "mode": 'sticky'
                            
//                         });
//                         toastEvent.fire();
//                         component.set("v.convertToOffering",false);
//                     }
//                 }
//                     else{
//                         helper.handlerSaveAdminChanges(component,event, helper);
//                     }
//             });
//         	$A.enqueueAction(action);
        
//     },
//   //added by priyanka  -- US912153
    
   
//     urlRedirectLogic :function(component, helper){
//         var action = component.get('c.isIntelMPAdmin');
//         action.setCallback(this, function(response){
//             var state = response.getState(); // get the response state
//             if(state === 'SUCCESS' && response.getReturnValue()) {
//                 var isIntelAdmin = response.getReturnValue();
//                     if(isIntelAdmin){
//                         var urlAdminEvent = $A.get("e.force:navigateToURL");
//                     	urlAdminEvent.setParams({ "url": "/solution-detail-page?recordId="+component.get("v.SurveyId")+"&viewchat=true" });
//                     	urlAdminEvent.fire(); 
//                     }
//                     else{
//                     	var urlEvent = $A.get("e.force:navigateToURL");
//                     	urlEvent.setParams({ "url": "/partner-solution-list" });
//                     	urlEvent.fire();
// 		    		}
//                     component.set('v.showSpinner', false);//Added for US535344,making showSpinner attribute as false to remove the spinner once the response from server is received. 
//             }
//         });
//         $A.enqueueAction(action);
//     },
    
    
//     convertSolution :function(component, helper){
//         var action = component.get('c.createOfferingFromSolution');
//         action.setParams({solutionId : component.get('v.SurveyId')});// setting the parameter to apex class method
//         action.setCallback(this, function(response){
//             var state = response.getState(); // get the response state
//             if(state === 'SUCCESS') {
//             	helper.urlRedirectLogic(component,helper);  
//             }
//         });
//         $A.enqueueAction(action);
//     },
    
//     impactPathScoreChanges  : function(component,event, helper){
//         let saveMap = new Map();
//         var isChanged = component.get('v.isTouched');
//         var strageticAttributes = component.get('v.attributeList');
//         if(isChanged){
//             saveMap['Strategic_Attributes__c'] = component.get("v.finalAttribute")?component.get("v.finalAttribute"):null;
//         }
//         else{
//         	saveMap['Strategic_Attributes__c'] = component.get("v.finalAttribute")?component.get("v.finalAttribute"):component.get("v.Survey").PSS_Strategic_Attributes_Nm__c;
//         }
//         // saveMap['PSS_Programs_Applicable_Nm__c'] = component.get("v.finalGenre")?component.get("v.finalGenre"):component.get("v.Survey").PSS_Programs_Applicable_Nm__c;

//         var action = component.get('c.reCalculateImpactPathScoring');
        
//         action.setParams({"surveyId": component.get('v.SurveyId'),
//                                "saveMap":saveMap
//                               });
//          action.setCallback(this, function(response){
//             var state = response.getState();
//              var value=response.getReturnValue();
//             if(state === 'SUCCESS' && response.getReturnValue().length > 0) {
//                 component.set("v.Survey.PSS_Impact_Path_Score__c",value[0].PSS_Impact_Path_Score__c);
//                 //code added to show recalculated benefit value in admin review screen
//                 if(value[0].PSS_System_Suggested_Benefit_Level__c){
//                     component.set("v.systemSuggestedBenefit",value[0].PSS_System_Suggested_Benefit_Level__r.Name);
//                 }
//                 if(value[0].PSS_Admin_Suggested_Benefit_Level__c){
//                     component.set("v.selectedBenefitStatus",value[0].PSS_Admin_Suggested_Benefit_Level__r.Name);
//                 }
//             }
             
//         });
//         $A.enqueueAction(action);
         
//     }

// })