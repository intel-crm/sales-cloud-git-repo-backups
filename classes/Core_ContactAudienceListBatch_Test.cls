@isTest
private class Core_ContactAudienceListBatch_Test {
    @testSetup 
    static void setup() {
       
        // Creating Contact
        Account account = new Account(Name ='RaushanTest',Core_Account_Type__c = 'Distributor',Core_Sales_Groups__c= 'CCG Sales Group',
                                      Industry='Agriculture', 	BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi') ;
        Database.insert(account);
        
        // Creating ERPM Engagement
        Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        Database.insert(cee); 
        
		// Creating Contact Records
        Contact contact1 = new Contact(firstname=' Batch1 ', 
                lastname='Test', accountId=account.id,Email='dellco1234@dell.com',Core_Audience_List__c='CCF Activity Submitter');
        insert contact1;
        Contact contact2 = new Contact(firstname=' Batch2 ', 
                lastname='Test', accountId=account.id,Email='dellco3234@dell.com',Core_Audience_List__c='CCF Account Budget Administrator'); 
        insert contact2;
        
        Contact contact3 = new Contact(firstname=' Batch3 ', 
                lastname='Test', accountId=account.id,Email='dellco4234@dell.com',Core_Audience_List__c=' DCF User');
        insert contact3;
 
        Contact contact4 = new Contact(firstname=' Batch4 ', 
                lastname='Test', accountId=account.id,Email='dellco5234@dell.com',Core_Audience_List__c='CCF User');
        insert contact4;
        
        Contact contact5 = new Contact(firstname=' Batch5 ', 
                lastname='Test', accountId=account.id,Email='dellco6234@dell.com',Core_Audience_List__c=null);
        insert contact5;
        
        Contact contact6 = new Contact(firstname=' Batch6 ', 
                lastname='Test', accountId=account.id,Email='dellco7234@dell.com',Core_Audience_List__c='');
        insert contact6;
       	
	   // Creating Entitlement Records
       Core_Entitlement__c entitlement1 = new Core_Entitlement__c(Name='Partner Portal - Leads',
                                                                  Core_Display_Name__c='Partner Portal - Leads',Core_ERPM_Engagement_Id__c=cee.id);
        insert(entitlement1);
        
       Core_Entitlement__c entitlement2 = new Core_Entitlement__c(Name='Partner Portal - IPS',
                                                                  Core_Display_Name__c='Partner Portal - IPS',Core_ERPM_Engagement_Id__c=cee.id);
        insert(entitlement2);
       Core_Entitlement__c entitlement3 = new Core_Entitlement__c(Name='Intel Partner FAE',
                                                                  Core_Display_Name__c='Intel Partner FAE',Core_ERPM_Engagement_Id__c=cee.id);
        insert(entitlement3);
       Core_Entitlement__c entitlement4 = new Core_Entitlement__c(Name='Partner Portal - DDR',
                                                                  Core_Display_Name__c='Partner Portal - DDR',Core_ERPM_Engagement_Id__c=cee.id);
        insert(entitlement4);
        

        // Creating Contact Entitlements
        Core_Contact_Entitlement__c contactEntitlement1 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement1.Id,Core_Contact_Id__c=contact1.Id,
                                                                                          Core_Selected__c=true,Core_Status__c='Complete');
        database.insert(contactEntitlement1);
        
        Core_Contact_Entitlement__c contactEntitlement2 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement1.Id,Core_Contact_Id__c=contact2.Id,
                                                                                          Core_Selected__c=true,Core_Status__c='Complete');
        database.insert(contactEntitlement2);
        
        Core_Contact_Entitlement__c contactEntitlement3 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement3.Id,Core_Contact_Id__c=contact3.Id,
                                                                                          Core_Selected__c=true,Core_Status__c='Complete');
        database.insert(contactEntitlement3);
        
        Core_Contact_Entitlement__c contactEntitlement4 = new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement4.Id,Core_Contact_Id__c=contact4.Id,
                                                                                          Core_Selected__c=true,Core_Status__c='Complete');
        
        //database.insert(contactEntitlement4);
        
        Core_Contact_Entitlement__c contactEntitlement5 = new Core_Contact_Entitlement__c(Core_Entitlement_Id__c=entitlement4.Id,Core_Contact_Id__c=contact5.Id,
                                                                                          Core_Selected__c=true,Core_Status__c='Complete');
        //insert(contactEntitlement5);
        
        Core_Contact_Entitlement__c contactEntitlement6 = 
            new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement2.Id,Core_Contact_Id__c=contact1.Id,
            Core_Selected__c=true,Core_Status__c='Complete');
        
        database.insert(contactEntitlement6);
        
		/*Core_Contact_Entitlement__c contactEntitlement7 = 
            new Core_Contact_Entitlement__c (Core_Entitlement_Id__c=entitlement2.Id,Core_Contact_Id__c=contact6.Id,
            Core_Selected__c=true,Core_Status__c='Complete');
        
        database.insert(contactEntitlement7);*/    
        
    }
        
    // Executing test method for audience list population
    static testmethod void test(){
        Test.startTest();
        Core_ContactAudienceListBatch contactAudience = new Core_ContactAudienceListBatch();
        
        System.runAs(new user(ID = UserInfo.getUserID())){
        	Id batchId = Database.executeBatch(contactAudience);
        }
        Test.stopTest();
        System.assertEquals(1, [select count() from contact where Core_Audience_List__c='CCF User']);
    }

}