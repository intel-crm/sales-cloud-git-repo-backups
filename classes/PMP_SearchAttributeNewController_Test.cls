@isTest
public class PMP_SearchAttributeNewController_Test extends PMP_SearchWrapperStore  {
    
     @testSetup static void setup(){
        PMP_Company__c partner = new PMP_Company__c();
        partner.Name = 'Test_Partner';
 //       partner.PMP_Partner_Program_nm__c = 'distributor'; 
        //partner.PMP_Account_Specialty__c = 'Specialty Partner'; 
        partner.PMP_Is_Published_Ind__c = true;
        //partner.PMP_Biz_Org_Type_Txt__c = 'Intel Approved Device Supplier (IADS)';
        insert partner;
        Id masterPartner = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Account intelAcc1 = PMP_TestDataUtility.createIntelAccount('TestIntelAccount',masterPartner, true);
        intelAcc1.Core_IPA_Partner_Role__c = 'Distributor' ;
        intelAcc1.Core_Account_Type__c='Intel Authorized Distributor (IAD)';
        update intelAcc1;
        //create PMP_Company__c records that match the criteria of the apex email records and some that do not match the criteria.
        PMP_Company__c partner1 = PMP_TestDataUtility.createCompanyInformation('Test1', intelAcc1.id,false);
       
         
             
       // PMP_Company__c partner1 = new PMP_Company__c();
        partner1.Name = 'Test_Partner1';
        partner1.PMP_Partner_Program_nm__c = 'Partner'; 
        //partner1.PMP_Account_Specialty__c = 'Specialty Partner';
        partner1.PMP_Is_Published_Ind__c = true;
        partner1.PMP_Disti_Components_Nm__c  = 'Data Center';
        partner1.PMP_Partner_Program_nm__c='Distributor';
        partner1.PMP_Disti_Sys_Solutions_Nm__c = 'Data Center';
        partner1.PMP_Disti_Country_Coverage_Txt__c = 'Testing';
         partner1.PMP_Biz_Org_Type_Value_Txt__c='Intel Authorized Distributor (IAD)';
       // partner1.PMP_Account_Id__c = true; 
        insert partner1;
         
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Dsc__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=partner1.Id);
        insert trans;
        trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Tag_Line__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=partner1.Id);
        insert trans;
        trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Tag_Line__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=partner1.Id);
        insert trans;
        trans = new PMP_Company_Translation__c(Name = 'test', PMP_Field_Nm__c='PMP_Account_Dsc__c',PMP_English_Txt__c='eng',PMP_Japanese_Txt__c='jap', PMP_Chinese_Txt__c='chi',PMP_Company_Information_Id__c=partner1.Id);
        insert trans;
         
        //IPA2.0:US-4497-1631_OfferingEOL
        /*PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = partner.Id;
        off.PMP_Category_nm__c='Middleware';
        off.PMP_Sub_Category_nm__c='Board';
        insert off;*/
         
         PMP_Category__c ParentCategory = new PMP_Category__c();
        ParentCategory.Name = 'Categories'; 
        ParentCategory.PMP_Active_Ind__c = true;
        ParentCategory.PMP_Partner_Product_Category_Cd__c = 'NPP_01_TYPE';
        ParentCategory.PMP_Partner_Product_Category_Key__c = 'appp';
        ParentCategory.PMP_Partner_Product_Parent_Category_Cd__c = 'Solution_Marketplace_Hierarchy';
        Insert ParentCategory;
        
        PMP_Category__c Categorynew = new PMP_Category__c();
        Categorynew.Name = 'Software'; 
        Categorynew.PMP_Active_Ind__c = true;
        Categorynew.PMP_Partner_Product_Category_Cd__c = 'bpppp';
        Categorynew.PMP_Partner_Product_Category_Key__c = 'bpppp';
        Categorynew.PMP_Partner_Product_Parent_Category_Cd__c = 'appp';
        Categorynew.PMP_Parent_Category_Id__c = ParentCategory.Id;
        Insert Categorynew;
        
        
        PMP_Category__c Category1 = new PMP_Category__c();
        Category1.Name = 'Middleware'; 
        Category1.PMP_Active_Ind__c = true;
        Category1.PMP_Partner_Product_Category_Cd__c = 'cpppp';
        Category1.PMP_Partner_Product_Category_Key__c = 'cpppp';
        Category1.PMP_Partner_Product_Parent_Category_Cd__c = 'bpppp';
        Category1.PMP_Parent_Category_Id__c = Categorynew.Id;
        
        Insert Category1;
         
         //IPA2.0:US-4497-1631_OfferingEOL
         /*PMP_Partner_Offering_Category__c offCatnew = new PMP_Partner_Offering_Category__c();
        offCatnew.Name = 'Categories';
        offCatnew.PMP_Offering_Id__c = off.Id;
      //  offCatnew.PMP_Category_Id__c = ParentCategory.Id;
        offCatnew.PMP_Category_Id__c = Category1.Id;
        insert offCatnew;        
         
        List<PMP_Partner_Offering_Translation__c> translationList = new List<PMP_Partner_Offering_Translation__c>();
        
        PMP_Partner_Offering_Translation__c offTranslation = PMP_TestDataUtility.createOfferingTranslation(off.id,'testTranslation');
        if(offTranslation!=null){
           offTranslation.PMP_English_Txt__c = 'Test';
           offTranslation.PMP_Chinese_Txt__c = 'Test';
           offTranslation.PMP_Japanese_Txt__c = 'Test';
           offTranslation.PMP_Field_Nm__c = 'PMP_Partner_Offering_Nm__c';
           translationList.add(offTranslation);
        }
        
        PMP_Partner_Offering_Translation__c offTranslation2 = PMP_TestDataUtility.createOfferingTranslation(off.id,'testTranslation');
        if(offTranslation2!=null){
           offTranslation2.PMP_English_Txt__c = 'Test';
           offTranslation2.PMP_Chinese_Txt__c = 'Test';
           offTranslation2.PMP_Japanese_Txt__c = 'Test';
           offTranslation2.PMP_Field_Nm__c = 'PMP_Partner_Offering_Dsc__c';
           translationList.add(offTranslation2);
        }
        
        PMP_Partner_Offering_Translation__c offTranslation3 = PMP_TestDataUtility.createOfferingTranslation(off.id,'testTranslation');
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
        
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = partner.Id;
        insert off1;
         PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Test','Public Content','Test',null,true,'Draft',' ');
         PMP_Partner_Offering_Specification__c offeringSpec = PMP_TestDataUtility.getPMPOfferingSpecification(offering.Id);
         PMP_Specification_Value__c newSpecVal=PMP_TestDataUtility.getSpecVals();
         newSpecVal.PMP_Spec_Value_Type_Nm__c ='Geography'; 
         update newSpecVal;
         
          PMP_Partner_Offering_Specification__c specs=PMP_TestDataUtility.createOfferingSpecification('2-in-1', off.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_GeographicCoverage',
                                                        'NPP_02_TYPE_Sys','NPP_03_TYPE_Sys_Laptop', 'NPP_GeographicCoverage','Checkbox');
          
          PMP_Partner_Offering_Specification__c specs1=PMP_TestDataUtility.createOfferingSpecification('2-in-2', off.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_GeographicCoverage',
                                                        'NPP_02_TYPE_Sys',' ', 'NPP_GeographicCoverage','Checkbox');
          string str= specs1.PMP_Specification_Value_Id__c;*/
          
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'test';
        Spec.PMP_Specification_Name__c = 'test1';
        Spec.PMP_Partner_Product_Specification_Id__c = 'Test|Test1';
        Spec.PMP_Partner_Product_Specification_Id__c = 'NPP|03|TYPE|Sys';
        insert Spec;
        
       PMP_Category__c appCategory = new PMP_Category__c (Name=system.label.PMP_application, PMP_Partner_Product_Category_Cd__c='NPP_01_APP',
                                                           PMP_Partner_Product_Parent_Category_Cd__c=PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY, PMP_Active_Ind__c=true);
        PMP_Category__c category = new PMP_Category__c(Name='Categories', PMP_Partner_Product_Category_Cd__c='NPP_01_Type',
                                                       PMP_Partner_Product_Parent_Category_Cd__c= PMP_StaticConstants_Partner.SOLUTION_MARKETPLACE_HIERARCHY, PMP_Active_Ind__c=true);
        PMP_Specification__c spec0 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox' ,Name = 'Geo',PMP_Parent_Specification_Id__c=null,PMP_Partner_Product_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Product_Parent_Specification_Id__c = null,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec0;
        PMP_Specification__c spec1 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo1',PMP_Parent_Specification_Id__c=spec0.id,PMP_Partner_Product_Specification_Id__c = 'ASMO',PMP_Product_Parent_Specification_Id__c = PMP_StaticConstants_Partner.REGION_PIM_ID,PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec1;
        PMP_Specification__c spec2 = new PMP_Specification__c(PMP_Display_Type_Nm__c ='checkbox',Name = 'Geo2',PMP_Parent_Specification_Id__c=spec1.id,PMP_Partner_Product_Specification_Id__c = 'LAR',PMP_Product_Parent_Specification_Id__c = 'ASMO',PMP_Specification_Japanese_Nm__c='japanese',PMP_Specification_Chinese_Nm__c='chinese');
        insert spec2;
        PMP_Specification_Value__c specValue = new PMP_Specification_Value__c(PMP_Display_Type_Nm__c ='Checkbox',PMP_Product_Specification_Value_Cd__c = 'NPP_03_TYPE_Sys_Laptop',PMP_Spec_Value_Type_Nm__c='Geography');
        insert specValue;
         
        
        PMP_Company_Region__c ptnrSpec = new PMP_Company_Region__c();
        ptnrSpec.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec;
        
        PMP_Company_Region__c ptnrSpec1 = new PMP_Company_Region__c();
        ptnrSpec1.PMP_Specification_Id__c = spec1.Id;
        ptnrSpec1.PMP_Company_Id__c = partner1.Id;
        insert ptnrSpec1;
        
        PMP_Company_Region__c ptnrSpec2 = new PMP_Company_Region__c();
        ptnrSpec2.PMP_Specification_Id__c = spec2.Id;
        ptnrSpec2.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec2;
        PMP_Company_Region__c ptnrSpec3 = new PMP_Company_Region__c();
        ptnrSpec3.PMP_Specification_Value__c = specValue.Id;
        ptnrSpec3.PMP_Company_Id__c = partner.Id;
        insert ptnrSpec3;
        
        
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE', 'Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        PMP_Category__c cat2 = PMP_TestDataUtility.getCategory('BoardNPP_01_TYPE', 'NPP_02_Comp_Board','NPP_02_Comp', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null; 
         
         cat0.PMP_Active_Ind__c = true;
        app0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
       
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        cat2.PMP_Parent_Category_Id__c = cat1.Id;
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        catList.add(cat2);
        update catList;
        
        PMP_Partner_Category__c ptnrCat = new PMP_Partner_Category__c();
        ptnrCat.PMP_Category_Id__c = app1.Id;
        ptnrCat.PMP_Partner_Id__c = partner.Id;
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
        ptnrCat.PMP_Partner_Id__c = partner.Id;
        insert ptnrCat;
        
        ptnrCat1 = new PMP_Partner_Category__c();
        ptnrCat1.PMP_Category_Id__c = ind1.Id;
        ptnrCat1.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat1;
        
        ptnrCat2 = new PMP_Partner_Category__c();
        ptnrCat2.PMP_Category_Id__c = ind2.Id;
        ptnrCat2.PMP_Partner_Id__c = partner1.Id;
        insert ptnrCat2;
        
       //IPA2.0:US-4497-1631_OfferingEOL
         /*off1.PMP_Category_nm__c =cat0.id;
         update off1;
          PMP_Partner_Offering_Category__c offCat = new PMP_Partner_Offering_Category__c();
        offCat.PMP_Category_Id__c = app1.Id;
        offCat.PMP_Offering_Id__c = off.Id;
        insert offCat;
        //PMP_Partner_Product_Category_Cd__c
        PMP_Partner_Offering_Category__c offCat1 = new PMP_Partner_Offering_Category__c();
        offCat1.PMP_Category_Id__c = app1.Id;
        offCat1.PMP_Offering_Id__c = off1.Id;
        insert offCat1;
        
        PMP_Partner_Offering_Category__c offCat2 = new PMP_Partner_Offering_Category__c();
        offCat2.PMP_Category_Id__c = app2.Id;
        offCat2.PMP_Offering_Id__c = off1.Id;
        insert offCat2;
        
        PMP_Partner_Offering_Category__c offCat3 = new PMP_Partner_Offering_Category__c();
        offCat3.PMP_Category_Id__c = cat2.Id;
        offCat3.PMP_Offering_Id__c = off1.Id;
        insert offCat3;
        
      //  offCat3 = new PMP_Partner_Offering_Category__c();
       // offCat3.PMP_Category_Id__c = cat0.Id;
       // offCat3.PMP_Offering_Id__c = off1.Id;
        //insert offCat3;
      PMP_Specification_Value_Association__c specCatValue = New PMP_Specification_Value_Association__c(Name = 'test',
                                                               PMP_Category_Id__c = cat0.id, PMP_Specification_Id__c = spec1.id,
                                                               PMP_Specification_Value_Id__c = specs.PMP_Specification_Value_Id__c );
         
      PMP_Specification_Value_Association__c specCatValue1 = New PMP_Specification_Value_Association__c(Name = 'test1',
                                                               PMP_Category_Id__c = cat0.id, PMP_Specification_Id__c = spec1.id,
                                                               PMP_Specification_Value_Id__c = specs1.PMP_Specification_Value_Id__c );
        insert specCatValue;*/  
         
      PMP_Specification_Value__c specCountry = new PMP_Specification_Value__c();
         specCountry.Name = 'XYZ-English';
         specCountry.PMP_Display_Type_Nm__c = 'Checkbox';
         specCountry.PMP_Specification_Value_Chinese_Cd__c = 'XYZ_Chinese';
         specCountry.PMP_Specification_Value_Japanese_Cd__c = 'XYZ_Japanese';
         specCountry.PMP_Spec_Value_Type_Nm__c = 'Geography';
       
         insert specCountry;
    }
    //IPA2.0:US-4497-1631_OfferingEOL
    /*@isTest static void testgetOfferingAttributes(){
         Test.startTest();
        List<String> temp = new List<String>();*/
  /*      List<PMP_Partner_Offering__c> offerings = [Select Id FROM PMP_Partner_Offering__c];
        for(PMP_Partner_Offering__c off :offerings){
            temp.add(off.Id);
        }*/
        /*PMP_Partner_Offering__c offering = [Select Id FROM PMP_Partner_Offering__c where name='Test_Off' LIMIT 1];
       
        Map<String, List<Object>> result = new Map<String, List<Object>>();
        result =  PMP_SearchAttributeNewController.getOfferingAttributes(offering.Id,'en_US');
        result =  PMP_SearchAttributeNewController.getOfferingAttributes(offering.Id,'zh_CN');
     //   result =  PMP_SearchAttributeNewController.getOfferingAttributes(temp[1],'en_US');
     //    Map<String, List<Object>> result2 =   PMP_SearchAttributeNewController.getAttributes(temp[1],'en_US');
         Map<String, List<Object>> result2 =   PMP_SearchAttributeNewController.getAttributes(offering.Id,'ja');
        
       system.assert(result.size() != 0);
        Test.StopTest();
    }*/
    
    @isTest static void getPartnerAttributes_Test(){
        List<String> temp = new List<String>();
         Test.startTest(); 
        List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c where name='Test_Partner1' LIMIT 1];
        
       
        
        PMP_Company__c partnerTest = [Select Id FROM PMP_Company__c where name='Test_Partner' LIMIT 1];
        PMP_Company__c partnerTest1 = [Select Id FROM PMP_Company__c where name='Test_Partner1' LIMIT 1];
        // System.debug('test'+partners.size());
        
        for(PMP_Company__c partner :partners){
            temp.add(partner.Id);
        }
        
        
       Map<String, List<Object>> result = PMP_SearchAttributeNewController.getPartnerAttributes(temp[0],'en_US');
        
       Map<String, List<Object>> result1 = PMP_SearchAttributeNewController.getPartnerAttributes(partnerTest.Id,'en-US');
       Map<String, List<Object>> result2 = PMP_SearchAttributeNewController.getPartnerAttributes(partnerTest.Id,'ja');
       Map<String, List<Object>> result3 = PMP_SearchAttributeNewController.getPartnerAttributes(partnerTest.Id,'zh-Hans-CN');
        
        
        
       Map<String, List<Object>> result4 = PMP_SearchAttributeNewController.getPartnerAttributes(partnerTest1.Id,'zh-Hans-CN');

       
        
       PMP_SearchAttributeNewController.getAttributes(partnerTest1.Id,'zh_CN');
        PMP_SearchAttributeNewController.getAttributes(partnerTest1.Id,'ja');

       system.assert(result.size() != 0);
        Test.stopTest();
    }
    @isTest static void getPartnerAttributesNew_Test(){
        Test.startTest();
         prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;

        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
                
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
       
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        //company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile;
        company.PMP_Is_Published_Ind__c=true;
      
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        acm.PRM_Status_Reason_Txt__c = 'Approved';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
       
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        
        
       Map<String, List<Object>> result4 = PMP_SearchAttributeNewController.getPartnerAttributes(company.Id,'zh-Hans-CN');
        Test.stopTest();
    }

}