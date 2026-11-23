({
	doInit: function(component, event, helper) {
       //Replace var with const--static code violation fix--harsha--14/06/21 
       // var pageReference = {
       	const pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__Core_IPS_CopyCase'
            },
            state : {
            	c__recordId : component.get('v.recordId')
        	}
        };
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        const handleUrl = (url) => {
            window.open(url, '_blank', "width=1000,height=600");
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageReference).then(handleUrl, handleError);
        setTimeout(function(){ 
            //Replace var with const--static code violation fix--harsha--14/06/21
            //var compEvent = component.getEvent("closeActionModalEvent");
            const compEvent = component.getEvent("closeActionModalEvent");
			compEvent.fire();
        }, 3000);
    },
            
	handleCloseEvent: function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire(); 
    }
})