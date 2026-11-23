({

    handleDropdownValueChange: function(component, helper,deleteOffSpec) {
        // VERY IMPORTANT API NAME HERE
        // This matches the DropdownRadioCombo and Dropdown namespace ie. ISGForm... or IntelForm...
        var radioComponentName = 'c:MarketplaceFormRadio';

        var dropdownValue = component.get('v.dropdownValue');
        if (typeof dropdownValue == 'undefined' || dropdownValue == '') return;
        var radioIdx = 0;
        component.get('v.dropdown').options.forEach(function(opt, idx) {
            if (opt.value == dropdownValue) radioIdx = idx;
        });
        var input = component.get('v.radios')[radioIdx];
        if(dropdownValue){ //Added by Shahrukh to hide the radio values initially
            $A.createComponent(radioComponentName,
                Object.assign({
                    disabled: component.get('v.disabled')
                }, input, {
                    "aura:id": "radio",
                    "required": input.required === true || input.required === false ? input.required : component.get('v.required'),//Added by raj as part of [03/26] merge
                    "value": component.getReference('v.radioValue'),
                    "valueType": 'complex',
                    "layoutItemSize": input.layoutItemSize || 12, // defaults to full width
                    "layoutItemMediumDeviceSize": input.layoutItemMediumDeviceSize || input.layoutItemSize || 12,
                    "updateFormCallback": $A.getCallback(function(cmp) {
                        helper.handleUpdateRadio(component, helper,deleteOffSpec,cmp);
                    })
                }),
                function(newComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        if (component.isValid()) {
                            component.set('v.radioComponent', newComponent);
                        }
                    } else if (status === "INCOMPLETE") {
                        console.error("No response from server or client is offline.");
                    } else if (status === "ERROR") {
                        console.error("Error: " + errorMessage);
                    }
                });
          }
    },

    handleUpdateDropdown: function(component, helper) {
        /*Added by raj to check whether level-2 subcategory is mandatory or not*/
        var dropdownValue = component.get('v.dropdownValue');
        if (typeof dropdownValue == 'undefined' || dropdownValue == '') return;
        var radioIdx = 0;
        component.get('v.dropdown').options.forEach(function(opt, idx) {
            if (opt.value == dropdownValue) radioIdx = idx;
        });
        var input = component.get('v.radios')[radioIdx];
        var isLevel2Required = input.required;
        /*Changes End*/
        component.set('v.valid', (!component.get('v.required') && !isLevel2Required));
        if (component.get('v.dropdownValue')) {
            component.set('v.value', [{
				id: component.get('v.dropdownValue')
			}]);
        }
        /*US523547 : End customer type field on the Create offering tab1 will be non mandatory, if selected category
        contains IoT as business segment */
        if(component.get('v.apiName')=='categoryAndSubCategory'){
            
            helper.handleCategoryDropdownUpdate(component,event,helper);
        }
        
        helper.updateForm(component)
            
            
    },

    handleUpdateRadio: function(component, helper,deleteOffSpec,cmp) {
        var fieldName = component.get('v.fieldName');
        console.log('firstLoad-->'+component.get('v.firstLoad'));
        if(component.get('v.isEdit') && ! component.get('v.firstLoad')&&
          fieldName =='Tab1DropdownRadioCombo'){
            component.set('v.firstLoad',true);
            
            var confirmValue = confirm($A.get("$Label.c.PMP_Edit_offering_Category_Change_Confirm_Message"));
            if(confirmValue== true){
                
                var value =(component.get('v.radioValue'))? [{
                id: component.get('v.dropdownValue')
                }].concat(component.get('v.radioValue')):[{id: component.get('v.dropdownValue')}];
            component.set('v.value', value);
            component.set('v.valid', true);
            helper.updateForm(component,'deleteOfferingSpecifications');
            }
            else{
                function resetValue(callback){
                    helper.handleDropdownValueChange(component,helper);
                    callback();
                }
                
                resetValue(function(){
                    setTimeout(function(){component.set('v.firstLoad',false);},2000);
                    //component.set('v.dropdownValue',component.get('v.initialDropdownValue'));
                    
                });
                
                
                 
            }
        }
        else{
            if(component.get('v.radioValue')){
                var value = [{
                id: component.get('v.dropdownValue')
            	}].concat(component.get('v.radioValue'));
                component.set('v.value', value);
                /*Added by raj as part of merge [03/26]*/
                component.set('v.valid', cmp.get('v.valid'));
                var dropdown = component.find("dropdown");
                component.set('v.touched', dropdown.get('v.touched') || cmp.get('v.touched'));
                component.set('v.errorAnchorLabel', cmp.get('v.errorAnchorLabel') || cmp.get('v.label'));
                /*Merge Changes End*/
                if(deleteOffSpec){
                    helper.updateForm(component,'deleteOfferingSpecifications');
                }
                else{helper.updateForm(component);}
                
            }
            else{
                var value = [{
                id: component.get('v.dropdownValue')
            	}];
                component.set('v.errorAnchorLabel', cmp.get('v.errorAnchorLabel') || cmp.get('v.label'));//Added by raj as part of POC[03/26]
                component.set('v.value', value);
                component.set('v.valid', true);
                if(deleteOffSpec){
                    helper.updateForm(component,'deleteOfferingSpecifications');
                }
                else{helper.updateForm(component);}
            }
            
        }
    },
    
    handleCategoryDropdownUpdate : function(component,event,helper){
        //get all the options for the dropdown and iterate over them.
        var dropdownOptions = component.get('v.dropdown.options');
            dropdownOptions.forEach(function(option) {
                console.log('insideddcombo-->' +option.label+ option.businessSegments);
                //if selected option matches with the iter option then we check for its business segment.
                if(component.get('v.dropdownValue') == option.value ){
                    var isMandatory = true;
                    //if business segment includes IoT(case sensitive), ECT field will not be mandatory
                    if(option.businessSegments.includes("IoT")){
                        isMandatory = false;
                    }
                    //This will be communicated to the main component via event.
                    var isEndCustomerTypeMandatoryEvent = component.getEvent("isEndCustomerTypeMandatory");
                    isEndCustomerTypeMandatoryEvent.setParams({"isMandatory" : isMandatory });
                    isEndCustomerTypeMandatoryEvent.fire();
                    console.log('eventFired!!-->' +isMandatory);
                }
            });
    },
    showErrorMessage : function(component, helper) {
         var dropdown = component.find("dropdown");
         if (dropdown) dropdown.showErrorMessage();
         var radio = [].concat(component.find("radio"))[0];//Added by raj as part of [03/26] merge
         if (radio) radio.showErrorMessage();
    },

})