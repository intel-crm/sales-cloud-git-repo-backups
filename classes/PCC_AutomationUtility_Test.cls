/*************************************************************************************************************************************
Apex Class Name     : PCC_AutomationUtility_Test
Version             : 
Created Date        : Sept 2023
Function            : Test class for PCC_AutomationUtility
************************************************************************************************************************************************/
@isTest
private class PCC_AutomationUtility_Test {

    @isTest
    static void testUpdateFields_DesignRegistration() {
        Core_Design_Registration__c ddrRec = new Core_Design_Registration__c();
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
        ddrRec.PCC_End_Customer_Country__c ='India';
        ddrRec.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec.Core_Opportunity_Decision_Dt__c = system.today()+10;
        ddrRec.Core_First_Customer_Ship_Dt__c = system.today()+11;
        ddrRec.Core_Production_End_Dt__c = system.today()+20;
        ddrRec.Core_Intel_Platform_Nm__c='ALDER LAKE';
        ddrRec.Core_Design_Registration_Nm__c='Test DR Name Arrow automation';
        ddrRec.Core_Design_Registration_Dsc__c='Test Des';
        
        insert ddrRec;

        Product2 pr1 = new Product2(
            Name = 'Test data 2',
            IsActive = true,
            Core_Design_Registration_Eligible_Ind__c = true,
            Core_Avail_for_New_Designs__c = true,
            Core_Sales_Visible_Flag__c = true
        );
        insert pr1;

        Core_Design_Registration_Product__c testRecordDRP = new Core_Design_Registration_Product__c(
            Core_Design_Registration_Id__c = ddrRec.Id,
            Core_Product_Id__c = pr1.Id,
            Core_Target_Resale_Amt__c = 20,
            Core_Full_Year_Qty__c = 3,
            Core_Design_Product_Status_Nm__c = 'Pending',
            Core_Submission_Type__c = 'M2M'
        );
        insert testRecordDRP;

        Core_Design_Registration__c ddrRec1 = [SELECT Id, Core_Design_Registration_Status_Nm__c FROM Core_Design_Registration__c WHERE Id = :ddrRec.Id LIMIT 1];
        Core_Design_Registration_Product__c testRecordDRP1 = [SELECT Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Id = :testRecordDRP.Id LIMIT 1];
        Test.startTest();
        // Call the updateFields method
        String result = PCC_AutomationUtility.updateFields(ddrRec1.Id,'Approved','Design Registration');
        String result1 = PCC_AutomationUtility.updateFields(testRecordDRP1.Id,'Rejected','Design Registration Product');
		Test.stopTest();
        System.assertNotEquals(null,result);
    }

    @isTest
    static void testUpdateFields_ErrorHandling() {
        Test.startTest();
        // Call the updateFields method with invalid data
        String result1 = PCC_AutomationUtility.updateFields('invalidId','New Status','Design Registration');
        String result = PCC_AutomationUtility.updateFields('invalidId','New Status','Design Registration Product');
    	Test.stopTest();
        System.assertNotEquals(null,result1);
    }
}