({
    fetchIPARecordType: function(component) {
        var action = component.get("c.getIPARecordType");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                if (result && result.recordTypeId && result.recordTypeName && result.recordTypeDeveloperName) {
                    // Set IPA record type data
                    component.set("v.selrecordtype", result.recordTypeId);
                    component.set("v.selrecordtypeName", result.recordTypeName);
                    component.set("v.selrecordtypeDeveloperName", result.recordTypeDeveloperName);
                    component.set("v.recordTypesFetched", true);
                    
                } else {
                    this.showToast("Error", "Invalid IPA record type data received", "error");
                    component.set("v.showNewButton", false);
                }
                
            } else {
                component.set("v.showNewButton", false);
                component.set("v.recordTypesFetched", false);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                title: title,
                message: message,
                type: type,
                duration: 5000
            });
            toastEvent.fire();
        } 
    },

    openTypeSelector: function(component) {
        // Create and show type selector modal for user to choose between Client, Datacenter, and IPA
        var self = this;
        $A.createComponent(
            "c:Core_MDF_OutcomeBased_TypeSelector",
            {
                parentComponent: component,
                userCreationPermissions: component.get('v.userCreationPermissions')
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    var headerLabel = "Create Outcome-Based Campaign";
                    // showCustomModal returns a Promise that resolves to the overlay panel instance
                    component.find("overlayLib").showCustomModal({
                        header: headerLabel,
                        body: content,
                        showCloseButton: true,
                        cssClass: "slds-modal_small",
                        // Refresh the tab whenever this modal closes, whether via X, Cancel, or code
                        closeCallback: function() {
                            $A.get("e.force:refreshView").fire();
                        }
                    }).then(function(modalOverlay) {
                        // Store resolved overlay reference for closing from child component
                        component.set("v.modalOverlay", modalOverlay);
                    });
                } else {
                    self.showToast("Error", "Failed to create type selector: " + status, "error");
                }
            }
        );
    }
    ,

    openIPAForm: function(component, parentComponent) {
        var self = this;
        parentComponent = parentComponent || component;

        var recordTypeId = parentComponent.get("v.selrecordtype");
        var recordTypeName = parentComponent.get("v.selrecordtypeName");
        var recordTypeDeveloperName = parentComponent.get("v.selrecordtypeDeveloperName");

        if (!recordTypeId || !recordTypeName || !recordTypeDeveloperName) {
            this.showToast("Error", "Invalid record type data. Please refresh the page.", "error");
            return;
        }

        $A.createComponent(
            "c:Core_MDF_CreateEditOutcomeBasedActivity",
            {
                recordId: parentComponent.get("v.recordId"),
                recordtype: recordTypeId,
                recordtypeName: recordTypeName,
                recordtypeDeveloperName: recordTypeDeveloperName,
                parentComponent: parentComponent
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    try {
                        var headerLabel = $A.get("$Label.c.Core_MDF_NewOutcomeBasedCampaign");
                        var ol = parentComponent.find("overlayLib");
                        if (!ol) { self.showToast('Error','Overlay library not found','error'); return; }
                        ol.showCustomModal({
                            header: headerLabel,
                            body: content,
                            showCloseButton: true,
                            cssClass: 'slds-modal_large',
                            closeCallback: function() { $A.get('e.force:refreshView').fire(); }
                        }).then(function(modalOverlay) { parentComponent.set('v.modalOverlay', modalOverlay); }).catch(function(err){
                            self.showToast('Error','Failed to show IPA form modal: '+(err && err.message?err.message:err),'error');
                        });
                    } catch (e) {
                        self.showToast('Error', 'Exception opening IPA form modal: ' + e.message, 'error');
                    }
                } else {
                    self.showToast('Error', 'Failed to create IPA form. Please try again.', 'error');
                }
            }
        );
    },

    /**
     * Decide modal flow based on user permissions stored on component.
     * - If user has both IPA and (CCF or DCF) permissions => show type selector
     * - If user has only IPA => open IPA form directly
     * - If user has only CCF/DCF => open CCF/DCF form directly (prefer CCF if both)
     */
    handleOpenModalFlow: function(component) {
        var perms = component.get('v.userCreationPermissions') || {};
        // If permissions haven't been fetched yet, fetch them now and re-run flow
        var permsFetched = component.get('v.permsFetched');
        if (!permsFetched && !component.get('_permsReloading')) {
            component.set('_permsReloading', true);
            var self = this;
            var action = component.get('c.getUserCreationPermissions');
            action.setCallback(this, function(response) {
                if (response.getState() === 'SUCCESS') {
                    var newPerms = response.getReturnValue() || {};
                    component.set('v.userCreationPermissions', newPerms);
                    component.set('v.permsFetched', true);
                    component.set('_permsReloading', false);
                    // re-run decision flow now that perms are available
                    self.handleOpenModalFlow(component);
                } else {
                    component.set('_permsReloading', false);
                    self.showToast('Error', 'Unable to fetch creation permissions. Please try again.', 'error');
                }
            });
            $A.enqueueAction(action);
            return;
        }
        // permissions available
        var hasIPA = !!perms.hasIPA;
        var hasCCF = !!perms.hasCCF;
        var hasDCF = !!perms.hasDCF;

        // If user has IPA and also CCF/DCF, show type selector
        if (hasIPA && (hasCCF || hasDCF)) {
            this.openTypeSelector(component);
            return;
        }

        // If user has only IPA -> open IPA form directly
        if (hasIPA && !hasCCF && !hasDCF) {
            this.openIPAForm(component, component);
            return;
        }

        // If user has only CCF/DCF -> open CCF/DCF form directly (prefer CCF)
        if (!hasIPA && (hasCCF || hasDCF)) {
            // call getClientRecordType if CCF present, otherwise datacenter
            var actionName = hasCCF ? 'c.getClientRecordType' : 'c.getDatacenterRecordType';
            // reuse existing fetchRecordTypeAndOpenForm flow in the type selector helper by creating the component and calling helper
            var self = this;
            // fetch the record type using server action directly
            var action = component.get(actionName);
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    if (result && result.recordTypeId) {
                        // create CCF/DCF form directly
                        $A.createComponent(
                            'c:Core_MDF_CreateEditCCFDCFOutcomeBasedActivity',
                            {
                                recordId: component.get('v.recordId'),
                                recordtype: result.recordTypeId,
                                recordtypeName: result.recordTypeName,
                                recordtypeDeveloperName: result.recordTypeDeveloperName,
                                parentComponent: component
                            },
                            function(content, status) {
                                if (status === 'SUCCESS') {
                                    var headerLabel = $A.get('$Label.c.Core_MDF_NewOutcomeBasedCampaign');
                                    component.find('overlayLib').showCustomModal({
                                        header: headerLabel,
                                        body: content,
                                        showCloseButton: true,
                                        cssClass: 'slds-modal_large',
                                        closeCallback: function() { $A.get('e.force:refreshView').fire(); }
                                    }).then(function(modalOverlay) { component.set('v.modalOverlay', modalOverlay); });
                                } else {
                                    self.showToast('Error', 'Failed to open form', 'error');
                                }
                            }
                        );
                    } else {
                        self.showToast('Error', 'Invalid record type data received', 'error');
                    }
                } else {
                    self.showToast('Error', 'Unable to fetch record type', 'error');
                }
            });
            $A.enqueueAction(action);
            return;
        }

        // Default: open type selector
        this.openTypeSelector(component);
    }
})