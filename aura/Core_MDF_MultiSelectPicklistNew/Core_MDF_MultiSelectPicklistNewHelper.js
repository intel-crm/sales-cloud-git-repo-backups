({ 
    fetchMultiSelectVal: function (component, event) {
        
		var action = component.get("c.fetchmultipicklist");
        var recId = component.get("v.RecId");
        var Objnm = component.get("v.objName");
        var fldname = component.get("v.fldName");
		//alert("allcntry line 8 helper custommultiselect--> "+ component.get("v.availableOptions"));
  
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
          
                if(fldname != 'Core_MDF_BU_Split__c'){
                    component.set("v.selectedOptions", selOptResult); 
                }
                if(fldname == 'Core_MDF_BU_Split__c' && recId != undefined &&  recId != null && recId != ''){
					component.set("v.selectedOptions", selOptResult);
					if(component.get("v.recStatus") == 'Draft' || component.get("v.recStatus") == 'Revision Required'){
						var picklistOptions = [];
						var allAvailableOptions = component.get("v.availableOptions");
						var selectedOptions = [];
						//selectedOptions = selOptResult.split(";");
						for(var i = 0;i < allAvailableOptions.length; i++){
							picklistOptions.push(allAvailableOptions[i].value);
						}

						if(picklistOptions.length == 1 && !selOptResult.includes(picklistOptions)){
							component.set("v.selectedOptions", picklistOptions);
						}

					}                    
                }
           // console.log('Selected Options-' + selOptResult);
               
                    
            }
             else {
					alert('Callback failed');//component.set("v.loadExceptionsAccountLayout", true);
			   	}
            
			//	   alert("allcntry line 8 helper custommultiselect--> "+ component.get("v.availableOptions"));

			
		});
		$A.enqueueAction(action);
},
    
    
    sortArray: function (arrayVal) {
		return arrayVal.sort((a, b) => a.label.localeCompare(b.label));
	},
    
        
})