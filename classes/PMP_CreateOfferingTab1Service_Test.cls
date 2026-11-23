@isTest
public class PMP_CreateOfferingTab1Service_Test {
//     private static final String ALIAS_NAME = 'testUseg';
//     public static final String PMP_INTERNAL_ADMIN_STR = 'PMP_Internal_Intel_Admin';
//     Public static final Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
    
//     @testSetup static void setup() {
//         // Create common test user
//      /*   User poeUser= PMP_TestDataUtility.createUser(True);
//         poeUser.Alias = ALIAS_NAME;
//         update poeUser;*/   //there is a validation rule in User object which will not allow certain fields updation   
//         Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
  
//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
//         Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
//         Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
//         User poeUser = new User(/**UserRoleId  = ur.Id,**/Alias = ALIAS_NAME, Email='testUsercoreMDF@intel.com',
//                                  EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
//                                  LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
//                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test', Contact = conObj);
//         insert poeUser;
//     }
    
//     static testMethod void getOfferingDetailsInputsTestPositiveScenario(){
//         test.startTest();
//         //PMP_CreateOfferingTab1Service tab1ServiceObj = new PMP_CreateOfferingTab1Service();
//         PMP_CreateOfferingTab1Service.getCompanyInfoOptions();
        
//         Account accObj = PMP_TestDataUtility.createIntelAccount('test Account1',devRecordTypeId,true);
        
//         User uObj = PMP_TestDataUtility.createUserNew(true,accObj.Id);
//         List<PMP_Company__c> companyList = new List<PMP_Company__c>();
//         PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('test intel company', uObj.Contact.AccountId, true);
//         companyList.add(companyInfo);
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         //Map<String, PMP_Specifications_Tab_Mapping__mdt> stepConfigurationsMap = new Map<String, PMP_Specifications_Tab_Mapping__mdt>();
//         string[] categoryList = new List<string>{'NPP_01_TYPE','NPP_02_TYPE_Comp','NPP_03_TYPE_Comp_Board','NPP_04_TYPE_Comp_Board_AMC','NPP_01_Industry','NPP_02_Ind_Agriculture','NPP_01_APP','NPP_02_APP_DigSecSurv'};
//         //String cDNA='12345';
          
//         // System.debug('speclist in testclass'+specList);
//         Intel_Text textUIGenerator = PMP_Offering_UI_Generator.createText('test','test',true);
//         //Intel_Checkbox checkBoxUIGenerator = PMP_Offering_UI_Generator.createCheckbox('name', 'label');
//         Intel_Resources resourceUIGenerator = PMP_Offering_UI_Generator.createResources();
//         PMP_Partner_Offering__c offObj = PMP_TestDataUtility.createOffering('test offering for test class',
//                                                                            'public content','Test desc',companyInfo.Id,true,'Draft','test tagline');
//         specList = PMP_SpecificationController.getOfferingSpecificationList(categoryList,offObj.id);  
//         //set<string> offSpecSet = new set<string>();
//         //map<string,string> specValDataMap = new  map<string,string>();
//        // PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Step1','Software',specList,stepConfigurationsMap,offObj,offSpecSet,specValDataMap);
//         Intel_Uploader uploaderUIGenerator = PMP_Offering_UI_Generator.createUploader(offObj,true);
//         Intel_Section sectionWrapperClass = new Intel_Section();
//         sectionWrapperClass.isAccordion = false; 
//         Intel_Subsection subSectionWrapperClass = new Intel_Subsection();
//         subSectionWrapperClass.expandable = false;
//         Intel_Dropdown dropDownWtapperClass = new Intel_Dropdown();
//         dropDownWtapperClass.placeholder = 'test';
//         dropDownWtapperClass.hidePlaceholder = false;
//         dropDownWtapperClass.allowMultipleOptions = false;
//         //Intel_Checkbox checkBoxWrapperClass = new Intel_Checkbox();
//        // checkBoxWrapperClass.containsSearch = false;
//        // checkBoxWrapperClass.isAccordion = false;
//         System.assertNotEquals(offObj, null);
//         test.stopTest();
//      }
//     static testMethod void getOfferingDetailsInputsTestNegativeScenario(){
//         test.startTest();
//         //PMP_CreateOfferingTab1Service tab1ServiceObj = new PMP_CreateOfferingTab1Service();
        
//         Account accObj = PMP_TestDataUtility.createIntelAccount('test Account2',devRecordTypeId,true);
        
//         User uObj = PMP_TestDataUtility.createUserNew(true,accObj.Id);
//         List<PMP_Company__c> companyList = new List<PMP_Company__c>();
//         PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('test class Account', uObj.Contact.AccountId, true);
//         companyList.add(companyInfo);
//         // System.debug('companyList TEST CLASS--->'+companyList);
//        // PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Step1');
//         System.assertNotEquals(companyList, null);
//         test.stopTest();
//      }
    
//     //Added by Shahrukh 
//     static testMethod void testCategoryList(){
              
             
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
                
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
                        
//         PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
//                                                                                  'TestDuplicate',cmp1.Id, true,'Published','');
                                                                                 
//         offering1.PMP_Category_nm__c = Label.PMP_CreateOffering_Software;
//         update offering1;
//         System.assertEquals(offering1.PMP_Category_nm__c, Label.PMP_CreateOffering_Software);
        
//         PMP_Category__c ParentCategory = new PMP_Category__c();
//         ParentCategory.Name = 'Categories'; 
//         ParentCategory.PMP_Active_Ind__c = true;
//         ParentCategory.PMP_Partner_Product_Category_Cd__c = 'appp';
//         ParentCategory.PMP_Partner_Product_Category_Key__c = 'appp';
//         ParentCategory.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
//         Insert ParentCategory;
        
//         PMP_Category__c Category = new PMP_Category__c();
//         Category.Name = 'Software'; 
//         Category.PMP_Active_Ind__c = true;
//         Category.PMP_Partner_Product_Category_Cd__c = 'bpppp';
//         Category.PMP_Partner_Product_Category_Key__c = 'bpppp';
//         Category.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_01_TYPE';
//         Category.PMP_Parent_Category_Id__c = ParentCategory.Id;
//         Insert Category;
        
//         // system.debug('********Category'+Category.Id);
//         // system.debug('********Category'+Category.Name);
        
//         PMP_Category__c Category1 = new PMP_Category__c();
//         Category1.Name = 'Middleware'; 
//         Category1.PMP_Active_Ind__c = true;
//         Category1.PMP_Partner_Product_Category_Cd__c = 'cpppp';
//         Category1.PMP_Partner_Product_Category_Key__c = 'cpppp';
//         Category1.PMP_Partner_Product_Parent_Category_Cd__c = 'bpppp';
//         Category1.PMP_Parent_Category_Id__c = Category.Id;
//         //Category1.Type__c = 'Category'; 
//         Insert Category1;
        
//         // system.debug('********Final'+Category.Id);
        
        
//         PMP_Category__c parentCategory2 = PMP_TestDataUtility.getCategory('System', 'IPA_TYPE_Sys','NPP_01_TYPE', 'en_us');
        
//         parentCategory2.PMP_Parent_Category_Id__c = ParentCategory.Id;
//         update parentCategory2;
        
//         PMP_Category__c Category2 = new PMP_Category__c();
//         Category2.Name = 'Server'; 
//         Category2.PMP_Active_Ind__c = true;
//         Category2.PMP_Partner_Product_Category_Cd__c = 'IPA_TYPE_Sys_Server';
//         Category2.PMP_Display_Type_Nm__c = 'Radio';
//         Category2.PMP_Category_Japanese_Nm__c = 'Japanese';
//         Category2.PMP_Category_Chinese_Nm__c = 'Chinese';
//         Category2.PMP_Partner_Product_Category_Key__c = 'ipa_type_sys_server';
//         Category2.PMP_Partner_Product_Parent_Category_Cd__c = 'IPA_TYPE_Sys';
//         Category2.PMP_Parent_Category_Id__c = parentCategory2.Id;
//         Category2.PMP_Category_Display_Sequence_Nbr__c = 2;
//         Insert Category2;     
//         // System.debug('subcategoresType--->'+parentCategory2.PMP_Ancestor_Category_Cd__c);
//         PMP_Category__c newcat = [select id,PMP_Parent_Category_Id__c,PMP_Parent_Category_Id__r.Name,PMP_Ancestor_Category_Nm__c from PMP_Category__c where Id=:Category1.Id];
  
//         Test.startTest(); 
//         List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryList = PMP_CreateOfferingTab1Service.getOfferingCategorySubCategoryList('NPP_01_TYPE','en_US','Category');
//         Test.stopTest();
//     }
    
//     //Added by Manasa
//     static testMethod void testSpecList(){
//         Test.startTest(); 
//         Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
//         PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
//                                                                                'TestDuplicate',cmp1.Id, true,'Published','');
        
//         offering1.PMP_Category_nm__c = Label.PMP_CreateOffering_Software;
//         offering1.PMP_Is_Converted_Ind__c = true;
//         update offering1;
//         System.assertEquals(offering1.PMP_Category_nm__c, Label.PMP_CreateOffering_Software);
        
//         PMP_Category__c ParentCategory = new PMP_Category__c();
//         ParentCategory.Name = 'Categories'; 
//         ParentCategory.PMP_Active_Ind__c = true;
//         ParentCategory.PMP_Partner_Product_Category_Cd__c = 'appp';
//         ParentCategory.PMP_Partner_Product_Category_Key__c = 'appp';
//         ParentCategory.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
//         Insert ParentCategory;
        
//         PMP_Category__c Category = new PMP_Category__c();
//         Category.Name = 'Software'; 
//         Category.PMP_Active_Ind__c = true;
//         Category.PMP_Partner_Product_Category_Cd__c = 'bpppp';
//         Category.PMP_Partner_Product_Category_Key__c = 'bpppp';
//         Category.PMP_Partner_Product_Parent_Category_Cd__c = 'appp';
//         Category.PMP_Parent_Category_Id__c = ParentCategory.Id;
//         Insert Category;
        
        
//         PMP_Category__c Category1 = new PMP_Category__c();
//         Category1.Name = 'Middleware'; 
//         Category1.PMP_Active_Ind__c = true;
//         Category1.PMP_Partner_Product_Category_Cd__c = 'cpppp';
//         Category1.PMP_Partner_Product_Category_Key__c = 'cpppp';
//         Category1.PMP_Partner_Product_Parent_Category_Cd__c = 'bpppp';
//         Category1.PMP_Parent_Category_Id__c = Category.Id;
        
//         Insert Category1;
        
//         PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c();
//         offCat1.Name = 'Categories';
//         offCat1.PMP_Offering_Id__c = offering1.Id;
//         offCat1.PMP_Category_Id__c = ParentCategory.Id;
        
//         insert offCat1;
        
//         PMP_Category__c newcat = [select id,PMP_Parent_Category_Id__c,PMP_Parent_Category_Id__r.Name,PMP_Ancestor_Category_Nm__c from PMP_Category__c where Id=:Category1.Id];
        
        
        
        
//         List<PMP_CategoryController.Core_PMP_OfferingCategory> categoryList = PMP_CreateOfferingTab1Service.getOfferingCategorySubCategoryList('IPA_TYPE_Sys',null,'Category');
        
        
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         map<string, PMP_Specifications_Tab_Mapping__mdt> configSpecMap = New Map<string,PMP_Specifications_Tab_Mapping__mdt>();
//         map<String,String> specValDataMap = new map<String,String>();
//         map<string,List<string>> specValListMap = new map<string,List<string>>();
//         List<string> valueList = new List<string>();
//         String value = 'Test Chipsets';
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> specValList1 = PMP_TestDataUtility.getSpecValueWrapper(5,'Checkbox');
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specWrapperList = PMP_TestDataUtility.getSpecWrapperList(10,'Checkbox');
//         PMP_Specifications_Tab_Mapping__mdt configMeta = [Select label,Accordion_Type__c,PMP_Field_Label__c, isAccordion__c, isSearchable__c,tab__c, Interaction_Type__c,PMP_Is_Create_Offering_Ind__c,Show_Select_All__c from PMP_Specifications_Tab_Mapping__mdt where PMP_Is_Create_Offering_Ind__c=true Limit 1];
        
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec1 = specWrapperList[0];
//         spec1.childOfferingSpecification.add(specWrapperList[1]);
        
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec2 = specWrapperList[2];
//         spec2.childOfferingSpecification.add(specWrapperList[3]);
//         spec2.childOfferingSpecification.add(specWrapperList[4]);
//         spec2.childOfferingSpecification.add(specWrapperList[5]);
//         spec2.specValues = specValList1;
//         spec1.childOfferingSpecification.add(spec2);
        
//         PMP_SpecificationController.Core_PMP_OfferingSpecs spec3 = specWrapperList[6];
//         spec3.childOfferingSpecification.add(specWrapperList[7]);
//         spec3.childOfferingSpecification.add(specWrapperList[8]);
//         spec3.childOfferingSpecification.add(specWrapperList[9]);
        
//         specWrapperList[0].specId = 'NPP_GeographicCoverage';
        
//         valueList.add(value);
//         configSpecMap.put(spec1.specid,configMeta );
//         configSpecMap.put(spec2.specid,configMeta );
//         configSpecMap.put(spec3.specid,configMeta );
//         specValDataMap.put('Chipsets','Consumer Chipsets');
//         specValListMap.put('Chipsets',valueList);
//         specList.add(spec1);
//         specList.add(spec2);
//         specList.add(spec3);
        
//         PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoff', null,null,null,true,null,null );
//         set<string> offSpecSet = new set<string>(); 
//         String offSpec = 'consumer chipsets';
//         offSpecSet.add(offSpec);
        
//         //populate (Offered By:Company information) for Admin and Partner Users 
//         //Admin User
//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
//         Account accObj = PMP_TestDataUtility.createIntelAccount('test Account 3',devRecordTypeId,true);
//         Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
//         PMP_Company__c cmp = PMP_TestDataUtility.createCompanyInformation(accObj.Name, accObj.Id, true);
        
        
        
//         Profile prf=[SELECT Id  FROM Profile WHERE name='System Administrator' limit 1];
//         User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
//                                  EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
//                                  LocaleSidKey='en_US', ProfileId = prf.Id,
//                                  TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test', Contact = conObj);
        
//         //PMP_CreateOfferingTab1Service.getCompanyInfoForAccount(accObj.Id);
//         System.runAs(testUser) {
//             Group grp=[SELECT Id FROM Group where DeveloperName ='PMP_All_Intel_Admin_Users' LIMIT 1];
//             GroupMember gpm = new GroupMember();
//             gpm.GroupId = grp.Id;
//             gpm.UserOrGroupId = testUser.Id;
//             Database.insert(gpm);
//             Test.stopTest();
            
//             PMP_CreateOfferingTab1Service.getCompanyInfoOptions();
//             PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Tab1','Software',specWrapperList,configSpecMap,offering1,offSpecSet,specValDataMap,specValListMap,null);
//             try{
//                  specWrapperList[0].specId = 'NPP_EndCustomerType';
//             PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Tab1','Software',specWrapperList,configSpecMap,offering1,offSpecSet,specValDataMap,specValListMap,null);

//             } catch(Exception e){
//             //System.debug(e.getMessage()+' '+ e.getCause()+' '+e.getLineNumber());
//             }
           
            
//         }
        
        
//     } 
//     @isTest
//     static void testSpecList2(){
        
        
//         map<String,String> specValDataMap = new map<String,String>();
//         map<string,List<string>> specValListMap = new map<string,List<string>>();
//         //List<string> valueList = new List<string>();
//         //String value = 'Test Chipsets';
//         //List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> specValList1 = new List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> ();//PMP_TestDataUtility.getSpecValueWrapper(5,'Checkbox');
//         //List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specWrapperList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs> ();//PMP_TestDataUtility.getSpecWrapperList(10,'Checkbox');
//         PMP_Specifications_Tab_Mapping__mdt configMeta = [Select label,Accordion_Type__c,PMP_Field_Label__c, isAccordion__c,PMP_Is_Create_Offering_Ind__c, isSearchable__c,tab__c from PMP_Specifications_Tab_Mapping__mdt where PMP_Is_Create_Offering_Ind__c=true Limit 1];
        
        
        
//         set<string> offSpecSet = new set<string>(); 
//         //populate (Offered By:Company information) for Admin and Partner Users 
//         //Partner USer
        
//         //User context
//         UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where Name='Admin' limit 1];
//         User thisUSer=[Select Id,UserRoleId  from User where Id=:UserInfo.getUserId()];
//         thisUSer.UserRoleId=ur.Id;
//         //update thisUSer; 
//         //non-mda start
//         Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
//         Account intelAccount;
//         Contact conObj;
//         User poeUser;
//         System.runAs(thisUSer){
//             update thisUSer; 
//             intelAccount = PMP_TestDataUtility.createIntelAccount('Intel Account10B',devRecordTypeId,true);
//             //intelAccount.Core_IPA_One_Partner_Id__c='a5S8A000000CnnaUAC';
//             //update intelAccount;
//             conObj = PMP_TestDataUtility.createContact(intelAccount.id,true);
//             Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
            
            
//             poeUser = new User(/*UserRoleId  = ur.Id,*/ Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
//                                EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
//                                LocaleSidKey='en_US', ProfileId = prf2.Id,
//                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
//                                FirstName='Test'
//                               );
//             poeUser.ContactId=conObj.Id;
//             insert poeUser;
            
             
            
//         }

//         //non-mda end
        
        
        
//         //mda start
//        // Account intelAccountwithMDA = PMP_TestDataUtility.createIntelAccount('Intel Account10A',devRecordTypeId,true);
//         //Contact contactWithMDA = PMP_TestDataUtility.createContact(intelAccountwithMDA.id,true);
//         //mda end
        
//         //partner acc start
//         devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
//         //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
//         Account partnerAccount = new Account();
//         partnerAccount.RecordTypeId = devRecordTypeId;
//         partnerAccount.Name = 'Partner Account10';       
//         partnerAccount.Core_Account_Country__c='India';
//         partnerAccount.Core_Sales_Group_New__c='US Sales Group';
//         partnerAccount.Core_Account_Type__c='ODM';
//         partnerAccount.BillingStreet='Bangalore Central';
//         partnerAccount.BillingCity='Bangalore';
//         partnerAccount.BillingCountry='IND';
//         partnerAccount.BillingState='KA';
//         partnerAccount.BillingPostalCode='560029';
//         partnerAccount.Industry='Agriculture';
//         insert partnerAccount;
//         //partner acc end
        
//         Test.startTest();
//         //non-MDA
//         Core_Account_Group_Member__c pag=new Core_Account_Group_Member__c();
//         pag.Core_Partner_Account_Id__c=partnerAccount.Id;
//         //pag.Core_MDA_Ind__c=false;
//         pag.Core_Intel_Account_Id__c=intelAccount.Id;
//         insert pag;
//         // system.debug('pag:'+pag.Id);
//         // system.debug('account2:'+pag.Core_Intel_Account_Id__c);
        
        
//         //mda
//       /*  Core_Account_Group_Member__c pagMDA=new Core_Account_Group_Member__c();
//         pagMDA.Core_Partner_Account_Id__c=partnerAccount.Id;
//         pagMDA.Core_MDA_Ind__c=true;
//         pagMDA.Core_Intel_Account_Id__c=intelAccountwithMDA.Id;
//         insert pagMDA;
// */        
//         ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
//         cpIPA.Name='Intel Partner Alliance';
//         cpIPA.PRM_programCode__c='IPA';
//         insert cpIPA;

//         ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
//         cplTitanium.Name='Titanium';
//         cplTitanium.ProgramId=cpIPA.Id;
//         insert cplTitanium;
        
//         /*PMP_Company__c company=new PMP_Company__c();
//         company.Name=partnerAccount.Name;
//         company.PMP_Account_Id__c=partnerAccount.Id;
//         company.PMP_Is_Published_Ind__c=true;
//         insert company;*/
        
//         //Account intelAccount =[Select Id from Account where Name='Intel Account10B'];
        
//         User u = [select Id, Core_IPA_One_Partner_Id__c, name, AccountID from User where alias=:ALIAS_NAME limit 1];
       
//         PMP_Company__c company=new PMP_Company__c();
//         company.Name=intelAccount.Name;
//         company.PMP_Benefit_Update_Ind__c=False;
//         company.PMP_Partner_Inactive_Ind__c = False;
//         company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
//         //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced; //IPA2.0 - TWC729-7885
//         company.PMP_Is_Published_Ind__c=true;
//         insert company;
        
//         PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
//         acm.PRM_Account_Id__c=partnerAccount.id;
//         acm.PRM_Status_Nm__c='Approved';
//         acm.PRM_Channel_Program_Id__c=cpIPA.Id;
//         acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
//         acm.PRM_Partner_Role__c='Service Provider';
//         insert acm;
       
//         PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
//         jun.PMP_One_Partner_ID__c= partnerAccount.Id;
//         jun.PMP_Marketing_Profile_Id__c= company.Id;
//         jun.Is_Active__c=true;     
//         insert jun;
                   

        
//         //PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
//                                                                               // 'TestDuplicate',cmp1.Id, true,'Published','');
     
//                 //PMP_Company__c companyInfo = [select Id, name,PMP_One_Partner_ID__c from  PMP_Company__c where name='TestCompany1' limit 1];
//         //List<PMP_Company__c> companyInfo1 = [SELECT Name, PMP_One_Partner_ID__c from PMP_Company__c where PMP_Is_Published_Ind__c=true and Id=:cmp1.Id ];
//         /*system.debug('userDetails1'+companyInfo1);
//         system.debug('userDetails2'+u);
//         system.debug('userDetails3'+poeUser.Core_IPA_One_Partner_Id__c);
//         system.debug('userDetails4'+intelAccount.Core_IPA_One_Partner_Id__c);
//         system.debug('userDetails5'+conObj.Core_IPA_One_Partner_Id__c);
//         system.debug('userDetails6'+PMP_Utility.getCompanyInfoForOpid(companyInfo1[0].PMP_One_Partner_ID__c));*/
        
//         System.runAs(u) {
            
//             PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_Internal_Intel_Admin'];
//             PermissionSetAssignment psa = new PermissionSetAssignment(
//                 AssigneeId = u.Id,
//                 PermissionSetId = ps.Id
//             );
//             insert psa;
//             PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Employee'];
//             PermissionSetAssignment psa1 = new PermissionSetAssignment(
//                 AssigneeId = poeUser.Id,
//                 PermissionSetId = ps2.Id
//             );
//             insert psa1;

//             Intel_Step response = PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Tab1','Software',new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>(),
//                                                                   new map<string, PMP_Specifications_Tab_Mapping__mdt>(),new PMP_Partner_Offering__c(),offSpecSet,specValDataMap,specValListMap,null);
            
            

//         }
     
//         System.runAs(poeUser) {

//             Intel_Step response = PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Tab1','Software',new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>(),
//                                                                    new map<string, PMP_Specifications_Tab_Mapping__mdt>(),new PMP_Partner_Offering__c(),offSpecSet,specValDataMap,specValListMap,null);
           
            
//             system.assertEquals(response.name,'Tab1');
//         }
//         Test.stopTest();
        
//     }
    

  
//     static testmethod void validateOfferingDataPositiveTest(){
        
//         Intel_FormData formData = new Intel_FormData();
//         List<PMP_Category__c> updateCategories = new List<PMP_Category__c>();
//         //List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
//         List<Intel_SpecificationDataWrapper> catSubCat = new List<Intel_SpecificationDataWrapper>();
//         List<Intel_SpecificationDataWrapper> industries = new List<Intel_SpecificationDataWrapper>();
//         List<Intel_SpecificationDataWrapper> applications = new List<Intel_SpecificationDataWrapper>();
//         Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeIndApp = new Map<String,List<Intel_SpecificationDataWrapper>>();
//         Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeCat = new Map<String,List<Intel_SpecificationDataWrapper>>();
//         Test.startTest();
//         PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
//         PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
//         PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
//         PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
//         System.assertEquals('Component', cat1.Name);
//         PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Memory', 'TPS_900022','TPS_900002', 'en_us');
//         PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
//         PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
//         PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Retail', 'IPA_Ind_Retail','NPP_01_Industry', 'en_us');
//         System.assertEquals('Retail', ind2.Name);
        
//         cat0.PMP_Parent_Category_Id__c = null;
//         cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         app0.PMP_Parent_Category_Id__c = null;
//         app0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         ind0.PMP_Parent_Category_Id__c = null;
//         ind0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat1.PMP_Parent_Category_Id__c = cat0.Id;
//         cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat2.PMP_Parent_Category_Id__c = cat1.Id;
//         cat2.PMP_Business_Segment_Nm__c = 'Server;Personal Computers';
//         app1.PMP_Parent_Category_Id__c = app0.Id;
//         app1.PMP_Business_Segment_Nm__c = 'IoT';
//         ind1.PMP_Parent_Category_Id__c = ind0.Id;
//         ind1.PMP_Business_Segment_Nm__c = 'IoT';
//         ind2.PMP_Parent_Category_Id__c = ind0.Id;
//         ind2.PMP_Business_Segment_Nm__c = 'IoT';
        
//         updateCategories.add(cat0);
//         updateCategories.add(app0);
//         updateCategories.add(ind0);
//         updateCategories.add(cat1);
//         updateCategories.add(cat2);
//         updateCategories.add(app1);
//         updateCategories.add(ind1);
//         updateCategories.add(ind2);
        
//         update updateCategories;
//         Test.stopTest();
//         Intel_SpecificationDataWrapper specDataWrapper1 = new Intel_SpecificationDataWrapper();
//         specDataWrapper1.id = cat1.Id;
//         catSubCat.add(specDataWrapper1);
//         Intel_SpecificationDataWrapper specDataWrapper2 = new Intel_SpecificationDataWrapper();
//         specDataWrapper2.id = cat2.Id;
//         catSubCat.add(specDataWrapper2);
//         Intel_SpecificationDataWrapper specDataWrapper3 = new Intel_SpecificationDataWrapper();
//         specDataWrapper3.id = app1.Id;
//         industries.add(specDataWrapper3);
//         Intel_SpecificationDataWrapper specDataWrapper4 = new Intel_SpecificationDataWrapper();
//         specDataWrapper4.id = ind1.Id;
//         applications.add(specDataWrapper4);
//         Intel_SpecificationDataWrapper specDataWrapper5 = new Intel_SpecificationDataWrapper();
//         specDataWrapper5.id = ind2.Id;
//         applications.add(specDataWrapper5);
        
//         valueByTypeCat.put('Tab1DropdownRadioCombo', catSubCat);
//         valueByTypeIndApp.put('industryValues', industries);
//         valueByTypeIndApp.put('applicationValues', applications);
//         formData.categoryAndSubCategory = valueByTypeCat;
//         formData.industryAndApplication = valueByTypeIndApp;
        
//         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
//         PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
//         PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
//         PMP_Partner_Offering__c off2=PMP_TestDataUtility.createOffering('offering2','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
//         formData.offering = off1;
        
//         Integer status = PMP_CreateOfferingTab1Service.validateOfferingData(formData);
//         system.assertEquals(1, status);
//     }
    
//     static testmethod void validateOfferingDataNegativeTest(){
//         Intel_FormData formData = new Intel_FormData();
//         List<PMP_Category__c> updateCategories = new List<PMP_Category__c>();
//         //List<PMP_Partner_Offering_Category__c> insertOffCategories = new List<PMP_Partner_Offering_Category__c>();
//         List<Intel_SpecificationDataWrapper> catSubCat = new List<Intel_SpecificationDataWrapper>();
//         List<Intel_SpecificationDataWrapper> industries = new List<Intel_SpecificationDataWrapper>();
//         List<Intel_SpecificationDataWrapper> applications = new List<Intel_SpecificationDataWrapper>();
//         Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeIndApp = new Map<String,List<Intel_SpecificationDataWrapper>>();
//         Map<String,List<Intel_SpecificationDataWrapper>> valueByTypeCat = new Map<String,List<Intel_SpecificationDataWrapper>>();
//         Test.startTest();
//         PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
//         PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
//         PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
//         PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
//         System.assertEquals('Component', cat1.Name);
//         PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Memory', 'TPS_900022','TPS_900002', 'en_us');
//         PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
//         PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
//         PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Retail', 'IPA_Ind_Retail','NPP_01_Industry', 'en_us');
//         System.assertEquals('Retail', ind2.Name);
        
//         cat0.PMP_Parent_Category_Id__c = null;
//         cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         app0.PMP_Parent_Category_Id__c = null;
//         app0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         ind0.PMP_Parent_Category_Id__c = null;
//         ind0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat1.PMP_Parent_Category_Id__c = cat0.Id;
//         cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat2.PMP_Parent_Category_Id__c = cat1.Id;
//         cat2.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         app1.PMP_Parent_Category_Id__c = app0.Id;
//         app1.PMP_Business_Segment_Nm__c = 'IoT';
//         ind1.PMP_Parent_Category_Id__c = ind0.Id;
//         ind1.PMP_Business_Segment_Nm__c = 'IoT';
//         ind2.PMP_Parent_Category_Id__c = ind0.Id;
//         ind2.PMP_Business_Segment_Nm__c = 'IoT';
        
//         updateCategories.add(cat0);
//         updateCategories.add(app0);
//         updateCategories.add(ind0);
//         updateCategories.add(cat1);
//         updateCategories.add(cat2);
//         updateCategories.add(app1);
//         updateCategories.add(ind1);
//         updateCategories.add(ind2);
        
//         update updateCategories;
        
//         Intel_SpecificationDataWrapper specDataWrapper1 = new Intel_SpecificationDataWrapper();
//         specDataWrapper1.id = cat1.Id;
//         catSubCat.add(specDataWrapper1);
//         Intel_SpecificationDataWrapper specDataWrapper2 = new Intel_SpecificationDataWrapper();
//         specDataWrapper2.id = cat2.Id;
//         catSubCat.add(specDataWrapper2);
//         Intel_SpecificationDataWrapper specDataWrapper3 = new Intel_SpecificationDataWrapper();
//         specDataWrapper3.id = app1.Id;
//         industries.add(specDataWrapper3);
//         Intel_SpecificationDataWrapper specDataWrapper4 = new Intel_SpecificationDataWrapper();
//         specDataWrapper4.id = ind1.Id;
//         applications.add(specDataWrapper4);
//         Intel_SpecificationDataWrapper specDataWrapper5 = new Intel_SpecificationDataWrapper();
//         specDataWrapper5.id = ind2.Id;
//         applications.add(specDataWrapper5);
        
//         valueByTypeCat.put('Tab1DropdownRadioCombo', catSubCat);
//         valueByTypeIndApp.put('industryValues', industries);
//         valueByTypeIndApp.put('applicationValues', applications);
//         formData.categoryAndSubCategory = valueByTypeCat;
//         formData.industryAndApplication = valueByTypeIndApp;
//         Test.stopTest();
//         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
//         PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
//         Account acc2=PMP_TestDataUtility.createIntelAccount('account2',PMP_TestDataUtility.intel_Account_Record_Type,true);
//         PMP_Company__c cmp2=PMP_TestDataUtility.createCompanyInformation('TestCompny2',acc2.Id,true);
//         PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
//         PMP_Partner_Offering__c off2=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp2.Id,true,'Draft','');
        
//         formData.offering = off2;
        
//         Integer status = PMP_CreateOfferingTab1Service.validateOfferingData(formData);
//         system.assertEquals(0, status);
//     }
    
//     static testMethod void testgetOfferingCategorySubCategoryList(){
        
//         List<PMP_Category__c> updateCategories = new List<PMP_Category__c>();
        
//         Test.startTest();
//         PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
//         PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'TPS_900002','NPP_01_TYPE', 'en_us');
//         System.assertEquals('Component', cat1.Name);
//         PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('Memory', 'TPS_900022','TPS_900002', 'en_us');
//         PMP_Category__c cat3 = PMP_TestDataUtility.getCategory('SSD', 'TPS_64','TPS_900022', 'en_us');
//         PMP_Category__c cat4 = PMP_TestDataUtility.getCategory('ABC', 'TPS_68','TPS_900022', 'en_us');
        
        
//         cat0.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat0.PMP_Partner_Product_Category_Key__c = 'npp_01_type';
//         cat1.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat1.PMP_Partner_Product_Category_Key__c = 'tps_900002';
//         cat2.PMP_Business_Segment_Nm__c = 'IoT;Server;Personal Computers';
//         cat2.PMP_Partner_Product_Category_Key__c = 'tps_900022';
//         cat3.PMP_Business_Segment_Nm__c = 'IoT';
//         cat3.PMP_Partner_Product_Category_Key__c = 'tps_64';
//         cat4.PMP_Partner_Product_Category_Key__c = 'tps_68';
        
//         updateCategories.add(cat0);
//         updateCategories.add(cat1);
//         updateCategories.add(cat2);
//         updateCategories.add(cat3);
//         updateCategories.add(cat4);
        
//         update updateCategories;
        
        
//         PMP_CreateOfferingTab1Service.getOfferingCategorySubCategoryList('TPS_900022','en_US','Category');
//         cat2.PMP_Category_Chinese_Nm__c = '';
//         update cat2;
//         PMP_CreateOfferingTab1Service.getOfferingCategorySubCategoryList('TPS_900022','zh_CN','Category');
//         Test.stopTest();
//     }
    
//     static testMethod void getOfferingDetailsOfferedByTest(){
        
//         //User uObj = PMP_TestDataUtility.createUser(true);
//         //uObj.Core_IPA_One_Partner_Id__c='0038A00000S1c05QAZ';
//         //update uObj;
//         User uObj = [SELECT id, name, AccountId, Core_IPA_One_Partner_Id__c, CreatedbyId FROM User WHERE Alias = :ALIAS_NAME LIMIT 1];
//         System.assertNotEquals(uObj, Null);
//         // system.debug('uObj::'+uObj);
//        List<PMP_Company__c> companyList = new List<PMP_Company__c>();
//          PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('TestCompany1', uObj.AccountId, true);
//         companyInfo.PMP_Is_Published_Ind__c = true;
//         companyInfo.PMP_One_Partner_ID__c=uObj.Core_IPA_One_Partner_Id__c;//'0038A00000S1c05QAZ';
//         companyInfo.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
//         update companyInfo;
//         PMP_Company__c companyInfo1 = [select Id, name,PMP_One_Partner_ID__c from  PMP_Company__c where name='TestCompany1' limit 1];
//         // system.debug(':companyInfo:'+companyInfo1);
//         companyList.add(companyInfo1);
        
//         List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specList = new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
//         //Map<String, PMP_Specifications_Tab_Mapping__mdt> stepConfigurationsMap = new Map<String, PMP_Specifications_Tab_Mapping__mdt>();
//         string[] categoryList = new List<string>{'NPP_01_TYPE','NPP_02_TYPE_Comp','NPP_03_TYPE_Comp_Board','NPP_04_TYPE_Comp_Board_AMC','NPP_01_Industry','NPP_02_Ind_Agriculture','NPP_01_APP','NPP_02_APP_DigSecSurv'};
//         //String cDNA='12345';
        
//         // System.debug('speclist in testclass'+specList);
//         Intel_Text textUIGenerator = PMP_Offering_UI_Generator.createText('test','test',true);
//         //Intel_Checkbox checkBoxUIGenerator = PMP_Offering_UI_Generator.createCheckbox('name', 'label');
//         Intel_Resources resourceUIGenerator = PMP_Offering_UI_Generator.createResources();
//         PMP_Partner_Offering__c offObj = PMP_TestDataUtility.createOffering('test offering for test class',
//                                                                            'public content','Test desc',companyInfo.Id,true,'Draft','test tagline');
//         specList = PMP_SpecificationController.getOfferingSpecificationList(categoryList,offObj.id);  
//         //set<string> offSpecSet = new set<string>();
//         //map<string,string> specValDataMap = new  map<string,string>();
//         ChannelProgram cProg = new ChannelProgram(Name = 'Intel Partner Alliance');
//         insert cProg;
//         PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(Name =System.Label.PMP_Offering_Benefit,
//                                                                             PRM_Benefit_Cd__c = 'BFTMKTPLBC',
//                                                                             PRM_Channel_Program_Id__c = cProg.Id);
//         insert prmPartnerBenefit;
        
//         /*PRM_AccountBenefitAssociation__c prmAccBenefitAssoc = new PRM_AccountBenefitAssociation__c(
//             PRM_Account_Id__c = uObj.AccountId,
//             PRM_Partner_Benefit_Id__c= prmPartnerBenefit.Id,
//             PRM_Status_Nm__c = 'Active');*/
//        //Database.insert(prmAccBenefitAssoc);
        
//         //PMP_CreateOfferingTab1Service tab1ServiceObj = new PMP_CreateOfferingTab1Service();
//         Map<Id,String> result = PMP_CreateOfferingTab1Service.getCompanyInfoOptions();
//         String name = result.get(companyInfo.id);
//         //system.debug('name'+name);
        
        
        
//     }
    
//     @IsTest
//     private static void testOPIDCode() {
        
//         PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name = :PMP_INTERNAL_ADMIN_STR];
//         system.debug('ps ='+ps);
        
//         PermissionSetAssignment newPermissioSet= new PermissionSetAssignment();
//         newPermissioSet.PermissionSetId=ps.Id;
//         newPermissioSet.AssigneeId=userInfo.getUserId();
//         User currentUser = [ select Id from User where Id = :UserInfo.getUserId()];
//         System.runAs (currentUser) {
//         //Database.insert(newPermissioSet);
//         }

        
//         Core_IPS_Error_Code__c newCustomSetting = new Core_IPS_Error_Code__c();
//         newCustomSetting.Name= 'G115';
//         newCustomSetting.Language__c='English';
//         newCustomSetting.Core_Locale__c='EN';
//         newCustomSetting.Core_Error_Message__c='You have insufficient privilege for this action.';
       
//        // newCustomSetting.Error Message='You have insufficient privilege for this action'.
//             insert(newCustomSetting); 
//         UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
//         Profile profile = [select Id,name from Profile where Name ='Partner'];
//         //List<User> userList = new List<User>();
//         Account intelAccount1 = new Account(Name ='IntelAccount1',
//                                             Core_Sales_Group_New__c= 'CCG Sales Group',
//                                           Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',
//                                             BillingStreet='cbc chowk delhi',Core_Account_Type__c='Original Design Manufacturer (ODM)');
//         Database.insert(intelAccount1);
//         // System.debug('intelAccount1 inserted = '+ intelAccount1);
        
//         Contact contact1 = new Contact(firstname='Intel', 
//                     lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com',MailingCountry='India');
//         Database.insert(contact1);
        
                
//        /* User newUser = new User(
//             UserRoleId = userRole.Id,
//             profileId = profile.id, 
//             username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
//             email = 'pb@ff.com', 
//             emailencodingkey = 'UTF-8', 
//             localesidkey = 'en_US', 
//             languagelocalekey = 'en_US', 
//             timezonesidkey = 'America/Los_Angeles', 
//             alias='nuser', 
//             lastname='lastname', 
//             contactId = contact1.Id
//          );*/
        
//         //Inserting User
//         /*System.runAs (currentUser) {
//             Database.insert(newUser);
//         }*/
        
          
//         //System.runAs (newUser) {
//             String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
//             Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
//                                                   Industry='Agriculture',RecordTypeId=partnerAccRecTypeId, BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi');
            
//             Database.insert(partnerAccount1);
            
//             Core_Account_Group_Member__c accGroupMem1 = new Core_Account_Group_Member__c();
//             accGroupMem1.Core_Partner_Account_Id__c = partnerAccount1.Id;
//             accGroupMem1.Core_Intel_Account_Id__c = intelAccount1.Id;
//             accGroupMem1.Core_MDA_Ind__c = true;
//             accGroupMem1.Core_Inactive_Ind__c = false;
            
//             Database.insert(accGroupMem1);
//              ChannelProgram cProg = new ChannelProgram(); //Channel Program
//             cProg.Name='Intel Partner Alliance';
//             cProg.PRM_programCode__c='IPA';
//             Database.insert(cProg);        
            
//             ChannelProgramLevel lvl = new ChannelProgramLevel();
//             lvl.Name = 'Titanium';
//             lvl.PRM_programlevelcode__c = 'Titanium';
//             lvl.PRM_inactind__c = false;
//             lvl.ProgramId = cProg.Id;
//             insert lvl;
        
//             PRM_AccountChannelMemberShip__c acctMembership= new PRM_AccountChannelMemberShip__c();
//             acctMembership.PRM_Account_Id__c = intelAccount1.Id;
//             acctMembership.PRM_Channel_Program_Id__c = cProg.Id;
//             acctMembership.PRM_Status_Nm__c = 'Approved';        
//             acctMembership.PRM_Channel_Program_Level_Id__c = lvl.Id;     
//             acctMembership.PRM_Partner_Role__c = 'Service Provider'; 
//             //ginsert acctMembership;
            
            
        
//         PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(); //Partner Benefit
//         prmPartnerBenefit.Name='Partner University';
//         prmPartnerBenefit.PRM_Benefit_Cd__c = 'BFTTRGUNI';
//         prmPartnerBenefit.PRM_Channel_Program_Id__c = cProg.id;
//         insert prmPartnerBenefit;
        
        
        
//             /*PRM_PartnerBenefit__c prmPartnerBenefit = new PRM_PartnerBenefit__c(Name =System.Label.PMP_Offering_Benefit,
//                                                                                 PRM_Benefit_Cd__c = 'SMEN',
//                                                                                 PRM_Channel_Program_Id__c = cProg.Id);
//             Database.insert(prmPartnerBenefit);*/
//              PRM_PartnerType__c pt = new PRM_PartnerType__c(); //Partner Type
//             pt.Name = 'Cloud Service Provider (CSP)';
//             pt.PRM_PartneryTypeCode__c = 'CSP';
//             pt.PRM_PartnerRoleCode__c = 'SPR';
//             pt.PRM_channelprogram__c = cProg.id;
//             insert pt;
        
//             PRM_VXBnftMatrix__c bm = new PRM_VXBnftMatrix__c(); //Benefit Matrix 
//             bm.PRM_Partner_Benefit_Id__c = prmPartnerBenefit.id;
//             bm.PRM_Channel_Program_Id__c = cProg.id;
//             bm.PRM_Channel_Program_Level_Id__c = lvl.id;
//             bm.PRM_Partner_Type_Id__c = pt.id;
//             bm.PRM_Covered_Account_Ind__c  = true;
//             bm.PRM_Approval_Type_Nm__c = 'Manual';
                
//             /*PRM_AccountBenefitAssociation__c prmAccBenefitAssoc = new PRM_AccountBenefitAssociation__c(
//                 PRM_Account_Id__c = intelAccount1.Id,
//                 PRM_Partner_Benefit_Id__c= prmPartnerBenefit.Id,
//                 PRM_Status_Nm__c = 'Active');*/
//             //Database.insert(prmAccBenefitAssoc);

//         //}
//         //System.runAs (newUser) {
//             Test.startTest();
//             //User usr = [select Id, Core_IPA_One_Partner_Id__c, name, AccountID from User where Id=:newUser.id limit 1];
//             //system.debug('usr:::::1'+usr);
//         PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany11', intelAccount1.Id, true);
//         //cmp1.PMP_One_Partner_ID__c=usr.Core_IPA_One_Partner_Id__c;
//         cmp1.PMP_Company_Lifecycle_Status_Nm__c=PMP_StaticConstants_Partner.Published;
//         //cmp1.PMP_Partner_Benefit_Type__c =PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced; //IPA2.0 - TWC729-7885
//         update cmp1;
//         System.assertEquals('Published', cmp1.PMP_Company_Lifecycle_Status_Nm__c);
        
//              //methods to call
//              //st2
//             set<string> offSpecSet = new set<string>();
//              map<string,string> specValDataMap = new  map<string,string>();
//             //st2end
//             map<string,List<string>> specValListMap = new map<string,List<string>>();
//            Intel_Step response = PMP_CreateOfferingTab1Service.getOfferingDetailsInputs('Tab1','Software',new List<PMP_SpecificationController.Core_PMP_OfferingSpecs>(),
//                                                                   new map<string, PMP_Specifications_Tab_Mapping__mdt>(),new PMP_Partner_Offering__c(),offSpecSet,specValDataMap,specValListMap,null);
            
            
//             Test.stopTest();
//        //}
       
//     }// end of test method
    
}