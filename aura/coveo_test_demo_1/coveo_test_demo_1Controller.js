({
    doInit : function(component, event, helper) {
        setInterval(function(){
            let locValue = localStorage.getItem('flag');
            if(locValue !== 'false'){
                component.set("v.flag", true);
            }
        }, 1000);    
    }
})