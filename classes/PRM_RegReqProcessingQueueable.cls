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
    Boolean assignBenefit ;
    Boolean isAdminProcess;    
    String businessEvent;
    PRM_Registration_Request__c regReq;
    
    public PRM_RegReqProcessingQueueable(List<Account> accToInsert, List<Contact> conToInsert, Boolean assignBenefit, Boolean isAdminProcess, String businessEvent, PRM_Registration_Request__c regReq) {  
        
        this.accountsToInsert = accToInsert;  
        this.contactsToInsert = conToInsert;  
        this.assignBenefit = assignBenefit;
        this.isAdminProcess = isAdminProcess;        
        this.businessEvent = businessEvent;
        this.regReq = regReq;
    }
    
    public void execute(QueueableContext qc) {  
        system.debug('************inside queueable class************'); 
        system.debug('Total queries executed before ABA insert--->'+Limits.getQueries());
        system.debug(accountsToInsert);
        system.debug('contactsToInsert'+contactsToInsert);
        system.debug('assignBenefit-->'+assignBenefit);
       //system.debug(accountsToInsert[0].Core_Covered_Account__c);
       //system.debug(accountsToInsert[0].owner.alias); 
        try{
            if(assignBenefit)
            {
                system.debug('Account List for Benefit->'+accountsToInsert);
                //PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true);
                system.debug('Total queries executed after ABA insert--->'+isAdminProcess);
                system.debug('isAdminProcess--->'+isAdminProcess);
                if(isAdminProcess == False){
                PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true,false);
                PRM_CreateAccountAndRelatedRecords.sendWelcomeEmailNotification(contactsToInsert,businessEvent,regReq); 
                system.debug('Total queries executed after email--->'+Limits.getQueries()); 
                }
                else{
                   //email to send for admin process
                   PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true,true);
                   PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(contactsToInsert);
                }
            }
            else{
                system.debug('Account List for Benefit->'+accountsToInsert);
                //PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true);
                system.debug('Total queries executed after ABA insert--->'+Limits.getQueries());
                system.debug('isAdminProcess--->'+isAdminProcess);
                if(isAdminProcess == False){
                    PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true,false);
                    PRM_CreateAccountAndRelatedRecords.sendWelcomeEmailNotification(contactsToInsert,businessEvent,regReq); 
                    system.debug('Total queries executed after email--->'+Limits.getQueries()); 
                }
                else{
                   //email to send for admin process
                   PRM_BenefitUtility.assignBenefitsAndEntitlements(accountsToInsert,false,true,true);
                   PRM_CreateAccountAndRelatedRecordsAdmin.sendAdminRegApprovalEmail(contactsToInsert);
                }
            }
        
        }
        catch(Exception e){
            System.debug('E'+e);
        }
    }
    //System.enqueueJob( new PRM_RegReqProcessingQueueable( accountsToInsert, contactsToInsert ) );  
}