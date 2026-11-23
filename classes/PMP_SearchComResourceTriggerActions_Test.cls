@isTest
private with sharing class PMP_SearchComResourceTriggerActions_Test {
    
    @testSetup
    static void setupTestData() {
        List<PMP_Static_Constants__c> aa = new List<PMP_Static_Constants__c>();
        
        PMP_Static_Constants__c st = new PMP_Static_Constants__c();
        st.Name = 'PMP_Image';
        st.PMP_Value__c = 'Image';
        insert st;
        aa.add(st);
        
        PMP_Static_Constants__c st1 = new PMP_Static_Constants__c();
        st1.Name = 'PMP_Thumbnail_Image';
        st1.PMP_Value__c = 'Thumbnail Image';
        insert st1;
        aa.add(st1);
        
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c (Name = 'Comp_Resource_Handler',
                                                                        Core_Active__c = true,
                                                                        Core_Class_Name__c = 'PMP_SearchCompanyResourceTriggerHandler',
                                                                        Core_Object__c = 'PMP_Company_Resource__c',
                                                                        Core_Trigger_Events__c = 'After Insert, After Update',
                                                                        Core_Description__c = 'Update ContentDistribution');
        insert cs;
    }
	
    @isTest
    static void createContentDistributionTest(){
        Test.startTest();
        List<PMP_Company_Resource__c> nl = new List<PMP_Company_Resource__c>();
        Account acc = PMP_SearchTestDataFactory.createIntelAccount('TestAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c partner = PMP_SearchTestDataFactory.createCompanyInformation('testpartner', acc.Id , true);
        List<ContentDocument> conDocList = PMP_SearchTestDataFactory.createContentDocument(true);
        PMP_Company_Resource__c res = PMP_SearchTestDataFactory.createCompanyResource('TestRes', partner.Id, 'Image', false);
        res.PMP_Company_Image__c = conDocList[0].Id;
        insert res;
        nl.add(res);
        
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            ContentAsset ca =  new ContentAsset();
            ca.DeveloperName = 'Test'+'_'+String.valueOf(randomInt);
            ca.MasterLabel= String.valueOf(randomInt);
            ca.isVisibleByExternalUsers = TRUE;
            insert ca; 
            
            conDocList[0].contentAssetId = ca.id;
            update conDocList[0];
        
            delete res;
        
        Test.stopTest();
    }
    
    @isTest
    static void updateCompanyResourceTest(){
        Test.startTest();
        Account acc = PMP_SearchTestDataFactory.createIntelAccount('TestAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c partner = PMP_SearchTestDataFactory.createCompanyInformation('testpartner', acc.Id , true);
        List<ContentDocument> conDocList = PMP_SearchTestDataFactory.createContentDocument(true);
        PMP_Company_Resource__c res = PMP_SearchTestDataFactory.createCompanyResource('TestRes', partner.Id, 'Image', false);
        res.PMP_Company_Image__c = conDocList[0].Id;
        insert res;
        
        ContentVersion contentVersion_2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test2.jpg',
            VersionData = Blob.valueOf('Test2 Content'),
            IsMajorVersion = true
        );
        
        insert contentVersion_2;
        ContentVersion contentVersion_3 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_2.Id LIMIT 1];
        
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion_3.ContentDocumentId];
        
        res.PMP_Company_Image__c = document.Id;
        update res;
        
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            ContentAsset ca =  new ContentAsset();
            ca.DeveloperName = 'Test'+'_'+String.valueOf(randomInt);
            ca.MasterLabel= String.valueOf(randomInt);
            ca.isVisibleByExternalUsers = TRUE;
            insert ca; 
            
            conDocList[0].contentAssetId = ca.id;
            update conDocList[0];
        
            delete res;
        PMP_SearchCompanyResourceTriggerActions.getContentDistributionInstance(contentVersion_2.id, contentVersion_2.Title,partner.Id);
        Test.stopTest();
    }
     @isTest
    public static void testCreateContentAsset(){
        //Starting test with test Data created
        Test.startTest();
        //Creating Test Data
        Account testAccount = new Account(Name = 'Sample Account' ,Core_Account_Type__c='Other',
                                          BillingCity='Bangalore', BillingCountry='IND', BillingStreet = 'TestStreet');
        insert testAccount;
        Id accntId = testAccount.Id;
        
        PMP_Company__c testCompany = new PMP_Company__c(Name='TestCompany1',PMP_Account_Industry__c='Others',PMP_Account_Id__c=accntId);
        testCompany.PMP_Is_Published_Ind__c=true;
        insert testCompany;
        Id cmpnyId = testCompany.Id;
        
        Account acc = PMP_SearchTestDataFactory.createIntelAccount('TestAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, true);
        PMP_Company__c partner = PMP_SearchTestDataFactory.createCompanyInformation('testpartner', acc.Id , true);
        List<ContentDocument> conDocList = PMP_SearchTestDataFactory.createContentDocument(true);
        PMP_Company_Resource__c res = PMP_SearchTestDataFactory.createCompanyResource('TestRes', partner.Id, 'Image', false);
        PMP_Company_Resource__c res2 = PMP_SearchTestDataFactory.createCompanyResource('TestRes1', partner.Id, 'Thumbnail Image', false);
        res.PMP_Company_Image__c = conDocList[0].Id;
        insert res;
		res2.PMP_Company_Image__c = conDocList[0].Id;
        insert res2;
        String TImage = 'Thumbnail Image';
        String image = 'Image';
        ContentVersion contentVersion_2 = new ContentVersion(
            Title = 'Test2',
            PathOnClient = 'Test2.jpg',
            VersionData = Blob.valueOf('Test2 Content'),
            IsMajorVersion = true
        );
        
        insert contentVersion_2;
        ContentVersion contentVersion_3 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_2.Id LIMIT 1];
        
        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion_3.ContentDocumentId];
        
        res.PMP_Company_Image__c = document.Id;
        update res;
        
        PMP_Company_Resource__c testResource = new PMP_Company_Resource__c(Name='sampleResource1',PMP_Company_Id__c=cmpnyId,PMP_Company_Resource_Type_Nm__c=image,PMP_Company_Image__c=res.PMP_Company_Image__c);
        insert testResource;
        
        PMP_Company_Resource__c testResource2 = new PMP_Company_Resource__c(Name='sampleResource2',PMP_Company_Id__c=cmpnyId,PMP_Company_Resource_Type_Nm__c=TImage,PMP_Company_Image__c=res2.PMP_Company_Image__c);
        insert testResource2;
            
      	List<PMP_Company_Resource__c> partner_resourcesList = new List<PMP_Company_Resource__c>();
        partner_resourcesList.add(testResource);
        partner_resourcesList.add(testResource2);
        
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            ContentAsset ca =  new ContentAsset();
            ca.DeveloperName = 'Test'+'_'+String.valueOf(randomInt);
            ca.MasterLabel= String.valueOf(randomInt);
            ca.isVisibleByExternalUsers = TRUE;
            insert ca; 
        
        System.debug('partner_resourcesList**test'+partner_resourcesList);
        PMP_SearchCompanyResourceTriggerActions.createContentAsset(partner_resourcesList);
        PMP_SearchCompanyResourceTriggerActions.getContentAssetInstance(testResource.PMP_Company_Image__c,testResource.id,cmpnyId);
        PMP_SearchCompanyResourceTriggerActions.deleteContentAsset(partner_resourcesList);
        delete ca;
        Test.stopTest();
    }
    
}