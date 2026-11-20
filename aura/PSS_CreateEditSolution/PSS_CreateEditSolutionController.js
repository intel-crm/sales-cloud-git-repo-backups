//IPA2.0: US-TWC729-7976
({
	myAction : function(component, event, helper) {
		
	}
})
/*({
    doInit : function(component, event, helper) {
        try{
            var surveyURL='https://crmdevipam-intelcloudcrm.cs36.force.com/imp/ArdiraSurvey/SurveyResponse.app?';
            var url = window.location.href;
            
            //helper.showModal(component,  $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading"), $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Current_Step_Incomplete"), true);

            //component.set('v.isDetailActive',true);
            var urlToParse = location.search;
            var urlParams = {};
            urlToParse.replace(new RegExp("([^?=&]+)(=([^&]*))?", "g"), function(
                $0,
                $1,
                $2,
                $3
            ) {
                urlParams[$1] = $3;
            });
            console.log(JSON.stringify(urlParams));
            if(urlParams.hasOwnProperty('recordId')){
                component.set("v.recordId", urlParams.recordId);
                surveyURL += 'recordId='+urlParams.recordId;
            }
            else{
                surveyURL += 'recordId=a7r2h0000004ut4&logicalId=7edde2c2-6311-f640-90a5-fe55ee99c2d5'; 
            }
            component.set('v.surveyurl', surveyURL);
            console.log(surveyURL);
            var action = component.get("c.getPartnerResponses");
            action.setParams({
                recordId: component.get('v.recordId')
            });

            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    console.log(a.getReturnValue());
                    component.set("v.quesAnsObj",a.getReturnValue().questionAnsList);
                    component.set("v.responseWrapper",a.getReturnValue());
                    component.set("v.recordId",a.getReturnValue().resultRecord.Id);
                    component.set("v.solutionStatus",a.getReturnValue().resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
                    
                    
  
                }
            });
            $A.enqueueAction(action);
        } catch(e) {
            console.log(e.stack);
        }
    },
    
    handleDetailClick : function(component, event, helper) {
        
        var action = component.get("c.getPartnerResponses");
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.recordId",a.getReturnValue().resultRecord.Id);
                component.set("v.solutionStatus",a.getReturnValue().resultRecord.PSS_Partner_Solution_Lifecycle_Status_Nm__c);
                if(!component.get('v.isDetailActive')){
                    //location.reload();
                    if(component.get("v.solutionStatus")=="Admin Review" || component.get("v.solutionStatus")=="Update Required" || component.get("v.solutionStatus")=="On Hold" || component.get("v.solutionStatus")=="Review Scheduled"){
                        location.reload();
                    } 
                } 
            }
        });
        $A.enqueueAction(action);
    },
    handlePreviewClick : function(component, event, helper) {
       
        
        component.set('v.isDetailActive',false);
        component.set('v.isPreviewActive',true);
        component.set('v.isAdminReviewActive',false);
    },
    handleAdminReviewClick : function(component, event, helper) {
       
        if(!component.get("v.solutionStatus") || component.get("v.solutionStatus")=="In Progress" || component.get("v.solutionStatus")=="Draft" || component.get("v.solutionStatus")=="Update Required"){
            helper.showModal(component, $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Heading"), $A.get("$Label.c.PMP_Create_Offering_Form_Warning_Current_Step_Incomplete"), false);
        }else{
        
            var appEvent = $A.get("e.c:PSS_HandleAdminReview");
            appEvent.setParams({
                "isAdmin" : true
            });
            appEvent.fire();
            
            component.set('v.isDetailActive',false);
            component.set('v.isPreviewActive',false);
            component.set('v.isAdminReviewActive',true); 
        }  
    },
    
    changePath : function(component, event, helper) {
        //Set the progress bar indicator for Details to complete
        var toggleIndicatorCurrent = component.find("step1Indicator");
        $A.util.removeClass(toggleIndicatorCurrent,'slds-tabs--path__item slds-is-current');
        $A.util.addClass(toggleIndicatorCurrent,'slds-tabs--path__item slds-is-complete');
        //Set the progress bar indicator for Account selection to current
        var toggleIndicatorNext = component.find("step2Indicator");
        $A.util.removeClass(toggleIndicatorNext,'slds-tabs--path__item slds-is-incomplete');
        $A.util.addClass(toggleIndicatorNext,'slds-tabs--path__item slds-is-current');
    },
    
    handleSolutionSubmitEvent : function(component, event, helper) {
        component.set('v.tabVisibility', true);
    }
})*/