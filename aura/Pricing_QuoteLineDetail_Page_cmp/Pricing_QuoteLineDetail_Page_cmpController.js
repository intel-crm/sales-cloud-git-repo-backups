({
	doInit : function(component, event, helper) {
        
        const recordId = component.get('v.recordId');
        component.set('v.quoteLineId', recordId);
        const showQuoteLineDetailAction = component.get('c.showQuoteLineDetail');
        showQuoteLineDetailAction.setParams({
          quoteLineId: recordId,
        });
        showQuoteLineDetailAction.setCallback(this, function (response) {
          component.set('v.isStandardQuoteLine', response.getReturnValue());
          console.log('is standard===>',component.get('v.isStandardQuoteLine'));
        });
        $A.enqueueAction(showQuoteLineDetailAction);
		
	}
})