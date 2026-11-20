({  
    //function call and load KPI attributes in case of retail - clone /Edit  
    afterRender: function (component, helper) {
        //Default renderer function
        this.superAfterRender();
        //To load KPI after default renderer function on Claim Clone and Edit
        helper.loadKPIAttributesOnCloneAndEdit(component);
    },
})