({
    doInit: function(component, event, helper) {
        // Close modal when clicking outside of component
    var closeIfClickedOutsideComponent = function(event) {
      if (component.get('v.toggle')) {
        var thisComponent = component.find('outerElement').getElement();
        var isClickInside = thisComponent.contains(event.target);

        if (!isClickInside) {
          // console.log('click outside',event.target, event.target.classList, thisComponent);
          component.set('v.toggle', false);
          helper.toggleModal(component, false);
        }
      }
    };
    document.addEventListener("touchstart", closeIfClickedOutsideComponent);
    document.addEventListener("click", closeIfClickedOutsideComponent);      
        
        // handleDataChange
        $A.enqueueAction(component.get('c.handleDataChange'));
        console.log('data : ' , component.get('v.dataObj'));
    },
    
    
    openContactLinks: function(component, event, helper) {
        
       
        
        var modalOpen = component.get("v.toggle");
        var singleItem = component.get("v.singleItem");
        var data = component.get("v.dataObj");
        if (!singleItem) {
           
            modalOpen = !modalOpen;
            component.set("v.toggle", modalOpen);
            // have to manually change it here as transitions wont work if we do it inline
            component.set('v.renderOverlay',true);
            helper.toggleModal(component, modalOpen);
            
        } else {
            // for single item launch it separately
            if (data.contactByEmail) {
                $A.enqueueAction(component.get('c.handleContactByEmail'));
            } else if (data.contactByForm) {
                
                $A.enqueueAction(component.get('c.handleContactByForm'));
            } else if (data.requestAQuote) {
                $A.enqueueAction(component.get('c.handleRequestAQuote'));
            }
        }
        event.preventDefault();
    },
    
    handleContactByForm: function(component, event, helper) {
        
       //Contact Partner analytics code starts
        var analyticsData = component.find("analyticsData");
        var categoryLabel = (component.get('v.dataObj').categoryLabel == null) ? 'Not-Applicable' : component.get('v.dataObj').categoryLabel;
        var partnerId = (component.get('v.dataObj').id == null) ? 'Not-Applicable' : component.get('v.dataObj').id;
        var offeringId =  (component.get('v.dataObj').offRecId == null) ? 'Not-Applicable' : component.get('v.dataObj').offRecId;
        var str = 'modal_contact-partner|' + categoryLabel +'|' + partnerId + '|' + offeringId;
        analyticsData.formAnalyticsData('click',str,'ask-a-question');
        //Contact Partner analytics code ends
        
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        appEvent.setParams({
            type: "openLeadGenModal",
            payload: {
                formType: "contact",
                partnerData: component.get('v.dataObj'),
                productData: component.get('v.productData'),
                languageMessage: component.get("v.languagePreference"),
                userAuthentication: component.get("v.isLoggedIn")
                
            }
        });
        appEvent.fire();
        event.preventDefault();
        
        
    },

    handleRequestAQuote: function(component, event, helper) {
                
        //Contact Partner analytics code starts
        var analyticsData = component.find("analyticsData");
        var categoryLabel = (component.get('v.dataObj').categoryLabel == null) ? 'Not-Applicable' : component.get('v.dataObj').categoryLabel;
        var partnerId = (component.get('v.dataObj').id == null) ? 'Not-Applicable' : component.get('v.dataObj').id;
        var offeringId =  (component.get('v.dataObj').offRecId == null) ? 'Not-Applicable' : component.get('v.dataObj').offRecId;
        var str = 'modal_contact-partner|' + categoryLabel +'|' + partnerId + '|' + offeringId;
        analyticsData.formAnalyticsData('click',str,'request-a-quote');
        //Contact Partner analytics code ends
        
        var mockLogin = event && event.target && event.target.dataset ? event.target.dataset.loggedin : component.get("v.loggedin");
        var ptnrName = component.get("v.dataObj.name");
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        appEvent.setParams({
            type: "openLeadGenModal",
            payload: {
                formType: "quote",
                partnerData: component.get('v.dataObj'),
                productData: component.get('v.productData'),
                languageMessage: component.get("v.languagePreference"), //Added as part of US443556
                userAuthentication: component.get('v.isLoggedIn')
                
            }
        });
        appEvent.fire();
        
        event.preventDefault();
    },
    
    handleDataChange: function(component, event, helper) {
        var data = component.get("v.dataObj");
        // check for singleItem
        var count = 0;
        ["contactByEmail", "contactByForm", "requestAQuote"].forEach(function(name){
            if (data && data[name]){
                count++;
            }
        })
        // Disable this for now as it is incomplete yet and deprioritized
        component.set("v.singleItem", (count == 1));
    },
    
    
    /*handleBlur: function(component, event, helper) {
        if (component.get('v.toggle')) {
            // close timeout
            var debounceIndex = component.get('v.closeTimeoutId');
            window.clearTimeout(debounceIndex);
            debounceIndex = window.setTimeout($A.getCallback(function() {
                component.set('v.toggle', false);
                helper.toggleModal(component, false);
            }), 50);
            component.set('v.closeTimeoutId', debounceIndex);
        }
    },
    handleFocus: function(component, event, helper) {
        // focusing on other elements
        var debounceIndex = component.get('v.closeTimeoutId');
        window.clearTimeout(debounceIndex);
    }*/
    /*handleContactByFormLoggedIn: function(component,event,helper){
        console.log('handleContactByFormLoggedIn ');
        // Set logged user details
        var url = window.location.href; 
        var prevUrl=url.substr(0,url.substr(0, url.lastIndexOf("/")).lastIndexOf("/") + 1);
        
    component
    .find("contactForm")
    .set("v.userDetails", component.get("v.userDetails"));
    
    
    var appEvent = $A.get("e.c:MarketplacePageEvent");
    console.log('lang contact : '+ component.get("v.languagePreference"));
    appEvent.setParams({
    type: "openLeadGenModal",
    payload: {
        formType: "contact",
        mockAuthenticated: component.get("v.languagePreference"),
        //prefLanguage: component.get("v.languagePreference")
    }
});
appEvent.fire();
},*/
    /*handleContactByEmail: function(component, event, helper) {
        console.log("handleContactByEmail");
        
        var mockLogin = event && event.target && event.target.dataset ? event.target.dataset.loggedin : component.get("v.loggedin");
        var appEvent = $A.get("e.c:MarketplacePageEvent");
        appEvent.setParams({
            type: "openLeadGenModal",
            payload: {
                formType: "contact",
                mockAuthenticated: component.get("v.languagePreference")
                // prefLanguage: component.get("v.languagePreference")
            }
        });
        appEvent.fire();
        event.preventDefault();
        
    },*/    
    
});