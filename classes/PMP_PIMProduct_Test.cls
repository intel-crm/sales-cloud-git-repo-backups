@isTest(SeeAllData=false)
public class PMP_PIMProduct_Test {
    
    @isTest
    static void testIsWorking() {
        Boolean result = PMP_PIMProduct.isWorking();
        System.assertEquals(true, result);
    }
//IPA2.0:US-4497-1631_OfferingEOL
    /*@isTest(SeeAllData=false)
    static void testBuildPostRequestMessage(){
        test.startTest();

        List<Id> offeringId=new List<Id>();

        String offferingNameDesc=String.valueOf(DateTime.now());
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
       
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                  'TestDuplicate',cmp1.Id, true,'Published','');
        testOffering.PMP_Offering_Language_Nm__c='English';
        update testOffering;
        //PMP_Partner_Offering__c testOffering=PMP_TestDataUtility.createOffering(offferingNameDesc,'Public Content',offferingNameDesc,'a3z0n0000003sHGAAY',true,'Published','The paper Company');
        offeringId.add(testOffering.Id);
        PMP_TestDataUtility.getPMPOfferingCategory(testOffering.Id);
        
        PMP_TestDataUtility.getPMPOfferingSpecification(testOffering.Id);
        
        PMP_TestDataUtility.createResources('AXMA','www.axma.com',testOffering.Id, 'Web Page','');
        
        PMP_TestDataUtility.createResources('DataSheet1','www.datasheet1.com',testOffering.Id, 'Data Sheet','');
        PMP_TestDataUtility.createResources('Product Brief','www.productbrief.com',testOffering.Id, 'Product Brief','');
        PMP_TestDataUtility.createResources('AdditionalRes1','www.add1.com',testOffering.Id, 'Additional Resources','');
        PMP_TestDataUtility.createResources('AdditionalRes2','www.add2.com',testOffering.Id, 'Additional Resources','');
        List<contentDocument> contentDoc=PMP_TestDataUtility.createContentDocument(true);
        PMP_TestDataUtility.createResources('global-communications-icon','',testOffering.Id, 'Image', contentDoc[0].Id);
        
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        test.stopTest();
        

        PMP_PIMProduct.buildProduct(offeringId);
        
        system.assertEquals(apiKey.PMP_API_KEY__c,'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk');
        
    }
    
    
    
    @isTest(SeeAllData=false)
    static void testBuildPostRequestMessage2(){
        test.startTest();

        List<Id> offeringId=new List<Id>();
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                  'TestDuplicate',cmp1.Id, true,'Published','');
        testOffering.PMP_Offering_Language_Nm__c='Japanese';
        update testOffering;

        offeringId.add(testOffering.Id);
        PMP_TestDataUtility.getPMPOfferingCategory(testOffering.Id);

        PMP_TestDataUtility.createOfferingSpecification('2-in-1', testOffering.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies',
                                                       'NPP_02_TYPE_Sys','NPP_03_TYPE_Sys_Laptop', 'NPP_IntelTechnologies','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor', testOffering.Id, 'NPP_Processors',
                                                       'Intel® Celeron® Processor','Intel® Celeron® Processor', '122698','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor 3000 Series', testOffering.Id, 'NPP_Processors|43521',
                                                       'Intel® Celeron® Processor','Intel® Celeron® Processor 3965Y (2M Cache, 1.50 GHz)', '122698','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('FPGAs', testOffering.Id, 'NPP_FPGA|Arria V',
                                                       'FPGAs','FPGAs', 'Arria V FPGAs','Checkbox');
        PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
                                                       'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '126380','Checkbox');
        PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
                                                       'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '','Checkbox'); 
        
        PMP_TestDataUtility.createOfferingSpecification('Mass Product', testOffering.Id, 'AvailabilityandPricingLevel1',
                                                       'NPP_AvailabilityAndPricing_MassProductionSchedule','NPP_AvailabilityAndPricing_MassProductionSchedule', '2019-02-28','Date');
        
        PMP_TestDataUtility.createOfferingSpecification('Order Lead Time (Days)', testOffering.Id, 'AvailabilityandPricingLevel1',
                                                       'NPP_AvailabilityAndPricing_OrderLeadTimeDays','NPP_AvailabilityAndPricing_MassProductionSchedule', '20','Integer');
        
        

        PMP_TestDataUtility.createResources('AXMA','www.axma.com',testOffering.Id, 'Web Page','');
        
        PMP_TestDataUtility.createResources('DataSheet1','www.datasheet1.com',testOffering.Id, 'Data Sheet','');
        PMP_TestDataUtility.createResources('Product Brief','www.productbrief.com',testOffering.Id, 'Product Brief','');
        PMP_TestDataUtility.createResources('AdditionalRes1','www.add1.com',testOffering.Id, 'Additional Resources','');
        List<contentDocument> contentDoc=PMP_TestDataUtility.createContentDocument(true);
        PMP_TestDataUtility.createResources('global-communications-icon','',testOffering.Id, 'Image', contentDoc[0].Id);
        
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        test.stopTest();
        
        PMP_PIMProduct.buildProduct(offeringId);
        system.assertEquals(apiKey.PMP_API_KEY__c,'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk');
    }
    
    
     @isTest(SeeAllData=false)
    static void testBuildPostRequestMessage3(){

        Test.startTest();
        List<Id> offeringId=new List<Id>();
        
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                  'TestDuplicate',cmp1.Id, true,'Published','');
        testOffering.PMP_Partner_Offering_Id__c='NPP1276527361253';
        testOffering.PMP_Offering_Language_Nm__c='Simplified Chinese';
        update testOffering;

        offeringId.add(testOffering.Id);
        PMP_TestDataUtility.getPMPOfferingCategory(testOffering.Id);

        PMP_TestDataUtility.createOfferingSpecification('2-in-1', testOffering.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies',
                                                       'NPP_02_TYPE_Sys','', 'NPP_IntelTechnologies','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor', testOffering.Id, 'NPP_Processors',
                                                       'Intel® Celeron® Processor','Intel® Celeron® Processor', '122698','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor 3000 Series', testOffering.Id, 'NPP_Processors|43521',
                                                       'Intel® Celeron® Processor','Intel® Celeron® Processor 3965Y (2M Cache, 1.50 GHz)', '122698','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('FPGAs', testOffering.Id, 'NPP_FPGA|Arria V',
                                                       'FPGAs','FPGAs', 'Arria V FPGAs','Checkbox');
        PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
                                                       'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '126380','Checkbox');
        PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
                                                       'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Mass Product', testOffering.Id, 'AvailabilityandPricingLevel1',
                                                       'NPP_AvailabilityAndPricing_MassProductionSchedule','NPP_AvailabilityAndPricing_MassProductionSchedule', '2019-02-28','Date');
        
        PMP_TestDataUtility.createOfferingSpecification('Order Lead Time (Days)', testOffering.Id, 'AvailabilityandPricingLevel1',
                                                       'NPP_AvailabilityAndPricing_OrderLeadTimeDays','NPP_AvailabilityAndPricing_MassProductionSchedule', '20','Integer');
        
        
        PMP_TestDataUtility.createResources('AXMA','www.axma.com',testOffering.Id, 'Web Page','');
        
        PMP_TestDataUtility.createResources('DataSheet1','www.datasheet1.com',testOffering.Id, 'Data Sheet','');
        PMP_TestDataUtility.createResources('Product Brief','www.productbrief.com',testOffering.Id, 'Product Brief','');
        PMP_TestDataUtility.createResources('AdditionalRes1','www.add1.com',testOffering.Id, 'Additional Resources','');
        List<contentDocument> contentDoc=PMP_TestDataUtility.createContentDocument(true);
        PMP_TestDataUtility.createResources('global-communications-icon','',testOffering.Id, 'Image', contentDoc[0].Id);
		

        PMP_Partner_Offering_Translation__c translations=new PMP_Partner_Offering_Translation__c();
        translations.PMP_Partner_Offering_Id__c=testOffering.Id;
        translations.Name='testTranslations';
        translations.PMP_English_Txt__c='abnc';
        translations.PMP_Chinese_Txt__c='abnc';        
        translations.PMP_Japanese_Txt__c='abnc';
        translations.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        insert translations;
        
        List<PMP_Languages__mdt>  lang=[select PIM_Language_Code__c,PIM_Locale_Name__c, Locale_Nm__c from PMP_Languages__mdt LIMIT 10];
                                 
                                 
        
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        
        PMP_PIMProduct.buildProduct(offeringId);
        
        
        testOffering.PMP_Offering_Language_Nm__c='Japanese';
        update testOffering;
        PMP_PIMProduct.buildProduct(offeringId);
        
        
        system.assertEquals(apiKey.PMP_API_KEY__c,'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk');
        
        
		Test.stopTest();        
    }
    
     @isTest(SeeAllData=false)
    static void testBuildPostRequestMessage4(){

        Test.startTest();
        List<Id> offeringId=new List<Id>();
        
        
        Account acc1 = PMP_TestDataUtility.createIntelAccount('TestAccount1', PMP_TestDataUtility.intel_Account_Record_Type, true);
        
        Contact con1 = PMP_TestDataUtility.createContact(acc1.id,true);
        
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', acc1.Id, true);
        
        PMP_Partner_Offering__c testOffering = PMP_TestDataUtility.createOffering('TestDuplicateOffering2','Public Content', 
                                                                                  'TestDuplicate',cmp1.Id, true,'Published','');
        testOffering.PMP_Partner_Offering_Id__c='NPP1276527361253';
        testOffering.PMP_Offering_Language_Nm__c='English';
        testOffering.PMP_Partner_Offering_Tag_Line_Txt__c='tagline';
        update testOffering;

        offeringId.add(testOffering.Id);
        PMP_TestDataUtility.getPMPOfferingCategory(testOffering.Id);

        PMP_TestDataUtility.createOfferingSpecification('2-in-1', testOffering.Id, 'NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies',
                                                       'NPP_02_TYPE_Sys','', 'NPP_IntelTechnologies','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor', testOffering.Id, 'NPP_Processors',
                                                       'Intel® Celeron® Processor','Intel® Celeron® Processor', '122698','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Intel® Celeron® Processor 3000 Series', testOffering.Id, 'NPP_Processors|43521',
                                                       'Intel® Celeron® Processor','Intel® Celeron® Processor 3965Y (2M Cache, 1.50 GHz)', '122698','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('FPGAs', testOffering.Id, 'NPP_FPGA|Arria V',
                                                       'FPGAs','FPGAs', 'Arria V FPGAs','Checkbox');
        PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
                                                       'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '126380','Checkbox');
        PMP_TestDataUtility.createOfferingSpecification('Intel® 300 Series Chipsets', testOffering.Id, 'NPP_Chipsets|98455',
                                                       'Intel® 300 Series Chipsets','Intel® 300 Series Chipsets', '','Checkbox');
        
        PMP_TestDataUtility.createOfferingSpecification('Mass Product', testOffering.Id, 'AvailabilityandPricingLevel1',
                                                       'NPP_AvailabilityAndPricing_MassProductionSchedule','NPP_AvailabilityAndPricing_MassProductionSchedule', '2019-02-28','Date');
        
        PMP_TestDataUtility.createOfferingSpecification('Order Lead Time (Days)', testOffering.Id, 'AvailabilityandPricingLevel1',
                                                       'NPP_AvailabilityAndPricing_OrderLeadTimeDays','NPP_AvailabilityAndPricing_MassProductionSchedule', '20','Integer');
        
        
        PMP_TestDataUtility.createResources('AXMA','www.axma.com',testOffering.Id, 'Web Page','');
        
        PMP_TestDataUtility.createResources('DataSheet1','www.datasheet1.com',testOffering.Id, 'Data Sheet','');
        PMP_TestDataUtility.createResources('Product Brief','www.productbrief.com',testOffering.Id, 'Product Brief','');
        PMP_TestDataUtility.createResources('AdditionalRes1','www.add1.com',testOffering.Id, 'Additional Resources','');
        List<contentDocument> contentDoc=PMP_TestDataUtility.createContentDocument(true);
        PMP_TestDataUtility.createResources('global-communications-icon','',testOffering.Id, 'Image', contentDoc[0].Id);
		

        PMP_Partner_Offering_Translation__c translations=new PMP_Partner_Offering_Translation__c();
        translations.PMP_Partner_Offering_Id__c=testOffering.Id;
        translations.Name='testTranslations';
        translations.PMP_English_Txt__c='abnc';
        translations.PMP_Chinese_Txt__c='abnc';        
        translations.PMP_Japanese_Txt__c='abnc';
        translations.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        insert translations;
        
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationTagLine=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationTagLine.Name=testOffering.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_Partner_Offering_Id__c=testOffering.Id;
        partnerOfferingTranslationTagLine.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        partnerOfferingTranslationTagLine.PMP_English_Txt__c=testOffering.Name;
        partnerOfferingTranslationTagLine.PMP_Chinese_Txt__c='aASDASDASD';
        partnerOfferingTranslationTagLine.PMP_Japanese_Txt__c='ASDASDSAD';
        insert partnerOfferingTranslationTagLine;
        
        
        PMP_Partner_Offering_Translation__c partnerOfferingTranslationDesc=new PMP_Partner_Offering_Translation__c();
        partnerOfferingTranslationDesc.Name=testOffering.Id+'PMP_Partner_Offering_Dsc__c';
        partnerOfferingTranslationDesc.PMP_Partner_Offering_Id__c=testOffering.Id;
        partnerOfferingTranslationDesc.PMP_Field_Nm__c='PMP_Partner_Offering_Dsc__c';
        partnerOfferingTranslationDesc.PMP_English_Txt__c=testOffering.Name;
        partnerOfferingTranslationDesc.PMP_Chinese_Txt__c='aASDASDASD';
        partnerOfferingTranslationDesc.PMP_Japanese_Txt__c='ASDASDSAD';
        insert partnerOfferingTranslationDesc;
        
        
        
        List<PMP_Languages__mdt>  lang=[select PIM_Language_Code__c,PIM_Locale_Name__c, Locale_Nm__c from PMP_Languages__mdt LIMIT 10];
                                 
                                 
        
        PMP_Product_API_Key__c apiKey=new PMP_Product_API_Key__c();
        apiKey.Name='API_Key';
        apiKey.PMP_API_KEY__c='efm9JpXElhgutg8t8HuHTYWc4tVvcvWk';
        insert apiKey;
        
        PMP_PIMProduct.buildProduct(offeringId);
        
        
       
        
        PMP_PIMProduct.getTranslatedData(offeringId[0]);
        PMP_PIMProduct.checkExistingTranslatedDataList(offeringId);
        
        system.assertEquals(apiKey.PMP_API_KEY__c,'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk');
        
        system.assertEquals(apiKey.PMP_API_KEY__c,'efm9JpXElhgutg8t8HuHTYWc4tVvcvWk');
        
		Test.stopTest();        
    }*/
    
    /*static testMethod void getTranslatedDataTest(){
        
            }*/
}