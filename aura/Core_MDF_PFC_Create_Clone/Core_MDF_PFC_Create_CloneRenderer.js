({
    //function call an d load KPI attributes in case of retail - clone /Edit
    afterRender: function (component, helper) {        
        this.superAfterRender();
        window.setTimeout($A.getCallback(function () {
            if(component.get('v.isClaimActivitySwap') && 
               (component.get("v.isCloneClaim") || component.get("v.isClaimEdit"))){        
                // helper function to load KPI attributes
                helper.loadKpiAttributes(component);
            }
        }), 2000);
        
    }
})