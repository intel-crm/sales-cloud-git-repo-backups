({
    leadCreation_helper: function(component, event, helper) {
        
        var set_action = component.get("c.fetchUser"); //getRegistrationRequest
        console.log('before Set Storable');
        // set_action.setStorable();
        console.log('After Set Storable');
        set_action.setParams({registerId: component.get('v.recordId')}); //list of record id
        console.log('Set Storable reocrd id');
        
        
        set_action.setCallback(this, result => {
            console.log('inside setcallback');
            switch (result.getState()) {
            case "SUCCESS":
           // case "DRAFT":
            // 	component.set("v.regDetails",response.getReturnValue());
            $A.get("e.force:showToast")
            .setParams({
            type: 'success',
            message: 'Lead Created!',
            mode: 'pester'
        })
        .fire();
        break;
        default:
        $A.get("e.force:showToast")
        .setParams({
            type: 'error',
            mode: 'pester',
            message: 'Lead Creation Failed!'
        })
        
    }
    $A.get("e.force:closeQuickAction").fire();
    $A.get("e.force:refreshView").fire();
});
$A.enqueueAction(set_action);       
}
})