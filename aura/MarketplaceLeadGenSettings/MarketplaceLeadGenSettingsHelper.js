({
    getLeadSettings : function(component, helper){
		  return new Promise(function(resolve, reject) {
            var action = component.get('c.getExistingSettings');
            
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                                 
            });	
           // console.log('partnerId',partnerId);
            action.setCallback(this, function(response) {
                var status = response.getState();
               
                if (status === "SUCCESS") {
                    component.set('v.data', response.getReturnValue());
                    component.set('v.dataModified', false);
                    component.set('v.loading', false);
                    resolve();
                } else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction( action );
        });      
    },
    
    saveData : function(component, helper) {
        // Call the server to save the Data on success resolve
        
        var newUpdatedData = Object.assign({}, component.get('v.localSettingsData'), {
            languagePreference: component.get('v.languageData')
        });
        console.log("Save DATA :", newUpdatedData);
        
        return new Promise(function(resolve, reject) {
            var action = component.get('c.saveSettingsData');
            
            action.setParams({
                'partnerId':component.get('v.partnerId'),
                'requestJSON': JSON.stringify(newUpdatedData) 
            });	
            
            action.setCallback(this, function(response) {
                var status = response.getState();
                console.log(status);
                if (status === "SUCCESS") {
                    console.log('SAVE SUCCESS :'+ response.getReturnValue());
                    
                    resolve( response.getReturnValue() );
                } else if (status === "INCOMPLETE") {
                    // do something?
                } else if (status === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.error(errors[0].message);
                        };
                    }
                } else {
                    reject('Unknown error.');
                }
            });
            $A.enqueueAction( action );
        });
    },
    
  getPartnerAdminAccountsList: function(component) {
        var action = component.get('c.getPartnerAdminAccounts');
        // Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
         component.set('v.partnerAdminData', actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
      }
})