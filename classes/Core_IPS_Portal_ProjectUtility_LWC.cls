/***************************************************************************************************
Apex Class Name:  Core_IPS_Portal_ProjectUtility_LWC 
Version     : 1.0 
Created Date: 13 Nov 2021
Function    : To differentiate the with and with out sharing classes from Core_IPS_Portal_Project_Controller
Test Class  : Core_IPS_Portal_Project_Controller_Test 
Modification Log :
* Developer                    Date                    Description
* ----------------------------------------------------------------------------                 
* Shruti Hasilkar              25/04/2022               Created
* Vishal Suryavanshi       15/04/2022         Updated  
****************************************************************************************************/
public without sharing class Core_IPS_Portal_ProjectUtility_LWC {
    /** Author: Shruti Hasilkar
* Date: 19/4/2022
* Description: Add or Remove the Product from the Dual box.
*/
    public static  User loggedInUser;
    
    @AuraEnabled
    public static string addOrRemoveProducts(List<ID> initialIds, List<ID> selectedIds, String projID){
        String message;
        try{
            List<Id> addIdList = new List<Id>();
            List<Id> removeIdList = new List<Id>();
            if(selectedIds.size() > initialIds.size()){
                for(ID ids:selectedIds){
                    if(!initialIds.contains(ids)){
                        addIdList.add(ids);
                    }
                }
            }
            if(addIdList.size()>0){
                List<Core_IPS_Product__c> addIPSProdList = upsertIPSProducts(addIdList,projID);
                if(addIPSProdList.size()>0){
                    message = 'Success';
                }
            }
            if(selectedIds.size() < initialIds.size()){
                for(ID ids2: initialIds){
                    if(!selectedIds.contains(ids2)){
                        removeIdList.add(ids2);
                    }
                }
            }
            if(removeIdList.size()>0){
                List<Core_IPS_Product__c> removedIPSProdList = removeIPSProductsfromProj(removeIdList,projID);
                if(removedIPSProdList.size()>0){
                    message = 'Success';
                }
            }
        }catch(Exception e){
            message = e.getMessage();
        }   
        
        return message;
    }
    
    /** Author: Shruti Hasilkar
* Date: 20/4/2022
* Description: Upsert the IPS Products.
*/
    @AuraEnabled
    public static  List<Core_IPS_Product__c> upsertIPSProducts(List<Id> selectedIdsInThirdPage, string ipsProject){
        
        Set<ID> supProdIDSet = new Set<ID>();
        List<Core_IPS_Product__c> lIPSProducts = new List<Core_IPS_Product__c>();
        /*FLS Read fix  13/05/2022 */
        List<Asset> asstList=new List<Asset>();
        if (Schema.sObjectType.Asset.isAccessible()){
            asstList = [SELECT ID, Name , Core_Supported_Product__c FROM Asset WHERE ID IN:selectedIdsInThirdPage];
        }
        Map<Id,Asset> MapofIdAsset = new Map<Id,Asset>();
        Map<Id,Id> mapOfAstSupProd = new Map<Id,Id>();
        for(Asset ast: asstList){
            supProdIDSet.add(ast.Core_Supported_Product__c);
            MapofIdAsset.put(ast.ID, ast);
            mapOfAstSupProd.put(ast.ID, ast.Core_Supported_Product__c);
            
        }
        /*FLS Read fix  13/05/2022 */
        List<Core_IPS_Product__c> IPSProdList=new List<Core_IPS_Product__c>();
        if (Schema.sObjectType.Core_IPS_Product__c.isAccessible()){
            IPSProdList = [SELECT Id, name, Core_Supported_Product__c FROM Core_IPS_Product__c WHERE Core_Supported_Product__c IN :supProdIDSet and Core_IPS_Project__c = :ipsProject];
        }
        /* removal of the exisitng asset from that map.*/
        List<ID> asstIDs = new List<ID>();
        for(ID idKeys: mapOfAstSupProd.keySet()){
            for(Core_IPS_Product__c coreIPS: IPSProdList){
                if(coreIPS.Core_Supported_Product__c == mapOfAstSupProd.get(idKeys)){
                    asstIDs.add(idKeys); 
                }
            }
        }
        
        List<Id> ipsProdTocreateList = new List<Id>();
        if(asstIDs != null){
            for(ID ids2: selectedIdsInThirdPage){
                if(!asstIDs.contains(ids2)){
                    ipsProdTocreateList.add(ids2);
                }
            }
        }
        /*id-- FLS Read fix FP 13/05/2022 */
        Id IPSProductBasicRecordType = [SELECT Id FROM RecordType where SobjectType = 'Core_IPS_Product__c' AND DeveloperName = 'Core_IPS_Project_Product'].Id;
        
        if(ipsProdTocreateList.size()>0){
            for(Id Assetid : ipsProdTocreateList){
                Core_IPS_Product__c prod = new Core_IPS_Product__c();
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Project__c.isupdateable()){
                    prod.Core_IPS_Project__c = ipsProject;
                }
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_Supported_Product__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Core_Supported_Product__c.isupdateable())
                {
                    prod.Core_Supported_Product__c = MapofIdAsset.get(Assetid).Core_Supported_Product__c;
                }
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isupdateable())
                {
                    prod.Core_IPS_Product_Status__c ='Active';
                }
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Status__c.isupdateable())
                {
                    prod.Status__c = 'Approved';
                }
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_IsAutoApprove__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_IsAutoApprove__c.isupdateable())
                {
                    prod.Core_IPS_IsAutoApprove__c = true;
                }
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_Intel_Product__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Core_Intel_Product__c.isupdateable())
                {
                    prod.Core_Intel_Product__c  = Assetid;
                }
                if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IsSubmitted_Header__c.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.Core_IsSubmitted_Header__c.isupdateable())
                {
                    prod.Core_IsSubmitted_Header__c = true;
                }
                //Fix done--Suresh--15/07/2022
                if (Schema.sObjectType.Core_IPS_Product__c.fields.RecordTypeId.isCreateable()||Schema.sObjectType.Core_IPS_Product__c.fields.RecordTypeId.isupdateable())
                {
                    prod.RecordTypeId  = IPSProductBasicRecordType;
                }
                lIPSProducts.add(prod);
            }
        }
        if(IPSProdList.size()>0){
            for(Core_IPS_Product__c cp: IPSProdList){
                Core_IPS_Product__c IPSProd = new Core_IPS_Product__c();
                IPSProd.ID = cp.ID;
                if(Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isupdateable()){
                    IPSProd.Core_IPS_Product_Status__c ='Active';
                }
                lIPSProducts.add(IPSProd);
            }
        }
        
        if(lIPSProducts != null && lIPSProducts.size()>0){
            upsert lIPSProducts;
        }
        if(lIPSProducts.size()!=null){
            updateAssertsStatus(lIPSProducts,ipsProject);
        }    
        return lIPSProducts;
    }
	public static  void updateAssertsStatus(List<Core_IPS_Product__c> lIPSProducts, string ipsProject){
        Map<Id, Core_IPS_Product__c> ipsProdMap;
        List <Asset> lAssetsToActivate = new List<Asset>();  
        Set<Id> ipsSupProdIdSet = new Set<Id>();
        if(lIPSProducts!=null) {
            Map<Id,Core_IPS_Product__c> ipsProdMapNew =  new Map<Id,Core_IPS_Product__c>();
            ipsProdMapNew.putAll(lIPSProducts); 
           if(Core_IPS_Product__c.SObjectType.getDescribe().isAccessible()){
            ipsProdMap = new Map<Id, Core_IPS_Product__c>([SELECT Name,Id,Core_Supported_Product__R.Id,Core_Intel_Product__C FROM Core_IPS_Product__c WHERE Id IN :ipsProdMapNew.keySet()]);
            }
            for(Id ipsProdId : ipsProdMap.keySet()) {
                ipsSupProdIdSet.add(ipsProdMap.get(ipsProdId).Core_Supported_Product__R.Id);
            }
            Map<Id, Asset> assetMap = new Map<Id, Asset>([SELECT Id, Status, UsageEndDate, Core_Supported_Product__R.Id FROM Asset WHERE Core_Supported_Product__R.Id IN:ipsSupProdIdSet AND Core_IPS_Project__R.Id =:ipsProject]);
            Map<Id, Asset> supProdAssetMap = new Map<Id, Asset>();
            for(Id assetId : assetMap.keySet()) {
                supProdAssetMap.put(assetMap.get(assetId).Core_Supported_Product__R.Id, assetMap.get(assetId) );
            }
            
            for(Id ipsProdId : ipsProdMap.keySet()) {
                Asset assetActivate = supProdAssetMap.get(ipsProdMap.get(ipsProdId).Core_Supported_Product__R.Id);
                if (Schema.sObjectType.Asset.fields.Status.isCreateable() || Schema.sObjectType.Asset.fields.Status.isUpdateable()) { //FLS Create/Update added -Gangadhar 29/09/2023
                	assetActivate.Status = 'Active';
                }
                lAssetsToActivate.add(assetActivate);
            }
            
        }
        if(lAssetsToActivate != null && !lAssetsToActivate.isEmpty()){
            upsert lAssetsToActivate;
        }
       
    }
    
    /** Author: Shruti Hasilkar
* Date: 20/4/2022
* Description: Update the IPS Products to Inactive stage.
*/
    @AuraEnabled
    public static  List<Core_IPS_Product__c> removeIPSProductsfromProj(list<Id> selectedIdsInThirdPage, string ipsProject){
        List<Core_IPS_Product__c> lIPSProducts = new List<Core_IPS_Product__c>();
        Set<ID> supProdIDSet = new Set<ID>();
        /*FLS Read fix  13/05/2022 */
        List<Asset> asstList=new List<Asset>();
        if (Schema.sObjectType.Asset.isAccessible())
        {
            asstList = [SELECT ID, Name , Core_Supported_Product__c FROM Asset WHERE ID IN:selectedIdsInThirdPage];
        }
        
        for(Asset ast: asstList){
            supProdIDSet.add(ast.Core_Supported_Product__c);
        }
        /*FLS Read fix  13/05/2022 */
        List<Core_IPS_Product__c> IPSProdList=new List<Core_IPS_Product__c>();
        if (Schema.sObjectType.Core_IPS_Product__c.isAccessible())
        {
            IPSProdList = [SELECT Id,name FROM Core_IPS_Product__c WHERE Core_Supported_Product__c IN :supProdIDSet and Core_IPS_Project__c = :ipsProject];
        }
        
        for(Core_IPS_Product__c cp: IPSProdList){
            Core_IPS_Product__c IPSProd = new Core_IPS_Product__c();
            IPSProd.ID = cp.ID;
            if (Schema.sObjectType.Core_IPS_Product__c.fields.Core_IPS_Product_Status__c.isUpdateable()) {
                IPSProd.Core_IPS_Product_Status__c ='InActive';
            }
            
            lIPSProducts.add(IPSProd);
        }
        
        if(lIPSProducts != null){
            update lIPSProducts;
        }
        
        return lIPSProducts;
    }
    
    /** Author: Shruti Hasilkar
* Date: 20/4/2022
* Description: Update the Project member status as Active.
*/
    @AuraEnabled
    public static string addOrRemoveProjMembers(List<ID> initialProjMemIds, List<ID> selectedProMemIds, String projID){
        String message;
        try{
            
            List<Id> addIdList = new List<Id>();
            List<Id> removeIdList = new List<Id>();
            if(selectedProMemIds.size() > initialProjMemIds.size()){
                for(ID ids:selectedProMemIds){
                    if(!initialProjMemIds.contains(ids)){
                        addIdList.add(ids);
                    }
                }
            }
            if(addIdList.size()>0){
                List<Core_IPS_Project_Member__c> addIPSProjMemList = addProjectMem(addIdList,projID);
                if(addIPSProjMemList.size()>0){
                    message = 'Success';
                }
            }
            if(selectedProMemIds.size() < initialProjMemIds.size()){
                for(ID ids2: initialProjMemIds){
                    if(!selectedProMemIds.contains(ids2)){
                        removeIdList.add(ids2);
                    }
                }
            }
            if(removeIdList.size()>0){
                List<Core_IPS_Project_Member__c> removedIPSProjMemList = removeProjectMem(removeIdList,projID);
                if(removedIPSProjMemList.size()>0){
                    message = 'Success';
                }
            }
        }catch(Exception e){
            message = e.getMessage();
        }   
        
        return message;    
    }
    
    /** Author: Shruti Hasilkar
* Date: 21/4/2022
* Description: Update the Project member status as Active.
*/
    
    public static List<Core_IPS_Project_Member__c> addProjectMem(List<Id> addList, String projId){
        List<Core_IPS_Project_Member__c> lProjMembers = new List<Core_IPS_Project_Member__c>();
        List<Core_IPS_Project_Member__c> projMemList=new List<Core_IPS_Project_Member__c>();
        if (Schema.sObjectType.Core_IPS_Project_Member__c.isAccessible())
        {
            projMemList = [SELECT ID, Core_Status__c, Core_IPS_Contact__c, Core_IPS_Project__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Contact__c IN :addList AND Core_IPS_Project__c = :projId];
        }
        List<Id> contactIdList = new List<Id>();
        if(projMemList.size()>0){
            for(Core_IPS_Project_Member__c proMem: projMemList){
                contactIdList.add(proMem.Core_IPS_Contact__c);
            }
        }
        List<Id> projMemNeedToCreateList = new List<Id>();
        if(contactIdList != null){
            for(ID ids2: addList){
                if(!contactIdList.contains(ids2)){
                    projMemNeedToCreateList.add(ids2);
                }
            }
        }
        User loggedInUser=new User();
        loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
        Map<Id, Id> contactUserMap = new Map<Id,Id>();
        List<User> userList  = [SELECT ID, ContactID FROM User WHERE ContactID IN :projMemNeedToCreateList];
        for(User us: userList){
            contactUserMap.put(us.ContactID, us.Id);
        }
        for(Id memberId : projMemNeedToCreateList ){
            Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isupdateable())
            {
                pm.Core_IPS_Contact__c = memberId;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isupdateable())
            {
                pm.Core_Selective_Member__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable())
            {
                pm.Core_Status__c = 'Active';
            }
            //Fix done --Suresh --15/07/22
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isupdateable())
            {
                pm.Core_User__c = contactUserMap.get(memberId);
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isupdateable())
            {
                pm.Core_IPS_Project__c = projId;
            }
            lProjMembers.add(pm);
        }
        
        if(projMemList.size()>0){
            for(Core_IPS_Project_Member__c proMem: projMemList){
                Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
                pm.ID = proMem.ID;
                //Fix done --Suresh --15/07/22
                if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable())
                {
                    pm.Core_Status__c = 'Active';
                }
                lProjMembers.add(pm);
            }
        }
        
        if(lProjMembers != null){
            upsert lProjMembers;
        }
        return lProjMembers;
    }
    
    /** Author: Shruti Hasilkar
* Date: 21/4/2022
* Description: Update the Project member status as Inactive.
*/
    
    public static List<Core_IPS_Project_Member__c> removeProjectMem(List<Id> removeList, String projId){
        List<Core_IPS_Project_Member__c> projMemList = new List<Core_IPS_Project_Member__c>();
        projMemList = [SELECT ID, Core_Status__c, Core_IPS_Project__c, Core_IPS_Contact__c FROM Core_IPS_Project_Member__c WHERE Core_IPS_Contact__c IN :removeList AND Core_IPS_Project__c = :projId];
        if(projMemList.size()>0){
            for(Core_IPS_Project_Member__c proMem: projMemList){
                if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable())
                {
                    proMem.Core_Status__c = 'Inactive';
                }
                
            }
            
            update projMemList;
        }
        return projMemList;
    }
    
    @AuraEnabled
    public static string getOwnerOfProject(String projId){
        User us;
        /*FLS Read fix  13/05/2022 */
        Core_IPS_Project__c ipsProj=new Core_IPS_Project__c();
        ipsProj = [SELECT Owner.ID FROM Core_IPS_Project__c WHERE id = :projId];
        if(ipsProj.Owner.ID != null || ipsProj.Owner.ID != ''){
            us = [SELECT ContactID FROM User WHERE ID = :ipsProj.Owner.ID];
        }
        if(us != null){
            return us.ContactID;
        }else{
            return '';
        }
        
    }
    
    //This method get called while Editing Project
    @AuraEnabled(cacheable=true)
    public static  List<Core_IPS_Product__c> existingIPSProducts(String projIdfromJS){
        String prodId = String.escapeSingleQuotes(projIdfromJS);
        List<Core_IPS_Product__c> sobjListEprdos;
        try {
            User loggedInUser=new User();
            loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
            String loggedInUserAcctId = loggedInUser.Contact.AccountId;
            String loggedInUserContId = loggedInUser.ContactId ;
            String query = null;
             // SOQL Injection Fix - Start -  Shipra
             Map<String, Object> bindMap = new Map<String, Object>{'status' => 'ACTIVE','productId' => (prodId == null ? '' :prodId)  };

            query = 'Select Name, Core_Supported_Product_Name__c,Core_IPS_Product_Status__c, Core_Intel_Product__c,Product_Application__c, Core_Supported_Product__c  '+
                'FROM Core_IPS_Product__c where Core_IPS_Product_Status__c = :status AND  Core_IPS_Project__c = :productId';
            
            sobjListEprdos = Database.queryWithBinds(query,bindMap,AccessLevel.USER_MODE);
            // SOQL Injection Fix - End -  Shipra 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return sobjListEprdos;
    }
    
    
    //This method get called while Editing Project
    @AuraEnabled
    public static List<Core_IPS_Project_Member__c> existingProjectMembers(String projIdfromJS){
        String prodId = String.escapeSingleQuotes(projIdfromJS);
        List<Core_IPS_Project_Member__c> sobjListPM;
        try {
            Core_IPS_Project__c  ipsProject = new Core_IPS_Project__c();
            User loggedInUser=new User();
            loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
            String loggedInUserAcctId = loggedInUser.Contact.AccountId;
            String loggedInUserContId = loggedInUser.ContactId ;
            String query = null;
             // SOQL Injection Fix - Start -  Shipra
             Map<String, Object> bindMap = new Map<String, Object>{'status' => 'ACTIVE','productId' => (prodId == null ? '' :prodId), 'loggedInUserAcctId'=>loggedInUserAcctId  };
            
            query = 'Select Id,Core_IPS_Contact__c,Core_Status__c,Core_IPS_Contact__r.FirstName,Core_IPS_Contact_Account__c, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Account.Name '+
                ' FROM Core_IPS_Project_Member__c WHERE  Core_Status__c = :status AND  Core_IPS_Contact__r.AccountId  = :loggedInUserAcctId  AND Core_IPS_Project__c = :productId';
            
            sobjListPM = Database.queryWithBinds(query,bindMap,AccessLevel.USER_MODE);
             // SOQL Injection Fix - End -  Shipra
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return sobjListPM;
    }
    
    /** Author: Vishal Suryavanshi
* Date: 15/07/2022
* Description: Edit Project functionality
*/
    @AuraEnabled 
    public static Core_IPS_Project__c editProjectRecord(String newprojRecordId,Core_IPS_Project__c projectData){
        Core_IPS_Project__c projObj = new Core_IPS_Project__c();
        projObj.Id = projectData.Id; 
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Name.isupdateable()) 
        {
            projObj.Name =  projectData.Name;
        }
        
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Project_Description__c.isupdateable()) 
        {
            projObj.Core_Project_Description__c =  projectData.Core_Project_Description__c;
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_Status__c.isupdateable()) 
        {
            projObj.Core_Status__c =  projectData.Core_Status__c;
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_MPNDA__c.isupdateable()) 
        {
            projObj.Core_MPNDA__c =  projectData.Core_MPNDA__c; 
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Remove_Notification_Details__c.isupdateable()) 
        {
            projObj.Core_IPS_Remove_Notification_Details__c =  projectData.Core_IPS_Remove_Notification_Details__c; 
        }
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_EnableMemberasInterestedParties__c.isupdateable()) 
        {
            projObj.Core_IPS_EnableMemberasInterestedParties__c =  projectData.Core_IPS_EnableMemberasInterestedParties__c; 
        }
        
        update projObj; 
        return projObj;
    }
    @AuraEnabled
    public static  List<Core_IPS_Project_Member__c> upsertProjectMembers(list<Id> selectedIdsInsecondPage, string ipsProject){
        loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
        List<Core_IPS_Project_Member__c> lProjMembers = new List<Core_IPS_Project_Member__c>();
        Map<Id, Id> contactUserMap = new Map<Id,Id>();
        List<User> userList = new List<User>();
        if(selectedIdsInsecondPage != null){
         userList  = [SELECT ID, ContactID FROM User WHERE ContactID IN :selectedIdsInsecondPage];
        }
        for(User us: userList){
            contactUserMap.put(us.ContactID, us.Id);
        }
        for(Id memberId : selectedIdsInsecondPage ){
            Core_IPS_Project_Member__c pm = new Core_IPS_Project_Member__c();
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isupdateable()) 
            {
                pm.Core_IPS_Contact__c = memberId;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isupdateable()) 
            {
                pm.Core_Selective_Member__c = true;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable()) 
            {
                pm.Core_Status__c = 'Active';
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Status__c.isupdateable()) 
            {
                pm.Core_User__c = contactUserMap.get(memberId);//loggedInUser.Id;
            }
            if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()||Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isupdateable()) 
            {
                pm.Core_IPS_Project__c = ipsProject;
            }
            lProjMembers.add(pm);
        }
        
        //Adding all the project memners at once in portal project creation to add group members in a single transaction - Added by Pavani
        Core_IPS_Project_Member__c coreMember = new Core_IPS_Project_Member__c();
        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()) 
        {
            coreMember.Core_IPS_Project__c = ipsProject;
        }
        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()) 
        {
            coreMember.Core_Selective_Member__c = true;
        }
        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()) 
        {
            coreMember.Core_IPS_Contact__c = loggedInUser.ContactId;
        }
        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()) 
        {
            coreMember.Core_User__c = loggedInUser.Id;
        }
        lProjMembers.add(coreMember);
        // End by Pavani
        
        if(lProjMembers != null){
            upsert lProjMembers;
        }
        return lProjMembers;
    }
    
    
}