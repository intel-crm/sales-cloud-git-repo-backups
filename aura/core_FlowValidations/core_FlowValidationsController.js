({
    invoke : function(component, event, helper) {
        var message = component.get("v.messageText");//'test'
        var type = component.get("v.type");
        var errorType='';
        var ValidationMessage='';
        if(message.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION:")){
            errorType='FIELD_CUSTOM_VALIDATION_EXCEPTION:';
        }else if(message.includes("ENTITY_IS_LOCKED:")){
            errorType='ENTITY_IS_LOCKED:';   
        }
        
        if(!(errorType != "" && errorType != null && errorType.trim().length > 0)){  
            console.log('#else'+message);           
        }else{
            let firstIndex=(message.indexOf(errorType)+errorType.length);
            let lastIndex = message.indexOf('You can look up ExceptionCode values');
            ValidationMessage = ValidationMessage+'\n'+message.substring(firstIndex,lastIndex);
            
            console.log('#2FirstIndex'+ValidationMessage);
            
            helper.showToast(component, event, helper, type, ValidationMessage);
            helper.refresh(component, event, helper);
        }
        
        	/* var lst = [];
        	var testmsg='Error element Update_All_Opportunity_Products (FlowRecordUpdate).The flow tried to update these records: 00k2D00000560BBQAY. This error occurred: FIELD_CUSTOM_VALIDATION_EXCEPTION: This Value is only for Data ops Profile. Please Select any of these value mention below Americas Partner Holding EMEA Partner Holding APJ Partner Holding PRC Partner Holding Undefined. You can look up ExceptionCode values in the SOAP API Developer Guide.---The flow tried to update these records: 00k2D00000560BGQAY. This error occurrd:ENTITY_IS_LOCKED:Entity Error. You can look up ExceptionCode values in the SOAP API Developer Guide.';
        	var array = message.split("The flow tried to "); 
        	array.shift();
        	console.log('array'+array);
           	for(var i=0; i<array.length; i++){
            let firstIndex=(array[i].indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION')+errorType.length);
            let lastIndex = array[i].indexOf('You can look up ExceptionCode values');
            ValidationMessage = ValidationMessage+'\n'+array[i].substring(firstIndex,lastIndex);
            console.log('#2FirstIndex'+ValidationMessage);
        	}*/
    }
})