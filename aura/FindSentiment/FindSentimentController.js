({
	init: function(cmp, event, helper) {
		cmp.set("v.isSpinner", false);
	},
    findSentimentResult: function(cmp, event, helper) {
        cmp.set("v.isSpinner", true);
        helper.getSentiments(cmp, event, helper);        
    }
})