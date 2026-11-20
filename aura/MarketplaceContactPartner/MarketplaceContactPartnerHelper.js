({
    toggleModal : function(component, toggle) {
        var overlay = component.find("partnerOverlay");
        var analyticsData = component.find("analyticsData");
        
        if (toggle) {
            $A.util.removeClass(overlay, "slds-hide");
            overlay.getElement().classList.remove('slds-hide');
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(overlay, "slds-show");
                    overlay.getElement().classList.add('slds-show');
                }),
                5
            );
            //Contact Partner analytics code starts
            var categoryLabel = (component.get('v.dataObj').categoryLabel == null) ? 'Not-Applicable' : component.get('v.dataObj').categoryLabel;
            var partnerId = (component.get('v.dataObj').id == null) ? 'Not-Applicable' : component.get('v.dataObj').id;
            // IPA2.0 + US TWC4497-1631
            // var offeringId =  (component.get('v.dataObj').offRecId == null) ? 'Not-Applicable' : component.get('v.dataObj').offRecId;
            // var str = 'expand:' + categoryLabel +'|' + partnerId + '|' + offeringId;
            var str = 'expand:' + categoryLabel +'|' + partnerId ;
           analyticsData.formAnalyticsData('click',str,'contact-partner');
            //Contact Partner analytics code ends
        } else {
            $A.util.removeClass(overlay, "slds-show");
            $A.util.addClass(overlay, "slds-hide");
            overlay.getElement().classList.add('slds-hide');
            overlay.getElement().classList.remove('slds-show');
            
            //Contact Partner analytics code starts
            var categoryLabel = (component.get('v.dataObj').categoryLabel == null) ? 'Not-Applicable' : component.get('v.dataObj').categoryLabel;
            var partnerId = (component.get('v.dataObj').id == null) ? 'Not-Applicable' : component.get('v.dataObj').id;
            // IPA2.0 + US TWC4497-1631
            // var offeringId =  (component.get('v.dataObj').offRecId == null) ? 'Not-Applicable' : component.get('v.dataObj').offRecId;
            // var str = categoryLabel +'|' + partnerId + '|' + offeringId;
            var str = categoryLabel +'|' + partnerId;
            analyticsData.formAnalyticsData('click',str,'contact-partner');
        }
    }
})