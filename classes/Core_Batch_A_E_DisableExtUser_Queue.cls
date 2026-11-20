/*************************************************************************************************************************************************
Apex Class Name : Core_Batch_A_E_DisableExtUser_Queue 
Created Date    : 21/09/2020
Function        : This apex class is used to update user's field's values,we have used Queueable interface as we were facing issue to call future
				  method through batch while updating user.
**************************************************************************************************************************************************
* Developer                   Date                   Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Sonali Mehetre            21/09/2020             US731342 - Pipeline: IPS Issue fix implementation

*************************************************************************************************************************************************/

public class Core_Batch_A_E_DisableExtUser_Queue implements Queueable {
    public List<User> lstOfUser = new List<User>();    
    public static DateTime dtWhen = system.now();
    public static Integer count = 0;
        
    public Core_Batch_A_E_DisableExtUser_Queue(List<User> records) {
        this.lstOfUser = records;        
    }
    
    //Method is used to update user's field values.    
    public void execute(QueueableContext context) {
        try{
        List<User> lstToUpdateUser = new List<User>();
        for(User usr : lstOfUser) {
            usr.Partner_License_Reclaimed__c = false;
            usr.IsPortalEnabled = false;
            usr.FederationIdentifier = null;
            lstToUpdateUser.add(usr);
        }
          
        List<Database.SaveResult> lstUserSaveResultUpdate = Database.update(lstToUpdateUser, false);        
               
        for (Database.SaveResult saveResult : lstUserSaveResultUpdate) {            
            if (!saveResult.isSuccess()) {
                for (Database.Error err: saveResult.getErrors()) {
                                      
                } 
            }else{
                count++;                
            }        
        } 
        createLogEntry(count,dtWhen);
    }
    catch(exception e){
            Core_Log_Entry__c excepLog = new Core_Log_Entry__c(Core_Message__c = e.getMessage(), Core_Origin__c = 'updateUser', Core_Project__c = 'Core_Batch_A_E_DisableExtUser_Queue' , Core_Details__c = 'In Core Batch A E DisableExtUser Queue', Core_Severity__c = 'info', Core_When__c = System.Now());     
            insert excepLog;
        }
    }
    @future
    public static void createLogEntry(Integer count,DateTime dtWhen) {
        
        DateTime dtnow = system.now();
        decimal duration = ((dtnow.getTime())/1000) - ((dtWhen.getTime())/1000);
        
        // Create Assign log Entry
        Core_Log_Entry__c assignCLE = new Core_Log_Entry__c ();
        assignCLE.Core_Origin__c = 'A&E Batch to Disable External Users';
        assignCLE.Core_Project__c = 'A&E';
        assignCLE.Core_Scope__c = 'Disable External Users';
        assignCLE.Core_Severity__c = 'Information';
        assignCLE.Core_Message__c = 'Batch to Disable External Users';
        assignCLE.Core_When__c = dtWhen;        
        assignCLE.Core_Details__c = 'Duration : ' + duration + ' seconds\r\n '+ 'Records Processed : ' + count;
        
        try {
            insert assignCLE;
        } catch (Exception e) {
            System.debug('Error inserting log entry: ' + e.getMessage());
        }
        
    }
}