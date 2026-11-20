/***************************************************************************************************************************************
Apex Class Name     : PRM_RegReqProcessingQueueable 
Version             : 1.0
Created Date        : June 2019
Function            : To invoke the processes asynchronously while procesing registeration request in system.

Modification Log    :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------
* Harshit                   21-06-2019                    Implemented execute method to assign benefits, entitlements to the Account created 
and trigger email to corresponding contacts/users.
*************************************************************************************************************************************/
public class PRM_RegReqProcessingQueueable implements Queueable{
    
    List<Account> accountsToInsert = new list<Account>();
    List<Contact> contactsToInsert = new list<Contact>();
    Boolean isAdminProcess;    
    String businessEvent;
    PRM_Registration_Request__c regReq;
    Boolean flagNeedToUse;

    public static final String LOG_ENTRY_ORIGIN   = 'PRM_RegReqProcessingQueueable';
    public static final String LOG_ENTRY_SCOPE_ACCOUNT_UPDATE   = 'Account_Update';
    public static final String LOG_ENTRY_PROJECT  = 'IPA Registrations';
    public static final String LOG_ENTRY_SCOPE    = 'PRM_RegReqProcessingQueueable';
    public static final String LOG_ENTRY_SEVERITY = 'error';
    
    
    public PRM_RegReqProcessingQueueable(List<Account> accToInsert, List<Contact> conToInsert, Boolean isAdminProcess, String businessEvent, PRM_Registration_Request__c regReq,Boolean flagNeedToUse)
    {
        
        this.accountsToInsert = accToInsert;  
        this.contactsToInsert = conToInsert;  
        this.isAdminProcess = isAdminProcess;        
        this.businessEvent = businessEvent;
        this.regReq = regReq;
        this.flagNeedToUse=flagNeedToUse;
    }
    
    public void execute(QueueableContext qc) {  
        //system.debug(accountsToInsert);
        string logentry;
        String isActiveEmailFramework = flagNeedToUse ? System.Label.PRM_Invoke_Email_Framework : 'false';           
        try{
                if(!isAdminProcess){
                    //TWC729-7729
                   if(businessEvent == 'Update_Account'){
                        updateAccount(accountsToInsert);
                    }
                    else{
                        PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true,false);
                        if(isActiveEmailFramework == 'true'){
                            PRM_RegistrationRequestUtility.sendApprovalEmail(contactsToInsert,businessEvent,regReq.Id,regReq.PRM_Partner_Role__c);
                        }
                        if(isActiveEmailFramework == 'false'){
                            PRM_CreateAccountAndRelatedRecords.sendWelcomeEmailNotification(contactsToInsert,businessEvent,regReq); 
                        }
                    }
                }                            
                else{
                        PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true,true);
                        if(isActiveEmailFramework == 'true'){
                            PRM_RegistrationRequestUtility.sendApprovalEmail(contactsToInsert,businessEvent,regReq.Id,regReq.PRM_Partner_Role__c);
                        }
                        if(isActiveEmailFramework == 'false'){
                            PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(contactsToInsert, regReq);
                        }
                    }
            }   
        catch(Exception e){
            logentry=Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'' ,'' , '', '', '',e);
        }
        finally{
             if(businessEvent != 'Update_Account'){//TWC729-7729
                string retype=isAdminProcess?'Admin':'Self';
                set<string> recList=new set<String>();
                recList.add(string.valueof(regReq.Id));
             //system.debug('---queulimit '+Limits.getQueueableJobs());
                if(System.Label.PRM_Tracker_Enabled=='true')
                PRM_RegistrationTrackerUtility.EnQueueTrackerUtility(recList,null,logentry,'PRM_RegReqProcessingQueueable',retype);
             }
        
        }

    }
    public static void updateAccount(List<Account> accList){//TWC729-7729
        if(accList != null && !accList.IsEmpty()){
            String LogEntryId;
            List<Core_Log_Entry__c> logEntryToUpdate = new List<Core_Log_Entry__c>();
            list<Database.SaveResult> saveResult = Database.update(accList, false);
            for (Integer i = 0; i< saveResult.size(); i++) {
                if(!saveResult[i].isSuccess()){
                    LogEntryId = Core_Log_Entry.logEntryWithDetails(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_ACCOUNT_UPDATE, LOG_ENTRY_SEVERITY ,saveResult[i].getErrors()[0].getMessage(),JSON.serialize(new List<Account>{accList[i]}), accList[i].Id, 'Account', accList[i].Id);
                    Core_Log_Entry__c logEntry = new Core_Log_Entry__c(Id = LogEntryId, Core_Retry_Counter__c = 1);
                    logEntryToUpdate.add(logEntry);

                }
            }
            if(!logEntryToUpdate.isEmpty() && logEntryToUpdate != null){
                update logEntryToUpdate;
            }
        }
    }
}