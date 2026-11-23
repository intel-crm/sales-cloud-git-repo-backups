global without sharing class Core_MDF_Create_CCP_Cases_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public List<PartnerFundClaim> pfcListForNewCases = new List<PartnerFundClaim>();
    public Database.QueryLocator start(Database.BatchableContext context){
        String strQuery = '';
        strQuery = 'select id,Core_MDF_Document_Submission_Missed_Ind__c, Core_MDF_Audit_Hold__c,Core_MDF_PIC_Review_Completed__c,Core_MDF_BackendReviewSelection_Ind__c from PartnerFundClaim ';
        strQuery += 'where Core_MDF_Claim_Review_Case__c = null AND (';
        //Query Condition #1 where Claim has completed PIC Review and has never run through Rules Engine
        strQuery += '(Core_MDF_PIC_Review_Completed__c = true AND Core_MDF_BackendReviewSelection_Ind__c = false AND ';
        strQuery += 'Core_MDF_Status__c in (';
        for(string status : Label.Core_MDF_Create_CCP_Cases_Claim_Statuses.split(';')){  //Payment Due, Pending Available Fund
            strQuery += '\'' + status + '\',';
        }
        strQuery = strQuery.removeend(',');
        strQuery += ')) OR ';
        //Query Condition #2 where Cases need to be created with ZV Scorecard
        strQuery += '(Core_MDF_Document_Submission_Missed_Ind__c = true) OR ';
        //Query Condition #3 where Case failed to create after Review Hold is true
        strQuery += '(Core_MDF_Audit_Hold__c = true AND Core_MDF_Status__c != \'Cancelled\' AND Core_MDF_PIC_Review_Completed__c = true))';
        System.debug('Query@@@ '+strQuery);
        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext context,List<PartnerFundClaim> pfcList){
        
        set<id> pfcListForRE = new set<id>();
        Map<string,set<Id>> runAuditRules = new Map<string,set<Id>>();
        Map<string,Map<Id,Core_MDF_Rules_Engine.RulesEngineParams>> outputFromRE = new Map<string,Map<Id,Core_MDF_Rules_Engine.RulesEngineParams>>();
        Map<id,PartnerFundClaim> pfcIdtoPFCMap = new Map<id,PartnerFundClaim>();
        List<PartnerFundClaim> pfcToBeUpdated = new List<PartnerFundClaim>();
        
        try{
            for(PartnerFundClaim pfc:pfcList){
                pfcIdtoPFCMap.put(pfc.id,pfc);
                //For new claims that need to run through Rules Engine                
                if(pfc.Core_MDF_PIC_Review_Completed__c && !pfc.Core_MDF_BackendReviewSelection_Ind__c && !pfc.Core_MDF_Document_Submission_Missed_Ind__c){
                    System.debug('IF@@@');
                    pfcListForRE.add(pfc.id);
                }
                //For claims that need case to be generated (ZV Cases or normal Cases)
                else{
                    System.debug('else@@@');
                    pfcListForNewCases.add(pfc);
                }
            }
          
            //Send claims to Rules Engine to execute 'Audit' rules
            if(pfcListForRE.size()>0){
                System.debug('49-IF@@@');
                runAuditRules.put('Audit',pfcListForRE);
                outputFromRE = Core_MDF_Rules_Engine.genericEngineFlow(runAuditRules);
            }
            
           
            if(outputFromRE.size()>0){
                System.debug('57 --IF@@@');
                Map<Id,Core_MDF_Rules_Engine.RulesEngineParams> resultMap = outputFromRE.get('Audit');
                for(id claimID: resultMap.keyset()){
                    PartnerFundClaim claimRecord = new PartnerFundClaim(id = claimID);
                    Core_MDF_Bulk_Transaction__e evtObj = new Core_MDF_Bulk_Transaction__e();
                    
                    //If the result is true -> select for case creation
                    if(resultMap.get(claimID).result){
                        claimRecord.Core_MDF_Audit_Hold__c = true;
                    	claimRecord.Core_MDF_Audit_Type__c= resultMap.get(claimID).ruleRecord.Core_MDF_Rule_Type_Nm__c;              
                    	claimRecord.Core_MDF_FlaggedForAudit__c = true; 
                    	claimRecord.Core_MDF_Review_Hold_Rule_Nm__c = resultMap.get(claimID).ruleRecord.Name;
                        claimRecord.Core_MDF_Audit_Type__c = resultMap.get(claimID).additionalInfo;

                        pfcListForNewCases.add(pfcIdtoPFCMap.get(claimID));
                    }
                    //Else update fields on claim
                    claimRecord.Core_MDF_BackendReviewSelection_Ind__c = true;
                    pfcToBeUpdated.add(claimRecord);
                }
             } 
             //Update the Claims
             if(pfcToBeUpdated.size()>0){
                Database.SaveResult[] results = Database.update(pfcToBeUpdated,false);
               
             }    
        }
        catch(exception ex){Core_MDF_CCP_UtilityClass.logError(ex);}
    }
    public void finish(Database.BatchableContext context) {
 

        //Send Claims for Case creation
             if(pfcListForNewCases.size()>0){
                System.debug('finish@@@');
                Id batchInstanceId = Database.executeBatch(new Core_MDF_ClaimReviewCaseProcessHelper(pfcListForNewCases,'CreateCases'),50);
             }  
    }
}