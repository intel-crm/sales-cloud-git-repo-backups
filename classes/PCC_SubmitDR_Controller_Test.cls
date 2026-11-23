@isTest
public class PCC_SubmitDR_Controller_Test {

    @testSetup
    static void testSetUp(){
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
         Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        Account a2 = PRM_TestUtility.getAccount();
        a2.RecordTypeId = accountRecordTypeIntel;
        a2.Name='New Account';
        a2.Core_Account_Type__c ='Distributor';
        a2.Industry='Agriculture';
        a2.BillingCity='Goa';
        a2.BillingCountryCode='IND';
        a2.BillingStreet='4th Floor,New Road';
        a2.BillingPostalCode='110065';
        a2.BillingStateCode='KA';
        a2.Core_IPA_Partner_Role__c = 'Service Provider';
        a2.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        a2.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert a2;
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a2.Id;
        c1.Email='test.user@intel.com';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_IPA_Partner_Role__c = 'Service Provider';
        c1.MailingCountry='USA';
        c1.Email = 'test.diqhwqi@test.com';
        insert c1;
        
        Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
        ee.Name = 'Intel Partner Alliance';
        ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
        ee.Core_Engagement_Type__c = 'SEC';
        insert ee;
        
        Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
        ed1.Name='Employee';
        ed1.Core_Display_Name__c='Employee';
        ed1.Core_ERPM_Engagement_Id__c=ee.id;
        insert ed1;
        
        Core_Contact_Entitlement__c cce=new Core_Contact_Entitlement__c(); // Contact Entitlement
        cce.Core_Contact_Id__c=c1.Id;
        cce.Core_Entitlement_Id__c = ed1.id;
        cce.Core_Status__c='Complete';
        cce.Core_Selected__c = true;
        cce.Core_Source__c = 'Entitlement';
        insert cce;
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Partner Covers Customer (PCC)';
        cp.IsActive  = true;
        insert cp;
        Product2 pr = new Product2();
        pr.Name = 'Test data 1';
        pr.IsActive = true;
        pr.Core_Design_Registration_Eligible_Ind__c = true;
        pr.Core_Avail_for_New_Designs__c = true;
        pr.Core_Sales_Visible_Flag__c = true;
        insert pr;
        
        Core_Design_Registration__c ddrRec = new  Core_Design_Registration__c();
        ddrRec.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec.Core_Vertical_Market_Nm__c='Education';
        ddrRec.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec.PCC_End_Customer_Country__c='India';
        ddrRec.Core_End_Customer_Country_Nm__c='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec.Core_Production_End_Dt__c = system.today()+22;
        ddrRec.Core_Intel_Platform_Nm__c='AMSTON LAKE';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec.Core_End_Customer_URL__c = 'Test';
        ddrRec.Core_Design_Registration_Status_Nm__c ='Draft';
        insert ddrRec; 
        
        Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
        ddrRec1.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec1.Core_Vertical_Market_Nm__c='Education';
        ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec1.PCC_End_Customer_Country__c='India';
        ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='AMSTON LAKE';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test11.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        ddrRec1.Core_Design_Registration_Status_Nm__c ='submitted';
        insert ddrRec1;
        /*Core_Design_Registration__c ddrRec1 = new  Core_Design_Registration__c();
        ddrRec1.Core_Product_Group_Nm__c = 'Embedded/IOT';
        ddrRec1.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec1.Core_Vertical_Market_Nm__c='Education';
        ddrRec1.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec1.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec1.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec1.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec1.Core_Partner_FSR_Nm__c='Test FSR';
        ddrRec1.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec1.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec1.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec1.Core_End_Customer_Country_Nm__c='India';
        ddrRec1.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec1.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec1.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec1.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec1.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec1.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec1.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec1.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec1.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec1.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec1.Core_Production_End_Dt__c = system.today()+22;
        ddrRec1.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec1.Core_Design_Registration_Nm__c='Test DR Name Arrow';
        ddrRec1.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec1.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec1.Core_End_Customer_URL__c = 'Test';
        ddrRec1.Core_Design_Registration_Status_Nm__c ='Draft';
        insert ddrRec1; */
        
        Product_MM_Attribute_Mapping__c pmam = new Product_MM_Attribute_Mapping__c();
        pmam.Ordering_Code__c = 'WX80660E52630V4';
        pmam.Name = '949344';
        pmam.MMID__c = '949344';
        pmam.L4_Product__c = pr.Id;
        insert pmam;
        
        Core_Design_Registration_Product__c DRproducts = new Core_Design_Registration_Product__c();
        DRproducts.Core_Design_Registration_Id__c = ddrRec.id;
        DRproducts.Core_Product_Id__c = pr.Id;
        DRproducts.Core_Target_Resale_Amt__c = 20;
        DRproducts.Core_Full_Year_Qty__c = 3;
        DRproducts.Core_Design_Product_Status_Nm__c = 'Pending';
        DRproducts.Core_External_Id__c = 'shs002ABCD12LLLL';
        insert DRproducts;
    }
    
    @isTest 
    static void testdrp() {
        list<Core_Design_Registration__c> drList = [select id,Core_Product_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Workflow_Status__c from Core_Design_Registration__c limit 1];
        boolean productAvail = PCC_Submit_DesignRegistrationController.productsAvailableonDr(drList[0].id);
        System.assertEquals(true, productAvail, 'Products should be available');
 		//throw new StringException('Exception added');
    }
    @isTest
    static void testddr(){
        list<Core_Design_Registration__c> drList = [select id,Core_Product_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Workflow_Status__c from Core_Design_Registration__c limit 1];
        PCC_Submit_DesignRegistrationController.logictochangestatus(drList[0].id);
        System.assertEquals('Draft', drList[0].Core_Design_Registration_Status_Nm__c, 'Products should be available');
		
    }
    @isTest
    static void testdrstatus(){
        list<Core_Design_Registration__c> drList = [select id,Core_Product_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Workflow_Status__c from Core_Design_Registration__c limit 1];
        boolean status = PCC_Submit_DesignRegistrationController.getDRStatus(drList[0].id);
        System.assertEquals(true, status, 'Products should be available');
    }
    /*@isTest
    static void testdrstatusCatch(){
        list<Core_Design_Registration__c> drList = [select id,Core_Product_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Workflow_Status__c,DDR_Partner_FAE_Email__c from Core_Design_Registration__c where DDR_Partner_FAE_Email__c = 'test11.diqhwqi@test.com' limit 1];
        boolean status = PCC_Submit_DesignRegistrationController.getDRStatus(drList[0].id);
        
        System.assertEquals(true, status, 'Products should be available');
    }*/
    /*@isTest
    static void testChangeStatus() {
        // Create a Design Registration in Draft status
        Core_Design_Registration__c designRegistration = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Status_Nm__c = 'Draft'
            // Add other required fields here
        );
        insert designRegistration;

        // Call the method to change status, force an exception by passing an invalid ID
        Test.startTest();
        try {
            PCC_Submit_DesignRegistrationController.logictochangestatus('InvalidId');
        } catch (Exception e) {
            // Verify that the exception message is thrown correctly
            System.assertEquals('Couldn\'t change the dr status', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();

        // Retrieve the Design Registration after status change (it should remain unchanged)
        Core_Design_Registration__c updatedDesignRegistration = [
            SELECT Id, Core_Design_Registration_Status_Nm__c, Workflow_Status__c
            FROM Core_Design_Registration__c 
            WHERE Id = :designRegistration.Id
        ];

        // Assert that the status is still 'Draft'
        System.assertEquals('Draft', updatedDesignRegistration.Core_Design_Registration_Status_Nm__c, 'Design Registration status should remain Draft');
    }

    @isTest
    static void testGetDRStatus() {
        // Create a Design Registration in Draft status
        Core_Design_Registration__c designRegistration = new Core_Design_Registration__c(
            Core_Product_Group_Nm__c = 'Embedded/IOT',
            Core_Design_Registration_Status_Nm__c = 'Draft'
            // Add other required fields here
        );
        insert designRegistration;

        // Call the method to get DR status, force an exception by passing an invalid ID
        Test.startTest();
        try {
            Boolean drStatus = PCC_Submit_DesignRegistrationController.getDRStatus('InvalidId');
        } catch (Exception e) {
            // Verify that the exception message is thrown correctly
            System.assertEquals('Invalid id: InvalidId', e.getMessage(), 'Exception message should match');
        }
        Test.stopTest();
    }*/
}