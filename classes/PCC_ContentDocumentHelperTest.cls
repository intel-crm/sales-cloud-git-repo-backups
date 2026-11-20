/****************************************************************************************************************************************
* Class Name  : PCC_ContentDocumentHelperTest 
* Version     : 1.0 
* Created Date:  01-08-2024
* Modification Log :
* Developer            		  Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
Aravind                       01-08-2024         Created
*****************************************************************************************************************************************/
@IsTest
private class PCC_ContentDocumentHelperTest {
    @TestSetup
    static void setupData(){

        Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'Americas Brazil Sales Group';
        LstAcc[0].recordtypeID = accountRecordTypeIntel;
        lstAcc[1].recordtypeID = accountRecordTypeIntel;
        insert LstAcc;

        PCC_EndCustomerAcc_Mapping__c mapRec = new PCC_EndCustomerAcc_Mapping__c();
        mapRec.PCC_Write_In_OEM_Nm__c='Test';
        mapRec.PCC_End_Customer_Account_Id__c=LstAcc[0].id;
        mapRec.PCC_Registration_Type_Nm__c ='Deal Registration';
        mapRec.PCC_Partner_Account_Id__c = LstAcc[1].id;
        insert mapRec;

        Id DealRecordTypeid = Schema.SObjectType.Core_Design_Registration__c.getRecordTypeInfosByDeveloperName().get('Deal_Registration_Draft').getRecordTypeId();
        
        Core_Design_Registration__c ddrRec2 = new  Core_Design_Registration__c();
        ddrRec2.Core_Military_Aerospace_Gvrnmt_Use_Ind__c = 'Yes';
        ddrRec2.Core_Vertical_Market_Nm__c='Education';
        ddrRec2.Core_Product_Segment_Nm__c='Client Computing';
        ddrRec2.Core_Product_Application_Nm__c='Business Desktop';
        ddrRec2.Core_Opportunity_Volume_Cnt__c=100;
        ddrRec2.Core_Partner_FAE_Nm__c='Test FAE';
        ddrRec2.Core_Partner_FSR_Nm__c='Test FSR';
        //ddrRec2.Core_End_Customer_Nm__c='Arrow Electronics Account';
        ddrRec2.PCC_EndCustomerAcc_Mapping__c=mapRec.id;
        ddrRec2.Core_End_Customer_Street_Addr_Line1_Txt__c='12 Street 99';
        ddrRec2.Core_End_Customer_Street_Addr_Line2_Txt__c='';
        ddrRec2.PCC_End_Customer_Country__c='India';
        ddrRec2.Core_End_Customer_City_Nm__c='Bangalore';
        ddrRec2.Core_End_Customer_Country_Subdivision_Nm__c='Karnataka';
        ddrRec2.Core_End_Customer_Postal_Cd__c='758854';
        ddrRec2.Core_End_Customer_Contact_Title_Txt__c='Mr.';
        ddrRec2.Core_End_Customer_Contact_Nm__c='Arrow Electronics Partner User 01';
        ddrRec2.Core_End_Customer_Contact_Email_Txt__c='arrowelec.partneruser01@marketstar.com';
        ddrRec2.Core_End_Customer_Contact_Phone_Txt__c='7826499722';
        ddrRec2.Core_Manufacturing_Region_Cd__c='ASMO';
        ddrRec2.Core_Opportunity_Decision_Dt__c = system.today()+20;
        ddrRec2.Core_First_Customer_Ship_Dt__c = system.today()+21;
        ddrRec2.Core_Production_End_Dt__c = system.today()+22;
        ddrRec2.Core_Intel_Platform_Nm__c='Agilex';
        ddrRec2.Core_Design_Registration_Nm__c='Test DR Name Arrow9';
        ddrRec2.Core_Design_Registration_Dsc__c='Test Des';
        ddrRec2.Core_External_Id__c='abczd001';
        ddrRec2.DDR_Partner_FAE_Email__c = 'test.diqhwqi@test.com';
        ddrRec2.Core_End_Customer_URL__c = 'Test';
        ddrRec2.PCC_Consumption_Countries__c = 'Test';
        ddrRec2.PCC_Current_EndCustomer_Product_Provider__c='Test';
        ddrRec2.RecordTypeId=DealRecordTypeid;
        ddrRec2.Core_Design_Registration_Status_Nm__c = 'Submitted';
        insert ddrRec2; 

        // Create a test ContentVersion (which will create ContentDocument)
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test File partner delete',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert testContentVersion;

        // Get the ContentDocument ID from the inserted ContentVersion
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId;

        // Create a ContentDocumentLink between the test record and the ContentDocument
        ContentDocumentLink testCDL = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = ddrRec2.Id,
            ShareType = 'V'
        );
        insert testCDL;

    }

    @isTest 
    public static void preventDeletionForPartners(){
        List<ContentDocument> cds = [Select Id from ContentDocument where Title = 'Test File partner delete'];
        Test.startTest();
        delete cds;
        Test.stopTest();
        Assert.areEqual(1, cds.size(), 'Expected one file'); 
    }
}