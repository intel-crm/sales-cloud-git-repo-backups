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
            console.log('returnvale -->'+returnvale);
            var state = response.getState();
            console.log('state -->'+state);
            
            if(state =="SUCCESS"){
                if(returnvale===true){
                    error=false;
                }else{
                    error=true;
                }        
                if(!error){                    
                    component.set('v.message',"This will initiate a real sync with CIM system.");
                    component.set('v.title',"Success!");
                    component.set('v.type',"success");
                    $A.enqueueAction(component.get('c.showToast'));                                
                }else{
                    component.set('v.message',"Sync is in Progress!");
                    component.set('v.title',"Error!");
                    component.set('v.type',"error");
                    $A.enqueueAction(component.get('c.showToast'));
                }
            }            
        });
        $A.enqueueAction(action);
    },
    
    showToast: function(component, event, handler){
        console.log('showtoast called'+component.get('v.type')+''+component.get('v.title')+''+component.get('v.message'));
        $A.get("e.force:closeQuickAction").fire();
        
        var toastEvent = $A.get("e.force:showToast");        
        toastEvent.setParams({
            "type": component.get('v.type'),
            "title": component.get('v.title'),
            "message": component.get('v.message')
        });
        toastEvent.fire();
        $A.get('e.force:refreshView').fire();
        
    }
    
})