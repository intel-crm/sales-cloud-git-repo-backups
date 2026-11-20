({
    handleFAQJump : function(component, event, helper) {
      var appEvent = $A.get("e.c:MarketplacePageEvent");
      appEvent.setParams({
            type: 'scrollToFAQ',
            payload: { questionId: component.get('v.questionId') }
          });
      appEvent.fire();

    }
})