/**************************************************************************************
Apex Class Name:Core_Batch_AccountShare  
Version     : 1.0 
Created Date: 08 Dec 2016
Description : This Batch Iterates on the User and Upserts all the assicoiated user accounts to AccountCoverageExport object
*************************************************************************************/
public class Core_Batch_AccountShare implements Database.Batchable<sObject>{
    Private static final String BATCH_NAME = 'Core_Batch_AccountShare';
    
    public Database.QueryLocator  start(Database.BatchableContext batchcontext) {
        System.debug('+++++++++++++++++ Core_Batch_AccountShare STARTED -----------------');
        Map<Id, User> mapUser  = Core_AccountCoverageExportUtil.getUsers();
        System.debug('#01 mapUser.keyset().size(): ' + mapUser.keyset().size());
        //Reset the Custom Setting to Blank
        Core_AccountCoverageExportUtil.setCustomSettings(BATCH_NAME,'');
        //005g0000003p8dz
        return Database.getQueryLocator([SELECT UserOrGroupId, UserOrGroup.Name, UserOrGroup.Email, AccountId, Account.Name, Account.Core_Account_Legal_Name__c, Account.Core_CIM_ID__c, Account.Core_GEO__c, RowCause FROM AccountShare WHERE UserOrGroupId IN :mapUser.keyset() AND AccountAccessLevel in ('Edit','All') AND Account.Core_B2B_Entitlement__c  = true]);
        //return Database.getQueryLocator([SELECT UserOrGroupId, UserOrGroup.Name, UserOrGroup.Email, AccountId, Account.Name, Account.Core_Account_Legal_Name__c, Account.Core_CIM_ID__c, Account.Core_GEO__c, RowCause FROM AccountShare WHERE UserOrGroupId IN :mapUser.keyset() AND AccountAccessLevel = 'Edit' AND Account.Core_B2B_Entitlement__c  = false]);
  
    }
    
    public void execute(Database.BatchableContext BC, list<AccountShare> aslist){
        System.debug(' Core_Batch_AccountShare Execute Method Invoked  SCOPE Size '+aslist.size());
        List<Core_AccountCoverage_Export__c> listtoUpdate = new List<Core_AccountCoverage_Export__c>();
        Map<String, Core_AccountCoverage_Export__c> mapAC = new Map<String, Core_AccountCoverage_Export__c>();
        if(aslist != null && !aslist.isEmpty()) {
            //declare the User set
            Set<Id> uids = new Set<Id>();
            for(AccountShare listuids:aslist){
                uids.add(listuids.UserOrGroupId);
            }
            //  Set<Id> uids = new Set<User>([Select Id from User Where IsActive = true]); 
            Map<Id, User> uksMap = new Map<Id, User>( [Select Id, Name, Core_User_Country_Code__c, Title, IsActive, Phone, MobilePhone, City, FirstName, LastName, Email, LocaleSidKey,FederationIdentifier, Core_Login_Id__c from User where id IN: uids]);
            
            for(AccountShare listAS:aslist){
                
                Core_AccountCoverage_Export__c ace = new Core_AccountCoverage_Export__c();
                // User Details
                ace.Core_User_Id__c = uksMap.get(listAS.UserOrGroupId).Id;
                ace.Name = uksMap.get(listAS.UserOrGroupId).Name;
                ace.Core_User_Email__c = uksMap.get(listAS.UserOrGroupId).Email;
                ace.Core_User_WWID__c = uksMap.get(listAS.UserOrGroupId).FederationIdentifier;
                ace.Core_Login_Id__c = uksMap.get(listAS.UserOrGroupId).Core_Login_Id__c ;            
                ace.Core_User_First_Name__c = uksMap.get(listAS.UserOrGroupId).FirstName;
                ace.Core_User_Last_Name__c = uksMap.get(listAS.UserOrGroupId).LastName;
                ace.Core_User_Title__c  = uksMap.get(listAS.UserOrGroupId).Title;
                ace.Core_User_Country_Code__c = uksMap.get(listAS.UserOrGroupId).Core_User_Country_Code__c;
                ace.Core_User_IsActive__c = ( (uksMap.get(listAS.UserOrGroupId).IsActive == true) ? 'True' : 'False' );            
                if(String.isBlank(uksMap.get(listAS.UserOrGroupId).Phone))
                {
                    ace.Core_User_Phone__c =uksMap.get(listAS.UserOrGroupId).MobilePhone;
                }
                else{
                    ace.Core_User_Phone__c =uksMap.get(listAS.UserOrGroupId).Phone;
                }
                ace.Core_User_City__c = uksMap.get(listAS.UserOrGroupId).City;
                ace.Core_User_Language_Locale_Key__c  = uksMap.get(listAS.UserOrGroupId).LocaleSidKey;
                
                // Account Details
                ace.Core_Account_Id__c = listAS.AccountId;
                ace.Core_Account_CIMID__c = listAS.Account.Core_CIM_ID__c;
                ace.Core_Account_Geo__c = listAS.Account.Core_GEO__c;
                //    String extid = String.valueOf(listAS.AccountId) + String.valueOf(uksMap.get(listAS.UserOrGroupId).Id);
                String extid = String.valueOf(uksMap.get(listAS.UserOrGroupId).Id) + String.valueOf(listAS.AccountId);
                ace.Core_Ext_Id__c =  extid;
                //ace.Core_Account_Share__c = 'AS';
                ace.Core_Account_Share__c = listAS.RowCause;
                ace.Core_Status__c = 'New';
                //listtoUpdate.add(ace);
                mapAC.put(extid, ace);
            }
            listtoUpdate = mapAC.values();
            Database.upsert(listtoUpdate, Core_AccountCoverage_Export__c.fields.Core_Ext_Id__c);
        }
    }
    public void finish(Database.BatchableContext batchcontext){
        
        Core_AccountCoverageExportUtil.sendNotification(batchcontext, 'Core_Batch_AccountShare');
        
        /*
        if(!Test.isRunningTest() &&  Core_AccountCoverageExportUtil.areAllAccountCoverageBatchesCompleted())
            Database.executeBatch(new Core_Batch_AccountCoverage_Summary(),1500);
        */
        //Database.executeBatch(new Core_Batch_TerritoryManagement(),1);
        Database.executeBatch(new Core_Batch_AccountCoverage_Summary(),1500);
       // Database.executeBatch(new Core_Batch_RoleHierarchy(), 1);
        System.debug('+++++++++++++++++ Core_Batch_AccountShare FINISHED  -----------------');
        
    }
}