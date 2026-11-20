({

  processInput : function(component, helper) {
    var valid = component.find("input").reportValidity();
      if(!component.get('v.required') && !component.get('v.value')){
          console.log('insideNot required' );
          valid = true;
      }  
    component.set('v.valid', valid);
    component.set('v.touched', true);
    helper.updateForm(component);
  },

  processInputWithoutReport : function(component, helper) {
    var valid = component.find("input").checkValidity();
		component.set('v.valid', valid);
    component.set('v.touched', true);
    helper.updateForm(component);
  },
  setInitialValue : function(component, helper) {
    // set initial value if textValue exists
    if (component.get('v.textValue')) component.set('v.value', component.get('v.textValue'));
      console.log(component.get('v.textValue'));
    component.set('v._value', component.getReference('v.value'));
  },

  setInitialComplexValue : function(component, helper) {
     // console.log('intialValue',component.get('v.textValue'));
    var initialValue = component.get('v.textValue');
    component.set('v._value', initialValue || '');
    if (initialValue) helper.setComplexValue(component, helper);
  },

  setComplexValue : function(component, helper) {
      //console.log('additionalValues',JSON.stringify(component.get('v.additionalValues')));
      var obj=component.get('v.additionalValues');
     /* console.log('obj::',obj);
    component.set('v.value', Object.assign({},
      component.get('v.additionalValues') || {}, 
      { value: component.get('v._value') }
    ));*/
    console.log('obj::', obj);
//SemGrep Fix TWC729-7771
    // Get the additionalValues or set it to an empty object if it doesn't exist
    var additionalValues = component.get('v.additionalValues') || {};
    
    // Create a new object for merged values
    var mergedValues = {};
    
    // Copy properties from additionalValues into mergedValues
    for (var key in additionalValues) {
        if (additionalValues.hasOwnProperty(key)) {
            mergedValues[key] = additionalValues[key];
        }
    }
    
    // Add the value property
    mergedValues.value = component.get('v._value');
    
    // Set the merged values to the component
    component.set('v.value', mergedValues);
    


      
      //component.get('v.additionalValues').length>0?component.set('v.value', component.get('v.additionalValues')):'';
    //console.log('additionalValues1',component.get('v.value'));
  },
  
    checkError : function(component, helper, label){
        
        component.set("v.valid", false);
        component.set('v.hasError', true);
        component.set('v.error',label); 
        window.localStorage.setItem('hideSave', true);
        var cmpTarget = component.find('input'); 
        $A.util.addClass(cmpTarget, 'slds-has-error');
        
    },
    
    checkNoError : function(component, helper){
        
       component.set("v.valid", true);
       component.set('v.hasError', false);
        window.localStorage.setItem('hideSave', false);
       var cmpTarget = component.find('input'); 
       $A.util.removeClass(cmpTarget, 'slds-has-error');
        
    },
    getLanguageName : function(languageCode) {
      
		// this map is a list of the available languages and their locale names
		var languageMap = {
      
		  zh_CN:           "Simplified Chinese",
		  en_US:       "English",
		  ja_JP:       "Japanese", 
		  
		};
		return languageMap[languageCode];
	},
    
    showErrorMessage : function(component, helper) {
    component.find("input").showHelpMessageIfInvalid();
  	},
   

})