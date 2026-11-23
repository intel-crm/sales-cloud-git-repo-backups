({
	doInit : function(component, event, helper) {
		var action =component.get("c.validateDpaRec");
        action.setParams({
            dpaId : component.get("v.recordId"),
            action: "modify"
        });
        action.setCallback(this,(response)=>{
            if(response.getState()==='SUCCESS'){
            	console.log('insidefaction');
                if(response.getReturnValue().isSuccess){
					//update flag
					console.log('insidefaction2');
					var actionChangeFlag =component.get("c.modifyLineBeforeSendToSap");
					actionChangeFlag.setParams({
						dpaId : component.get("v.recordId"),
						action: "modify"
					});
					actionChangeFlag.setCallback(this,(response)=>{
						if(response.getState()==='SUCCESS'){
							//****************
							var actionSend =component.get("c.sendRequestToSAP");
							actionSend.setParams({
								dpaId : component.get("v.recordId"),
                        		action: "modify"
							});
							actionSend.setCallback(this,(response)=>{
							   
								if(response.getState()==='SUCCESS'){
								 console.log('insidesaction');
									if(response.getReturnValue().isSuccess){
										helper.showToast('Success!',response.getReturnValue().message,'success');
										$A.get("e.force:closeQuickAction").fire();
										helper.refreshView();
									}else{
										helper.showToast('Failed',response.getReturnValue().message,'error');
										$A.get("e.force:closeQuickAction").fire();
										helper.refreshView();
									}
								}else if (response.getState() === "ERROR") {
								console.log('insideesaction');
									var errors = response.getError();
									if (errors) {
										if (errors[0] && errors[0].message) {
											console.log("Error message: " + 
													 errors[0].message);
											helper.showToast('Failed',errors[0].message,'error');
											$A.get("e.force:closeQuickAction").fire();
											helper.refreshView();
										}
									} else {
										console.log("Unknown error");
										helper.showToast('Failed',"Unknown error",'error');
										$A.get("e.force:closeQuickAction").fire();
										helper.refreshView();
									}
								}
							});
							$A.enqueueAction(actionSend);
							//**********
						}else if (response.getState() === "ERROR") {
							var errors = response.getError();
							if (errors) {
								if (errors[0] && errors[0].message) {
									console.log("Error message: " + 
											 errors[0].message);
									helper.showToast('Failed',errors[0].message,'error');
									$A.get("e.force:closeQuickAction").fire();
									helper.refreshView();
								}
							}else {
								console.log("Unknown error");
								helper.showToast('Failed',"Unknown error",'error');
								$A.get("e.force:closeQuickAction").fire();
								helper.refreshView();
							}
						}
					});
					
					$A.enqueueAction(actionChangeFlag);
					//*********
									
                }else{
                    helper.showToast('Failed',response.getReturnValue().message,'error');
                    
                    $A.get("e.force:closeQuickAction").fire();
                   helper.refreshView();
                   console.log('insideError');
                }
            }else if (response.getState() === "ERROR") {
                console.log('insidefeaction');
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        helper.showToast('Failed',errors[0].message,'error');
                        $A.get("e.force:closeQuickAction").fire();
                        helper.refreshView();
                    }
                } else {
                    console.log("Unknown error");
                    helper.showToast('Failed',"Unknown error",'error');
                    $A.get("e.force:closeQuickAction").fire();
                    helper.refreshView();
                }
            }
        });
        $A.enqueueAction(action);
	}
})