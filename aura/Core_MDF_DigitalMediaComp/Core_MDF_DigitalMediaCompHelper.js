({
	fetchPicklistVal : function(component, event, helper) {
		//alert('Helper method');
        var action = component.get("c.fetchpicklistVal");
		var recId = component.get("v.RecId");
        var Objnm = component.get("v.objName");
        //var fldname = component.get("v.fldName");
        var fldname = 'Core_MDF_PagetoLink_Nm__c,Core_MDF_KPI_Nm__c';
        
        action.setParams({
            "objObject":Objnm,
			"fldName": fldname,
            "recordId":recId                      
		});	        
        
		action.setCallback(this, function (response) {
			var state = response.getState();
			//var allOptions = [];
			var selPagetolinkOption = [];
            var selKPIOption = [];
			var selsorted = [];
			if (state === "SUCCESS") {
                var result = response.getReturnValue();
              //  var allOptsrResult = response.getReturnValue().OptionsMap;
                var selPagetolinkOption = response.getReturnValue().selectedPageToLinkOption;
                var selKPIOption = response.getReturnValue().selectedKPIOption;
                               
           /*    if (Object.keys(allOptsrResult).length > 0) 
                {
                    allOptions.push({
                        class: "optionClass",
                        label: $A.get("$Label.c.Core_MDF_PFR_None_Translation"),
                        value: ""
                    });
                    
					for (var key in allOptsrResult) {
						allOptions.push({
							label: allOptsrResult[key],
							value: key
						});
					}
				}
                
                              
                 if (allOptions.length > 0) {
					allOptions = this.sortArray(allOptions);
				}
            
            component.set("v.availableOptions", allOptions);     */ 
            component.set("v.SelPageToLinkOpt", selPagetolinkOption);
            component.set("v.SelKPIOpt", selKPIOption);
                
            console.log('Selected Options-' + selKPIOption);
           // console.log('Available Options-' + allOptions);   
                    
            }
             else {
					alert('Callback failed');//component.set("v.loadExceptionsAccountLayout", true);
			   	}
            
           
			
		});
		$A.enqueueAction(action);
	},
    
    
    sortArray: function (arrayVal) {
		return arrayVal.sort((a, b) => a.label.localeCompare(b.label));
	},
})