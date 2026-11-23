({
    doInit : function(component, event, helper) {  
     },
    saveEntitlementChanges : function(component,event,helper){
        var sContactIdStr = component.get("v.sContactIdStr");
        component.set("v.recordNotFound", true);
        helper.saveEntitlements(component, event, sContactIdStr); 
    },
    displayContactEntitlements :function(component,event,helper){
        var sContactIdStr = event.getParam("sContactIdStr");
        var getSource = event.getParam("sourceCmp");
        component.set("v.sourceCmp",getSource);
        
        //var pContactIdStr = event.getParam("pContactIdStr");
       /* var onePartnerIdStr = event.getParam("onePartnerIdStr");
        var PCAccountIdStr = event.getParam("intelAccountIdStr_PC");*/
        var showEntitlements = event.getParam("showEntitlements");
        component.set("v.sContactIdStr",sContactIdStr);
        console.log('displayContactEntitlements: ContactId'+sContactIdStr);
        helper.loadEntitlements(component, event,sContactIdStr,showEntitlements); 
    },
    saveEntBtn: function (component, event, helper) {
        component.set("v.recordNotFound", false);
        console.log('access name '+event.getSource().get("v.name"))
        console.log('access checked '+event.getSource().get("v.checked"))
        var entitlementRec = event.getSource().get("v.name")
        var entName = entitlementRec.entitlementNameStr
        var entStatus = entitlementRec.ContactEntitlement ? entitlementRec.ContactEntitlement.Core_Status__c : '';
        var status = event.getSource().get("v.checked")
        console.log('entitlement record'+JSON.stringify(entitlementRec))
		console.log('entitlement Name'+JSON.stringify(entName))
        console.log('entitlement Status'+JSON.stringify(entStatus))
        
        if(entName == "Employee" && status == false ){
            component.set("v.requireValidation", true);
        }
        if(entName == "Partner Admin Delegate" && status == true){
            
            var entitlementsList = component.get("v.lstContactEntitlements");
          for(i = 0; i < entitlementsList.length; i++) {
            if(entitlementsList[i].entitlementNameStr != "Partner Admin Delegate" && entitlementsList[i].entitlementNameStr != "Employee")
                
            {
                entitlementsList[i].readOnly=true;
           }
            else{
                entitlementsList[i].readOnly=false;
            }
            }
            component.set("v.lstContactEntitlements", entitlementsList);
        }
        if(entName== "Partner Admin Delegate" && status== false){
            var entitlementsList = component.get("v.lstContactEntitlements");
          for(i = 0; i < entitlementsList.length; i++) {
            if(entitlementsList[i].entitlementNameStr != "Partner Admin Delegate")
                entitlementsList[i].readOnly=false;
            
           }
            component.set("v.lstContactEntitlements", entitlementsList);
        }
        
        
        
    },
    hideModal: function (component, event, helper) {
        component.set("v.requireValidation", false)
        console.log('entitlementsList '+JSON.stringify(component.get("v.lstContactEntitlements")))
        var entitlementsList = component.get("v.lstContactEntitlements");
        for(i = 0; i < entitlementsList.length; i++) {
            if(entitlementsList[i].entitlementNameStr == "Employee" && entitlementsList[i].isSelected == false) {
                console.log('entitlements ' + i+JSON.stringify(entitlementsList[i]));
                entitlementsList[i].isSelected = true;
            }
        }
        component.set("v.lstContactEntitlements", entitlementsList);
    },
    onAgree: function (component, event, helper) {
        component.set("v.requireValidation", false)
    },
    onCancel:function(component,event,helper){
        var epumRnRURLEvent = $A.get("e.force:navigateToURL");
        epumRnRURLEvent.setParams({
            "url": "/ipa/s/manage-responsibilities"
        });
        epumRnRURLEvent.fire();    
    }
})