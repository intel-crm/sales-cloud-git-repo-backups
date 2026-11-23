public class Core_A_E_TestDataUtility {
    
    public static Id intel_Contact_Record_Type = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();

        public static User createUser(Boolean isInsert){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test',
                                 UserPermissionsMarketingUser = TRUE);
        if(isInsert){
            insert testUser;
        }
        return testUser;
        
    }
    public static Contact createContact(Id accountId,Boolean isInsert){
        Contact testContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='testcontact'+String.valueOf(Math.random())+'@CoreA_E.com',
                                          AccountId=accountId,RecordTypeId=intel_Contact_Record_Type);       
        if(isInsert){
            insert testContact;
        }
        
        return testContact;
    }
    public static PermissionSet createPermSet(String name,String label,Boolean isInsert){
        PermissionSet testPS = new PermissionSet(Name = name,Label = label);
        if(isInsert){
            insert testPS;
        }       
        return testPS;
    }
}