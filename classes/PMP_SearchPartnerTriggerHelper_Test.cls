@isTest
public class PMP_SearchPartnerTriggerHelper_Test {
    @testSetup
    static void setupTestData() {
        
         Folder folder = [SELECT Id from Folder WHERE DeveloperName= 'PMP_Marketplace_Images' LIMIT 1];
        
        Document doc = new Document(Name='IntelLogo',FolderId = folder.Id); 
        insert doc;
          List<PMP_Static_Constants__c> pmlist = new List<PMP_Static_Constants__c>();
        PMP_Static_Constants__c  pm1 = new PMP_Static_Constants__c();
        pm1.PMP_Value__c = 'Image';
        pm1.name = 'PMP_Image';
        pmlist.add(pm1);

        PMP_Static_Constants__c  pm2 = new PMP_Static_Constants__c();
        pm2.PMP_Value__c = 'Thumbnail Image';
        pm2.name = 'PMP_Thumbnail_Image';
        pmlist.add(pm2);

        insert pmlist;

        
        List<PMP_Specification__c> specs = new List<PMP_Specification__c>();
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Company_Info_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_Company_Info_TriggerHandler',
                                                                        Core_Object__c = 'PMP_Company__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update and create Partners');
        insert cs;

         List<PMP_Category__c> catList = new List<PMP_Category__c>();
        PMP_Category__c cat0 = PMP_TestDataUtility.getCategory('Categories', 'NPP_01_TYPE','Solution_Marketplace_Hierarchy', 'en_us');
        PMP_Category__c app0 = PMP_TestDataUtility.getCategory(system.label.PMP_application, 'NPP_01_APP','Solution_Marketplace_Hierarchy', 'en_us'); // value change from Application to Use Cases
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
        
        Account acc = PMP_SearchTestDataFactory.createIntelAccount('TestAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        
        PMP_Company__c partner_wc = new PMP_Company__c(Name='workingPartner', 
                                                       PMP_Is_Working_Copy_Ind__c = true,
                                                       PMP_Is_Enabled_Lead_Gen_Nm__c = 'true',
                                                       PMP_Is_Lead_Gen_Limited_Nm__c = 'true',
                                                       PMP_Company_Lead_Gen_Language_Nm__c = 'English',
                                                       PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review);
        insert partner_wc;
        
        PMP_Company__c Partner_pc = new PMP_Company__c(Name='pubPartner', 
                                                       PMP_Is_Published_Ind__c=true, 
                                                       PMP_Working_Copy_Id__c=partner_wc.Id,
                                                       PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Approved,
                                                       PMP_Is_Working_Copy_Ind__c = false);
        insert Partner_pc;

        partner_wc.PMP_Published_Copy_Id__c = Partner_pc.Id;
        update partner_wc;
        
        PMP_Company_Resource__c testResource = PMP_SearchTestDataFactory.createCompanyResource('testResource', Partner_pc.Id, 'White Paper', true);
        PMP_Company_Resource__c testResourceWc = PMP_SearchTestDataFactory.createCompanyResource('testResource', partner_wc.Id, 'White Paper', true);
        
        PMP_Specification__c testRegionSpec = new PMP_Specification__c(name='testRegion',   PMP_Partner_Product_Specification_Id__c='NPP_GeographicCoverage');
        PMP_Specification__c testSubRegion = new PMP_Specification__c(name='testSubRegion',     PMP_Partner_Product_Specification_Id__c = 'Test_Spec',PMP_Product_Parent_Specification_Id__c='NPP_GeographicCoverage',PMP_Parent_Specification_Id__c = testRegionSpec.Id);
        specs.add(testRegionSpec);
        specs.add(testSubRegion);
        insert specs;

        PMP_Company_Region__c testRegionWc = PMP_SearchTestDataFactory.createCompanyRegion(partner_wc.Id, testRegionSpec.Id, true);
        PMP_Company_Region__c testRegionPc = PMP_SearchTestDataFactory.createCompanyRegion(partner_pc.Id, testSubRegion.Id, true);
        PMP_Category__c cat = [SELECT id, Name from PMP_Category__c where Name='Component'];
        PMP_Partner_Category__c part_cat_pc = new PMP_Partner_Category__c();
        part_cat_pc.PMP_Category_Id__c = cat.Id;
        part_cat_pc.PMP_Partner_Id__c = Partner_pc.Id;
        insert part_cat_pc; 
        
        PMP_Partner_Category__c part_cat_wc = new PMP_Partner_Category__c();
        part_cat_wc.PMP_Category_Id__c = cat.Id;
        part_cat_wc.PMP_Partner_Id__c = Partner_wc.Id;
        insert part_cat_wc; 
/*        
        ContentVersion cv = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert cv;
        Id cvId = [select id from ContentVersion].Id; 
        ContentDistribution cd = new ContentDistribution(name = 'cdTest', contentVersionId = cvId);
        insert cd;
        Id cdId = [select id from ContentDistribution].Id; 
*/        
        //create content document , so that we can assocaite to company resource
                ContentVersion testContent = new ContentVersion(Title = 'Test logo1',
                                                        PathOnClient = 'testContent.jpg',
                                                        VersionData = Blob.valueOf('Test Content'),
                                                        IsMajorVersion = true,ContentDocumentId=testResource.PMP_Company_Image__c);
               insert testContent;
        
        List<ContentVersion> versions = new List<ContentVersion>();
        versions.add(PMP_SearchTestDataFactory.createCompanyDocuments(Partner_pc.Id, 'Test logo1', true));
        versions.add(PMP_SearchTestDataFactory.createCompanyDocuments(Partner_wc.Id, 'Test logo2', true));
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : versions) {
            cvIds.add(cv.Id);
        }
        cvIds.add(testContent.id);
        // System.debug(':::cvIds:::' + cvIds);
        List<ContentVersion> insertedVersions = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cvIds];
        
        List<PMP_Company_Resource__c> extRes = [SELECT Id,PMP_Company_Image__c FROM PMP_Company_Resource__c LIMIT 50];
        for(PMP_Company_Resource__c res : extRes) {
            res.PMP_Company_Image__c = insertedVersions[0].ContentDocumentId;
        }
        update extRes;
        
        List<PMP_Static_Constants__c> consts = new List<PMP_Static_Constants__c>{
        	new PMP_Static_Constants__c(Name='PMP_Image', PMP_Value__c='Image'),
            new PMP_Static_Constants__c(Name='PMP_Thumbnail_Image', PMP_Value__c='Thumbnail Image')
        };
        insert consts;
        // System.debug(':::insertedVersions:::' + insertedVersions);
        //set up company resources and insert 
        List<PMP_Company_Resource__c> comp_resources = new List<PMP_Company_Resource__c>();
        comp_resources.add(createCompanyResourceInstance('Resource1','www.intel.com',Partner_pc.Id,'Image',insertedVersions[0].ContentDocumentId));
        comp_resources.add(createCompanyResourceInstance('Resource2','www.intel.com',Partner_wc.Id,'Thumbnail Image',insertedVersions[1].ContentDocumentId));
        insert comp_resources;
        
               
    }

    public static PMP_Company_Resource__c createCompanyResourceInstance(String name,String url, Id compId, String resourceType, String contentId){ 
        
        PMP_Company_Resource__c resource = new PMP_Company_Resource__c();
        resource.Name               =   name;
        resource.PMP_Company_Id__c = compId;
        resource.PMP_Company_Resource_Type_Nm__c = resourceType;
        // System.debug('Resource'+resourceType);
        if(resourceType == PMP_StaticConstants_Partner.IMAGE || resourceType == PMP_StaticConstants_Partner.THUMBNAIL_IMAGE)
            resource.PMP_Company_Image__c = contentId;
        else
            resource.PMP_Company_Resource_URL_txt__c = url;

        return resource;
    } 
    
   @isTest
    static void approveStoreFrontEdiTest() {
       PMP_Company__c partner;
        List<PMP_Company__c> partner_lst = [SELECT id, PMP_Account_Id__c, Name,PMP_Published_Copy_Id__c, PMP_Is_Published_Ind__c, 
                                  PMP_Working_Copy_Id__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Working_Copy_Ind__c  from PMP_Company__c 
                                  where PMP_Company_Lifecycle_Status_Nm__c =: PMP_StaticConstants_Partner.Admin_Review AND
                                  PMP_Is_Working_Copy_Ind__c = true];
        // system.debug('partner_lst[0] : '+ partner_lst[0]); 
        Test.startTest();
        if(!partner_lst.isEmpty()){
            partner = partner_lst[0];
            partner.PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Approved;
            // system.debug('Partner : ' + partner);
            update partner;            
        } 
        List<PMP_Company__c> updatedPartner =  [SELECT id, PMP_Company_Lifecycle_Status_Nm__c, Name FROM PMP_Company__c  WHERE id = :partner_lst[0].id ];
        String updatedStatus = updatedPartner[0].PMP_Company_Lifecycle_Status_Nm__c;
        System.assertEquals(updatedStatus == PMP_StaticConstants_Partner.Approved, true, 'Life Cycle Status not Approved'); 
        Test.stopTest();
    }  
    
    @isTest
    static void createResourcesTest() {
        
        Set<Id> workingCopyIds = new Set<Id>();
        Map<Id, Id> wcMap = new Map<Id, Id>();
        
        List<PMP_Company__c> companies = [SELECT Id,PMP_Working_Copy_Id__c,PMP_Is_Published_Ind__c FROM PMP_Company__c WHERE PMP_Is_Published_Ind__c = true];
        for(PMP_Company__c comp : companies) {
            workingCopyIds.add(comp.PMP_Working_Copy_Id__c);
            wcMap.put(comp.PMP_Working_Copy_Id__c, comp.PMP_Working_Copy_Id__c);
        }
        
        PMP_SearchPartnerTriggerHelper.createResources(companies, workingCopyIds, wcMap);
        system.assertNotEquals(companies, null);
    }
    
    @isTest
    static void deactivateIntelAccountMP_Test() {
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        List<Account> accts = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newAccount);
        
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
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
        insert coreAccnt;
        

        List<PMP_Company__c> pubCopy = new List<PMP_Company__c>();
        PMP_Company__c mpi1 = new PMP_Company__c(Name='PAG Account', PMP_Is_Published_Ind__c=true, PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Draft, PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced,PMP_Is_Working_Copy_Ind__c =false);
       //PMP_Company__c mpi2 = new PMP_Company__c(Name='Int Account', PMP_Account_Id__c=newAccount.Id, PMP_Is_Published_Ind__c=true, PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published, PMP_Is_Working_Copy_Ind__c = false);
       pubCopy.add(mpi1);
       // pubCopy.add(mpi2);
        insert pubCopy;
        
        PMP_OPID_MPI_Rel__c juncRec1= new PMP_OPID_MPI_Rel__c();
        juncRec1.PMP_Marketing_Profile_Id__c=mpi1.Id;
        juncRec1.PMP_One_Partner_ID__c=newPagAccount.Id;
       
        insert juncRec1;
        
     
        Test.startTest();
        pubCopy[0].PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Published;
         Map<Id,PMP_Company__c> oldmap = new Map<Id,PMP_Company__c>([SELECT Id, Name, PMP_Account_Id__c, PMP_Is_Published_Ind__c, PMP_Company_Lifecycle_Status_Nm__c, PMP_Is_Working_Copy_Ind__c from PMP_Company__c WHERE Name='PAG Account' OR Name='Int Account' ]); 
        update pubCopy[0];
        PMP_SearchPartnerTriggerHelper.deactivateIntelAccountMP(PubCopy,oldmap);
        Test.stopTest();
    }
}