({
    fetchAccountContact : function(component,event,helper) {
        var action = component.get("c.showAccountsContacts");
        console.log('component.get("v.accountName")-->' +JSON.stringify(component.get("v.accountName")));
        console.log('mapValues-->  ' + JSON.stringify(component.get("v.redDetMap")));
        if(component.get("v.redDetMap") != null){
            var accountDupStatusMapTemp = component.get("v.redDetMap").accountDupStatusMapOnUI;
            var inputMapForApex = component.get("v.redDetMap") ;
            console.log('input for Apex'+JSON.stringify(inputMapForApex));
            console.log('selected attribute of input Map'+component.get("v.redDetMap").SelectedRow);
            if(component.get("v.redDetMap").SelectedRow != null) inputMapForApex.SelectedRow = JSON.stringify(component.get("v.redDetMap").SelectedRow);
            if(component.get("v.redDetMap").accountAssociatedToExistingContact != null) inputMapForApex.accountAssociatedToExistingContact = JSON.stringify(component.get("v.redDetMap").accountAssociatedToExistingContact);
            if(component.get("v.redDetMap").duplicateContactRecord != null) inputMapForApex.duplicateContactRecord = JSON.stringify(component.get("v.redDetMap").duplicateContactRecord);
            if(component.get("v.redDetMap").associatedAccountIsIPA != null) inputMapForApex.associatedAccountIsIPA = JSON.stringify(component.get("v.redDetMap").associatedAccountIsIPA);
            if(component.get("v.redDetMap").accountDupStatusMapOnUI !=null) inputMapForApex.accountDupStatusMapOnUI = JSON.stringify(component.get("v.redDetMap").accountDupStatusMapOnUI);
            action.setParams({
               requestDetails:inputMapForApex
            });
            
            action.setCallback(this, function(data) {
                var state= data.getState();
                //alert('return value'+JSON.stringify(data.getReturnValue()));
                console.log('STATE -->'+state);

                if(component.isValid() && state === "SUCCESS") {
                    var result = data.getReturnValue();
                    var concatAddr;
                    var finalAddr;
                    console.log('Result Response -->'+JSON.stringify(data.getReturnValue()));
                    var resultAccList = result.accountList;
                    var accountMap = result.accountIdDupStatus; //Added as part of TWC729-3218
                    console.log('result.accountIdDupStatus'+result.accountIdDupStatus);
                    console.log('resultAccList-->'+ JSON.stringify(resultAccList));
                    console.log('accountMap1 '+accountMap);
                    
                    if(result.accountList == null && component.get("v.redDetMap")['DuplicateInfo']!=null && component.get("v.redDetMap")['DuplicateInfo'].length!=0 && component.get("v.redDetMap")['DuplicateInfo']!='No Duplicate Values Found'){
                        //in case no callout required for CIM  i.e.  DuplicateInfo in Map is blank or 'No DUplicate values Found' --> in this case apex will return null
                        resultAccList = JSON.parse(component.get("v.redDetMap")['DuplicateInfo']);   
                    }else if(resultAccList == null || resultAccList =='' || resultAccList==' '){
                        resultAccList = null;  
                    }
                    
                    if(accountMap == undefined && accountDupStatusMapTemp != undefined && accountDupStatusMapTemp.length!=0){
                    console.log('inside dup status:'+accountDupStatusMapTemp);
                    accountMap = accountDupStatusMapTemp;
                    }
                    //alert(''+JSON.stringify(result.associatedAccountIsIPA));
                    console.log('resultAccList --> '+resultAccList);
                    //component.set("v.accountsCim",resultAccList);
                    
                    
                    /*if(result.accountDupStatus != undefined && result.accountDupStatus != '' &&
                       result.accountDupStatus != null){
                        alert('Set Dup Status');
                        component.set("v.accountDupStatus",result.accountDupStatus);
                    } */
                    
                    //alert('result.accountDupStatus'+result.accountDupStatus);
                    var accountDupStatus = null;
                    console.log('MAP VALUES____'+component.get("v.redDetMap"));
                    if(component.get("v.redDetMap")  != null && component.get("v.redDetMap")  != undefined)
                    {   //alert('Map values-->'+component.get("v.redDetMap").AccountDuplicateStatus)
                        accountDupStatus = component.get("v.redDetMap").AccountDuplicateStatus ;
                    }
                    //alert('Duplicate value in MAP'+accountDupStatus);
                    if(result.accountDupStatus != undefined && result.accountDupStatus != '' && result.accountDupStatus != null && 
                       (component.get("v.redDetMap")['DuplicateInfo']==null || component.get("v.redDetMap")['DuplicateInfo'].length==0)){
                        //alert('Set Dup Status-- Value returned from CIM');
                        accountDupStatus = result.accountDupStatus ;
                    }
                    component.set("v.accountDupStatus",accountDupStatus);
                    var contactDupStatus = null ; 
                    if(component.get("v.redDetMap")  != null && component.get("v.redDetMap")  != undefined)
                    {   //alert('Map values-->'+component.get("v.redDetMap").AccountDuplicateStatus)
                        contactDupStatus = component.get("v.redDetMap").CountDuplicateStatus ;
                    }
                    //alert('Duplicate value in MAP'+contactDupStatus);
                    if(result.contactDupStatus != undefined && result.contactDupStatus != '' && result.contactDupStatus != null){
                        //alert('Set Dup Status-- Value returned from CIM');
                        contactDupStatus = result.contactDupStatus ;
                    }
                    component.set("v.contDupStatus",contactDupStatus);
                    
                    //set value of AccountAssociatedToContact in case of duplicate contact
                    var accountAssociatedToExistingContact = null ;
                    if(result.accountAssociatedToExistingContact != null)
                    {
                        accountAssociatedToExistingContact = result.accountAssociatedToExistingContact;
                    }
                    var duplicateContactRecord = null;
                    if(result.duplicateContactRecord != undefined && result.duplicateContactRecord != null){
                        duplicateContactRecord = result.duplicateContactRecord;
                    }
                    
                    console.log("duplicateContactRecord"+JSON.stringify(duplicateContactRecord));
                    var resultContList = result.contactList;
                    var accList= [];
                    var reqAccList=[];
                    var cntList= [];
                    var blocked=false;
                    // For the user input Account
                    component.set("v.requstdaccountColumns", [
                        {label:"Reuse",type:"text",initialWidth:75,cellAttributes: { alignment: 'left' }},
                        {label:"Name",fieldName:"AccountName",type:"text",initialWidth: 150,cellAttributes: { class: { fieldName: 'colorReqAcc' }}},
                        {label:"Primary Address",fieldName:"BillingAddress",type:"text",initialWidth: 150},
                        {label:"Unified Heirarchy",fieldName:"Unified_Hierarchy_View__c",type:"text",initialWidth: 150},
                        {label:"Unified Id",fieldName:"Core_Business_Party_Id__c",type:"text",initialWidth: 150},
                        //{label:"Unified Customer Type",fieldName:"Core_Customer_Aggregation_Type__c",type:"text",initialWidth: 150},
                        {label:"Associated Unified Global",fieldName:"parentName",type:"url", initialWidth: 150},
                        {label:"IPA Account",fieldName:"Core_Intel_Partner_Alliance_PartnerGroup__c",type:"boolean",initialWidth: 150},
                        {label:"Biz OrgType",fieldName:"Core_Account_Type__c",type:"text"},
                        {label:"Partner Role",fieldName:"Core_IPA_Partner_Role__c",type:"text"},
                        //{label:"Duplicate Account Status",fieldName:"DuplicateStatus",type:"text"}
                    ]);
                    
                    if (component.get("v.redDetMap")['AddressLine2'] != null && component.get("v.redDetMap")['AddressLine2']!='undefined' && component.get("v.redDetMap")['AddressLine2'] != ' ' && component.get("v.redDetMap")['AddressLine2'] !=''){
                        concatAddr= component.get("v.redDetMap")['AddressLine1']+','+component.get("v.redDetMap")['AddressLine2'];
                    }else{
                        concatAddr= component.get("v.redDetMap")['AddressLine1']; 
                    }
                    
                    if(component.get("v.redDetMap")['State'] == '' || component.get("v.redDetMap")['State'] == undefined || component.get("v.redDetMap")['State'] == null){
                        finalAddr = concatAddr+','+component.get("v.redDetMap")['City']+','+component.get("v.redDetMap")['PostalCode']+','+component.get("v.redDetMap")['Country'];
                    }
                    else {
                        finalAddr = concatAddr+','+component.get("v.redDetMap")['City']+','+component.get("v.redDetMap")['State']+','+component.get("v.redDetMap")['PostalCode']+','+component.get("v.redDetMap")['Country'];
                    }
                    var reqAccVal = {
                        AccountName : component.get("v.redDetMap")['AccountName'],
                        BillingAddress : finalAddr,
                        Core_Account_Type__c : component.get("v.redDetMap")['BizOrgType'],
                        Core_IPA_Partner_Role__c : component.get("v.redDetMap")['PartnerRole'],
                        colorReqAcc : 'colorReqAcc',
                        DuplicateStatus : component.get("v.accountDupStatus")
                    };
                    
                    reqAccList.push(reqAccVal); 
                    
                    // For the CIM/SFDC matched Accounts list
                    if(resultAccList !=null && resultAccList!=''){
                        for(var i=0; i<resultAccList.length; i++){
                            var addrBillingStreet = '';
                            var addrBillingCity = '';
                            var addrBillingState = '';
                            var addrBillingPostalCode = '';
                            var addrBillingCountry = '';
                            var finalAddress = '';
                            if(resultAccList[i].BillingStreet != undefined && resultAccList[i].BillingStreet != null){
                                addrBillingStreet = resultAccList[i].BillingStreet;
                            }
                            
                            if(resultAccList[i].BillingCity != undefined && resultAccList[i].BillingCity != null){
                                addrBillingCity = resultAccList[i].BillingCity;
                            }
                            
                            if(resultAccList[i].BillingState != undefined && resultAccList[i].BillingState != null){
                                addrBillingState = resultAccList[i].BillingState;
                            }
                            
                            if(resultAccList[i].BillingPostalCode != undefined && resultAccList[i].BillingPostalCode != null){
                                addrBillingPostalCode = resultAccList[i].BillingPostalCode;
                            }
                            
                            if(resultAccList[i].BillingCountry != undefined && resultAccList[i].BillingCountry != null){
                                addrBillingCountry = resultAccList[i].BillingCountry;
                            }
                           
                            
                            if(addrBillingStreet != ''){
                                finalAddress += addrBillingStreet;
                            }
                            
                            if(addrBillingCity != ''){
                                if(finalAddress.length > 0){
                                finalAddress += ','+addrBillingCity;
                                }
                                else {
                                    finalAddress += addrBillingCity;
                                }
                            }
                            
                            if(addrBillingState != ''){
                                if(finalAddress.length > 0){
                                finalAddress += ','+addrBillingState;
                                }
                                else{
                                    finalAddress += addrBillingState;
                                }
                            }
                            
                            if(addrBillingPostalCode != ''){
                                if(finalAddress.length > 0){
                                finalAddress += ','+addrBillingPostalCode;
                                }
                                else{
                                    finalAddress += addrBillingPostalCode;
                                }
                            }
                            
                            if(addrBillingCountry != ''){
                                if(finalAddress.length > 0){
                                finalAddress += ','+addrBillingCountry;
                                }
                                else{
                                    finalAddress += addrBillingCountry;
                                }
                            }
                            
                            
                            
                            console.log('Final Address'+finalAddress);
                            var name = $A.get("$Label.c.PRM_AccountName");
                            console.log('resultAccList[i] -- > '+JSON.stringify(resultAccList[i]));
                            component.set("v.accountColumns", [
                                {label:"Reuse",type:"text",initialWidth:75,cellAttributes: { alignment: 'left' }},
                                {label:"Name",fieldName:"AccountName",type:"url",initialWidth: 150,cellAttributes: { alignment: 'left' },typeAttributes: {label: { fieldName: name },tooltip: { fieldName: 'Name'},target :"_blank"}},
                                {label:"Primary Address",fieldName:"BillingAddress",type:"text",initialWidth: 150},
                                {label:"Unified Heirarchy",fieldName:"Unified_Hierarchy_View__c",type:"text",initialWidth: 150},
                                {label:"Unified Id",fieldName:"Core_Business_Party_Id__c",type:"text",initialWidth: 150},
                                //{label:"Unified Customer Type",fieldName:"Core_Customer_Aggregation_Type__c",type:"text",initialWidth: 150},
                                {label:"Associated Unified Global",fieldName:"parentName",type:"url",initialWidth: 150,cellAttributes: { alignment: 'left' },typeAttributes: {label: { fieldName: 'Core_Unified_Global_Customer_Name__c' },target :"_blank"}},
                                {label:"IPA Account",fieldName:"Core_Intel_Partner_Alliance_PartnerGroup__c",type:"boolean",initialWidth: 150},
                                {label:"Biz OrgType",fieldName:"Core_Account_Type__c",type:"text"},
                                {label:"Partner Role",fieldName:"Core_IPA_Partner_Role__c",type:"text"},
                                // {label:"Duplicate Account Status",fieldName:"DuplicateStatus",type:"text"}
                            ]);
                            if(resultAccList[i] !=null){
                                resultAccList[i]['AccountName'] ='/lightning/r/Account/' + resultAccList[i].accId +'/view';
                                resultAccList[i][name] =  resultAccList[i].accName;
                                resultAccList[i]['Id'] =  resultAccList[i].accId;
                                resultAccList[i]['BillingAddress'] = resultAccList[i].address;
                                resultAccList[i]['Core_Intel_Partner_Alliance_PartnerGroup__c'] = resultAccList[i].ipaAccount;
                                resultAccList[i]['Core_Account_Type__c'] = resultAccList[i].bizOrgType;
                                resultAccList[i]['Core_IPA_Partner_Role__c'] = resultAccList[i].partnerRole;
                                resultAccList[i]['Core_Business_Party_Id__c'] = resultAccList[i].unifiedId;
                                resultAccList[i]['Unified_Hierarchy_View__c'] = resultAccList[i].unifiedHierarchy;
                                resultAccList[i]['Core_Account_Record_Type__c'] = resultAccList[i].Core_Account_Record_Type__c;
                                //resultAccList[i]['Core_Customer_Aggregation_Type__c'] = resultAccList[i].unifiedAggrCd;
                                resultAccList[i]['parentName'] = resultAccList[i].parentAccUrl;
                                resultAccList[i]['Core_Unified_Global_Customer_Name__c'] =  resultAccList[i].parentAccName;
                                
                                //resultAccList[i]['DuplicateStatus'] = component.get("v.accountDupStatus");
                                console.log('accountMap in line 229'+accountMap);
                                //console.log('Account Map in line 230'+accountMap[resultAccList[i].Id]);
                                if(accountMap!=null && accountMap!=undefined){
                                
                                resultAccList[i]['DuplicateStatus'] = accountMap[resultAccList[i].Id]; //Added as part of TWC729-3218 
                                }
                                accList.push(resultAccList[i]); 
                            }
                        }
                       
                       
                    }
                    
                    // For populating duplicate contact
                    for(var j=0; j<resultContList.length; j++){
                        component.set("v.contactColumns", [
                            {label :"",initialWidth:75,fieldName:"none",type:"text"},
                            {label:"Name",fieldName:"ContactName",type:"url",cellAttributes: { alignment: 'left' },typeAttributes: {label: { fieldName: 'ContName' },tooltip: { fieldName: 'ContName'},target :"_blank"}},
                            {label:"Contact Email",fieldName:"ContactEmail",type:"text"}
                        ]);
                        
                        if(resultContList[j] !=null){
                            resultContList[j]['ContactName'] ='/lightning/r/Contact/' + resultContList[j].Id +'/view';
                            resultContList[j]['ContName'] =  resultContList[j].Name;
                            resultContList[j]['ContactEmail'] = resultContList[j].Email;
                            //resultContList[j]['none']=" ";
                            //colornone:'colornone';
                            cntList.push(resultContList[j]); 
                        }
                    }
                    console.log('reqAccList -->'+JSON.stringify(reqAccList));
                    console.log('accList -->'+JSON.stringify(accList));
                    console.log('cntList -->'+JSON.stringify(cntList));
                    
                    component.set("v.AccountList",accList);
                    component.set("v.ReqAccList",reqAccList);
                    component.set("v.ContactList",cntList);
                    
                                        
                    // Logic for displaying the total number of pages in Account List
                    
                    if(accList.length > 0){
                        component.set("v.totalPages", Math.ceil(accList.length/component.get("v.pageSize")));
                        component.set("v.allData",component.get("v.AccountList")); 
                        component.set("v.currentPageNumber", 1);
                        helper.buildData(component, helper,event);
                        //set values for selected row when returning from 3rd screen to 2nd screen
                        var returnmap = component.get("v.redDetMap") ;
                        console.log('Apex Results====>'+returnmap);
                        console.log('Apex Results Stringified====>'+returnmap);
                        returnmap.SelectedRow = JSON.parse(component.get("v.redDetMap").SelectedRow)
                        console.log('Test Parsing======>'+returnmap.SelectedRow.length);
                        if(returnmap.SelectedRow != null && returnmap.SelectedRow.length>0) { 
                            var list= returnmap.SelectedRow;
                            console.log('list-->',list);
                            var selected = [];
                            list.forEach(function(file) {
                                console.log('file==>',file);    
                                selected.push(file.Id);
                            });
                            
                            //clear account selections if contact is a duplicate                    
                            if(component.get("v.contDupStatus") == "Duplicate"){
                               // alert('Clear radio buttons');
                                component.set("v.selectedList",[]);
                                var dTable = component.find('accsFoundTable');
                                dTable.set("v.selectedRows","");
                                component.set("v.selectedRowsList",[]);
                                component.set("v.clearSelections",false);
                            }
                            else {
                                component.set("v.selectedRowsList",returnmap.SelectedRow) ;
                                component.set("v.selectedList",selected);
                                var dTable = component.find('accsFoundTable');
                                console.log('set value in table'+component.get("v.selectedList")+'  '+dTable);
                                console.log('setting id in table',selected);
                                dTable.set("v.selectedRows",selected);
                                if(selected != "" && selected != null && selected != undefined){
                                    component.set("v.clearSelections",true);
                                    // $A.util.removeClass(component.find("clearButton"), "slds-align_absolute-center");
                                }
                            }

                        }
                        
                    }
                    

                    //Clear selections when Apex Callout required
                    //alert(JSON.stringify(component.get("v.redDetMap")['DuplicateInfo']));
                    if(component.get("v.redDetMap")['DuplicateInfo'].length == 0)
                    {
                        helper.clearResults(component,event,helper);  
                    }
                    
                    console.log('accountAssociatedToExistingContact'+JSON.stringify(accountAssociatedToExistingContact));
                    console.log('@@ result.accountExactMatch'+result.accountExactMatch);
                    var selectedRowMap = {
                        DuplicateRecords :  resultAccList,
                        AccountDuplicateStatus : component.get("v.accountDupStatus"),
                        ContactDuplicateStatus : component.get("v.contDupStatus"),
                        SelectedRow :  component.get("v.selectedRowsList"),
                        accountAssociatedToExistingContact : accountAssociatedToExistingContact,
                        duplicateContactRecord : duplicateContactRecord,
                        associatedAccountIsIPA : result.associatedAccountIsIPA,
                        accountExactMatch : result.accountExactMatch
                    }
                    component.set("v.selectedRowMap",selectedRowMap);
                    console.log('Map to return==>',JSON.stringify(selectedRowMap));
                    
                    // Hiding the spinner and displaying the progress bar
                    if(reqAccList.length > 0){
                        var spinner = component.find("mySpinner");
                        $A.util.toggleClass(spinner, "slds-hide");
                        var myEvent = component.getEvent("myComponentEvent");
                        myEvent.setParams({"Loading" : "true","FinalMap" : component.get("v.selectedRowMap")});
                        myEvent.fire();
                        component.set("v.displayDuplicates",true);
                    }
                    
                    //Display Toast Messages
                    if(component.get("v.selectedRowMap") != null && component.get("v.selectedRowMap") != undefined){
                        if(result.associatedAccountIsIPA && component.get("v.showBlockedContact")==false){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                message: "Click Next to add the Contact to Account's IPA Membership"
                            });
                            toastEvent.fire();
                        }
                        else
                        {
                            if((component.get("v.selectedRowMap").AccountDuplicateStatus == "NoDup" &&
                                component.get("v.selectedRowMap").ContactDuplicateStatus == "Duplicate")
                               || (component.get("v.selectedRowMap").AccountDuplicateStatus == "PartDup" &&
                                   component.get("v.selectedRowMap").ContactDuplicateStatus == "Duplicate")){
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    message: "Click Next to enroll the Contact's Account"
                                });
                                toastEvent.fire();
                                
                            }
                            else if(component.get("v.selectedRowMap").AccountDuplicateStatus == "FullDup" &&
                                    component.get("v.selectedRowMap").ContactDuplicateStatus == "Duplicate"){
                                
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    message: "Contact's Account is already part of IPA"
                                });
                                toastEvent.fire();
                                
                            }
                        }
                    }
                    
                    if(component.get("v.selectedRowMap") != null && component.get("v.selectedRowMap") != undefined
                       && component.get("v.selectedRowMap").ContactDuplicateStatus == "Duplicate")
                    {
                        //alert('Disable Radio buttons');
                        component.set("v.disableRadioButton",true);
                    }
                    
                    //keep the row selected in case of FullDup Account and NoDup Contact Scenario
                    if(component.get("v.selectedRowMap") != null && component.get("v.selectedRowMap") != undefined
                       && component.get("v.selectedRowMap").AccountDuplicateStatus =="FullDup" &&
                       component.get("v.selectedRowMap").ContactDuplicateStatus == "NoDuplicate")
                    {
                        if(component.get("v.selectedRowsList")!= null && component.get("v.selectedRowsList").length != 0 && 
                           component.get("v.selectedList") != null &&component.get("v.selectedList").length != 0){
                            
                            helper.selectedRow(component,event,helper);
                        }
                    }
                }
                else if (state === "ERROR") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "An error occurred. Please Try again later.",
                        "type": "error",
                        "mode":"sticky"                   
                    });
                    toastEvent.fire();
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                    setTimeout(function() {
                        window.location.href = "/lightning/n/PRM_Admin_Registration";
                    }, 15000);
                    //window.location.href = "/lightning/n/PRM_Admin_Registration"; 
                }
                
            });

            
            $A.enqueueAction(action);
        }
    },
    
    //get selected Rows
    selectedRow : function(component,event,helper) {
        //alert('SELECTED ROW');
        
        //fire event for hiding next button
        var mapValue = component.get("v.selectedRowMap");
        //if(mapValue != null && mapValue != undefined && mapValue.AccountDuplicateStatus== "FullDup"
          // && mapValue.ContactDuplicateStatus == "NoDuplicate"){
          if(mapValue != null && mapValue != undefined && mapValue.AccountDuplicateStatus== "FullDup"
          && mapValue.accountExactMatch == true){
            var myEvent2 = component.getEvent("displayButtonEvent");
            myEvent2.setParams({"Button" : "show"});
            myEvent2.fire();
        }
        
        //alert("Helper Select Rows");
        component.set("v.clearSelections",true);
        //$A.util.removeClass(component.find("clearButton"), "slds-align_absolute-center");
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows -->' +JSON.stringify(selectedRows));
        if (typeof selectedRows != 'undefined' && selectedRows !=' ' && selectedRows.length >0) {
            component.set("v.selectedRowsList",selectedRows);
            component.set("v.selectedList",selectedRows[0].Id);
            
            //Inactive Account - Validation----Cannot Reuse Inactive Account
            if(selectedRows[0].Core_Account_Record_Type__c=="Inactive Account"){
                var myEvent3 = component.getEvent("displayButtonEvent");
                myEvent3.setParams({"Button" : "hide"});
                myEvent3.fire();
                var msg1 = 'Cannot Re use an Inactive Account';
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    message: msg1,
                    
                });
                toastEvent.fire();          
            } 
            if(selectedRows[0].blockedAccount){
                var myEvent3 = component.getEvent("displayButtonEvent");
                myEvent3.setParams({"Button" : "hide"});
                myEvent3.fire();
                var msg1 = 'The Account is blocked for IPA registration';
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    
                    message: msg1,
                    
                });
                toastEvent.fire();          
            } 
        }
    },
    
    clearResults : function(component,event,helper){
        //fire event for showing hide button
        var mapValue = component.get("v.selectedRowMap");
       // if(mapValue != null && mapValue != undefined && mapValue.AccountDuplicateStatus== "FullDup"
           //&& mapValue.ContactDuplicateStatus == "NoDuplicate"){
            if(mapValue != null && mapValue != undefined && mapValue.AccountDuplicateStatus== "FullDup"
           && mapValue.accountExactMatch == true){
            var myEvent2 = component.getEvent("displayButtonEvent");
            myEvent2.setParams({"Button" : "hide"});
            myEvent2.fire();
        }
        
        var dTable = component.find('accsFoundTable');
        component.set("v.selectedRowsList",[]);
        dTable.set("v.selectedRows","");
        component.set("v.clearSelections",false);
        
    },
    
    
    // Pagination logic
    buildData : function(component, helper,event) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        //alert('Before Setting Account List');
        component.set("v.AccountList", data);      
        //alert('Before generating Page List');
        
        helper.generatePageList(component, pageNumber);
    },
    
    // Displaying the page numbers
    
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var totalPages = component.get("v.totalPages");
        console.log("totalPages "+totalPages);
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
})