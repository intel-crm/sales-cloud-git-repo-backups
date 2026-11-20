({
    initialize : function(cmp,event,helper) {
        var accId;
        var channelProgram;
        var objectName;
        var sPageURL = decodeURIComponent(window.location.href);
       	if(sPageURL.includes("PRM_AccountChannelMembership__c")){
        	objectName ='PRM_AccountChannelMembership__c';
            accId = cmp.get("v.recordId");
        } 
        else{ 
                // get account id from the attribute passing
        		accId  = cmp.get("v.AccountId");
        		// or else get it from the record page
                if(accId == null){
                    accId = cmp.get("v.recordId");
                }else{
                    cmp.set("v.recordId",accId);
                }
            	objectName ='Account';
        }
        
        // get the channel program name from the design attribute
        channelProgram = cmp.get("v.ChannelProgram");
        var action = cmp.get("c.getResponses");
        action.setParams({ recordId : accId ,
                          channelProg : channelProgram,
                          objectName : objectName});
        
        //action.setParams({ accId : accId ,
                          //channelProg : channelProgram});
                          
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.response",response.getReturnValue());
                 //cmp.set("v.responselst",responselst.getReturnValue());

                //console.log("Here 1-->"+JSON.stringify(response.getReturnValue()[8].response));
                console.log("Here 1-->"+JSON.stringify(cmp.get("v.response")));
                console.log("Here 2-->"+(JSON.stringify(cmp.get("v.response")).question)); 
         	  	cmp.set("v.loadChildopid",true);
                //cmp.get("v.response").accountId;
                //console.log('accountId'+ cmp.get("v.response").accountId);
                cmp.set("v.accId",response.getReturnValue()[0].accountId);
                 //cmp.set("v.accId",responselst.getReturnValue()[0].accountId);

                console.log(response.getReturnValue());
                console.log('accountId 1'+response.getReturnValue()[0].accountId);
            } else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    save:function(cmp){
        var lstResp = cmp.get("v.saveResponse");
        console.log('---lstResp',lstResp);
        console.log('Size of  cmp.get"v.saveResponse" = ' + lstResp.length);

        var delResp = cmp.get("v.deleteResponse");
        console.log('---delResp',delResp);
        console.log('Size of  cmp.get"v.deleteResponse" = ' + delResp.length);
        console.log("Here delResp-->"+JSON.stringify(cmp.get("v.deleteResponse")));
        console.log("Here lstResp-->"+JSON.stringify(cmp.get("v.saveResponse")));
        this.showSpinner(cmp);
        var action = cmp.get("c.saveResponse");
        action.setParams({ lstResp : lstResp , delResp : delResp , accId : cmp.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                this.hideSpinner(cmp); console.log('refresh view fires');
                $A.get('e.force:refreshView').fire();
                setTimeout(function(){window.location.reload();},200);
               
            } else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "An error occurred. Please check."
                });
                toastEvent.fire();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    clear:function(cmp, event, helper){
        $A.get('e.force:refreshView').fire();
        this.initialize(cmp, event, helper);
        this.hideSpinner(cmp);
    },
    showSpinner: function (cmp, event, helper) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (cmp, event, helper) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    //updateButton: function (cmp, event, helper) {
    	//cmp.set("v.disableButton",true);
    //},
})