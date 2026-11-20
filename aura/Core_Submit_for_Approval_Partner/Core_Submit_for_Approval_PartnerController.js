({
   handleClose: function (component,event, helper) {
        
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
       	/*var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'Opportunity Submitted for Approval Successfully. ',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();*/
      
    
    },

})