/*****************************************************************************************************************************************
* Class Name  : Core_IPS_Account_Trigger_Handler 
*
* Modification Log :
* Developer                 Date            Description
* ----------------------------------------------------------------------------
* Accenture-VD              23/7/2018       US99134 Stop Outbound messages to CIM and EPRM for Virtual Accounts
                                            Updated Below Methods to stop creating OutBound message for Co-Marketing Record Type of Account 
                                            -restrictManageExternalAccount
                                            -assignEntitlementToIPSAccount
                                            -UpdateContactOnECBCheck
                                            -revokeAccess
                                            -grantAccess
*****************************************************************************************************************************************/

public class Core_IPS_Account_Trigger_Handler{
     
    public static Id coMarketingRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Core_MDF_Co_Marketing_Record_Type_Name).getRecordTypeId(); //Added by Accenture - VD -> Check if the record type is not Co-Marketing
    /***************************************************************************************************** 
    Method Name:                                             assignEntitlementToIPSAccount
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
    public static void assignEntitlementToIPSAccount(Map<Id,Account> oldMap,List<Account> newList){
        /*List<Entitlement> entList = new List<Entitlement>();
        
        //added by amritesh 4/26/2018 US104230 - start
        String entitlementExpiryYearStr = System.Label.Core_IPS_Account_Entitlement_Expiry_Year;
        Integer entitlementExpiryYearInt;
        if(String.isBlank(entitlementExpiryYearStr) || (!entitlementExpiryYearStr.isNumeric())) entitlementExpiryYearInt = Date.Today().year() + 5;
        else entitlementExpiryYearInt = Integer.valueOf(entitlementExpiryYearStr);
        //added by amritesh 4/26/2018 US104230 - end
        
        //Added null check by sonali as test class was failing.
        if(newList != null && !newList.isEmpty()){
            for(Account acc: newList)
            {
                System.debug('RecordTypeId>>>'+acc.RecordTypeId);
                if(acc.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                {
                    System.debug('oldMap Val:--'+oldMap.get(acc.id));
                    if(acc.Core_IPS_Active__c && oldMap.get(acc.id) != null && acc.Core_IPS_Active__c <> oldMap.get(acc.id).Core_IPS_Active__c){
                        
                        Entitlement ent = new Entitlement();
                        ent.Name = Core_IPS_Helper_utility.getIPSLabel('IPS Standard Entitlement');
                        if(Test.isRunningTest()==false)
                        {
                            ent.slaprocessid=Core_IPS_Helper_utility.getIPSLabel('IPS Standard Entitlement Process ID');
                        }
                        ent.startDate = System.today();
                        //ent.endDate = system.today()+730;
                        ent.endDate = Date.newInstance(entitlementExpiryYearInt,12,31); //added by amritesh 4/26/2018 US104230
                        ent.accountid=acc.id;
                        ent.type=Core_IPS_Helper_utility.getIPSLabel('Entitlement Type');
                        entList.add(ent);
                    }
                }
            }
        }
        
        if(entList.size()>0)
            insert entList;*/
    }
    
     /***************************************************************************************************** 
    Method Name:                                             revokeAccess
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
    public static void revokeAccess(List<Account> newList,Map<Id,Account> oldMap){
        
        Map<Id,Id> ownerIdbyAccId = new Map<Id,Id>();
        Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
        
        if(oldMap <> null && oldMap.size() > 0){
            for(Account acc: newList)
            {
                if(acc.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                {                
                    if(oldMap <> null && oldMap.size() > 0 && acc.Core_IPS_Active__c == True && acc.OwnerId <> oldMap.get(acc.Id).OwnerId)
                        ownerIdbyAccId.put(acc.Id,oldMap.get(acc.Id).OwnerId);
                }
            }
        }            
        if(ownerIdbyAccId <> null && ownerIdbyAccId.size() > 0){
            Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(ownerIdbyAccId.keyset());
            //system.debug('#######'+assetIdsbyAccountId.size()+assetIdsbyAccountId);
            
            Set<Id> userSet1;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0 && assetIdsbyAccountId.get(accId) <> null && assetIdsbyAccountId.get(accId).size() > 0){
                    for(Id astId : assetIdsbyAccountId.get(accId)){
                        userSet1 = new Set<Id>();
                        userSet1.add(ownerIdbyAccId.get(accId));
                        userIdsbyAssetId.put(astId,userSet1);
                    }
                }
            }
            Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet2;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(parsbyAccountId <> null && parsbyAccountId.size() > 0 && parsbyAccountId.get(accId) <> null && parsbyAccountId.get(accId).size() > 0){    
                    for(Id parsId: parsbyAccountId.get(accId)){
                        userSet2 = new Set<Id>();
                        userSet2.add(ownerIdbyAccId.get(accId));
                        userIdsbyParsId.put(parsId,userSet2);
                    }
                }
            }
            
            
            Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(ownerIdbyAccId.keyset());
            system.debug('#######'+projectIdsbyAccountId.size()+projectIdsbyAccountId);            
            
            Set<Id> userSet3;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId: projectIdsbyAccountId.get(accId)){
                        userSet3 = new Set<Id>();
                        userSet3.add(ownerIdbyAccId.get(accId));
                        userIdsbyProjectId.put(projId,userSet3);
                    }
                }
            }
            
            Set<Id> projIdSet = new Set<Id>();            
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        projIdSet.add(projId);
                    }
                }
            }            
            
            Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(projIdSet);            
            
            Set<Id> userSet4;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projId) <> null && assetIdsbyProjectId.get(projId).size() > 0){
                            for(Id astId: assetIdsbyProjectId.get(projId)){
                                userSet4 = new Set<Id>();
                                userSet4.add(ownerIdbyAccId.get(accId));
                                userIdsbyAssetId.put(astId,userSet4);
                            }
                        }
                    }
                }
            }            
            
            if(userIdsbyAssetId <> null && userIdsbyAssetId.size() > 0){
                //System.debug('#####revokeAccess For Asset#####'+userIdsbyAssetId.size()+userIdsbyAssetId);
                Core_SharingUtility.revokeAccess('Asset','AssetShare',userIdsbyAssetId);
            }
            if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0){
                //System.debug('#####revokeAccess For Project#####'+userIdsbyProjectId.size()+userIdsbyProjectId);                    
                Core_SharingUtility.revokeAccess('Core_IPS_Project__c','Core_IPS_Project__Share',userIdsbyProjectId);
                //Core_SharingUtility.revokeProjectAccess(userIdsbyProjectId);
            }
            if(userIdsbyParsId <> null && userIdsbyParsId.size() > 0){
                //System.debug('#####RevokeAccess For PARS#####'+userIdsbyParsId.size()+userIdsbyParsId);
                Core_SharingUtility.revokeAccess('Core_IPS_MAP_PAR__c','Core_IPS_MAP_PAR__Share',userIdsbyParsId);
            }            
        }                               
    }
    
    /***************************************************************************************************** 
    Method Name:                                             grantAccess
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
    public static void grantAccess(List<Account> newList,Map<Id,Account> oldMap){
        Map<Id,Id> ownerIdbyAccId = new Map<Id,Id>();
        Map<Id,Set<Id>> userIdsbyAssetId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyProjectId = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> userIdsbyParsId = new Map<Id,Set<Id>>();
        
        
        if(oldMap <> null && oldMap.size() > 0)
        {
            for(Account acc: newList)
            {
                if(acc.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
                {                
                    if(oldMap <> null && oldMap.size() > 0 && acc.Core_IPS_Active__c == True && acc.OwnerId <> oldMap.get(acc.Id).OwnerId)
                        ownerIdbyAccId.put(acc.Id,acc.OwnerId);
                }
            }
        }        
        
        if(ownerIdbyAccId <> null && ownerIdbyAccId.size() > 0){
            Map<Id,Set<Id>> assetIdsbyAccountId = Core_IPS_Helper_Utility.getAssetsByAccountId(ownerIdbyAccId.keyset());
            //system.debug('#######'+assetIdsbyAccountId.size()+assetIdsbyAccountId);
            
            Set<Id> userSet1;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(assetIdsbyAccountId <> null && assetIdsbyAccountId.size() > 0 && assetIdsbyAccountId.get(accId) <> null && assetIdsbyAccountId.get(accId).size() > 0){
                    for(Id astId : assetIdsbyAccountId.get(accId)){
                        userSet1 = new Set<Id>();
                        userSet1.add(ownerIdbyAccId.get(accId));
                        userIdsbyAssetId.put(astId,userSet1);
                    }
                }
            }
            Map<Id,Set<Id>> parsbyAccountId = Core_IPS_Helper_Utility.getPARsByAccountId(ownerIdbyAccId.keyset());
            
            Set<Id> userSet2;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(parsbyAccountId <> null && parsbyAccountId.size() > 0 && parsbyAccountId.get(accId) <> null && parsbyAccountId.get(accId).size() > 0){    
                    for(Id parsId: parsbyAccountId.get(accId)){
                        userSet2 = new Set<Id>();
                        userSet2.add(ownerIdbyAccId.get(accId));
                        userIdsbyParsId.put(parsId,userSet2);
                    }
                }
            }
            
            
            Map<Id,Set<Id>> projectIdsbyAccountId = Core_IPS_Helper_Utility.getProjectsByAccountId(ownerIdbyAccId.keyset());
            //system.debug('#######'+projectIdsbyAccountId.size()+projectIdsbyAccountId);            
            
            Set<Id> userSet3;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId: projectIdsbyAccountId.get(accId)){
                        userSet3 = new Set<Id>();
                        userSet3.add(ownerIdbyAccId.get(accId));
                        userIdsbyProjectId.put(projId,userSet3);
                    }
                }
            }
            
            Set<Id> projIdSet = new Set<Id>();            
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        projIdSet.add(projId);
                    }
                }
            }            
            
            Map<Id,Set<Id>> assetIdsbyProjectId = Core_IPS_Helper_Utility.getAssetsByProjectId(projIdSet);            
            
            Set<Id> userSet4;
            for(Id accId : ownerIdbyAccId.keyset()){
                if(projectIdsbyAccountId <> null && projectIdsbyAccountId.size() > 0 && projectIdsbyAccountId.get(accId) <> null && projectIdsbyAccountId.get(accId).size() > 0){
                    for(Id projId : projectIdsbyAccountId.get(accId)){
                        if(assetIdsbyProjectId <> null && assetIdsbyProjectId.size() > 0 && assetIdsbyProjectId.get(projId) <> null && assetIdsbyProjectId.get(projId).size() > 0){
                            for(Id astId: assetIdsbyProjectId.get(projId)){
                                userSet4 = new Set<Id>();
                                userSet4.add(ownerIdbyAccId.get(accId));
                                userIdsbyAssetId.put(astId,userSet4);
                            }
                        }
                    }
                }
            }            
            
            if(userIdsbyAssetId <> null && userIdsbyAssetId.size() > 0){
                //System.debug('#####Provide Access For Asset#####'+userIdsbyAssetId.size()+userIdsbyAssetId);
                Core_SharingUtility.provideAccess('Asset','AssetShare','Read',userIdsbyAssetId);
            }
            if(userIdsbyProjectId <> null && userIdsbyProjectId.size() > 0){
                //System.debug('#####ProvideAccess For Project#####'+userIdsbyProjectId.size()+userIdsbyProjectId);
                Core_SharingUtility.provideAccess('Core_IPS_Project__c','Core_IPS_Project__Share','Read',userIdsbyProjectId);
            }
            if(userIdsbyParsId <> null && userIdsbyParsId.size() > 0){
                //System.debug('#####ProvideAccess For PARS#####'+userIdsbyParsId.size()+userIdsbyParsId);
                Core_SharingUtility.provideAccess('Core_IPS_MAP_PAR__c','Core_IPS_MAP_PAR__Share','Read',userIdsbyParsId);
            }            
        }                               
    }
    
     /***************************************************************************************************
    Version     : 1.0 
    Created Date: 07 March 2016
    Function    : 
    Input Parameters: newList and OldMap 
    Output Parameters: None
    Transactions: Before Update
    Description: This method is used to restrict Users to change from Partner->Customer/Customer->Partner Account.
    Used in     : Core_Account
    Number of Queries Within this Method : 1
    Number of Queries in Loop : 0
    Number of Queries from Called methods : 0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                             Date                   Description
    * ----------------------------------------------------------------------------                 
    * Abhishek Arya                        03/07/2016              Created
    ****************************************************************************************************/
     /***************************************************************************************************** 
    Method Name:                                             restrictManageExternalAccount
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
    public static void restrictManageExternalAccount(List<Account> newList,Map<Id,Account> oldMap){
        
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String myProflieName = PROFILE[0].Name;
        Boolean isProfileRestricted = true;
        for(String profileName : Label.Core_Admin_Profile_Names.split(',')){
            if(myProflieName == profileName){
                isProfileRestricted = false;
            }
        }
        
        Map<string,Core_IPS_Error_Code__c> mapCodes = Core_IPS_Error_Code__c.getAll();          
        // display the Error Message for G115
        //System.debug('Error Message: '+mapCodes.get('G115').Core_Error_Message__c);

        for(Account acn:newList)
        {
            if(acn.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
            {
                if(isProfileRestricted && ((acn.IsCustomerPortal <> null && acn.IsCustomerPortal <> oldMap.get(acn.Id).IsCustomerPortal) || (acn.IsPartner <> null && acn.IsPartner <> oldMap.get(acn.Id).IsPartner)))
                    acn.addError(mapCodes.get('G115').Core_Error_Message__c);
            }
        }    
    }
    
    /***********************************************************************************************
    Version     : 1.0 
    Created Date: 09 Oct 2015
    Function    : User Story# US36728 : This method executes when Account field named "Export Compliance Block" is true then make IPS Active field on related Contacts to false.
    Input Parameters: Case Old Map, Case New List
    Output Parameters: None
    Transactions: After Insert, After Update
    Description: This method executes when Export Compliance Block =  true as follows:
                 Take respected contact and update Field IPS Active = false
                 
    Used in     : Core_CaseTrigger_Dispatcher
    Number of Queries Within this Method: 1(one per transaction)
    Number of Queries in Loop: 0
    Number of Queries from Called methods:0
    Number of times called: Once for trigger execution
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani              15/03/2016              Created
    * Abhishek Arya               16/03/2016              Modified
    ****************************************************************************************************/
    /***************************************************************************************************** 
    Method Name:                                             UpdateContactOnECBCheck
    @return  :                                               Void
    Modified By:                            Date:            Changes: 
    Accenture – VD                          07/23/2018       US99134 - Updated Method to stop creating OutBound message for Co-Marketing Record Type of Account 
    ******************************************************************************************************/
    public static void UpdateContactOnECBCheck(List<Account> newList,Map<id,Account> MapOldAccount){
        Set<Id> accountIdSet = new Set<Id>();
        //account Id is collected
        for(Account accObj:newList)
        {
            if(accObj.RecordTypeId != coMarketingRecordTypeId) //Added by Accenture - VD -> Check if the record type is not Co-Marketing
            {            
                 if((MapOldAccount !=null && MapOldAccount.get(accObj.id).Core_Export_Compliance_Block__c != accObj.Core_Export_Compliance_Block__c && accObj.Core_Export_Compliance_Block__c) || (MapOldAccount == null && accObj.Core_Export_Compliance_Block__c))
                 {
                  accountIdSet.add(accObj.Id);
                 }
            }
         
        }
        
        //Take respected contact
        Map<Id,Contact> mapContact = new Map<Id,Contact>([Select id,Core_IPS_Active__c,Core_IPS_By_Pass_Validation__c,AccountId from Contact where AccountId in :accountIdSet]);
        System.debug(mapContact);
        
        if(mapContact <> null && mapContact.size() > 0 && mapContact.keyset() <> null){
            //update the respected contact data        
            for(Id ContactId:mapContact.keyset()){               
               mapContact.get(ContactId).Core_IPS_Active__c = false;
               mapContact.get(ContactId).Core_IPS_By_Pass_Validation__c = true;        
            }
            if(mapContact.Values() <> null && mapContact.Values().size() > 0)
            {
                try{
                    update mapContact.Values();  
                }catch(DMLException e){
                    Core_Exceptionclass Exce =  new Core_Exceptionclass();
                    string  Str = Exce.InsertException('','Core_IPS_Account_Trigger_Handler','Account','','UpdateContactOnECBCheck',e);
                    system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>' + Str);
                    System.debug('Error:In Catch:'+e);            
                }         
            }
        }        
    }
    
}