({
    doInit : function(component, event, helper) {
        var action = component.get("c.getLoginUserType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('storeSucess'+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse'+storeResponse);
                component.set("v.userType", storeResponse);
                console.log(component.get("v.userType"));
            }else{
                var errors = response.getError();
                console.log("Error message: " + errors[0].message);
            }
        });
        $A.enqueueAction(action);
        console.log(action);
    },
    recordLoaded: function(component, event){
        component.set("v.disableSave",false);
        var oldStatus = component.get("v.Quote.SBQQ__Status__c"); 	
        component.set("v.oldStatus",oldStatus);
        var lastChangedStatus= component.find("inputStatus").get("v.value");		
        component.set("v.lastChangedStatus",lastChangedStatus);
        var quoteType = component.get("v.Quote.core_cpq_quote_type_nm__c"); 
        component.set("v.quoteType",quoteType);
        console.log('oldStatusOnload'+oldStatus);
        console.log('statusType'+quoteType);

    },
    validateStatus: function(component,event){
    	
        var inputStatusField = component.find("inputStatus");
        var status = inputStatusField.get("v.value");
        component.set("v.newStatus",status);
        var oldStatus = component.get("v.oldStatus");
		var lastChangedStatus = component.get("v.lastChangedStatus");

        component.find("isActive").set("v.value",true);
        var loginUserType = component.get("v.userType");
        var errorMessage;
        console.log('oldStatu::'+oldStatus+'<-->User Type ::'+loginUserType);
        console.log('selected value::' + status);
        console.log('LableUser::' + $A.get("$Label.c.PSG_Quote_SOS_PermissionSet"));
		
        if(status == $A.get("$Label.c.PSG_Quote_Status_In_Progress")){
            console.log('LoginUser::' + loginUserType); 
			//Pending and Rejected quotes cannot be flipped by Non-SOS
			if(loginUserType != $A.get("$Label.c.PSG_Quote_SOS_PermissionSet") && (oldStatus == $A.get("$Label.c.PSG_Quote_Status_Rejected") || oldStatus ==$A.get("$Label.c.PSG_Quote_Status_Pending"))){
                errorMessage = 'Cannot flip the status to '+status;
            }
			
            if(loginUserType== $A.get("$Label.c.PSG_Quote_SOS_PermissionSet") && (oldStatus == $A.get("$Label.c.PSG_Quote_Status_Recalled") 
			|| oldStatus == $A.get("$Label.c.PSG_Quote_Status_In_Review") || oldStatus == $A.get("$Label.c.PSG_Quote_Status_Cancelled") || oldStatus == $A.get("$Label.c.PSG_Quote_Status_Approved"))){
                errorMessage = 'Cannot flip the status to '+status;
            }   
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_In_Review")){
            if(loginUserType != $A.get("$Label.c.PSG_Quote_SOS_PermissionSet") && oldStatus == $A.get("$Label.c.PSG_Quote_Status_Recalled") ) {
				errorMessage = 'Cannot flip the status to '+status;
			}
            //login user is sos/bm/buops4
            //previous status value 
            if(oldStatus ==$A.get("$Label.c.PSG_Quote_Status_Rejected") || oldStatus == $A.get("$Label.c.PSG_Quote_Status_Pending") ){
                errorMessage = 'Cannot flip the status to '+status;
            }
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_Approved")){
            //login user is sos/bm/buops4
            //previous status value 
            //
            if(loginUserType == $A.get("$Label.c.PSG_Quote_SOS_PermissionSet")) {
                errorMessage = 'Only BizOps/BM can approve In Review Quotes';
            }
            if(oldStatus != $A.get("$Label.c.PSG_Quote_Status_In_Review") && oldStatus != $A.get("$Label.c.PSG_Quote_Status_Approved")){
                errorMessage = 'Cannot flip the status to '+status;
            }
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_Rejected")){
            
           /* if(loginUserType == $A.get("$Label.c.PSG_Quote_SOS_PermissionSet") ) {
                errorMessage = 'Only BizOps/BM can Reject the Quotes';
            }*/
			
			
			if(loginUserType == $A.get("$Label.c.PSG_Quote_SOS_PermissionSet")){
				if(oldStatus != $A.get("$Label.c.PSG_Quote_Status_In_Progress") && oldStatus != $A.get("$Label.c.PSG_Quote_Status_New")){
					errorMessage = 'Cannot flip the status to '+status;
				}
			}
			
			else if(loginUserType != $A.get("$Label.c.PSG_Quote_SOS_PermissionSet")){
				if(oldStatus == $A.get("$Label.c.PSG_Quote_Status_In_Progress") || oldStatus == $A.get("$Label.c.PSG_Quote_Status_New")){
					errorMessage = 'Only SOS can Reject In Progress and New Quotes'
				}
				else if(oldStatus != $A.get("$Label.c.PSG_Quote_Status_In_Review") && oldStatus != $A.get("$Label.c.PSG_Quote_Status_Rejected")){
					errorMessage = errorMessage = 'Cannot flip the status to '+status;	
				}
				
			}
          
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_Cancelled")){    

            if(loginUserType =='System Administrator' && (oldStatus ==$A.get("$Label.c.PSG_Quote_Status_New")||oldStatus==$A.get("$Label.c.PSG_Quote_Status_Rejected")||oldStatus==$A.get("$Label.c.PSG_Quote_Status_Draft") )){
               //  quote.core_cpq_active_cb__c=false;
                //component.set("v.Quote.core_cpq_active_cb__c",false);
                component.find("isActive").set("v.value",false);
            }else if(loginUserType == $A.get("$Label.c.PSG_Quote_SOS_PermissionSet") && (oldStatus ==$A.get("$Label.c.PSG_Quote_Status_New")||oldStatus==$A.get("$Label.c.PSG_Quote_Status_Rejected") || oldStatus == $A.get("$Label.c.PSG_Quote_Status_In_Progress") || oldStatus==$A.get("$Label.c.PSG_Quote_Status_Recalled") ||oldStatus==$A.get("$Label.c.PSG_Quote_Status_Draft"))){
               // quote.core_cpq_active_cb__c=false;
                //component.set("v.Quote.core_cpq_active_cb__c",false);
                component.find("isActive").set("v.value",false);
                
            }else{ 
                errorMessage = 'You cannot flip the status to '+status;
                //alert("Login>>"+loginUserType+"abcd"+oldStatus);
            }                       
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_Recalled")){
            console.log('inside Recall new stats'+loginUserType);
            if((loginUserType == $A.get("$Label.c.PSG_Quote_SOS_PermissionSet")) || loginUserType == 'System Administrator'){
                console.log('inside Recall uder if '+loginUserType);
                if(oldStatus!=$A.get("$Label.c.PSG_Quote_Status_In_Review")&&oldStatus!=$A.get("$Label.c.PSG_Quote_Status_Recalled")){
                    errorMessage = 'Only In Review quotes can be '+status;
                }
            }else{
                errorMessage = 'Only SOS/Admin can flip the status to '+status;
                }
                
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_Pending")){
              console.log("status msg: " + status + '<---->' + oldStatus);
              console.log("status user: " + loginUserType);
            if(oldStatus!= $A.get("$Label.c.PSG_Quote_Status_In_Progress")){
                errorMessage = 'You cannot flip the status to '+status;
            }
            if(loginUserType != $A.get("$Label.c.PSG_Quote_SOS_PermissionSet") && oldStatus == $A.get("$Label.c.PSG_Quote_Status_In_Progress")){
                errorMessage = 'Only SOS can flip the status to '+status;
            }else if(oldStatus == $A.get("$Label.c.PSG_Quote_Status_Rejected")){
                errorMessage = 'Cannot flip the status to '+status;
        }
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_Draft")){
            if(oldStatus==$A.get("$Label.c.PSG_Quote_Status_Rejected") || oldStatus==$A.get("$Label.c.PSG_Quote_Status_Pending") ){
                errorMessage = 'Cannot flip the status to '+status;
            }
        }else if(status == $A.get("$Label.c.PSG_Quote_Status_New")){
            if(oldStatus==$A.get("$Label.c.PSG_Quote_Status_Rejected")  || oldStatus==$A.get("$Label.c.PSG_Quote_Status_Pending") ){
                errorMessage = 'Cannot flip the status to '+status;
            }
        }
        console.log('i am inside error'+errorMessage);

        if(errorMessage){
            console.log('i am inside error'+errorMessage);
        	component.find('errorMessage').setError(errorMessage);
            component.set("v.noErrors",false);
        }else{
            component.set("v.noErrors",true);
            component.find('errorMessage').setError('');
            if( status==$A.get("$Label.c.PSG_Quote_Status_Recalled") ||  status==$A.get("$Label.c.PSG_Quote_Status_Rejected") ||  status==$A.get("$Label.c.PSG_Quote_Status_Cancelled")||  status==$A.get("$Label.c.PSG_Quote_Status_Pending")){
                if( lastChangedStatus==$A.get("$Label.c.PSG_Quote_Status_Recalled") ||  lastChangedStatus==("$Label.c.PSG_Quote_Status_Rejected") ||  lastChangedStatus==$A.get("$Label.c.PSG_Quote_Status_Cancelled")||  lastChangedStatus==$A.get("$Label.c.PSG_Quote_Status_Pending")){
                    component.set("v.disableSave",false);
                }else{
                    component.set("v.disableSave",true);
                }
                
         	   component.set("v.showReasonBox", true);            
           	   console.log('If else test ' +  status);
              // $A.enqueueAction(component.get('c.recordLoaded'));
            }
            else{
                component.set("v.showReasonBox", false);           
            }
			            
        }
            
    },

    
    handleSubmit: function(component,event){
        let status = component.get("v.newStatus");
        var quoteType = component.get("v.quoteType");
        component.set("v.disableSave",true);
        //helper.savePicklistValues(component, event);
        console.log('handle Submit :: '+status + component.find("inputStatus").get("v.value"));
        if(status){
            event.getParams().fields.SBQQ__Status__c = status;
        }else{
            event.getParams().fields.SBQQ__Status__c = component.find("inputStatus").get("v.value");
        }
   
        if(status == $A.get("$Label.c.PSG_Quote_Status_Approved") && quoteType!=null &&  quoteType == $A.get("$Label.c.PSG_Quote_Type_Design_Win")){
            console.log('enter handle submit '+component.get("v.recordId"));
            var action = component.get("c.createPRIDRecords");
            action.setParams({
                "quoteId":component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('enter handle submit2 ');
                }else{
                    var errors = response.getError();
                    console.log("Error message: " + errors[0].message);
                }
            });
            $A.enqueueAction(action);
        }
    
    },
    
    handleSuccess: function(component,event){
		var closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
        $A.get('e.force:refreshView').fire();
        var errorMessage = 'Quote status was successfully updated';
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "message": errorMessage,
            "type": "success"
        });
        toastEvent.fire();
    },
     
    handleCancel: function(component,event){
        var closeAction = $A.get("e.force:closeQuickAction");
        closeAction.fire();
    }
})