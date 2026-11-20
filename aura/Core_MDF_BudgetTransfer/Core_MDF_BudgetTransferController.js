({
    DoInit : function(component, event, helper) {
       //server call for FromAccount
        helper.callServer(component,
                         "c.searchAccountsLookup",
                         function(response){component.set("v.fromAccountList",response);});
        
        //server call for FromAccount if Auto Selected is true
        helper.callServer(component, "c.checkAccess",
                          function(response){
                              if(response == true)
                              {
                                  component.set('v.hasAccess',response); 
                                  var getRecordId=component.get("v.recordId");
                                  
                                  
                                  //get Account Name-From
                                  if (typeof getRecordId != 'undefined' && getRecordId.length>0 ){
                                      
                                      helper.callServer(component,
                                                        "c.accountIDNameMapping",
                                                        function(response){
                                                            component.set("v.fromAccountSelectedValue",response);  
                                                            
                                                        },
                                                        {id:component.get("v.recordId")} 
                                                       );
                                      
                                      helper.GetBudget(component, event, helper);
                                  }
                                  
                              }
                              else 
                              {
                                  component.set('v.accessErrorMsg', $A.get('$Label.c.Core_MDF_Budget_Transfer_Access_Error_Message')); 
                              }
                          });
    }, 
    
    
    CloseToast: function(component, event, helper) {
        var cmpTarget = component.find('toast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    CloseErrorToast: function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },
    close: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    //Getting From Account selected value
    OnBudgetChange:function(component, event, helper) {
         //getting values from dispatch event call
        let selectedBudget = event.getParam('selectedItem');
        component.set("v.budgetSelectedValue",selectedBudget);
        $A.enqueueAction(component.get('c.CloseToast'));
        $A.enqueueAction(component.get('c.CloseErrorToast'));
        helper.BudgetChange(component, event, helper);
    },
    TransferBudget: function(component, event, helper) {
        var dt = new Date();
		$A.enqueueAction(component.get('c.CloseToast'));
        $A.enqueueAction(component.get('c.CloseErrorToast'));
        // will output something like "Thu Feb 14 2019 11:04:42 GMT+0530 (India Standard Time)"
        console.log('Start::'+dt.toString());
        
        helper.BudgetTransfer(component, event, helper);
        
        console.log('End::'+dt.toString());
    },
    // to clear all field value if dispatch event is called from FromAccount
    ClearFromAccount:function(component, event, helper) {
        helper.ClearForm(component);
    },
    fromAccountClick:function(component, event, helper) {
        component.set("v.button",true);
    },
    //to clear Budget, Avaiable amount, To Account and Amount to Tranfer value if dispatch event is called from Budget field
    ClearBudget:function(component, event, helper) {
        helper.ClearBudgetField(component);
    },
    //to clear To Account, Amount to transfer value if dispatch event is called from To Account
    ClearToAccount:function(component, event, helper) {
        helper.ClearToAccountField(component);
    },
    
    //To toggle transfer button & to show error messages
    HandleBlur:function(component, event, helper) {                
        $A.enqueueAction(component.get('c.CloseToast'));
        $A.enqueueAction(component.get('c.CloseErrorToast'));
        //toggle transfer button
        helper.ButtonToggle(component,event);
        helper.ClearErrorMessages(component);        
    },
    //to clear all field value when clear button is clicked
    Clear:function(component, event, helper) {
        //clear form data
        helper.ClearForm(component);
        var findfromAcclwcComp=component.find('fromAccountComponent');
        findfromAcclwcComp.inputClearValue();
    },
    //Getting From Account selected value
    fromAccountToChange:function(component, event, helper) {
    	helper.ClearForm(component);
        //getting values from dispatch event call
    	let selectedFromAcc = event.getParam('selectedItem');
        component.set("v.fromAccountSelectedValue",selectedFromAcc);
        //set auto selected value of from account to false
        component.set("v.autoSelected","false");
        helper.GetBudget(component, event, helper);
	},
    //Getting To Account selected value
    toAccountToChange:function(component, event, helper) {
        //getting values from dispatch event call
        let selectedToAcc = event.getParam('selectedItem');
        component.set("v.toAccountSelectedValue",selectedToAcc);
        if(selectedToAcc != null && selectedToAcc != ''){
           component.set("v.disableTransferAmount",false);
           }
    	$A.enqueueAction(component.get('c.CloseToast'));
        $A.enqueueAction(component.get('c.CloseErrorToast'));
    },
})