/****************************************************************************************************************************************
 * Class Name      : Core_MDF_PaymentRunHelper_Test
 * Version               : 1.0 
 * Created Date          : 04-02-2019
 * Modification Log      : 
 * Developer            Date             Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - RG     01-30-2019       Test Class of Core_MDF_PaymentRunHelper
 *****************************************************************************************************************************************/
@isTest
private class Core_MDF_PaymentRunHelper_Test{

    @isTest
    static void testDuplicatesAndValidations(){
        /*Channel program record*/
        ChannelProgram cp = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);
        
        /* List to hold the payment Run records */
        list<Core_MDF_Payment_Run__c> paymentRunList = new list<Core_MDF_Payment_Run__c>();
        
        /* List to hold the payment Run records to be deleted*/        
        list<Core_MDF_Payment_Run__c> paymentRunDelList = new list<Core_MDF_Payment_Run__c>();
        
        /* The payment Run records */
        Core_MDF_Payment_Run__c paymentRunRec1 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec2 = new Core_MDF_Payment_Run__c();
        Core_MDF_Payment_Run__c paymentRunRec3 = new Core_MDF_Payment_Run__c();
        
        /*Map to Hold the payment Run records */
        map<Id, Core_MDF_Payment_Run__c> paymentRunRecMap = new map<Id, Core_MDF_Payment_Run__c>();
        
        /* First Payment Run Record */
        paymentRunRec1.Core_MDF_Program_Id__c = cp.Id;
        paymentRunRec1.Core_MDF_Geo_Txt__c = 'EMEA';
        paymentRunRec1.Core_MDF_Status_Txt__c = 'Scheduled';
        paymentRunRec1.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(10);
        
        /* Duplicate Record of First Payment Run Record in the List */
        paymentRunRec2.Core_MDF_Program_Id__c = cp.Id;
        paymentRunRec2.Core_MDF_Geo_Txt__c = 'EMEA';
        paymentRunRec2.Core_MDF_Status_Txt__c = 'Error';
        paymentRunRec2.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(10);
        
        paymentRunList.add(paymentRunRec1);
        paymentRunList.add(paymentRunRec2);      
        
        /* Duplicate Record in the DB */       
        paymentRunRec3.Core_MDF_Geo_Txt__c = 'EMEA';
        paymentRunRec3.Core_MDF_Status_Txt__c = 'Scheduled';
        paymentRunRec3.Core_MDF_ScheduleRun_Dtm__c = system.now().addMinutes(10);
        paymentRunRec3.Core_MDF_Program_Id__c = cp.Id;
    
        paymentRunDelList.add(paymentRunRec2);
        paymentRunRecMap.put(paymentRunRec1.Id, paymentRunRec1);

        Core_MDF_PaymentRunHelper.preventDeleteWhenNotInScheduledState(paymentRunDelList);  
        Test.StartTest();
        try{            
            insert paymentRunRec3;
            database.insert(paymentRunList);
            System.assertEquals(paymentRunRec3.Core_MDF_Program_Id__c ,paymentRunRec1.Core_MDF_Program_Id__c);
            System.assertEquals(paymentRunRec3.Core_MDF_Geo_Txt__c ,paymentRunRec1.Core_MDF_Geo_Txt__c);
            System.assertEquals(paymentRunRec3.Core_MDF_ScheduleRun_Dtm__c ,paymentRunRec1.Core_MDF_ScheduleRun_Dtm__c);      
        }
        catch(dmlException dmlEx){
            string errorMessage = dmlEx.getMessage();
            system.assert(errorMessage.contains(System.Label.Core_MDF_PaymentRun_DuplicateErrorMessage_2));       
        }   
        paymentRunRec3.Core_MDF_Geo_Txt__c = 'PRC';        
        try{
            update paymentRunRec3; 
        }
        catch(Exception ex){
            string errorMessage = ex.getMessage();
            system.assertEquals(errorMessage, NULL);
        }  
        Test.StopTest();   
    }
}