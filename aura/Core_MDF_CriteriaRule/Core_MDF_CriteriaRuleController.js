({
    doInit : function(component, event, helper) {
        
        var operatorList = [];
        operatorList.push({class: "optionClass",label: "None",value: ""});        
        operatorList.push({class: "optionClass",label: "In",value: "In"});
        operatorList.push({class: "optionClass",label: "Not In",value: "Not In"});
        operatorList.push({class: "optionClass",label: "Equal",value: "Equal"});
        operatorList.push({class: "optionClass",label: "Not Equal",value: "Not Equal"});
        operatorList.push({class: "optionClass",label: "Less Than",value: "Less Than"});
        operatorList.push({class: "optionClass",label: "Greater Than",value: "Greater Than"});
        operatorList.push({class: "optionClass",label: "Less Than or Equal",value: "Less Than or Equal"});
        operatorList.push({class: "optionClass",label: "Greater Than or Equal",value: "Greater Than or Equal"});
        
        component.set("v.operatorOptions", operatorList);
        
        
        //Setting Approval Criteria record on load
        var apprRecId = component.get("v.recordId");
        
        var action = component.get("c.getCriteriaRule");
        action.setParams({ recId : apprRecId });                
        action.setCallback(this, function(res) {
            var state = res.getState();
            if (state === "SUCCESS") {
                var crtRule = res.getReturnValue();
                component.set("v.criteriaRule", crtRule);                
            }
        });
        $A.enqueueAction(action);
        //Setting Criteria
        var action = component.get("c.getFields");
        action.setParams({ recId : apprRecId });        
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
    
    
    deleteRow : function(component, event, helper) {
        var target = event.getSource();
        var indx = target.get("v.value");        
        var crtRuleList = component.get("v.criteriaRule");
        crtRuleList.splice(indx,1);
        component.set("v.criteriaRule",crtRuleList);        
    },
    
    addRow : function(component, event, helper) {        
        var crtRuleList = component.get("v.criteriaRule");
        var apprRecId = component.get("v.recordId");
        crtRuleList.push({'sobjectType':'Core_MDF_Criteria_Rule__c','Core_MDF_Approver__c':apprRecId});
        component.set("v.criteriaRule",crtRuleList);
    },
    
    updateCriteria : function(component, event, helper) {
        //Calling the Apex Function		        
        var crtRule = component.get("v.criteriaRule");
        var recId = component.get("v.recordId");
        var action = component.get("c.updateCriteriaRule");	
        //Setting the Apex Parameter
        action.setParams({crtRuleList : crtRule, apprId : recId });
        action.setCallback(this, function(res) {
            var state = res.getState();
            var type;
            var message;
            
            var appRecId = component.get("v.recordId");
            if (state === "SUCCESS") {
                type = 'Success';
                message = 'Record has been saved successfully.' 
                //$A.get('e.force:refreshView').fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": appRecId,
                    "slideDevName": "related"                    
                });	
                
            }
            else if (res.getState() === "ERROR") {
                type = 'error'
                var errors = res.getError();
                var err = errors[0] && errors[0].message;
                if(err.includes('REQUIRED_FIELD_MISSING')){
                    message = 'Required fields are missing.';
                }
                else if(err.includes('EXCEPTION')){
                    var errlist = err.split('EXCEPTION,');
                    var errlist1 = errlist[1].split(':');
                    message = errlist1[0];
                }
                    else{
                        message = 'Unable to save the changes.'
                    }
            }                
            //Display message 				
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: message,
                duration:'5000',
                key: 'info_alt',
                type: type
            });
            toastEvent.fire();
            if (state === "SUCCESS"){
                
                navEvt.fire();  
                // Added by Harika for fixing DE44818
                setTimeout(function(){window.location.reload();},2000);
            }                	           
        });
        
        $A.enqueueAction(action);
        
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