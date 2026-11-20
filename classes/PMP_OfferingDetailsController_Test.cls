/****************************************************************************************************************************************
* Class Name  : PMP_OfferingDetailsController_Test
* Version     : 1.0 
* Created Date: 11-22-2018
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* PMP Team     11/22/2018                    Test class of Core_PMP_CreateOfferingsTest
*****************************************************************************************************************************************/

@isTest
public class PMP_OfferingDetailsController_Test {
    
   /*@testSetup static void setup() {
        // Create common test accounts
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
       Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
       Account acc2 = PMP_TestDataUtility.createAccount('TestPartnerAccount1', devRecordTypeId, true);
       
       
       
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
    cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
         update cmp1;
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= acc1.Id;
        jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun.Is_Active__c=true;     
        insert jun;
               
                                
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering1','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
       
        PMP_Partner_Offering_Category__c offCategory = PMP_TestDataUtility.getPMPOfferingCategory(offering1.id);
        
        PMP_Partner_Offering_Specification__c offSpecs = PMP_TestDataUtility.getPMPOfferingSpecification(offering1.id);
        
        PMP_Partner_Offering__c offering2 = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
                                                                                 
        PMP_Partner_Offering_Category__c offCategory2 = PMP_TestDataUtility.getPMPOfferingCategory(offering2.id);
        
        PMP_Partner_Offering_Specification__c offSpecs2 = PMP_TestDataUtility.getPMPOfferingSpecification(offering2.id);
        
        List<PMP_Partner_Offering_Translation__c> translationList = new List<PMP_Partner_Offering_Translation__c>();
        
        PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation!=null){
           offTranslation.PMP_English_Txt__c = 'Test';
           offTranslation.PMP_Chinese_Txt__c = 'Test';
           offTranslation.PMP_Japanese_Txt__c = 'Test';
           offTranslation.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
           translationList.add(offTranslation);
        }
        
        PMP_Partner_Offering_Translation__c offTranslation2 = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation2!=null){
           offTranslation2.PMP_English_Txt__c = 'Test';
           offTranslation2.PMP_Chinese_Txt__c = 'Test';
           offTranslation2.PMP_Japanese_Txt__c = 'Test';
           offTranslation2.PMP_Field_Nm__c = 'PMP_Partner_Offering_Dsc__c';
           translationList.add(offTranslation2);
        }
        
        PMP_Partner_Offering_Translation__c offTranslation3 = PMP_TestDataUtility.createOfferingTranslation(offering1.id,'testTranslation');
        if(offTranslation3!=null){
           offTranslation3.PMP_English_Txt__c = 'Test';
           offTranslation3.PMP_Chinese_Txt__c = 'Test';
           offTranslation3.PMP_Japanese_Txt__c = 'Test';
           offTranslation3.PMP_Field_Nm__c = 'PMP_Partner_Offering_Tag_Line_Txt__c';
           translationList.add(offTranslation3);
        }
        
        if(!translationList.isEmpty()){
            insert translationList;
        }
        
        //Gireesh
        PMP_OfferingDetailsController.offeringSpecValueMap off=new PMP_OfferingDetailsController.offeringSpecValueMap();
       off.masterCategory='';
       off.valueList=new List<string>();
       off.category='test';
       
        PMP_Partner_Offering__c offering3 = PMP_TestDataUtility.createOffering('TestDuplicateOffering3','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Draft','');
        PMP_Partner_Offering__c offering4 = PMP_TestDataUtility.createOffering('TestDuplicateOffering4','Public Content', 
                                                                                 'TestDuplicate',cmp1.Id, true,'Published','');
        
        offering4.PMP_Working_Copy_Id__c=offering3.id;
        update offering4;
    }
    
    @isTest
    public static void fetchOfferingDetailTest(){
        Test.startTest();
        PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
        insert apiKey;
        Account acc1 = [select id from Account where Name=:'TestAccount1']; 
        //Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
        
        PMP_Company__c cmp1 = [select id, Name, PMP_Account_Id__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c,PMP_Account_Address_Txt__c
                               ,PMP_Account_Industry__c, PMP_Account_Application__c
                               , PMP_Account_Region__c,PMP_Account_Website__c,
                               PMP_Account_Program_Membership__c, PMP_Account_Specialty__c, toLabel(PMP_Company_Lead_Gen_Language_Nm__c) from PMP_Company__c where Name=:'TestCompany1' limit 1]; 
        
        
        PMP_Partner_Offering__c offering1 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1' limit 1];
        
        PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
        
        PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
        
        PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
        
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        
        PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        PMP_Partner_Offering_Resource__c offeringResource = PMP_TestDataUtility.createOfferingResourceInstance('res1','www.intel.com',offering1.Id,'Data Sheet','');
        offeringResource.PMP_Partner_Offering_Image__c = contentDocument[0].id;
        insert offeringResource;
        
        List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
        
  
        offering1.PMP_Working_Copy_Id__c = offering2.id;
        update offering1;
        
        //string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        //string offeringsChinese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'zh_CN','en_US',true);
        //string offeringsJapanese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'ja_JP','en_US',true);
        string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US', null);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null);
        //Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview
        //System.assertNotEquals(offerings,'');
        
        List<Id> offeringIds = new List<Id>();
        offeringIds.add(offering1.Id);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Intel® Solutions Marketplace Profile'].Id;
        //  PMP_StaticConstants_Offering.guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};                  
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason1@gmail.com',
                            Username = 'testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                            ProfileId = profileId, 
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'ja',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'ja'
                           ); 
        insert usr;
        System.runAs(usr){
            Map<String,object> fetchOfferingDetailsMap = PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,false,false,false,'en-US', false);
            map<String,object> fetchOfferingDetailsMap2 = PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,false,false,false,'ja', true);
            map<String,object> fetchOfferingDetailsMap3 = PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,false,false,false,'zh_Hans_CN', false);
            map<String,object> fetchOfferingDetailsMap4 = PMP_OfferingDetailsController.fetchOfferingDetails(offeringIds,false,false,true,null, false);

            System.assertNotEquals(fetchOfferingDetailsMap.get('offerings'),Null);
        }
        Test.stopTest();
        
    }
        
        @isTest
    public static void cloneOfferingTest(){
            PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
            insert apiKey;
        Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
                    
            PMP_Company__c cmp1 = [select id from PMP_Company__c where Name=:'TestCompany1']; 
                                    
            PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
            
            PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
            
            PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
            
            PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
            
            list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
            
            PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
            
            PMP_Partner_Offering_Resource__c getResources1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering2.id);
            
            List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
            
            
      
            offering1.PMP_Working_Copy_Id__c = offering2.id;
            update offering1;
            
            
            Test.startTest();

            PMP_OfferingDetailsController.cloneOfferingDetail(offering2.Id,'en_US');
   
            offering1.PMP_Partner_Offering_Nm__c = 'Test record for having length greater than 255 as we need to cover a block in test class. Adding random paragraph, Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text';
            update offering1;
            
            String response = PMP_OfferingDetailsController.cloneOfferingDetail(offering2.Id,'en_US');
            
            system.assertNotEquals(response,Null);
        
            Test.stopTest();
                    
        }
    @isTest
    public static void contentAssetTest(){
        
        
        PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        PMP_Partner_Offering_Resource__c resource1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        resource1.PMP_Resource_Type_Nm__c = 'Thumbnail Image';
        update resource1;    
        PMP_Partner_Offering_Resource__c resource2 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        
        test.startTest();
        //string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        string offerings1 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'NA','en_US',true);
        
        //string offerings2 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US',true);
        string offerings3 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'ja',true);
        //string offerings4 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,null,true);
        string offerings5 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,true,'en_US','en_US',true);
        system.assertNotEquals(offerings1,Null);
        test.stopTest();
        
        
    }
    @isTest
    public static void previewTest(){
        PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        test.startTest();
        string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        test.stopTest();
        system.assertNotEquals(offerings,Null);
    }
     @isTest static void testFetchOfferingDetailNotPreview(){
         
         
        PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        PMP_Partner_Offering_Resource__c resource1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        resource1.PMP_Resource_Type_Nm__c = 'Thumbnail Image';
        update resource1;    
        PMP_Partner_Offering_Resource__c resource2 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        Test.startTest();
        string response=PMP_OfferingDetailsController.fetchOfferingDetailNotPreview(offering1.Id, true, true, false,'en_US','en_US',true);
		resource1.PMP_Resource_Type_Nm__c = System.Label.PMP_Image; 
        update resource1;
        string response1=PMP_OfferingDetailsController.fetchOfferingDetailNotPreview(offering1.Id, true, true, false,'en_US','en_US',true);													  																																   
        Test.stopTest();
        
        system.assertNotEquals(response,Null); 
    }
    
 @isTest static void testGetOfferingDetail(){
     PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        PMP_Partner_Offering_Resource__c resource1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        resource1.PMP_Resource_Type_Nm__c = 'Thumbnail Image';
        update resource1;    
        PMP_Partner_Offering_Resource__c resource2 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
     Test.startTest();
        String response=PMP_OfferingDetailsController.getOfferingDetail(offering1.Id, true, true, false,'en_US','en_US',true);
     String response1=PMP_OfferingDetailsController.getOfferingDetail(offering1.Id, true, true, false,'en_US','en_US',false);
        Test.stopTest();
     
     system.assertNotEquals(response,Null); 
 }

 @isTest static void testGetOfferingProductDetails(){
    PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
     PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
     offering1.PMP_Working_Copy_Id__c = offering2.Id;
     update offering1;
       list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
       PMP_Partner_Offering_Resource__c resource1 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
       resource1.PMP_Resource_Type_Nm__c = 'Thumbnail Image';
       update resource1;    
       PMP_Partner_Offering_Resource__c resource2 = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
    Test.startTest();
       String response=PMP_OfferingDetailsController.getOfferingDetailProductDetails(offering1.Id, true, true, false,'en_US','en_US',true);
    String response1=PMP_OfferingDetailsController.getOfferingDetailProductDetails(offering1.Id, true, true, false,'en_US','en_US',false);
       Test.stopTest();
    
    system.assertNotEquals(response,Null); 
}
 
 @istest static void testUpdateOfferingDates(){
         PMP_Partner_Offering__c offering1 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
         Test.startTest();
         offering1.PMP_Partner_Offering_Start_Dt__c = Date.today().addDays(10);
         offering1.PMP_Partner_Offering_End_Dt__c = Date.today().addDays(20);
         
         PMP_OfferingDetailsController.updateOfferingDates(offering1);
           Test.stopTest();
         PMP_Partner_Offering__c updatedOffering = [select id,PMP_Partner_Offering_Start_Dt__c  from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
         system.assertEquals(updatedOffering.PMP_Partner_Offering_Start_Dt__c , Date.today().addDays(10)  );
         
 }
    @isTest Static void testPlatformCache(){
        PMP_Partner_Offering__c offeringCache = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1'];
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Intel® Solutions Marketplace Profile'].Id;
      //  PMP_StaticConstants_Offering.guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};                    
        User usr = new User(LastName = 'LIVESTON',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason1@gmail.com',
                           Username = 'testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                           ProfileId = profileId, 
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           ); 
        
      //  User usr = [select ProfileId from User where ProfileId=:profileId LIMIT 1];
        insert usr;
        System.runAs(usr){
        //System.debug('Current User-'+userInfo.getUserId());
            Test.startTest();
            
            String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
            Boolean isPreview = true;
            
            string key = offeringCache.id+'enUS';
            String cacheFlag = PMP_Utility.getValue('Cache_Flag');
               
            Cache.Org.put(partitionInput+'.'+key, 'TestString',86400);
            Cache.Org.put(partitionInput+'.'+offeringCache.id+'ja', 'TestString',86400);
            Cache.Org.contains(partitionInput+'.'+ key); 
            System.assertEquals(Cache.Org.contains(partitionInput+'.'+ key),true);
            PMP_OfferingDetailsController.fetchOfferingDetail(offeringCache.Id,false,true,false,'en_US','en_US',false);
            PMP_OfferingDetailsController.fetchOfferingDetail(offeringCache.Id,false,true,false,'en_US','en_US',true);
            Test.stopTest();
        
        }
            
    }
    @isTest
    public static void partnerDetailsTest1(){
        
        
        Test.startTest();
        // System.debug('LIMITS++++++====:'+Limits.getQueries());
        
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Region_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_ENHANCED_CODE';
        st.PMP_Value__c = 'BFTMKTPLED';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Sys_Admin_Profile';
        st.PMP_Value__c = 'System Administrator';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_IT_Admin_Profile';
        st.PMP_Value__c = ' IT Admin';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
        

        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        update acc1;
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,false);
        cmp1.PMP_Account_Industry__c = 'Agriculture';
        cmp1.PMP_Account_Application__c= 'Storage';
        cmp1.PMP_Account_Region__c = 'APJ';
        cmp1.PMP_Account_Sub_Region__c = 'ANZ';
       // cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist;LOEM-ODM Partner Program';
        cmp1.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp1.PMP_Account_Website__c = 'www.TestCompany1.com';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        cmp1.PMP_Partner_Program_nm__c='ODM-LOEM';
        //cmp1.PMP_Account_Program_Membership__c='Member';
        cmp1.PMP_Account_Program_Membership__c='ITP - Gold';
        cmp1.PMP_Account_Program_Membership__c='LOEM-ODM Partner Program';
        cmp1.PMP_Disti_Components_Nm__c =  'Data Center'; //'Client Computing';
        cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center'; //'Client Computing';
        cmp1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        cmp1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;  
        
   //  cmp1.PMP_Account_Specialty__c=PMP_Static_Constants__c.getValu'LOEM-ODM Partner Program');
        
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Account_Id__c = acc1.Id;
        insert cmp1;
        // system.debug('cmp1'+cmp1);
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=cmp1.Id;
        resource.PMP_Company_Image__c=document.Id;
        resource.PMP_Company_Resource_Type_Nm__c='Image';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert resource;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
       //partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        //partner1.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        //partner1.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner1.PMP_Is_Published_Ind__c = true;
        partner1.PMP_Account_Id__c = acc1.Id;
        partner1.PMP_Disti_Components_Nm__c = 'Data Center'; //'Client Computing';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center'; //'Client Computing';
        partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        insert partner1;
        
        List<PMP_Partner_Offering__c> offList = new  List<PMP_Partner_Offering__c>();
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = cmp1.Id;
        //insert off;
        offList.add(off);
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = cmp1.Id;
        //insert off1;
        offList.add(off1);
        insert offList;
        
        List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec0;
        specList.add(spec0);
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec1;
        specList.add(spec1);
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec2;
        specList.add(spec2);
        
        insert specList;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        List<PMP_Company_Region__c> ptnrSpecList = new List<PMP_Company_Region__c>();
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = specList[1].Id;
        ptnrSpec.PMP_Company_Id__c = cmp1.Id;
        //insert ptnrSpec;
        ptnrSpecList.add(ptnrSpec);
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = specList[1].Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        //insert ptnrSpec1;
        ptnrSpecList.add(ptnrSpec1);
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = specList[2].Id;
        ptnrSpec2.PMP_Company_Id__c = cmp1.Id;
        //insert ptnrSpec2;
        ptnrSpecList.add(ptnrSpec2);
        insert ptnrSpecList;
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        //cat0.PMP_Parent_Category_Id__c = null; 
        //app0.PMP_Parent_Category_Id__c = null;
        //ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        //Test.startTest();
        //system.debug('testing===>'+cmp1);
        
        
        PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
        insert apiKey;
       // Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
        
        PMP_Partner_Offering__c offering1 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1' limit 1];
        
        PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
        
        PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
        
        PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
        
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        
        PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        
        
        List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
        
  
        offering1.PMP_Working_Copy_Id__c = offering2.id;
        update offering1;
        
        Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
        //Added by Gireesh
        pagMem.Core_Partner_Account_Id__c = acc2.Id;
        pagMem.Core_Intel_Account_Id__c = acc1.Id;
        insert pagMem;
               
        
        //string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        //string offeringsChinese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'zh_CN','en_US',true);
        //string offeringsJapanese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'ja_JP','en_US',true);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US', null);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null);
        //Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview
        //System.assertNotEquals(offerings,'');
        
        //PMP_ProductPartnerDetailsController.getPartnerDetails(offering1.Id,offering1.PMP_Company_Id__c,null,true,'en_US');
        PMP_ProductPartnerDetailsController.getPartnerDetails(offering1.PMP_Company_Id__c,null,true,'en_US');
       
        List<Id> offeringIds = new List<Id>();
        offeringIds.add(offering1.Id);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Intel® Solutions Marketplace Profile'].Id;
        //  PMP_StaticConstants_Offering.guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};                  
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason1@gmail.com',
                            Username = 'testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                            ProfileId = profileId, 
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'ja',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'ja'
                           ); 
        insert usr;
               
        System.runAs(usr){

           //String fetchOfferingDetailsMap = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US',null);
            String fetchOfferingDetailsMap2 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,false,false,false,null,'en_US',null);
            system.assertNotEquals(fetchOfferingDetailsMap2,Null);
            PMP_OfferingDetailsController.checkValidOffering(offering1.id, false);
        }
        PMP_OfferingDetailsController.checkValidOffering(offering1.id, false);
        // System.debug('LIMITS++++++====:'+Limits.getQueries());
        Test.stopTest();
        
    
    
    }
    
    @isTest
    public static void partnerDetailsTest2(){
        
        Test.startTest();
        
        // System.debug('LIMITS++++++====:'+Limits.getQueries());
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Region_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_ENHANCED_CODE';
        st.PMP_Value__c = 'BFTMKTPLED';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Sys_Admin_Profile';
        st.PMP_Value__c = 'System Administrator';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_IT_Admin_Profile';
        st.PMP_Value__c = ' IT Admin';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
        

        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        update acc1;
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,false);
        cmp1.PMP_Account_Industry__c = 'Agriculture';
        cmp1.PMP_Account_Application__c= 'Storage';
        cmp1.PMP_Account_Region__c = 'APJ';
        cmp1.PMP_Account_Sub_Region__c = 'ANZ';
        //cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist;LOEM-ODM Partner Program';
        cmp1.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp1.PMP_Account_Website__c = 'www.TestCompany1.com';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        cmp1.PMP_Partner_Program_nm__c='ODM-LOEM';
        //cmp1.PMP_Account_Program_Membership__c='Member';
        cmp1.PMP_Account_Program_Membership__c='ITP - Gold';
        cmp1.PMP_Account_Program_Membership__c='LOEM-ODM Partner Program';
        cmp1.PMP_Disti_Components_Nm__c = 'Data Center'; //'Client Computing';
        cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center'; //'Client Computing';
        cmp1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        cmp1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;  
        
   //  cmp1.PMP_Account_Specialty__c=PMP_Static_Constants__c.getValu'LOEM-ODM Partner Program');
        
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Account_Id__c = acc1.Id;
        insert cmp1;
        // system.debug('cmp1'+cmp1);
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=cmp1.Id;
        resource.PMP_Company_Image__c=document.Id;
        resource.PMP_Company_Resource_Type_Nm__c='Image';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert resource;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
       //partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        //partner1.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        //partner1.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner1.PMP_Is_Published_Ind__c = true;
        partner1.PMP_Account_Id__c = acc1.Id;
        partner1.PMP_Disti_Components_Nm__c = 'Data Center'; //'Client Computing';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center'; //'Client Computing';
        partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        insert partner1;
        
        List<PMP_Partner_Offering__c> offList = new  List<PMP_Partner_Offering__c>();
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = cmp1.Id;
        //insert off;
        offList.add(off);
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = cmp1.Id;
        //insert off1;
        offList.add(off1);
        insert offList;
        
        List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec0;
        specList.add(spec0);
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec1;
        specList.add(spec1);
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec2;
        specList.add(spec2);
        
        insert specList;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        List<PMP_Company_Region__c> ptnrSpecList = new List<PMP_Company_Region__c>();
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = specList[1].Id;
        ptnrSpec.PMP_Company_Id__c = cmp1.Id;
        //insert ptnrSpec;
        ptnrSpecList.add(ptnrSpec);
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = specList[1].Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        //insert ptnrSpec1;
        ptnrSpecList.add(ptnrSpec1);
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = specList[2].Id;
        ptnrSpec2.PMP_Company_Id__c = cmp1.Id;
        //insert ptnrSpec2;
        ptnrSpecList.add(ptnrSpec2);
        insert ptnrSpecList;
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        //cat0.PMP_Parent_Category_Id__c = null; 
        //app0.PMP_Parent_Category_Id__c = null;
        //ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        //Test.startTest();
        //system.debug('testing===>'+cmp1);
        //Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(cmp1.Id,null,true,'en_US');
        
        
        PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
        insert apiKey;
       // Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
        
        PMP_Partner_Offering__c offering1 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1' limit 1];
        
        PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
        
        PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
        
        PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
        
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        
        PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        
        
        List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
        
  
        offering1.PMP_Working_Copy_Id__c = offering2.id;
        update offering1;
        
        Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
        //Added by Gireesh
        pagMem.Core_Partner_Account_Id__c = acc2.Id;
        pagMem.Core_Intel_Account_Id__c = acc1.Id;
        insert pagMem;
               
        
        //string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        //string offeringsChinese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'zh_CN','en_US',true);
        //string offeringsJapanese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'ja_JP','en_US',true);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US', null);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null);
        //Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview
        //System.assertNotEquals(offerings,'');
        
        List<Id> offeringIds = new List<Id>();
        offeringIds.add(offering1.Id);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Intel® Solutions Marketplace Profile'].Id;
        //  PMP_StaticConstants_Offering.guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};                  
        User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason1@gmail.com',
                            Username = 'testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                            ProfileId = profileId, 
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'ja',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'ja'
                           ); 
        insert usr;
               
        System.runAs(usr){

           //String fetchOfferingDetailsMap = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US',null);
            String fetchOfferingDetailsMap2 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,false,false,false,null,'en_US',null);
            system.assertNotEquals(fetchOfferingDetailsMap2,Null);
            PMP_OfferingDetailsController.checkValidOffering(offering1.id, false);
        }
        PMP_OfferingDetailsController.isMPAdmin();
        // System.debug('LIMITS++++++====:'+Limits.getQueries());
        Test.stopTest();
        
    
    }
    @isTest
    public static void partnerDetailsTest3(){
        Test.startTest();
        
        // System.debug('LIMITS++++++====:'+Limits.getQueries());
        List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Application_Id';
        st.PMP_Value__c = 'NPP_01_APP';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Region_Id';
        st.PMP_Value__c = 'NPP_GeographicCoverage';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_LOEM_ODM_Partner_Program';
        st.PMP_Value__c = 'LOEM-ODM Partner Program';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_BENEFIT_ENHANCED_CODE';
        st.PMP_Value__c = 'BFTMKTPLED';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Sys_Admin_Profile';
        st.PMP_Value__c = 'System Administrator';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_IT_Admin_Profile';
        st.PMP_Value__c = ' IT Admin';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Thumbnail_Image';
        st.PMP_Value__c = 'Thumbnail Image';
        stList.add(st);
        
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Employee',PMP_Value__c='PMP_External_Employee'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_LDR',PMP_Value__c='PMP_External_Lead_Development_Representative'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Marketing_Specialist',PMP_Value__c='PMP_External_Marketing_Specialist'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Offering_Editor',PMP_Value__c='PMP_External_Offering_Editor'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_External_Partner_Admin',PMP_Value__c='PMP_External_Partner_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Guest_User_Name',PMP_Value__c='Intel® Solutions Marketplace Site Guest User'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Internal_Intel_Admin',PMP_Value__c='PMP_Internal_Intel_Admin'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP_All_Intel_Admin_Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
        insert stList;
        

        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        acc1.Core_IPA_Partner_Role__c = 'Distributor';
        update acc1;
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,false);
        cmp1.PMP_Account_Industry__c = 'Agriculture';
        cmp1.PMP_Account_Application__c= 'Storage';
        cmp1.PMP_Account_Region__c = 'APJ';
        cmp1.PMP_Account_Sub_Region__c = 'ANZ';
        //cmp1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist;LOEM-ODM Partner Program';
        cmp1.PMP_Account_Dsc__c = 'Description below the limit.';
        cmp1.PMP_Account_Website__c = 'www.TestCompany1.com';
        cmp1.PMP_Company_Lead_Gen_Language_Nm__c='English';
        cmp1.PMP_Partner_Program_nm__c='ODM-LOEM';
        //cmp1.PMP_Account_Program_Membership__c='Member';
        cmp1.PMP_Account_Program_Membership__c='ITP - Gold';
        cmp1.PMP_Account_Program_Membership__c='LOEM-ODM Partner Program';
        cmp1.PMP_Disti_Components_Nm__c = 'Data Center'; //'Client Computing';
        cmp1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center'; //'Client Computing';
        cmp1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        cmp1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;  
        
   //  cmp1.PMP_Account_Specialty__c=PMP_Static_Constants__c.getValu'LOEM-ODM Partner Program');
        
        cmp1.PMP_Is_Published_Ind__c = true;
        cmp1.PMP_Account_Id__c = acc1.Id;
        insert cmp1;
        // system.debug('cmp1'+cmp1);
        List<ContentDocument> doc=PMP_TestDataUtility.createContentDocument(true);
        ContentDocument document=[select Id from ContentDocument limit 1];
        PMP_Company_Resource__c resource=new PMP_Company_Resource__c();
        resource.PMP_Company_Id__c=cmp1.Id;
        resource.PMP_Company_Image__c=document.Id;
        resource.PMP_Company_Resource_Type_Nm__c='Image';
        resource.PMP_Company_Resource_Sequence_Nbr__c=0;
        insert resource;
        
        PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
       //partner1.PMP_Account_Specialty__c = 'Artificial Intelligence Specialist';
        //partner1.PMP_Account_Specialty__c=PMP_StaticConstants_Partner.LOEM_ODM_Partner_Program;
        //partner1.PMP_Account_Specialty__c='LOEM-ODM Partner Program';
        partner1.PMP_Is_Published_Ind__c = true;
        partner1.PMP_Account_Id__c = acc1.Id;
        partner1.PMP_Disti_Components_Nm__c = 'Data Center'; //'Client Computing';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center'; //'Client Computing';
        partner1.PMP_Partner_Primary_Street_Txt__c = 'Acc Address';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'India';
        insert partner1;
        
        List<PMP_Partner_Offering__c> offList = new  List<PMP_Partner_Offering__c>();
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = cmp1.Id;
        //insert off;
        offList.add(off);
       
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = cmp1.Id;
        //insert off1;
        offList.add(off1);
        insert offList;
        
        List<PMP_Specification__c> specList = new List<PMP_Specification__c>();
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec0;
        specList.add(spec0);
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec1;
        specList.add(spec1);
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        //insert spec2;
        specList.add(spec2);
        
        insert specList;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop' );
        insert specValue;
        
        List<PMP_Company_Region__c> ptnrSpecList = new List<PMP_Company_Region__c>();
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = specList[1].Id;
        ptnrSpec.PMP_Company_Id__c = cmp1.Id;
        //insert ptnrSpec;
        ptnrSpecList.add(ptnrSpec);
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = specList[1].Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        //insert ptnrSpec1;
        ptnrSpecList.add(ptnrSpec1);
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = specList[2].Id;
        ptnrSpec2.PMP_Company_Id__c = cmp1.Id;
        //insert ptnrSpec2;
        ptnrSpecList.add(ptnrSpec2);
        insert ptnrSpecList;
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        //cat0.PMP_Parent_Category_Id__c = null; 
        //app0.PMP_Parent_Category_Id__c = null;
        //ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        PMP_Partner_Category__c ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = app1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        PMP_Partner_Category__c ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = app2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = ind1.Id;
        ptnrCat.PMP_Partner_Id__c = cmp1.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
        //Test.startTest();
        //system.debug('testing===>'+cmp1);
        //Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(cmp1.Id,null,true,'en_US');
        
        
        PMP_Product_API_Key__c apiKey = New PMP_Product_API_Key__c(Name = 'API_Key' , PMP_API_KEY__c = 'abcde');
        insert apiKey;
       // Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
        
        PMP_Partner_Offering__c offering1 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1' limit 1];
        
        PMP_Partner_Offering__c offering2 = [select id from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering2'];
        
        PMP_Partner_Offering_Category__c offCategory = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offering1.Id];
        
        PMP_Partner_Offering_Specification__c offSpecs = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c=:offering1.Id];
        
        list<contentDocument> contentDocument = PMP_TestDataUtility.createContentDocument(true);
        
        PMP_Partner_Offering_Resource__c getResources = PMP_TestDataUtility.getResources(contentDocument[0].id, offering1.id);
        
        
        List<PMP_Partner_Offering_Translation__c> offTrans = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c =:offering1.Id];
        
  
        offering1.PMP_Working_Copy_Id__c = offering2.id;
        update offering1;
        
        Core_Account_Group_Member__c pagMem = new Core_Account_Group_Member__c();
        //Added by Gireesh
        pagMem.Core_Partner_Account_Id__c = acc2.Id;
        pagMem.Core_Intel_Account_Id__c = acc1.Id;
        insert pagMem;
               
        
        //string offerings = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'en_US','en_US',true);
        //string offeringsChinese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'zh_CN','en_US',true);
        //string offeringsJapanese = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,'ja_JP','en_US',true);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US', null);
        //string offeringsNoLang = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null);
        //Id offeringId, Boolean bEditOffering, Boolean bViewOffering, Boolean bCompareOffering,string language, String langCode,boolean isPreview
        //System.assertNotEquals(offerings,'');
        
        List<Id> offeringIds = new List<Id>();
        offeringIds.add(offering1.Id);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Intel® Solutions Marketplace Profile'].Id;
        //  PMP_StaticConstants_Offering.guestProfiles = new String[]{'Intel® Solutions Marketplace Profile'};                  
       /* User usr = new User(LastName = 'LIVESTON',
                            FirstName='JASON',
                            Alias = 'jliv',
                            Email = 'jason1@gmail.com',
                            Username = 'testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                            ProfileId = profileId, 
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'ja',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'ja'
                           ); 
        insert usr;
               
        System.runAs(usr){

           //String fetchOfferingDetailsMap = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,true,true,false,null,'en_US',null);
            String fetchOfferingDetailsMap2 = PMP_OfferingDetailsController.fetchOfferingDetail(offering1.id,false,false,false,null,'en_US',null);
            system.assertNotEquals(fetchOfferingDetailsMap2,Null);
            PMP_OfferingDetailsController.checkValidOffering(offering1.id, false);
        }
        PMP_OfferingDetailsController.isOfferingPermissionUser();
        PMP_OfferingDetailsController.checkValidOffering(offering1.id, false);
        // System.debug('LIMITS++++++====:'+Limits.getQueries());
        Test.stopTest();
        
    }   
     @isTest
    public static void checkValidOfferingTest2(){
        Test.startTest();
        Account acc1 = [select id from Account where Name=:'TestAccount1'];
        Account acc2 = [select id from Account where Name=:'TestPartnerAccount1'];
        Contact con1 = [Select Id from Contact where FirstName = 'Test'and LastName='Contact' Limit 1];
        PMP_Partner_Offering__c offering1 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering1' limit 1];
        User adminUser = [Select Id, UserRoleId From User where Id=:userinfo.getUserId() Limit 1];
        adminUser.UserRoleId = [Select Id, DeveloperName From UserRole where DeveloperName='Admin'].Id;
        update adminUser;
        List<Id> offeringIds = new List<Id>();
        offeringIds.add(offering1.Id);
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Partner'].Id;        
        System.runAs(adminUser){
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                Alias = 'jliv',
                                Email = 'jason2@gmail.com',
                                Username = 'testUser2'+String.valueOf(Math.random())+'@CoreMDF.com',
                                ProfileId = profileId, 
                                ContactId = con1.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'ja',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'ja'
                               );  
            insert usr; 
        }
        User u =[Select Id from User where Email ='jason2@gmail.com' Limit 1];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Offering_Editor' Limit 1];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        System.runAs(u){
            PMP_OfferingDetailsController.checkValidOffering(offering1.id, false);
        }
        Test.stopTest();
    }
     @isTest
    public static void getOfferingDetailProductDetailsTest2(){
        Test.startTest();
        Contact con1 = [Select Id from Contact where FirstName = 'Test'and LastName='Contact' Limit 1];
        PMP_Partner_Offering__c offering4 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering4' limit 1];
        User adminUser = [Select Id, UserRoleId From User where Id=:userinfo.getUserId() Limit 1];
        adminUser.UserRoleId = [Select Id, DeveloperName From UserRole where DeveloperName='Admin'].Id;
        update adminUser;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Partner'].Id;        
        System.runAs(adminUser){
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                Alias = 'jliv',
                                Email = 'jason3@gmail.com',
                                Username = 'testUser3'+String.valueOf(Math.random())+'@CoreMDF.com',
                                ProfileId = profileId, 
                                ContactId = con1.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'ja',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'ja'
                               );  
            insert usr; 
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Offering_Editor' Limit 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = usr.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();
            partOfferingShare.AccessLevel  = 'Edit';
            partOfferingShare.UserOrGroupId  = usr.id;
            partOfferingShare.ParentId = offering4.Id;
            insert partOfferingShare;
        }
        User u =[Select Id from User where Email ='jason3@gmail.com' Limit 1];
       
        System.runAs(u){
           PMP_OfferingDetailsController.getOfferingDetailProductDetails(offering4.Id, true, true, false,'en_US','en_US',true);
           PMP_OfferingDetailsController.getOfferingDetailProductDetails(offering4.Id, true, true, true,'en_US','en_US',true);
        }
         Test.stopTest();
    }
     @isTest
    public static void fetchPreviewOfferingDetailTest2(){
        Test.startTest();
        Contact con1 = [Select Id from Contact where FirstName = 'Test'and LastName='Contact' Limit 1];
        PMP_Partner_Offering__c offering4 = [select id, PMP_Company_Id__c from PMP_Partner_Offering__c where Name=:'TestDuplicateOffering4' limit 1];
        User adminUser = [Select Id, UserRoleId From User where Id=:userinfo.getUserId() Limit 1];
        adminUser.UserRoleId = [Select Id, DeveloperName From UserRole where DeveloperName='Admin'].Id;
        update adminUser;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Partner'].Id;        
        System.runAs(adminUser){
            User usr = new User(LastName = 'LIVESTON',
                                FirstName='JASON',
                                Alias = 'jliv',
                                Email = 'jason4@gmail.com',
                                Username = 'testUser4'+String.valueOf(Math.random())+'@CoreMDF.com',
                                ProfileId = profileId, 
                                ContactId = con1.id,
                                TimeZoneSidKey = 'GMT',
                                LanguageLocaleKey = 'ja',
                                EmailEncodingKey = 'UTF-8',
                                LocaleSidKey = 'ja'
                               );  
            insert usr; 
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'PMP_External_Offering_Editor' Limit 1];
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = usr.Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
            PMP_Partner_Offering__Share partOfferingShare = new PMP_Partner_Offering__Share();
            partOfferingShare.AccessLevel  = 'Edit';
            partOfferingShare.UserOrGroupId  = usr.id;
            partOfferingShare.ParentId = offering4.Id;
            insert partOfferingShare;
        }
        User u =[Select Id from User where Email ='jason4@gmail.com' Limit 1];
       
        System.runAs(u){
           PMP_OfferingDetailsController.fetchOfferingDetail(offering4.id,false,false,false,null,null,true);
           PMP_OfferingDetailsController.fetchOfferingDetail(offering4.id,false,false,false,'ja',null,false);
           PMP_OfferingDetailsController.fetchOfferingDetail(offering4.id,false,false,false,'zh_Hans_CN',null,false);
           PMP_OfferingDetailsController.fetchOfferingDetail(offering4.id,false,true,false,'',null,false);
        }
         Test.stopTest();
    }
    
     @isTest
    static void buildMarketingInfoTest4(){
        
        List<PMP_Category__c> categories = new List<PMP_Category__c>();
         PMP_Category__c cat1 = new PMP_Category__c();
         cat1.Name='Industry';
         cat1.PMP_Category_Chinese_Nm__c='Chinese';
         cat1.PMP_Category_Japanese_Nm__c='Japanese';
         cat1.PMP_Active_Ind__c=true;
         cat1.PMP_Partner_Product_Category_Cd__c='NPP_01_TYPE';
         cat1.PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy';
         cat1.PMP_Partner_Product_Category_Key__c='npp_01_type';
             
         PMP_Category__c cat2 = new PMP_Category__c();
         cat2.Name='Component';
         cat2.PMP_Category_Chinese_Nm__c='Chinese';
         cat2.PMP_Category_Japanese_Nm__c='Japanese';
         cat2.PMP_Active_Ind__c=true;
         cat2.PMP_Partner_Product_Category_Cd__c='TPS_900002';
         cat2.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE';
         cat2.PMP_Partner_Product_Category_Key__c='tps_900002';
             
         PMP_Category__c cat3 = new PMP_Category__c();
         cat3.Name='FPGA Boards';
         cat3.PMP_Category_Chinese_Nm__c='Chinese';
         cat3.PMP_Category_Japanese_Nm__c='Japanese';
         cat3.PMP_Active_Ind__c=true;
         cat3.PMP_Partner_Product_Category_Cd__c='TPS_900214';
         cat3.PMP_Partner_Product_Parent_Category_Cd__c='TPS_900002';
         cat3.PMP_Partner_Product_Category_Key__c='TPS_900214';
             
         PMP_Category__c cat4= new PMP_Category__c();
         cat4.Name='Development Kits';
         cat4.PMP_Category_Chinese_Nm__c='Chinese';
         cat4.PMP_Category_Japanese_Nm__c='Japanese';
         cat4.PMP_Active_Ind__c=true;
         cat4.PMP_Partner_Product_Category_Cd__c='TPS_900218';
         cat4.PMP_Partner_Product_Parent_Category_Cd__c='TPS_900214';
         cat4.PMP_Partner_Product_Category_Key__c=' tps_900218';
        
         PMP_Category__c cat5= new PMP_Category__c();
         cat5.Name='Application';
         cat5.PMP_Category_Chinese_Nm__c='Chinese';
         cat5.PMP_Category_Japanese_Nm__c='Japanese';
         cat5.PMP_Active_Ind__c=true;
         cat5.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
         cat5.PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy';
         cat5.PMP_Partner_Product_Category_Key__c=' npp_01_app';
        
        PMP_Category__c cat6= new PMP_Category__c();
         cat6.Name='Advanced Analytics';
         cat6.PMP_Category_Chinese_Nm__c='Chinese';
         cat6.PMP_Category_Japanese_Nm__c='Japanese';
         cat6.PMP_Active_Ind__c=true;
         cat6.PMP_Partner_Product_Category_Cd__c='IPA_APP_AdvancedAnalytics';
         cat6.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_APP';
         cat6.PMP_Partner_Product_Category_Key__c='ipa_app_advancedanalytics';
          
         cat2.PMP_Parent_Category_Id__c = cat1.Id;
        cat3.PMP_Parent_Category_Id__c = cat2.Id;
        cat4.PMP_Parent_Category_Id__c = cat3.Id;
        cat6.PMP_Parent_Category_Id__c = cat5.Id;
         categories.add(cat1);
         categories.add(cat2);
         categories.add(cat3);
         categories.add(cat4);
         categories.add(cat5);
        categories.add(cat6);
   
        insert categories;
      
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.Name = cat3.Name;
        offCat2.PMP_Offering_Category_External_Key__c = 'NPP_01_TYPE';
        offCat2.PMP_Offering_Id__c = off1.Id;
        offCat2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|NPP_01_TYPE';
        offCat2.PMP_Category_Id__c = cat3.id;
        
        
        PMP_Partner_Offering_Category__c offCat4 = new PMP_Partner_Offering_Category__c();
        offCat4.Name = cat2.Name;
        offCat4.PMP_Offering_Category_External_Key__c = System.Label.PMP_NPP_01_Industry;
        offCat4.PMP_Offering_Id__c = off1.Id;
        offCat4.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        offCat4.PMP_Category_Id__c = cat2.Id;
        
        PMP_Partner_Offering_Category__c offCat5 = new PMP_Partner_Offering_Category__c();
        offCat5.Name = 'Test';
        offCat5.PMP_Offering_Category_External_Key__c = 'IPA_APP_ConnectedWorker';
        offCat5.PMP_Offering_Id__c = off1.Id;
        offCat5.PMP_Category_Id__c = cat3.Id;
        offCat5.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        
        PMP_Partner_Offering_Category__c offCat6 = new PMP_Partner_Offering_Category__c();
        //offCat6.Name = cat2.Name;
        offCat6.PMP_Offering_Category_External_Key__c = System.Label.PMP_NPP_01_Industry;
        offCat6.PMP_Offering_Id__c = off1.Id;
        offCat6.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        offCat6.PMP_Category_Id__c = cat2.Id;
        
        insertOffCategories.add(offCat2);
        insertOffCategories.add(offCat4);
        insertOffCategories.add(offCat5);
        insertOffCategories.add(offCat6);
        
        insert insertOffCategories;
        
      //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
                                                    
        PMP_Company__c testCompany = PMP_TestDataUtility.createCompanyInformation('Test_Company1', acc1.Id, true);
        
        List<PMP_Specification__c> specificationList=new List<PMP_Specification__c>();
        
        List<PMP_Partner_Offering_Specification__c> listOfferSpec=new List<PMP_Partner_Offering_Specification__c>();
        List<PMP_Partner_Offering_Specification__c> listOfferSpec2=new List<PMP_Partner_Offering_Specification__c>();
        List<PMP_Partner_Offering_Specification__c> listOfferSpec3=new List<PMP_Partner_Offering_Specification__c>();
        PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',testCompany.Id,true,'Draft','');
       
        PMP_Specification__c Spec9 = new PMP_Specification__c(); 
        Spec9.Name = 'Availability and Pricing';
        Spec9.PMP_Specification_Name__c = 'Processor Lev2';
        //Spec9.PMP_Parent_Specification_Id__c=Spec7.Id;
        Spec9.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
        Spec9.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
        Spec9.PMP_Display_Type_Nm__c='Checkbox';
        Spec9.PMP_Active_Ind__c=true;
        Spec9.PMP_Specification_Type_Nm__c='Other';
        Spec9.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec9.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec9;
        
        PMP_Specification__c Spec10 = new PMP_Specification__c(); 
        Spec10 .Name = 'Processor Lev3';
        Spec10 .PMP_Specification_Name__c = 'Processor Lev3';
        Spec10 .PMP_Parent_Specification_Id__c=Spec9.Id;
        Spec10 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
        Spec10 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
        Spec10 .PMP_Display_Type_Nm__c='Checkbox';
        Spec10 .PMP_Active_Ind__c=true;
        Spec10 .PMP_Specification_Type_Nm__c='Other';
        Spec10.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec10.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec10 ;
        
        PMP_Specification__c Spec11 = new PMP_Specification__c(); 
        Spec11.Name = 'Regional Coverage';
        Spec11.PMP_Specification_Name__c = 'Processor Lev2';
        //Spec11.PMP_Parent_Specification_Id__c=Spec7.Id;
        Spec11.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
        Spec11.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
        Spec11.PMP_Display_Type_Nm__c='Checkbox';
        Spec11.PMP_Active_Ind__c=true;
        Spec11.PMP_Specification_Type_Nm__c='Other';
        Spec11.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec11.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec11;
        
        PMP_Specification__c Spec12 = new PMP_Specification__c(); 
        Spec12 .Name = 'Processor Lev4';
        Spec12 .PMP_Specification_Name__c = 'Processor Lev4';
        Spec12 .PMP_Parent_Specification_Id__c=Spec11.Id;
        Spec12 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
        Spec12 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
        Spec12 .PMP_Display_Type_Nm__c='Checkbox';
        Spec12 .PMP_Active_Ind__c=true;
        Spec12 .PMP_Specification_Type_Nm__c='Other';
        Spec12.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec12.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec12 ;
       
        PMP_Specification__c Spec13 = new PMP_Specification__c(); 
        Spec13.Name = 'Processor Lev5';
        Spec13.PMP_Specification_Name__c = 'Processor Lev5';
        Spec13.PMP_Parent_Specification_Id__c=Spec11.Id;
        Spec13.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
        Spec13.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
        Spec13.PMP_Display_Type_Nm__c='Checkbox';
        Spec13.PMP_Active_Ind__c=true;
        Spec13.PMP_Specification_Type_Nm__c='Other';
        Spec13.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec13.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec13;
        
        PMP_Specification__c Spec14 = new PMP_Specification__c(); 
        Spec14 .Name = 'Processor Lev6';
        Spec14 .PMP_Specification_Name__c = 'Processor Lev6';
        Spec14 .PMP_Parent_Specification_Id__c=Spec13.Id;
        Spec14 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
        Spec14 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
        Spec14 .PMP_Display_Type_Nm__c='Checkbox';
        Spec14 .PMP_Active_Ind__c=true;
        Spec14 .PMP_Specification_Type_Nm__c='Other';
        Spec14.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec14.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec14 ;
        
        PMP_Specification_Value__c newSpecVal0=new PMP_Specification_Value__c();
        newSpecVal0.PMP_Partner_Off_Roadmap_Ind__c=True;
        newSpecVal0.Name='processorLev4';
        newSpecVal0.PMP_Product_Specification_Value_Cd__c='processorLev4';
        newSpecVal0.PMP_Specification_Value_Cd__c='processorLev4';
        newSpecVal0.PMP_Active_Ind__c=true;
        newSpecVal0.PMP_Display_Type_Nm__c='Checkbox';
        newSpecVal0.PMP_Spec_Value_Type_Nm__c='Other';
        insert newSpecVal0;
 
        List<PMP_Specification__c> aa=[Select Id, Name, PMP_Ancestor_Specification_Nm__c, PMP_Parent_Specification_Id__r.Name, PMP_Ancestor_Specification_Cd__c from PMP_Specification__c where Name = 'Processor Lev3' ];
      // system.debug('aa ' + aa);
        PMP_Specification_Value__c newSpecVal=new PMP_Specification_Value__c();
        newSpecVal.PMP_Partner_Off_Roadmap_Ind__c=True;
        newSpecVal.Name='Windows Server';
        newSpecVal.PMP_Product_Specification_Value_Cd__c='Windows Server';
        newSpecVal.PMP_Specification_Value_Cd__c='Windows Server';
        newSpecVal.PMP_Active_Ind__c=true;
        newSpecVal.PMP_Display_Type_Nm__c='Checkbox';
        newSpecVal.PMP_Spec_Value_Type_Nm__c='Other';
        insert newSpecVal;
        
        // for 'Availability and Pricing'
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec9=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec9.Name=Spec10.Name;
        newPMPOfferingSpec9.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec9.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec9.PMP_Specification_Nm__c=Spec10.Name;
        newPMPOfferingSpec9.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec9.PMP_Product_Specification_Cd__c= Spec10.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec9.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec9.PMP_Specification_Id__c=Spec10.Id;   
        //newPMPOfferingSpec9.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec9);
        
        // for 'Availability and Pricing'
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec13=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec13.Name=Spec10.Name;
        newPMPOfferingSpec13.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec13.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec13.PMP_Specification_Nm__c='newPMPOfferingSpec13';
        newPMPOfferingSpec13.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec13.PMP_Product_Specification_Cd__c= Spec10.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec13.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec13.PMP_Specification_Id__c=Spec10.Id;   
        //newPMPOfferingSpec13.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec13);
        
        // for 'Regional Coverage'
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec10=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec10.Name=Spec12.Name;
        newPMPOfferingSpec10.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec10.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec10.PMP_Specification_Nm__c=Spec12.Name;
        newPMPOfferingSpec10.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec10.PMP_Product_Specification_Cd__c= Spec12.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec10.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec10.PMP_Specification_Id__c=Spec12.Id;   
        //newPMPOfferingSpec10.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec10);
        
        // for 'Regional Coverage'
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec14=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec14.Name=Spec12.Name;
        newPMPOfferingSpec14.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec14.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec14.PMP_Specification_Nm__c='newPMPOfferingSpec14';
        newPMPOfferingSpec14.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec14.PMP_Product_Specification_Cd__c= Spec12.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec14.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec14.PMP_Specification_Id__c=Spec12.Id;   
        //newPMPOfferingSpec14.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec14);
        
        
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec11=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec11.Name=Spec14.Name;
        newPMPOfferingSpec11.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec11.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec11.PMP_Specification_Nm__c=Spec12.Name;
        newPMPOfferingSpec11.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec11.PMP_Product_Specification_Cd__c= Spec14.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec11.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec11.PMP_Specification_Id__c=Spec14.Id;   
        //newPMPOfferingSpec11.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec11);
        
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec12=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec12.Name=Spec14.Name;
        newPMPOfferingSpec12.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec12.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec12.PMP_Specification_Nm__c=Spec14.Name;
        //newPMPOfferingSpec12.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec12.PMP_Product_Specification_Cd__c= Spec14.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec12.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec12.PMP_Specification_Id__c=Spec14.Id;   
        //newPMPOfferingSpec12.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec12);
        
        
        insert listOfferSpec;
        
        
        //system.debug('newPMPOfferingSpec5:'+newPMPOfferingSpec5);

        // requerying as formula field was resulting in less code coverage.
        List <PMP_Partner_Offering_Specification__c> offSpecNewList = [SELECT Name,PMP_Ancestor_Specification_Cd__c,PMP_Display_Type_Nm__c,PMP_Localized_Specification_Nm__c,
                                                                        PMP_Localized_Specification_Value_Nm__c,PMP_Offering_Id__c,PMP_Product_Specification_Cd__c,
                                                                        PMP_Specification_Id__c,PMP_Specification_Nm__c,PMP_Specification_Value_Cd__c,
                                                                        PMP_Specification_Value_Id__c,PMP_Specification_Value_Nm__c,
                                                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c,
                                                                        PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                                        PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                                                                        PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,
                                                                        PMP_Specification_Id__r.PMP_Specification_Name__c,
                                                                        PMP_Specification_Id__r.PMP_Ancestor_Specification_nm__c,
                                                                        PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                                                        PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
                                                                        PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c,
                                                                        PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                                                        PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c
                                                                        
                                                                        FROM PMP_Partner_Offering_Specification__c Where PMP_Offering_Id__c =: testOffering.id];
   
       // Map<string, List<string>> response = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(offSpecNewList,'en_US' );
        List<PMP_Partner_Offering_Category__c> insertOffCategories2 = [select Name, 
                                                                      PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,
                                                                      PMP_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Category_Japanese_Nm__c
                                                                      from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c =: off1.Id];
        
        PMP_OfferingDetailsController.buildMarketingInfo(offSpecNewList,insertOffCategories2,'en');
        PMP_OfferingDetailsController.buildMarketingInfo(offSpecNewList,insertOffCategories2,'zh');
        PMP_OfferingDetailsController.buildMarketingInfo(offSpecNewList,insertOffCategories2,'ja');
        
    }
    
    @isTest
    static void buildMarketingInfoTest5(){
        
        List<PMP_Category__c> categories = new List<PMP_Category__c>();
         PMP_Category__c cat1 = new PMP_Category__c();
         cat1.Name='Industry';
         cat1.PMP_Category_Chinese_Nm__c='Chinese';
         cat1.PMP_Category_Japanese_Nm__c='Japanese';
         cat1.PMP_Active_Ind__c=true;
         cat1.PMP_Partner_Product_Category_Cd__c='NPP_01_TYPE';
         cat1.PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy';
         cat1.PMP_Partner_Product_Category_Key__c='npp_01_type';
             
         PMP_Category__c cat2 = new PMP_Category__c();
         cat2.Name='Component';
         cat2.PMP_Category_Chinese_Nm__c='Chinese';
         cat2.PMP_Category_Japanese_Nm__c='Japanese';
         cat2.PMP_Active_Ind__c=true;
         cat2.PMP_Partner_Product_Category_Cd__c='TPS_900002';
         cat2.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_TYPE';
         cat2.PMP_Partner_Product_Category_Key__c='tps_900002';
             
         PMP_Category__c cat3 = new PMP_Category__c();
         cat3.Name='FPGA Boards';
         cat3.PMP_Category_Chinese_Nm__c='Chinese';
         cat3.PMP_Category_Japanese_Nm__c='Japanese';
         cat3.PMP_Active_Ind__c=true;
         cat3.PMP_Partner_Product_Category_Cd__c='TPS_900214';
         cat3.PMP_Partner_Product_Parent_Category_Cd__c='TPS_900002';
         cat3.PMP_Partner_Product_Category_Key__c='TPS_900214';
             
         PMP_Category__c cat4= new PMP_Category__c();
         cat4.Name='Development Kits';
         cat4.PMP_Category_Chinese_Nm__c='Chinese';
         cat4.PMP_Category_Japanese_Nm__c='Japanese';
         cat4.PMP_Active_Ind__c=true;
         cat4.PMP_Partner_Product_Category_Cd__c='TPS_900218';
         cat4.PMP_Partner_Product_Parent_Category_Cd__c='TPS_900214';
         cat4.PMP_Partner_Product_Category_Key__c=' tps_900218';
        
         PMP_Category__c cat5= new PMP_Category__c();
         cat5.Name='Application';
         cat5.PMP_Category_Chinese_Nm__c='Chinese';
         cat5.PMP_Category_Japanese_Nm__c='Japanese';
         cat5.PMP_Active_Ind__c=true;
         cat5.PMP_Partner_Product_Category_Cd__c='NPP_01_APP';
         cat5.PMP_Partner_Product_Parent_Category_Cd__c='Solution_Marketplace_Hierarchy';
         cat5.PMP_Partner_Product_Category_Key__c=' npp_01_app';
        
        PMP_Category__c cat6= new PMP_Category__c();
         cat6.Name='Advanced Analytics';
         cat6.PMP_Category_Chinese_Nm__c='Chinese';
         cat6.PMP_Category_Japanese_Nm__c='Japanese';
         cat6.PMP_Active_Ind__c=true;
         cat6.PMP_Partner_Product_Category_Cd__c='IPA_APP_AdvancedAnalytics';
         cat6.PMP_Partner_Product_Parent_Category_Cd__c='NPP_01_APP';
         cat6.PMP_Partner_Product_Category_Key__c='ipa_app_advancedanalytics';
          
         cat2.PMP_Parent_Category_Id__c = cat1.Id;
        cat3.PMP_Parent_Category_Id__c = cat2.Id;
        cat4.PMP_Parent_Category_Id__c = cat3.Id;
        cat6.PMP_Parent_Category_Id__c = cat5.Id;
         categories.add(cat1);
         categories.add(cat2);
         categories.add(cat3);
         categories.add(cat4);
         categories.add(cat5);
        categories.add(cat6);
   
        insert categories;
      
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.Name = cat3.Name;
        offCat2.PMP_Offering_Category_External_Key__c = 'NPP_01_TYPE';
        offCat2.PMP_Offering_Id__c = off1.Id;
        offCat2.PMP_Ancestor_Category_Cd__c = 'NPP_01_TYPE|NPP_01_TYPE';
        offCat2.PMP_Category_Id__c = cat3.id;
        
        
        PMP_Partner_Offering_Category__c offCat4 = new PMP_Partner_Offering_Category__c();
        offCat4.Name = cat2.Name;
        offCat4.PMP_Offering_Category_External_Key__c = System.Label.PMP_NPP_01_Industry;
        offCat4.PMP_Offering_Id__c = off1.Id;
        offCat4.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        offCat4.PMP_Category_Id__c = cat2.Id;
        
    
        PMP_Partner_Offering_Category__c offCat5 = new PMP_Partner_Offering_Category__c();
        offCat5.Name = 'Test';
        offCat5.PMP_Offering_Category_External_Key__c = 'IPA_APP_ConnectedWorker';
        offCat5.PMP_Offering_Id__c = off1.Id;
        offCat5.PMP_Category_Id__c = cat3.Id;
        offCat5.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        
        PMP_Partner_Offering_Category__c offCat6 = new PMP_Partner_Offering_Category__c();
        //offCat6.Name = cat2.Name;
        offCat6.PMP_Offering_Category_External_Key__c = System.Label.PMP_NPP_01_Industry;
        offCat6.PMP_Offering_Id__c = off1.Id;
        offCat6.PMP_Ancestor_Category_Cd__c = 'NPP_01_APP';
        offCat6.PMP_Category_Id__c = cat2.Id;
        
        insertOffCategories.add(offCat2);
        insertOffCategories.add(offCat4);
        insertOffCategories.add(offCat5);
        insertOffCategories.add(offCat6);
        
        insert insertOffCategories;
   
        
      //Create account
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = 'Test Account 19-Jun-19';       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        insert testAccount;
        
                                                      
        PMP_Company__c testCompany = PMP_TestDataUtility.createCompanyInformation('Test_Company1', acc1.Id, true);
        
        List<PMP_Specification__c> specificationList=new List<PMP_Specification__c>();
        
        List<PMP_Partner_Offering_Specification__c> listOfferSpec=new List<PMP_Partner_Offering_Specification__c>();
        List<PMP_Partner_Offering_Specification__c> listOfferSpec2=new List<PMP_Partner_Offering_Specification__c>();
        List<PMP_Partner_Offering_Specification__c> listOfferSpec3=new List<PMP_Partner_Offering_Specification__c>();
        PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',testCompany.Id,true,'Draft','');
        
        PMP_Specification__c Spec9 = new PMP_Specification__c(); 
        Spec9.Name = 'Availability and Pricing';
        Spec9.PMP_Specification_Name__c = 'Processor Lev5';
        //Spec9.PMP_Parent_Specification_Id__c=Spec7.Id;
        Spec9.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
        Spec9.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
        Spec9.PMP_Display_Type_Nm__c='Checkbox';
        Spec9.PMP_Active_Ind__c=true;
        Spec9.PMP_Specification_Type_Nm__c='Other';
        Spec9.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec9.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec9;
        
        PMP_Specification__c Spec10 = new PMP_Specification__c(); 
        Spec10 .Name = 'Processor Lev3';
        Spec10 .PMP_Specification_Name__c = 'Processor Lev3';
        Spec10 .PMP_Parent_Specification_Id__c=Spec9.Id;
        Spec10 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
        Spec10 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
        Spec10 .PMP_Display_Type_Nm__c='Checkbox';
        Spec10 .PMP_Active_Ind__c=true;
        Spec10 .PMP_Specification_Type_Nm__c='Other';
        Spec10.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec10.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec10 ;
        
        PMP_Specification__c Spec11 = new PMP_Specification__c(); 
        Spec11.Name = 'Regional Coverage';
        Spec11.PMP_Specification_Name__c = 'Regional Coverage';
        //Spec11.PMP_Parent_Specification_Id__c=Spec7.Id;
        Spec11.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
        Spec11.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
        Spec11.PMP_Display_Type_Nm__c='Checkbox';
        Spec11.PMP_Active_Ind__c=true;
        Spec11.PMP_Specification_Type_Nm__c='Other';
        Spec11.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec11.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec11;
        
        PMP_Specification__c Spec12 = new PMP_Specification__c(); 
        Spec12 .Name = 'Processor Lev4';
        Spec12 .PMP_Specification_Name__c = 'Processor Lev4';
        Spec12 .PMP_Parent_Specification_Id__c=Spec11.Id;
        Spec12 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
        Spec12 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
        Spec12 .PMP_Display_Type_Nm__c='Checkbox';
        Spec12 .PMP_Active_Ind__c=true;
        Spec12 .PMP_Specification_Type_Nm__c='Other';
        Spec12.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec12.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec12 ;
       
        PMP_Specification__c Spec13 = new PMP_Specification__c(); 
        Spec13.Name = 'Processor Lev5';
        Spec13.PMP_Specification_Name__c = 'Processor Lev5';
        Spec13.PMP_Parent_Specification_Id__c=Spec11.Id;
        Spec13.PMP_Product_Parent_Specification_Id__c= 'Npp_Processor';
        Spec13.PMP_Partner_Product_Specification_Id__c = 'Lev2Processor';
        Spec13.PMP_Display_Type_Nm__c='Checkbox';
        Spec13.PMP_Active_Ind__c=true;
        Spec13.PMP_Specification_Type_Nm__c='Other';
        Spec13.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec13.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec13;
        
        PMP_Specification__c Spec14 = new PMP_Specification__c(); 
        Spec14 .Name = 'Processor Lev6';
        Spec14 .PMP_Specification_Name__c = 'Processor Lev6';
        Spec14 .PMP_Parent_Specification_Id__c=Spec13.Id;
        Spec14 .PMP_Product_Parent_Specification_Id__c= 'Lev2Processor';
        Spec14 .PMP_Partner_Product_Specification_Id__c = 'Lev3Processor';
        Spec14 .PMP_Display_Type_Nm__c='Checkbox';
        Spec14 .PMP_Active_Ind__c=true;
        Spec14 .PMP_Specification_Type_Nm__c='Other';
        Spec14.PMP_Specification_Chinese_Nm__c = 'asjdhad';
        Spec14.PMP_Specification_Japanese_Nm__c = 'lskdjl';
        insert Spec14 ;
        
        PMP_Specification_Value__c newSpecVal0=new PMP_Specification_Value__c();
        newSpecVal0.PMP_Partner_Off_Roadmap_Ind__c=True;
        newSpecVal0.Name='processorLev4';
        newSpecVal0.PMP_Product_Specification_Value_Cd__c='processorLev4';
        newSpecVal0.PMP_Specification_Value_Cd__c='processorLev4';
        newSpecVal0.PMP_Active_Ind__c=true;
        newSpecVal0.PMP_Display_Type_Nm__c='Checkbox';
        newSpecVal0.PMP_Spec_Value_Type_Nm__c='Other';
        insert newSpecVal0;
 
        List<PMP_Specification__c> aa=[Select Id, Name, PMP_Ancestor_Specification_Nm__c, PMP_Parent_Specification_Id__r.Name, PMP_Ancestor_Specification_Cd__c from PMP_Specification__c where Name = 'Processor Lev3' ];
      // system.debug('aa ' + aa);
        PMP_Specification_Value__c newSpecVal=new PMP_Specification_Value__c();
        newSpecVal.PMP_Partner_Off_Roadmap_Ind__c=True;
        newSpecVal.Name='Windows Server';
        newSpecVal.PMP_Product_Specification_Value_Cd__c='Windows Server';
        newSpecVal.PMP_Specification_Value_Cd__c='Windows Server';
        newSpecVal.PMP_Active_Ind__c=true;
        newSpecVal.PMP_Display_Type_Nm__c='Checkbox';
        newSpecVal.PMP_Spec_Value_Type_Nm__c='Other';
        insert newSpecVal;
        
                PMP_Partner_Offering_Specification__c newPMPOfferingSpec12=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec12.Name=Spec12.Name;
        newPMPOfferingSpec12.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec12.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec12.PMP_Specification_Nm__c=Spec12.Name;
        //newPMPOfferingSpec12.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec12.PMP_Product_Specification_Cd__c= Spec12.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec12.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec12.PMP_Specification_Id__c=Spec12.Id;   
        //newPMPOfferingSpec12.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec12);
        
        // for 'Regional Coverage'
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec10=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec10.Name=Spec12.Name;
        newPMPOfferingSpec10.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec10.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec10.PMP_Specification_Nm__c=Spec12.Name;
        newPMPOfferingSpec10.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec10.PMP_Product_Specification_Cd__c= Spec12.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec10.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec10.PMP_Specification_Id__c=Spec12.Id;   
        //newPMPOfferingSpec10.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec10);
        
        // for 'Regional Coverage'
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec14=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec14.Name=Spec12.Name;
        newPMPOfferingSpec14.PMP_Offering_Id__c=testOffering.Id;
        newPMPOfferingSpec14.PMP_Ancestor_Specification_Cd__c='NPP_GeographicCoverage|etm-1b8f55ddb38f4054b32794910f6975cc';
        newPMPOfferingSpec14.PMP_Specification_Nm__c='newPMPOfferingSpec14';
        newPMPOfferingSpec14.PMP_Specification_Value_Cd__c=newSpecVal.PMP_Specification_Value_Cd__c;
        newPMPOfferingSpec14.PMP_Product_Specification_Cd__c= Spec12.PMP_Partner_Product_Specification_Id__c;
        newPMPOfferingSpec14.PMP_Display_Type_Nm__c='Checkbox';
        newPMPOfferingSpec14.PMP_Specification_Id__c=Spec12.Id;   
        //newPMPOfferingSpec14.PMP_Specification_Value_Id__c=newSpecVal.Id;
        listOfferSpec.add(newPMPOfferingSpec14);
       
        insert listOfferSpec;
        
        
        //system.debug('newPMPOfferingSpec5:'+newPMPOfferingSpec5);

        // requerying as formula field was resulting in less code coverage.
        List <PMP_Partner_Offering_Specification__c> offSpecNewList = [SELECT Name,PMP_Ancestor_Specification_Cd__c,PMP_Display_Type_Nm__c,PMP_Localized_Specification_Nm__c,
                                                                        PMP_Localized_Specification_Value_Nm__c,PMP_Offering_Id__c,PMP_Product_Specification_Cd__c,
                                                                        PMP_Specification_Id__c,PMP_Specification_Nm__c,PMP_Specification_Value_Cd__c,
                                                                        PMP_Specification_Value_Id__c,PMP_Specification_Value_Nm__c,
                                                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Chinese_Cd__c,
                                                                       PMP_Specification_Value_Id__r.PMP_Specification_Value_Japanese_Cd__c,
                                                                        PMP_Specification_Id__r.PMP_Ancestor_Specification_Cd__c,
                                                                        PMP_Specification_Id__r.PMP_Partner_Product_Specification_Id__c,
                                                                        PMP_Specification_Id__r.PMP_Product_Parent_Specification_Id__c,
                                                                        PMP_Specification_Id__r.PMP_Specification_Name__c,
                                                                        PMP_Specification_Id__r.PMP_Ancestor_Specification_nm__c,
                                                                        PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                                                        PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Japanese_Nm__c,
                                                                        PMP_Specification_Id__r.PMP_Parent_Specification_Id__r.PMP_Specification_Name__c,
                                                                        PMP_Specification_Id__r.PMP_Specification_Chinese_Nm__c,
                                                                        PMP_Specification_Id__r.PMP_Specification_Japanese_Nm__c
                                                                        
                                                                        FROM PMP_Partner_Offering_Specification__c Where PMP_Offering_Id__c =: testOffering.id];
   
       // Map<string, List<string>> response = PMP_SpecificationController.getOfferingValuesAndSpecificationMap(offSpecNewList,'en_US' );
        List<PMP_Partner_Offering_Category__c> insertOffCategories2 = [select Name, 
                                                                      PMP_Category_Id__r.PMP_Ancestor_Category_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Parent_Category_Id__r.Name,
                                                                      PMP_Category_Id__r.PMP_Ancestor_Category_Chinese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Category_Chinese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Ancestor_Category_Japanese_Nm__c,
                                                                      PMP_Category_Id__r.PMP_Category_Japanese_Nm__c
                                                                      from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c =: off1.Id];
        
        PMP_OfferingDetailsController.buildMarketingInfo(offSpecNewList,insertOffCategories2,'en');
        PMP_OfferingDetailsController.buildMarketingInfo(offSpecNewList,insertOffCategories2,'zh');
        PMP_OfferingDetailsController.buildMarketingInfo(offSpecNewList,insertOffCategories2,'ja');
        
    }*/
 
}