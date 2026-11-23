/*****************************************************************************************************************************************************************
* Class Name  : PMP_OfferingResourceHelper_Test 
* Version     : 1.0 
* Created Date: 06-25-2019 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-25-2019                    Test class of PMP_OfferingResourceHelper apex class
******************************************************************************************************************************************************************/
@isTest
public class PMP_OfferingResourceHelper_Test {
    
	static testMethod void editOfferingResourceTest(){//test for edit scenario
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res1','www.intel.com',off1.Id,'Data Sheet',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Product Web Page',''));
        
        if(addOfferingResources != null){
            insert addOfferingResources;
        }
        
        List <PMP_Partner_Offering_Resource__c> resources = new List<PMP_Partner_Offering_Resource__c>();
        PMP_Partner_Offering_Resource__c AddResource1 = new PMP_Partner_Offering_Resource__c();
        PMP_Partner_Offering_Resource__c AddResource2 = new PMP_Partner_Offering_Resource__c();
        Intel_FormData formData = new Intel_FormData();
        Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
        webPageData.Name = 'res2Changed';
        webPageData.Url = 'www.intel2.com';
        formData.productWebPageData = webPageData;
        AddResource1.Name='addRes1';
        AddResource1.PMP_Resource_Type_Nm__c='Data Sheet';
		AddResource1.PMP_Partner_Offering_Resource_URL_Txt__c='www.addRes1.com';
        AddResource2.Name='addRes2';
        AddResource2.PMP_Resource_Type_Nm__c='Product Brief';
		AddResource2.PMP_Partner_Offering_Resource_URL_Txt__c='www.addRes2.com';
        resources.add(AddResource1);
        resources.add(AddResource2);
        formData.resources = resources;
        List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        for(contentDocument cd : contentDocs){
            cdl.add(PMP_TestDataUtility.createContentDocumentLink(off1.Id, cd.Id));
        }
        Test.startTest();
        PMP_OfferingResourceHelper.createOfferingResource(formData, off1.Id);
        List<PMP_Partner_Offering_Resource__c> offResources = PMP_CreateOfferingTab4Service.getOfferingResources(off1.Id);
        
        System.assertEquals(4, offResources.size());
        
        PMP_Partner_Offering_Resource__c offeringRes = [SELECT Id, Name, PMP_Resource_Type_Nm__c FROM PMP_Partner_Offering_Resource__c 
                                                             WHERE PMP_Resource_Type_Nm__c = 'Product Web Page'];
        
        System.assertEquals('res2Changed', offeringRes.Name);
        Test.stopTest();
    }
    
    static testMethod void createOfferingResourceTest(){//test for create scenario
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        
        List <PMP_Partner_Offering_Resource__c> resources = new List<PMP_Partner_Offering_Resource__c>();
        PMP_Partner_Offering_Resource__c AddResource1 = new PMP_Partner_Offering_Resource__c();
        PMP_Partner_Offering_Resource__c AddResource2 = new PMP_Partner_Offering_Resource__c();
        Intel_FormData formData = new Intel_FormData();
        Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
        webPageData.Name = 'res2Changed';
        webPageData.Url = 'www.intel2.com';
        formData.productWebPageData = webPageData;
        AddResource1.Name='addRes1';
        AddResource1.PMP_Resource_Type_Nm__c='Data Sheet';
		AddResource1.PMP_Partner_Offering_Resource_URL_Txt__c='www.addRes1.com';
        AddResource2.Name='addRes2';
        AddResource2.PMP_Resource_Type_Nm__c='Product Brief';
		AddResource2.PMP_Partner_Offering_Resource_URL_Txt__c='www.addRes2.com';
        resources.add(AddResource1);
        resources.add(AddResource2);
        formData.resources = resources;
        List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        for(contentDocument cd : contentDocs){
            cdl.add(PMP_TestDataUtility.createContentDocumentLink(off1.Id, cd.Id));
        }
        Test.startTest();
        PMP_OfferingResourceHelper.createOfferingResource(formData, off1.Id);
        List<PMP_Partner_Offering_Resource__c> offResources = PMP_CreateOfferingTab4Service.getOfferingResources(off1.Id);
        
        System.assertEquals(4, offResources.size());
        
        PMP_Partner_Offering_Resource__c offeringRes = [SELECT Id, Name, PMP_Resource_Type_Nm__c FROM PMP_Partner_Offering_Resource__c 
                                                             WHERE PMP_Resource_Type_Nm__c = 'Product Web Page'];
        
        System.assertEquals('res2Changed', offeringRes.Name);
        Test.stopTest();
    }
    
    static testMethod void createOfferingResourceNegativeTest(){
        
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res1','www.intel.com',off1.Id,'Data Sheet',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Product Web Page',''));

        if(addOfferingResources != null){
            insert addOfferingResources;
        }
        
        List <PMP_Partner_Offering_Resource__c> resources = new List<PMP_Partner_Offering_Resource__c>();
        PMP_Partner_Offering_Resource__c AddResource1 = new PMP_Partner_Offering_Resource__c();
        PMP_Partner_Offering_Resource__c AddResource2 = new PMP_Partner_Offering_Resource__c();
        Intel_FormData formData = new Intel_FormData();
        Intel_ProductWebPageDataWrapper webPageData = new Intel_ProductWebPageDataWrapper();
        formData.productWebPageData = webPageData;
        AddResource1.Name='addRes1';
        AddResource1.PMP_Resource_Type_Nm__c='Data Sheet';
		AddResource1.PMP_Partner_Offering_Resource_URL_Txt__c='www.addRes1.com';
        resources.add(AddResource1);
        formData.resources = resources;
        List<contentDocument> contentDocs = PMP_TestDataUtility.createContentDocument(true);
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        for(contentDocument cd : contentDocs){
            cdl.add(PMP_TestDataUtility.createContentDocumentLink(off1.Id, cd.Id));
        }
        Test.startTest();
        PMP_OfferingResourceHelper.createOfferingResource(formData, off1.Id);
        List<PMP_Partner_Offering_Resource__c> offResources = PMP_CreateOfferingTab4Service.getOfferingResources(off1.Id);
        
        System.assertEquals(2, offResources.size());
        
        PMP_Partner_Offering_Resource__c offeringRes = [SELECT Id, Name, PMP_Resource_Type_Nm__c, PMP_Partner_Offering_Resource_URL_Txt__c 
                                                        FROM PMP_Partner_Offering_Resource__c WHERE PMP_Resource_Type_Nm__c = 'Data Sheet'];
        
        System.assertEquals('addRes1', offeringRes.Name);
        System.assertEquals('www.addRes1.com', offeringRes.PMP_Partner_Offering_Resource_URL_Txt__c);
        
        for(PMP_Partner_Offering_Resource__c res : offResources){
            System.assertEquals(true, res.PMP_Resource_Type_Nm__c != 'Product Web Page');
        }
        Test.stopTest();
    }
    
    static testMethod void getProductWebPageDataTest(){
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        PMP_Partner_Offering_Resource__c offRes2 = PMP_TestDataUtility.createResources('res2','www.google.com',off1.Id,'Product Web Page','');
        Test.startTest();
        Intel_ProductWebPageDataWrapper webPageData = PMP_OfferingResourceHelper.getProductWebPageData(off1.Id);
        
        System.assertEquals(offRes2.Name, webPageData.Name);
        System.assertEquals(offRes2.PMP_Partner_Offering_Resource_URL_Txt__c, webPageData.Url);
        
       	Test.stopTest();
    }
    
    static testMethod void getProductWebPageDataNegativeTest(){
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        PMP_Partner_Offering_Resource__c offRes2 = PMP_TestDataUtility.createResources('res2','www.google.com',off1.Id,'Product Brief','');
        Test.startTest();
        Intel_ProductWebPageDataWrapper webPageData = PMP_OfferingResourceHelper.getProductWebPageData(off1.Id);
        
        System.assertEquals(null, webPageData.Name);
        System.assertEquals(null, webPageData.Url);
        
       	Test.stopTest();
    }
    
    static testMethod void getAdditionalResourcesTest(){
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res1','www.intel.com',off1.Id,'Data Sheet',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Product Web Page',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Product Brief',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Tutorials',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Image',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Thumbnail Image',''));
        
        if(addOfferingResources != null){
            insert addOfferingResources;
        }
        Test.startTest();
        List<PMP_Partner_Offering_Resource__c> addResources = PMP_OfferingResourceHelper.getAdditionalResources(off1.Id);
        
        System.assertEquals(3, addResources.size());
        
        for(PMP_Partner_Offering_Resource__c res : addResources){
            System.assertEquals(true, res.PMP_Resource_Type_Nm__c != 'Product Web Page');
            System.assertEquals(true, res.PMP_Resource_Type_Nm__c != 'Image');
            System.assertEquals(true, res.PMP_Resource_Type_Nm__c != 'Thumbnail Image');
        }
        Test.stopTest();
    }
    
    static testMethod void getAdditionalResourcesNegativeTest(){
        List<PMP_Partner_Offering_Resource__c> addOfferingResources = new List<PMP_Partner_Offering_Resource__c>();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Product Web Page',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Image',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Image',''));
        addOfferingResources.add(PMP_TestDataUtility.createOfferingResourceInstance('res2','www.google.com',off1.Id,'Thumbnail Image',''));
        
        if(addOfferingResources != null){
            insert addOfferingResources;
        }
        
        Test.startTest();
        List<PMP_Partner_Offering_Resource__c> addResources = PMP_OfferingResourceHelper.getAdditionalResources(off1.Id);
        
        System.assertEquals(0, addResources.size());

        Test.stopTest();
    }

}