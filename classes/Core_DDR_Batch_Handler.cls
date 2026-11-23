public with sharing class Core_DDR_Batch_Handler{
    
    public static void processAfterInsert(List<Core_Design_Registration_Batch__c> newDR_Stage, List<Core_Design_Registration_Batch__c> oldDR_Stage){
        designRegBatchShare((List<Core_Design_Registration_Batch__c>) newDR_Stage);
    }
    
    public static void designRegBatchShare(List<Core_Design_Registration_Batch__c> newDR_Stagelst){
        
        //Create a set for Roles
        Set<id> userRoleSet = new Set<id>();
        List<Core_Design_Registration_Batch__c> designRegBatchRoleList = [select id, Core_Partner_Account_Id__c, owner.UserRoleId from Core_Design_Registration_Batch__c where id IN: newDR_Stagelst];
        
        Set<Id> setPartnerAccIds = new Set<Id>();
        for(Core_Design_Registration_Batch__c iDesign : designRegBatchRoleList)
        {
            if(iDesign.Core_Partner_Account_Id__c != NULL)
                setPartnerAccIds.add(iDesign.Core_Partner_Account_Id__c);    
        }
        
        List<User> lstUser = new List<User>();
        Map<Id, User> mapPartnerAccountIdToUserId = new Map<Id, User>();
        
        lstUser = [SELECT Id, UserRoleId, Contact.Account.Id FROM User WHERE UserRoleId != NULL AND Contact.Account.Id IN: setPartnerAccIds];
        
        for(User iUser : lstUser){mapPartnerAccountIdToUserId.put(iUser.Contact.Account.Id, iUser);    
        }
        
        for(Core_Design_Registration_Batch__c designRegBatchRole: designRegBatchRoleList){
            if(mapPartnerAccountIdToUserId.containsKey(designRegBatchRole.Core_Partner_Account_Id__c) && mapPartnerAccountIdToUserId.get(designRegBatchRole.Core_Partner_Account_Id__c).UserRoleId != NULL){userRoleSet.add(mapPartnerAccountIdToUserId.get(designRegBatchRole.Core_Partner_Account_Id__c).UserRoleId);
            //system.debug('Role id'+designRegBatchRole.owner.UserRoleId);
            }
        }
        
        //Get the Group Id
        List<Group> roleGroup = [SELECT Id, RelatedId, Type FROM Group WHERE RelatedId IN: userRoleSet and type = 'role'];
        
        Map<id, id> roleAndGroupMap = new Map<id, id>();
        
        for(group grp: roleGroup){roleAndGroupMap.put(grp.RelatedId, grp.id);
        }
        
        // Create a new list of sharing objects for Design Registration
        List<Core_Design_Registration_Batch__Share> designRegBatchShrs  = new List<Core_Design_Registration_Batch__Share>();
        
        // Declare variables for Design Registration sharing
        Core_Design_Registration_Batch__Share designRolebatchShr;
        
        for(Core_Design_Registration_Batch__c designRegBatchShr : designRegBatchRoleList){
            // Instantiate the sharing objects
            designRolebatchShr = new Core_Design_Registration_Batch__Share();
            
            // Set the ID of record being shared
            designRolebatchShr.ParentId = designRegBatchShr.Id;
            
            if(mapPartnerAccountIdToUserId.containsKey(designRegBatchShr.Core_Partner_Account_Id__c) && mapPartnerAccountIdToUserId.get(designRegBatchShr.Core_Partner_Account_Id__c).UserRoleId != NULL && roleAndGroupMap.containsKey(mapPartnerAccountIdToUserId.get(designRegBatchShr.Core_Partner_Account_Id__c).UserRoleId))
            {
                // Set the ID of user or group being granted access
                designRolebatchShr.UserOrGroupId = roleAndGroupMap.get(mapPartnerAccountIdToUserId.get(designRegBatchShr.Core_Partner_Account_Id__c).UserRoleId);//'00Gg0000002taQY';
            }
            
            // Set the access level
            designRolebatchShr.AccessLevel = 'edit';
            
            // Set the Apex sharing 
            designRolebatchShr.RowCause = 'Manual';
            designRegBatchShrs.add(designRolebatchShr);
        }
        
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(designRegBatchShrs,false);
        
    }
}