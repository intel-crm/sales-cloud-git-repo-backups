({
    myAction : function(component, event, helper) {
        console.log('account id'+component.get('v.recordId'));
        
        var action = component.get('c.getAccountDetails');
        action.setParams({sfdcOnepartnerId:component.get('v.recordId') });// set parameter like, OPID, one partner account numbber etc,
        action.setCallback(this, function(response){
            // if no error - no record exists for same onepartner id with status = inprogress
            // call the CIM integration and get the response paylod  and create a record with all the required values from APEX action
            // if any error - fire error event
            var error= false;
            var returnvale = response.getReturnValue();
            console.log('---> JSON'+JSON.stringify(returnvale));
            //console.log('returnvale -->'+returnvale);
            var state = response.getState();
            console.log('state -->'+state);
            
            if(state =="SUCCESS"){
                if(returnvale == null){
                    error=false;
                }else{
                    error=true;
                }        
                if(!error){                    
                    component.set('v.message',"This will initiate a real sync with CIM system.");
                    component.set('v.title',"Success!");
                    component.set('v.type',"success");
                    //   $A.enqueueAction(component.get('c.showToast'));  
                    component.set('v.showConfirmDialog',true);                              
                }else{
                    component.set('v.message',JSON.stringify(returnvale));
                    component.set('v.title',"Error!");
                    component.set('v.type',"error");
                    // $A.enqueueAction(component.get('c.showToast'));
                }
            }            
        });
        $A.enqueueAction(action);
    },
    
    handleCancelButton: function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    
  
    
    handleConfirmButton : function (component, event, helper) {
        var action = component.get("c.createSyncRequest");
    var regRequestId = component.get("v.recordId");
        action.setParams({
            recordId : regRequestId           
        });

         $A.enqueueAction(action);
        window.location.reload();
}
    
       
        
        
    
    
    
    
})