({
	navigate : function(component, event, helper) {
		/*var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c:GMS_TestComp2'
            }
        };
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        /*const handleUrl = (url) => {
            //window.open(url, '_blank', "width=1000,height=600");
            console.log('url '+url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageReference).then(handleUrl, handleError);
        navService.navigate(pageReference);*/
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:GMS_TestComp2"
        });
        evt.fire();
	},
    doInit: function(component, event, helper) {
        var str = [{key:'None', value:'None'},{key:'MDF+', value:'MDF+'}];
        component.set("v.budgetTypeVal",str);
        component.set("v.selBudgetType",str[1].value);
        
        
    },
    maketrue:function(component, event, helper) {
        alert(component.get("v.budgetTypeVal"));
        component.set("v.flag",true);
    }
})