({
    doInit : function(component, event, helper) {
        
        var partnerId = component.get('v.partnerId');
        console.log('doInit-LeadGenSettings',partnerId);
        helper.getLeadSettings(component, helper);        
        console.log('lang default lead gen data##S : ', component.get('v.languageData'));
        component.set('v.onSaveClick', function(){
            
            component.set('v.dataModified', false);
            // Call Save record to the server
            helper.saveData(component,helper).then(function(){
                
                //console.log('Reached .then');
                var newUpdatedData = Object.assign({}, component.get('v.localSettingsData'), {
                    languagePreference: component.get('v.languageData')
                });
                // upload new data
                component.set('v.data', newUpdatedData);
                component.set('v.dataSaved', true);
                
            });
            
            
        });
        
        
        component.set('v.onCancelClick', function(){
            // reinsert old data to localSettingsData
            $A.enqueueAction(component.get('c.handleDataChange'));
            
        });
        // initialize data
        
        
        component.set('v.dataModified', false);
        
        
        
        component.set('v.columns', [
            {label: $A.get("$Label.c.PMP_Name"), fieldName: 'Name', type: 'text'},
            {label: $A.get("$Label.c.PMP_Email"), fieldName: 'Email', type: 'email'},
            {label: $A.get("$Label.c.PMP_Phone"), fieldName: 'Phone', type: 'text'}
        ]);
        helper.getPartnerAdminAccountsList(component);
    },
    
    handleDataChange : function(component, event, helper) {
        console.log('handleDataChange');
        // Lead Data change
        var data = component.get('v.data');
        var newData = Object.assign({}, data);
        
        component.set('v.localSettingsData', newData);
        // Need to Decouple from localSettingsData.languagePreferences
        console.log('lang default Data : ', component.get('v.languageData'));
        component.set('v.languageData', JSON.parse(JSON.stringify(newData.languagePreference)));
        console.log('lang Data : ', component.get('v.languageData'));
        component.set('v.dataModified', false);
        component.set('v.dataSaved', false);
        
        component.find('language').update();
        
        
    },
    
    handleLocalDataChange: function(component, event, helper) {
        console.log('handleLocalDataChange');
        component.set('v.dataModified', true);
        component.set('v.dataSaved', false);
    },
    
    handleStorefrontAdministratorModal : function(component, event, helper) {
        var modalOpen = component.get("v.storeFrontAdministratorModalOpen");
        var overlay = component.find('storeFrontAdminModal');
        var backdrop = component.find('storeFrontAdminModalBackdrop');
        
        
        modalOpen = !modalOpen;
        component.set("v.storeFrontAdministratorModalOpen", modalOpen);
        // have to manually change it here as transitions wont work if we do it inline
        if (modalOpen) {
            $A.util.removeClass(overlay, 'slds-hide');
            window.setTimeout(
                $A.getCallback(function() {
                    $A.util.addClass(overlay, 'slds-show');
                }), 5
            );
            $A.util.addClass(document.body,'modal-open-no-scroll');
            // TODO add body overrride on css
            //document.body.style.overflowY = 'hidden'; // Commented to fix defect : DE59528 - Prabuddh (Merge carefully)
            
            $A.util.removeClass(backdrop, 'slds-hide');
            $A.util.addClass(backdrop, 'slds-show');
            
            
        } else {
            $A.util.removeClass(document.body,'modal-open-no-scroll');
            // TODO add body overrride on css
            document.body.style.overflowY = '';
            $A.util.removeClass(overlay, 'slds-show');
            $A.util.addClass(overlay, 'slds-hide');
            $A.util.addClass(backdrop, 'slds-hide');
            $A.util.removeClass(backdrop, 'slds-show');
            
            
        }
        // check if mobile prevent opening of window
        event.preventDefault();
        
    },
    
    
    saveSettings: function(component, event, helper){

        if(event.getParam('type') == 'saveLeadSettings'){
            helper.saveData(component, helper);            
        }
        
            
   }
    
})