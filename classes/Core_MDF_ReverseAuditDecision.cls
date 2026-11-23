/****************************************************************************************************************************************
* Class Name  : Core_MDF_ReverseAuditDecision 
* Version     : 1.0 
* Created Date: 05-08-2020
* Modification Log :
* Developer                          Date                     Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Bikram Bebarta         05/08/2020               Reverse Audit Decision
*****************************************************************************************************************************************/
public class Core_MDF_ReverseAuditDecision{
    public static string processAuditReverse(string caseId){
        string result = '';
        try{
            if(string.isNotBlank(caseId)){
                list<PartnerFundClaim> claimList = [SELECT Core_MDF_Claim_Review_Case__r.Core_MDF_Review_Case_Status__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c, 
                                                    Core_MDF_Claim_Review_Case__r.RecordTypeId, Core_MDF_Claim_Review_Case__r.Core_MDF_SLA_Start_Date__c, 
                                                    Core_MDF_Claim_Review_Case__r.Core_MDF_SLA_Days_Nbr__c, Core_MDF_Claim_Review_Case__r.Core_MDF_Audit_Reversal_Count_Nbr__c, 
                                                    Core_MDF_Status__c , Core_MDF_Audit_Hold__c, Core_MDF_Claim_Review_Case__c,
                                                    Core_MDF_Program__c, Request.Core_MDF_Budget_Type_txt__c
                                                    FROM PartnerFundClaim 
                                                    WHERE 
                                                    Core_MDF_Claim_Review_Case__c = :caseId 
                                                    AND Core_MDF_Claim_Review_Case__r.Core_MDF_Status__c = 'Compliant' 
                                                    AND 
                                                    (
                                                        Core_MDF_Status__c IN ('Pending Available Fund','Payment Due')
                                                        OR
                                                        (Core_MDF_Status__c = 'Hold' AND Core_MDF_Audit_Hold__c = false)
                                                    )
                                                    ];
                //claimList = null;
                if(claimList != null && !claimList.isEmpty()){
                    PartnerFundClaim claim = claimList[0];
                    string caseRecordTypeAudit = 'Core_MDF_Audit';
                    list<RecordType> recordTypeList = [SELECT DeveloperName, Id FROM RecordType 
                                                       WHERE SobjectType = 'case' 
                                                       AND DeveloperName = :caseRecordTypeAudit];
                                                          
                    Case cs = claim.Core_MDF_Claim_Review_Case__r;
                    cs.Core_MDF_Review_Case_Status__c = null;
                    cs.Core_MDF_Status__c = 'Under Review';
                    cs.Status = 'Open';
                    if(cs.Core_MDF_Audit_Reversal_Count_Nbr__c == null){
                        cs.Core_MDF_Audit_Reversal_Count_Nbr__c = 1;
                    }else{
                        cs.Core_MDF_Audit_Reversal_Count_Nbr__c ++;
                    }
                    
                    cs.RecordTypeId = recordTypeList[0].id;
                    
                    //SLA
                    Map<string,integer> programBudgetTypeToCaseSLAMap = new Map<string,integer>();
                    for(Core_MDF_CCP_Claim_Window__mdt claimWindow : [SELECT Id, Core_MDF_Program_Txt__c, Core_MDF_Budget_Type_Txt__c, Core_MDF_Submission_SLA_Nbr__c, Core_MDF_Case_SLA_Nbr__c
                                                                      FROM Core_MDF_CCP_Claim_Window__mdt LIMIT 1000]) {
                    	string key = claimWindow.Core_MDF_Program_Txt__c + claimWindow.Core_MDF_Budget_Type_Txt__c;
                        programBudgetTypeToCaseSLAMap.put(key,integer.valueof(claimWindow.Core_MDF_Case_SLA_Nbr__c));
                    }
                    cs.Core_MDF_SLA_Start_Date__c = system.now();
                    string programAndBudget = claim.Core_MDF_Program__c + (claim.Request.Core_MDF_Budget_Type_txt__c == null? 'NA': claim.Request.Core_MDF_Budget_Type_txt__c);
                    cs.Core_MDF_SLA_Days_Nbr__c = programBudgetTypeToCaseSLAMap.get(programAndBudget);
                    update cs;
                    
                    claim.Core_MDF_Status__c = 'Hold';
                    claim.Core_MDF_Audit_Hold__c = true;
                    update claim;
                    result = 'Success';
                }
                else{
                    result = Label.Core_MDF_Reverse_Audit_Error_Message;
                }
            }
        }catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
        return result;
    }
 }