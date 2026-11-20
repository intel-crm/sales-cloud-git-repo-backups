({
    handleOnClick: function(component, event, helper) {
        console.log('Testing For Web Analytics');
        
        
        var windowUrl = window.location.href;
        
        if(!(windowUrl.includes("search") || windowUrl.includes("pmp-category") || windowUrl.includes("pmp-specification") || windowUrl.includes("pmp-partner-program") || windowUrl.includes("pmp-partner-specialty"))){
            var analyticsData = component.find("analyticsData");
            
            analyticsData.formAnalyticsData('click','focus','search'); 
        }  
        
        
        
    },  
    
    doFocus: function(component, event, helper) {
        console.log('Testing For Web Analytics');  
        component.find('input').getElement().focus();
    },
    
    handleInputChange: function(component, event, helper) {
        component.set('v.value', event.currentTarget.value);
        var onKeyUp = component.get('v.onkeyup');
        // set this manually as we have an input
        if (typeof onKeyUp === 'function') {
            onKeyUp(component, event, helper);
        }
    },
    
    handleKeyDown: function(component, event, helper) {
        var onKeyDown = component.get('v.onkeydown');
        // set this manually as we have an input
        if (typeof onKeyDown === 'function') {
            onKeyDown(component, event, helper);
        }
    },
    
    handleInputBlur: function(component, event, helper) {
        var onBlur = component.get('v.onblur');
        if (typeof onBlur === 'function') {
            onBlur(component, event, helper);
        }
    },
    
})