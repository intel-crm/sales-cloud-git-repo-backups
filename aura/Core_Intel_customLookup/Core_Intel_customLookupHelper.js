({
	// To fetch the results
    searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
	 // alert('component.get("v.objectAPIName")'+component.get("v.objectAPIName")+'    component.get("v.sAdditionalFilter")'+component.get("v.sAdditionalFilter"));;
     var action = component.get("c.fetchLookUpValues");
      console.log('test-searchKeyWord'+ getInputkeyWord);
      console.log('test-objectName'+ component.get("v.objectAPIName"));
      console.log('test-sAdditionalFilter'+ component.get("v.sAdditionalFilter"));
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'objectName' : component.get("v.objectAPIName"),
            'sAdditionalFilter' : component.get("v.sAdditionalFilter")
          });
        // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
          //  alert(response.getReturnValue());
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", $A.get("$Label.c.Core_MDF_PFR_No_Result_Translation"));
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
               // var UserName =  $A.get("$SObjectType.CurrentUser.Id");
                //alert("UserID"+UserName);
                //  if( var UserName =  $A.get("$SObjectType.CurrentUser.Email");)
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	}
})