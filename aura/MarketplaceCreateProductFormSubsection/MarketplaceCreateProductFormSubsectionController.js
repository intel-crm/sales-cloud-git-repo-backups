({

	doInit : function(component, event, helper) {
        var offeringName = component.get('v.formData.offering.Name');
            var isEdit = offeringName == ''? false :true;
        console.log('isEdit-->' +isEdit);
         console.log('inputs-->' , component.get('v.inputs'));
        console.log('Subsection Lang--' +component.get('v.userSelectedLanguage'));
       // component.set('v.isEdit',isEdit);
    var inputBuildPromises = component.get('v.inputs').map(function(input) {
      return new Promise(function(resolve, reject) {
          		console.log('input-->' , input)
				// looks up the lightning component for the given input type (see helper#getApiName)
        var apiName = helper.getApiName(input.type);
				// dynamically builds the input components based on type
				// builds attributes with:
				//   - the type-specific attributes (ie. uploader might have v.currentNumberOfFiles)
				//   - the base attributes (inhereted base attributes for all input types)
				
          		var inputValue, boundValueAttribute = 'v.formData.';
				boundValueAttribute += input.apiName;
				if (input.fieldName) boundValueAttribute += '.' + input.fieldName;
				console.log('boundValAttr-->',JSON.stringify(component.get('v.formData.offering.Name')));
				if (input.doNotSave) {
					inputValue = null;
				} else {
					inputValue = component.getReference(boundValueAttribute);
				}
        $A.createComponent(apiName, Object.assign(input, {
					"aura:id" : "formInput",
            		"name" : input.apiName + (input.fieldName ? '__' + input.fieldName : ''),
					"required" : input.required ? true : false,
					"value": inputValue,
            		"currentStepTouched" : component.getReference('v.currentStepTouched'),
					"layoutItemSize" : input.layoutItemSize || 12, // defaults to full width
					"layoutItemMediumDeviceSize" : input.layoutItemMediumDeviceSize || input.layoutItemSize || 12,
					"updateFormCallback": component.getReference('v.updateFormCallback'),
            		"isEdit": isEdit,
            		"userSelectedLanguage": component.get('v.userSelectedLanguage'), 
            "offeringCreatedLanguage" : component.get('v.formData.offering.PMP_Offering_Language_Nm__c')
        }), function(newComponent, status, errorMessage) {
					if (status === "SUCCESS") {
						resolve(newComponent);
					} else if (status === "INCOMPLETE") {
            reject("No response from server or client is offline.");
          } else if (status === "ERROR") {
            reject("Error in (" + input.apiName + "):" + errorMessage);
          }
        });
      });
    });

		// once all the inputs are built this promise is resolved
		var inputsBuiltPromise = Promise.all(inputBuildPromises).then(function(inputs) {
      component.set("v.inputsBody", inputs);
    }).catch(function(errorMessage) {
      console.error('Create Offering Wizard: problem with inputs.', errorMessage);
    });
    component.set('v.inputsBuiltPromise', inputsBuiltPromise);
	},

})