({

    doInit : function(component, event, helper) {
        component.set('v.mapStateToAttributes', function(state) {
            return {
                currentModalName: state.openModal,
                currentModalData: state.openModalData
            };
        });
    },

    handleModalChange : function(component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            var modalName = component.get('v.currentModalName'), cmpName = '', attrs = {};
            var modalData = component.get('v.currentModalData');
            component.set('v.modal', []);

            if (modalName === 'contactPartnerRequestQuote') {
                // cmpName = 'c:psMpLeadGenForm';
                cmpName = 'c:MarketplaceLeadGenForm';
                attrs.formType = 'quote';
                if (modalData && modalData.partnerData) attrs.partnerName = modalData.partnerData.name;
                if (modalData && modalData.productData){
                    attrs.partnerName = modalData.productData.name;
                    attrs.partnerRecId = modalData.productData.id;
                    attrs.languageLabel = modalData.productData.leadLangPreference;
                    attrs.partnerId = modalData.productData.autoPartnerId;
                    attrs.offeringName = modalData.productData.title;
                    attrs.productRecId = modalData.productData.oid;
                    attrs.productId = modalData.productData.autoOffId;
                    attrs.isLoggedIn = modalData.productData.isLoggedIn;
                } 
                if (modalData && modalData.userDetails) attrs.userDetails = modalData.userDetails;
            }

            if (modalName === 'contactPartnerAskQuestion') {
                cmpName = 'c:MarketplaceLeadGenForm';
                attrs.formType = 'contact';
                if (modalData && modalData.partnerData){
                    attrs.partnerName = modalData.partnerData.name;
                    attrs.partnerRecId = modalData.partnerData.id;
                    attrs.languageLabel = modalData.partnerData.leadLangPreference;
                    attrs.partnerId = modalData.partnerData.autoPartnerId;
                    attrs.isLoggedIn = modalData.partnerData.isLoggedIn;
                } 
                if (modalData && modalData.productData){
                    attrs.partnerName = modalData.productData.name;
                    attrs.partnerRecId = modalData.productData.id;
                    attrs.languageLabel = modalData.productData.leadLangPreference;
                    attrs.partnerId = modalData.productData.autoPartnerId;
                    attrs.isLoggedIn = modalData.productData.isLoggedIn;
                } 
                if (modalData && modalData.userDetails) attrs.userDetails = modalData.userDetails;
            }
    
            if (cmpName) {
                $A.createComponent(cmpName, attrs, function(newComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        newComponent.set('v.isOpen', true);
                        component.set('v.modal', newComponent);
                    } else if (status === "INCOMPLETE") {
                        console.error("No response from server or client is offline.");
                        component.set('v.modal', []);
                    } else if (status === "ERROR") {
                        console.error("Error in (" + cmpName + "):" + errorMessage);
                        component.set('v.modal', []);
                    }
                });
            } else {
                component.set('v.modal', []);
            }
        }));
    },

})