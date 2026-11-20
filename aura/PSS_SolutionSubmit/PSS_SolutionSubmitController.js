//IPA2.0: US-TWC729-7976
({
	myAction : function(component, event, helper) {
		
	}
})
/*({
    doInit: function (component, event, helper) {

        //To take the url paramters
        let urlParams;
        let companyId;
        let recordId;
        let assignedToContact;
        let solutionCategory;

        if (window.parent.location !== undefined) {
            const url = window.parent.location.href;
            urlParams = new URL(url);
            companyId = urlParams.searchParams.get('PSS_company_Id__c');
            recordId = urlParams.searchParams.get('recordId');

            //Part of ww8
            assignedToContact = urlParams.searchParams.get('ArdiraSurvey__Assigned_To_Contact__c');

            //Part of ww8
            solutionCategory = urlParams.searchParams.get('PSS_Solution_Category_Nm__c');
        }

        //call getSolutionDataAura for getting solutionDataCheck wrapper
        const action = component.get('c.getSolutionDataAura');
        action.setParams({ 'solRecordId': recordId });
        action.setCallback(this, function (response) {

            let solutionDataCheck;
            const state = response.getState();

            if (state === 'SUCCESS') {
                solutionDataCheck = response.getReturnValue();

                if (solutionDataCheck.isRedirect) {
                    window.parent.location.href = $A.get('$Label.c.PMP_Marketplace_Community_URL') + $A.get('$Label.c.PSS_Solution_Detail_Page_URL') + recordId;
                } else {
                    if (recordId !== null && recordId !== undefined && recordId !== '') {
                        component.set('v.surveyResultId', recordId);
                    }
                    
                    component.set('v.loadSurvey', true);
                    const solutionEvent = $A.get('e.c:PSS_SolutionSubmitEvent');
                    solutionEvent.fire();
                    component.set('v.addContactVisibility', solutionDataCheck.showAddConFlag);
                    helper.hideSpinner(component, event);
                }//END ELSE

            } else if (state === 'INCOMPLETE') {
                helper.hideSpinner(component, event);
            } else if (state === 'ERROR') {
                helper.hideSpinner(component, event);
            }
        });

        $A.enqueueAction(action);

        let additionalParameter = '';
        //additionalParams should be ~ separated(if mulitple params)
        //this code is for ww8
        if (solutionCategory) {
            additionalParameter += 'PSS_Solution_Category_Nm__c=' + solutionCategory;
        }

        if (assignedToContact && companyId) {
            additionalParameter += '~PSS_company_Id__c=' + companyId + '~ArdiraSurvey__Assigned_To_Contact__c=' + assignedToContact;

            //'~PSS_OPID_Account_Id__c='+opidAccount to be added if opid required
            //add opid in if condition also 
        }

        component.set('v.additionalParameter', additionalParameter);

        if (solutionCategory !== undefined && solutionCategory !== null) {
            if (solutionCategory === 'IOTG') {
                component.set('v.createRecordId', $A.get('$Label.c.PSS_IOTG_Survey_RecordId'));
                component.set('v.psslogicalId', $A.get('$Label.c.PSS_IOTG_Survey_LogicalId'));
            } else if (solutionCategory === 'DCG') {
                component.set('v.createRecordId', $A.get('$Label.c.PSS_DCG_Survey_RecordId'));
                component.set('v.psslogicalId', $A.get('$Label.c.PSS_DCG_Survey_LogicalId'));
            } else {
                component.set('v.createRecordId', $A.get('$Label.c.PSS_Partner_Solution_Survey_RecordId'));
                component.set('v.psslogicalId', $A.get('$Label.c.PSS_Partner_Solution_Survey_LogicalId'));
            }
        } else if (recordId !== undefined && recordId !== null) {
            component.set('v.createRecordId', recordId);
            component.set('v.psslogicalId', recordId);
        }
        component.set('v.addContactDisableCheck', helper.disableCheck(component, event, helper));
    },

    surveyLoad: function (component, event, helper) {
        helper.setSurveyId(component, event, helper);
    },

    nextButtonClick: function (component, event, helper) {
        helper.setSurveyId(component, event, helper);
        helper.handler(component, event, helper);
    },

    draftClick: function (component, event, helper) {
        helper.setSurveyId(component, event, helper);
    },

    surveySubmit: function (component, event, helper) {

        let thankYouButton;
        const terminatingThankYouQuestion = event.getParam('terminatingThankYouQuestion');

        helper.setSurveyId(component, event, helper);
        
        if (terminatingThankYouQuestion !== undefined) {
            thankYouButton = terminatingThankYouQuestion.thankYouButtonLabel;
            if (thankYouButton === 'Quit' || thankYouButton === 'Next') {
                helper.submitButtonClick(component, event, helper);
            } else {
                helper.submitButtonClick(component, event, helper);
            }
        } else if (terminatingThankYouQuestion === undefined) {
            helper.submitButtonClick(component, event, helper);
        }
    },

    openAddContactModal: function (component, event, helper) {
        const recId = component.get('v.recordId') ? component.get('v.recordId') : component.get('v.surveyResultId') ? component.get('v.surveyResultId') : component.get('v.createRecordId');
        component.set('v.recId', recId);
        component.set('v.toggleLwcComponent', true);
    },

    closeContactModal: function (component, event, helper) {
        component.set('v.toggleLwcComponent', false);
    },

    previousButtonClick: function (component, event, helper) {
            helper.handler(component, event, helper);
    },

    submitButtonClick: function (component, event, helper) {
        helper.handler(component, event, helper);
    },

    thankYouButtonClick: function (component, event, helper) {
        helper.handler(component, event, helper);
    },

    thankYouQuestionClick: function (component, event, helper) {
        helper.handler(component, event, helper);
    },

    scrollToTop: function (component, event, helper) {
        helper.scrollToTop(component, event, helper);
    },
    
});*/