({
    fetchAccount : function(component,event,helper) {
        var action = component.get("c.showAccounts");
        
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(data) {
            var state= data.getState();
            console.log('STATE -->'+state);
            if(component.isValid() && state === "SUCCESS") {
                var contactId;
                var salesforceAccountName;
                var result = data.getReturnValue();
                console.log('result'+JSON.stringify(result));
                var resultMap = result.accountMap;
                var accountCon = result.accountContactEmail;
                var regAccName = result.accList;
                var sfdcAccId = result.salesforceAccountId;
				var existingAccountCon = result.existingAccountContactEmail;
                var existingAccInfo = result.existingAccInfo;
                //console.log(JSON.stringify(result.metaData[0]))
                //component.set("v.mName",JSON.stringify(result.metaData[0]));
                var dupStatus;
                console.log('regAccName'+JSON.stringify(regAccName));
                //console.log('regAccName.PRM_Salesforce_ID__c'+regAccName.PRM_Salesforce_ID__c);
                component.set("v.newRegId",regAccName.Id);
                //console.log('accountCon'+result.accountMap.size);
                var finalList= [];
                var regList= [];
                if (regAccName != null){
                    contactId = regAccName.PRM_Matching_Contact__c; 
                    dupStatus=regAccName.PRM_Dup_Status__c;
                    salesforceAccountName = regAccName.PRM_Salesforce_ID__c;
                }
                
                console.log('salesforceAccountName'+salesforceAccountName);
                if(sfdcAccId != null && sfdcAccId != ''){
					var e = existingAccountCon.split(';');
					var existingAccountName = e[0];
                    var newContactEmail = e[1];
					if(existingAccountName != null && existingAccountName != '' && newContactEmail != null &&
                       newContactEmail != ''){
                        component.set('v.showToastMessage',true);
                        var msg = 'The user '+newContactEmail+' has requested to be associated with an existing Account '+existingAccountName;
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: msg,
                            mode: 'sticky'
                        });
                        toastEvent.fire();
                    }
				}
                console.log('resultMap'+JSON.stringify(resultMap.length));
                console.log('before');
                //component.set("v.displayDuplicateAccounts",true);
                console.log('displayDuplicateAccounts ki value'+component.get("v.displayDuplicateAccounts"))
                console.log('accountShow ki value'+component.get("v.accountShow"));
                console.log('v.totalPages ki value'+component.get("v.totalPages"));
                console.log('searchAccount ki value'+component.get("v.searchAccount"));
                console.log('accountCon'+accountCon);
                if(accountCon != null && accountCon != ''){
                    //console.log('sab hide karo');
                    console.log('accountCon '+accountCon);
                    var e = accountCon.split(';');
                    console.log(e);
                    var accountName = e[1];
                    var contactEmail = e[0];
                    console.log('accountName'+accountName);
                    console.log('contactEmail'+contactEmail);
                    if(accountName != null && accountName != '' && contactEmail != null &&
                       contactEmail != ''){
                        component.set('v.showToastMessage',true);
                        var msg = 'The user '+contactEmail+' is already associated with '+accountName+'.\n';
                        msg += 'Approve the Request to approve IPA program request for '+accountName+'.';
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            message: msg,
                            mode: 'sticky'
                        });
                        toastEvent.fire();
                    }
                }
                else {
                    //console.log('sab show karo');
                    component.set("v.accountShow",true);
                    
                    /* var name = $A.get("$Label.c.PRM_AccountName");
                    var cimName = $A.get("$Label.c.PRM_CIMResultName");
                    component.set("v.accountColumns", [
                        {label:"Name",fieldName:"AccountName",type:"url",cellAttributes: { alignment: 'left' },typeAttributes: {label: { fieldName: name },tooltip: { fieldName: 'Name'},target :"_blank"}},
                        {label:"Primary Address",fieldName:"BillingAddress",type:"text"},
                        {label:"IPA Account",fieldName:"Core_Intel_Partner_Alliance_PartnerGroup__c",type:"boolean"},
                        {label:"Biz OrgType",fieldName:"Core_Account_Type__c",type:"text",cellAttributes: { alignment: 'left' }},
                        {label:"Partner Role",fieldName:"Core_IPA_Partner_Role__c",type:"text",cellAttributes: { alignment: 'left' }},
                        {label:"CIM Details", fieldName:"Record",type:"url",typeAttributes: {label: { fieldName: cimName },tooltip: { fieldName: 'Names'},target :"_blank"}}
                    ]);*/
                    for(var p in resultMap){
                        
                        var billingStreet = '';
                        var billingCity = '';
                        var billingState ='';
                        var billingPostalCode = '';
                        var billingCountry = '';
						var address = '';
                        var CIM = JSON.parse(p);  //parsed Object(for Keys)
                        console.log('CIM'+JSON.stringify(CIM));
                        var Values =[resultMap[p],CIM];
                        //for account record+keys
                        var name = $A.get("$Label.c.PRM_AccountName");
                        var cimName = $A.get("$Label.c.PRM_CIMResultName");
                        component.set("v.accountColumns", [
                            {label:"Name",fieldName:"AccountName",type:"url",initialWidth: 50,cellAttributes: { alignment: 'left' },typeAttributes: {label: { fieldName: name },tooltip: { fieldName: 'Name'},target :"_blank"}},
                            {label:"Primary Address",fieldName:"BillingAddress",type:"text"},
                            {label:"IPA Account",fieldName:"Core_Intel_Partner_Alliance_PartnerGroup__c",type:"boolean",initialWidth: 30},
                            {label:"Biz OrgType",fieldName:"Core_Account_Type__c",type:"text"},
                            {label:"Partner Role",fieldName:"Core_IPA_Partner_Role__c",type:"text"},
                            {label:"CIM Details", fieldName:"Record",type:"url",typeAttributes: {label: { fieldName: cimName },tooltip: { fieldName: 'Names'},target :"_blank"}},
                            {label:"CIM Search Score",fieldName:"CIMSearchScore",type:"number"},
                            {label:"Account Owner",fieldName:"OwnerName",type:"text"}
                        ]);
                        if(Values[1] !=null){
                            if(Values[0].BillingStreet != undefined && Values[0].BillingStreet != null){
                                billingStreet = Values[0].BillingStreet;
                            }
                            if(Values[0].BillingCity != undefined && Values[0].BillingCity != null){
                                billingCity = Values[0].BillingCity;
                            }
                            if(Values[0].BillingState != undefined && Values[0].BillingState != null){
                                billingState = Values[0].BillingState;
                            }
                            if(Values[0].BillingPostalCode != undefined && Values[0].BillingPostalCode != null){
                                billingPostalCode = Values[0].BillingPostalCode;
                            }
                            if(Values[0].BillingCountry != undefined && Values[0].BillingCountry != null){
                                billingCountry = Values[0].BillingCountry;
                            }

                            if(billingStreet != ''){
                                address += billingStreet;
                            }
                            
                            if(billingCity != ''){
                                if(address.length > 0){
                                    address += ','+billingCity;
                                }
                                else {
                                    address += billingCity;
                                }
                            }
                            
                            if(billingState != ''){
                                if(address.length > 0){
                                    address += ','+billingState;
                                }
                                else{
                                    address += billingState;
                                }
                            }
                            
                            if(billingPostalCode != ''){
                                if(address.length > 0){
                                    address += ','+billingPostalCode;
                                }
                                else{
                                    address += billingPostalCode;
                                }
                            }
                            
                            if(billingCountry != ''){
                                if(address.length > 0){
                                    address += ','+billingCountry;
                                }
                                else{
                                    address += billingCountry;
                                }
                            }

                            
                            Values[cimName] = Values[1].Name;
                            Values['Record'] = '/lightning/r/PRM_CIMSearchResults__c/' + Values[1].Id +'/view';
                            Values['AccountName'] ='/lightning/r/Account/' + Values[0].Id +'/view';
                            Values[name] =  Values[0].Name;
                            //Values['BillingAddress'] = Values[0].BillingStreet+','+Values[0].BillingCity+','+Values[0].BillingState+','+Values[0].BillingPostalCode+','+Values[0].BillingCountry;
                            Values['BillingAddress'] = address;
                            Values['Core_Intel_Partner_Alliance_PartnerGroup__c'] = Values[0].Core_Intel_Partner_Alliance_PartnerGroup__c;
                            Values['Core_Account_Type__c'] = Values[0].Core_Account_Type__c;
                            Values['Core_IPA_Partner_Role__c'] = Values[0].Core_IPA_Partner_Role__c;
                            console.log('Values[1]'+Values[1].PRM_SearchScore_Nbr__c);
                            Values['CIMSearchScore'] = Values[1].PRM_SearchScore_Nbr__c;
                            console.log('Values[CIMSearchScore]'+Values['CIMSearchScore']);
                            Values['OwnerName']=Values[0].Owner.Name;
                            //Values['Id'] = Values[0].Id;
                            
                            finalList.push(Values); 
                        }
                        else{
                            console.log('ELSE');
                            
                            var regBillingStreet = '';
                            var regBillingCity = '';
                            var regBillingState ='';
                            var regBillingPostalCode = '';
                            var regBillingCountry = '';
                            var regAddress = '';
                            if(sfdcAccId != null && sfdcAccId != ''){
                                if(existingAccInfo.BillingStreet != undefined && existingAccInfo.BillingStreet != null){
                                regBillingStreet= existingAccInfo.BillingStreet;
                                }
                                if(existingAccInfo.BillingCity != undefined && existingAccInfo.BillingCity != null){
                                    regBillingCity= existingAccInfo.BillingCity;
                                }
                                if(existingAccInfo.BillingState != undefined && existingAccInfo.BillingState != null){
                                    regBillingState= existingAccInfo.BillingState;
                                }
                                if(existingAccInfo.BillingPostalCode != undefined && existingAccInfo.BillingPostalCode != null){
                                    regBillingPostalCode= existingAccInfo.BillingPostalCode;
                                }
                                if(existingAccInfo.BillingCountry != undefined && existingAccInfo.BillingCountry != null){
                                    regBillingCountry= existingAccInfo.BillingCountry;
                                }
                            }
                            else{
                                if(regAccName.PRM_Address_Line_1__c != undefined && regAccName.PRM_Address_Line_1__c != null){
                                    regBillingStreet = regAccName.PRM_Address_Line_1__c;
                                }
                                if(regAccName.PRM_City__c != undefined && regAccName.PRM_City__c != null){
                                    regBillingCity = regAccName.PRM_City__c;
                                }
                                if(regAccName.PRM_State_Province__c != undefined && regAccName.PRM_State_Province__c != null){
                                    regBillingState = regAccName.PRM_State_Province__c;
                                }
                                if(regAccName.PRM_Zip_Postal_Code__c != undefined && regAccName.PRM_Zip_Postal_Code__c != null){
                                    regBillingPostalCode = regAccName.PRM_Zip_Postal_Code__c;
                                }
                                if(regAccName.PRM_Country__c != undefined && regAccName.PRM_Country__c != null){
                                    regBillingCountry = regAccName.PRM_Country__c;
                                }
                            }
                            
                            if(regBillingStreet != ''){
                                regAddress += regBillingStreet;
                            }
                            
                            if(regBillingCity != ''){
                                if(regAddress.length > 0){
                                    regAddress += ','+regBillingCity;
                                }
                                else {
                                    regAddress += regBillingCity;
                                }
                            }
                            
                            if(regBillingState != ''){
                                if(regAddress.length > 0){
                                    regAddress += ','+regBillingState;
                                }
                                else{
                                    regAddress += regBillingState;
                                }
                            }
                            
                            if(regBillingPostalCode != ''){
                                if(regAddress.length > 0){
                                    regAddress += ','+regBillingPostalCode;
                                }
                                else{
                                    regAddress += regBillingPostalCode;
                                }
                            }
                            
                            if(regBillingCountry != ''){
                                if(regAddress.length > 0){
                                    regAddress += ','+regBillingCountry;
                                }
                                else{
                                    regAddress += regBillingCountry;
                                }
                            }
							if(sfdcAccId != null && sfdcAccId != ''){
                                component.set("v.regAccName",regAccName.PRM_Account_Name__c);
                                Values['AccountName']='/lightning/r/PRM_Registration_Request__c/' + regAccName.Id +'/view';;
                                Values[name] =  existingAccInfo.Name;
                                Values['BillingAddress'] = regAddress;
                                Values['Core_Account_Type__c'] = existingAccInfo.Core_Account_Type__c;
                                Values['Core_IPA_Partner_Role__c'] = existingAccInfo.Core_IPA_Partner_Role__c;
                                Values['OwnerName'] = existingAccInfo.Owner.Name;
                                Values['Core_Intel_Partner_Alliance_PartnerGroup__c']=existingAccInfo.Core_Intel_Partner_Alliance_PartnerGroup__c;
                            }
                            else{
                                component.set("v.regAccName",regAccName.PRM_Account_Name__c);
                                Values['AccountName']='/lightning/r/PRM_Registration_Request__c/' + regAccName.Id +'/view';;
                                Values[name] =  regAccName.PRM_Account_Name__c;
                                //Values['BillingAddress'] = regAccName.PRM_Address_Line_1__c+','+regAccName.PRM_City__c+','+regAccName.PRM_State_Province__c+','+regAccName.PRM_Zip_Postal_Code__c+','+regAccName.PRM_Country__c;
                                Values['BillingAddress'] = regAddress;
                                Values['Core_Account_Type__c'] = regAccName.PRM_Partner_Type__c;
                                Values['Core_IPA_Partner_Role__c'] = regAccName.PRM_Partner_Role__c;   
                            }
                            regList.push(Values); 
                        }
                    }
                    console.log('contactId'+contactId);
                    console.log('dupStatus'+dupStatus);
                    
                    console.log('finalList Length'+finalList.length);
                    component.set("v.AccountList",finalList);
                    component.set("v.RegList",regList);
                    var listData = component.get("v.AccountList");
                    component.set("v.totalPages", Math.ceil(listData.length/component.get("v.pageSize")));
                    component.set("v.allData",component.get("v.AccountList"));
                    console.log("List Size --> "+ listData.length);
                    //if (listData.length == 0 ){
                    //}
                    
                    
                    //	Existing User/Existing Account -- PARTDUP/FULLDUP
                   // if((contactId != null) && ((dupStatus == $A.get("$Label.c.PRM_Fulldup")) || (dupStatus == $A.get("$Label.c.PRM_Partdup")))){
                     //   component.set("v.hideRadioButtons",true);
                      //  component.set("v.searchAccount",false);
                    //}
                    	// New User/Existing Account -- FULLDUP
                    if((contactId == null) && ((dupStatus == $A.get("$Label.c.PRM_Fulldup")) || (dupStatus== $A.get("$Label.c.PRM_Error"))) &&
                       (salesforceAccountName == undefined || salesforceAccountName == null)){
                      component.set("v.hideApprove",true);
                    }
                    
                    // Existing Contact
                    if(contactId != null){    
                    component.set("v.hideRadioButtons",true);
                    component.set("v.searchAccount",false);
                    component.set("v.searchAccountNoDupForExistingContact",false);
                    }
                    
                   // if(component.get("v.hideRadioButtons") == false){
                     //   var element=component.find("reg");
                        
                        //$A.util.removeClass(element, 'slds-show');
                       // $A.util.addClass(element, 'slds-grid_align-spread');  
                    //}
                    
                    
                    
                    //if (listData.length == 0 ){
                    // component.set("v.accountShow",false);                  
                    // }
                    
                    //Added by Rahul for US516435
                    //positioning account search text box when radio buttons are hidden
                    //if(component.get("v.hideRadioButtons") == true){
                      //  var field = component.find("inputs");
                        //console.log('field'+field);
                        //$A.util.removeClass(field,'slds-p-left_x-large');
                    //}
                    
                    helper.buildData(component, helper,event);
                } // else part ends
                
                console.log('after');
                console.log('displayDuplicateAccounts ki value'+component.get("v.displayDuplicateAccounts"))
                console.log('accountShow ki value'+component.get("v.accountShow"));
                console.log('v.totalPages ki value'+component.get("v.totalPages"));
                console.log('searchAccount ki value'+component.get("v.searchAccount"));
                
                
            }
        });
        
        $A.enqueueAction(action);
        
    },
    
    selectedRow : function(component,event,helper){
        var selectedRows = event.getParam('selectedRows');
        console.log('REGNAME -->' +component.get("v.regAccName"));
        
        if (typeof selectedRows != 'undefined' && selectedRows !=' ' && selectedRows.length >0) {
            component.set("v.selectedList",null);
            component.set("v.selectedRowsList",selectedRows);
            console.log('selectedRows -->' + JSON.stringify(selectedRows[0]));
            component.set("v.selectedList",selectedRows[0].Names);
            component.set("v.showReuse",true);
        }
    },
    
    click : function(component,event,helper,button){
        var accountList;
        var regReqId = component.get("v.newRegId");
        
        //invoked by selecting radio button
        if(button == ''){
            var selectedResult =  component.get("v.selectedRowsList");
            console.log('SELECTED RESULT'+JSON.stringify(selectedResult));
            selectedResult.forEach(function(items){
                accountList = items[0];
                //regReqId = items[1].PRM_RegReq_Id__c;
                //console.log('RR ID '+regReqId);
            });
        }
        else {
            accountList = component.get("v.accRecord");
        }
        console.log('RR ID '+regReqId);
        console.log('ACCOUNT LIST'+JSON.stringify(accountList));
        var action = component.get("c.insertRecords");
        
        action.setParams({
            regRequestId : regReqId,
            accountResult : accountList,
            recordId : component.get("v.recordId")
        });
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS") {
                var result = data.getReturnValue();
                console.log('Step Id'+JSON.stringify(result));
                if(result != null && result != ''){
                    var eUrl= $A.get("e.force:navigateToURL");
                    eUrl.setParams({
                        "url": '/lightning/r/ProcessInstanceStep/'+result+'/view' 
                    });
                    eUrl.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    buildData : function(component, helper,event) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = (pageNumber-1)*pageSize;
        //component.set("v.selectedList",null);
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.AccountList", data);      
        
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
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
    
    reuseAccount : function(component,event,helper){
        var accntId = component.find("accountInput").get("v.value");
        console.log('Id '+accntId);
        component.set("v.accId",accntId);
        
        var action = component.get("c.searchAccount");
        console.log('action'+JSON.stringify(action));
        
        action.setParams({
            accntId : accntId
        });
        console.log('action'+JSON.stringify(action));
        
        action.setCallback(this,function(data) {
            var state= data.getState();
            console.log('STATE -->'+state);
            if(component.isValid() && state === "SUCCESS") {
                var result = data.getReturnValue();
                console.log('result'+JSON.stringify(result));
                if(result.errorMsg != ''){
                    component.set("v.ErrorMessage",result.errorMsg);
                }
                
                if(result.accountList != null){
                    component.set("v.displayDuplicateAccounts",false);
                    component.set("v.confirmationDuplicateScreen",true);
                    component.set("v.accRecord",result.accountList);
                    if(result.accountList.Name != undefined){
                        component.set("v.accName",result.accountList.Name);
                    }
                    if(result.accountList.BillingCountry != undefined){
                        component.set("v.accCountry",result.accountList.BillingCountry);
                    }
                    if(result.accountList.Owner.Name != undefined){
                        component.set("v.accOwner",result.accountList.Owner.Name);
                    }
                    if(result.accountList.Core_CIM_ID__c != undefined){
                        component.set("v.accCim",result.accountList.Core_CIM_ID__c);
                    }
                }
                
                var accountListData = {
                    Name :component.get("v.accName"),
                    Core_CIM_ID__c : component.get("v.accCim"),
                    BillingCountry :component.get("v.accCountry"),
                    Owner : component.get("v.accOwner")
                }
                console.log('accountListData'+JSON.stringify(accountListData));
                component.set("v.accountTableColumns",[
                    {label:"Account Name",fieldName:"Name",type:"text"},
                    {label:"Account CIM",fieldName:"Core_CIM_ID__c",type:"text"},
                    {label:"Account Country",fieldName:"BillingCountry",type:"text"},
                    {label:"Account Owner",fieldName:"Owner",type:"text"}
                ]);
                component.set("v.accountTableData",accountListData);
            }
        });
        $A.enqueueAction(action);
        
    }
    
})