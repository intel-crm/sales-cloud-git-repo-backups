({
	handleKeyUp: function (cmp, evt, helper) {
        var baseUrlRecord;
        var intelUrl;
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var searchParam = cmp.find('searchBox').get('v.value');
            var languageCode = helper.getLanguageCookie("PrefLangIETF");
            var action = cmp.get('c.getBaseUrlForLaunguageCode');
            action.setParams({
                "languageCode": languageCode
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    baseUrlRecord = JSON.parse(response.getReturnValue());
                    intelUrl = baseUrlRecord[0].BaseURL__c+searchParam+baseUrlRecord[0].Tab__c;
                    window.location.href = intelUrl;    
                }
            });
            $A.enqueueAction(action);
        }
    }
})