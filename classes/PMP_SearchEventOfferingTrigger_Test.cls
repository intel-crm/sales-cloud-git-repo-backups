@isTest
public class PMP_SearchEventOfferingTrigger_Test extends PMP_SearchWrapperStore{

     @isTest static void testEventOfferingTrigger(){
        Test.startTest(); 
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
     
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        
        testPartner1.PMP_Account_Specialty__c = 'Video Specialty';       
        testPartner1.PMP_Partner_Program_nm__c = 'ISA;ODM-LOEM';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert testPartner1; 
        
        PMP_Partner_Offering__c offering1 = PMP_SearchTestDataFactory.createOffering('TestDuplicateOffering1','Public Content', 
                                                                               'TestDuplicate',testPartner1.Id, true,'Draft','');
        offering1.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Published';
        offering1.PMP_Partner_Offering_Start_Dt__c = System.today();
        offering1.PMP_Offering_Status_Update_Dt__c = System.today();
        offering1.PMP_Partner_Offering_End_Dt__c = System.today();   
        offering1.PMP_Partner_Offering_Dsc__c = 'testDescription';
        offering1.PMP_Partner_Offering_Tag_Line_Txt__c = 'testTagline';
        update offering1;
        
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.today()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.today()+1;
         eve.PMP_Marketplace_Event_Tagline__c = 'testTag';
         eve.PMP_Marketplace_Desc__c = 'testDesc';
        insert eve;
        
        PMP_Marketplace_Event_Offering__c eveOff=new PMP_Marketplace_Event_Offering__c();
        eveOff.PMP_Offering_Id__c=offering1.Id;
        eveOff.PMP_Event_Id__c=eve.Id;
        insert eveOff;
         

         
         try{
             PMP_Marketplace_Event_Offering__c eveOff1=new PMP_Marketplace_Event_Offering__c();
             eveOff1.PMP_Offering_Id__c=offering1.Id;
             eveOff1.PMP_Event_Id__c=eve.Id;
             insert eveOff1; 

         }catch(Exception e){
             
         }
        
         
        Test.stopTest(); 
    }
    
    
    
}