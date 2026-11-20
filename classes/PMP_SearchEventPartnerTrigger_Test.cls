@isTest
public class PMP_SearchEventPartnerTrigger_Test {/*extends PMP_SearchWrapperStore{
    @isTest static void testEventOfferingTrigger(){
        Test.startTest(); 
        Account testAccount = PMP_SearchTestDataFactory.createIntelAccount('testAccount', PMP_SearchTestDataFactory.intel_Account_Record_Type, false);
        insert testAccount;
        Id accId = [SELECT id from Account WHERE Name = 'testAccount'].id;
     
        PMP_Company__c testPartner1 =  PMP_SearchTestDataFactory.createCompanyInformation('testPartner1',accId , false);
        
        testPartner1.PMP_Account_Specialty__c = 'None';       
        testPartner1.PMP_Partner_Program_nm__c = 'ISA;ODM-LOEM';
        testPartner1.PMP_Account_Dsc__c = 'test';
        testPartner1.PMP_Company_Information_Language_Nm__c = 'English';
        testPartner1.PMP_Is_Published_Ind__c = true;
        testPartner1.PMP_Company_Lead_Gen_Language_Nm__c = 'English;Japanese';
        testPartner1.PMP_Company_Lifecycle_Status_Nm__c = 'Published';
        insert testPartner1; 
        
        
        
        PMP_Marketplace_Event__c eve=new PMP_Marketplace_Event__c();
        eve.Name='Test Event';
        eve.PMP_Marketplace_Event_Start_Dt__c=System.today()-1;
        eve.PMP_Marketplace_Event_End_Dt__c=System.today()+1;
         eve.PMP_Marketplace_Event_Tagline__c = 'testTag';
         eve.PMP_Marketplace_Desc__c = 'testDesc';
        insert eve;
        
    
         
        PMP_Marketplace_Event_Partner__c evePar=new PMP_Marketplace_Event_Partner__c ();
        evePar.PMP_Company_Id__c=testPartner1.Id;
        evePar.PMP_Event_Id__c=eve.Id;
        insert evePar; 
         
         try{
            
             PMP_Marketplace_Event_Partner__c evePar1=new PMP_Marketplace_Event_Partner__c ();
             evePar1.PMP_Company_Id__c=testPartner1.Id;
             evePar1.PMP_Event_Id__c=eve.Id;
             insert evePar1; 
         }catch(Exception e){
               //system.debug('Some Error occured while insert::'+ e.getMessage());
         }
        
        try{
            
            delete [select id from PMP_Marketplace_Event_Partner__c where PMP_Event_Id__r.name='Test Event']; 
            
        }catch(Exception e){
            //system.debug('Some Error occured while delete::'+ e.getMessage());
        }
        
        system.assertNotEquals(Null,evePar,'failed'); 
        Test.stopTest(); 
    }*/
}