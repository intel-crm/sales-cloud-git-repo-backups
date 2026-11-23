({
    Search: function(component, event, helper) {
        
        component.set("v.isNew",false);
        var searchKeyFld = component.find("searchId");
        var srcValue1 = searchKeyFld.get("v.value");        
        var srcValue = srcValue1.trim();
        //alert('**'+srcValue+'***');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        console.log('userId = '+ userId);       
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
                helper.SearchHelper(component, event, userId);
            }
    },
    navigateToContact : function(component, event, helper) { 
        
        component.set("v.isNew",false);
        component.set("v.isView",true);
        component.set("v.objId",event.target.id); 
        component.set("v.headerText","My Contact");
        
        // Get the application event by using the
        // e.. syntax
        var appEvent = $A.get("e.c:ContactViewCompEvent");
        appEvent.setParams({"recordId" : event.target.id});
        appEvent.fire();
    } ,
    
    createNew : function(component){ 
        
        try{
            //var searchResultList = component.get("v.searchResult");
            /*if(searchResultList[0] != null){
                emailAddress = searchResultList[0].Email;
            }*/
            component.set("v.isNew",true);
            component.set("v.headerText","New Contact");
            component.set("v.isNew",true);
            component.set("v.isView",false);
            component.set("v.isNewContact",true);
            
            var compEventCreate =  $A.get("e.c:Core_Contact_Creation_Event"); 
            var emailAddress = component.get("v.searchKeyword");
            console.log('createNew > emailAddress = '+ emailAddress);
            compEventCreate.setParams({'emailAddress': emailAddress});
            console.log('compEventCreate = '+ compEventCreate);
            compEventCreate.fire(); 
        }catch(error){
            console.log(error);
        }
        
        
        /**/
        
        /* try{
            var compEvent =  $A.get("e.c:Core_Contact_Creation_Event");
            console.log(compEvent);
            compEvent.fire(); 
             }catch(error){
            console.log(error);
        }*/
    },
    searchShow : function(component){ 
        component.set("v.headerText","Search Contact");
        component.set("v.isNew",false);
        component.set("v.isView",false);
    },
    
    passEmailFromSavedContactToDisplay : function(component, event, helper){
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.searchKeyword",event.getParam("passEmail"));
        helper.SearchHelper(component, event, userId);
    },
    
    loadEntitlements : function(component, helper){
        try{
            //helper.loadEntitlementsHelperFunc(component);
            //console.log('helper --> ' + helper); 
        }catch(error){
            console.log(error);
        }
        //console.log(component); 
        try{
            var compEvent =  $A.get("e.c:Core_Contact_Ent_Event"); 
            //var compEvent = component.getEvent("loadEntitlementEvent");
            var contactRecordId = component.get("v.contactRecId");
            console.log('contactRecordId = '+ contactRecordId);
            compEvent.setParams({'contactId' : contactRecordId, 'isClearEntitlements': false});  //'0033D00000W6A5YQAV'
            console.log(compEvent);
            compEvent.fire(); 
        }catch(error){
            console.log(error);
        }
    }
    
})