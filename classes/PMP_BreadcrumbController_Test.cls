@isTest
public class PMP_BreadcrumbController_Test {
    
    @testSetup static void testDataFactory() {
        
        //create the test account
        String accountRecordTypeId=PMP_SearchTestDataFactory.intel_Account_Record_Type;
        Account testAccount = new Account(Name = 'testAccount' , RecordTypeId = accountRecordTypeId,Core_Account_Type__c='Other',
                                          BillingCity='Bangalore', BillingCountry='IND', BillingStreet = 'TestStreet');
        
        insert testAccount;
        Id accId = testAccount.id;
        
        //create the partner having account speciality
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        testPartner1.PMP_Account_Region__c = 'EMEA';
        testPartner1.PMP_Account_Sub_Region__c = 'TAIWAN';
        //testPartner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        testPartner1.PMP_Account_Industry__c = 'Energy';
        testPartner1.PMP_Account_Application__c = 'Storage';
        testPartner1.PMP_Partner_Program_nm__c = 'ISA;ODM-LOEM';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
        testPartner1.PMP_Partner_Segment_Nm__c = 'Client Computing';
        insert testPartner1;
        
        //create speciality that the partner belongs to
        PMP_Partner_Specialty__c ps= new PMP_Partner_Specialty__c();
        ps.Name='Artificial Intelligence Specialist';
        ps.PMP_Is_Active_Ind__c= true;
        ps.PMP_Partner_Specialty_English_Dsc__c='Description';
        ps.PMP_Partner_Specialty_Chinese_Nm__c = 'Artificial Intelligence Specialist';
        ps.PMP_Partner_Specialty_Japanese_Nm__c = 'Artificial Intelligence Specialist';
        ps.PMP_Partner_Specialty_Chinese_Dsc__c = 'Artificial Intelligence Specialist';
        ps.PMP_Partner_Specialty_English_Dsc__c = 'Artificial Intelligence Specialist';
        ps.PMP_Partner_Specialty_Japanese_Dsc__c = 'Artificial Intelligence Specialist';
        insert ps;
        
        String partnerspecId = ps.Id;
        Set<String> partnerspecIdSet = new Set<String>();
        partnerspecIdSet.add(partnerspecId);
        
        //create the partner segment records
        PMP_Partner_Segment__c partnerSegment= new PMP_Partner_Segment__c();
        partnerSegment.Name='Client Computing';
        partnerSegment.PMP_Partner_Segment_Value_Txt__c='Client Computing';
        partnerSegment.PMP_Is_Active_Ind__c=true;
        insert partnerSegment;
        
        String partnersegId = partnerSegment.Id;
        Set<String> partnersegIdSet = new Set<String>();
        partnersegIdSet.add(partnersegId);
        //Create MP Event
        PMP_Marketplace_Event__c mpEvent= new PMP_Marketplace_Event__c();
        mpEvent.Name='Intel MP Event';
        mpEvent.PMP_Marketplace_Event_Start_Dt__c=System.now();
        mpEvent.PMP_Marketplace_Event_End_Dt__c=System.now()+1;
        insert mpEvent;
        
        PMP_Specification__c spec = new PMP_Specification__c();
        spec.name= 'Other Processors';
        spec.PMP_Product_Parent_Specification_Id__c = 'NPP_Processors';
        insert spec;    
        
        PMP_Category__c cat = new PMP_Category__c();
        cat.PMP_Active_Ind__c=true;
        cat.PMP_Partner_Product_Category_Cd__c='NPP_01_Industry';
        cat.PMP_Partner_Product_Category_Key__c = 'npp_01_industry';
        cat.PMP_Partner_Product_Parent_Category_Cd__c  ='Solution_Marketplace_Hierarchy';
        cat.Name='Industry';
        insert cat;
        
        PMP_Category__c cat1= new PMP_Category__c();
        cat1.PMP_Active_Ind__c=true;
        cat1.PMP_Partner_Product_Category_Cd__c='IPA_Ind_HealthCare';
        cat1.PMP_Partner_Product_Category_Key__c = 'ipa_ind_healthcare';
        cat1.PMP_Partner_Product_Parent_Category_Cd__c  ='NPP_01_Industry';
        cat1.PMP_Parent_Category_Id__c = cat.Id;
        cat1.Name='Healthcare';
        insert cat1;
        
        PMP_Partner_Program__c partProg = new PMP_Partner_Program__c(Name ='Solution, Software, and Service Providers', PMP_Is_Active_Ind__c = true,
                                                                      PMP_Partner_Program_Value_Txt__c ='Solution, Software, and Service Providers');
        insert partProg;
       
        PMP_Partner_Category__c partCat2 = new PMP_Partner_Category__c(PMP_Category_Id__c=cat1.Id,PMP_Partner_Id__c=testPartner1.Id);
        insert partCat2;
        
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,true,'draft','taglineTest'); 
        offering.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering.PMP_Partner_Offering_Start_Dt__c = System.today().addDays(-2);
        offering.PMP_Partner_Offering_End_Dt__c = System.today().addDays(2);
        update offering;

        
        PMP_Marketplace_Event__c event = new PMP_Marketplace_Event__c(Name='Test Event',PMP_Event_Banner_Language__c='English', PMP_Marketplace_Event_Tagline__c='tag',
                                                                      PMP_Marketplace_Event_Start_Dt__c=System.today(), PMP_Marketplace_Event_End_Dt__c=SYSTEM.today());
        insert event;
        
        PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
        newPMPOfferingCat.Name='HealthCare-in-Industry';
        newPMPOfferingCat.PMP_Offering_Id__c=offering.Id;
        newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_Industry|IPA_Ind_HealthCare';
        newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_01_Industry';
        newPMPOfferingCat.PMP_Category_Id__c = cat1.Id;
        insert newPMPOfferingCat;
        Test.startTest();
        PMP_BreadcrumbController.getPartnerSegment('en_US',partnersegId,partnersegIdSet);
        PMP_BreadcrumbController.getPartnerSpeciality('en_US',partnerspecId,partnerspecIdSet);
        test.stopTest();
    }
    
    @isTest
    public static void getBreadcrumbTest() { 
        test.startTest();
        //String baseURL = System.Label.PMP_Marketplace_Community_URL;
        system.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/offerings-by-category'),'failed');
        
        PMP_Company__c comp = [SELECT Id, Name FROM PMP_Company__c LIMIT 1];
        system.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/partner/' + comp.Id),'failed');
        
        PMP_Partner_Offering__c off = [SELECT Id, Name FROM PMP_Partner_Offering__c LIMIT 1];
        system.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/offering/' + off.Id),'failed');
        PMP_BreadcrumbController.getIntelSolutionsBreadcrumb('en_US', 'https://martketplace.intel.com/s/offering/' + off.Id);
        
        PMP_Marketplace_Event__c evt = [SELECT Id, Name FROM PMP_Marketplace_Event__c LIMIT 1];
        system.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-marketplace-event/' + evt.Id),'failed');
        
        List<PMP_BreadcrumbController.Buttons> buttons = PMP_BreadcrumbController.getButtons('en_US');
        System.assert(buttons.size() > 0, true);
        test.stopTest();
    }
    
    @isTest
    public static void getBreadcrumbTest2() { 
        test.startTest();
        //String baseURL = System.Label.PMP_Marketplace_Community_URL;
        PMP_Category__c cat = [SELECT Id, Name FROM PMP_Category__c WHERE Name = 'Healthcare' LIMIT 1];
        System.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-category/' + cat.Id),'failed');
        System.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-category/' + cat.Id),'failed');
        
        PMP_Partner_Program__c partProg = [SELECT Id, Name FROM PMP_Partner_Program__c LIMIT 1];
        System.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-program/' + partProg.Id),'failed');
        String partnerprog = partProg.Id;
        PMP_BreadcrumbController.getIntelSolutionsBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-program/' + partProg.Id);
        
        PMP_Partner_Segment__c partnerSegment = [SELECT Id, Name FROM PMP_Partner_Segment__c LIMIT 1];
        System.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-segment/' + partnerSegment.Id),'failed');
        
        PMP_Partner_Specialty__c ps = [SELECT Id, Name FROM PMP_Partner_Specialty__c LIMIT 1];
        System.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-specialty/' + ps.Id),'failed');
        System.assertNotEquals(NULL,PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/partners-by-industry/'),'failed');
        PMP_BreadcrumbController.getCategories('en_US', 'NPP_01_Industry');
        PMP_BreadcrumbController.getIntelSolutionsBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-category/' + cat.Id);
        PMP_BreadcrumbController.getBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-category/' + cat.Id);
        PMP_BreadcrumbController.getPartnerIndustry('en_US');
        PMP_BreadcrumbController.getPartnerDirectory('en_US',partnerprog);
        PMP_BreadcrumbController.getIntelSolutionsBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-segment/' + partnerSegment.Id);
        PMP_BreadcrumbController.getIntelSolutionsBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-category/' + cat.Id);
        PMP_BreadcrumbController.getIntelSolutionsBreadcrumb('en_US', 'https://martketplace.intel.com/s/pmp-partner-specialty/' + ps.Id);
        
        test.stopTest();
    }
}