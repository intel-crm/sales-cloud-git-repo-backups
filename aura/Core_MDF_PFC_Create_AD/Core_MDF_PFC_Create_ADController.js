({    
    // Method is called on component Initalization
    doInit: function(component, event, helper) {
        //To identify weather its Insert/clone or EDit claim process, used for close modal
        if(component.get("v.simpleNewClaim.Id")!='' && component.get("v.simpleNewClaim.Id")!= undefined){     
            if(component.get("v.isCloneClaim"))
            {
                component.set("v.isClaimEdit",false);
            }
            else{
                component.set("v.isClaimEdit",true);
            }  
        }
    },
    
    // Method is called on click of cancel icon
    closeModal: function(component, event, helper) {
        helper.closeModel(component);
    },
    
    //Close Error toast message Modal
    closeErrorToast: function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    
    //Display error message
    displayErrorMessage: function(component,event,helper){
        if(event.getParam("errorMsg") != null && event.getParam("errorMsg")!=undefined){
            helper.handleServerExceptions(component, event.getParam("errorMsg"));
        }        
    },
    
    // when user click direactly on step 1,step 2 indicator then showing appropriate step using set 'currentStep'   
    clickClaimDetails : function(component,event,helper){
        component.set("v.currentStep", "1");
    },

    //This function is used for Claim manditory fields & duplicate claim validation
    moveNext : function(component,event,helper){
        //Calling child function  to validate fields
        var childCmp = component.find('pfcInputFieldsCmp');
        //Validating all required fields
        childCmp.validateClaimForm();
    },    
    //event handler to handle event fired from save buttom cmp, to check which button clicked
    manageActionEvent : function(component,event,helper){
        if(event.getParam("buttonClicked") == 'Next'){
            //Invoke move next function
            $A.enqueueAction(component.get('c.moveNext'));
        }else if(event.getParam("buttonClicked") == 'Back'){
            // control the back button based on 'currentStep' attribute value    
            var getCurrentStep = component.get("v.currentStep");
            if(component.get("v.currentStep")!=null &&
               component.get("v.currentStep") == "2"){
                component.set("v.currentStep", "1");
            }
        }else{
            //Close Modal on cancel button
            helper.closeModel(component);
        }
    }
})