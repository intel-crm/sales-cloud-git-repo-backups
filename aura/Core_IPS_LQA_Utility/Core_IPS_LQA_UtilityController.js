({
    doInit: function (component, event, helper) {  
		//Start--Replace var with let or const--static code violation fix--harsha--14/06/21
        //var recId = component.get("v.recordId");
        let recId = component.get("v.recordId");
        //var src =  component.get("v.sourceBtn");
		const src =  component.get("v.sourceBtn");
        if(src == 'Accept Case'){            
            //var userId = $A.get("$SObjectType.CurrentUser.Id");
			const userId = $A.get("$SObjectType.CurrentUser.Id");
            component.set("v.caseRecord.OwnerId",userId);
            setTimeout(function(){
                /* This event is fired only in case of accept case to close the pop up and immediately call save method */
                component.set("v.spinnerOn", true);
                //var compEvent = component.getEvent("closeActionModalEvent");
                const compEvent = component.getEvent("closeActionModalEvent");
                compEvent.fire();
            }, 1000);
        }        
    },
    
    handleAccept : function(component, event, helper) {
        //var src =  component.get("v.sourceBtn");
        const src =  component.get("v.sourceBtn");
        if(src == 'Accept Case'){     
            //var userId = $A.get("$SObjectType.CurrentUser.Id");
            const userId = $A.get("$SObjectType.CurrentUser.Id");
            component.set("v.caseRecord.OwnerId",userId);
            helper.saveRecord(component);
        }
        $A.get('e.force:closeQuickAction').fire();
    },
    
    handleCancel : function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
    
    saveCase : function(component, event, helper) {
        //var src =  component.get("v.sourceBtn");
        const src =  component.get("v.sourceBtn");
        component.set("v.spinnerOn", true);
        if(src == 'Invalid Case'){
            component.set("v.caseRecord.Status", "Closed");
            component.set("v.caseRecord.Core_Sub_Status__c", "Invalid");
        }
        /*   
			Added for US551220 - LEX: Change Case Status to Closed (FAE) 
		*/
        if(src == 'Close Case'){
            //var statusClosedStr = $A.get("$Label.c.Core_IPS_Case_Status_Closed");
			const statusClosedStr = $A.get("$Label.c.Core_IPS_Case_Status_Closed");
            //End--Replace var with let--static code violation fix--harsha
            component.set("v.caseRecord.Status", statusClosedStr);
            component.set("v.caseRecord.Core_Sub_Status__c", statusClosedStr);
        }
        helper.saveRecord(component);
	}
})