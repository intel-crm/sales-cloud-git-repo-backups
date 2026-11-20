({
    doInit : function(component, event, helper) {
        helper.getEventTopicType(component, event, helper);
        //ipa 2.0 priyas change for topic event
      //  helper.getPromotionLanguageOptions(component, event, helper);
    },

    handleDestroy : function (component, event, helper) {
        helper.getCloneImages(component, event, helper);
    },

})