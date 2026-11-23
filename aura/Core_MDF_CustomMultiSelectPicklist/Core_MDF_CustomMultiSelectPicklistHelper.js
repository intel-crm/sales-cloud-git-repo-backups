({ 
    fetchMultiSelectVal: function (component, event) {
        
		var action = component.get("c.fetchmultipicklist");
        var recId = component.get("v.RecId");
        var Objnm = component.get("v.objName");
        var fldname = component.get("v.fldName");
		   
        if(component.get("v.CloneRecId")!= null && component.get("v.CloneRecId")!= '')
            recId = component.get("v.CloneRecId"); 
        else if(component.get("v.CommunityRecId")!= null && component.get("v.CommunityRecId")!= '')
        	recId = component.get("v.CommunityRecId"); 
 
        //alert("fldName=" + fldname);

		action.setParams({
            "objObject":Objnm,
			"fldName": fldname,
            "recordId":recId                      
		});	        
        
		action.setCallback(this, function (response) {
			var state = response.getState();
			var allOptions = [];
			var selOptions = [];
			var selsorted = [];
			if (state === "SUCCESS") {
                //var result = response.getReturnValue();
                //var allOptsrResult = response.getReturnValue().OptionsMap;
                var selOptResult = response.getReturnValue().selectedOptionLst;
                         
             /*   if (Object.keys(allOptsrResult).length > 0) 
                {
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
            
            component.set("v.availableOptions", allOptions);    */   
            component.set("v.selectedOptions", selOptResult);
           
            //console.log('Selected Options-' + selOptResult);
               
                    
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