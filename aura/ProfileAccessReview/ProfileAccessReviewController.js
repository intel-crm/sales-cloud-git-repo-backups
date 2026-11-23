({
    doInit: function(component, event, helper) {
       /* var cmpTarget = component.find('CRUDTable');
        $A.util.addClass(cmpTarget, 'slds-hide');
        var cmpTarget = component.find('FLSTable');
        $A.util.addClass(cmpTarget, 'slds-hide'); */
        var action1 = component.get("c.getProfileNames");
        var action2 = component.get("c.getObjectNames");
        action1.setCallback(this, function(response) {
            var state1 = response.getState();
            if (state1 === "SUCCESS"){
                var profiles = response.getReturnValue();
         		  var profileValues = [];
                for (var i = 0; i < profiles.length; i++) {
                    profileValues.push({
                        label: profiles[i],
                        value: profiles[i]
                    });
                } 
                component.set("v.ProfileList", profileValues);
            }
        });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var objects = response.getReturnValue();
                var objectValues = [];
                for (var j = 0; j < objects.length; j++) {
                    objectValues.push({
                        label: objects[j],
                        value: objects[j]
                    });
                } 
                component.set("v.ObjectList", objectValues);
                component.set("v.AllObjectList", objectValues);
            }
        }); 
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
    },
    search: function(component, event, helper) {
        // Filter list
        helper.searchFunction(component);
    },
    
    handleObjectChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");
         
        //Update the Selected Values  
        component.set("v.SelectedObjectList", selectedValues);
    },
     
    getSelectedObjectFLS : function(component, event, helper){
        //Get selected Genre List on button click 
        var cmpTarget = component.find('CRUDTable');
        $A.util.addClass(cmpTarget, 'slds-hide');
        var cmpTarget = component.find('FLSTable');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        var inputCmp = component.find('profile');
        var profileNames = inputCmp.get("v.value");
        console.log('Profile ' + profileNames);
        var selectedValues = component.get("v.SelectedObjectList");
        console.log('Objects ' + selectedValues);
        helper.callServer(component,
                              "c.profileAccess",
                              function(response){    
                                  console.log('response: '+response);
                                  component.set("v.FieldPermissionsList", response);
                                  
                              },
                              {profileName:profileNames,objectName:selectedValues}
                             );
       
    },
    
    getSelectedObjectCrud : function(component, event, helper){
        //Get selected Genre List on button click 
        var cmpTarget = component.find('FLSTable');
        $A.util.addClass(cmpTarget, 'slds-hide');
        var cmpTarget = component.find('CRUDTable');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        var inputCmp = component.find('profile');
        var profileNames = inputCmp.get("v.value");
        console.log('Profile ' + profileNames);
        var selectedValues = component.get("v.SelectedObjectList");
        console.log('Objects ' + selectedValues);
        helper.callServer(component,
                              "c.profileCRUD",
                              function(response){    
                                  console.log('response: '+response);
                                  console.log('profileNames:'+profileNames);
                                  console.log('selectedValues:'+selectedValues);
                                  component.set("v.ObjectPermissionsList", response);
                                  
                              },
                              {profileName:profileNames,objectName:selectedValues}
                             );
        
    }
})