/*****************************************************************************************************************************************************************
* Class Name  : PMP_CreateLanguageTranslations_Test 
* Version     : 1.0 
* Created Date: 06-17-2019 
* Modification Log :
*
* Developer                           Date                          Description
* ----------------------------------------------------------------------------------------------------------------------------------------------------------------
* ONYX Team                          06-17-2019                    Test class of PMP_CreateLanguageTranslations apex class
******************************************************************************************************************************************************************/
@isTest
public class PMP_CreateLanguageTranslations_Test {
     @isTest
    static void testIsWorking() {
        Boolean result = PMP_CreateLanguageTranslations.isWorking();
        System.assertEquals(true, result);
    }
    //IPA2.0 offering changes
    /*
	@isTest
    static void testinsertLanguageEnglsihTranslation(){
        test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering__c updatedOffering=[SELECT Id,PMP_Partner_Offering_Lifecycle_Status_Nm__c FROM PMP_Partner_Offering__c WHERE Id=:off1.Id LIMIT 1];
        system.assertEquals('Draft', updatedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageChineseTranslation(){
        test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering__c updatedOffering=[SELECT Id,PMP_Partner_Offering_Lifecycle_Status_Nm__c FROM PMP_Partner_Offering__c WHERE Id=:off1.Id LIMIT 1];
        system.assertEquals('Draft', updatedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageJapneseTranslation(){
        test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Japanese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering__c updatedOffering=[SELECT Id,PMP_Partner_Offering_Lifecycle_Status_Nm__c FROM PMP_Partner_Offering__c WHERE Id=:off1.Id LIMIT 1];
        system.assertEquals('Draft', updatedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageEnglsihTranslationDuplicate(){
        test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        //off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
		*/
        //creating translation data
        /*PMP_Partner_Offering_Translation__c lngeTrnsl = new PMP_Partner_Offering_Translation__c();
        lngeTrnsl.Name = off1.id+PMP_StaticConstants_Offering.Description ;
        lngeTrnsl.PMP_Partner_Offering_Id__c=off1.id;
        lngeTrnsl.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description ; 
        if(off1.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.English) 
            lngeTrnsl.PMP_English_Txt__c = off1.PMP_Partner_Offering_Tag_Line_Txt__c;                   
        else if(off1.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Chinese) 
            lngeTrnsl.PMP_Chinese_Txt__c= off1.PMP_Partner_Offering_Tag_Line_Txt__c;
        else  if(off1.PMP_Offering_Language_Nm__c == PMP_StaticConstants_Offering.Japanese)
            lngeTrnsl.PMP_Japanese_Txt__c = off1.PMP_Partner_Offering_Tag_Line_Txt__c;
        insert lngeTrnsl;
        */
        /*PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Chinese_Txt__c='asdasdasd';
        trans.PMP_English_Txt__c='asdasd';
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        */
        /*PMP_Partner_Offering__c updatedOffering=[SELECT Id,PMP_Partner_Offering_Lifecycle_Status_Nm__c FROM PMP_Partner_Offering__c WHERE Id=:off1.Id LIMIT 1];
        system.assertEquals('Draft', updatedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
     test.stopTest();
    }
    
    @isTest
    static void testinsertLanguageEnglishTranslationBlank(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        //off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        
        system.assertEquals(off1.PMP_Offering_Language_Nm__c,'English');
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageChineseTranslationBlank(){
         test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Chinese_Txt__c='sdfsdfsdf';
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        
        PMP_Partner_Offering_Translation__c trans2=new PMP_Partner_Offering_Translation__c();
        trans2.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans2.PMP_Chinese_Txt__c='sdfsasdasasddfsdf';
        trans2.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans2;
        
        
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_Chinese_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id limit 1];
        system.assertNotEquals(updatedTrans.PMP_Chinese_Txt__c,off1.Name);
        test.stopTest();
    }
     @isTest
    static void testinsertLanguageEnglishTranslationMultiRecords(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_English_Txt__c='sdfsdfsdf';
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        
        PMP_Partner_Offering_Translation__c trans2=new PMP_Partner_Offering_Translation__c();
        trans2.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans2.PMP_English_Txt__c='sdfsasdasasddfsdf';
        trans2.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans2;
        
        
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_English_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id limit 1];
        system.assertNotEquals(updatedTrans.PMP_English_Txt__c,off1.Name);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageJapaneseTranslationMultiRecords(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Japanese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Japanese_Txt__c='sdfsdfsdf';
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        
        PMP_Partner_Offering_Translation__c trans2=new PMP_Partner_Offering_Translation__c();
        trans2.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans2.PMP_Japanese_Txt__c='sdfsasdasasddfsdf';
        trans2.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans2;
        
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_Japanese_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id limit 1];
        system.assertNotEquals(updatedTrans.PMP_Japanese_Txt__c,off1.Name);
        test.stopTest();
    }
     @isTest
    static void testinsertLanguageException(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        Exception ex;
        system.assertEquals(off1.PMP_Offering_Language_Nm__c,'English');
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
        test.stopTest();
    }
     @isTest
    static void testinsertLanguageEnglishOfferinName(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Name;
        trans.PMP_English_Txt__c='';
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_English_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id];
        system.assertEquals(updatedTrans.PMP_English_Txt__c,off1.Name);
        test.stopTest();
    }
     @isTest
    static void testinsertLanguageDescriptionOfferingName(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description;
        trans.PMP_English_Txt__c='';
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_English_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id];
        system.assertEquals(updatedTrans.PMP_English_Txt__c,off1.PMP_Partner_Offering_Dsc__c);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageChineseOfferingName(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Name;
        trans.PMP_Chinese_Txt__c =null;
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_Chinese_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id];
        system.assertEquals(updatedTrans.PMP_Chinese_Txt__c,off1.Name);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageChineseOfferingDescription(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description;
        trans.PMP_Chinese_Txt__c =null;
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_Chinese_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id];
        system.assertEquals(updatedTrans.PMP_Chinese_Txt__c,off1.PMP_Partner_Offering_Dsc__c);
        test.stopTest();

    }
    @isTest
    static void testinsertLanguageChineseOfferinTag(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c =PMP_StaticConstants_Offering.tag;
        trans.PMP_Chinese_Txt__c =null;
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        PMP_Partner_Offering_Translation__c updatedTrans = [select id,PMP_Chinese_Txt__c,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c=:off1.id];
        system.assertEquals(updatedTrans.PMP_Chinese_Txt__c,off1.PMP_Partner_Offering_Tag_Line_Txt__c);
		test.stopTest();
    }
    
    
    @isTest
    static void testinsertLanguageJapaneseOfferingName(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Japanese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Name;
        trans.PMP_Chinese_Txt__c =null;
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        system.assertNotEquals(trans.PMP_Chinese_Txt__c,off1.PMP_Partner_Offering_Tag_Line_Txt__c);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageJapaneseOfferingDescription(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Japanese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c = PMP_StaticConstants_Offering.Description;
        trans.PMP_Chinese_Txt__c =null;
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
        system.assertNotEquals(trans.PMP_Chinese_Txt__c,off1.PMP_Partner_Offering_Tag_Line_Txt__c);
        test.stopTest();
    }
    @isTest
    static void testinsertLanguageJapaneseOfferinTag(){
        test.startTest();
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'Japanese';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;
        PMP_Partner_Offering_Translation__c trans=new PMP_Partner_Offering_Translation__c();
        trans.Name=off1.id+off1.PMP_Offering_Language_Nm__c;
        trans.PMP_Field_Nm__c =PMP_StaticConstants_Offering.tag;
        trans.PMP_Chinese_Txt__c =null;
        trans.PMP_Partner_Offering_Id__c=off1.Id;
        insert trans;
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
		system.assertNotEquals(trans.PMP_Chinese_Txt__c,off1.PMP_Partner_Offering_Tag_Line_Txt__c);
        test.stopTest();
    }
     
     
   */ 
}