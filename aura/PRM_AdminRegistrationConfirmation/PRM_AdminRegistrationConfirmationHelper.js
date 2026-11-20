({
    showAcctContInfo : function(component,event,helper) {
        console.log('displayInputs 1'+JSON.stringify(component.get("v.displayInputs")));
        var JSONVALUE = component.get("v.displayInputs");
        var JSON1 = JSONVALUE.SelectedRow;
        console.log('JSON1'+JSON.stringify(JSON1));
        console.log('JSONVal'+JSON.stringify(JSONVALUE));
        var associatedAccount = JSONVALUE.accountAssociatedToExistingContact;
        //console.log('associatedAccount'+JSON.stringify(associatedAccount));
        var existingContact = JSONVALUE.duplicateContactRecord;
        //console.log('existingContact'+JSON.stringify(existingContact));
        var address= '';
        var billingStreet = '';
        var billingCity = '';
        var billingState ='';
        var billingPostalCode = '';
        var billingCountry = '';
        var acctList = [];
        var contList= [];
        var accountListData = {
            AccountName :"",
            BillingAddress : "",
            Core_Account_Type__c : component.get("v.displayInputs")['BizOrgType'],
            Core_IPA_Partner_Role__c : component.get("v.displayInputs")['PartnerRole']
        }
        var contactListData;
        component.set("v.accountColumns",[
            {label:"Name",fieldName:"AccountName",type:"text"},
            {label:"Primary Address",fieldName:"BillingAddress",type:"text"},
            {label:"Biz OrgType",fieldName:"Core_Account_Type__c",type:"text"},
            {label:"Partner Role",fieldName:"Core_IPA_Partner_Role__c",type:"text"}
            
        ]);
        
        component.set("v.contactColumns",[
            {label:"Name",fieldName:"ContactName",type:"text"},
            {label:"Contact Email",fieldName:"ContactEmail",type:"text"}
        ]);
        
        //Populate Account Information
        
        //account associated to an existing contact
        if(associatedAccount != null){
            //alert('Associated Account');
            if(associatedAccount.BillingStreet != undefined && associatedAccount.BillingStreet != null){
                billingStreet = associatedAccount.BillingStreet;
            }
            
            if(associatedAccount.BillingCity != undefined && associatedAccount.BillingCity != null){
                billingCity = associatedAccount.BillingCity;
            }
            
            if(associatedAccount.BillingState != undefined && associatedAccount.BillingState != null){
                billingState = associatedAccount.BillingState;
            }
            
            if(associatedAccount.BillingPostalCode != undefined && associatedAccount.BillingPostalCode != null){
                billingPostalCode = associatedAccount.BillingPostalCode;
            }
            
            if(associatedAccount.BillingCountry != undefined && associatedAccount.BillingCountry != null){
                billingCountry = associatedAccount.BillingCountry;
            }
            
            if(billingStreet != ''){
                address += billingStreet;
            }
            
            if(billingCity != ''){
                if(address.length > 0){
                    address += '\n'+billingCity;
                }
                else {
                    address += billingCity;
                }
            }
            
            if(billingState != ''){
                if(address.length > 0){
                    address += ','+' '+billingState;
                }
                else{
                    address += billingState;
                }
            }
            
            if(billingPostalCode != ''){
                if(address.length > 0){
                    address += ' '+billingPostalCode;
                }
                else{
                    address += billingPostalCode;
                }
            }
            
            if(billingCountry != ''){
                if(address.length > 0){
                    address += '\n'+billingCountry;
                }
                else{
                    address += billingCountry;
                }
            }
            
            //address = associatedAccount.BillingStreet+'\n'+associatedAccount.BillingCity+','+' '+associatedAccount.BillingState+' '+associatedAccount.BillingPostalCode+'\n'+associatedAccount.BillingCountry;
            
            accountListData.AccountName = associatedAccount.Name,
            accountListData.BillingAddress = address
        }
        
        else{
            
            if(JSON1 == null || JSON1 == '' || JSON1.length == 0){
                //alert('UI INPUT');
                
                /*if(component.get("v.displayInputs")['AddressLine2'] != null && component.get("v.displayInputs")['AddressLine2'] != 'undefined' && component.get("v.displayInputs")['AddressLine2'] != ''){
                    address = component.get("v.displayInputs")['AddressLine1']+' '+component.get("v.displayInputs")['AddressLine2']+'\n'+component.get("v.displayInputs")['City']+','+' '+component.get("v.displayInputs")['State']+' '+component.get("v.displayInputs")['PostalCode']+'\n'+component.get("v.displayInputs")['Country'];
                }
                else
                {
                    address = component.get("v.displayInputs")['AddressLine1']+'\n'+component.get("v.displayInputs")['City']+','+' '+component.get("v.displayInputs")['State']+' '+component.get("v.displayInputs")['PostalCode']+'\n'+component.get("v.displayInputs")['Country'];
                }*/
                
                accountListData.AccountName = component.get("v.displayInputs")['AccountName'],
                accountListData.BillingAddress = component.get("v.displayInputs")['BillingAddress']
            }
            
            else {
                //alert('SELECTED ROW');
                //address = JSON1[0].BillingStreet+'\n'+JSON1[0].BillingCity+','+' '+JSON1[0].BillingState+' '+JSON1[0].BillingPostalCode+'\n'+JSON1[0].BillingCountry;
                
                /*if(JSON1[0].BillingStreet != undefined && JSON1[0].BillingStreet != null){
                    billingStreet = JSON1[0].BillingStreet;
                }
                
                if(JSON1[0].BillingCity != undefined && JSON1[0].BillingCity != null){
                    billingCity = JSON1[0].BillingCity;
                }
                
                if(JSON1[0].BillingState != undefined && JSON1[0].BillingState != null){
                    billingState = JSON1[0].BillingState;
                }
                
                if(JSON1[0].BillingPostalCode != undefined && JSON1[0].BillingPostalCode != null){
                    billingPostalCode = JSON1[0].BillingPostalCode;
                }
                
                if(JSON1[0].BillingCountry != undefined && JSON1[0].BillingCountry != null){
                    billingCountry = JSON1[0].BillingCountry;
                }
                
                if(billingStreet != ''){
                    address += billingStreet;
                }
                
                if(billingCity != ''){
                    if(address.length > 0){
                        address += '\n'+billingCity;
                    }
                    else {
                        address += billingCity;
                    }
                }
                
                if(billingState != ''){
                    if(address.length > 0){
                        address += ','+' '+billingState;
                    }
                    else{
                        address += billingState;
                    }
                }
                
                if(billingPostalCode != ''){
                    if(address.length > 0){
                        address += ' '+billingPostalCode;
                    }
                    else{
                        address += billingPostalCode;
                    }
                }
                
                if(billingCountry != ''){
                    if(address.length > 0){
                        address += '\n'+billingCountry;
                    }
                    else{
                        address += billingCountry;
                    }
                }*/
                
                accountListData.AccountName = JSON1[0].Name,
                accountListData.BillingAddress = JSON1[0].BillingAddress                
            }
        }
        
        //Populate Contact Information
        if(existingContact != null){
            
            contactListData = {
                ContactName : existingContact.Name,
                ContactEmail : existingContact.Email
                
            }
        }
        else{
            contactListData = {
                ContactName : component.get("v.displayInputs")['ContactFirstName']+' '+component.get("v.displayInputs")['ContactLastName'],
                ContactEmail : component.get("v.displayInputs")['ContactEmail']
            }
        }
        
        acctList.push(accountListData);
        contList.push(contactListData);
        
        console.log('accountListData' + JSON.stringify(acctList));
        console.log('contactListData'+JSON.stringify(contList));
        
        component.set("v.accountData",acctList);
        component.set("v.contactData",contList);        
    }
})