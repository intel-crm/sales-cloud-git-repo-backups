({    
    doInit : function(component, event, helper) {
        
        var action=component.get("c.ValidateZeroProducts");
        action.setParams({
            DRRecordId : component.get("v.recordId")
        })
         action.setCallback(this, function(response){
             var state=response.getState();
             if(state === "SUCCESS"){
                
                 var result = false;
                 result = response.getReturnValue();
                 if(result){
                      component.set("v.hasZeroQnty", true);
                 }else{
                     component.set("v.hasZeroQnty", false);
                 }
             }else{
                console.log("Error on validating lead record "+JSON.stringify(response.getError()));
            }
             
             });
      
		$A.enqueueAction(action);
	},
 
	isRefreshed : function(component, event, helper) {
       // alert('g');
        location.reload();
       // $A.get("e.force:refreshView").fire();
        
     
     }
})