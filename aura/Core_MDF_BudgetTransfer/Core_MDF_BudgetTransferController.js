({
    DoInit : function(component, event, helper) {
        
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
                                                            component.set("v.selectedValue",response);  
                                                            
                                                        },
                                                        {id:component.get("v.recordId")} 
                                                       );
                                      
                                      helper.DropDownActivity(component, event, helper);
                                      
                                      
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
    SearchAccounts: function(component, event, helper) {
       	var search = "";
        component.find('partner_').reduce(function (validSoFar, inputCmp) {
            var name = inputCmp.get('v.name'); 
            if(name=="fromAccount"){   
               search=inputCmp.get('v.value');   
            }
            
        },true);
        
        var fromAccountDropDown=component.find("fromAccountDropDown");
        
        //user searches for more than 2 chars
        if(search.length > 2){
            $A.util.addClass(fromAccountDropDown,"slds-is-open");
            
            
            //get the from list
            helper.callServer(component,
                              "c.searchAccountsLookup",
                              function(response){                                  
                                  component.set("v.searchAccRes", response);
                                  
                              },
                              {query:search}
                             );
            
        }
        else{   
            component.set("v.searchAccRes", "");
            $A.util.removeClass(fromAccountDropDown,"slds-is-open");
        }
        
    },
    DropDownCombo:function(component, event, helper) {
        //setting auto selected value for FROM list
        component.set("v.autoSelected","false");
        helper.DropDownActivity(component, event, helper);
        
        
        
    },
    OnBudgetChange:function(component, event, helper) {
        console.log("from:"+component.get("v.selectedValue").Id);
        helper.BudgetChange(component, event, helper);
    },
    TransferBudget: function(component, event, helper) {
        helper.BudgetTrasfer(component, event, helper);
        
    },
    
    CloseButton:function(component, event, helper) {
        helper.ClearForm(component);
    },
    HandleBlur:function(component, event, helper) {
        
        //toggle transfer button
        helper.ButtonToggle(component,event);
        helper.ClearErrorMessages(component); 
        
    },
    Clear:function(component, event, helper) {
        //clear form data
        helper.ClearForm(component);
    },
    ClearErrorMsg:function(component, event, helper) {
        helper.ClearErrorMessages(component);       
    },
    OnAccountToChange:function(component, event, helper) {
    
    }
})