@isTest
public class PMP_FeaturedCarouselController_Test extends PMP_SearchWrapperStore {
    
    @testSetup static void testDataFactory(){
        /*List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'EVENT_TAB_ID';
        st.PMP_Value__c = 'Marketplace_Event';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'THUMBNAIL_IMAGE';
        st.PMP_Value__c = 'PMP_Thumbnail_Image';
        stList.add(st);
        
        insert stList;*/
        
          List<PMP_Static_Constants__c> stList = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_PIM_Industry_Id';
        st.PMP_Value__c = 'NPP_01_Industry';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Off_Sort_By_Featured';
        st.PMP_Value__c = 'PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST';
        stList.add(st);
        
        st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Partner_Sort_By_Name_Desc';
        st.PMP_Value__c = 'Name DESC NULLS LAST';
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
        st.PMP_Value__c = '	IT Admin';
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
        stList.add(new PMP_Static_Constants__c(Name='PMP_IPA_INTERNAL_ADMIN',PMP_Value__c='PMP - All Intel Admin Users'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Image',PMP_Value__c='Image'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Storefront_Default_Image_URL',PMP_Value__c='/file-asset/PMP_Partner_Default_Logo?isOptimized=false'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_Intel_Only',PMP_Value__c='Intel Only Content'));
        stList.add(new PMP_Static_Constants__c(Name='PMP_PIM_Category_Id',PMP_Value__c='NPP_01_TYPE'));
       	stList.add(new PMP_Static_Constants__c(Name='PMP_Partner_Sort_By_Name_Asc',PMP_Value__c='Name ASC NULLS LAST'));
        
        insert stList;
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c ind0 = PMP_TestDataUtility.getCategory('Industry', 'NPP_01_Industry','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c cat1 = PMP_TestDataUtility.getCategory('Component', 'NPP_02_Comp','NPP_01_TYPE', 'en_us');
        PMP_Category__c cat3 = PMP_TestDataUtility.getCategory('Board', 'NPP_02_Board','NPP_02_Comp', 'en_us');
        PMP_Category__c app1 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker','NPP_01_APP', 'en_us');
        PMP_Category__c ind1 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare','NPP_01_Industry', 'en_us');
        PMP_Category__c app2 = PMP_TestDataUtility.getCategory('Connected Worker', 'IPA_APP_ConnectedWorker1','IPA_APP_ConnectedWorker', 'en_us');
        PMP_Category__c ind2 = PMP_TestDataUtility.getCategory('Healthcare', 'IPA_Ind_HealthCare1','IPA_Ind_HealthCare', 'en_us');
        cat0.PMP_Parent_Category_Id__c = null; 
        app0.PMP_Parent_Category_Id__c = null;
        ind0.PMP_Parent_Category_Id__c = null;
        cat1.PMP_Parent_Category_Id__c = cat0.Id;
        app1.PMP_Parent_Category_Id__c = app0.Id;
        ind1.PMP_Parent_Category_Id__c = ind0.Id;
        app2.PMP_Parent_Category_Id__c = app1.Id;
        ind2.PMP_Parent_Category_Id__c = ind1.Id;
        cat3.PMP_Parent_Category_Id__c = cat1.Id;
      
        catList.add(cat0);
        catList.add(cat1);
        catList.add(app0);
        catList.add(app1);
        catList.add(ind0);
        catList.add(ind1);
        catList.add(app2);
        catList.add(ind2);
        catList.add(cat3);
        update catList;  
        
        FeaturedProductTab FPList = new FeaturedProductTab();
        
        /*Id offId = PMP_TestDataUtility.getOffering();
system.debug('offId'+offId);

PMP_Partner_Offering_Category__c offCatId = PMP_TestDataUtility.getPMPOfferingCategory(offId);
system.debug('offCatId'+offCatId);*/
        
        /*PMP_Category__c newCategory=PMP_TestDataUtility.getCategory('Application', 'NPP_01_APP','NPP Taxonomy', 'en_us');
//insert newCategory; 
offCatId.Name='2-in-1';
//offCatId.PMP_Offering_Id__c=offId;
offCatId.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
offCatId.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
offCatId.PMP_Category_Id__c = newCategory.Id;
update offCatId;*/
        
        List<Id> cateId=new List<Id>();
        PMP_Category__c testCategory = new PMP_Category__c();
        testCategory.Name = 'testCategory';
        testCategory.PMP_Category_Chinese_Nm__c = 'Chinese';
        testCategory.PMP_Category_Japanese_Nm__c = 'Japanese';
        testCategory.PMP_Partner_Product_Category_Cd__c = 'NPP_01_Type';
        testCategory.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_Taxonomy';
        testCategory.PMP_Category_Display_Sequence_Nbr__c=123;
        testCategory.PMP_Active_Ind__c = true;
        insert testCategory; 
        cateId.add(testCategory.Id);
        
        PMP_Category__c testCategory1 = new PMP_Category__c();
        testCategory1.Name = 'testCategory1';
        testCategory1.PMP_Category_Chinese_Nm__c = 'Chinese';
        testCategory1.PMP_Category_Japanese_Nm__c = 'Japanese';
        testCategory1.PMP_Partner_Product_Category_Cd__c = 'NPP_01_Type';
        testCategory1.PMP_Partner_Product_Parent_Category_Cd__c = 'NPP_Taxonomy';
        testCategory1.PMP_Category_Display_Sequence_Nbr__c=123;
        testCategory1.PMP_Active_Ind__c = true;
        insert testCategory1;
        cateId.add(testCategory1.Id);
        
        List<Id> partId=new List<Id>();
        PMP_Company__c testPartner1 =  new PMP_Company__c();
        testPartner1.Name = 'testPartner1';
        testPartner1.PMP_Account_Specialty__c = 'Video Specialty';       
        testPartner1.PMP_Partner_Program_nm__c = 'ISA';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert testPartner1; 
        partId.add(testPartner1.Id);
        
        PMP_Company__c testPartner2 =  new PMP_Company__c();
        testPartner2.Name = 'testPartner2';
        testPartner2.PMP_Account_Specialty__c = 'Video Specialty';       
        testPartner2.PMP_Partner_Program_nm__c = 'ISA';
        testPartner2.PMP_Account_Dsc__c = 'test';
        testPartner2.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner2.PMP_Is_Published_Ind__c = true;
        testPartner2.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner2.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert testPartner2; 
        partId.add(testPartner2.Id);
        
        List<Id> offId=new List<Id>();
        PMP_Partner_Offering__c off = new PMP_Partner_Offering__c();
        off.Name = 'Test_Off';
        off.PMP_Company_Id__c = testPartner1.Id;
        off.PMP_Category_nm__c=testCategory1.Id;
        off.PMP_Featured_Offering_Ind__c = true;
        off.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        off.PMP_Partner_Offering_Nm__c = 'Test_Off';
        off.PMP_Partner_Offering_Start_Dt__c=System.today() - 1;
        off.PMP_Partner_Offering_End_Dt__c=System.today() + 1;
        off.PMP_Offering_Status_Update_Dt__c=System.today()-10;
        off.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
        insert off;
        offId.add(off.Id);
        
        PMP_Partner_Offering__c off1 = new PMP_Partner_Offering__c();
        off1.Name = 'Test_Off1';
        off1.PMP_Company_Id__c = testPartner2.Id;
        off1.PMP_Category_nm__c=testCategory1.Id;
        off1.PMP_Featured_Offering_Ind__c = true;
        off1.PMP_Partner_Offering_Lifecycle_Status_Nm__c='Published';
        off1.PMP_Partner_Offering_Nm__c = 'Test_Off1';
        off1.PMP_Partner_Offering_Start_Dt__c=System.today() - 1;
        off1.PMP_Partner_Offering_End_Dt__c=System.today() + 1;
        off1.PMP_Offering_Status_Update_Dt__c=System.today()-10;
        off1.PMP_Partner_Offering_Visibility_Nm__c = 'Public Content';
        insert off1;
        offId.add(off1.Id);
        
        PMP_Partner_Offering_Category__c testOfferingCategory1 = new PMP_Partner_Offering_Category__c();
        testOfferingCategory1.PMP_Category_Id__c = testCategory1.Id;
        testOfferingCategory1.PMP_Offering_Id__c=off1.Id;
        insert testOfferingCategory1; 
        
        PMP_Partner_Offering_Category__c testOfferingCategory = new PMP_Partner_Offering_Category__c();
        testOfferingCategory.PMP_Category_Id__c = testCategory.Id;
        testOfferingCategory.PMP_Offering_Id__c=off.Id;
        insert testOfferingCategory;  
        
        
        List<Id> eveIds=new List<Id>();
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.Now()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.Now()+1;
        eve.PMP_Marketplace_Event_Tagline__c = 'tagline';
        insert eve;
        eveIds.add(eve.Id);
        
        PMP_Marketplace_Event__c eve1=new PMP_Marketplace_Event__c();
        eve1.Name='Test Event1';
        eve1.PMP_Marketplace_Event_Start_Dt__c=System.Now()-5;
        eve1.PMP_Marketplace_Event_End_Dt__c=System.Now()+5;
        eve1.PMP_Marketplace_Event_Tagline__c = 'tagline1';
        insert eve1;
        eveIds.add(eve1.Id);
        
        
        PMP_Marketplace_Event_Offering__c eveOff=new PMP_Marketplace_Event_Offering__c();
        eveOff.PMP_Offering_Id__c=offId[0];
        eveOff.PMP_Event_Id__c=eveIds[0];
        insert eveoff; 
        
        PMP_Marketplace_Event_Offering__c eveOff1 = new PMP_Marketplace_Event_Offering__c();
        eveOff1.PMP_Offering_Id__c=offId[1];
        eveOff1.PMP_Event_Id__c=eveIds[1];
        insert eveoff1;
        
        PMP_Marketplace_Event_Partner__c  evePar=new PMP_Marketplace_Event_Partner__c();
        evePar.PMP_Company_Id__c=testPartner1.Id;
        evePar.PMP_Event_Id__c=eve.Id;
        insert evePar;
        
        PMP_Partner_Offering_Resource__c parRes = new PMP_Partner_Offering_Resource__c();
        parRes.PMP_Offering_Id__c = off1.Id;
        parRes.PMP_Partner_Offering_Image__c = st.Name;
        parRes.PMP_Resource_Type_Nm__c='Product Web Page';
        insert parRes;
        
        PMP_Marketplace_Event_Translation__c  trans=new PMP_Marketplace_Event_Translation__c();
        trans.PMP_Marketplace_Event_Id__c=eve.Id;
        trans.PMP_Field_Nm__c='Tagline';
        trans.PMP_English_Txt__c='Tagline';
        trans.PMP_Chinese_Txt__c = 'tag';
        trans.PMP_Japanese_Txt__c = 'tag';
        insert trans;
        
        PMP_Marketplace_Event_Translation__c trans1=new PMP_Marketplace_Event_Translation__c();
        trans1.PMP_Marketplace_Event_Id__c=eve.Id;
        trans1.PMP_Field_Nm__c='Description';
        trans1.PMP_English_Txt__c='Desc';
        trans1.PMP_Chinese_Txt__c = 'desc';
        trans1.PMP_Japanese_Txt__c = 'desc';
        insert trans1;
        
        PMP_Partner_Offering_Translation__c partOffTrans = new PMP_Partner_Offering_Translation__c();
        partOffTrans.PMP_English_Txt__c = 'Text';
        partOffTrans.PMP_Chinese_Txt__c = 'Text';
        partOffTrans.PMP_Japanese_Txt__c = 'Text';
        partOffTrans.PMP_Partner_Offering_Id__c = off.Id;
        insert partOffTrans;
    }    
    
    @isTest static void testGetFeatredTabs(){
        /* List<FeaturedProductTab> ftList= new List<FeaturedProductTab>();
for (PMP_Category__c cat: catList){
FeaturedProductTab ft=new FeaturedProductTab();
ft.categoryId = cat.Id;
ftList.add(ft);}  */
        List<String> catIds=new List<String>();
        List<PMP_Category__c> cc=[Select Id,Name from PMP_Category__c ];
        for(PMP_Category__c cat:cc)
        {
            catIds.add(cat.Id);
        }
        
        Test.StartTest();
        PMP_SearchFeaturedCarouselController.getFeaturedTabs('en_US');
        Test.stopTest();
        
        
        /*List<String> temp = new List<String>();
List<PMP_Company__c> partners = [Select Id FROM PMP_Company__c WHERE Name Like 'Test_Partner%'];
for(PMP_Company__c partner :partners){
temp.add(partner.Id);
}

Test.startTest();
List<Filter> result = PMP_SearchContextualFilterController.getPartnerContextualFilters(temp,'en_US');
system.assert(!result.isEmpty());
Test.stopTest();  */
        
    }
    
    @isTest static void getEvents_Test()
    {
        Map<String, List<String>> selectedFilters = new Map<String, List<String>>();
        Map<String,Tag> eventTagMap=  new Map<String,Tag>();
        List<String> eventList=new List<String>();
        eventList.add('Marketplace_event');
        selectedFilters.put('Marketplace_event', eventList);
        List<String> offengIds=new List<String>();
        
        list<PMP_Partner_Offering__c> offIds = [SELECT Id from PMP_Partner_Offering__c where Name = 'Test_Off' LIMIT 1];
        //offengIds.add(offIds[0].id);
        Test.startTest();
        PMP_SearchFeaturedCarouselController.getEvents(selectedFilters,'',offengIds);
        PMP_SearchFeaturedCarouselController.getEventOffCount(eventTagMap,offengIds);
        Test.stopTest();
        
    }
    
    @isTest static void getFeaturedOfferings_Test(){
        PMP_Category__c pp=[Select Id,Name from  PMP_Category__c limit 1];
        
        List<PMP_Partner_Offering_Category__c> Offcat=[Select Id,Name from PMP_Partner_Offering_Category__c];
        List<String> offCatIds=new List<String>();
        
        for(PMP_Partner_Offering_Category__c offCatLists:Offcat)
        {
            offCatIds.add(offCatLists.Id);
        }
        
        List<PMP_Partner_Offering__c> Off=[Select Id,Name from PMP_Partner_Offering__c];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:Off)
        {
            offIds.add(offLists.Id);
        }
        
        List<PMP_Company__c> part=[Select Id,Name from PMP_Company__c];
        List<String> parIds=new List<String>();
        
        for(PMP_Company__c partLists:part)
        {
            parIds.add(partLists.Id);
        }
       
        List<PMP_Marketplace_Event_Offering__c> eveOff=[SELECT id, Name,PMP_Offering_Id__c,PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where Name LIKE 'Test Event Partner%'];
        List<Id> eveIds=new List<Id>();
        for(PMP_Marketplace_Event_Offering__c eveoffLists:eveOff)
        {
            eveIds.add(eveoffLists.Id);
        }
        Test.startTest();
        PMP_SearchFeaturedCarouselController.getFeaturedOfferings(pp.Id,1,1,'en_US');
        //PMP_SearchFeaturedCarouselController.getFeaturedOfferings('Marketplace_Event',1,1,'en_US');
        
        Test.stopTest();
        
    }
    
    @isTest static void getFeaturedEventOfferings_Test(){
        PMP_Category__c  pp=[Select Id,Name from  PMP_Category__c limit 1];
        List<PMP_Partner_Offering__c> Off=[Select Id,Name from PMP_Partner_Offering__c];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:Off)
        {
            offIds.add(offLists.Id);
        }
        
        List<PMP_Company__c> part=[Select Id,Name from PMP_Company__c];
        List<String> parIds=new List<String>();
        
        for(PMP_Company__c partLists:part)
        {
            parIds.add(partLists.Id);
        }
        
        List<PMP_Partner_Offering_Category__c> poc = [Select Id,Name from PMP_Partner_Offering_Category__c];
        List<String> offCIds=new List<String>();
        
        for(PMP_Partner_Offering_Category__c offCatLists:poc)
        {
            offCIds.add(offCatLists.Id);
        }
        
         List<PMP_Marketplace_Event__c> pp1=[Select Id,Name from PMP_Marketplace_Event__c];
        List<String> ppIds=new List<String>();
        for(PMP_Marketplace_Event__c cc:pp1)
        {
            ppIds.add(cc.Id);
        }
       
        List<PMP_Marketplace_Event_Offering__c> eveOff=[SELECT id, Name,PMP_Offering_Id__c,PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where Name LIKE 'Test Event Partner%' ];
        List<Id> eveIds=new List<Id>();
        for(PMP_Marketplace_Event_Offering__c eveoffLists:eveOff)
        {
            eveIds.add(eveoffLists.Id);
        }
        
        //List<AggregateResult> distincteveOff=[SELECT id, Name,PMP_Offering_Id__c,PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where Name LIKE '%Test%' group by PMP_Offering_Id__c]; 
        Test.startTest();
        //PMP_SearchFeaturedCarouselController.getFeaturedOfferings(pp.Id,1,1,'en_US');
        PMP_SearchFeaturedCarouselController.getFeaturedOfferings('Marketplace_Event',1,1,'en_US');
        
        Test.stopTest();
        
    }  
     @isTest static void getEventOffCount_test()
    {
        Map<String,Tag> eventTag=new Map<String,Tag>();
        Tag tag = new Tag();
        tag.label ='';
        tag.count = 3;
        tag.value ='';
        tag.parent ='';
        tag.children = new List<Tag>();
        tag.pimId = '';
        eventTag.put('IPC Connect',tag);
        List<PMP_Marketplace_Event_Offering__c> eveOff=[SELECT id, Name,PMP_Offering_Id__c,PMP_Event_Id__c from PMP_Marketplace_Event_Offering__c where Name LIKE 'Test Event Partner%'];
        List<Id> eveIds=new List<Id>();
        for(PMP_Marketplace_Event_Offering__c eveoffLists:eveOff)
        {
            eveIds.add(eveoffLists.PMP_Event_Id__c);
        }
        List<PMP_Company__c> par=[Select Id,Name from PMP_Company__c];
        List<Id> parIds=new List<Id>();
        for( PMP_Company__c  parLists:par)
        {
            parIds.add(parLists.Id);
        }
        List<PMP_Marketplace_Event__c> eve=[Select Id,Name from PMP_Marketplace_Event__c];
        
        
        for(PMP_Marketplace_Event__c eveLists:eve)
        {
            eveIds.add(eveLists.Id);
        }
        
        List<PMP_Partner_Offering__c> Off=[Select Id,Name from PMP_Partner_Offering__c];
        List<String> offIds=new List<String>();
        
        for(PMP_Partner_Offering__c offLists:Off)
        {
            offIds.add(offLists.Id);
        }
        
        
        Test.startTest();
       PMP_SearchFeaturedCarouselController.getEventOffCount(eventTag,offIds);
       Test.stopTest();
        
    }
    
    
    
}