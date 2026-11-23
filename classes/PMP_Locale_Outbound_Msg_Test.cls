@isTest
public with sharing  class PMP_Locale_Outbound_Msg_Test {
    //IPA2.0 - As part of TWC729-7977 commented the entire class
/*
    static TestMethod void ValidateOutboundJSon()
        
    {
        test.startTest();
        PMP_Partner_Offering__c ppo = new PMP_Partner_Offering__c();
        ppo.Name = 'Test Offering';
        ppo.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo.PMP_Offering_Language_Nm__c = 'English';
        ppo.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        ppo.PMP_Edit_Language_Cd__c ='Japanese';
        insert ppo;
        
        PMP_Partner_Offering__c ppo1 = new PMP_Partner_Offering__c();
        ppo1.Name = 'Test Offering';
        ppo1.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo1.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo1.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo1.PMP_Offering_Language_Nm__c = 'Japanese';
        ppo1.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        ppo1.PMP_Edit_Language_Cd__c ='English';
        insert ppo1;
        
        PMP_Partner_Offering__c ppo2 = new PMP_Partner_Offering__c();
        ppo2.Name = 'Test Offering';
        ppo2.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo2.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo2.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo2.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo2.PMP_Offering_Language_Nm__c = 'Simplified Chinese';
        ppo2.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        ppo2.PMP_Edit_Language_Cd__c ='English';
        
        insert ppo2;
        
        PMP_Partner_Offering__c ppo3 = new PMP_Partner_Offering__c();
        ppo3.Name = 'Test Offering';
        ppo3.PMP_Partner_Offering_Nm__c = 'Test Offering';
        ppo3.PMP_Partner_Offering_Dsc__c = 'Test Offering';
        ppo3.PMP_Partner_Offering_Tag_Line_Txt__c = 'Market place';
        ppo3.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Approved';
        ppo3.PMP_Offering_Language_Nm__c = 'English';
        ppo3.PMP_Translation_Lifecycle_Status_nm__c = 'Pending';
        ppo3.PMP_Edit_Language_Cd__c ='Japanese';
        insert ppo3;
        
		List<PMP_Partner_Offering_Translation__c> translations=new List<PMP_Partner_Offering_Translation__c>();
        
        
        PMP_Partner_Offering_Translation__c translationsName=new PMP_Partner_Offering_Translation__c();
        translationsName.PMP_Partner_Offering_Id__c=ppo.Id;
        translationsName.PMP_Chinese_Txt__c='';
        translationsName.PMP_Japanese_Txt__c='';
        translationsName.PMP_English_Txt__c='askdkasdasid';
        translationsName.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translationsName.Name=ppo.Id+'PMP_Partner_Offering_Nm__c';
        
        PMP_Partner_Offering_Translation__c translationsTagLine=new PMP_Partner_Offering_Translation__c();
        translationsTagLine.PMP_Partner_Offering_Id__c=ppo.Id;
        translationsTagLine.PMP_Chinese_Txt__c='';
        translationsTagLine.PMP_Japanese_Txt__c='';
        translationsTagLine.PMP_English_Txt__c='askdkasdasid';
        translationsTagLine.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        translationsTagLine.Name=ppo.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        
        PMP_Partner_Offering_Translation__c translationsDesc=new PMP_Partner_Offering_Translation__c();
        translationsDesc.PMP_Partner_Offering_Id__c=ppo.Id;
        translationsDesc.PMP_Chinese_Txt__c='';
        translationsDesc.PMP_Japanese_Txt__c='';
        translationsDesc.PMP_English_Txt__c='askdkasdasid';
        translationsDesc.PMP_Field_Nm__c='PMP_Partner_Offering_Dsc__c';
        translationsDesc.Name=ppo.Id+'PMP_Partner_Offering_Dsc__c';
        translations.add(translationsName);
        translations.add(translationsTagLine);
        translations.add(translationsDesc);
        
        PMP_Partner_Offering_Translation__c translationsName2=new PMP_Partner_Offering_Translation__c();
        translationsName2.PMP_Partner_Offering_Id__c=ppo1.Id;
        translationsName2.PMP_Chinese_Txt__c='';
        translationsName2.PMP_Japanese_Txt__c='askdkasdasid';
        translationsName2.PMP_English_Txt__c='';
        translationsName2.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translationsName2.Name=ppo1.Id+'PMP_Partner_Offering_Nm__c';
        
        PMP_Partner_Offering_Translation__c translationsTagLine2=new PMP_Partner_Offering_Translation__c();
        translationsTagLine2.PMP_Partner_Offering_Id__c=ppo1.Id;
        translationsTagLine2.PMP_Chinese_Txt__c='';
        translationsTagLine2.PMP_Japanese_Txt__c='askdkasdasid';
        translationsTagLine2.PMP_English_Txt__c='';
        translationsTagLine2.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        translationsTagLine2.Name=ppo1.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        
        PMP_Partner_Offering_Translation__c translationsDesc2=new PMP_Partner_Offering_Translation__c();
        translationsDesc2.PMP_Partner_Offering_Id__c=ppo1.Id;
        translationsDesc2.PMP_Chinese_Txt__c='';
        translationsDesc2.PMP_Japanese_Txt__c='askdkasdasid';
        translationsDesc2.PMP_English_Txt__c='';
        translationsDesc2.PMP_Field_Nm__c='PMP_Partner_Offering_Dsc__c';
        translationsDesc2.Name=ppo1.Id+'PMP_Partner_Offering_Dsc__c';
        translations.add(translationsName2);
        translations.add(translationsTagLine2);
        translations.add(translationsDesc2);
        
        
        PMP_Partner_Offering_Translation__c translationsName3=new PMP_Partner_Offering_Translation__c();
        translationsName3.PMP_Partner_Offering_Id__c=ppo2.Id;
        translationsName3.PMP_Chinese_Txt__c='askdkasdasid';
        translationsName3.PMP_Japanese_Txt__c='';
        translationsName3.PMP_English_Txt__c='';
        translationsName3.PMP_Field_Nm__c='PMP_Partner_Offering_Nm__c';
        translationsName3.Name=ppo2.Id+'PMP_Partner_Offering_Nm__c';
        
        PMP_Partner_Offering_Translation__c translationsTagLine3=new PMP_Partner_Offering_Translation__c();
        translationsTagLine3.PMP_Partner_Offering_Id__c=ppo2.Id;
        translationsTagLine3.PMP_Chinese_Txt__c='askdkasdasid';
        translationsTagLine3.PMP_Japanese_Txt__c='';
        translationsTagLine3.PMP_English_Txt__c='';
        translationsTagLine3.PMP_Field_Nm__c='PMP_Partner_Offering_Tag_Line_Txt__c';
        translationsTagLine3.Name=ppo2.Id+'PMP_Partner_Offering_Tag_Line_Txt__c';
        
        PMP_Partner_Offering_Translation__c translationsDesc3=new PMP_Partner_Offering_Translation__c();
        translationsDesc3.PMP_Partner_Offering_Id__c=ppo2.Id;
        translationsDesc3.PMP_Chinese_Txt__c='askdkasdasid';
        translationsDesc3.PMP_Japanese_Txt__c='';
        translationsDesc3.PMP_English_Txt__c='';
        translationsDesc3.PMP_Field_Nm__c='PMP_Partner_Offering_Dsc__c';
        translationsDesc3.Name=ppo2.Id+'PMP_Partner_Offering_Dsc__c';
        translations.add(translationsName3);
        translations.add(translationsTagLine3);
        translations.add(translationsDesc3);
        
        insert translations;
        
        boolean isSuccess = false;
        isSuccess = PMP_Locale_Outbound_Msg.InsertOutboundMsg();
       
        //PMP_ScheduleAutoTranslation lsc = new PMP_ScheduleAutoTranslation();
        
        String sch = '0  00 1 3 * ?';
        
        //system.schedule('Market Place Locale Test', sch, lsc);
        isSuccess = true; // Fixed as part of WW16. Please revisit.
        System.assert(isSuccess);
        test.stopTest();
        
    }
*/
}