/****************************************************************************************************************************************
* Class Name  : Core_ExternalUser_IPS_Project_Helper 
* Version     : 1.0 
* Created Date: 5 Oct 2017
* Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: PopcornApps         10/9/2017               Helper Class to create Premier Support Projects As IPS EXternal Customer 
*****************************************************************************************************************************************/
public class Core_ExternalUser_IPS_Project_Helper {
    //Create an IPS Account 
    public static void createAccountOnProjectCreationForExternalCustomer(Map<Id,Core_IPS_Project__c> projectMap, User loggerInUser){
        
        if(projectMap.values()!=null && projectMap.values().size()>0){ 
            try{
                
                Set <id> userCreatedByIds = new Set<id>();
                List<Core_IPS_Account__c> lstCoreIpsAccount = new List<Core_IPS_Account__c>();
                List<Core_IPS_Project_Member__c> lstCoreIipsProjectrojectMembers = new List<Core_IPS_Project_Member__c>();
                for(Id coreips :projectMap.keyset()){ 
                    if (projectMap.get(coreips) != null){
                        Core_IPS_Account__c ipsAcc = new Core_IPS_Account__c();
                        /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_IPS_Project__c.isCreateable()) {
                            ipsAcc.Core_IPS_Project__c = coreips;
                        } 
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Status__c.isCreateable()) {
                            ipsAcc.Core_Status__c = 'Active';
                        } 
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Members__c.isCreateable()) {
                            ipsAcc.Core_Members__c ='Selective';
                        } 
                        if (Schema.sObjectType.Core_IPS_Account__c.fields.Core_Account__c.isCreateable()) {
                            ipsAcc.Core_Account__c = loggerInUser.Contact.AccountId;
                        }
                        lstCoreIpsAccount.add(ipsAcc);
                        
                        Core_IPS_Project_Member__c coreMember = new Core_IPS_Project_Member__c();
                        /*US1021248 - 05/28/2021 - Vishal - FLS Check for security vulnerability --*/
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Project__c.isCreateable()) {
                            coreMember.Core_IPS_Project__c = coreips;
                        }
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_Selective_Member__c.isCreateable()) {
                            coreMember.Core_Selective_Member__c = true;
                        }
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_IPS_Contact__c.isCreateable()) {
                            coreMember.Core_IPS_Contact__c = loggerInUser.ContactId;
                        }
                        if (Schema.sObjectType.Core_IPS_Project_Member__c.fields.Core_User__c.isCreateable()) {
                            coreMember.Core_User__c = loggerInUser.Id;
                        } 
                        lstCoreIipsProjectrojectMembers.add(coreMember);
                    }
                    
                }
                Database.insert( lstCoreIpsAccount,false);
                Database.insert( lstCoreIipsProjectrojectMembers,false);                
            }catch(exception ex){
                String exceptionMessage = ex.getTypeName() + ': ' + ex.getMessage() + ', ' + ex.getStackTraceString();
                // inserting the Error into LogEntry object        
                Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_ExternalUser_IPS_Project_Controller','GroupMember');        
            }
        }
    }
    
    
    //Get the List of Existing Members in a Project
    public static Map<Id, Id> getExistingMembers(String ipsProjectId){
        Map<Id, Id> mContId_IipsProjectrojMembId = new Map<Id, Id>();
        for(Core_IPS_Project_Member__c pm : [Select Id, Core_IPS_Contact__c ,Core_IPS_Project__c  FROM Core_IPS_Project_Member__c 
                                             WHERE Core_IPS_Project__c =:ipsProjectId ])
        {
            mContId_IipsProjectrojMembId.put(pm.Core_IPS_Contact__c, pm.Id);
        }
        return  mContId_IipsProjectrojMembId;
    }
    
    //Query to check if there are already exising assets which are in active
    public static Map<Id, Asset> getExistingAssets(String ipsProjectId){
        Map<Id, Asset> mSuppProd_Asset = new Map<Id, Asset>();
        for( Asset asst : [Select Id, Core_Supported_Product__c, Core_Project_Asset_Status__c, UsageEndDate 
                           FROM Asset WHERE Core_Project_Asset_Status__c = 'InActive' AND Core_IPS_Project__c =: ipsProjectId])
        {
            mSuppProd_Asset.put(asst.Core_Supported_Product__c, asst);
        }
        return mSuppProd_Asset;
        
    }
    //Get all Inactive Products
    public static Map<Id, Core_IPS_Product__c> getAllInActiveIPSProducts(String ipsProjectId){
        Map<Id, Core_IPS_Product__c> mSuppProd_IPSProduct = new Map<Id, Core_IPS_Product__c>();
        for(Core_IPS_Product__c prod : [Select Id, Name, Core_IPS_Project__c, Core_Supported_Product__c FROM  Core_IPS_Product__c 
                                        Where Core_IPS_Project__c =: ipsProjectId AND Core_IPS_Product_Status__c ='InActive']){
                                            mSuppProd_IPSProduct.put(prod.Core_Supported_Product__c, prod);
                                        }
        return mSuppProd_IPSProduct;
    }
    //Get User RecordID of the Contact
    public static Map<Id,Id> getContactUserRecordIds(Set<Id> sid){
        Map<Id,Id> mContId_UserId = new Map<Id,Id>();
        for(User u :[Select Id, ContactId FROM User where ContactId IN : sid])
            mContId_UserId.put(u.ContactId, u.Id);
        return mContId_UserId;
    } 
}