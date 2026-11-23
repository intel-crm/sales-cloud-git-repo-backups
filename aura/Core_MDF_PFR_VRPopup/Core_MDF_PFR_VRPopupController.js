({
	//Handle Yes and No Scenario
    handleYes : function(component,event,helper){
        helper.sendChoiceYes(component);
    },
    handleNo : function(component,event,helper){
        helper.sendChoiceNo(component);
    },
    
    handleResponse : function(component,event,helper){
        
    	var response = component.get("v.PicklistValue");
    	
    	if(response == 'Yes')
        {
            alert("Inside");
            component.set("v.doApply",true);
        }
    	
	}
})