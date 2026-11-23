({  
   doInit: function(component, event, helper) {
    // helper.apexMethod(cmp);  
    
        var oppreturn = component.get("c.fetchAccounts");
       
        oppreturn.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.accwrplst", actionResult.getReturnValue());
               // alert(component.get("V.accwrplst").length);
            }
        });
        $A.enqueueAction(oppreturn);
   },  
    
    handleClick : function(component, event, helper) {
        
        var tit = event.getSource().get("v.value");
        var wlst =  component.get("v.accwrplst");
        for(var i=0;i<wlst.length;i++)
        {
            if(wlst[i].acc.Id == tit)
            {
                if(wlst[i].shwoppwrp == false)
                {
                    wlst[i].shwoppwrp  = true;
                  //  alert('1');
                    // Null the sub-Child
                    var temppplst = wlst[i].chldlistobj;
                    for(var j=0;j<temppplst.length;j++)
                    {
                        temppplst[j].shwoppwrp2 = false;
                    }
                }
                else
                {
                    wlst[i].shwoppwrp  = false;
                   // alert('2');
                }
            }
            else
            {
                wlst[i].shwoppwrp = false;
                //alert('3');
            }
        }
        component.set("v.accwrplst", wlst);
        
        //var actId = event.getSource().get("v.value");
       // component.set("v.usrname",event.getSource().get("v.value"));
     /*   var action = component.get("c.fetchchildaccs");
        action.setParams({
             "accid":actId,
        });
        action.setCallback(this,function(result)
                           {
                               var state = result.getState();
                               if (state =="SUCCESS")
                               {
                                   var v=result.getReturnValue();
                                   if(v == null || v == '')
                                   {
                                       component.set("v.chldaccnts",'');
                                       var toastEvent = $A.get("e.force:showToast");
                                       toastEvent.setParams({
                                           mode: 'dismissible',
                                           message: 'No records found',
                                           type : 'warning'
                                       });
                                       toastEvent.fire();
                                       alert('No records found');
                                       return;
                                   }
                                   else
                                   {                                    
                                       component.set("v.chldaccnts",result.getReturnValue());
                                   }
                               }
                           });
        $A.enqueueAction(action);  */
        
    },
    
    getsubchild : function(component, event, helper) {
        component.set("v.sbchldTsks",'');
        var tit = event.getSource().get("v.value");
        var wlst =  component.get("v.accwrplst");
       
        for(var i=0;i<wlst.length;i++)
        {
            var tempprdlst = wlst[i].chldlistobj;
            for(var j=0;j<tempprdlst.length;j++)
            {
                if(tempprdlst[j].chacc.Id == tit)
                {
                    if(tempprdlst[j].shwoppwrp2 == false)
                    {
                        tempprdlst[j].shwoppwrp2  = true;
                    }
                    else
                    {
                        tempprdlst[j].shwoppwrp2  = false;
                    }
                }
                else
                {
                    tempprdlst[j].shwoppwrp2 = false;
                }
            }
        }
        component.set("v.accwrplst", wlst);
    },
   
    
   handleSelect: function (cmp, event, helper) {  
     //return name of selected tree item  
     var myName = event.getParam('name');  
     alert("You selected: " + myName);  
   }  
 })