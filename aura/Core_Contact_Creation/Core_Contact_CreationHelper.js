({
    searchAccount: function(component, event , radioSelected) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.fetchAccountList");
        action.setParams({
            'userId': userId,
            'AccType':radioSelected
        });
        action.setCallback(this, function(response){
            var storeResponse = response.getReturnValue();
            component.set("v.accounList", storeResponse);
            component.set("v.loaded",false);
        });
        $A.enqueueAction(action);       
    },
    
    populatePicklists : function(component, event) {
        
        var action = component.get("c.fetchPicklistValues");
        var salutationPickListNames = ['Salutation']; /*MailingCountryCode,'MailingCountry'*/
        var countryPickListNames = ['MailingCountryCode'];
        action.setParams({
            'salutationPickListNames': salutationPickListNames,
        });
        action.setCallback(this, function(response){
            var storeResponse = response.getReturnValue();
            try{
                $(storeResponse).each(function(index,entry){
                    if(entry.picklistName !=null && entry.picklistName == 'Salutation' ){//Salutation
                        component.set("v.salutationList", entry.valueList);  
                    }
                    /*if(entry.picklistName !=null && entry.picklistName == 'MailingCountry'){
                        component.set("v.contryList", entry.valueList);
                    }*/
                });
            }catch(error){
            }
            
            
            
            //component.set("v.loaded",false);
        });
        $A.enqueueAction(action);     
    },
    
    populateCountryPicklists : function(component, event) {
        
        var action = component.get("c.fetchPicklistValues");
        var countryPickListNames = ['MailingCountryCode'];
        action.setParams({
            'salutationPickListNames': countryPickListNames,
        });
        action.setCallback(this, function(response){
            var storeResponse = response.getReturnValue();
            try{
                $(storeResponse).each(function(index,entry){
                    if(entry.picklistName !=null && entry.picklistName == 'MailingCountryCode'){
                        component.set("v.contryList", entry.valueList);
                    }
                });
            }catch(error){
            }
            
            
            
            //component.set("v.loaded",false);
        });
        $A.enqueueAction(action);     
    },
    
    saveCont: function(component, userId){
        var title = component.get("v.title");
        var salutation = component.get("v.salutation");
        var phone = component.get("v.phone");
        var first_name = component.get("v.first_name");
        var last_name = component.get("v.last_name");
        var mobile = component.get("v.mobile");
        var email = component.get("v.email");
        var country = component.get("v.country");
        var region = component.get("v.region");
        var accId = component.find("myAccSelect").get("v.value");
        if (accId == 'Search Accounts'){
            component.set("v.loaded",false);
            $('#errorMessageDiv').html($A.get("$Label.c.Core_MDF_Account_error"));
            //component.set("errorMessageDiv", 'Please select appropriate account.');
            //alert('Please select appropriate account');
        }
        else if(first_name == null || first_name == '' || last_name == null || last_name == '' || email == null || email == '' || country == null || country == ''|| (last_name == null && email == null && first_name == null && country == null))
        {
            component.set("v.loaded",false);
            $('#errorMessageDiv').html($A.get("$Label.c.Core_MDF_Required_Information")); 
        }
            else{
                //alert('salutation='+salutation);
                var action = component.get("c.saveContact");
                action.setParams({
                    'userId' : userId,
                    'title': title,
                    'salutation':salutation,
                    'phone': phone,
                    'first_name': first_name,
                    'last_name': last_name,
                    'mobile': mobile,
                    'email': email,
                    'country': country,
                    'region': region,
                    'accId': accId,
                });
            }
        action.setCallback(this, function(response){
            var storeResponse = response.getReturnValue();
            if(storeResponse == false){
                component.set("v.loaded",false);
                $('#errorMessageDiv').html($A.get("$Label.c.Core_MDF_Cannot_Createcontact")); 
            }
            if(storeResponse == true){
                component.set("v.loaded",false);
                $('#errorMessageDiv').html($A.get("$Label.c.Core_MDF_Contact_Success")
);
                //this.navigateToGrantAccessPage(component);
                var evt = $A.get("e.c:Core_Contact_Creation_DisplayEvent");
                evt.setParams({"passEmail": email});
                /*var email2 = component.get("v.email"); */
                evt.fire();
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    navigateToGrantAccessPage : function(component) {
        var address = $A.get("$Label.c.Core_GrantAccessUrl");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": address,
            "isredirect" :false
        });
        urlEvent.fire();
    }
})