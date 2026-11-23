({
    loadEntitlements :function(component,event,helper){
        try{
            var compEvent =  $A.get("e.c:EPUM_Contact_Entitlement_Event"); 
            //var pContactIdStr = component.get("v.pContactIdStr");
            var sContactIdStr = component.get("v.sContactIdStr");
            var sourceComponent = component.get("v.sourceCmp");
            /*var onePartnerIdStr = component.get("v.onePartnerIdStr");
            var intelAccountIdStr_PC = component.get("v.intelAccountIdStr_PC");
           // console.log('pContactIdStr = '+ pContactIdStr);
            console.log('sContactIdStr = '+ sContactIdStr);
            console.log('onePartnerIdStr = '+ onePartnerIdStr);
            console.log('intelAccountIdStr_PC = '+ intelAccountIdStr_PC); */           
            /*compEvent.setParams({'sContactIdStr' : sContactIdStr,
                                 'onePartnerIdStr' : onePartnerIdStr,
                                 'intelAccountIdStr_PC' : intelAccountIdStr_PC,
                                 'showEntitlements': false
                                });*/
            compEvent.setParams({'sContactIdStr' : sContactIdStr,
                                 'showEntitlements': false,
                                 'sourceCmp' : sourceComponent
                                });
            console.log(compEvent);
            compEvent.fire(); 
            component.set("v.recordNotFound",true);
        }catch(error){
            console.log(error);
        }
    }
})