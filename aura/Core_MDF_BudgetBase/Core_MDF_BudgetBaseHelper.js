({
    callServer : function(component,method,callback,params) { 
        var spinner = component.find("accountTransferSpinner");
        var action = component.get(method);
        if (params != undefined) {
            action.setParams(params);
        }
        action.setCallback(this,function(response) {
            if (response.getState()=== "SUCCESS") { 
                // pass returned value to callback functtion
                callback.call(this,response.getReturnValue());
              
            } else { 
                var errors = response.getError();
                if (errors){                    
                    if(errors[0] && errors[0].message== $A.get("$Label.c.Core_MDF_No_Available_Budget_Error")){
                        var successToast = component.find('toast');
                                          $A.util.addClass(successToast, 'slds-hide');
                                          
                        				  //hide spinner
                                          $A.util.addClass(spinner, "slds-hide");
                        
                                          var errToast = component.find('errorToast');
                                          component.set("v.errorMsg", errors[0].message);
                                          $A.util.removeClass(errToast, 'slds-hide'); 
                        
                                          window.setTimeout($A.getCallback(function() {
                                              if(component.isValid()) {
                                                  $A.util.addClass(errToast, "slds-hide");
                                              }
                                          }), component.get("v.fadeTimeout"));
                    }else{ 
                            this.handleServerExceptions(component,response.getReturnValue());
                        }
                    
                } else {
                    throw new Error($A.get("$Label.c.Core_MDF_Unknown_Error"));
                }
            }
            
        });
         
        $A.enqueueAction(action);
    },
    
    BudgetChange:function(component, event, helper){
        var pbmId='';
        var partnerFrom=component.get("v.fromAccountSelectedValue").Id;
        
        var spinner = component.find("accountTransferSpinner");
        //show spinner when Budget amount is getting load
        $A.util.removeClass(spinner, "slds-hide");
        //disable the button
        component.set("v.button","true");
        
        pbmId=component.get("v.budgetSelectedValue").Id;
        
        //get TO list       
        helper.callServer(component,
                          "c.getToAccounts",
                          function(response){
                              component.set("v.toAccountList",response);
                              component.set("v.disableToAccount",false);
                                            },
                          {fromAcctId:partnerFrom,
                          budgetId:pbmId}
                         );
        
       if(pbmId !='' && !$A.util.isUndefinedOrNull(pbmId)){
        helper.callServer(component,
                          "c.getBalanceAllocationAmount",
                          function(response){
                              component.set("v.totalAmount",response);
                              var cmpTarget = component.find('availableAmount');
                              $A.util.removeClass(cmpTarget, 'slds-hide');                            
                              //hide spinner
 			      $A.util.addClass(spinner, "slds-hide");
                          },
                          {accountId:partnerFrom,pmbId:pbmId} 
                         );
        }
    },
    
    
    BudgetTransfer:function(component, event, helper){
     
        var partnerFrom= component.get("v.fromAccountSelectedValue").Id;
        var partnerTo='';
        var budget='';
        var pbmId='';
        var spinner = component.find("accountTransferSpinner");
        //show spinner when transfer button is clicked
        $A.util.removeClass(spinner, "slds-hide");
        
        if(partnerFrom !=null && partnerFrom != ''){
            partnerTo= component.get("v.toAccountSelectedValue").Id;
            if(partnerTo !=null && partnerTo != ''){
                helper.callServer(component,
                                      "c.accountIDNameMapping",
                                      function(response){ component.set("v.partnerTransferTo",response.Name);},
                                      {id:partnerTo} 
                                     );
            }
            component.find('partner_').reduce(function (validSoFar, inputCmp) {
            var name = inputCmp.get('v.name'); 
                if(name=="budget"){
                    budget=inputCmp.get('v.value'); 
                }
            },true);
            
            pbmId=  component.get("v.budgetSelectedValue").Id;
            if(partnerFrom==partnerTo){
                return false;
            } 
        
        if(partnerTo !=null && partnerTo != '' && budget !=null && budget != '' && pbmId !=null && pbmId != ''){            
            if(component.get("v.button")=="false"){
                helper.callServer(component,
                                  "c.transferAllocationAmount",
                                  function(response){ 
                                      if(response==$A.get("$Label.c.Core_MDF_Success")){
                                          
                                          component.set("v.onSuccessAmount",budget);
                                          
                                          //close other toasts 
                                          var errorToast = component.find('errorToast');        
                                          $A.util.addClass(errorToast, "slds-hide");
                                          
                                          
                                          var cmpTarget = component.find('toast');
                                          $A.util.removeClass(cmpTarget, 'slds-hide'); 
                                          //hide spinner
 					  $A.util.addClass(spinner, "slds-hide");

                                      }
                                      else if(response==$A.get("$Label.c.Core_MDF_NoIUPGMExists") || response==$A.get("$Label.c.Core_MDF_RestrictTransfer_from_Nodes_for_PrimaryRoles")){
                                            //close other toasts 
                                            var successToast = component.find('toast');
                                            $A.util.addClass(successToast, 'slds-hide');
                                            
                                            var errToast = component.find('errorToast');
                                            component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_BudgetAccountValidation"));
                                            $A.util.removeClass(errToast, 'slds-hide');                                      
                                              //hide spinner
                                              $A.util.addClass(spinner, "slds-hide");
                                            window.setTimeout($A.getCallback(function() {
                                                if(component.isValid()) {
                                                    $A.util.addClass(errToast, "slds-hide");
                                                }
                                            }), component.get("v.fadeTimeout"));
                                      }
                                      else {
                                          //close other toasts 
                                          var successToast = component.find('toast');
                                          $A.util.addClass(successToast, 'slds-hide');
                                          
                                          var errToast = component.find('errorToast');
                                          component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
                                          $A.util.removeClass(errToast, 'slds-hide');                                      
                                          //hide spinner
 					  $A.util.addClass(spinner, "slds-hide");
                                          window.setTimeout($A.getCallback(function() {
                                              if(component.isValid()) {
                                                  $A.util.addClass(errToast, "slds-hide");
                                              }
                                          }), component.get("v.fadeTimeout"));
                                          
                                      }
                                      
                                  },
                                  {partnerFrom:partnerFrom,partnerTo:partnerTo,pbmId:pbmId,amount:budget,typeOfTransfer:$A.get("$Label.c.Core_MDF_Budget_Transfer_Type_Manual")} 
                                 );
            }
        } 
        else{
            component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_fill_req_fields"));
            var errorToast = component.find('errorToast');        
            $A.util.removeClass(errorToast, "slds-hide");
            }
        }
        
        
        component.set("v.button","true");
        helper.callServer(component,
                          "c.getBalanceAllocationAmount",
                          function(response){component.set("v.totalAmount",response);},
                          {accountId:partnerFrom,pmbId:pbmId} 
                         ); 
    },
    
    //transfer button toggle
    ButtonToggle:function(component, event){
        
        //disable the transfer button
        component.set("v.button","true");
        
        var serverAmount=0;
        var currentAmount=component.get("v.budget");
        var pbmId='';
        var toAccId='';
        var currentAmountDecimalLength = (currentAmount != '' && parseFloat(currentAmount) % 1 != 0) ? parseFloat(currentAmount).toString().split(".")[1].length : '';
        
        if(currentAmount !=null && currentAmount != ''){
            
            pbmId=component.get("v.budgetSelectedValue").Id;
            toAccId = component.get("v.toAccountSelectedValue").Id;
            	if(pbmId!='' && pbmId!= null && toAccId!='' && toAccId!= null){
                    serverAmount=component.get("v.totalAmount");  
                    if(parseFloat(currentAmount)<=parseFloat(serverAmount) && parseFloat(currentAmount)>0 && parseFloat(serverAmount)>0 
                        && (currentAmountDecimalLength == '' || parseFloat(currentAmountDecimalLength) <= 2)){
                        //enable the transfer button
                        component.set("v.button","false");  
                    }
                    else{
                        //disable the button
                        component.set("v.button","true");
                    }
                }
                component.find('partner_') .reduce(function (validSoFar, inputCmp) {
                    var name = inputCmp.get('v.name');
                    if(name=="budget"){ 
                        if(parseFloat(currentAmount)>parseFloat(component.get("v.totalAmount")) && 
                           parseFloat(currentAmount)>0 && parseFloat(component.get("v.totalAmount"))>0){
                           //disable the transfer button
                            component.set("v.button","true");
                            inputCmp.setCustomValidity($A.get("$Label.c.Core_MDF_Transfer_cannot_exceed"));
                            inputCmp.reportValidity();
                            component.set("v.amountTransferExceedsError", "true");
                            
                        }
                    }
    
            },true);
        }
    },
    
    GetBudget:function(component,event, helper){
        var selectedId='';
        
        var spinner = component.find("accountTransferSpinner");
        //show spinner when Budget is getting load
        $A.util.removeClass(spinner, "slds-hide");
        //check if Account record Account Transfer button is clicked
        if(component.get("v.autoSelected")=="false")
        {
            var selectedVal=component.get("v.fromAccountSelectedValue");
            //component.set("v.fromAccountSelectedValue",selectedVal);
            selectedId=selectedVal.Id; 
        }
        else
        {
            selectedId=component.get("v.recordId");    
        }
        //get budget list
        helper.callServer(component,
                          "c.getBudgetList",
                          function(response){
                              component.set("v.PartnerMarketingBudgetList",response);
                              //hide spinner
 							  $A.util.addClass(spinner, "slds-hide");
                              component.set("v.disableBudget",false);
                          },
                          {fromAcctId:selectedId}  
                         );
        
    },
    ClearForm:function(component) {
	        //clear the form
        
	        //hide successfull toast message
	        var successToast = component.find('toast');        
	        $A.util.addClass(successToast, "slds-hide");
        
	        //hide error toast message
	        var errorToast = component.find('errorToast');        
	        $A.util.addClass(errorToast, "slds-hide");
        
	        component.set("v.fromAccountSelectedValue","");
        
	        //Clear Budget field
	        var findPMBlwcComp=component.find('PMBComponent');
	        findPMBlwcComp.inputClearValue();
        
	        component.set("v.PartnerMarketingBudgetList",[]);        
        
	        this.ClearBudgetField(component);
        
        //disable the button
        component.set("v.button","true");
        component.set("v.disableBudget",true);
        
	        this.ClearErrorMessages(component);
    },
    ClearBudgetField : function(component){
        component.set("v.toAccountList", []);
        component.set("v.totalAmount","")
        var findlwcComp=component.find('toAccountComponent');
        findlwcComp.inputClearValue();
        this.ClearToAccountField(component);
        
        //hiding Available Amount   
        var cmpTarget = component.find('availableAmount');
        $A.util.addClass(cmpTarget, 'slds-hide');
        component.set("v.disableToAccount",true);
        
    },
    ClearToAccountField : function(component){
        component.set("v.budget","");
        component.set("v.toAccountSelectedValue","");
        component.set("v.disableTransferAmount",true);
    },
    
    ClearErrorMessages: function(component){
       component.find('partner_').reduce(function (validSoFar, inputCmp){
            var name = inputCmp.get('v.name'); 
            if(name=="budget" && component.get("v.sameAmountTransferError")=="true"){                
                inputCmp.setCustomValidity("");
                component.set("v.sameAmountTransferError","false");
            }
            else  if(name=="budget" && component.get("v.amountTransferExceedsError")=="true"){
                inputCmp.setCustomValidity("");
                component.set("v.amountTransferExceedsError","false");
            }
            if(component.get("v.error")=="true"){                
                inputCmp.setCustomValidity("");
                component.set("v.error","false");
            }
        },true);
    },
    
    handleServerExceptions: function(component,returnValue) {
        var exceptionerrors = returnValue;
        var errorToast = component.find('errorToast');        
        $A.util.addClass(errorToast, "slds-hide");
        var errToast = component.find('errorToast');
        component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_ApplicationErrorMessage"));
        $A.util.removeClass(errToast, 'slds-hide');                                      
        window.setTimeout($A.getCallback(function() {
            if(component.isValid()) {
                $A.util.addClass(errToast, "slds-hide");
            }
        }), component.get("v.fadeTimeout"));
    }  
    
})