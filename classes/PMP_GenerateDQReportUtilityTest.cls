/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportUtilityTest 
* Version     : 1.0 
* Created Date: 22/08/2022   
* Modification Log :
* Developer                       Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal            22/08/2022                   Test class for PMP_GenerateDQReportUtility
* ****************************************************************************************************************************************/
@isTest
public class PMP_GenerateDQReportUtilityTest {
     @testSetup static void setup() {
        // Create common test accounts
         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
         Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
         Account pagAcc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
         Account pagAcc1 = PMP_TestDataUtility.createAccount('TestPartnerAccount2', devRecordTypeId, true);
         Account pagAcc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount3', devRecordTypeId, true);
         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', pagAcc.Id, true);
         PMP_Company__c cmp2 = PMP_TestDataUtility.createCompanyInformation('TestCompany2', pagAcc.Id, true);
         PMP_Company__c cmp3 = PMP_TestDataUtility.createCompanyInformation('TestCompany3', pagAcc.Id, true);
         
         PMP_Company_Resource__c testResource = new PMP_Company_Resource__c(Name='sampleResource1',PMP_Company_Id__c=cmp1.Id,PMP_Company_Resource_Type_Nm__c='Image');
         testResource.PMP_Company_Image__c='';
         cmp1.PMP_Company_Lifecycle_Status_Nm__c='Published';
         update cmp1;
         insert testResource;
         
         PMP_Partner_Tier__c pt = new PMP_Partner_Tier__c();
         pt.Name='Gold';
         insert pt;
         PMP_Partner_Program__c pp = new PMP_Partner_Program__c();
         pt.Name='Seller';
         insert pp;
         PMP_Partner_Segment__c ps = new PMP_Partner_Segment__c();
         ps.Name='Storage and Memory';
         insert ps;
         PMP_Partner_Specialty__c pss = new PMP_Partner_Specialty__c();
         pss.Name='Networking Specialist';
         insert pss;
         	 
         List<PMP_Marketing_Profile_Attributes_Mapping__c> partnerAttributeMappingList = new  List<PMP_Marketing_Profile_Attributes_Mapping__c>();
         PMP_Marketing_Profile_Attributes_Mapping__c partnerAttributeMap1 = new PMP_Marketing_Profile_Attributes_Mapping__c();
         partnerAttributeMap1.PMP_Marketing_Profile_Id__c = cmp1.id;
         partnerAttributeMap1.PMP_Partner_Tier__c=pt.id;
         partnerAttributeMappingList.add(partnerAttributeMap1);
         
         PMP_Marketing_Profile_Attributes_Mapping__c partnerAttributeMap2 = new PMP_Marketing_Profile_Attributes_Mapping__c();
         partnerAttributeMap2.PMP_Marketing_Profile_Id__c = cmp1.id;
         partnerAttributeMap2.PMP_Partner_Role__c=pp.id;
         partnerAttributeMappingList.add(partnerAttributeMap2);
         
         PMP_Marketing_Profile_Attributes_Mapping__c partnerAttributeMap3 = new PMP_Marketing_Profile_Attributes_Mapping__c();
         partnerAttributeMap3.PMP_Marketing_Profile_Id__c = cmp1.id;
         partnerAttributeMap3.PMP_Partner_Segment__c=ps.id;
         partnerAttributeMappingList.add(partnerAttributeMap3);
         
         PMP_Marketing_Profile_Attributes_Mapping__c partnerAttributeMap4 = new PMP_Marketing_Profile_Attributes_Mapping__c();
         partnerAttributeMap4.PMP_Marketing_Profile_Id__c = cmp1.id;
         partnerAttributeMap4.PMP_Partner_Specialty__c=pss.id;
         partnerAttributeMappingList.add(partnerAttributeMap4);
         
         insert partnerAttributeMappingList;
         
         cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
         cmp1.PMP_IPA_Badge_Tier_Txt__c='Member';
         cmp1.PMP_Partner_Segment_Nm__c = 'Storage and Memory';
         cmp1.PMP_Partner_Program_nm__c='Seller';
         update cmp1;
         cmp2.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
         cmp2.PMP_Benefit_Update_Ind__c=false;
         update cmp2;
         PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
         jun.PMP_One_Partner_ID__c= pagAcc.Id;
         jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
         jun.Is_Active__c=true;     
         insert jun; 
         PMP_OPID_MPI_Rel__c jun1= new PMP_OPID_MPI_Rel__c();
         jun1.PMP_One_Partner_ID__c= pagAcc1.Id;
         jun1.PMP_Marketing_Profile_Id__c= cmp1.Id;
         jun1.Is_Active__c=true;     
         insert jun1;
         PMP_OPID_MPI_Rel__c jun2= new PMP_OPID_MPI_Rel__c();
         jun2.PMP_One_Partner_ID__c= pagAcc2.Id;
         jun2.PMP_Marketing_Profile_Id__c= cmp2.Id;
         jun2.Is_Active__c=false;     
         insert jun2;
         
        //  PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestOffering','Public Content', 
        //                                                                            'TestOffering',cmp1.Id, true,'Published','');
        //  PMP_Partner_Offering__c testOffering2 = PMP_TestDataUtility.createOffering('TestOffering2','Public Content', 
        //                                                                            'TestOffering2',cmp1.Id, true,'Published','');
        //  PMP_Partner_Offering_Resource__c offResource = PMP_TestDataUtility.createOfferingResourceInstance('IntelImage','',testOffering.Id,'Image','');
        //  offResource.PMP_Partner_Offering_Image__c='';
        //  insert offResource;
         
         ContentVersion contentVersion_1 = new ContentVersion(
             Title = 'Test',
             PathOnClient = 'Test.jpg',
             VersionData = Blob.valueOf('Test Content'),
             IsMajorVersion = true
         );
         insert contentVersion_1;
         ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
         ContentAsset ca = new ContentAsset();
         ca.DeveloperName = 'caDev';
         ca.MasterLabel = 'caTest';
         ca.isVisibleByExternalUsers = TRUE;
         insert ca;
         
         contentDocument cd = new contentDocument();
         cd.Id = contentVersion_2.ContentDocumentId;
         cd.ContentAssetId = ca.Id;
         update cd;
         
        //  PMP_Partner_Offering_Resource__c offResource2 = PMP_TestDataUtility.createOfferingResourceInstance('IntelImage2','',testOffering2.Id,'Image','');
        //  offResource2.PMP_Partner_Offering_Image__c=cd.id;
        //  insert offResource2;
         
         PMP_Company_Resource__c testResource2 = new PMP_Company_Resource__c(Name='sampleResource2',PMP_Company_Id__c=cmp3.Id,PMP_Company_Resource_Type_Nm__c='Image');
         testResource2.PMP_Company_Image__c=cd.id;
         cmp3.PMP_Company_Lifecycle_Status_Nm__c='Published';
         update cmp3;
         insert testResource2;
         
         ChannelProgram cp = new ChannelProgram(); //Channel Program
         cp.Name='Intel Partner Alliance';
         cp.PRM_programCode__c='IPA';
         insert cp;
         
         ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
         cpl.Name='Titanium';
         cpl.ProgramId=cp.Id;
         insert cpl;
         
         ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
         cpl1.Name='Member';
         cpl1.ProgramId=cp.Id;
         insert cpl1;
         
         ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
         cpl2.Name='Gold';
         cpl2.ProgramId=cp.Id;
         insert cpl2;        
         
         PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
         contRelation.Name='Primary Contact';
         contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
         contRelation.PRM_Channel_Program_Id__c = cp.Id;
         contRelation.PRM_Default_Relationship_Ind__c = true;
         insert contRelation;
         
         PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
         acctContRel.PRM_Account_Id__c=acc1.Id;
         acctContRel.PRM_Contact_Id__c=con1.Id;
         acctContRel.PRM_Relationship_Id__c=contRelation.Id;
         acctContRel.PRM_InActive_Ind__c=false;
         acctContRel.PRM_Status_Reason_Txt__c= 'For relation';
         insert acctContRel;
         
         PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
         acm.PRM_Account_Id__c=pagAcc.id;
         acm.PRM_Status_Nm__c='Approved';
         acm.PRM_Channel_Program_Id__c=cp.Id;
         acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
         acm.PRM_Partner_Role__c='Service Provider';
         insert acm;  
         PRM_AccountChannelMembership__c acm1= new PRM_AccountChannelMembership__c(); //Account Channel Membership
         acm1.PRM_Account_Id__c=pagAcc.id;
         acm1.PRM_Status_Nm__c='Approved';
         acm1.PRM_Channel_Program_Id__c=cp.Id;
         acm1.PRM_Channel_Program_Level_Id__c=cpl.Id;
         acm1.PRM_Partner_Role__c='Distributor';
         insert acm1; 
         
         PRM_PartnerBenefit__c pb1 = new PRM_PartnerBenefit__c(); //Partner Benefit
         pb1.Name = 'Solutions Marketplace Basic Profile';
         pb1.PRM_Channel_Program_Id__c = cp.id;
         pb1.PRM_Benefit_Cd__c = 'BFTMKTPLBC';
         pb1.PRM_Account_Type_Nm__c = 'Both'; 
         insert pb1;
         
         PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c();
         aba.PRM_Account_Id__c=pagAcc.id;
         aba.PRM_Status_Nm__c='Active';
         aba.PRM_Partner_Benefit_Id__c=pb1.id;
         insert aba;
         
         PMP_Marketplace_DQ_Monitor__c dqRec = new PMP_Marketplace_DQ_Monitor__c(); 
         dqRec.PMP_Marketing_Profile_Id__c = cmp1.Id;   
         dqRec.PMP_Issue_Dsc_Txt__c ='Storefront Logo is Missing';
         dqRec.PMP_Issue_Type_Nm__c = 'Image Missing';
         dqRec.PMP_Issue_Sub_Type_Nm__c='Storefront Image';
         dqRec.PMP_External_Key__c= dqRec.PMP_Issue_Type_Nm__c.replaceAll(' ', '_') + '_' + dqRec.PMP_Issue_Sub_Type_Nm__c.replaceAll(' ', '_')  + '_' + dqRec.PMP_Marketing_Profile_Id__c + '_' + 'DQ21';
         dqRec.PMP_Status_Nm__c = 'Closed';
         insert dqRec;
     }
    @isTest
    public static void getPartnerTranslationRecordsTest()
    {   
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        Test.startTest();
        PMP_Company__c cmp1 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c from PMP_Company__c where Name=:'TestCompany1' Limit 1];
        cmp1.PMP_Company_Information_Language_Nm__c='English';
        cmp1.PMP_Account_Tag_Line__c ='テスト';
        cmp1.PMP_Account_Dsc__c ='testing';
        update cmp1;
        partnerList.add(cmp1);
        PMP_GenerateDQReportUtility.getPartnerTranslationRecords(partnerList);
        cmp1.PMP_Company_Information_Language_Nm__c='Japanese';
        update cmp1;
        PMP_GenerateDQReportUtility.getPartnerTranslationRecords(partnerList);
        cmp1.PMP_Company_Information_Language_Nm__c='Simplified Chinese';
        update cmp1;
        PMP_GenerateDQReportUtility.getPartnerTranslationRecords(partnerList);
        Test.stopTest();
    }
    //@isTest
    //public static void getOfferingTranslationRecordsTest()
    //{   
        // List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
        // Test.startTest();
        // PMP_Partner_Offering__c testOffering = [select id,Name,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c where Name=:'TestOffering' Limit 1];
        // testOffering.PMP_Offering_Language_Nm__c='English';
        // testOffering.PMP_Partner_Offering_Tag_Line_Txt__c ='テスト';
        // testOffering.PMP_Partner_Offering_Dsc__c ='testing';
        // update testOffering;
        // offList.add(testOffering);
        // PMP_GenerateDQReportUtility.getOfferingTranslationRecords(offList);
        // testOffering.PMP_Offering_Language_Nm__c='Japanese';
        // update testOffering;
        // PMP_GenerateDQReportUtility.getOfferingTranslationRecords(offList);
        // testOffering.PMP_Offering_Language_Nm__c='Simplified Chinese';
        // update testOffering;
        // PMP_GenerateDQReportUtility.getOfferingTranslationRecords(offList);      
        // Test.stopTest();
    //}
    @isTest
    public static void getCoveoIssueMPIRecordsTest()
    {   
         List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
         PMP_Company__c cmp1 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c,PMP_IPA_Badge_Tier_Txt__c,
                                PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Segment_Nm__c,PMP_Account_Specialty__c,PMP_Partner_Program_nm__c 
                                from PMP_Company__c where Name=:'TestCompany1' Limit 1];
        
         Test.startTest();
         partnerList.add(cmp1);
         PMP_GenerateDQReportUtility.getCoveoIssueMPIRecords(partnerList);
         Test.stopTest();
    }
    @isTest
    public static void getOPIDIssueMPIReccordsTest()
    {   
         List<PMP_Company__c> partnerList1 = new List<PMP_Company__c>();
         List<PMP_Company__c> partnerList2 = new List<PMP_Company__c>();
         PMP_Company__c cmp1 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c,PMP_IPA_Badge_Tier_Txt__c,
                                PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Segment_Nm__c,PMP_Account_Specialty__c,PMP_Partner_Program_nm__c 
                                from PMP_Company__c where Name=:'TestCompany1' Limit 1];
         PMP_Company__c cmp3 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c,PMP_IPA_Badge_Tier_Txt__c,
                                PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Segment_Nm__c,PMP_Account_Specialty__c,PMP_Partner_Program_nm__c 
                                from PMP_Company__c where Name=:'TestCompany3' Limit 1];
        Test.startTest();
        cmp1.PMP_Benefit_Update_Ind__c=true;
        update cmp1;
        partnerList1.add(cmp1);
        cmp3.PMP_Benefit_Update_Ind__c=false;
        update cmp3;
        partnerList1.add(cmp3);
        PMP_GenerateDQReportUtility.getOPIDIssueMPIReccords(partnerList1);       
        PMP_GenerateDQReportUtility.getOPIDIssueMPIReccords(partnerList2);
        Test.stopTest();
    }
    
    @isTest
    public static void getImageIssueRecordsTest()
    {
        List<PMP_Company__c> partnerList = new List<PMP_Company__c>();
        //List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
        PMP_Company__c cmp1 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c,PMP_IPA_Badge_Tier_Txt__c,
                               PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Segment_Nm__c,PMP_Account_Specialty__c,PMP_Partner_Program_nm__c 
                               from PMP_Company__c where Name=:'TestCompany1' Limit 1];
        PMP_Company__c cmp3 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c,PMP_IPA_Badge_Tier_Txt__c,
                               PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c,PMP_Partner_Segment_Nm__c,PMP_Account_Specialty__c,PMP_Partner_Program_nm__c 
                               from PMP_Company__c where Name=:'TestCompany3' Limit 1];
        // PMP_Partner_Offering__c testOffering = [select id,Name,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c where Name=:'TestOffering' Limit 1];
        // PMP_Partner_Offering__c testOffering2 = [select id,Name,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c where Name=:'TestOffering2' Limit 1];
        Test.startTest();
        partnerList.add(cmp1);
        partnerList.add(cmp3);
        // offList.add(testOffering);
        // offList.add(testOffering2);
        PMP_GenerateDQReportUtility.getStorefrontImageIssueRecords(partnerList);
        // PMP_GenerateDQReportUtility.getOfferingImageIssueRecords(offList);
        Test.stopTest();
    }
    
    @isTest
    public static void createLogEntryTest()
    {   
        Test.startTest();
        PMP_Company__c cmp1 = [select id,Name,PMP_Company_Information_Language_Nm__c,PMP_Account_Tag_Line__c,PMP_Account_Dsc__c from PMP_Company__c where Name=:'TestCompany1' Limit 1];
        // PMP_Partner_Offering__c testOffering = [select id,Name,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c where Name=:'TestOffering' Limit 1];
        DmlException e = new DmlException();
        PMP_GenerateDQReportUtility.createLogEntry(e,'PMP_Company__c',cmp1.id);
        // PMP_GenerateDQReportUtility.createLogEntry(e,'PMP_Partner_Offering__c',testOffering.id);
        PMP_GenerateDQReportUtility.createMarketplaceDQMonitorRecord('PMP_Company__c',cmp1.id,'Image Missing','Storefront Image','Storefront Logo is Missing','DQ21');
        Test.stopTest();
    }
    @isTest
    public static void sendDQReportEmailTest()
    {   
         Test.startTest();
         PMP_GenerateDQReportUtility.sendDQReportEmail();
         Test.stopTest();
    }
}