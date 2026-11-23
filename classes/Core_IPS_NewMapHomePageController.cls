/***************************************************************************************************
* Apex Class Name : Core_IPS_NewMapHomePageController
* Test Class Name : Core_IPS_NewMapHomePageControllerTest
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sneha                    10/08/2019              Created
* Ganapati                 25/11/2019              Modified for US517861 
* Ganapati                 16/01/2019             Modified for US534513
****************************************************************************************************/

public with sharing class Core_IPS_NewMapHomePageController {  
    private static String currentUserId = UserInfo.getUserId();
    private static Id currentProfileID = Userinfo.getProfileId();
    @AuraEnabled(cacheable=true)
    public static Boolean isNewMapButtonVisible(){
        Boolean validUser = TRUE;
        Profile currentProfile = [SELECT Name from Profile where ID =:currentProfileID LIMIT 1];
        if(currentProfile != NULL){
            String profileLabel = System.Label.core_IPS_NewMapProfiles;
            if(profileLabel.contains(currentProfile.Name)) {
                validUser = FALSE;
            }
        }
        return validUser;
    }
    
    @AuraEnabled(cacheable=true)
    //Modified the return type and method - Aparna for US484364 -16 Oct,2019
    public static List<DataTableWrapper> displayMapResults(String queryString){
        List<sObject> sObjLst = new list<sObject>();
        List<Core_IPS_MAP_PAR__c> resultToDisplay = new List<Core_IPS_MAP_PAR__c>();
        List<DataTableWrapper> response = new list<DataTableWrapper>();
        
        try {
            // Venrublity Fix - Refering query to service class
            // sObjLst = Database.query(queryString);
            sObjLst = Core_IPS_QueryService.queryRecords(queryString);
            
            for(Core_IPS_MAP_PAR__c mapResults : (List<Core_IPS_MAP_PAR__c>)sObjLst) {                
                DataTableWrapper obj = new DataTableWrapper();
                obj.mapName = mapResults.Core_Name__c;
                obj.mapNumber = mapResults.Name;
                obj.mapStatus = mapResults.Core_Status__c;
                obj.accessFlag = mapResults.Core_IPS_MAP_Access_Flag__c;
                obj.mapOrg = mapResults.Core_Product_Organization__r.Name;
                obj.mapOrgName = mapResults.Core_Product_Organization__r.Core_IPS_Support_Org_Name__c;
                obj.mapModifiedBy = mapResults.LastModifiedBy.Name;
                obj.mapPFA= mapResults.Core_Product_Organization__r.Core_Organization_Description__c;
                obj.mapNavigationUrl=  '/lightning/r/' + mapResults.Id + '/view';
                obj.orgNavigationUrl = '/lightning/r/' + mapResults.Core_Product_Organization__r.Id + '/view';
                obj.modifiedByUrl = '/lightning/r/' + mapResults.LastModifiedById + '/view';
                
                obj.objectToDisplay = mapResults; 
                
                response.add(obj);
            }
        } catch(Exception e) {
           
        }
        return response;
    }
    
    //Added by Aparna for US484364 -16 Oct,2019
    public class DataTableWrapper {
        @AuraEnabled
        public string mapName {get;set;}
        @AuraEnabled
        public string mapNumber {get;set;}
        @AuraEnabled
        public String mapStatus {get;set;}
        @AuraEnabled
        public String accessFlag {get;set;}
        @AuraEnabled
        public String mapPFA {get;set;}
        @AuraEnabled
        public String mapOrg {get;set;}
        @AuraEnabled
        public String mapOrgName {get;set;}
        @AuraEnabled
        public String mapModifiedBy {get;set;}
        @AuraEnabled
        public String mapNavigationUrl {get;set;}
        @AuraEnabled
        public String orgNavigationUrl {get;set;}
        @AuraEnabled
        public String modifiedByUrl {get;set;}
        @AuraEnabled
        public sObject objectToDisplay{get;set;}
    }
    
    //end for US484364
    
    @AuraEnabled
    public static Core_IPS_MAP_PAR__c updateMAPRecord(Core_IPS_MAP_PAR__c mapRecord) {
        
        // Venrublity Fix - Refering query to service class
        // update mapRecord;
        List<SObject> updatedRecords = Core_IPS_QueryService.updateRecords(new List<SObject>{ mapRecord });
        mapRecord = (Core_IPS_MAP_PAR__c) updatedRecords[0];
        return mapRecord;
    } 
    @AuraEnabled
    public static String deleteMAPRecord(sObject rec) {
        // Venrublity Fix - Refering query to service class
        // delete rec;
        Core_IPS_QueryService.deleteRecords(new List<SObject>{ rec });
        return 'Success';
    }
    
    @AuraEnabled(cacheable = true)
    public static List<sObject> getQueryResult(String queryString) {
        //SOQL SOSL Injection Fix cannot be done here as it is handled in javascript controller.       
        List<sObject> sObjLst = new list<sObject>();
        // Venrublity Fix - Refering query to service class
        // sObjLst = Database.query(queryString);
        sObjLst = Core_IPS_QueryService.queryRecords(queryString);
        return sObjLst;
    }
    
    /***************************************************************************************************
Method Name: addSupportedProductToMAP
Version     : 1.0 
Created Date: 23 Oct 2019
Description : This method inserts Core_IPS_MAP_Product__c rec
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  23/10/2019           Created for US508857
****************************************************************************************************/      
    @AuraEnabled
    public static Object addSupportedProductToMAP(List<Core_IPS_MAP_Product__c> mapProducts) {
        String response;
        if(mapProducts!=null) {
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=true;
            try {
                //insert mapProducts;
                Core_IPS_AdminUtility.insertProdAccessProdJOs(mapProducts);
                response = '{"Status" : "success", "data" : ' + JSON.serialize(mapProducts) + '}';
            } catch(Exception e) {
                response = '{"Status" : "error", "message" : "' + e.getMessage() +'"}';
            }
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=false;
        }
        return JSON.deserializeUntyped(response) ;
    }
    
    /***************************************************************************************************
Method Name: addAccountToMAP
Version     : 1.0 
Created Date: 06 Nov 2019
Description : This method inserts Core_IPS_MAP_Account__c rec
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  06/11/2019           Created for US508857
****************************************************************************************************/      
    @AuraEnabled
    public static Object addAccountToMAP(Core_IPS_MAP_Account__c mapAccount) {
        String response;
        if(mapAccount!=null) {
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=true;
            try {
                //insert mapAccount;   
                List<Core_IPS_MAP_Account__c> coreMapAccToInsert = new List<Core_IPS_MAP_Account__c>();
                coreMapAccToInsert.add(mapAccount);
                Core_IPS_AdminUtility.insertProdAccessAccJOs(coreMapAccToInsert);
                response = '{"Status" : "success", "data" : ' + JSON.serialize(mapAccount) + '}';
            } catch(Exception e) {
                response = '{"Status" : "error", "message" : "' + e.getMessage() +'"}';
            }
            Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger=false;
        }
        return JSON.deserializeUntyped(response) ;
    }
    
    /***************************************************************************************************
Method Name: createLineItems
Version     : 1.0 
Created Date: 23 Oct 2019
Description : This method takes list MAP line items and inserts.
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  23/10/2019           Created for US410459
****************************************************************************************************/        
    @AuraEnabled
    public static Object createLineItems(List<Core_IPS_Map_Par_Line_Item__c> mapLineItemList){  
        String response = '{"Status" : "success"}';
       
        Boolean createNewLineItemsFlag = true;   
        String uniqueKey = '';
        Map<String, Core_IPS_Map_Par_Line_Item__c> draftLineItemsMap = new Map<String, Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_MAP_Account__c> accountsList = new List<Core_IPS_MAP_Account__c>();
        List<Core_IPS_MAP_Product__c> productsList = new List<Core_IPS_MAP_Product__c>();
        List<Core_IPS_Map_Par_Line_Item__c> newLineItemsToInsert = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> eOISLitems = new List<Core_IPS_Map_Par_Line_Item__c>();     
        List<Core_IPS_Map_Par_Line_Item__c> activatedLitems = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> inActiveLineItemLst = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> activeLineItemLst = new List<Core_IPS_Map_Par_Line_Item__c>();
        Set<Id> mapIds = new Set<Id>();
        Set<Id> inActiveLineItemAccounts = new Set<Id>();
        Set<Id> inActiveLineItemProducts = new Set<Id>();
        Set<Id> activeLineItemAccounts = new Set<Id>();
        Set<Id> activeLineItemProducts = new Set<Id>();
        
        Set<Id> draftLineItemProductIdSet = new Set<Id>();
        Set<Id> draftLineItemAccountIdSet = new Set<Id>();
        
        Set<Id> supportOrgIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> supportedProdIdSet = new Set<Id>();
        MAP<Id, Id> prodAccesssupportOrgMap = new MAP<Id, Id>();
        
        for(Core_IPS_Map_Par_Line_Item__c lineitem : mapLineItemList){
            mapIds.add(lineitem.Core_MAP_PAR__c);
            accountIdSet.add(lineitem.Core_Account__c);
            supportedProdIdSet.add(lineitem.Core_Supported_Product__c);
            draftLineItemProductIdSet.add(lineitem.Core_Supported_Product__c);
            draftLineItemAccountIdSet.add(lineitem.Core_Account__c);
            uniqueKey = lineitem.Core_MAP_PAR__c + '$' + lineitem.Core_Supported_Product__c + '$' + lineitem.Core_Account__c;
            if(!draftLineItemsMap.containsKey(uniqueKey)) {
                draftLineItemsMap.put(uniqueKey, lineitem);
            }
        }
        
        // Venrublity Fix - Refering query to service class
        // Map<Id,Core_IPS_MAP_PAR__c> mapRecords=new Map<Id,Core_IPS_MAP_PAR__c>([
        //     SELECT 
        //     Id, 
        //     RecordType.Name,
        //     Core_Product_Organization__c,
        //     (
        //         SELECT          
        //         Id, 
        //         Core_MAP_Supported_Product__c,
        //         Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c,
        //         Core_MAP_Supported_Product__r.Id, 
        //         Core_MAP_Supported_Product__r.Core_Product__c,
        //         Core_MAP_PAR__c,Core_MAP_PAR__r.RecordType.Name 
        //         FROM MAP_Supported_Products__r
        //     ), 
        //     (
        //         SELECT 
        //         Id, 
        //         Core_Account__c, 
        //         Core_MAP_PAR__c, 
        //         Core_MAP_PAR__r.RecordType.Name 
        //         FROM MAP_Accounts__r
        //     ) 
        //     FROM Core_IPS_MAP_PAR__c 
        //     WHERE Id IN : mapIds
        // ]);
        Map<Id,Core_IPS_MAP_PAR__c> mapRecords = new Map<Id,Core_IPS_MAP_PAR__c>(
            (List<Core_IPS_MAP_PAR__c>) Core_IPS_QueryService.queryRecords(
                'SELECT Id, RecordType.Name, Core_Product_Organization__c, (SELECT Id, Core_MAP_Supported_Product__c, Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c, Core_MAP_Supported_Product__r.Id, Core_MAP_Supported_Product__r.Core_Product__c, Core_MAP_PAR__c,Core_MAP_PAR__r.RecordType.Name FROM MAP_Supported_Products__r), (SELECT Id, Core_Account__c, Core_MAP_PAR__c, Core_MAP_PAR__r.RecordType.Name FROM MAP_Accounts__r) FROM Core_IPS_MAP_PAR__c WHERE Id IN :mapIds',
                new Map<String, Object>{ 'mapIds' => mapIds }
            )
        );
        
        for(Core_IPS_MAP_PAR__c mapRec : mapRecords.values()) {
            supportOrgIdSet.add(mapRec.Core_Product_Organization__c);
            prodAccesssupportOrgMap.put(mapRec.Id, mapRec.Core_Product_Organization__c);
            if(mapRec.MAP_Accounts__r.size()>0) {
                accountsList.addAll(mapRec.MAP_Accounts__r);
            }
            if(mapRec.MAP_Supported_Products__r.size()>0) {
                productsList.addAll(mapRec.MAP_Supported_Products__r);
            }
        }
        
        
        for(Asset assetRec : [
            SELECT 
            Id, Status, AccountId, Core_Supported_Product__c, Core_Product_Organization__c   
            FROM Asset 
            WHERE AccountId IN :accountIdSet
            AND Core_Supported_Product__c IN :supportedProdIdSet
            AND Core_Product_Organization__c IN :prodAccesssupportOrgMap.values()]
           ) {
               for(Core_IPS_Map_Par_Line_Item__c lineItem : mapLineItemList) {
                   if(assetRec.Status == 'Active' &&  assetRec.AccountId == lineItem.Core_Account__c && assetRec.Core_Supported_Product__c == lineItem.Core_Supported_Product__c && assetRec.Core_Product_Organization__c == prodAccesssupportOrgMap.get(lineItem.Core_MAP_PAR__c)  ) {
                       lineItem.Core_Approval_Type__c = '';
                       lineItem.Core_Status__c = 'Active';
                   }    
               }
           }
        
        // Venrublity Fix - Refering query to service class
        // for(Core_IPS_Map_Par_Line_Item__c lineItem : [
        //     SELECT 
        //     Id, 
        //     Name,
        //     Core_Account__c, 
        //     Core_Supported_Product_EOIS__c, 
        //     RecordTypeId, 
        //     RecordType.Name, 
        //     Core_Supported_Product__c,
        //     Core_Status__c 
        //     FROM Core_IPS_Map_Par_Line_Item__c 
        //     WHERE (Core_Status__c = 'INACTIVE'
        //            OR Core_Status__c = 'ACTIVE' )
        //     AND Core_MAP_PAR__c IN: mapIds
        //     AND Core_Supported_Product__c IN: draftLineItemProductIdSet  
        //     AND Core_Account__c IN: draftLineItemAccountIdSet 
        // ]) {
        for(Core_IPS_Map_Par_Line_Item__c lineItem : (List<Core_IPS_Map_Par_Line_Item__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Core_Account__c, Core_Supported_Product_EOIS__c, RecordTypeId, RecordType.Name, Core_Supported_Product__c, Core_Status__c FROM Core_IPS_Map_Par_Line_Item__c WHERE (Core_Status__c = \'INACTIVE\' OR Core_Status__c = \'ACTIVE\') AND Core_MAP_PAR__c IN :mapIds AND Core_Supported_Product__c IN :draftLineItemProductIdSet AND Core_Account__c IN :draftLineItemAccountIdSet',
            new Map<String, Object>{
                'mapIds' => mapIds,
                'draftLineItemProductIdSet' => draftLineItemProductIdSet,
                'draftLineItemAccountIdSet' => draftLineItemAccountIdSet
            }
        )) {
            if(lineItem.Core_Status__c == 'INACTIVE') {
                inActiveLineItemLst.add(lineItem);
            }
            if(lineItem.Core_Status__c == 'ACTIVE') {
                activeLineItemLst.add(lineItem);
                activeLineItemAccounts.add(lineItem.Core_Account__c);
                activeLineItemProducts.add(lineItem.Core_Supported_Product__c);
            }
        }
        
        uniqueKey = '';
        for(Core_IPS_MAP_Account__c aMAP : accountsList) {
            if(mapRecords.get(aMap.Core_MAP_PAR__c).MAP_Supported_Products__r.size()>0) {
                for(Core_IPS_MAP_Product__c pmAP: mapRecords.get(aMap.Core_MAP_PAR__c).MAP_Supported_Products__r) {  
                    uniqueKey = aMap.Core_MAP_PAR__c + '$' + pmAP.Core_MAP_Supported_Product__c + '$' + aMAP.Core_Account__c;
                    for(Core_IPS_Map_Par_Line_Item__c inActiveLineItem : inActiveLineItemLst) {
                        if(inActiveLineItem.Core_Account__c==aMAP.Core_Account__c 
                           && inActiveLineItem.Core_Supported_Product__c == pmAP.Core_MAP_Supported_Product__c 
                           && draftLineItemsMap != null && draftLineItemsMap.get(uniqueKey) != null 
                           && draftLineItemsMap.get(uniqueKey).Core_Status__c == 'ACTIVE'
                          ) {
                              inActiveLineItemAccounts.add(inActiveLineItem.Core_Account__c);
                              inActiveLineItemProducts.add(inActiveLineItem.Core_Supported_Product__c);
                              if(inActiveLineItem.Core_Supported_Product_EOIS__c <> true) {
                                  inActiveLineItem.Core_Status__c='ACTIVE';
                                  inActiveLineItem.Core_Submitter_Comments__c = draftLineItemsMap.get(uniqueKey).Core_Submitter_Comments__c;
                                  activatedLitems.add(inActiveLineItem);
                                  
                              } else {
                                  eOISLitems.add(inActiveLineItem);
                              }                                        
                          }                           
                    }  
                    if(inActiveLineItemLst!=null 
                       && inActiveLineItemLst.size()>0 
                       && (!inActiveLineItemAccounts.contains(aMAP.Core_Account__c) 
                           && !inActiveLineItemProducts.contains(pmAP.Core_MAP_Supported_Product__c)
                           && !activeLineItemAccounts.contains(aMAP.Core_Account__c)
                           && !activeLineItemProducts.contains(pmAP.Core_MAP_Supported_Product__c))
                       && (draftLineItemsMap != null && draftLineItemsMap.get(uniqueKey) != null)
                      ) {
                          Core_IPS_Map_Par_Line_Item__c insertlitem = new Core_IPS_Map_Par_Line_Item__c();
                          insertlitem.Core_Account__c = aMAP.Core_Account__c;
                          insertlitem.Core_MAP_PAR__c = pmAP.Core_MAP_PAR__c;
                          insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                          insertlitem.Core_Status__c = 'ACTIVE';
                          insertlitem.Core_Supported_Product__c = pmap.Core_MAP_Supported_Product__r.Id;    
                          insertlitem.Core_Submitter_Comments__c = draftLineItemsMap.get(uniqueKey).Core_Submitter_Comments__c;                          
                          newLineItemsToInsert.add(insertlitem);
                      }
                }
            }
        }
        
        if(activatedLitems !=null && activatedLitems.size() > 0){
            try {
                //update activatedLitems;
                AdminOperations admOps = new AdminOperations();
                admOps.updateLineItems(activatedLitems);
            } catch(Exception e) {
                response = '{"Status" : "error", "message" : "' + e.getMessage() +'"}';
            }
            createNewLineItemsFlag = false;
        }
        
        if(newLineItemsToInsert <> null && newLineItemsToInsert.size() > 0){
            Core_Asset_Dispatcher.Assetfieldupdated = false;
            try {
                //insert newLineItemsToInsert;    
                Core_IPS_AdminUtility.insertLineItems(newLineItemsToInsert);
              
            } catch(Exception e) {
                response = '{"Status" : "error", "message" : "' + e.getMessage() +'"}';
            }
            createNewLineItemsFlag = false;
        }
        
        if(eOISLitems.size() > 0){
            createNewLineItemsFlag = false;
        }
        
        if(createNewLineItemsFlag) {
            if(mapLineItemList != null && !mapLineItemList.isEmpty() ) {
                try  {
                    //insert mapLineItemList;    
                    Core_IPS_AdminUtility.insertLineItems(mapLineItemList);
                } catch(Exception e) {
                    response = '{"Status" : "error", "message" : "' + e.getMessage() +'"}';
                }
            }
        }
        return JSON.deserializeUntyped(response);
    }
    
    /***************************************************************************************************
Method Name: isCurrentUserOrgAdminMember
Version     : 1.0 
Created Date: 25 Nov 2019
Description : This method takes the support org Id and return a true ot false based on the current user is in the support org admin group.
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  25/11/2019           Created for US517861
****************************************************************************************************/       
    @AuraEnabled
    public static Boolean isCurrentUserOrgAdminMember(String supportOrgId) {
        Boolean isOrgAdminMember = false;
        //String currentUserId = UserInfo.getUserId();
        //Id currentProfileID = Userinfo.getProfileId();
        // Venrublity Fix - Refering query to service class
        List<Profile> currentProfileList= [SELECT Name from Profile where ID =:currentProfileID LIMIT 1];
       
        Profile currentProfile = currentProfileList.isEmpty() ? null : currentProfileList[0];
        if(currentProfile != null){
            if(System.Label.Core_IPS_System_Admin_Profile_Name.equalsIgnoreCase(currentProfile.Name) || System.Label.Core_IT_Admin_Profile_Name.equalsIgnoreCase(currentProfile.Name)) {
                return true;
            }
        }
        // Venrublity Fix - Refering query to service class
        // Core_IPS_Product_Organization__c supportOrg = [
        //     SELECT 
        //     Id,
        //     OwnerId,
        //     Owner.Type, 
        //     (
        //         SELECT 
        //         Id,
        //         Core_Product_Organization__c,
        //         Core_Admin__c 
        //         From Product_Organization_Admins__r
        //     ) 
        //     FROM Core_IPS_Product_Organization__c 
        //     WHERE Id = :supportOrgId
        // ];
        List<Core_IPS_Product_Organization__c> supportOrgList = (List<Core_IPS_Product_Organization__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, OwnerId, Owner.Type, (SELECT Id, Core_Product_Organization__c, Core_Admin__c From Product_Organization_Admins__r) FROM Core_IPS_Product_Organization__c WHERE Id = :supportOrgId',
            new Map<String, Object>{ 'supportOrgId' => supportOrgId }
        );
        if (supportOrgList.isEmpty()) {
            return false;
        }
        Core_IPS_Product_Organization__c supportOrg = supportOrgList[0];
        
        if(supportOrg.Owner.Type == 'User' && String.valueOf(supportOrg.OwnerId).contains(currentUserId)) {
            isOrgAdminMember = true;
        } else if (supportOrg.Owner.Type == 'Queue') {
            Set<Id> ownerIdSet = new Set<Id>();
            ownerIdSet = getUserIdsFromQPB(supportOrg.OwnerId);
            if(ownerIdSet.contains(currentUserId)) {
                isOrgAdminMember = true;
            }
        }
        
        if(!isOrgAdminMember) {
            for(Core_IPS_Product_Organization_Admin__c orgAdminRec : supportOrg.Product_Organization_Admins__r) {
                if(String.valueOf(orgAdminRec.Core_Admin__c).contains(currentUserId)) {
                    isOrgAdminMember = true;
                    break;
                }
            }    
        }
        
        return isOrgAdminMember;
    }
    
    /***************************************************************************************************
Method Name: getFAEAffiliatedAccounts
Version     : 1.0 
Created Date: 25 Nov 2019
Description : This method returns list off account for which current user affiliated, i.e. Owner or team member
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  25/11/2019           Created for US517861
****************************************************************************************************/
    @AuraEnabled
    public static List<Account> getFAEAffiliatedAccounts() {
        //String currentUserId = UserInfo.getUserId();
        Set<Id> accIdSet = new Set<Id>();
        List<Account> accounts = new List<Account>(); 
        // Venrublity Fix - Refering query to service class
        // for(Account accRec : [SELECT Id, Name, Core_CNDA_Number__c, Core_IPS_Active__c, Owner.Name FROM Account where OwnerId = :currentUserId AND (Core_CNDA_Number__c !='' OR Core_CNDA_Number__c != Null) AND Core_IPS_Active__c=true]) {
        for(Account accRec : (List<Account>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Core_CNDA_Number__c, Core_IPS_Active__c, Owner.Name FROM Account where OwnerId = :currentUserId AND (Core_CNDA_Number__c != \'\' OR Core_CNDA_Number__c != Null) AND Core_IPS_Active__c=true',
            new Map<String, Object>{ 'currentUserId' => currentUserId }
        )) {
            accounts.add(accRec);
            accIdSet.add(accRec.Id);
        }
        // Venrublity Fix - Refering query to service class
        // for(AccountTeamMember accTeamMember : [
        //     SELECT Id, AccountId from AccountTeamMember where (CaseAccessLevel = 'Edit' OR CaseAccessLevel = 'Read') AND userId = :currentUserId]
        //    ) {
        for(AccountTeamMember accTeamMember : (List<AccountTeamMember>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, AccountId from AccountTeamMember where (CaseAccessLevel = \'Edit\' OR CaseAccessLevel = \'Read\') AND userId = :currentUserId',
            new Map<String, Object>{ 'currentUserId' => currentUserId }
        )) {
               if(!accIdSet.contains(accTeamMember.AccountId)) {
                   accIdSet.add(accTeamMember.AccountId);   
               }
           }
        // Venrublity Fix - Refering query to service class
        // accounts.addAll([SELECT Id, Name, Core_CNDA_Number__c, Core_IPS_Active__c, Owner.Name FROM Account where Id IN :accIdSet AND (Core_CNDA_Number__c !='' OR Core_CNDA_Number__c != Null) AND Core_IPS_Active__c=true]);
        accounts.addAll((List<Account>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, Core_CNDA_Number__c, Core_IPS_Active__c, Owner.Name FROM Account where Id IN :accIdSet AND (Core_CNDA_Number__c != \'\' OR Core_CNDA_Number__c != Null) AND Core_IPS_Active__c=true',
            new Map<String, Object>{ 'accIdSet' => accIdSet }
        ));
        return accounts;
    } 
    
    /***************************************************************************************************
Method Name: getUserIdsFromQPB
Version     : 1.0 
Created Date: 02 Dec 2019
Description : This method takes the Queue or Public Group Id and return set of user ids from that Queue or Public group
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  02/12/2019           Created for US517861
****************************************************************************************************/         
    public static Set<Id> getUserIdsFromQPB(Id queueId) {
        Set<Id> userIds = new Set<Id>();
        // Venrublity Fix - Refering query to service class
        // for(GroupMember grpMem : [
        //     SELECT 
        //     UserOrGroupId 
        //     FROM GroupMember 
        //     WHERE GroupId = :queueId
        // ]) {
        for(GroupMember grpMem : (List<GroupMember>) Core_IPS_QueryService.queryRecords(
            'SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queueId',
            new Map<String, Object>{ 'queueId' => queueId }
        )) {
            if(String.valueOf(grpMem.UserOrGroupId).startsWith('00G')){
                userIds.addAll(getUserIdsFromQPB(grpMem.UserOrGroupId));
            } else {
                userIds.add(grpMem.UserOrGroupId);    
            }            
        }    
        return userIds;
    }
    
    /***************************************************************************************************
Method Name : getFAEAffiliatedMapAccounts
Version     : 1.0 
Created Date: 18 Dec 2019
Description : This method takes the MAP Id and QueryString and returns the MAP Accounts or Line Items 
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  18/12/2019           Created for US530013
****************************************************************************************************/  
    @AuraEnabled     
    public static List<sObject> getFAEAffiliatedMapAccounts(String queryString) {
        //SOQL SOSL Injection Fix cannot be done here as it is handled in javascript controller.          
        Set<Id> accountIdSet = new Set<Id>();
        List<sObject> sObjLst = new list<sObject>();
        List<Account> accounts = getFAEAffiliatedAccounts();
        for(Account acc : accounts) {
            accountIdSet.add(acc.Id);
        }
        queryString = queryString + ' AND Core_Account__c IN :accountIdSet ORDER BY LastModifiedDate DESC'; 
        
        // Venrublity Fix - Refering query to service class
        // sObjLst = Database.query(queryString);
        sObjLst = Core_IPS_QueryService.queryRecords(
            queryString,
            new Map<String, Object>{ 'accountIdSet' => accountIdSet }
        );
        return sObjLst;
    } 
    /***************************************************************************************************
Method Name : getLabel
Version     : 1.0 
Created Date: 22 Jan 2020
Description : This method maps API name and value with a map
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ranjini                  22/01/2020           
****************************************************************************************************/  
    @AuraEnabled
    public static Map<String,String> getLabel(String ObjectName, String ApiName){ 
        Schema.DescribeSObjectResult r = Core_IPS_MAP_PAR__c.sObjectType.getDescribe();
        List<String> apiNames =  new list<String>();
        for(string test : r.fields.getMap().keySet()){
            apiNames.add(test);
        }
        Map<String,String> labelList = new Map<String,String>();
        Map<String,String> newlabelMap = new Map<String,String>();
        
        for(String s:apiNames){
            
            String fieldTypeName = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(s).getDescribe().getLabel(); 
            
            
            labelList.put(s,fieldTypeName);
        }
        labelList.put('created','created');
        labelList.put('owner','Owner');  
        return labelList;
    }
    
    public without sharing class AdminOperations {
        public List<Core_IPS_Map_Par_Line_Item__c> updateLineItems(List<Core_IPS_Map_Par_Line_Item__c> mapLineItemList) {
            // Venrublity Fix - Refering query to service class
            // update mapLineItemList;
            mapLineItemList = (List<Core_IPS_Map_Par_Line_Item__c>) Core_IPS_QueryService.updateRecords((List<SObject>) mapLineItemList);
            return mapLineItemList;
        }
        
    }
    
    
     @AuraEnabled
     public static string getCase(Id recordId){
         Case caseRecord=new Case();
         //fix done--suresh on 14/07/2022
         if (Schema.sObjectType.Case.fields.Status.isAccessible()) {
                caseRecord = [Select Id,Status FROM Case WHERE Id = :recordId];
                }
         
          return caseRecord.Status;
     }
      
      @AuraEnabled(cacheable=true)
      public static List<Core_IPS_Case_Attachments__c> getattachments(String caseID){
        List<Core_IPS_Case_Attachments__c> cdoc = new List<Core_IPS_Case_Attachments__c>();
        String strqry = 'SELECT Core_Case__c,Name,Core_Upload_idsid__c,Core_Category__c,Core_Case__r.Status,Core_FileUploadedBy__r.Name,CreatedBy.Name,Core_File_URL__c,Core_File_Hyperlink__c,CreatedDate, Core_File_Description__c, Core_File_Name__c, Core_File_Size__c, Core_Upload_Status__c,Core_IPS_Attachment_Visibility__c FROM Core_IPS_Case_Attachments__c where Core_Case__c =:caseID ORDER BY CreatedDate DESC ';
        // Venrublity Fix - Refering query to service class
        // cdoc = Database.Query(strqry);
        cdoc = (List<Core_IPS_Case_Attachments__c>) Core_IPS_QueryService.queryRecords(
            strqry,
            new Map<String, Object>{ 'caseID' => caseID }
        );
        for(Core_IPS_Case_Attachments__c att:cdoc ){
            if(att.Core_Upload_Status__c == 'Pending'){
                String url = att.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('" target="_blank">Resume</a>', ' ').replace('amp;', '');
                att.Core_File_URL__c = url;
            }
            if(att.Core_Upload_Status__c == 'Complete'){
                String url = att.Core_File_Hyperlink__c;
                url = url.replace('<a href="', '').replace('" target="Self">Download</a>', ' ').replace('amp;', '');
                att.Core_File_URL__c = url;
            }

        }
        return cdoc;
    }
    /*Start -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Case_Interested_Party__c> getInterestedParties(Id caseId) {
        // Venrublity Fix - Refering query to service class
        // return [
        //     SELECT Id, Name, First_Name__c, Last_Name__c, 
        //     User__r.FirstName, User__r.LastName, Active__c
        //     FROM Core_IPS_Case_Interested_Party__c
        //     WHERE Case__c = :caseId
        //     WITH USER_MODE
        //     LIMIT 49999
        // ];
        return (List<Core_IPS_Case_Interested_Party__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Id, Name, First_Name__c, Last_Name__c, User__r.FirstName, User__r.LastName, Active__c FROM Core_IPS_Case_Interested_Party__c WHERE Case__c = :caseId LIMIT 49999',
            new Map<String, Object>{ 'caseId' => caseId }
        );
    }
 	/*END -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
    /*Start -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
    @AuraEnabled(cacheable = true)
    public static List<Core_IPS_Account__c> getProjectsForOpportunity(String recordId, String projStatus) {
        Id oppId = (Id) recordId; // type-safe cast prevents injection via Id format validation
        // Venrublity Fix - Refering query to service class
        // List<Core_IPS_Account__c> results = [
        //     SELECT Core_IPS_Project__r.Name, Core_IPS_Project__r.Id, Core_IPS_Project__r.CreatedDate
        //     FROM Core_IPS_Account__c
        //     WHERE Core_IPS_Project__r.Core_Status__c = :projStatus
        //     AND Core_Account__c IN (SELECT AccountId FROM Opportunity WHERE Id = :oppId)
        //     WITH USER_MODE
        //     ORDER BY Core_IPS_Project__r.CreatedDate DESC
        // ];
        List<Core_IPS_Account__c> results = (List<Core_IPS_Account__c>) Core_IPS_QueryService.queryRecords(
            'SELECT Core_IPS_Project__r.Name, Core_IPS_Project__r.Id, Core_IPS_Project__r.CreatedDate FROM Core_IPS_Account__c WHERE Core_IPS_Project__r.Core_Status__c = :projStatus AND Core_Account__c IN (SELECT AccountId FROM Opportunity WHERE Id = :oppId) ORDER BY Core_IPS_Project__r.CreatedDate DESC',
            new Map<String, Object>{ 'projStatus' => projStatus, 'oppId' => oppId }
        );
        return results;
    }
    /*END -- Tushar -- 12/05/2026 --- added as part of vulnerability fix. */
    @AuraEnabled(cacheable=true)
    public static List<Core_IPS_Supported_Product__c> getSupportedProducts(String searchKey) {
        
        if (String.isBlank(searchKey)) {
            return new List<Core_IPS_Supported_Product__c>();
        }
        
        String searchPattern = '%' + String.escapeSingleQuotes(searchKey.trim()) + '%';
        
        // Venrublity Fix - Refering query to service class
         return [
             SELECT Id,
             Name,
             Core_Supported_Product_Name__c,
             Core_Product_Application__c,
             Core_Support_Org_Name__c
             FROM Core_IPS_Supported_Product__c
             WHERE Core_Flag_Status__c != 'EOIS'
             AND Core_Flag_Status__c != 'Par Hidden'
             AND Core_Supported_Product_Name__c LIKE :searchPattern
             LIMIT 1000
         ];
    }
}