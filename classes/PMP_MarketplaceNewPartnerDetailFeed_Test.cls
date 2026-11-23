@isTest
public class PMP_MarketplaceNewPartnerDetailFeed_Test extends PMP_SearchWrapperStore{
//IPA2.0:US-4497-1631_OfferingEOL  
    
    // static testMethod void getPartnerDetailsPositiveTest(){
        
    //     List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Industry_Id',PMP_Value__c='NPP_01_Industry'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Application_Id',PMP_Value__c='NPP_01_APP'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Region_Id',PMP_Value__c='NPP_GeographicCoverage'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_LOEM_ODM_Partner_Program',PMP_Value__c='LOEM-ODM Partner Program'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_BENEFIT_ENHANCED_CODE',PMP_Value__c='BFTMKTPLED'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Sys_Admin_Profile',PMP_Value__c='System Administrator'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_IT_Admin_Profile',PMP_Value__c='IT Admin'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Thumbnail_Image',PMP_Value__c='Thumbnail Image'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
    //     insert stList;
        
    //     Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    //     Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
    //     /*prm_skip_trigger__c rec = new prm_skip_trigger__c();
    //     rec.Name = 'ABA_Trigger';
    //     rec.inactive__c = true;
    //     insert rec;*/
        
    //     Account newAccount = new Account();//Account
    //     newAccount.RecordTypeId = recordTypeIdAccount;
    //     newAccount.Name='Greg Thomas';
    //     newAccount.BillingCity='City';
    //     newAccount.BillingStreet='Street';
    //     newAccount.BillingCountry='India';
    //     newAccount.BillingPostalCode='Postal code';
    //     newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
    //     insert newAccount;
        
    //     Account newPagAccount = new Account();//Account
    //     newPagAccount.RecordTypeId = recordTypeIdPagAccount;
    //     newPagAccount.Name='Greg Thomas';
    //     newPagAccount.BillingCity='City';
    //     newPagAccount.BillingStreet='Street';
    //     newPagAccount.BillingCountry='India';
    //     newPagAccount.BillingPostalCode='Postal code';
    //     newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
    //     insert newPagAccount;
        
    //     Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
    //     coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
    //     coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
    //     insert coreAccnt;
        
    //     //custom Setting
    //     PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c();
    //     cust.Name='BatchFieldValues';
    //     cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
    //     cust.PRM_PartnerRole__c= 'Service Provider';
    //     cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';       
    //     insert cust;
        
    //     ChannelProgram cp = new ChannelProgram(); //Channel Program
    //     cp.Name='Intel Partner Alliance';
    //     cp.PRM_programCode__c='IPA';
    //     insert cp;
        
    //     ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
    //     cpl.Name='Titanium';
    //     cpl.ProgramId=cp.Id;
    //     insert cpl;
        
    //     ChannelProgramLevel cpl1=new ChannelProgramLevel(); //Channel Program Level
    //     cpl1.Name='Member';
    //     cpl1.ProgramId=cp.Id;
    //     insert cpl1;
        
    //     ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
    //     cpl2.Name='Gold';
    //     cpl2.ProgramId=cp.Id;
    //     insert cpl2;        
        
    //     PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
    //     acm.PRM_Account_Id__c=newAccount.id;
    //     acm.PRM_Status_Nm__c='Approved';
    //     acm.PRM_Channel_Program_Id__c=cp.Id;
    //     acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
    //     acm.PRM_Partner_Role__c='Service Provider';
    //     insert acm;
        
    //     PRM_PartnerBenefit__c pb2 = new PRM_PartnerBenefit__c(); //Partner Benefit
    //     pb2.Name = 'Solutions Marketplace Enhanced';
    //     pb2.PRM_Channel_Program_Id__c = cp.id;
    //     pb2.PRM_Benefit_Cd__c = 'BFTMKTPLED';
    //     pb2.PRM_Account_Type_Nm__c = 'Both'; 
    //     insert pb2;
        
    //     PRM_PartnerType__c pt=new PRM_PartnerType__c(); // Partner type
    //     pt.Name='Cloud Service Provider (CSP)';
    //     pt.PRM_Role_Name__c='Service Provider';
    //     pt.PRM_PartneryTypeCode__c='CSP';
    //     pt.PRM_PartnerRoleCode__c='SPR';
    //     pt.PRM_channelprogram__c=cp.Id;
    //     insert pt;
        
    //     PRM_VXBnftMatrix__c bem1=new PRM_VXBnftMatrix__c(); //Benefit Matrix
    //     bem1.PRM_Approval_Type_Nm__c='Automatic';
    //     bem1.PRM_Channel_Program_Id__c=cp.Id;
    //     bem1.PRM_Channel_Program_Level_Id__c=cpl.Id;
    //     bem1.PRM_Covered_Account_Ind__c=True;
    //     bem1.PRM_IsActive_Ind__c=True;
    //     bem1.PRM_Partner_Benefit_Id__c=pb2.Id;
    //     bem1.PRM_Partner_Type_Id__c=pt.Id;
    //     bem1.PRM_Partner_Role_Nm__c='Service Provider';
    //     insert bem1;
        
    //     /*PRM_AccountBenefitAssociation__c aba = new PRM_AccountBenefitAssociation__c(); // commented by shiva
    //     aba.PRM_Account_Id__c = newAccount.Id;
    //     aba.PRM_Partner_Benefit_Id__c = pb2.id;
    //     aba.PRM_Status_Nm__c = 'Active';
    //     insert aba;
    //     */
    //     PMP_Company__c partner1 = new PMP_Company__c();
    //     partner1.Name = 'Test_Partner1';
    //     partner1.PMP_IPA_Badge_Tier_Txt__c='Gold';
    //     //partner1.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
    //     partner1.PMP_Is_Published_Ind__c = true;
    //     partner1.PMP_Account_Id__c = newAccount.Id;
    //     partner1.PMP_Disti_Components_Nm__c = 'Data Center';
    //     partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
    //     partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
    //     //partner1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced; //IPA2.0 - TWC729-7885
        
    //     insert partner1;
        
        
    //     PMP_Company__c partner2 = new PMP_Company__c();
    //     partner2.Name = 'Test_Partner2';
    //     //partner2.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
    //     partner2.PMP_Is_Working_Copy_Ind__c = true;
    //     partner2.PMP_Account_Id__c = newPagAccount.Id;
    //     partner2.PMP_Disti_Components_Nm__c = 'Data Center';
    //     partner2.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
    //     partner2.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
    //     partner2.PMP_Disti_Country_Coverage_Txt__c = 'India';
    //     insert partner2;
    //     partner1.PMP_Published_Copy_Id__c=partner2.id;
    //     update partner1;
        
    //     partner2.PMP_Working_Copy_Id__c=partner1.id;
    //     update partner2;
        
    //     PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
    //     off1.Name = 'Test_Off1';
    //     off1.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
    //     off1.PMP_Partner_Offering_Start_Dt__c=System.today();
    //     off1.PMP_Partner_Offering_End_Dt__c=System.today();
    //     off1.PMP_Partner_Offering_Visibility_Nm__c='Public Content';
    //     off1.PMP_Partner_Offering_Nm__c='Test_Off1';
    //     off1.PMP_Partner_Offering_Dsc__c='fsdfsdfsdf';
    //     off1.PMP_Featured_Offering_Ind__c=true;
    //     off1.PMP_Partner_Offering_Tag_Line_Txt__c='Test_Off1';
    //     off1.PMP_Company_Id__c = partner1.Id;
    //     insert off1;  
        
    //     List<PMP_Category__c> catList = new List<PMP_Category__c>();
    //     PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
    //     cat0.PMP_Category_Japanese_Nm__c='sfdfsdfsdf';
    //     update cat0;
        
    //     PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        
    //     cat1.PMP_Parent_Category_Id__c = cat0.Id;
    //     catList.add(cat0);
    //     catList.add(cat1);
    //     Database.SaveResult[] result = Database.update(catList);
    //     for (Database.SaveResult sr : result) {
    //         if (sr.isSuccess()) {
    //             // Operation was successful, so get the ID of the record that was processed
    //             // System.debug('Successfully inserted category. categroy ID: ' + sr.getId());
    //         }
    //         else {
    //             // Operation failed, so get all errors                
    //             for(Database.Error err : sr.getErrors()) {
    //                 // System.debug('The following error has occurred.');                    
    //                 // System.debug(err.getStatusCode() + ': ' + err.getMessage());
    //                 // System.debug('Account fields that affected this error: ' + err.getFields());
    //             }
    //         }
    //     }
        
    //     List<PMP_Category__c> listCats = [select id,name,PMP_Parent_Category_Id__c from PMP_Category__c];
        
    //     StorefrontFeedItem item = new StorefrontFeedItem();
    //     item.cardData=new List<cardData>(); 
    //     item.filterStructure = new List<FilterStructure>(); 
    //     item.filterData = new Map<id,FilterData>();
    //     item.totalItems = 0;
        
    //     list<contentDocument> createContentDocument = PMP_TestDataUtility.createContentDocument(true);
        
    //     PMP_Partner_Offering_Resource__c offRes1 = PMP_TestDataUtility.createResources('Product Web Page', 'http://www.abc.com', off1.Id, PMP_StaticConstants_Partner.IMAGE, createContentDocument[0].Id);
    //     //offres1.PMP_Resource_Type_Nm__c=PMP_StaticConstants_Partner.THUMBNAIL_IMAGE;
    //     //offres1.PMP_Partner_Offering_Image__c = 'testId';
    //     offres1.PMP_Resource_Sequence_Nbr__c = 0;
    //     update offRes1;
        
    //     PMP_Category__c catCmp = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
    //     PMP_Category__c catBoard = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','NPP_02_Comp', 'en_us');
        
    //     PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
    //     offCat2.Name = system.label.PMP_application; // value change from Application to Use Cases
    //     offCat2.Name = 'Categories';
    //     offCat2.PMP_Offering_Category_External_Key__c = 'NPP_01_TYPE';
    //     offCat2.PMP_Offering_Id__c = off1.Id;
    //     offCat2.PMP_Category_Id__c = cat1.id;
    //     insert offCat2;
        
    //     PMP_Partner_Offering_Category__c offCat3 = new PMP_Partner_Offering_Category__c();
    //     offCat3.Name = 'Component'; // value change from Application to Use Cases
    //     offCat3.PMP_Offering_Category_External_Key__c = 'NPP_02_Comp';
    //     offCat3.PMP_Offering_Id__c = off1.Id;
    //     offCat3.PMP_Category_Id__c = catCmp.id;
    //     insert offCat3;
        
    //     PMP_Partner_Offering_Category__c offCat4 = new PMP_Partner_Offering_Category__c();
    //     offCat4.Name = 'Board'; // value change from Application to Use Cases
    //     offCat4.PMP_Offering_Category_External_Key__c = 'NPP_02_Board';
    //     offCat4.PMP_Offering_Id__c = off1.Id;
    //     offCat4.PMP_Category_Id__c = catBoard.id;
    //     insert offCat4;
        
        
    //     CardData offeringData = new CardData();
    //     offeringData.cardType = PMP_StaticConstants_Partner.Offering;
    //     offeringData.id=offCat2.PMP_Offering_Id__c;
    //     offeringData.title = offCat2.PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c;
    //     offeringData.tagline = offCat2.PMP_Offering_Id__r.PMP_Partner_Offering_Tag_Line_Txt__c;
    //     offeringData.description = offCat2.PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c;
    //     offeringData.imageUrl = PMP_StaticConstants_Partner.staticProductUrl;
    //     offeringData.imageAlt = offCat2.PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c;
    //     offeringData.featured = offCat2.PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c;
        
    //     Map<String,CardData> offeringMap = new Map<String,CardData>();
    //     offeringMap.put(offeringData.id, offeringData);
        
    //     String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
    //     PMP_Company_Translation__c translation = new PMP_Company_Translation__c(PMP_English_Txt__c='12345', PMP_Field_Nm__c=streamIdName, PMP_Company_Information_Id__c=partner1.Id);
    //     insert translation;
        
    //     List<PMP_Partner_Offering_Translation__c> translationList = new List<PMP_Partner_Offering_Translation__c>();
        
    //     PMP_Partner_Offering_Translation__c offTranslation3 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(off1.id,'testTranslation','PMP_Partner_Offering_Tag_Line_Txt__c','TestTagLine');
    //     PMP_Partner_Offering_Translation__c offTranslation4 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(off1.id,'testTranslation','PMP_Partner_Offering_Tag_Line_Txt__c','TestTagLine');
    //     PMP_Partner_Offering_Translation__c offTranslation5 = PMP_TestDataUtility.createOfferingTranslationsWithFieldNames(off1.id,'testTranslation','PMP_Partner_Offering_Tag_Line_Txt__c','TestTagLine');

    //     if(offTranslation3!=null){
    //         offTranslation3.PMP_Field_Nm__c = PMP_StaticConstants_Partner.OFFERING_NAME;
    //         translationList.add(offTranslation3);
    //     }
        
    //     if(offTranslation4!=null){
    //         offTranslation4.PMP_Field_Nm__c = PMP_StaticConstants_Partner.OFFERING_DESCRIPTION;
    //         translationList.add(offTranslation4);
    //     }
    //     if(offTranslation5!=null){
    //         offTranslation5.PMP_Field_Nm__c = PMP_StaticConstants_Partner.OFFERING_TAGLINE;
    //         translationList.add(offTranslation5);
    //     }
        
    //     if(!translationList.isEmpty()){
    //         insert translationList;
    //     }
        
    //     FilterData filterdata = new Filterdata();
    //     filterdata.id = cat0.id;
    //     filterdata.label = 'Category'; //category.Name;
    //     filterdata.count = 0;
    //     filterdata.children = new Set<String>();
    //     filterdata.relatedOfferings = new Set<String>();
    //     Map<Id, FilterData> myMap = new Map<Id, FilterData>();
    //     myMap.put(cat1.PMP_Parent_Category_Id__c,filterdata);
    //     //.mapParentToChildFilterData=myMap;
        
    //     Test.setMock(HttpCalloutMock.class, new PMP_CompanyArticlesMock());
        
    //     Test.startTest();
    //     PMP_MarketplaceNewPartnerDetailFeed mptest = new PMP_MarketplaceNewPartnerDetailFeed();
    //     //PMP_MarketplaceNewPartnerDetailFeed.getStorefrontFeedDetails(partner2.Id, 'en_US');
    //     //PMP_MarketplaceNewPartnerDetailFeed.getPartnerOfferings(item, partner1.Id, 'Test_Partner1', 'en_US');
    //     //PMP_MarketplaceNewPartnerDetailFeed.getFilterData(item,offeringMap.keySet(),'en_US');
    //     //PMP_MarketplaceNewPartnerDetailFeed.getFilterCount(cat0.id);
    //     Test.stopTest();
    //     system.assertNotEquals(cat0.id, null);
    // }
    
    // static testMethod void getPartnerDetailsPositiveTest1(){
        
    //     List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Industry_Id',PMP_Value__c='NPP_01_Industry'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Application_Id',PMP_Value__c='NPP_01_APP'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Region_Id',PMP_Value__c='NPP_GeographicCoverage'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_LOEM_ODM_Partner_Program',PMP_Value__c='LOEM-ODM Partner Program'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_BENEFIT_ENHANCED_CODE',PMP_Value__c='BFTMKTPLED'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Sys_Admin_Profile',PMP_Value__c='System Administrator'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_IT_Admin_Profile',PMP_Value__c='IT Admin'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Thumbnail_Image',PMP_Value__c='Thumbnail Image'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
    //     stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
    //     insert stList;
        
    //     StorefrontFeedItem item = new StorefrontFeedItem();
    //     item.cardData=new List<cardData>(); 
    //     item.filterStructure = new List<FilterStructure>(); 
    //     item.filterData = new Map<id,FilterData>();
    //     item.totalItems = 0;
        
    //     Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);        
    //     PMP_Company__c partner3 = PMP_SearchTestDataFactory.createCompanyInformation('testPartner', testAccount.Id, true);
    //     partner3.PMP_Is_Working_Copy_Ind__c = true;
    //     update partner3;
    //     String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
    //     PMP_Company_Translation__c translation = new PMP_Company_Translation__c(PMP_English_Txt__c='12345', PMP_Field_Nm__c=streamIdName, PMP_Company_Information_Id__c=partner3.Id);
    //     insert translation;
        
    //     Test.setMock(HttpCalloutMock.class, new PMP_CompanyArticlesMock());
        
    //     Test.startTest();
    //     //PMP_MarketplaceNewPartnerDetailFeed.getArticles(item,partner3.id,'en_US');
    //     Test.stopTest();
    //     system.assertNotEquals(partner3.id, null);
    // }
}