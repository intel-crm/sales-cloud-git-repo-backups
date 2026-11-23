/****************************************************************************************************************************************
* Class Name  : Core_MDF_AuditAssignment 
* Version     : 1.0 
* Created Date: 10-19-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture K Alka             10/19/2018                    Created Core_MDF_AuditCaseProcess to have all the methods related to Audit Case process in this class 
*****************************************************************************************************************************************/
public without sharing class Core_MDF_AuditCaseProcess
{

/****************************************************************************************************************************************
    Method Name:                                             auditCaseAssignment
    @return  :                                               NA
    @parameters:                                             Case record Id List
    Description:                                             Trigger the Assignment rule for the Cases 
                                                             for which Id are passed as parameter
    Added By:                                                Accenture â€“ K Alka  -  19/10/2018

    Modified By:                  Date:                      Changes: 
    Accenture  K Alka             10/19/2018                 Created.
*****************************************************************************************************************************************/ 
    @InvocableMethod
    public static void auditCaseAssignment(List<Id> caseIds)
    {
        if(caseIds.size() > 0){//If caseIds list is not empty then initiate the case assignment

            try{
                //Creating the DMLOptions for "Assign using active assignment rules" checkbox
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                dmo.EmailHeader.triggerUserEmail = true; 
                //get the Case record list to trigger for assignment         
                List<Case> cases = [select id, Core_MDF_Claim_Submitter__c,  Core_MDF_Claim_Submitter__r.LanguageLocaleKey, Core_MDF_Claim_Submitter_Language__c from case where case.id in :caseIds];
                for(Case c :cases){
                    //Setting the DMLOption on each Case 
                    c.Core_MDF_Claim_Submitter_Language__c = c.Core_MDF_Claim_Submitter__r.LanguageLocaleKey;
                    c.setOptions(dmo);
                }
                //US949837 - Added extra condition to fix checkmarx issues
                if(Schema.sObjectType.Case.isUpdateable()){
                    update cases;
                }
            }catch(exception ex){Core_MDF_CCP_UtilityClass.logErrorinLogObject(ex.getMessage(),'Audit Assignment');}    
        }
   }
}