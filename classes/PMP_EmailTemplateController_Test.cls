@isTest
private class PMP_EmailTemplateController_Test {
    
    @isTest static void setup(){
        
        Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        
		Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
        
        
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
        
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , true);
        
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Approved';
        testPartner1.PMP_Is_Published_Ind__c=false;
        testPartner1.PMP_Is_Working_Copy_Ind__c=true;
        update testPartner1; 
        
       
        
        Test.startTest();
        PMP_EmailTemplateController ctrl=new PMP_EmailTemplateController();
         ctrl.headerMessage = 'Offering Submitted Successfully';
        PMP_Company__c  existingPartner = [Select Id from PMP_Company__c where name='testPartner1' ];
        ctrl.partnerId = existingPartner.Id; 
        PMP_Company__c partner = ctrl.getPartnerData();
        System.AssertNotEquals(partner.Id,null);
        
        
        PMP_EmailTemplateController ctrl1=new PMP_EmailTemplateController();
        PMP_Company__c partner1 = ctrl1.getPartnerData();
        ctrl1.partnerId = NULL;
        Test.stopTest();
        
        
        
    }
    
    
    
    @isTest static void setupCatch(){
        
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
        
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , true);
        
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Approved';
        testPartner1.PMP_Is_Published_Ind__c=false;
        testPartner1.PMP_Is_Working_Copy_Ind__c=true;
        
        Test.startTest();
        
        
         PMP_EmailTemplateController ctrl1=new PMP_EmailTemplateController();
         ctrl1.headerMessage = 'Offering Submitted Successfully';
        PMP_Company__c  existingPartner = [Select Id from PMP_Company__c where name= 'testPartner1' ];
        ctrl1.partnerId = existingPartner.Id; 
        PMP_Company__c partner = ctrl1.getPartnerData();
        System.AssertNotEquals(partner.Id,null);
        String communityURL =ctrl1.getCommunityURL();
		System.AssertNotEquals(communityURL,null);
        
       /* PMP_EmailTemplateController ctrl=new PMP_EmailTemplateController();
         PMP_Company__c partner = ctrl.getPartnerData();
        System.AssertNotEquals(partner.Id,null); */
        Test.stopTest();
         }

    
    

}