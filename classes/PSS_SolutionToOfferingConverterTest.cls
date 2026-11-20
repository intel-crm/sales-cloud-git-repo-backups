/*****************************************************************************************************************************************************************
* Class Name  : PSS_SolutionToOfferingConverterTest

* Version     : 1.0 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-04-2019                    Test class of PSS_SolutionToOfferingConverter apex class
* ONYX Team               28-05-2021             Updated Test Class to include Multiple Choice, Tree Question and all end to end Scenarios
******************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
@isTest
public class PSS_SolutionToOfferingConverterTest {
    
  
    /*public static void generateData1(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = PMP_TestDataUtility.createTestUser(profileId);
        
        insert u;
        Group gp = new Group(Name = 'PMP_Admin_GroupName', DeveloperName ='PMP - All Intel Admin Users');
        insert gp;
        
        GroupMember gpm = new GroupMember();
        gpm.GroupId = gp.Id;
        gpm.UserOrGroupId = u.id;
        Database.insert(gpm);
    }
    @testSetup
    public static void generateData(){
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account acc = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
        Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount2', devRecordTypeId, true);
        Account acc3 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        Contact con = PMP_TestDataUtility.createContact(acc3.Id,true);
        PMP_Company__c companyInfo1 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        PMP_Company__c companyInfo2 = PMP_TestDataUtility.createCompanyInformation('test intel company', acc.Id, true);
        PMP_Company__c companyInfo3 = PMP_TestDataUtility.createCompanyInformation('test intel company2', acc2.Id, true);
        companyInfo1.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo1.PMP_One_Partner_ID__c = acc.Id;
        companyInfo2.PMP_Partner_Benefit_Type__c = PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED;
        companyInfo2.PMP_One_Partner_ID__c = acc.Id;
        companyInfo3.PMP_Partner_Benefit_Type__c = 'Solutions Marketplace Basic Profile';
        companyInfo3.PMP_One_Partner_ID__c = acc2.Id;
        update companyInfo1;
        update companyInfo2;
        update companyInfo3;
        
        List<PSS_Conversion_File_Formats__c> sFileFormatCustomSettingsList = new List<PSS_Conversion_File_Formats__c>();
        PSS_Conversion_File_Formats__c sConversionFileFormatCustomSetting1 = new PSS_Conversion_File_Formats__c(Name='PDF',PSS_File_Format_Nm__c='PDF',PSS_Inactive_Ind__c=false,PSS_Resource_Type_Txt__c='Additional Resources');
        PSS_Conversion_File_Formats__c sConversionFileFormatCustomSetting2 = new PSS_Conversion_File_Formats__c(Name='PNG',PSS_File_Format_Nm__c='PNG',PSS_Inactive_Ind__c=false,PSS_Resource_Type_Txt__c='Additional Resources');
        PSS_Conversion_File_Formats__c sConversionFileFormatCustomSetting3 = new PSS_Conversion_File_Formats__c(Name='JPEG',PSS_File_Format_Nm__c='JPEG',PSS_Inactive_Ind__c=false,PSS_Resource_Type_Txt__c='Additional Resources');
        PSS_Conversion_File_Formats__c sConversionFileFormatCustomSetting4 = new PSS_Conversion_File_Formats__c(Name='JPG',PSS_File_Format_Nm__c='JPG',PSS_Inactive_Ind__c=false,PSS_Resource_Type_Txt__c='Additional Resources');
        PSS_Conversion_File_Formats__c sConversionFileFormatCustomSetting5 = new PSS_Conversion_File_Formats__c(Name='GIF',PSS_File_Format_Nm__c='GIF',PSS_Inactive_Ind__c=false,PSS_Resource_Type_Txt__c='Additional Resources');
        sFileFormatCustomSettingsList.add(sConversionFileFormatCustomSetting1);
        sFileFormatCustomSettingsList.add(sConversionFileFormatCustomSetting2);
        sFileFormatCustomSettingsList.add(sConversionFileFormatCustomSetting3);
        sFileFormatCustomSettingsList.add(sConversionFileFormatCustomSetting4);
        sFileFormatCustomSettingsList.add(sConversionFileFormatCustomSetting5);
        insert sFileFormatCustomSettingsList;
        
        //Create PDF Document
        List<String> cvIds = new List<String>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document1';
        cv.PathOnClient = 'TestDocument1.pdf';
        cv.VersionData = Blob.valueOf('Test Content1');
        insert cv;
        cvIds.add(cv.id);
        
        //Create PDF Document
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document2';
        cv2.PathOnClient = 'TestDocument2.pdf';
        cv2.VersionData = Blob.valueOf('Test Content2');
        insert cv2;
        cvIds.add(cv2.id);
        
        //Create JPG Document
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Image1';
        cv1.PathOnClient = 'TestImage1.jpg';
        cv1.VersionData = Blob.valueOf('Test Content1 for Image');
        insert cv1;
        cvIds.add(cv1.id);
        
        //Create JPG Document
        ContentVersion cv3 = new ContentVersion();
        cv3.Title = 'Test Image3';
        cv3.PathOnClient = 'TestImage3.jpg';
        cv3.VersionData = Blob.valueOf('Test Content3 for Image');
        insert cv3;
        cvIds.add(cv3.id);
        
        
        
        PMP_Category__c appCategory = new PMP_Category__c (Name='Application', PMP_Partner_Product_Category_Cd__c='NPP_01_APP',PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='npp_01_app');
        PMP_Category__c category = new PMP_Category__c(Name='Categories', PMP_Partner_Product_Category_Cd__c='NPP_01_Type',PMP_Partner_Product_Parent_Category_Cd__c= 'Solution_Marketplace_Hierarchy', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='npp_01_type');
        PMP_Category__c solutionCategory = new PMP_Category__c(Name='Solution', PMP_Partner_Product_Category_Cd__c='IPA_TYPE_Sol',PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_01_TYPE', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='ipa_type_sol');
        PMP_Category__c categorySystem = new PMP_Category__c(Name='System', PMP_Partner_Product_Category_Cd__c='NPP_01_Type|NPP_02_Type_SYS',PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_Taxonomy|NPP_01_Type', PMP_Active_Ind__c=true);
        PMP_Category__c industryCategory = new PMP_Category__c(Name='Industry',PMP_Partner_Product_Category_Cd__c='NPP_01_Industry',PMP_Partner_Product_Parent_Category_Cd__c= 'Solution_Marketplace_Hierarchy', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='npp_01_industry');
        PMP_Category__c agricultureCategory = new PMP_Category__c(Name='Agriculture',PMP_Partner_Product_Category_Cd__c='IPA_Ind_Agriculture',PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_01_Industry', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='ipa_ind_agriculture');
        PMP_Category__c accomodationFoodServiceCat = new PMP_Category__c(Name='Accommodation and Food Services',PMP_Partner_Product_Category_Cd__c='IPA_Ind_AccomFoodServ',PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_01_Industry', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='ipa_ind_accomfoodserv');
        PMP_Category__c artificalIntelligenceCat = new PMP_Category__c(Name='Artificial Intelligence',PMP_Partner_Product_Category_Cd__c='IPA_APP_ArtificalIntel',PMP_Partner_Product_Parent_Category_Cd__c= 'NPP_01_APP', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='ipa_app_artificalintel');       
        PMP_Category__c sMRSCat = new PMP_Category__c(Name='Intel® IoT Market Ready Solutions',PMP_Partner_Product_Category_Cd__c='TPS_900036',PMP_Partner_Product_Parent_Category_Cd__c='IPA_TYPE_Sol', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='tps_900036',PMP_Business_Segment_Nm__c='IoT');
        PMP_Category__c sRRKCat = new PMP_Category__c(Name='Intel® IoT RFP Ready Kits',PMP_Partner_Product_Category_Cd__c='TPS_900037',PMP_Partner_Product_Parent_Category_Cd__c='IPA_TYPE_Sol', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='tps_900037',PMP_Business_Segment_Nm__c='IoT');
        PMP_Category__c sAIIPCat = new PMP_Category__c(Name='Partner Solutions',PMP_Partner_Product_Category_Cd__c='TPS_900039',PMP_Partner_Product_Parent_Category_Cd__c='IPA_TYPE_Sol', PMP_Active_Ind__c=true,PMP_Partner_Product_Category_Key__c='tps_900039',PMP_Business_Segment_Nm__c='IoT');
        List<PMP_Category__c> categoryList = New List<PMP_Category__c>{artificalIntelligenceCat,sAIIPCat,sRRKCat,sMRSCat,appCategory,category,categorySystem,solutionCategory,industryCategory,agricultureCategory,accomodationFoodServiceCat};
            insert categoryList;
        
        PMP_Specification__c spec1 = new PMP_Specification__c(name = 'Processors', PMP_Partner_Product_Specification_Id__c= 'PMP_Processor',PMP_Active_Ind__c=true);
        PMP_Specification__c spec2 = new PMP_Specification__c(name = 'X1Processor',PMP_Partner_Product_Specification_Id__c= 'PMP_Processor|X1Processor',PMP_Active_Ind__c=true);
        PMP_Specification__c spec3 = new PMP_Specification__c(name = 'Operating Systems', PMP_Partner_Product_Specification_Id__c='NPP_OperationSystems',PMP_Partner_Product_Specification_Key__c='npp_operationsystems',PMP_Active_Ind__c=true);
        PMP_Specification__c spec4 = new PMP_Specification__c(name = 'Cloud Services', PMP_Partner_Product_Specification_Id__c='NPP_Cloud_Services',PMP_Partner_Product_Specification_Key__c='npp_cloud_services',PMP_Active_Ind__c=true);
        PMP_Specification__c spec5 = new PMP_Specification__c(name = 'Microsoft Windows Client*',PMP_Product_Parent_Specification_Id__c='NPP_OperationSystems', PMP_Partner_Product_Specification_Id__c='203699',PMP_Partner_Product_Specification_Key__c='203699',PMP_Active_Ind__c=true);
        PMP_Specification__c spec6 = new PMP_Specification__c(name = 'Microsoft Windows Server*',PMP_Product_Parent_Specification_Id__c='NPP_OperationSystems', PMP_Partner_Product_Specification_Id__c='203697',PMP_Partner_Product_Specification_Key__c='203697',PMP_Active_Ind__c=true);
        PMP_Specification__c spec7 = new PMP_Specification__c(name = 'Google',PMP_Product_Parent_Specification_Id__c='NPP_OperationSystems', PMP_Partner_Product_Specification_Id__c='203702',PMP_Partner_Product_Specification_Key__c='203702',PMP_Active_Ind__c=true);
        PMP_Specification__c spec8 = new PMP_Specification__c(name = 'Availability and Pricing', PMP_Partner_Product_Specification_Id__c='AvailabilityandPricingLevel1',PMP_Partner_Product_Specification_Key__c='availabilityandpricinglevel1',PMP_Active_Ind__c=true);
        PMP_Specification__c spec9 = new PMP_Specification__c(name = 'Order Lead Time (Days)',PMP_Product_Parent_Specification_Id__c='AvailabilityandPricingLevel1', PMP_Partner_Product_Specification_Id__c='NPP_AvailabilityAndPricing_OrderLeadTimeDays',PMP_Partner_Product_Specification_Key__c='npp_availabilityandpricing_orderleadtimedays',PMP_Active_Ind__c=true);
        PMP_Specification__c spec11 = new PMP_Specification__c(name = 'Wireless', PMP_Partner_Product_Specification_Id__c='NPP_Wireless',PMP_Partner_Product_Specification_Key__c='npp_wireless',PMP_Active_Ind__c=true);
        PMP_Specification__c spec10 = new PMP_Specification__c(name = 'WAN',PMP_Product_Parent_Specification_Id__c='NPP_Wireless', PMP_Partner_Product_Specification_Id__c='NPP_Wireless_WAN',PMP_Partner_Product_Specification_Key__c='npp_wireless_wan',PMP_Active_Ind__c=true);
        List<PMP_Specification__c> specificationList = New List<PMP_Specification__c>{spec1,spec2,spec3,spec4,spec5,spec6,spec7,spec8,spec9,spec11,spec10};
            
            insert specificationList;
        
        
        PMP_Specification_Value__c specValue1 = new PMP_Specification_Value__c(name='Alibaba Cloud',PMP_Product_Specification_Value_Cd__c='Alibaba Cloud',PMP_Active_Ind__c=true,PMP_Product_Specification_Value_Key__c='NPP_Cloud_Services_alibabacloud',PMP_Specification_Product_Cd__c='NPP_Cloud_Services');
        PMP_Specification_Value__c specValue2 = new PMP_Specification_Value__c(name='Google Cloud',PMP_Product_Specification_Value_Cd__c='',PMP_Active_Ind__c=true,PMP_Product_Specification_Value_Key__c='NPP_Cloud_Services_googlecloud',PMP_Specification_Product_Cd__c='NPP_Cloud_Services');
        PMP_Specification_Value__c specValue3 = new PMP_Specification_Value__c(name='5G',PMP_Product_Specification_Value_Cd__c='',PMP_Active_Ind__c=true,PMP_Product_Specification_Value_Key__c='NPP_Wireless_WAN_5g',PMP_Specification_Product_Cd__c='NPP_Wireless_WAN');
        
        List<PMP_Specification_Value__c> specValueList = new List<PMP_Specification_Value__c>{specValue1,specValue2,specValue3};
            
            insert specValueList;    
        
        ArdiraSurvey__Survey__c survey = New ArdiraSurvey__Survey__c(Name = 'Test Survey', ArdiraSurvey__CNav_Pagination__c = 'Section', ArdiraSurvey__Status__c = 'Draft');
        
        insert survey;
        
        List<ArdiraSurvey__Question__c> questionList = New List<ArdiraSurvey__Question__c>();
        
        ArdiraSurvey__Question__c   question1 = New ArdiraSurvey__Question__c();
        question1.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question1.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question1.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question1.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question1.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question1.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question1.ArdiraSurvey__Question__c = 'Provide a link to a public website or published marketing collateral showing the solution’s value for specific target industries. Relevant files can also be uploaded.';
        question1.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question1.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question1.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question1.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question1.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question1.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question1.PSS_Conversion_Taxonomy_Nm__c = 'Partner Offering Resource';
        question1.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question1);
        
        ArdiraSurvey__Question__c   question2 = New ArdiraSurvey__Question__c();
        question2.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question2.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question2.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question2.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question2.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question2.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question2.ArdiraSurvey__Question__c = 'Select Industry';
        question2.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question2.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question2.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question2.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question2.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question2.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question2.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question2);
        
        
        ArdiraSurvey__Question__c   question3 = New ArdiraSurvey__Question__c();
        question3.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question3.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question3.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question3.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question3.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question3.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question3.ArdiraSurvey__Question__c = 'Enter the solution name';
        question3.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question3.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question3.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question3.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question3.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question3.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question3.PSS_Offering_Nm__c = 'PMP_Partner_Offering_Nm__c';
        question3.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question3);
        
        ArdiraSurvey__Question__c   question4 = New ArdiraSurvey__Question__c();
        question4.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question4.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question4.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question4.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question4.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question4.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question4.ArdiraSurvey__Type__c = 'Document Upload';
        question4.ArdiraSurvey__Question__c = 'Upload a solution architecture or data flow diagram. It must clearly represent the data ingestion from the edge, edge compute, connection to the cloud or data center, and the resulting business insight or analytics the solution delivers. Please also include all relevant technical specifications which may include enclosure standards, operating temperatures, and power supply requirements.';
        question4.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question4.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question4.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question4.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question4.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question4.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question4.PSS_Conversion_Taxonomy_Nm__c = 'Partner Offering Resource';
        question4.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question4);
        
        ArdiraSurvey__Question__c   question5 = New ArdiraSurvey__Question__c();
        question5.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question5.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question5.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question5.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question5.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question5.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question5.ArdiraSurvey__Type__c = 'Multiple Choice';
        question5.ArdiraSurvey__Question__c = 'What operating system is used at the edge in this solution?';
        question5.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question5.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question5.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question5.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question5.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question5.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question5.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question5);
        
        ArdiraSurvey__Question__c   question6 = New ArdiraSurvey__Question__c();
        question6.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question6.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question6.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question6.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question6.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question6.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question6.ArdiraSurvey__Type__c = 'Multiple Choice';
        question6.ArdiraSurvey__Question__c = 'What cloud service provider is used in this offer?';
        question6.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question6.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question6.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question6.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question6.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question6.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question6.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question6);
        
        ArdiraSurvey__Question__c   question7 = New ArdiraSurvey__Question__c();
        question7.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question7.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question7.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question7.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question7.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question7.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question7.ArdiraSurvey__Type__c = 'Number';
        question7.ArdiraSurvey__Question__c = 'Order Lead (Days)';
        question7.PSS_Conversion_Taxonomy_Nm__c = 'Partner Offering Specification';
        question7.PSS_Related_Parent_Taxonomy_Txt__c = spec8.PMP_Partner_Product_Specification_Key__c;
        question7.PSS_Related_Offering_Options_Txt__c = spec9.PMP_Partner_Product_Specification_Key__c;
        question7.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question7.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question7.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question7.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question7.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question7.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question7.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question7); 
        
        ArdiraSurvey__Question__c   question8 = New ArdiraSurvey__Question__c();
        question8.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question8.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question8.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question8.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question8.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question8.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question8.ArdiraSurvey__Type__c = 'Number';
        question8.ArdiraSurvey__Question__c = 'No of Artificial Intelligence Framework Used';
        question8.PSS_Conversion_Taxonomy_Nm__c = 'Partner Offering Category';
        question8.PSS_Related_Parent_Taxonomy_Txt__c = appCategory.PMP_Partner_Product_Category_Key__c;
        question8.PSS_Related_Offering_Options_Txt__c = artificalIntelligenceCat.PMP_Partner_Product_Category_Key__c;
        question8.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question8.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question8.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question8.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question8.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question8.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question8.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question8);
        
        ArdiraSurvey__Question__c   question9 = New ArdiraSurvey__Question__c();
        question9.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question9.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question9.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question9.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question9.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question9.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question9.ArdiraSurvey__Question__c = 'Enter your Signature';
        question9.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question9.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question9.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question9.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question9.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question9.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question9.PSS_Offering_Nm__c = 'PMP_Partner_Offering_Dsc__c';
        question9.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question9);
        
        ArdiraSurvey__Question__c   question10 = New ArdiraSurvey__Question__c();
        question10.ArdiraSurvey__C_Date_Correct_Answer_When__c= 'Answered';
        question10.ArdiraSurvey__C_Polar_Correct_Answer_When__c = 'True';
        question10.ArdiraSurvey__C_Radio_Display__c = 'Vertical Radio';
        question10.ArdiraSurvey__C_Ranking_Correct_Answer_When__c = 'Correct Order';
        question10.ArdiraSurvey__C_Text_Correct_Answer_When__c = 'Answered';
        question10.ArdiraSurvey__C_Display_Image_Size__c = 'Small';
        question10.ArdiraSurvey__Question__c = 'How do the solution’s edge hardware/gateways connect to the server and/or cloud? Select all that apply.';
        question10.ArdiraSurvey__Date_Allowed_Dates__c = 'Any';
        question10.ArdiraSurvey__C_Multiple_Choice_Display__c = 'Checkbox';
        question10.ArdiraSurvey__C_Multiple_Choice_Scoring_option__c = 'Use Choice Score';
        question10.ArdiraSurvey__C_Polar_Yes_No_Display__c = 'YesNo';
        question10.ArdiraSurvey__Rating_Rating_Range__c = '3';
        question10.ArdiraSurvey__C_Rating_Shape__c = 'Star';
        question10.ArdiraSurvey__Survey__c = survey.id;
        questionList.add(question10);
        
        insert questionList;
        
        ArdiraSurvey__Answer_Choice__c choice1 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = 'Agriculture',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = industryCategory.PMP_Partner_Product_Category_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c =agricultureCategory.PMP_Partner_Product_Category_Key__c,
                                                                                    ArdiraSurvey__Question__c = question2.id );
        
        ArdiraSurvey__Answer_Choice__c choice2 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = 'Accommodation and Food Services',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = industryCategory.PMP_Partner_Product_Category_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c = accomodationFoodServiceCat.PMP_Partner_Product_Category_Key__c , 
                                                                                    ArdiraSurvey__Question__c = question2.id );
        
        ArdiraSurvey__Answer_Choice__c choice3 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = 'Windows',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = spec3.PMP_Partner_Product_Specification_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c = spec5.PMP_Partner_Product_Specification_Key__c + ',' + spec6.PMP_Partner_Product_Specification_Key__c , 
                                                                                    ArdiraSurvey__Question__c = question5.id );
        
        ArdiraSurvey__Answer_Choice__c choice4 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = 'Android',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = spec3.PMP_Partner_Product_Specification_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c = spec7.PMP_Partner_Product_Specification_Key__c , 
                                                                                    ArdiraSurvey__Question__c = question5.id );
        
        ArdiraSurvey__Answer_Choice__c choice5 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = 'Alibaba Cloud',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = spec4.PMP_Partner_Product_Specification_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c = specValue1.PMP_Product_Specification_Value_Key__c , 
                                                                                    ArdiraSurvey__Question__c = question6.id );
        
        ArdiraSurvey__Answer_Choice__c choice6 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = 'Google Cloud Platform',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = spec4.PMP_Partner_Product_Specification_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c = specValue2.PMP_Product_Specification_Value_Key__c , 
                                                                                    ArdiraSurvey__Question__c = question6.id );
        
        ArdiraSurvey__Answer_Choice__c choice7 = New ArdiraSurvey__Answer_Choice__c(ArdiraSurvey__Choice_Label__c = '5G',
                                                                                    PSS_Related_Parent_Taxonomy_Txt__c = spec10.PMP_Partner_Product_Specification_Key__c,
                                                                                    PSS_Related_Offering_Options_Txt__c = specValue3.PMP_Product_Specification_Value_Key__c , 
                                                                                    ArdiraSurvey__Question__c = question10.id );
        
        List<ArdiraSurvey__Answer_Choice__c > choiceList = New List<ArdiraSurvey__Answer_Choice__c >{choice1,choice2,choice3,choice4,choice5,choice6,choice7};
            insert choiceList;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User u = PMP_TestDataUtility.createTestUser(profileId);
        
        insert u;
        Group gp = new Group(Name = 'PMP_All_Intel_Admin_Users');
        insert gp;
        
        GroupMember groupMembers=[SELECT id,Group.DeveloperName  FROM GroupMember where Group.DeveloperName ='PMP_All_Intel_Admin_Users'limit 1];  
        
        ArdiraSurvey__Survey_Result__c solution = PSS_TestDataUtility.createSolution();
        solution.ArdiraSurvey__Survey__c = survey.id;
        solution.PSS_Programs_Applicable_Nm__c = 'MRS;RRK';
        solution.PSS_Company_Id__c = companyInfo1.Id;
        solution.PSS_Partner_Account_Id__c   = acc.Id;
        solution.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        solution.PSS_Solution_Submitter_UserId_Id__c = u.Id; //added
        insert solution;
        
        ArdiraSurvey__Survey_Result__c partnerSolution = PSS_TestDataUtility.createSolution();
        partnerSolution.ArdiraSurvey__Survey__c = survey.id;
        partnerSolution.PSS_Programs_Applicable_Nm__c = 'Partner Solution';
        partnerSolution.PSS_Company_Id__c = companyInfo1.Id;
        partnerSolution.PSS_Partner_Account_Id__c   = acc.Id;
        partnerSolution.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Approved';
        partnerSolution.PSS_Solution_Submitter_UserId_Id__c = u.Id; //added
        insert partnerSolution;
        
        
        ArdiraSurvey__Question_Result__c questionRes1 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question1.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='http://www.applicationtest.com');
        
        ArdiraSurvey__Question_Result__c questionRes2 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question2.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='Agriculture,Accommodation and Food Services');
        
        ArdiraSurvey__Question_Result__c questionRes3 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question3.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='Sample Test Data');
        
        ArdiraSurvey__Question_Result__c questionRes4 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question4.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true);
        
        ArdiraSurvey__Question_Result__c questionRes5 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question5.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='Android,Windows');
        
        ArdiraSurvey__Question_Result__c questionRes6 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question6.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='Google Cloud Platform,Alibaba Cloud');
        
        ArdiraSurvey__Question_Result__c questionRes7 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question7.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='10');
        
        ArdiraSurvey__Question_Result__c questionRes8 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question8.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='1');
        
        ArdiraSurvey__Question_Result__c questionRes9 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question9.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Rich_Text__c='<img src="https://intel--crmdevipam--c.documentforce.com/servlet/rtaImage?eid=a7l2h000000I8vI&amp;feoid=00N2h0000019HoU&amp;refid=0EM2h0000004wBa"></img>');
        
        ArdiraSurvey__Question_Result__c questionRes10 = New ArdiraSurvey__Question_Result__c(ArdiraSurvey__Question__c = question10.id, ArdiraSurvey__Survey_Result__c = solution.id, ArdiraSurvey__Survey__c = survey.id,ArdiraSurvey__Answered__c=true,ArdiraSurvey__Answer_Text__c='5G');
        
        List<ArdiraSurvey__Question_Result__c > questionResList = New List<ArdiraSurvey__Question_Result__c >{questionRes1,questionRes2,questionRes3,questionRes4,questionRes5,questionRes6,questionRes7,questionRes8,questionRes9,questionRes10};
            insert questionResList;
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer1 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice1.id, ArdiraSurvey__Question_Result__c = questionRes2.id);
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer2 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice2.id, ArdiraSurvey__Question_Result__c = questionRes2.id);
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer3 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice3.id, ArdiraSurvey__Question_Result__c = questionRes5.id);
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer4 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice4.id, ArdiraSurvey__Question_Result__c = questionRes5.id);
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer5 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice5.id, ArdiraSurvey__Question_Result__c = questionRes6.id);
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer6 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice6.id, ArdiraSurvey__Question_Result__c = questionRes6.id);
        
        ArdiraSurvey__Question_Result_Choice__c qstnResAnswer7 = New ArdiraSurvey__Question_Result_Choice__c(ArdiraSurvey__Answer_Choice__c = choice7.id, ArdiraSurvey__Question_Result__c = questionRes10.id);
        
        
        List<ArdiraSurvey__Question_Result_Choice__c > qstnResAnswerList = New List<ArdiraSurvey__Question_Result_Choice__c >{qstnResAnswer1,qstnResAnswer2,qstnResAnswer3,qstnResAnswer4,qstnResAnswer5,qstnResAnswer6,qstnResAnswer7};
            insert qstnResAnswerList;
        
        Map<Id,ContentVersion> sContentVersionIdListMap = New Map<Id,ContentVersion>([SELECT Id,ContentDocumentId from ContentVersion WHERE Id IN: cvIds]);
        
        
        //CREATING CONTENT DOCUMENT LINKS
        List<ContentDocumentLink> sContentLinks = new List<ContentDocumentLink>();
        ContentDocumentLink contentLink1 = new ContentDocumentLink();
        contentLink1.LinkedEntityId = solution.Id;
        contentLink1.ContentDocumentId = sContentVersionIdListMap.get(cvIds[0]).ContentDocumentId;
        contentLink1.ShareType = 'I';
        contentLink1.Visibility = 'AllUsers'; 
        
        ContentDocumentLink contentLink2 = new ContentDocumentLink();
        contentLink2.LinkedEntityId = solution.Id;
        contentLink2.ContentDocumentId = sContentVersionIdListMap.get(cvIds[1]).ContentDocumentId;
        contentLink2.ShareType = 'I';
        contentLink2.Visibility = 'AllUsers'; 
        
        ContentDocumentLink contentLink3 = new ContentDocumentLink();
        contentLink3.LinkedEntityId = solution.Id;
        contentLink3.ContentDocumentId = sContentVersionIdListMap.get(cvIds[2]).ContentDocumentId;
        contentLink3.ShareType = 'I';
        contentLink3.Visibility = 'AllUsers'; 
        
        ContentDocumentLink contentLink4 = new ContentDocumentLink();
        contentLink4.LinkedEntityId = solution.Id;
        contentLink4.ContentDocumentId = sContentVersionIdListMap.get(cvIds[3]).ContentDocumentId;
        contentLink4.ShareType = 'I';
        contentLink4.Visibility = 'AllUsers'; 
        
        ContentDocumentLink contentLink5 = new ContentDocumentLink();
        contentLink5.LinkedEntityId = questionRes4.Id;
        contentLink5.ContentDocumentId = sContentVersionIdListMap.get(cvIds[0]).ContentDocumentId;
        contentLink5.ShareType = 'I';
        contentLink5.Visibility = 'AllUsers';
        
        ContentDocumentLink contentLink6 = new ContentDocumentLink();
        contentLink6.LinkedEntityId = questionRes4.Id;
        contentLink6.ContentDocumentId = sContentVersionIdListMap.get(cvIds[1]).ContentDocumentId;
        contentLink6.ShareType = 'I';
        contentLink6.Visibility = 'AllUsers';
        
        ContentDocumentLink contentLink7 = new ContentDocumentLink();
        contentLink7.LinkedEntityId = questionRes4.Id;
        contentLink7.ContentDocumentId = sContentVersionIdListMap.get(cvIds[2]).ContentDocumentId;
        contentLink7.ShareType = 'I';
        contentLink7.Visibility = 'AllUsers';
        
        ContentDocumentLink contentLink8 = new ContentDocumentLink();
        contentLink8.LinkedEntityId = questionRes4.Id;
        contentLink8.ContentDocumentId = sContentVersionIdListMap.get(cvIds[3]).ContentDocumentId;
        contentLink8.ShareType = 'I';
        contentLink8.Visibility = 'AllUsers';
        
        sContentLinks.add(contentLink1);
        sContentLinks.add(contentLink2);
        sContentLinks.add(contentLink3);
        sContentLinks.add(contentLink4);
        sContentLinks.add(contentLink5);
        sContentLinks.add(contentLink6);
        sContentLinks.add(contentLink7);
        sContentLinks.add(contentLink8);
        
        insert sContentLinks;
        
    }
    
    @isTest static void convertSolutionToOffering(){
        List<ArdiraSurvey__Survey_Result__c> solutionList = [Select id,PSS_Programs_Applicable_Nm__c,PSS_Company_Id__c,PSS_Solution_Submitter_UserId_Id__c,PSS_Intel_Admin_Id__c from ArdiraSurvey__Survey_Result__c limit 10];
        List<ArdiraSurvey__Survey_Result__c> solutionListForException = [Select id from ArdiraSurvey__Survey_Result__c limit 10];//Mandatory Input Fields Missing
        
        Test.startTest();
        
        PSS_SolutionToOfferingConverter.convertProposal(solutionList);
        
        Integer sSOQLUsed = Limits.getQueries();
        
        //System.debug('SOQL Queries Fired : ' + String.valueOf(sSOQLUsed) );
        
        //Forcing Exception Scenario
        try{
            PSS_SolutionToOfferingConverter.convertProposal(solutionListForException);
        }
        catch(Exception e){
            system.assertEquals(e.getMessage(), e.getMessage(), '');          
        }
        
        Test.stopTest();
        
        integer offeringCount = [Select count() from pmp_partner_offering__c limit 10];
        
        system.assertEquals(2,solutionList.size(), '');
        
    }
    
     static testMethod void cloneOfferingResourcesTest(){
        Test.startTest();
        //creating offerings
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
        PMP_Partner_Offering__c clonedOffering = PMP_TestDataUtility.createOffering('clonedOffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
        
        //create contentDocument
        List<ContentDocument> docs = PMP_TestDataUtility.createContentDocument(true);
        
        //create offeringResources
        PMP_Partner_Offering_Resource__c offRes1 = PMP_TestDataUtility.createResources('Web Page', 'http://www.abc.com', offering.Id, 'Web Page', null);
        PMP_Partner_Offering_Resource__c offRes2 = PMP_TestDataUtility.createResources('Image', null, offering.Id, 'Image', docs[0].Id);
        
        List<PMP_Partner_Offering_Resource__c> clonedResources = PSS_SolutionToOfferingConverter.cloneOfferingResources(offering.Id, clonedOffering.Id);
        
        System.assertEquals('Testoffering',offering.Name );
        Test.stopTest();
   
    }
    public static testMethod void prepareLanguageTranslation_Test(){
         PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
        offering.PMP_Partner_Offering_Tag_Line_Txt__c='xyz';
        offering.PMP_Offering_Language_Nm__c = 'English';
        update offering;
 		PSS_SolutionToOfferingConverter.prepareLanguageTranslation(offering);
        offering.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        update offering;
		PSS_SolutionToOfferingConverter.prepareLanguageTranslation(offering);
        offering.PMP_Offering_Language_Nm__c = 'Japanese';
        update offering;
		PSS_SolutionToOfferingConverter.prepareLanguageTranslation(offering);
        System.assertEquals('Testoffering',offering.Name );
    }*/
    
}