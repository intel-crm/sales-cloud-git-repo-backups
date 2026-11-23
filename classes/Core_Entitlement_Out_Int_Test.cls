@isTest
public class Core_Entitlement_Out_Int_Test {
    //public static Integer currentNumber = 1;
	public static testmethod void testGenerateAGSOBM() {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        
        Contact testConObj = createTestContact();
        Contact testOldConObj = testConObj.clone(true, true, true, true);
        
        createTestContactEntitlement(testConObj, 3);
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        testOldConObj.Core_ERPM_Integration_Status__c = 'Pending';
        testOldConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        lstTestContacts.add(testConObj);
        lstOldTestContacts.put(testConObj.Id, testOldConObj);
        
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        
        testConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testConObj.Core_AGS_Integration_Status__c = 'Pending';
        
        testOldConObj.Core_ERPM_Integration_Status__c = 'Successful';
        testOldConObj.Core_AGS_Integration_Status__c = '';
        
        lstTestContacts.add(testConObj);
        lstOldTestContacts.put(testConObj.Id, testOldConObj);
        
        Core_Entitlement_Outbound_Integrations.generateAgsOutboundMessage(lstTestContacts,lstOldTestContacts);
        
    }
    public static testmethod void testGenerateERPMOBM() {
        List<Contact> lstTestContacts = new List<Contact>();
        Map<Id,Contact> lstOldTestContacts = new Map<Id,Contact>();
        Contact testConObj = createTestContact();
        createTestContactEntitlement(testConObj, 3);
        
        lstTestContacts.add(testConObj);
        Test.startTest();
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        Integer currentNumErpmObm = lstIntOBM.size();
        
        System.debug('Zay Inside Test Class Before Reg Test - ' + testConObj);
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts, lstOldTestContacts);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());
        System.debug(lstIntOBM);
              
        createTestSMPContactEntitlement(testConObj, 2);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        currentNumErpmObm = lstIntOBM.size();
        System.debug('Zay Inside Test Class Before SMP Test - ' + testConObj);
        Core_Entitlement_Outbound_Integrations.generateErpmOutboundMessage(lstTestContacts,lstOldTestContacts);
        
        lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='ERPM Contact Entitlement'];
        System.assertEquals(currentNumErpmObm+1, lstIntOBM.size());
        
        Test.stopTest();
        
    }
    public static testmethod void testGenerateBoxBAccountOBM() {
        List<Account> lstAccounts = new List<Account>();
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        
        Account acctObj = createB2BTestAccount();
        Account acctOldObj = acctObj.clone(true,true,true,true);
        
        List<Core_Integration_Outbound_Message__c> lstIntOBM = [Select id, Core_Payload__c, Core_MessageType__c from Core_Integration_Outbound_Message__c where Core_MessageType__c='BoxB Account'];
        
        acctOldObj.Name = 'Old Name';
        
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, mapOldAccounts);
        
        lstAccounts = new List<Account>();
        
        acctObj.Core_Deactivated__c = true;
        acctObj.Name = 'Old Name';
        
        lstAccounts.add(acctObj);
        
        Core_Entitlement_Outbound_Integrations.generateBoxBAccountOutboundMessage(lstAccounts, mapOldAccounts);
      
    }
    public static testmethod void testGenerateERPMOnCIMUpdate() {
        List<Contact> lstTestContacts = new List<Contact>();
        Contact testConObj = createB2BTestContact();
        
        System.debug('Zay Inside Test Class - ' + testConObj.Core_Contact_B2B_Indicator__c);
        createTestContactEntitlement(testConObj, 3);
        
        lstTestContacts.add(testConObj);
        
        List<Account> lstAccounts = new List<Account>();
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        

        Account acctObj = [Select id, Name, Core_CNDA_Number__c, BillingStreet,BillingCity,BillingStateCode,BillingCountryCode,
                           BillingPostalCode,Phone,Core_Account_Legal_Name__c,Core_IsODM__c,Core_B2B_ERPM_Account_Number__c,
                           Core_English_Only_Name__c, Core_Alternate_Language_Name__c, Core_B2B_Entitlement__c,
                           BillingCountry, BillingState, Core_CIM_ID__c from Account where id=:testConObj.AccountId];
        
        Account acctOldObj = new Account();
        acctOldObj = acctObj.clone(true,true,true,true);
        /*acctOldObj.Name = 'Old Outbound Test Account';
        acctOldObj.Core_CNDA_Number__c = '112233445566';
        acctOldObj.BillingStreet = '1234 Tester Account';
        acctOldObj.BillingCity = 'Testing City';
        acctOldObj.BillingStateCode = 'OR';
        acctOldObj.BillingCountryCode = 'USA';
        acctOldObj.BillingPostalCode = '12345';
        acctOldObj.Phone = '1234567890';
        acctOldObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctOldObj.Core_IsODM__c = false;
        acctOldObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctOldObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctOldObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        
        insert acctOldObj;*/
        acctObj.Name = 'New Outbound Test Account';
        
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        
        System.debug('Zay Inside Test Class - ' + testConObj.Core_Contact_B2B_Indicator__c);
		
        Core_Entitlement_Outbound_Integrations.runOnce = false;
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(lstAccounts, mapOldAccounts);
        
        acctOldObj.Name = 'New Outbound Test Account';
        acctObj.Core_English_Only_Name__c = 'New English Only Name Outbound Test Account';
        
        lstAccounts = new List<Account>();
        lstAccounts.add(acctObj);
        mapOldAccounts.put(acctObj.id, acctOldObj);
        Core_Entitlement_Outbound_Integrations.generateOBMOnCIMUpdate(lstAccounts, mapOldAccounts);
    }
    
    public static testmethod void testSmartSplitLogic1() {
        // Scenario 1: String less than partition length
        List<String> stringList = new List<String>();
        String testString = '12345 tester street';
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 125);
        Test.stopTest();
        
        System.assert(stringList.size() == 1);
        
        
        
    }
    
    public static testmethod void testSmartSplitLogic2() {
        // Scenario 2: String greater than partition length
        List<String> stringList = new List<String>();
        String testString = '12345 tester test testing testerino testing street';
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 20);
        Test.stopTest();
        
        System.assert(stringList.size() == 3);
        System.assertEquals(17,stringList[0].length());
        System.assertEquals(17,stringList[1].length());
        System.assertEquals('12345 tester test',stringList[0]);
        System.assertEquals('testing testerino',stringList[1]);
    }
    
    public static testmethod void testSmartSplitLogic3() {
        // Scenario 3: String is null
        List<String> stringList = new List<String>();
        String testString = null;
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 20);
        Test.stopTest();
        
        System.assertEquals(null, stringList);
    }
    public static testmethod void testSmartSplitLogic4() {
        // Scenario 3: String is blank
        List<String> stringList = new List<String>();
        String testString = '';
        
        Test.startTest();
        stringList = Core_Entitlement_Outbound_Integrations.smartSplit(testString, 20);
        Test.stopTest();
        
        System.assertEquals(null, stringList);
    }
    
    public static testmethod void testIsoCountryCodeLogic1() {
        // Scenario 1: No country code custom settings values
        String returnStr = '';
        Test.startTest();
        returnStr = Core_Entitlement_Outbound_Integrations.getISO2CountryCode('ALB');
        Test.stopTest();
        System.assertEquals(null, returnStr);
    }
    
    public static testmethod void testIsoCountryCodeLogic2() {
        // Scenario 2: No matching country codes
        Database.insert(new Core_Country_Code_Mapping__c(Name = 'Albania', Country_Code__c = 'AL', ISO_Code__c='ALB'));
        
        String returnStr = '';
        Test.startTest();
        returnStr = Core_Entitlement_Outbound_Integrations.getISO2CountryCode('USA');
        Test.stopTest();
        System.assertEquals(null, returnStr);
    }
    
    public static testmethod void testIsoCountryCodeLogic3() {
        // Scenario 3: Matching country code
        Database.insert(new Core_Country_Code_Mapping__c(Name = 'Albania', Country_Code__c = 'AL', ISO_Code__c='ALB'));
        
        String returnStr = '';
        Test.startTest();
        returnStr = Core_Entitlement_Outbound_Integrations.getISO2CountryCode('ALB');
        Test.stopTest();
        System.assertEquals('AL', returnStr);
    }
    
    private static List<Core_AGS_Role__c> createTestAGSRole(Integer numOfTestAGSRoles) {
        
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        for(Integer i=0; i<numOfTestAGSRoles; i++) {
            Integer currentNumber = 1;
            Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
            testAGSRole.Name = 'Test AGS Role ' + currentNumber;
            testAGSRole.Core_IsActive__c = true;
            testAGSRole.Core_Technical_Name__c = 'Test AGS Role Tech Name ' + currentNumber;
            lstAGSRoles.add(testAGSRole);
        }
        if(lstAGSRoles.size()>0) {
            insert lstAGSRoles;
            return lstAGSRoles;
        } else {
            return null;
        }
    }
    
    private static List<Core_ERPM_Engagement__c> createTestERPMEngagement(Integer numOfTestERPMEngagements) {
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        for(Integer i = 0; i < numOfTestERPMEngagements; i++) {
            Integer currentNumber = 1;
            Core_ERPM_Engagement__c testERPMEngagement = new Core_ERPM_Engagement__c();
            testERPMEngagement.Name = 'Test ERPM Engagement ' + currentNumber;
            testERPMEngagement.Core_Technical_Engagement_Code__c = 'ENG' + currentNumber;
            testERPMEngagement.Core_Technical_DeDup_Number__c = 'B2B';
            testERPMEngagement.Core_Engagement_Type__c = 'SEC';
            testERPMEngagement.Core_IsActive__c = true;
            lstERPMEngagements.add(testERPMEngagement);
        }
        if(lstERPMEngagements.size()>0) {
            insert lstERPMEngagements;
            return lstERPMEngagements;
        } else {
            return null;
        }
    }
    public static List<Core_Entitlement__c> createTestActiveEntitlementDetail(Integer numOfTestEntitlementDetails) {
        Integer currentNumber = 1;
        
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        
        lstAGSRoles = createTestAGSRole(numOfTestEntitlementDetails);
        lstERPMEngagements = createTestERPMEngagement(numOfTestEntitlementDetails);
        
        for(Integer i = 0; i<numOfTestEntitlementDetails; i++) {
            Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
            testEntitlementDetail.Name = 'Test Entitilement Detail ' + currentNumber;
            testEntitlementDetail.Core_Display_Name__c = 'Entitlement Detail ' + currentNumber;
            testEntitlementDetail.Core_ERPM_Engagement_Id__c = lstERPMEngagements[i].Id;
            testEntitlementDetail.Core_AGS_Role_Id__c = lstAGSRoles[i].Id;
            testEntitlementDetail.Core_IsActive__c = true;
            currentNumber++;
            lstEntitlementDetails.add(testEntitlementDetail);
        }
        if(lstEntitlementDetails.size()>0) {
            insert lstEntitlementDetails;
        }
        return lstEntitlementDetails;
    }
    
    public static Contact createTestContact() {
       
       User u = [select id from user where usertype= 'Standard' AND ISActive=true limit 1];
         Account acctObj = createTestAccount();
    	Contact conObj = new Contact();
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.Core_IPS_Active__c=true;
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.MailingStreet = '1234 Tester St';
        conObj.MailingCity = 'Testing City';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '12345';
        conObj.Phone = '1234567890';
        conObj.MobilePhone = '0987654321';
        conObj.AccountId = acctObj.Id;
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.Core_IPS_Intel_Support_Owner__c = u.id; 
        
        insert conObj;
        
        return conObj;
    }
    public static Account createTestAccount() {
      
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.Phone = '1234567890';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_IPS_Active__c=true;
        
        insert acctObj;
        
        return acctObj;
    }
    
    public static Contact createB2BTestContact() {
        
         User u = [select id from user where usertype= 'Standard' AND ISActive=true limit 1];
        string stdId = [SELECT id from RecordType where Name ='Standard'].Id;
    	Contact conObj = new Contact();
        Account acctObj = createB2BTestAccount();
        conObj.Core_eRPM_Person_Id__c = '111111';
        conObj.Core_Enterprise_Id__c = '123456';
        conObj.Core_IPS_Active__c=true;
        conObj.Core_Login_Id__c = '12355';
        conObj.FirstName = 'Outbound Integrations Tester';
        conObj.LastName = 'Person';
        conObj.Email = 'OITester123@tester.com';
        conObj.Core_English_Only_First_Name__c = 'Outbound Integrations Tester';
        conObj.Core_English_Only_Last_Name__c = 'Person';
        conObj.Core_Do_Not_Contact__c = false;
        conObj.Salutation = 'Mr.';
        conObj.Title = 'OBM Tester';
        conObj.Core_Job_Function__c = 'Information Technology';
        conObj.MailingStreet = '1234 Tester St';
        conObj.MailingCity = 'Testing City';
        conObj.MailingStateCode = 'OR';
        conObj.MailingCountryCode = 'USA';
        conObj.MailingPostalCode = '12345';
        conObj.Phone = '1234567890';
        conObj.MobilePhone = '0987654321';
        conObj.AccountId = acctObj.Id;
        conObj.Core_ERPM_Integration_Status__c = 'Pending';
        conObj.Core_AGS_Integration_Status__c = 'Pending';
        conObj.Core_Contact_B2B_Indicator__c = true;
        conObj.RecordTypeId = stdId;
       conObj.Core_IPS_Intel_Support_Owner__c =u.id;
        
        insert conObj;
        
        return conObj;
    }
    public static Account createB2BTestAccount() {
      
        Account acctObj = new Account();
        acctObj.Name = 'Outbound Test Account';
        acctObj.Core_CNDA_Number__c = '112233445566';
        acctObj.BillingStreet = '1234 Tester Account';
        acctObj.BillingCity = 'Testing City';
        acctObj.BillingStateCode = 'OR';
        acctObj.BillingCountryCode = 'USA';
        acctObj.BillingPostalCode = '12345';
        acctObj.Phone = '1234567890';
        acctObj.Core_Account_Legal_Name__c = 'Outbound Test Account';
        acctObj.Core_IsODM__c = false;
        acctObj.Core_B2B_ERPM_Account_Number__c = 'ERPM1234';
        acctObj.Core_English_Only_Name__c = 'Outbound Test Account';
        acctObj.Core_Alternate_Language_Name__c = 'Alternate Name Account';
        acctObj.Core_B2B_Entitlement__c = true;
        acctObj.Core_Deactivated__c = false;
        acctObj.Core_CIM_ID__c = '123456789';
        acctObj.Core_IPS_Active__c=true;
        
        insert acctObj;
        
        return acctObj;
    }
    
    public static void createTestContactEntitlement(Contact conObj, Integer numTestContactEntitlements) {
        List<Core_Entitlement__c> lstEntitlements = createTestActiveEntitlementDetail(numTestContactEntitlements);
        List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        Boolean selected = true;
        for(Core_Entitlement__c entObj : lstEntitlements) {
            Core_Contact_Entitlement__c ce =
                            new Core_Contact_Entitlement__c(Core_Contact_Id__c=conObj.Id, Core_From_Source__c=true, Core_Selected__c=selected,
                                                            Core_Entitlement_Id__c=entObj.id);
            lstTestContactEntitlementsToInsert.add(ce);
            selected = !selected;
        }
        
        if(lstTestContactEntitlementsToInsert != null && lstTestContactEntitlementsToInsert.size() > 0) {
            insert lstTestContactEntitlementsToInsert;
        }
    }
    
    private static List<Core_AGS_Role__c> createTestSMPAGSRole(Integer numOfTestAGSRoles) {
        
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        for(Integer i=0; i<numOfTestAGSRoles; i++) {
            Integer currentNumber = 1;
            Core_AGS_Role__c testAGSRole = new Core_AGS_Role__c();
            testAGSRole.Name = 'Test SMP AGS Role ' + currentNumber;
            testAGSRole.Core_IsActive__c = true;
            testAGSRole.Core_Technical_Name__c = 'Test SMP AGS Role Tech Name ' + currentNumber;
            lstAGSRoles.add(testAGSRole);
        }
        if(lstAGSRoles.size()>0) {
            insert lstAGSRoles;
            return lstAGSRoles;
        } else {
            return null;
        }
    }
    
    private static List<Core_ERPM_Engagement__c> createTestSMPERPMEngagement(Integer numOfTestERPMEngagements) {
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        for(Integer i = 0; i < numOfTestERPMEngagements; i++) {
            Integer currentNumber = 1;
            Core_ERPM_Engagement__c testERPMEngagement = new Core_ERPM_Engagement__c();
            testERPMEngagement.Name = 'Test SMP ERPM Engagement ' + currentNumber;
            testERPMEngagement.Core_Technical_Engagement_Code__c = 'SMPENG' + currentNumber;
            testERPMEngagement.Core_Technical_DeDup_Number__c = 'B2B';
            testERPMEngagement.Core_Engagement_Type__c = 'SMP';
            testERPMEngagement.Core_IsActive__c = true;
            lstERPMEngagements.add(testERPMEngagement);
        }
        if(lstERPMEngagements.size()>0) {
            insert lstERPMEngagements;
            return lstERPMEngagements;
        } else {
            return null;
        }
    }
    public static List<Core_Entitlement__c> createTestSMPActiveEntitlementDetail(Integer numOfTestEntitlementDetails) {
        Integer currentNumber = 1;
        
        List<Core_Entitlement__c> lstEntitlementDetails = new List<Core_Entitlement__c>();
        List<Core_AGS_Role__c> lstAGSRoles = new List<Core_AGS_Role__c>();
        List<Core_ERPM_Engagement__c> lstERPMEngagements = new List<Core_ERPM_Engagement__c>();
        
        lstAGSRoles = createTestSMPAGSRole(numOfTestEntitlementDetails);
        lstERPMEngagements = createTestSMPERPMEngagement(numOfTestEntitlementDetails);
        
        for(Integer i = 0; i<numOfTestEntitlementDetails; i++) {
            Core_Entitlement__c testEntitlementDetail = new Core_Entitlement__c();
            testEntitlementDetail.Name = 'Test SMP Entitilement Detail ' + currentNumber;
            testEntitlementDetail.Core_Display_Name__c = 'SMP Entitlement Detail ' + currentNumber;
            testEntitlementDetail.Core_ERPM_Engagement_Id__c = lstERPMEngagements[i].Id;
            testEntitlementDetail.Core_AGS_Role_Id__c = lstAGSRoles[i].Id;
            testEntitlementDetail.Core_IsActive__c = true;
            currentNumber++;
            lstEntitlementDetails.add(testEntitlementDetail);
        }
        if(lstEntitlementDetails.size()>0) {
            insert lstEntitlementDetails;
        }
        return lstEntitlementDetails;
    }
    
    public static void createTestSMPContactEntitlement(Contact conObj, Integer numTestContactEntitlements) {
        List<Core_Entitlement__c> lstEntitlements = createTestSMPActiveEntitlementDetail(numTestContactEntitlements);
        List<Core_Contact_Entitlement__c> lstTestContactEntitlementsToInsert = new List<Core_Contact_Entitlement__c>();
        Boolean selected = true;
        for(Core_Entitlement__c entObj : lstEntitlements) {
            Core_Contact_Entitlement__c ce =
                            new Core_Contact_Entitlement__c(Core_Contact_Id__c=conObj.Id, Core_From_Source__c=true, Core_Selected__c=selected,
                                                            Core_Entitlement_Id__c=entObj.id);
            lstTestContactEntitlementsToInsert.add(ce);
            selected = !selected;
        }
        
        if(lstTestContactEntitlementsToInsert != null && lstTestContactEntitlementsToInsert.size() > 0) {
            insert lstTestContactEntitlementsToInsert;
        }
    }
}