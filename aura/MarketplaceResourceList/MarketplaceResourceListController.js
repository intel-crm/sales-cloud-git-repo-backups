({
    navigateToURL: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToURL");
        var URL = '';
        if((event.target.dataset.target).includes('https://')){
            URL= event.target.dataset.target;
        }
        else if((event.target.dataset.target).includes('http://')){
            URL= event.target.dataset.target;
        }
            else {
                URL= 'https://'+event.target.dataset.target          
            }                              
        navEvt.setParams({
            url : URL
        });
        navEvt.fire();        
    }
    
})