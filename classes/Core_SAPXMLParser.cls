public with sharing class Core_SAPXMLParser {
    public static Core_SAPXMLUtility.JsonResponse insertXMLData(String messageXml){
        Core_SAPXMLUtility.JsonResponse attributes = new Core_SAPXMLUtility.JsonResponse();
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        Map<String, List<String>> shipToUnsuccessfulMap = new Map<String, List<String>>();
		Map<String, Core_SAPXMLUtility.AccountEaiAltera> allAccountMap = new Map<String, Core_SAPXMLUtility.AccountEaiAltera>();
         List<String> accountProcessedBeginList = new List<String>();
        try{
            List<Account> upsertAccountList = new List<Account>();
            List<Core_Account_SoldTo_ShipTo_Rel__c> soldToShipToList = new List<Core_Account_SoldTo_ShipTo_Rel__c>();
            //List<Core_Account_SoldTo_ShipTo_Rel__c> soldToShipToUpdateList = new List<Core_Account_SoldTo_ShipTo_Rel__c>();
            List<Id> existingShiptToUpdateExcludeList = new List<Id>();
            List<RecordType> recType =[SELECT Id, DeveloperName FROM Recordtype WHERE DeveloperName = 'Core_Direct_Account'];
            Core_SAPXMLUtility.ListOfAccountEaiAltera listOfAccounts = parseSAPXML(messageXml);
            Integer externalIDCounter = 0;
            String externalID = String.valueOf(Datetime.Now())+String.valueOf(externalIDCounter);
            
            //Get AccountIds to Validate SAP Ids        
            List<Id> extractedAccountIdList = new List<Id>();
            List<Id> accountIdToValidateList = new List<Id>();//Create records only if recordIds present in this list are valid
            
            List<Id> soldExpressStIdFromXMLList = new List<Id>();//holds (SoldTo)info from XML
            List<Id> shipToExpressStIdFromXMLList = new List<Id>();//holds (ShipTo)info from XML
            
            final Map<String, String> PARENT_ACCOUNT_TIER_MAP  = new  Map<String, String>{'CAT0'=>'CAT0/CAT1', 'CAT1'=>'CAT0/CAT1'};
            
           
            //List<String> accountProcessedEndList = new List<String>();
                
            //First scan to get all Ids for validation before upserting
            for(Core_SAPXMLUtility.AccountEaiAltera accountEA : listOfAccounts.listAccountEaiAltera){
                try{
                    allAccountMap.put(accountEA.sAPAccountNumber, accountEA);
                    if(!String.isEmpty(accountEA.expressStationId) && (accountEA.expressStationId instanceOf Id) ){
                        extractedAccountIdList.add(accountEA.expressStationId);
                        accountIdToValidateList.add(accountEA.expressStationId);
                        soldExpressStIdFromXMLList.add(accountEA.expressStationId);
                    }
                    
                    if(!String.isEmpty(accountEA.trainStationID) && (accountEA.trainStationID instanceOf Id)){
                        accountIdToValidateList.add(accountEA.trainStationID);
                    }
                    
                    //GCH1
                    if((accountEA.x_ALT_SAP_ACCT_TYPE=='Sold To') && accountEA.shipToPartList!=null){
                        for(Core_SAPXMLUtility.Shipto_Partner stPartner: accountEA.shipToPartList){
                            if(!String.isEmpty(stPartner.shiptoExpressStationID) && (stPartner.shiptoExpressStationID instanceOf Id)){
                                extractedAccountIdList.add(stPartner.shiptoExpressStationID); 
                                shipToExpressStIdFromXMLList.add(stPartner.shiptoExpressStationID);
                            }
                        }
                    }
                }
                catch(Exception ex){
                    attributes.results.add(returnJsonResult('Failed', accountEA.sAPAccountNumber,accountEA.expressStationId, accountEA.trainStationId, ex.getMessage()));
                    //logEntryList.add(returnLogEntryResult('', 'failed', 'Exception:-'+messageXml));
                    logEntryList.add(returnLogEntryResult(accountEA.sAPAccountNumber+' | '+accountEA.expressStationId, 'Failed', 'Status:Failed\nSourceType:SAP\nSAPAccountNumber:'+accountEA.sAPAccountNumber+'\nExpressStationId:'+accountEA.expressStationId+'\nTrainStationID:'+accountEA.trainStationId+'\nMessage:'+ex.getMessage()+'\n\nXML:'+messageXml));
                    PMP_Utility.logError(ex, 'Core_SAPXMLParser.insertXMLData');
 
                }
            }
            
			//ValidatedAccountList: Insert/Update is valid only to these Ids
            Map<Id, Account> accountIdValidateMap = new Map<Id, Account>([Select Id,Name, Core_Direct_Account_Id__c,Core_Account_Record_Type__c, (SELECT Id,Core_Is_Deactivated_Ind__c, Core_Sold_To_Account__c,Core_Ship_To_Account__c from Sold_To_Relationship__r) from Account where ID IN:accountIdToValidateList]);            
            
            //To Check if SAPAccountNumber already exist:Query Record using SAPAccountNumber
            List<Account> existingSAPAccountList = [select id, Core_Direct_Account_Id__c from Account where Core_Direct_Account_Id__c IN: allAccountMap.keySet()];
            Map<String, Account> existingSAPAccountMap = new Map<String, Account>();
            for(Account acc: existingSAPAccountList){
                existingSAPAccountMap.put(acc.Core_Direct_Account_Id__c, acc);
            }
            /////
            
            //logic to deactivate JunctionObjectRecords when their expressionStation(ie SFId) not found in shipToExpressStIdFromXMLList
            List<Id> junctionObjectIdToDeactivateList = new List<Id>();
            List<Core_Account_SoldTo_ShipTo_Rel__c> soldToShipDeactivationList = new List<Core_Account_SoldTo_ShipTo_Rel__c>();
            for(Id soldToId: soldExpressStIdFromXMLList){//deactivate for existing soldToExpressIds only
                if(accountIdValidateMap.containsKey(soldToId)){
                    for(Core_Account_SoldTo_ShipTo_Rel__c soldToShipToJun: accountIdValidateMap.get(soldToId).Sold_To_Relationship__r){
                        if(!shipToExpressStIdFromXMLList.contains(soldToShipToJun.Core_Ship_To_Account__c) && !soldToShipToJun.Core_Is_Deactivated_Ind__c){
                            Core_Account_SoldTo_ShipTo_Rel__c soldToShipDeactivation = new Core_Account_SoldTo_ShipTo_Rel__c();
                            soldToShipDeactivation.Id = soldToShipToJun.Id;
                            soldToShipDeactivation.Core_Is_Deactivated_Ind__c = True;
                            soldToShipDeactivationList.add(soldToShipDeactivation);
                            junctionObjectIdToDeactivateList.add(soldToShipToJun.Id);
                        }
                    }
                }
            }
            
			final String ENDCUSTOMERTYPE = 'End Customer Parent';
            Map<Id, Account> accountIdMap = new Map<Id, Account>([Select Id,Name, Core_Direct_Account_Id__c from Account where ID IN:extractedAccountIdList]);
            //Only Accounts of the type 'End Customer Parent' can be created without ParentId(TrainStationId)
            for(Core_SAPXMLUtility.AccountEaiAltera accountEA : listOfAccounts.listAccountEaiAltera){
                
                //To check if SAPAccountNumber already exist:
                Boolean accountDoesntExist = True;
                if(String.isEmpty(accountEA.expressStationId) && existingSAPAccountMap.containsKey(accountEA.sAPAccountNumber)){
                    accountDoesntExist = False;
                }
                ////
             
                if(accountDoesntExist && ((String.isEmpty(accountEA.trainStationId) && accountEA.x_ALT_SAP_ACCT_TYPE == ENDCUSTOMERTYPE) || (!String.isEmpty(accountEA.trainStationId) && accountIdValidateMap.containsKey(accountEA.trainStationId) && accountIdValidateMap.get(accountEA.trainStationId).Core_Account_Record_Type__c=='Intel Account')
                  ))
                {
                    accountProcessedBeginList.add(accountEA.sAPAccountNumber);
                    Boolean validated = True;
                    Account acct = new Account();
                    if(!String.isEmpty(accountEA.trainStationId)){
                        acct.ParentId = accountEA.trainStationId;    
                    }else{
                        acct.ParentId = null;
                    }
                    
                    acct.Name = accountEA.name;
                    acct.Core_Direct_Account_Id__c = accountEA.sAPAccountNumber;
                    acct.Core_Direct_Incoterm_Dsc__c = accountEA.freightTerms;
                    //acct.Core_CIM_ID__c = accountEA.type;
                    acct.Core_Direct_Payment_Term_Nm__c = accountEA.x_ALT_PAYTERMS;
                    acct.Core_Direct_Account_Type_Nm__c = accountEA.x_ALT_SAP_ACCT_TYPE;
                    acct.Core_Direct_Shipping_Condition_Nm__c = accountEA.shippingCondition;
                    acct.BillingStreet = accountEA.streetAddress+' '+accountEA.streetAddress2;
                    acct.BillingCity = accountEA.city;
                    acct.BillingState = accountEA.state;//accountEA.regionCode;//accountEA.province;
                    acct.BillingStateCode = accountEA.state;
                    //acct.BillingCountry = accountEA.country; //it's auto populated based on BillingCountryCode with same value
                    acct.BillingCountryCode = accountEA.country; //SAP send 3 char len ISO Code - Country Code
                    acct.BillingPostalCode = accountEA.postalCode;
                    //acct.Core_Geo__c = accountEA.regionCode;
                    acct.Core_Direct_Sales_Organization_Nm__c = accountEA.salesOrganization;
                    acct.Core_Nielsen_ID__c = accountEA.nielsenId;
                    acct.Core_Direct_Distributor_Channel_Nm__c = accountEA.distyChannel;
                    acct.Core_Direct_Ship_To_End_Customer_Id__c = accountEA.shipToEndCustomer;
                    acct.Core_Direct_Shipping_Instruction_Txt__c = accountEA.shippingInstructions;
                    acct.Core_Direct_Account_Name_Txt__c = accountEA.accountName2; 
                    if(PARENT_ACCOUNT_TIER_MAP.containsKey(accountEA.parentAccountTier)){//SAP sends CAT0/CAT1, CAT2, CAT3, CAT4 maps to PSG TIER-1 etc..
                        acct.Core_Direct_Parent_Account_Tier_Nm__c = PARENT_ACCOUNT_TIER_MAP.get(accountEA.parentAccountTier);    
                    }else{
                        acct.Core_Direct_Parent_Account_Tier_Nm__c = accountEA.parentAccountTier; //sets to null else error with bad picklist value
                    }
                    
                    
                    acct.RecordtypeId = recType[0].Id;
                    if(accountEA.x_ALT_SAP_ACCT_TYPE == ENDCUSTOMERTYPE){
                        acct.Core_Is_Pricing_Parent_ChkBox__c = True; //Boolean.valueOf(accountEA.IsPricingParent);    
                    }
                    acct.Core_Direct_Account_Active_Ind__c = True;
                    if(!String.isEmpty(accountEA.expressStationId)){
                        if(accountIdValidateMap.containsKey(accountEA.expressStationId)){
                            acct.Id = accountEA.expressStationId; 
                        }                        
                        else{
                            validated = False;
                            attributes.results.add(returnJsonResult('Failed', accountEA.sAPAccountNumber,accountEA.expressStationId, accountEA.trainStationId, accountEA.expressStationId +' is invalid' ));
                            //logEntryList.add(returnLogEntryResult(accountEA.expressStationId,'Failed',  accountEA.expressStationId +' is invalid' +messageXml));
                            logEntryList.add(returnLogEntryResult(accountEA.sAPAccountNumber+' | '+accountEA.expressStationId, 'Failed', 'Status:Failed\nSourceType:SAP\nSAPAccountNumber:'+accountEA.sAPAccountNumber+'\nExpressStationId:'+accountEA.expressStationId+'\nTrainStationID:'+accountEA.trainStationId+'\nMessage:'+accountEA.expressStationId +' is invalid'+'\n\nXML:'+messageXml));
                        }
                    }
                    
                    acct.External_Id__c = externalID;
                    if(validated){
                        upsertAccountList.add(acct);                        
                    }
                    Account accountReference = new Account(External_Id__c=externalID); 
                    
                    //Sold To Ship To Junctinon Object
                    //Core_Account_SoldTo_ShipTo_Rel__c soldToShipToJntn= new Core_Account_SoldTo_ShipTo_Rel__c();
                    //if(validated && (accountEA.x_ALT_SAP_ACCT_TYPE=='Sold To') && accountEA.shipToPart!=null && !String.isEmpty(accountEA.shipToPart.shiptoExpressStationID)){
                    //GCH2
                    if(validated && (accountEA.x_ALT_SAP_ACCT_TYPE=='Sold To') && accountEA.shipToPartList!=null){// Add ShipTo only to SoldTo type Account
                        for(Core_SAPXMLUtility.Shipto_Partner stPartner : accountEA.shipToPartList){
                            if(!String.isEmpty(stPartner.shiptoExpressStationID) && (stPartner.shiptoExpressStationID instanceOf Id) ){
                                if(accountIdMap.containsKey(stPartner.shiptoExpressStationID)){
                                    Account directAccountDtls = accountIdMap.get(stPartner.shiptoExpressStationID);
                                    //Set<Id> allShipToIdsAssociationList = new Set<Id>();
                                    Map<Id, Core_Account_SoldTo_ShipTo_Rel__c> allShipToIdsAssociationMap = new Map<Id, Core_Account_SoldTo_ShipTo_Rel__c>();
                                    if(directAccountDtls!=null && directAccountDtls.Core_Direct_Account_Id__c!=null 
                                       && directAccountDtls.Core_Direct_Account_Id__c == stPartner.shipto){//xml SAP(ShipTo) should match SF DirectAccId
                                           if(!String.isEmpty(accountEA.expressStationId) && accountIdValidateMap.containsKey(accountEA.expressStationId))//Get existing ShipTo Details for this soldTo account
                                           {
                                               for(Core_Account_SoldTo_ShipTo_Rel__c soldTo : accountIdValidateMap.get(accountEA.expressStationId).Sold_To_Relationship__r){
                                                   //allShipToIdsAssociationList.add(soldTo.Core_Ship_To_Account__c);
                                                   allShipToIdsAssociationMap.put(soldTo.Core_Ship_To_Account__c, soldTo);
                                               }
                                           }
                                           if(String.isEmpty(accountEA.expressStationId) || !allShipToIdsAssociationMap.containsKey(stPartner.shiptoExpressStationID) ){ // creating ShipTo Junction associating to SoldTo Account
                                               Core_Account_SoldTo_ShipTo_Rel__c soldToShipToJntn= new Core_Account_SoldTo_ShipTo_Rel__c(Core_Ship_To_Account__c = stPartner.shiptoExpressStationID);
                                               soldToShipToJntn.Core_Sold_To_Account__r = accountReference;
                                               soldToShipToList.add(soldToShipToJntn);
                                           }                                           
                                           else if(!String.isEmpty(accountEA.expressStationId) && allShipToIdsAssociationMap.containsKey(stPartner.shiptoExpressStationID)
                                                  && allShipToIdsAssociationMap.get(stPartner.shiptoExpressStationID).Core_Is_Deactivated_Ind__c
                                                  ){//activate shipTo Junction record when ShipTo coming from XML and previuosly it was deactivated(because it's absent)
                                               Core_Account_SoldTo_ShipTo_Rel__c soldToShipToJntnUpdate= new Core_Account_SoldTo_ShipTo_Rel__c();
                                               soldToShipToJntnUpdate.Core_Is_Deactivated_Ind__c = False;
                                               soldToShipToJntnUpdate.Id = allShipToIdsAssociationMap.get(stPartner.shiptoExpressStationID).Id;
                                               //soldToShipToUpdateList.add(soldToShipToJntnUpdate);
                                               soldToShipToList.add(soldToShipToJntnUpdate);
                                               existingShiptToUpdateExcludeList.add(allShipToIdsAssociationMap.get(stPartner.shiptoExpressStationID).Id);
                                           }
                                           
                                       }
                                    else{//SAPId doesn't match
                                        if(!shipToUnsuccessfulMap.containsKey(accountEA.sAPAccountNumber )){//new insert
                                            shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , new List<String>{stPartner.shiptoExpressStationID});    
                                        }else{//update list
                                            List<String> tempMapList = shipToUnsuccessfulMap.get(accountEA.sAPAccountNumber );
                                            tempMapList.add(stPartner.shiptoExpressStationID);
                                            shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , tempMapList);    
                                        }
                                    }
                                }else{ //only ShipTo is invalid, so this attach's error after upserting
                                    //shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , stPartner.shiptoExpressStationID);
                                    if(!shipToUnsuccessfulMap.containsKey(accountEA.sAPAccountNumber )){//new insert
                                        shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , new List<String>{stPartner.shiptoExpressStationID});    
                                    }else{//update list
                                        List<String> tempMapList = shipToUnsuccessfulMap.get(accountEA.sAPAccountNumber );
                                        tempMapList.add(stPartner.shiptoExpressStationID);
                                        shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , tempMapList);   
                                    }
                                }
                            }
                            else if(! (stPartner.shiptoExpressStationID instanceOf Id)){//Bad ShipToPartner ExpressStationID
                                if(!shipToUnsuccessfulMap.containsKey(accountEA.sAPAccountNumber )){//new insert
                                        shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , new List<String>{stPartner.shiptoExpressStationID});    
                                    }else{//update list
                                        List<String> tempMapList = shipToUnsuccessfulMap.get(accountEA.sAPAccountNumber );
                                        tempMapList.add(stPartner.shiptoExpressStationID);
                                        shipToUnsuccessfulMap.put(accountEA.sAPAccountNumber , tempMapList);   
                                    }
                            }
                        }
                        
                        externalIDCounter += 1;
                        externalID = String.valueOf(Datetime.Now())+String.valueOf(externalIDCounter);
                    }
                    
                    //accountProcessedEndList.add(accountEA.sAPAccountNumber);
                }
                else //Trainstation Id is invalid
                {
                    if(!accountDoesntExist){//error message&&log for duplicate account creation
                        attributes.results.add(returnJsonResult('Failed',accountEA.sAPAccountNumber, accountEA.expressStationId, accountEA.trainStationId, accountEA.sAPAccountNumber +' is already associated with '+existingSAPAccountMap.get(accountEA.sAPAccountNumber).Id));
                    logEntryList.add(returnLogEntryResult(accountEA.sAPAccountNumber+' | '+accountEA.expressStationId, 'Failed', 'Status:Failed\nSourceType:SAP\nSAPAccountNumber:'+accountEA.sAPAccountNumber+'\nExpressStationId:'+accountEA.expressStationId+'\nTrainStationID:'+accountEA.trainStationId+'\nMessage:'+accountEA.sAPAccountNumber +' is already associated with'+existingSAPAccountMap.get(accountEA.sAPAccountNumber)+'\n\nXML:'+messageXml));
                    }
                    else{ //error message for invalid Id
                        attributes.results.add(returnJsonResult('Failed',accountEA.sAPAccountNumber, accountEA.expressStationId, accountEA.trainStationId, accountEA.trainStationId +' is invalid') );
                    //logEntryList.add(returnLogEntryResult(accountEA.expressStationId,'failed', accountEA.trainStationId +' is invalid-'+messageXml));
                    logEntryList.add(returnLogEntryResult(accountEA.sAPAccountNumber+' | '+accountEA.expressStationId, 'Failed', 'Status:Failed\nSourceType:SAP\nSAPAccountNumber:'+accountEA.sAPAccountNumber+'\nExpressStationId:'+accountEA.expressStationId+'\nTrainStationID:'+accountEA.trainStationId+'\nMessage:'+accountEA.trainStationId +' is invalid'+'\n\nXML:'+messageXml));
                    }
                    
                }
            }
            
            if(upsertAccountList!=null && upsertAccountList.size()>0){ //Upsert Accounts and Sold To Ship To Junction Object
                
                List<sObject> allIns = new List<sObject>();
                allIns.addAll( upsertAccountList );
                if(soldToShipToList!=null && soldToShipToList.size()>0){
                    allIns.addAll( soldToShipToList);
                }
                if(soldToShipDeactivationList!=null && soldToShipDeactivationList.size()>0){
                    allIns.addAll(soldToShipDeactivationList);
                }
                /*if(soldToShipToUpdateList!=null && soldToShipToUpdateList.size()>0){
                    allIns.addAll(soldToShipToUpdateList);
                }*/
                
                Database.UpsertResult[] results = Database.upsert(allIns, false);
                
                //Check results
                List<Id> successfulIds = new List<Id>(); 
                List<String> failedMessages = new List<String>();
                for (Integer i = 0; i < results.size(); i++) {                    
                    if (results[i].isSuccess()) {
                        if(!junctionObjectIdToDeactivateList.contains(results[i].getId()) && !existingShiptToUpdateExcludeList.contains(results[i].getId())){
                            successfulIds.add(results[i].getId());   
                        }
                    }else{
                        String lastSAPNumber = accountProcessedBeginList[accountProcessedBeginList.size()-1];
                        if(allAccountMap.containsKey(lastSAPNumber)){
                            Core_SAPXMLUtility.AccountEaiAltera acctDtlFailed = allAccountMap.get(lastSAPNumber);
                            attributes.results.add(returnJsonResult('Failed',acctDtlFailed.sAPAccountNumber, acctDtlFailed.expressStationId, acctDtlFailed.trainStationId, results[i].getErrors()[0].getMessage()) );
                            //logEntryList.add(returnLogEntryResult(acctDtlFailed.expressStationId, 'Failed', results[i].getErrors()[0].getMessage()+messageXml));
                            logEntryList.add(returnLogEntryResult(acctDtlFailed.sAPAccountNumber+' | '+acctDtlFailed.expressStationId, 'Failed', 'Status:Failed\nSourceType:SAP\nSAPAccountNumber:'+acctDtlFailed.sAPAccountNumber+'\nExpressStationId:'+acctDtlFailed.expressStationId+'\nTrainStationID:'+acctDtlFailed.trainStationId+'\nMessage:'+results[i].getErrors()[0].getMessage()+'\n\nXML:'+messageXml));
                        }
                        
                        //failedMessages.add(results[i].getErrors()[0].getMessage());
                        //actDtl.Core_Direct_Account_Id__c, actDtl.Id, actDtl.ParentId, actDtl.Core_Direct_Account_Type_Nm__c+'-'+(accountIdMap.containsKey(actDtl.Id)?' updated ':' inserted ')
                        //+ 'based on '+actDtl.Id+';'+ msg
                        //
                    }
                }
                
                //Get details of successfulIds
                Map<Id, Account> sucessfulAccountDetailsList = new Map<Id, Account>([Select Id,Name, Core_Direct_Account_Id__c, ParentId,Core_Direct_Account_Type_Nm__c  from Account where ID IN:successfulIds]);
                
                //Get Child Object details(Ship To)
                List<Id> shipToJunctionList = new List<Id>();
                for(Id successfulId : successfulIds){
                    if(!sucessfulAccountDetailsList.keySet().contains(successfulId)){
                        shipToJunctionList.add(successfulId);
                    }
                }
                
                //Map<Id, Id> soldToShipToParentAccount = new Map<Id, Id>();
                Map<String, List<Id> > junctionAccountSAPIdMap = new Map<String, List<Id>>();
                List<Core_Account_SoldTo_ShipTo_Rel__c> soldToShipToRetlList= [SELECT Id, Core_Sold_To_Account__r.Core_Direct_Account_Id__c, Core_Ship_To_Account__r.Id, Core_Ship_To_Account__r.Core_Direct_Account_Id__c, Core_Sold_To_Account__c from Core_Account_SoldTo_ShipTo_Rel__c where Id IN :shipToJunctionList];
                for(Core_Account_SoldTo_ShipTo_Rel__c soldToShipTo : soldToShipToRetlList){
                    //soldToShipToParentAccount.put(soldToShipTo.Core_Sold_To_Account__c, soldToShipTo.Id);
                    //add first id to Map
                    if(!junctionAccountSAPIdMap.containsKey(soldToShipTo.Core_Sold_To_Account__r.Core_Direct_Account_Id__c)){
                        junctionAccountSAPIdMap.put(soldToShipTo.Core_Sold_To_Account__r.Core_Direct_Account_Id__c, new List<Id>{soldToShipTo.Core_Ship_To_Account__r.Id});    
                    }else{//update existing map by adding new id
                        List<Id> tempExtractedList = junctionAccountSAPIdMap.get(soldToShipTo.Core_Sold_To_Account__r.Core_Direct_Account_Id__c);
                        if(!tempExtractedList.contains(soldToShipTo.Core_Ship_To_Account__r.Id)){
                            tempExtractedList.add(soldToShipTo.Core_Ship_To_Account__r.Id);    
                        }
                        junctionAccountSAPIdMap.put(soldToShipTo.Core_Sold_To_Account__r.Core_Direct_Account_Id__c, tempExtractedList );    
                    }                    
                }
                //success JSON
                //String msg = '';
                for(Account actDtl : sucessfulAccountDetailsList.values()){
                    String msg = '';
                     if(!junctionAccountSAPIdMap.containsKey(actDtl.Core_Direct_Account_Id__c) && !shipToUnsuccessfulMap.containsKey(actDtl.Core_Direct_Account_Id__c)){ //ShipTo as Junction Object not added as it wasnt present in XML
                        msg = msg+ '';
                    }
                   else if(junctionAccountSAPIdMap.containsKey(actDtl.Core_Direct_Account_Id__c) ){//successfuly inserted ShipTo to junction object
                        msg = msg + ' ;Ship To : '+junctionAccountSAPIdMap.get(actDtl.Core_Direct_Account_Id__c)+' added';
                    }
                     if(shipToUnsuccessfulMap.containsKey(actDtl.Core_Direct_Account_Id__c)){//check if any error of ShipToPartner
                        msg = msg + ' ;Ship To : '+shipToUnsuccessfulMap.get(actDtl.Core_Direct_Account_Id__c)+ ' not added';
                    }
                    attributes.results.add(returnJsonResult('SUCCESS', actDtl.Core_Direct_Account_Id__c, actDtl.Id, actDtl.ParentId, actDtl.Core_Direct_Account_Type_Nm__c+'-'+(accountIdMap.containsKey(actDtl.Id)?' updated ':' inserted ')
                        + 'based on '+actDtl.Id+';'+ msg));
                    
                    //Log
           
                    //logEntryList.add(returnLogEntryResult(actDtl.Id,'Success', actDtl.Core_Direct_Account_Type_Nm__c+'-'+(accountIdMap.containsKey(actDtl.Id)?' updated ':' inserted ')
                      //  + 'based on '+actDtl.Id+';'+ msg +'-'+messageXml));
                      logEntryList.add(returnLogEntryResult(actDtl.Core_Direct_Account_Id__c+' | '+actDtl.Id, 'Success', 'Status:SUCCESS\nSourceType:SAP\nSAPAccountNumber:'+actDtl.Core_Direct_Account_Id__c+'\nExpressStationId:'+actDtl.Id+'\nTrainStationID:'+actDtl.ParentId+'\nMessage:'+actDtl.Core_Direct_Account_Type_Nm__c+'-'+(accountIdMap.containsKey(actDtl.Id)?' updated ':' inserted ')+ 'based on '+actDtl.Id+';'+ msg+'\n\nXML:'+messageXml));
                    
                    //msg = '';
                }
                for(String failedMessage: failedMessages){
                    attributes.results.add(returnJsonResult('Failed', '', '', '', failedMessage));
                     logEntryList.add(returnLogEntryResult('', 'Failed', failedMessage+'-'+messageXml));
                }
            }
        }Catch(Exception ex){
            //attributes.results.add(returnJsonResult('Failed', '', '', '', ex.getMessage()));
            logEntryList.add(returnLogEntryResult('', 'Failed', '\nException:'+ex.getMessage()+'\nLine:'+ex.getLineNumber()+'\n\nXML:'+messageXml));
            PMP_Utility.logError(ex, 'Core_SAPXMLParser.insertXMLData');
            
        }
        finally{
            try{
                if(logEntryList!=null && logEntryList.size()>0){
                    insert logEntryList;
                   
                }
                
                
            }catch(Exception ex){
                //logEntryList.add(returnLogEntryResult('', 'Failed', 'Exception in finally:-'+ex.getMessage()+'-'+messageXml));
                PMP_Utility.logError(ex, 'Core_SAPXMLParser.insertXMLData');
            }
            
        }
        return attributes;
    }
    
    public static Core_SAPXMLUtility.ListOfAccountEaiAltera  parseSAPXML(String messageXml){
        Core_SAPXMLUtility.ListOfAccountEaiAltera listOfAccountEaiAlteraCls = new Core_SAPXMLUtility.ListOfAccountEaiAltera();
        Dom.Document doc = new Dom.Document();
        doc.load(messageXml);
        Dom.XmlNode rootXml = doc.getRootElement();
        Dom.XmlNode listOfAccountEaiAltera = rootXml.getChildElement('ListOfAccountEaiAltera', null);//<ListOfAccountEaiAltera>
        if (listOfAccountEaiAltera != null) {
            for (Dom.XmlNode childNode : listOfAccountEaiAltera.getChildElements()) {
                if (childNode.getName() == 'AccountEaiAltera') {
                    listOfAccountEaiAlteraCls.listAccountEaiAltera.add(parseAccountEaiAltera(childNode));
                }                
            }
        }        
        return listOfAccountEaiAlteraCls;
    }
    
    private static Core_SAPXMLUtility.Shipto_Partner parseShipToPartner(Dom.XmlNode accountShipToPartner) {
        Core_SAPXMLUtility.Shipto_Partner sP = new Core_SAPXMLUtility.Shipto_Partner();
        //Dom.XmlNode shipToPartnerXml = accountShipToPartner.getChildElement('Shipto_Partners', null);
        sP.shipto = getValue(accountShipToPartner, 'Shipto');
        sP.shiptoExpressStationID = getValue(accountShipToPartner, 'ShiptoExpressStationID');   
        return sP;
    }
    
    private static Core_SAPXMLUtility.AccountEaiAltera parseAccountEaiAltera(Dom.XmlNode accountEaiAlteratXml) {
        Core_SAPXMLUtility.AccountEaiAltera aEADtls = new Core_SAPXMLUtility.AccountEaiAltera();
        List<Core_SAPXMLUtility.Shipto_Partner> sPList = new List<Core_SAPXMLUtility.Shipto_Partner>();
        aEADtls.expressStationId =getValue(accountEaiAlteratXml, 'ExpressStationId');
        aEADtls.trainStationId =getValue(accountEaiAlteratXml, 'TrainStationID');
        aEADtls.name =getValue(accountEaiAlteratXml, 'Name');
        aEADtls.sAPAccountNumber =getValue(accountEaiAlteratXml, 'SAPAccountNumber');
        aEADtls.freightTerms =getValue(accountEaiAlteratXml, 'FreightTerms');
        aEADtls.type =getValue(accountEaiAlteratXml, 'Type');
        aEADtls.x_ALT_PAYTERMS =getValue(accountEaiAlteratXml, 'X_ALT_PAYTERMS');
        aEADtls.x_ALT_SAP_ACCT_TYPE =getValue(accountEaiAlteratXml, 'X_ALT_SAP_ACCT_TYPE');
        aEADtls.shippingCondition =getValue(accountEaiAlteratXml, 'ShippingCondition');
        aEADtls.streetAddress =getValue(accountEaiAlteratXml, 'StreetAddress');
        aEADtls.streetAddress2 =getValue(accountEaiAlteratXml, 'StreetAddress2');
        aEADtls.city =getValue(accountEaiAlteratXml, 'City');
        aEADtls.province =getValue(accountEaiAlteratXml, 'Province');
        aEADtls.state =getValue(accountEaiAlteratXml, 'State');
        aEADtls.country =getValue(accountEaiAlteratXml, 'Country');
        aEADtls.postalCode =getValue(accountEaiAlteratXml, 'PostalCode');
        aEADtls.regionCode =getValue(accountEaiAlteratXml, 'RegionCode');
        aEADtls.salesOrganization =getValue(accountEaiAlteratXml, 'SalesOrganization');
        aEADtls.nielsenId =getValue(accountEaiAlteratXml, 'NielsenID');
        aEADtls.distyChannel =getValue(accountEaiAlteratXml, 'DistyChannel');
        aEADtls.shipToEndCustomer =getValue(accountEaiAlteratXml, 'ShipToEndCustomer');
        aEADtls.shippingInstructions =getValue(accountEaiAlteratXml, 'ShippingInstructions');
        aEADtls.accountName2 =getValue(accountEaiAlteratXml, 'AccountName2');
        aEADtls.parentAccountTier =getValue(accountEaiAlteratXml, 'ParentAccountTier');
        //aEADtls.industryCode1 =getValue(accountEaiAlteratXml, 'IndustryCode1');
        //aEADtls.isPricingParent =getValue(accountEaiAlteratXml, 'IsPricingParent');//commented as per US#
        
        /*Dom.XmlNode shipToPartnerXml = accountEaiAlteratXml.getChildElement('Shipto_Partners', null);
        sP.shipto = getValue(shipToPartnerXml, 'Shipto');
        sP.shiptoExpressStationID = getValue(shipToPartnerXml, 'ShiptoExpressStationID');*/
        Dom.XmlNode shipToPartnerXml = accountEaiAlteratXml.getChildElement('Shipto_Partners', null);
        if(shipToPartnerXml!=null){
            for (Dom.XmlNode childNode : shipToPartnerXml.getChildElements()) {
                if (childNode.getName() == 'Shipto_Partner') {
                    sPList.add(parseShipToPartner(childNode));
                }                
            }
            aEADtls.shipToPartList = sPList;
        }
        //aEADtls.shipToPart=sp;
        
        return aEADtls;
    }
    
    private static String getValue(Dom.XmlNode node, String child) {
        
        if ((node != null) && (node.getChildElement(child, null) != null)) {
            Dom.XmlNode childNode = node.getChildElement(child, null);
            return childNode.getText();
        }
        return '';
    }
    
    private static Core_SAPXMLUtility.JsonResult  returnJsonResult( String status, string sAPAccountNumber, string expressStationId, string trainStationId, string msg){
        Core_SAPXMLUtility.JsonResult jsonResultSucc = new Core_SAPXMLUtility.JsonResult();
        jsonResultSucc.Status = status;
        jsonResultSucc.SourceType = 'SAP';
        jsonResultSucc.SAPAccountNumber = sAPAccountNumber;
        jsonResultSucc.ExpressStationId = expressStationId;
        jsonResultSucc.TrainStationID = trainStationId;
        jsonResultSucc.Message = msg;
        return jsonResultSucc;
    }
    
    /*private static Core_Platform_Event_Log__c returnLogResult(string objectId, string status, string message){
        Core_Platform_Event_Log__c log = new Core_Platform_Event_Log__c();
        log.Core_Object_Id__c = objectId;
        //log.Account__c = objectId;
        log.Core_Status__c = status;
        log.Core_Message__c = message;
        return log;
    }*/
    private static Core_Log_Entry__c returnLogEntryResult(string objectId, string status, string message){
        Core_Log_Entry__c log = new Core_Log_Entry__c();
        log.Core_sObjectId__c = objectId;
        log.Core_Details__c = message;
        log.Core_Project__c = 'SAP';
        log.Core_Message__c = status;
        log.Core_Origin__c = 'SF';
        log.Core_Severity__c = 'Medium';
        log.Core_sObjectType__c = 'Account';
        log.Core_When__c = DateTime.now();
        /*log.Core_Object_Id__c = objectId;
        //log.Account__c = objectId;
        log.Core_Status__c = status;
        log.Core_Message__c = message;
        return log;*/
        
        return log;
    }
}