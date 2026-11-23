@isTest public class SKPOC_TestPermissionset {
    
    
    private static final String v1_0 = 'v1.0';
    private static User commUser1  = null;
    private static User commUser2  = null;
    private static User commUser3_NoCases  = null;
    private static User adminUser  = null;
    
    //Case object for api assertion for getDetail service
    private static Case caseObj = null;
    
    //Setup the data required for tesing the use cases
    @testSetup public static void setupData(){
        
        adminUser = [Select Id FROM User where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        Test.startTest();
        System.runAs(adminUser){
            String accName = 'RestApiUnitTest';
            Integer noOfAccounts = 1;
            Integer noOfIPSContacts = 3;
            Integer noOfNonIPSContacts = 1;
            Integer noOfCommUsers = 3;
            String communityProfileName = 'IPS External Customer';
            Integer noOfAssets = 0; //Not needed for this testing
            TestUtilities.getCustomerUsersWithAccountsAndContacts(accName, noOfAccounts, noOfIPSContacts, noOfNonIPSContacts,noOfCommUsers, communityProfileName, noOfAssets);
        }
        List<User> allCommUsers = [Select Name, ContactId FROM User WHERE ContactId IN (Select Id FROM Contact) ];
        List<Contact> allIPSContacts = [Select Name, Core_IPS_Active__c FROM Contact] ;
        List<Account> allAccounts = [Select Name FROM Account];
        Contact nonIpsContact = [Select Name, Core_IPS_Active__c FROM Contact where Core_IPS_Active__c = false Limit 1] ;
        
        System.debug(' Core_RestAPI_Cases_Test \n Account '+allAccounts+'\n IPS Contacts '+allIPSContacts +'\n Non Contact '+nonIpsContact + ' \n All CommUsers '+allCommUsers);
        
        commUser1 = allCommUsers[0];
        commUser2 = allCommUsers[1];
        System.debug(' \n allCommUsers  '+allCommUsers);
        
        
        System.runAs(adminUser){
            List<Case> caseList = TestUtilities.getListOfCases(25);
            //Assign 5 cases for admin User with blank contact id
            for(Integer i = 0;i<5;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
                c.ContactId = null;
            }
            //Assign 5 cases for nonIPs Contact
            for(Integer i =5;i<10;i++){
                Case c = caseList[i];
                c.OwnerId = adminUser.Id;
                c.ContactId = nonIpsContact.id;
                c.AccountId = allAccounts[0].id;
            }
            //Assign 5 cases CommUser1 with the user contact Id
            for(Integer i =10;i<15;i++){
                Case c = caseList[i];
                c.OwnerId = commUser1.Id;
                c.ContactId = commUser1.ContactId;
                c.AccountId = allAccounts[0].id;
            }
            //Assign 5 cases for commUser1 with the another contact Id
            for(Integer i = 15;i<20;i++){
                Case c = caseList[i];
                c.OwnerId = commUser1.Id;
                c.ContactId = nonIpsContact.Id;
                c.AccountId = allAccounts[0].id;
            }
            
            //Assign 5 cases for commUser2
            for(Integer i = 20;i<25;i++){
                Case c = caseList[i];
                c.OwnerId = commUser2.Id;
                c.AccountId = allAccounts[0].id;
            }
            insert caseList;
            
            
            
            //Insert environment variables for the case
            List<Core_IPS_Environment_Details__c> envDet = TestUtilities.getEnvironmentDetailResponses(5);
            System.debug(' envDet '+envDet);
            for(Integer i=0 ;i< envDet.size();i++){
                Core_IPS_Environment_Details__c env = envDet[i];
                env.Core_Case__c = caseList[i+5].id;
                System.debug('+++++++ ENV Details '+env.Core_Case__c);
            }
            insert envDet;
            //TODO remove the below for loop
            for(Case c: [Select Id, Account.Name, Contact.Name, Owner.Name, Core_IPSPortal_Check__c from Case]){
                System.debug('+++++++ Account'+c.Account.Name+'>> Contact : '+c.contact.Name+'>> Owner '+c.Owner.Name+'>> Core_IPSPortal_Check__c '+c.Core_IPSPortal_Check__c);
            }
            
            System.debug('\n +++++++ ENV Details '+[Select Id, Name from Core_IPS_Environment_Details__c]);
            
            PermissionSet ps = [SELECT ID, name From PermissionSet WHERE Name = 'Core_IPS_Permission_Set'];
            system.debug(' Permissoin set Obj '+ps);
            insert new PermissionSetAssignment(AssigneeId = commUser1.id, PermissionSetId = ps.Id );
        }
        Test.stopTest();
    }
    
    public  static testmethod void testrun(){
        System.debug(' Testing ');
    }
    
    
}