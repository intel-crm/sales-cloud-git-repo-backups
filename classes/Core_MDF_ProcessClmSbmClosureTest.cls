/****************************************************************************************************************************************
* Class Name  : Core_MDF_ProcessClmSbmClosureTest 
* Version     : 1.0 
* Created Date: 05-20-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Bikram Bebarta         05/20/2020               Test class for Core_MDF_ProcessClaimSubmissionClosure
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_ProcessClmSbmClosureTest {
    @isTest static void unitTest(){
        list<Core_MDF_CCP_Submission_Window__mdt> mtdList = [SELECT Core_MDF_Program__c, Core_MDF_Budget_Type__c, 
                                                                  Core_MDF_Geo__c, Core_MDF_Sub_Geo__c, Core_MDF_Country__c,
                                                                  Core_MDF_Quarter__c,Core_MDF_Case_SLA__c, Core_MDF_Claim_Submission_Window_mnth__c, Core_MDF_Claim_Submission_Window_days__c,
                                                                  Core_MDF_Doc_Submission_Window__c,Core_MDF_Doc_Submission_Rule__c,
                                                                  Core_MDF_Escalation_Submission_Window__c,Core_MDF_Escalation_Submission_Rule__c,
                                                                  Core_MDF_Activity_Auto_Closure_SLA__c,Core_MDF_Activity_Auto_Closure_Rule__c    
                                                                  FROM Core_MDF_CCP_Submission_Window__mdt limit 100];
        if(mtdList != null && !mtdList.isEmpty()){
            Map<String,Date> dueDateMap = new Map<String,Date>();
            Map<string,integer> keyToDaysSLA = new Map<string,integer>();
            for(Core_MDF_CCP_Submission_Window__mdt mtd : mtdList){
                string key = mtd.Core_MDF_Program__c+
                            ':'+mtd.Core_MDF_Budget_Type__c+
                            ':'+mtd.Core_MDF_Geo__c+
                            ':'+mtd.Core_MDF_Sub_Geo__c+
                            ':'+mtd.Core_MDF_Country__c+
                            ':'+system.today().format(); 
                key = key.deleteWhitespace();
                system.debug('key-----------------      '+key);
                dueDateMap.put(key,null);
                keyToDaysSLA.put(key,0);
            }
            map<string,date> quarterWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getQuarterEndDate(dueDateMap);
            system.assert(quarterWindowMap != null);
            map<string,date> submissionWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getSubmissionDueDate(dueDateMap);
            map<string,date> closureWindowMap = Core_MDF_ProcessClaimSubmissionClosure.getDocSubDueDate(dueDateMap);
            map<string,date> escSubDate = Core_MDF_ProcessClaimSubmissionClosure.getEscSubDate(dueDateMap);
            map<string,date> actSubDueDate = Core_MDF_ProcessClaimSubmissionClosure.getActSubDueDate(dueDateMap);
            map<string,date> quarterStartDate = Core_MDF_ProcessClaimSubmissionClosure.getQuarterStartDate(dueDateMap);
            Map<string,integer> daysSLAMap = Core_MDF_ProcessClaimSubmissionClosure.getDaysSLA(keyToDaysSLA);
            system.assert(daysSLAMap != null);
            
        }
        
    }
}