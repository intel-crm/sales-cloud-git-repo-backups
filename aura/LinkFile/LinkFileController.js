({
	init : function(component, event, helper) {
        
                component.set('v.mycolumns', [
            {label: 'Core File Name', fieldName: 'Core_File_Name__c', type: 'text'},
                {label: 'Core File Description', fieldName: 'Core_File_Description__c', type: 'text'},
                {label: 'Core Category', fieldName: 'Core_Category__c', type: 'text'},
                {label: 'Core file Size', fieldName: 'Core_File_Size__c', type: 'text '}
            ]);

        
		var action = component.get("c.getFiles");
        action.setParams({
            currentcase : "5003F000000gRQv" //component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.lstPositions", response.getReturnValue());
            }
             console.log(component.get("v.lstPositions"));
        });
        $A.enqueueAction(action);
	}
   
})