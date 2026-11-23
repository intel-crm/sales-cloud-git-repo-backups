({
    callServer : function(component,method,callback,params) {
        
        var action = component.get(method);
        if (params != undefined) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    
                    if (errors[0] && errors.message) {
                        throw new Error("Error tr" + errors[0].message);
                    }                
                    else if(errors[0] && errors[0].fieldErrors && errors[0].fieldErrors.Amount[0]){
                        
                        var validity= component.find('partner_')                
                        .reduce(function (validSoFar, inputCmp) {
                            inputCmp.showHelpMessageIfInvalid(); 
                            var name = inputCmp.get('v.name');            
                            if(name=="budget"){                                                         
                                inputCmp.setCustomValidity(errors[0].fieldErrors.Amount[0].message);
                                inputCmp.reportValidity();     
                                
                            }
                            
                        },true);
                    }
                        else if(errors[0] && errors[0].message== $A.get("$Label.c.Core_MDF_No_Available_Budget_Error")){
                            
                            var validity= component.find('partner_')                
                            .reduce(function (validSoFar, inputCmp) {
                                var name = inputCmp.get('v.name');            
                                if(name=="fromAccount"){    
                                    
                                    inputCmp.setCustomValidity(errors[0].message);
                                    inputCmp.reportValidity();     
                                    component.set("v.error", "true");
                                    
                                }
                                
                            },true);
                            
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
        var partnerFrom=component.get("v.selectedValue").Id;
        
        //disable the button
        component.set("v.button","true");
        
        var allValid = component.find('partner_')                
        .reduce(function (validSoFar, inputCmp) {
            
            var name = inputCmp.get('v.name'); 
            if(name=="partnerAllocation"){
                pbmId=inputCmp.get('v.value'); 
                
            }
        },true);
        
        //get TO list       
        helper.callServer(component,
                          "c.getToAccounts",
                          function(response){
                              component.set("v.partnersDataTo",response);     
                              
                          },
                          {fromAcctId:component.get("v.selectedValue").Id}  
                         );
        
        
        helper.callServer(component,
                          "c.getBalanceAllocationAmount",
                          function(response){
                              component.set("v.totalAmount",response);
                              var cmpTarget = component.find('availableAmount');
                              $A.util.removeClass(cmpTarget, 'slds-hide');                            
                          },
                          {accountId:partnerFrom,pmbId:pbmId} 
                         );
    },
    
    BudgetTrasfer:function(component, event, helper){
        
        var budget=component.get("v.budget");       
        
        var partnerFrom=component.get("v.selectedValue").Id;
        
        var partnerTo='';
        var budget='';
        var pbmId='';
        var allValid = component.find('partner_')                
        .reduce(function (validSoFar, inputCmp) {
            
            var name = inputCmp.get('v.name');
            if(name=='partnerTo'){
                partnerTo=inputCmp.get('v.value');
                
                if(partnerTo.length>0){
                    helper.callServer(component,
                                      "c.accountIDNameMapping",
                                      function(response){                                      
                                          component.set("v.partnerTransferTo",response.Name);
                                      },
                                      {id:partnerTo} 
                                     );
                }
                
            }
            else if(name=="budget")
            {                     
                budget=inputCmp.get('v.value'); 
            }
                else if(name=="partnerAllocation"){
                    pbmId=inputCmp.get('v.value');                
                }
            if(partnerFrom==partnerTo){
                return false;
            }            
            return validSoFar && inputCmp.get('v.validity').valid;                
        },true);
        
        if(allValid){
            
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
                                          window.setTimeout($A.getCallback(function() {
                                              if(component.isValid()) {
                                                  $A.util.addClass(cmpTarget, "slds-hide");
                                                  component.set("v.onSuccessAmount","");
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
            component.set("v.errorMsg", $A.get("$Label.c.Core_MDF_fill_req_fields"))
            var errorToast = component.find('errorToast');        
            $A.util.removeClass(errorToast, "slds-hide");
        }
        
        
        component.set("v.button","true");
        helper.callServer(component,
                          "c.getBalanceAllocationAmount",
                          function(response){
                              component.set("v.totalAmount",response);                                                      
                          },
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
        var allValid = component.find('partner_')                
        .reduce(function (validSoFar, inputCmp) {
            
            var name = inputCmp.get('v.name');            
            if(name=="partnerAllocation"){
                pbmId=inputCmp.get('v.value'); 
                
                
                if(pbmId!=''){
                    
                    serverAmount=component.get("v.totalAmount");  
                    
                    if(currentAmount<=serverAmount && currentAmount>0 && serverAmount>0 ){   
                        //enable the transfer button
                        component.set("v.button","false");                
                        
                    }
                    
                    else{
                        //disable the button
                        component.set("v.button","true");
                        
                    }
                    
                    
                }
                
                
            }
            
            
            else if(name=="budget"){ 
                
                if(currentAmount>component.get("v.totalAmount") && currentAmount>0 && component.get("v.totalAmount")>0){
                    
                    //disable the transfer button
                    component.set("v.button","true");
                    
                    inputCmp.setCustomValidity($A.get("$Label.c.Core_MDF_Transfer_cannot_exceed"));
                    inputCmp.reportValidity();    
                    
                    component.set("v.amountTransferExceedsError", "true");
                    
                }
            }
            
            
        },true);
        
        
        
        
    },
    
    DropDownActivity:function(component,event, helper){
        
        var dropDownComboEle=component.find("fromAccountDropDown");
        $A.util.removeClass(dropDownComboEle,"slds-is-open");
        
        var selectedId='';
        if(component.get("v.autoSelected")=="false")
        {
            
            var selectedItem = event.currentTarget;
            var id = selectedItem.dataset.id;        
            var selectedVal=component.get("v.searchAccRes")[id]; 
            component.set("v.selectedValue",selectedVal);
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
                              
                              
                          },
                          {fromAcctId:selectedId}  
                         );
        
    },
    ClearForm:function(component) {
        //clear the form
        
        
        
        var clearFields = component.find('partner_')                
        .reduce(function (validSoFar, inputCmp) {
            
            var name = inputCmp.get('v.name');            
            if(name=="partnerAllocation"){
                inputCmp.set('v.value',"");                 
            }
            else if(name=="fromAccount"){
                inputCmp.set('v.value',"");                  
            }
        },true);
        
        //Hide Drop Down Combobox
        var fromAccountDropDown=component.find("fromAccountDropDown");
        $A.util.removeClass(fromAccountDropDown,"slds-is-open");
        
        //hiding Available Amount   
        var cmpTarget = component.find('availableAmount');
        $A.util.addClass(cmpTarget, 'slds-hide');
        
        //hide successfull toast message
        var successToast = component.find('toast');        
        $A.util.addClass(successToast, "slds-hide");
        
        //hide error toast message
        var errorToast = component.find('errorToast');        
        $A.util.addClass(errorToast, "slds-hide");
        
        
        
        component.set("v.totalAmount","");
        component.set("v.partnersDataFrom","");
        component.set("v.PartnerMarketingBudgetList",null);
        component.set("v.partnersDataTo",null);
        component.set("v.budget","");
        
        //disable the button
        component.set("v.button","true");
        
        this.ClearErrorMessages(component);
    },
    
    ClearErrorMessages: function(component){
        
        
        var clear= component.find('partner_')                
        .reduce(function (validSoFar, inputCmp) {
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
    
    
})