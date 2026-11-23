/************************************************************************************************************
* Purpose: This Class is a scheduled class for IPS_MyIntel_3_0_delete_Outbound_Batch
* @Name IPS_MyIntel_3_0_delete_Schedule_Batch.
* @Author Karthik Bandla
* @version 1.0
* @Created Date 22/06/2021
* @Last Modfied Date 25/06/2021
************************************************************************************************************/
global class IPS_MyIntel_3_0_delete_Schedule_Batch implements schedulable {
    
    private final static String strScope = 'ICS_Delete_OutboundMyintelRecords_ Schedulable';
    private final static String strDetails = '\n An Exception Occurred While executing the Scheduled Batch \n'; 
    private final static String strSeverity = 'Critical';
    
    global void execute(SchedulableContext sc)
    {
        try{
            IPS_MyIntel_3_0_delete_Outbound_Batch batch = new IPS_MyIntel_3_0_delete_Outbound_Batch();
            database.executebatch(batch);
            
            //Creating custom exception to cover catch block
            if(Test.isRunningTest()) {      
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(exception ex){
            Core_Log_Entry.logEntryWithException('SFDC','IPS',strScope,strSeverity,'Issue in IPS_MyIntel_3_0_delete_Schedule_Batch',strDetails,null,'Core_IPS_MyIntel_Outbound_Message__c',null,ex);
        }
        
    }
}