({
	call : function(action, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            if(params){
                action.setParams(params);
            }
            action.setCallback(this, function(a){
                if(a.getState() == "SUCCESS"){
                    resolve(a.getReturnValue());
                } else {
                    reject(a.getError());
                }
           });
           $A.enqueueAction(action);
        }));
    },

    quickActionFunction : function(component, quickAction, type) {
        component.set("v.modalHeader", '');
        component.set("v.isShowHeaderFooter", false);
        component.set("v.isDefaultQuickAction", false);
	 var objectDetailsMap = component.get("v.hiddenFieldsMap");
        if(quickAction == 'Sharing'){
            var getId = component.get("v.recordId");
            var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/p/share/CampaignSharingDetail?parentId="+getId
                        });
                        urlEvent.fire();
        }
        else if (type != 'Update a Record') {
            if (quickAction == 'Clone') {
                component.set("v.openCmp", 'Clone');
            }
            else if (quickAction == 'Create Activity') {
                component.set("v.openCmp", 'Create Activity');
            }
            else if (quickAction == 'Edit') {
                console.log('Checking-- 30');
                component.set("v.openCmp", 'Edit');
            }else if(quickAction == 'Close Activity'){
                component.set("v.isShowHeaderFooter", true);
                component.set("v.openCmp", 'Close Activity');
                component.set("v.modalHeader", quickAction);
            }else if(quickAction == 'Create Claim'){
                component.set("v.openCmp", 'Create Claim');
            }else if(quickAction == 'Reopen for Claiming'){
                component.set("v.openCmp", 'Reopen for Claiming');
            }else if(quickAction == 'Clone Claim'){
                component.set("v.openCmp", 'Clone Claim');
            }else if(quickAction == 'Hold Claim'){
                component.set("v.openCmp", 'Hold Claim');
            }else if(quickAction == 'Cancel Claim'){
                component.set("v.openCmp", 'Cancel Claim');
            }else if(quickAction == 'Release Hold'){
                component.set("v.openCmp", 'Release Hold');
            }else if(quickAction == 'Complete PIC Review'){  //Roshan - added for Outcome based
                component.set("v.openCmp", 'Complete PIC Review');
            }else if(quickAction == 'Submit For PIC'){  //Roshan - added for Outcome based
                component.set("v.openCmp", 'Submit For PIC');
            }else if(quickAction == 'Submit for Payment Clearance'){  
                component.set("v.openCmp", 'Submit for Payment Clearance');
            } else if(quickAction == 'Recall to Payment Clearance'){ //TWC3117-19154
                component.set("v.openCmp", 'Recall to Payment Clearance'); //TWC3117-19154
                component.set("v.modalHeader", 'Recall to Payment Clearance'); //TWC3117-19154
                component.set("v.isShowHeaderFooter", true); //TWC3117-19154
                component.set("v.errorMessage", ''); //TWC3117-19154
            }else if(quickAction == 'Manual Audit'){  //Anushya - added for IPA Final Outcome based
                component.set("v.openCmp", 'Manual Audit');
            }else if(quickAction == 'Complete Payment Clearance Processing'){
                component.set("v.openCmp", 'Complete Payment Clearance Processing');
            }else if(quickAction == 'Cancel VAT'){  //Roshan - TWC3117-19010
                component.set("v.openCmp", 'Cancel VAT');
            }
            if(quickAction != 'Create Claim'){
                component.set("v.openModalForLtCmp", true);
            }
        } else if (type == 'Update a Record') {
            component.set("v.openCmp", 'Update');
            component.set("v.openModalForUpdateButton", true);
            component.set("v.modalHeader", quickAction);
            
	    
        switch (quickAction) {
            case 'Cancel Campaign':
                component.set("v.modalPopConfMessage",objectDetailsMap.get("Cancel Alert"));
                component.set("v.fieldValue", 'Cancelled');
                break;
            case 'Submit For Approval':
                component.set("v.modalPopConfMessage", objectDetailsMap.get("Approval Alert"));
                component.set("v.fieldValue", 'Pending Review');
                break;
            case 'Notify Partner': 
                component.set("v.modalPopConfMessage","Confirm if you want to notify the claim submitter?");
                component.set("v.isNotifyOwner",true);
                break;
            default:
                component.set("v.modalPopConfMessage", 'Not a valid action');
                component.set("v.isDefaultQuickAction", true);
        }
        }
    },
    
    logErrors: function(component, errorMessage, objName) {
        let applicationErrorMessage = $A.get("$Label.c.Core_MDF_ApplicationErrorMessage");
        let action = component.get("c.logErrors");
        action.setParams({
            errorMessage: errorMessage,
            objName: objName
        });
        action.setCallback(this, function (res) {
            let state = res.getState();
            if (state === "SUCCESS") {
                this.fireToastEvent(component,applicationErrorMessage, "5000", "error");
            } else {
                this.fireToastEvent(component,applicationErrorMessage, "5000", "error");
            }
        });
        $A.enqueueAction(action);
    },

    fireToastEvent: function(component,message, duration, type) {
        component.set("v.openModalForLtCmp", false);
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            duration: duration,
            key: "info_alt",
            type: type
        });
        toastEvent.fire();
    },

})