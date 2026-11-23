({

    doInit: function(component, event, helper) {
        // VERY IMPORTANT API NAME
        // Matches DropdownRadioCombo and Dropdown namespace
        var dropdownComponentName = 'c:MarketplaceFormDropdown';
        // if (component.get('v.value') && component)
		
        var input = component.get('v.dropdown');
        $A.createComponent(dropdownComponentName,
            Object.assign({
                disabled: component.get('v.disabled')
            }, input, {
                "aura:id": "dropdown",
                "required": component.get('v.apiName')=='categoryAndSubCategory' ? true : component.get('v.required'),
                "value": component.getReference('v.dropdownValue'),
                "layoutItemSize": input.layoutItemSize || 12, // defaults to full width
                "layoutItemMediumDeviceSize": input.layoutItemMediumDeviceSize || input.layoutItemSize || 12,
                "updateFormCallback": $A.getCallback(function() {
                    helper.handleUpdateDropdown(component, helper);
                })
            }),
            function(newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    if (component.isValid()) {
                        if(component.get('v.apiName')=='categoryAndSubCategory'){
                           component.set('v.valid', false);  
                           //component.set('v.touched',true);
                        }
                        
                        component.set('v.dropdownComponent', newComponent);
                        component.set('v.errorAnchorLabel', input.errorAnchorLabel || input.label);
                        helper.updateForm(component);
                        helper.handleDropdownValueChange(component, helper);
                    }
                } else if (status === "INCOMPLETE") {
                    console.error("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.error("Error: " + errorMessage);
                }
            });
        //---- US 382505 --
        if(component.get('v.isEdit')){
           //if edit mode, save the initial values in an attribute to revert changes,
           // if user clicks cancel on confirm dialogue.
            component.set('v.initialDropdownValue',component.get('v.dropdownValue'));
            component.set('v.initialRadioValue',component.get('v.radioValue') );
           
        }
        component.set('v.firstLoad',false); 
        //----US382505 End ---- 
    },

    handleDropdownValueChange: function(component, event, helper) {
        var fieldName = component.get('v.fieldName');
         if(component.get('v.isEdit') && ! component.get('v.firstLoad') &&
            fieldName =='Tab1DropdownRadioCombo'){
            component.set('v.firstLoad',true);
            
            var confirmValue = confirm($A.get("$Label.c.PMP_Edit_offering_Category_Change_Confirm_Message"));
            if(confirmValue== true){
                
        		helper.handleDropdownValueChange(component, helper,true);
            }
             else{
                 component.set('v.dropdownValue',component.get('v.initialDropdownValue'));
                 component.set('v.radioValue',component.get('v.initialRadioValue') )
                
                 var init = component.get('c.doInit');
                 $A.enqueueAction(init);
                 setTimeout(function(){component.set('v.firstLoad',false);},2000);
             }
         }
        else{
            helper.handleDropdownValueChange(component, helper);
            
        }
        /* helper.handleDropdownValueChange(component, helper);
        console.log('handledropdownvalchange-->'); */
    }
})