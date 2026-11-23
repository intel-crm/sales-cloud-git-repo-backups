({
	doInit: function (component, event, helper) {
        //console.log('inside connected call back '+userId);
        
        let action = component.get("c.getUserPemissionSets");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        action.setParams({ userId: userId });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                response.getReturnValue().forEach(item => {
                    if((item.PermissionSet.Name).includes('Tender')){
                        component.set("v.isTender",true);
                        
                    }
            	});
            }else {
                console.log("Error in loading ");
            }
        });
		$A.enqueueAction(action);
	    //var navService = component.find("navService");
        /*var pageRef = {
            type: "standard__objectPage",
            attributes: {
                objectApiName: "SBQQ__Quote__c",
                actionName: "new"
            },
            state: {
            }
        }
        // Replace with your own field values
       // var defaultFieldValues = {
       //};
       // pageRef.state.defaultFieldValues = component.find("pageRefUtils").encodeDefaultFieldValues(defaultFieldValues);
       // component.set("v.pageReference", pageRef);
        //var defaultUrl = "#";
 
        // Generate a Link for the Aura Link example
        /*navService.generateUrl(pageRef)
        .then($A.getCallback(function(url) {
            component.set("v.url", url ? url : defaultUrl);
        }), $A.getCallback(function(error) {
            component.set("v.url", defaultUrl);
        }));*/
    },
    /*
    handleNavigate: function (component, event, helper) {
        var compDefinition = {
            componentDef: "c:psg_QuoteRequest",
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    },
    */
        
    /*
    get recordTypeId() {
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Pricing Tender Quote - Create');
    },*/
        
    /*openNewIQRQuoteForm: function (component, event, helper) {
		var navService = component.find("navService");
        var pageRef = component.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageRef);
    },*/
   /* openModal: function (component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModal: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    submitDetails: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    }*/
})