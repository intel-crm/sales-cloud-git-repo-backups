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
    static void testinsertLanguageEnglsihTranslation(){
        
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
        
    }
    @isTest
    static void testinsertLanguageChineseTranslation(){
        
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
        
    }
    @isTest
    static void testinsertLanguageJapneseTranslation(){
        
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
        
    }
    @isTest
    static void testinsertLanguageEnglsihTranslationDuplicate(){
        
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        //off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
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
        PMP_Partner_Offering__c updatedOffering=[SELECT Id,PMP_Partner_Offering_Lifecycle_Status_Nm__c FROM PMP_Partner_Offering__c WHERE Id=:off1.Id LIMIT 1];
        system.assertEquals('Draft', updatedOffering.PMP_Partner_Offering_Lifecycle_Status_Nm__c);
     
    }
    
    @isTest
    static void testinsertLanguageEnglishTranslationBlank(){
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        //off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1;     
        PMP_CreateLanguageTranslations.updateLanguageTranslation(off1);
    }
    @isTest
    static void testinsertLanguageChineseTranslationBlank(){
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
    }
     @isTest
    static void testinsertLanguageEnglishTranslationMultiRecords(){
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
    }
    @isTest
    static void testinsertLanguageJapaneseTranslationMultiRecords(){
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
    }
     @isTest
    static void testinsertLanguageException(){
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        off1.PMP_Offering_Language_Nm__c = 'English';
        off1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Test Tagline';
        update off1; 
        Exception ex;
        PMP_CreateLanguageTranslations.insertLanguageTranslation(off1);
    }
     @isTest
    static void testinsertLanguageEnglishOfferinName(){
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
    }
     @isTest
    static void testinsertLanguageDescriptionOfferingName(){
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
    }
    @isTest
    static void testinsertLanguageChineseOfferingName(){
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
    }
    @isTest
    static void testinsertLanguageChineseOfferingDescription(){
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

    }
    @isTest
    static void testinsertLanguageChineseOfferinTag(){
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

    }
    
    
    @isTest
    static void testinsertLanguageJapaneseOfferingName(){
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
    }
    @isTest
    static void testinsertLanguageJapaneseOfferingDescription(){
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

    }
    @isTest
    static void testinsertLanguageJapaneseOfferinTag(){
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

    }
     
     
    
}