({
	doInit : function(component, event, helper){
       
        var url = window.location.href;
        var temp = url.split("recordId="); 
        var temp1 = temp[1].split("&obj=");
        
        component.set("v.recordId",temp1[0]);
        component.set("v.objectName",temp1[1]);
        
        
        var action = component.get("c.removeRecordCache"); 
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "objectName": component.get("v.objectName")
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                component.set("v.cacheFlag", a.getReturnValue());
                console.log('value--->',a.getReturnValue());
                if(component.get("v.cacheFlag") === true){
                    helper.showToastSuccess(component, event, helper); 
                  
                }
                if(component.get("v.objectName") === 'OfferingDetail'){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({ "url": "/pmp-partner-offering/PMP_Partner_Offering__c" });
                    urlEvent.fire();
                }
                else if (window.location.href.indexOf("pmp-partner-offering") === -1 && !(component.get("v.objectName") === 'Event')){
                     var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({ "url": "/lightning/r/PMP_Partner_Offering__c/"+component.get("v.recordId")+"/view"});
                    urlEvent.fire();
                }
                else if (component.get("v.objectName") === 'Event'){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({ "url": "/pmp-marketplace-event/PMP_Marketplace_Event__c" });
                    urlEvent.fire();
                }
                else if (window.location.href.indexOf("pmp-marketplace-event") === -1){
                     var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({ "url": "/lightning/r/PMP_Marketplace_Event__c/"+component.get("v.recordId")+"/view"});
                    urlEvent.fire();
                }       
            }
            else {
                console.log('error--->');
                helper.showToastError(component, event, helper); 
            }             
        });
        $A.enqueueAction(action);
     }   
})