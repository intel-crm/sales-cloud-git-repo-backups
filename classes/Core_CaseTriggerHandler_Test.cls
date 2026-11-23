@isTest
public class Core_CaseTriggerHandler_Test
{

    static testMethod void testmethod1() {
        Core_CaseTriggerHandler instCTH = new Core_CaseTriggerHandler();
    }
      
    /** commented for US265805
    
    static testMethod void testupdateCEPCaseRegionPickListValue() {
        
        RecordType accRecordType = [select id from recordType where sObjectType='Account' and name ='Intel Account' limit 1];
       
        Account accountInstance = new Account(Name='CEP Test Account',recordtypeid=accRecordType.id,BillingCountryCode = 'USA',BIllingStateCode = 'AL',
                                    BillingCity = 'Alabama',BillingStreet = 'test',Core_Account_Type__c = 'Other',Core_Sales_Segment__c = 'Reseller/Channel',
                                    Core_Sub_Geo__c = 'CEE', Core_Geo__c='ASMO');    
       
        insert accountInstance;
        
        RecordType conRecordType = [select id from recordType where sObjectType='Contact' and name = 'Intel Contact' limit  1];
        Contact Cont = new Contact(recordtypeid=conRecordType.id,Email='testcepcontact1111@gmail.com',LastName = 'CEPLast98',FirstName = 'CEPFirst98',AccountId = accountInstance.id,MailingCountry='USA');
        insert Cont;
     
        RecordType caseRecordType = [select id from recordType where sObjectType='Case' and name ='CEP Case' limit 1];
        Case cepCase = new Case(contactId=Cont.id,Status ='New',Origin='Email',Core_CEP_Case_Region__c = 'ASMO',Core_CEP_Account_Name__c = accountInstance.id,recordTypeId = caseRecordType.id,Subject='This is a test case');
        insert cepCase;
          system.debug('@@####***n**'+cepCase.Core_CEP_Case_Region__c);
        Case newCase = [select id,Core_CEP_Case_Region__c from case where id=: cepCase.id limit 1];
        System.assertEquals('ASMO', newCase.Core_CEP_Case_Region__c);
        
       // newCase.Core_CEP_Case_Region__c ='APJ';
       
        
       // update newcase;
        test.startTest();
          cepCase.Core_CEP_Case_Region__c ='APJ';
        try{
            Core_CaseTrigger_Dispatcher.recursivetrigger = True;
            Core_CaseTrigger_Dispatcher.recursivetrigger1 = True;
            update cepCase;

             Case newCase2 = [select id,Core_CEP_Case_Region__c from case where id=: cepCase.id limit 1];
            system.debug('---newCase2--'+newCase2.Core_CEP_Case_Region__c);
            
        }catch(Exception e){
            
        }
           
            system.debug('-cepCase-----'+cepCase.Core_CEP_Case_Region__c);
        test.stopTest();
    }
    **/
}