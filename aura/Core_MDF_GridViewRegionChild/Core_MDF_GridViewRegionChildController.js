({
    inlineEditFYBudget : function(component,event,helper){ 
        var isUpdateable = component.get("v.regionEditable");
        // show the name edit field popup 
        if(isUpdateable){
            component.set("v.FYEditMode", true); 
            // after the 100 millisecond set focus to input field   
            setTimeout(function(){ 
                component.find("FYinputId").focus();
            }, 100);
            
        }
    },
    inlineEditSYBudget : function(component,event,helper){  
        
        var isUpdateable = component.get("v.regionEditable");
        if(isUpdateable){
            // show the name edit field popup 
            component.set("v.SYEditMode", true); 
            // after the 100 millisecond set focus to input field   
            setTimeout(function(){ 
                component.find("SYBudgetId").focus();
            }, 100);
        }
    },
    onFYBudgetChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        
        component.set("v.showSaveCancelBtn",true);
        
    },   
    closeSYBudgetBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'SYEditMode' att. as false   
        component.set("v.SYEditMode", false); 
        
    }, 
    closeFYBudgetBox : function (component, event, helper) {
        // on focus out, close the input section by setting the 'FYEditMode' att. as false 
        component.set("v.FYEditMode", false); 
    },   
    onSYBudgetChange : function (component, event, helper) {
        
        component.set("v.showSaveCancelBtn",true);
    },
    
})