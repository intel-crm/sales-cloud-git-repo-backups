({
    // Method is called on click of Finish and Save Button
    finish : function(component,event,helper){
        helper.saveClaim(component);        
    },
    //Function call on click of next button
    moveNext : function(component,event,helper){
        helper.buttonActionClickedEvent(component,event,helper,'Next');
    },
    //Function call on click of back button
    moveBack : function(component,event,helper){
        helper.buttonActionClickedEvent(component,event,helper,'Back');
    },
    //Function call on click of cancel button
    closeModalEvent : function(component,event,helper){
        helper.buttonActionClickedEvent(component,event,helper,'CloseModal');
    }
})