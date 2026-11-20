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
                
                var selOptResult = response.getReturnValue().selectedOptionLst;
                var selectedUIOptions = component.get("v.selectedOptions");
                if(!component.get("v.updateCountry") && !component.get("v.isIpaCloneAct")){
                    if (fldname != 'Core_MDF_Activity_SubType_nm__c' && fldname != 'Core_MDF_Member_Acceptor_Id__c') {
                        component.set("v.selectedOptions", selOptResult);
                    }
                    else{
                        var picklistSelectedOptions = [];
                        var checkSplitedValue = false;                                                      
                        if(selectedUIOptions != undefined && !$A.util.isEmpty(selectedUIOptions)){
                            for (var i = 0; i < selectedUIOptions.length; i++) {
                                if(selectedUIOptions[i].includes(';')){
                                    checkSplitedValue = true;
                                }
                                if(!checkSplitedValue){
                                    picklistSelectedOptions.push(selectedUIOptions[i]); 
                                }
                            }
                            if(picklistSelectedOptions != null && !selOptResult.includes(picklistSelectedOptions) && !checkSplitedValue) {
                                component.set("v.selectedOptions", picklistSelectedOptions);
                            }else{
                             component.set("v.selectedOptions", selOptResult);
                            }
                        } else{
                            component.set("v.selectedOptions", selOptResult);
                        }
                    }
                    
                }
				/*if (fldname == 'Core_MDF_BU_Split__c' && recId != undefined && recId != null && recId != '') {
					component.set("v.selectedOptions", selOptResult);
					
					if ((component.get("v.recStatus") == 'Draft' || component.get("v.recStatus") == 'Revision Required')
					|| component.get("v.isCloneIPA")) {

						var picklistOptions = [];
						var allAvailableOptions = component.get("v.availableOptions");
						for (var i = 0; i < allAvailableOptions.length; i++) {
							picklistOptions.push(allAvailableOptions[i].value);
						}
						
						if (picklistOptions.length == 1 && !selOptResult.includes(picklistOptions)) {
							if (component.get("v.selectedOptions")) {
								//console.log('selOptResult picklistOptions-->', picklistOptions);
								component.set("v.selectedOptions", picklistOptions);
							}
						}

					}
				}*/
			}
			else {
				alert('Callback failed');
			}

		});
		$A.enqueueAction(action);
},
    
    
    sortArray: function (arrayVal) {
		return arrayVal.sort((a, b) => a.label.localeCompare(b.label));
	},
    
        
})