({
    helperMethod : function(component, event, helper) {
        console.log('minhaj inside helper');
        var action = component.get("c.getCaseRecordTypeID");
        action.setParams({ recId : component.get('v.recordId') });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('minhaj status success')
                //alert(response.getReturnValue());
                var rTypeIdNameMap = response.getReturnValue();
                console.log('record selected', response.getReturnValue());
                component.set('v.recordTypeName', response.getReturnValue());
                if(rTypeIdNameMap !== undefined && rTypeIdNameMap !== null  && ('IPS_Case_Create' == rTypeIdNameMap  || 'Core_IPS_Case_Create_Self_Assigned' == rTypeIdNameMap  || 'IPS_GEC_ReadOnly' == rTypeIdNameMap || 'IPS_Closed_Case' == rTypeIdNameMap )) {
                    console.log('inside if minhaj');
                    const evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:core_IPS_CreateCase",
                        componentAttributes: {
                            recordId : component.get('v.recordId'),
                            mode : 'edit'
                        }
                    });
                    evt.fire();
                }else{
                      console.log('minhaj inside else');
                    //event.preventDefault();
                   /* var editRecordEvent = $A.get("e.force:editRecord");
                    editRecordEvent.setParams({
                        "recordId": component.get("v.recordId")
                    });
                    editRecordEvent.fire();   */
                  /*  const navService = component.find("navService");
                    const pageReference =
                        {
                            type: 'standard__recordPage',
                            "attributes": {
                                "recordId": component.get('v.recordId'), // Pass the record Id
                                "actionName": 'edit',
                                "objectApiName":"Case"
                            }
                        };
                    component.set("v.pageReference", pageReference);
                    navService.navigate(pageReference); */
                    const navService = component.find("navService");
                    var actionNav = component.get("c.navigateEdit");
                    actionNav.setParams({ recId : component.get('v.recordId') });
                    actionNav.setCallback(this, function(res){
                        let state = res.getState();
                        if(state === "SUCCESS"){
                            console.log('minhaj vf res', res.getReturnValue());
                           // component.set("v.pageReference", res.getReturnValue());
                           // navService.navigate(res.getReturnValue());
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": res.getReturnValue()
                            });
                            urlEvent.fire();
                            console.log('minhaj vf page state success');
                            
                        }else{
                            console.log('minhaj vf page state fail');
                        }
                    })
                    $A.enqueueAction(actionNav);
                    
                    
                }
                // do something with response.getReturnValue(), such as firing your create event here.
            }
            else {
                
                console.log("Failed with state: " + state);
            }
        });
        
        $A.enqueueAction(action);
    }
})