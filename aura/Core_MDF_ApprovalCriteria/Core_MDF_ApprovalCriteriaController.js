({
    doInit : function(component, event) {
        var crtObjectType;
        var options = [];
        options.push({class: "optionClass",label: "None",value: ""});        
        options.push({class: "optionClass",label: "In",value: "In"});
        options.push({class: "optionClass",label: "Not In",value: "Not In"});        
        options.push({class: "optionClass",label: "Equal",value: "Equal"});
        options.push({class: "optionClass",label: "Not Equal",value: "Not Equal"});
        options.push({class: "optionClass",label: "Less Than",value: "Less Than"});
        options.push({class: "optionClass",label: "Greater Than",value: "Greater Than"});
        options.push({class: "optionClass",label: "Less Than or Equal",value: "Less Than or Equal"});
        options.push({class: "optionClass",label: "Greater Than or Equal",value: "Greater Than or Equal"});
		component.set("v.operatorOptions", options);                

		//Setting Approval Criteria record on load
		var recId = component.get("v.recordId");
        var action = component.get("c.getCriteria");
		action.setParams({ recId : recId });                
        action.setCallback(this, function(res1) {
            var state1 = res1.getState();
            if (state1 === "SUCCESS") {
                var apprCrt = res1.getReturnValue();
                crtObjectType = apprCrt.Core_MDF_Object_Type__c;
                component.set("v.approvalCriteria", apprCrt);                
            }
        });
		$A.enqueueAction(action);
        
        // Fetch all the object and set allObjects attributes
        var action1 = component.get("c.getAllObjects");
        action1.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var resultMap = res.getReturnValue();
                var objList = [];
				objList.push({
                        label: "None",
                        value: ""
                    });
            	for (var index=0; index < resultMap.length; index++) {
                    var fieldNameWithLabel = resultMap[index].split('#;');
                	objList.push({
                        class: "optionClass",
                        label: fieldNameWithLabel[0],
                        value: fieldNameWithLabel[1]
                        
                    });
                component.set("v.allObjects", objList);               
                }}
        });
		$A.enqueueAction(action1);                        
    },
    
    getFields : function(component, event){
               
        var sObjectNameValue = component.find("selectedObject").get("v.value");     
        var action = component.get("c.getAllFields");
		action.setParams({ sObjectName : sObjectNameValue });        
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var resultMap = res.getReturnValue();
                var fieldList = [];
                fieldList.push({
                        class: "optionClass",
                        label: "None",
                        value: ""
                    });
            	for (var index=0; index < resultMap.length; index++) {
                    var fieldNameWithLabel = resultMap[index].split('#;');
                	fieldList.push({
                        class: "optionClass",
                        label: fieldNameWithLabel[0],
                        value: fieldNameWithLabel[1]
                        
                    });
            	}
                component.set("v.options", fieldList);
                
            }
        });
		$A.enqueueAction(action);
	},	
        
	create : function(component, event, helper) {
		//Calling the Apex Function		        
		var appCrt = component.get("v.approvalCriteria");
		var action1 = component.get("c.updateApprovalCriteria");
	
		//Setting the Apex Parameter
		action1.setParams({approvalCriteria : appCrt});
        action1.setCallback(this, function(res) {
            var state = res.getState();
            var type;
            var pageMessage = '';
            var recId = res.getReturnValue();
            if (state === "SUCCESS") {
                type = 'Success';
                pageMessage = 'Record has been saved successfully.' 
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					"recordId": recId,
					"slideDevName": "detail"
                });
				
            }
			else if (res.getState() === "ERROR") {
                type = 'error'
				var errors = res.getError();
                var err = errors[0] && errors[0].message;
                if(err.includes('REQUIRED_FIELD_MISSING')){
                   	pageMessage = 'Required fields are missing.';
                   }
                else if(err.includes('EXCEPTION')){
                    var errlist = err.split('EXCEPTION,');
                    var errlist1 = errlist[1].split(':');
					pageMessage = errlist1[0];
                }
				else{
                    pageMessage = 'Unable to save the changes.'
                }
            }
            //Display message    
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: pageMessage,
                duration:'5000',
                key: 'info_alt',
                type: type,
                mode: 'pester'
            });
			toastEvent.fire();
			if (state === "SUCCESS"){
				navEvt.fire();
                setTimeout(function(){window.location.reload();},2000);
                //window.location.reload();                                 
			}
		});        
        $A.enqueueAction(action1);        
    },
    
    cancel : function(component, event, helper) {
		var recId = component.get("v.recordId");        
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
			"recordId": recId,
			"slideDevName": "detail"
		});
        if(recId == null){
			var homeEvent = $A.get("e.force:navigateToObjectHome");
			homeEvent.setParams({
				"scope": "Core_MDF_Criteria__c"
			});
			homeEvent.fire();    
        }else{
			navEvt.fire();
        }
    },
       
})