({  
    // To close the PIC Review Screen and to reload the record page on completing the pic review
    hidePicReviewScreen : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        component.getEvent("closeModalEvent").fire();  //Naveen - close popup explicitly
        if(event.getParam('isReload')) {
            setTimeout(() => {
                window.location.reload();
            }, 4000);
        }
    },
})