({
    doInit : function(component, event, helper) {
        var pageSize = component.get("v.pageSize");
        component.set("v.Message", false);
        var loggedInUserEmail = $A.get("$SObjectType.CurrentUser.Email");
        //component.set("v.loggedInUserEmail",loggedInUserEmail);
        component.set("v.searchKeyword",""); 
        component.set("v.isSearchResult", false);
    	var action = component.get("c.contactListView");   
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State999999999 ="+response.getState());
            if (state === "SUCCESS") {                
                
                var returnValue = response.getReturnValue();
                //console.log("returnValue11="+returnValue);
                console.log("returnValue ="+JSON.stringify(returnValue));
                component.set("v.searchResult", returnValue.lstContactToReturn);
               	component.set("v.partnerRole", returnValue.contactPartnerRole);
                
                //JSON Formation
                var lstContacts = returnValue.lstContactToReturn;
                 
                for(var con in lstContacts) {
                    lstContacts[con].Name = lstContacts[con].Name.length > 30 ? lstContacts[con].Name.substring(0,30) + '...' : lstContacts[con].Name;
                    //lstContacts[con].displayRole = ''
                    var lstEntitlements = lstContacts[con].Contact_Entitlements__r
                    
                    var roles = ''
                    if(lstEntitlements && lstEntitlements.length > 0) {
                        if(lstEntitlements.length == 1) {
                           roles = lstEntitlements[0].Core_Entitlement_Id__r.Name
                        }
                        for(var conEnt in lstEntitlements){
                            
                        	console.log("single ent = "+JSON.stringify(lstEntitlements[conEnt]));
                            if(lstEntitlements[conEnt].Core_Entitlement_Id__r.Name != 'Employee'){
                                roles = roles=='' ?
                                    lstEntitlements[conEnt].Core_Entitlement_Id__r.Name : 
                                	roles + ', ' + lstEntitlements[conEnt].Core_Entitlement_Id__r.Name;
                            }
                            
                            if(lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin') {
                                roles = lstEntitlements[conEnt].Core_Entitlement_Id__r.Name
                                break;
                            }
                            if(lstEntitlements[conEnt].Core_Entitlement_Id__r.Name == 'Partner Admin Delegate') {
                                roles = lstEntitlements[conEnt].Core_Entitlement_Id__r.Name
                                break;
                            }
                            
                    	}
                    }
                    lstContacts[con].displayRole = roles
                    console.log("single contact = "+JSON.stringify(lstContacts[con]));
                }
                
                //PAgination logic
                component.set("v.totalRecords", returnValue.lstContactToReturn.length);
                component.set("v.startPage", 0);  
                component.set("v.endPage", pageSize - 1);
                var PagList =[];
                
                if( returnValue.lstContactToReturn.length > 0) {
                    for ( var i=0; i< pageSize; i++ ) {
                        if(returnValue.lstContactToReturn.length >i) {
                            PagList.push(returnValue.lstContactToReturn[i]);    
                        }    
                    }
                    // console.log('PagList'+PagList);
                    component.set("v.PaginationListrows",PagList);
                }
                
                
                //component.set("v.contList",cont); 
                
                console.log("contList ="+JSON.stringify(returnValue));
             
     }
            
  	});           
        $A.enqueueAction(action);  
	},
    showRow :function(component, event, helper){
        //alert("Load Entitlements");
        component.set("v.rowSelected",false);
        //var currentRow =
        component.set("v.currentRec",event.currentTarget.dataset.myid); 
        component.set("v.rowSelected",true);
        
        console.log("it's work ", event.currentTarget.dataset.myid);
        console.log("currentRec =",component.get("v.currentRec"));
    },
    Search: function(component, event, helper) {
        
        component.set("v.isSearchResult", true);
       	component.set("v.searchResult", null);
        var searchKeyFld = component.find("searchField");
        var srcValue1 = searchKeyFld.get("v.value");
        console.log('before email trim '+srcValue1.length);
		component.set("v.Message", false);
        component.set("v.createNew", false);
        var srcValue = srcValue1.trim();
        console.log('After email trim '+srcValue.length);
        //alert('**'+srcValue+'***');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('userId = '+ JSON.stringify(userId));       
        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;    
        
        if (srcValue == '' || srcValue == null) {
            // display error message if input value is blank or null
            searchKeyFld.set("v.errors", [{
                message: "Enter Search Keyword..."
            }]);
        }
        else if(!filter.test(srcValue)){
            searchKeyFld.set("v.errors", [{
                message: "Please provide a valid email address..."
            }]);
        }
            else {
                searchKeyFld.set("v.errors", null);
                // call helper method
                //helper.SearchHelper(component, event, userId);
                //helper.SearchHelperDB(component, event);
                
                helper.searchContact(component, event, userId);
                //alert('**'+Component.get("v.OPIDExists")+'**');
            }
    },
    
    
    showModal : function(component, event, helper) {
        component.set("v.showModal", "true");
    },
    
    validateComponent : function(component, event, helper) {
        var sourceComponent = event.getParam("sourceCmp");
        //alert(sourceComponent);
        if(sourceComponent != "EPUM_SearchContact"){
            //alert("in side if");
            component.set("v.searchResult",null);
        }
		//need to update logic
        if(sourceComponent == "EPUM_SearchContact" && !component.get("v.isSearchResult")){
			//alert("inside")            
            var epumLog = component.get("c.insertEpumLog");   
        	epumLog.setCallback(this, function(response) {
            var state = response.getState();
            console.log("State ="+response.getState());
            if (state === "SUCCESS") {                
                
            }
  		});    
        $A.enqueueAction(epumLog);
            
        }
        
    },
    
    nextButton : function(component, event, helper) {
        var contactsList = component.get("v.searchResult");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i = end + 1; i < end + pageSize + 1; i++ ) {
            console.log(contactsList.length);
            if ( contactsList.length > i ) {
                PagList.push(contactsList[i]);
            }
            counter ++ ;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationListrows', PagList);
    },
    
    previousButton : function(component, event, helper) {
        var contactsList = component.get("v.searchResult");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var PagList = [];
        var counter = 0;
        for ( var i= start-pageSize; i < start ; i++ ) {
            if ( i > -1 ) {
                PagList.push(contactsList[i]);
                counter ++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.PaginationListrows', PagList);
    },
    
})