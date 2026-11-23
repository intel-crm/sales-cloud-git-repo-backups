({
    doInit : function(component, event, helper) {
		//Start--Replace var with let or const--static code violation fix--harsha--14/06/21
        //var rTypeIdNameMap;
        let rTypeIdNameMap;
        component.set("v.retURL",'/lightning/o/Case/list?filterName=Recent');
        //var pageReference = component.get("v.pageReference");
        const pageReference = component.get("v.pageReference");
        //alert('minhaj core_ipslandingpage');
        //console.log('minhaj', pageReference);
        var mode = pageReference.state.c__mode;
        console.log('mode of page', mode);
        if(mode=='asset'){
            component.set("v.recTypeId", pageReference.state.c__recordTypeId); 
            component.set("v.retURL",'/lightning/r/Asset/'+pageReference.state.c__productId+'/view');
           //console.log('minhaj asset inside assist mode of if');
        }    
        else{
            //console.log('inside else of assist');
            component.set("v.recTypeId", pageReference.state.recordTypeId);
        }  
        //var action = component.get("c.getCaseRecordTypeIds");
        const action = component.get("c.getCaseRecordTypeIds");
        action.setCallback(this, function(response) {
            //var state = response.getState();
            const state = response.getState();
            //console.log('response of getcaserecordtypeids', response.getReturnValue());
            if (state === "SUCCESS") {
                console.log('checking state of getCaseRecordTypesIds');
                rTypeIdNameMap = response.getReturnValue();
                if(rTypeIdNameMap !== undefined && rTypeIdNameMap !== null  && ('IPS_Case_Create' === rTypeIdNameMap[pageReference.state.recordTypeId]  || 'Core_IPS_Case_Create_Self_Assigned' === rTypeIdNameMap[pageReference.state.recordTypeId]  || 'IPS_GEC_ReadOnly' === rTypeIdNameMap[pageReference.state.recordTypeId]  || 'IPS_Closed_Case' === rTypeIdNameMap[pageReference.state.recordTypeId]  )) {
                    component.set("v.recTypeName", rTypeIdNameMap[pageReference.state.recordTypeId]);
                    //console.log('recordName-- '+rTypeIdNameMap[pageReference.state.recordTypeId]);
                    //console.log('internalcase true');
                    component.set("v.InternalCaseCreate", true);
                } 
                else if(rTypeIdNameMap !== undefined && rTypeIdNameMap !== null  && mode=='asset' && ('IPS_Case_Create' === rTypeIdNameMap[pageReference.state.c__recordTypeId]  || 'Core_IPS_Case_Create_Self_Assigned' === rTypeIdNameMap[pageReference.state.c__recordTypeId] || 'IPS_GEC_ReadOnly' === rTypeIdNameMap[pageReference.state.recordTypeId]  || 'IPS_Closed_Case' === rTypeIdNameMap[pageReference.state.recordTypeId] )) {
                    component.set("v.recTypeName", rTypeIdNameMap[pageReference.state.c__recordTypeId]);
                    console.log('internalcase true11');
                    component.set("v.InternalCaseCreate", true);
                } else if(pageReference.state.recordTypeId == undefined){
                   // console.log('internalcase true22');
                    component.set("v.recTypeName", rTypeIdNameMap['012o0000000TPVhAAO']);
                    component.set("v.InternalCaseCreate", true);
                }
                else {
                    //console.log('inside else internal case false');
                    //console.log('inside else getstandardAction redirection url');
                    component.set("v.InternalCaseCreate", false);
                    //var actionRedirectToOldVersion = component.get("c.getStandardActionRedirectionURL");
                    const actionRedirectToOldVersion = component.get("c.getStandardActionRedirectionURL");
                    if(mode=='asset'){
                        actionRedirectToOldVersion.setParams({ actionStr:"new", objectStr:"case", profileStr:"null", recTypeName:pageReference.state.c__recordTypeId });
                    }else{
                        actionRedirectToOldVersion.setParams({ actionStr:"new", objectStr:"case", profileStr:"null", recTypeName:rTypeIdNameMap[pageReference.state.recordTypeId] });
                    }    
                    actionRedirectToOldVersion.setCallback(this, function(response) {
                        //var state = response.getState();
                        const state = response.getState();
                        //console.log('response of getstandaredactionredirection', response.getReturnValue());
                        if (state === "SUCCESS") {
                            //var redirectToURL = response.getReturnValue();
                            const redirectToURL = response.getReturnValue();
                           // console.log('redirectionToURL',redirectToURL);
                           // console.log('redirectionToURL', component.get('v.retURL'));
                            //var urlEvent = $A.get("e.force:navigateToURL");
                            const urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({ 
                                "url": redirectToURL + component.get("v.retURL")
                            });
                            urlEvent.fire();
                        }
                        else if (state === "INCOMPLETE") {
                            console.log("INCOMPLETE");
                        }
                            else if (state === "ERROR") {
                                //var errors = response.getError();
                                const errors = response.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + errors[0].message);
                                    }
                                } else {
                                    console.log("Unknown error");
                           }
                        }
                    });
                    $A.enqueueAction(actionRedirectToOldVersion);  
                    
                }
            }
            else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
            }
                else if (state === "ERROR") {
                    //var errors = response.getError();
					const errors = response.getError();
                    //End--Replace var with let--static code violation fix--harsha
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})