({
    searchContact: function(component, event, userId) {
        var action = component.get("c.searchContactByEmail");
        action.setParams({
            'searchKeyWord': component.get("v.searchKeyword").trim(),
            'userId': userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state "+ response.getState())
            if(state == "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log("Pending contact"+returnValue.isPendingContact);
                console.log("Existing contact"+returnValue.isContactExistsinOnePartnerAcc);
                //console.log("metadata coming"+returnValue.mapEPUMConstants.get('isContactExitssWithSameRole'));
                /*if(returnValue.isPendingContact) {
                        
                        console.log("Coming in pending");
                        component.set("v.Message", true);
                        component.set("v.messageText", "The contact has already been invited and registration is in progress");
                    }*/
                if(returnValue.isContactExistsinDB) {
                    if(returnValue.isContactExistsinOnePartnerAcc && returnValue.isContactExitssWithSameRole && !returnValue.isPendingContact) {
                        component.set("v.PaginationListrows", [returnValue.contactDetails]);
                        component.set("v.startPage", 0);
                        component.set("v.endPage", [returnValue.contactDetails].length);
                        component.set("v.totalRecords", [returnValue.contactDetails].length);
                        component.set("v.accountId", returnValue.strLoggedinUserAccId);
						component.set("v.onePartnerId", returnValue.strOnePartnerId);
                        
                    }
                   else if(returnValue.isPendingContact) {
                        
                        console.log("Coming in pending");
                        component.set("v.Message", true);
                        component.set("v.messageText", "The contact has already been invited and registration is in progress");
                    }
                    else if(!returnValue.isContactExistsinOnePartnerAcc) {
                        component.set("v.Message", true);
                        component.set("v.messageText", "Please contact Support team to onboard as contact is not part of your account.");
                    }
                        else if(!returnValue.isContactExitssWithSameRole) {
                        component.set("v.Message", true);
                        component.set("v.messageText", "Please contact Support team as contact is not part of your partner role");
                    }
                    
                    /*else if(returnValue.isPendingContact) {
                        
                        console.log("Coming in pending");
                        component.set("v.Message", true);
                        component.set("v.messageText", "The contact has already been invited and registration is in progress");
                    }*/
                } else {
                    component.set("v.Message", true);
					component.set("v.createNew", true);
                    component.set("v.messageText", "Please invite as this contact does not exist.");
                }
                console.log("return value"+ JSON.stringify(response.getReturnValue()))
            }
        });
        $A.enqueueAction(action);
    },
    
})