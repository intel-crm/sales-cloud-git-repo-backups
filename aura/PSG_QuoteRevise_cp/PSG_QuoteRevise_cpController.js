({
    doInit: function (component, event, helper) {
        console.log('inside PSG Revise');
       // component.find("mySpinner").set("v.class", "slds-show");
       // helper.reviseQuote(component);
        //helper.quoteTypeCheck(component);
       // helper.recordLoaded(component);
       component.set("v.isFinal", false);
    },
    
    goBackLink: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleSubmitOnClick: function (component, event, helper) {
        console.log('inside PSG Revise>>>');
        var selectedPicklistValue= component.find("statusPicklist").get("v.value");
        console.log(selectedPicklistValue);
        component.set("v.quotetype",selectedPicklistValue);
        
        
        component.set("v.isFinal", true);
        component.find("spinner").set("v.class", "slds-show");
        component.find("mySpinner").set("v.class", "slds-show");
        helper.reviseQuote(component);

        console.log('inside PSG Revise>>>after');
        
        //helper.quoteTypeCheck(component);
        // helper.recordLoaded(component);
    },
      recordLoaded: function(component, event){
        var oldType = component.get("v.Quote.core_cpq_quote_type_nm__c"); 
        component.set("v.oldQuoteType",oldType);
        console.log('oldQuoteTypeOnload'+oldType);
    },  
    
    navigateToRecord: function (component, event, helper) {
        let navService = component.find("navService");
        let pageReference = {
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.newRecordId"),
                "actionName": "view"
            }
        }

        navService.generateUrl(pageReference)
            .then($A.getCallback(function (url) {
                console.log('success: ' + url);
                window.open(url, '_blank');
            }),
                $A.getCallback(function (error) {
                    console.log('error: ' + error);
                }));
    }
})