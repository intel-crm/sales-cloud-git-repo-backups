({
	dpInit : function(component, event, helper) {
		
	},
    //Common method to display success/error
    displayToastMessage: function(component, event){
        var params = event.getParam('arguments');
		console.log(params);
        var Title = '';
        var Message = '';
        var Type ='';
           if (params) {
            console.log(params.title);
               console.log(params.message);
               console.log(params.type);
               Title = params.title;
               Message = params.message;
               Type = params.type;
        }
        if(params){
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: Title,
            message:Message,
            type: Type
        });
        toastEvent.fire();
        }

       
    }
})