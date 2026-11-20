//IPA2.0: US-TWC729-7976
({
	helperMethod : function() {
		
	}
})
/*({
    setSurveyId: function (component, event, helper) {

        const eventSurveyResultId = event.getParam('surveyResultId');
        const eventId = event.getParam('eventId');

        if (eventSurveyResultId !== undefined && eventSurveyResultId !== null &&
            (component.get('v.surveyResultId') === undefined || component.get('v.surveyResultId') === null)) {
            component.set('v.surveyResultId', eventSurveyResultId);
        }
        if (eventId === 'svevent_nextbuttonclicked' || eventId === 'svevent_savedraftclicked') {
            component.set('v.addContactDisableCheck', this.disableCheck(component, event, helper));
        }
    },

    disableCheck: function (component, event, helper) {
        const recId = component.get('v.recordId') ? component.get('v.recordId') : component.get('v.surveyResultId') ? component.get('v.surveyResultId') : '';
        return !(recId && recId !== '');
    },

    submitButtonClick: function (component, event, helper) {

        let tyButtonLabel;
        const terminatingThankYouQuestion = event.getParam('terminatingThankYouQuestion');
        const surveyId = event.getParam('surveyResultId');
        if (terminatingThankYouQuestion !== undefined) {
            tyButtonLabel = terminatingThankYouQuestion.thankYouButtonLabel;
        } else {
            tyButtonLabel = 'undefined';
        }
        const action = component.get('c.statusChangeOnSubmitAura');
        action.setParams({'recordId': surveyId, 'buttonLabel': tyButtonLabel});
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                let thankYouButton;
                if (terminatingThankYouQuestion !== undefined) {
                    thankYouButton = terminatingThankYouQuestion.thankYouButtonLabel;
                    if (thankYouButton !== 'Quit' && thankYouButton !== 'Next') {
                        window.parent.location.href = $A.get('$Label.c.PMP_Marketplace_Community_URL') + $A.get('$Label.c.PSS_Solution_Submit_Page_URL') + component.get('v.surveyResultId');
                    }
                } else if (terminatingThankYouQuestion === undefined) {
                    window.parent.location.href = $A.get('$Label.c.PMP_Marketplace_Community_URL') + $A.get('$Label.c.PSS_Solution_Submit_Page_URL') + component.get('v.surveyResultId');
                }
            }
        });
        $A.enqueueAction(action);
    },

    // Below event will bring the user at the top of the page.
    handler: function (component, event, helper) {
        window.parent.document.body.scrollIntoView(true);
    },

    // scroll up to top when modal dialog open
    scrollToTop: function (component, event, helper) {
        scrollY = 0;
        window.parent.scrollTo(0, scrollY);
    },

    showSpinner: function (component, event) {
        component.set('v.spinner', true);
    },

    hideSpinner: function (component, event) {
        component.set('v.spinner', false);
    },
});*/