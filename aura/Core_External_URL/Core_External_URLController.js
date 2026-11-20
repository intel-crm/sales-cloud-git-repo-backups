({
    doInit: function(cmp, event, helper) {
        var objApiName = '';
        var recTypeId = '';
        var accId = '';
        var desc =  '';
        var pageReference = cmp.get("v.pageReference");
        var caseType = pageReference.state.c__par1;
        switch(caseType) {
            case 'Sales_Assist':
                objApiName = pageReference.state.c__par2;
                recTypeId = pageReference.state.c__par3;
                accId = pageReference.state.c__par4;
                desc =  pageReference.state.c__par5;
                break;
            default :
                
        }
        
        var createRecEvent = $A.get("e.force:createRecord");
        createRecEvent.setParams({
            entityApiName: objApiName,
            defaultFieldValues: {
                RecordTypeId: recTypeId,
                AccountId: accId,
                Description: desc
            }
        });
        createRecEvent.fire();
    }
})