/****************************************************************************************************************************************
* Class Name        : Core_MDF_RecallApproval_Batch
* Test class 		: Core_MDF_RecallApproval_BatchTest
* Created Date      : 6/29/2021
* Modification Log
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - NZ       6/29/2021         Batch class to recall 
*****************************************************************************************************************************************/

public class Core_MDF_RecallApproval_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public static String logEntryMsg = '';
    public Set<Id> targetObjIdSet = new Set<Id>(); 
    public Set<Id> prcsInstnId = new Set<Id>(); 
    public Set<Id> resubmitPFRId = new Set<Id>(); 
    List<PartnerFundRequest> pfrList = new List<PartnerFundRequest>();	
    public static final string STATUS_PENDING ='Pending';
    public static final string PROCESS_NODE_ATF = 'After The Fact Approval';
    public static final string ACTION_REMOVED ='Removed';
    public static final string ERR_STR ='Approval Error: ';
    
    /***************************************************************************************************** 
Method Name :   start
@return     :   List of claims which are not audited
@parameters :   Database.BatchableContext
Description :   It fetches all Closed records with no internal approval
Added By    :   Accenture - NZ - 6/29/2021
Modified By :                               Date:                   Changes:
******************************************************************************************************/ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        init();
        System.debug('In Start VD: '+prcsInstnId);
        string qryStr = 'SELECT Id FROM ProcessInstanceWorkitem  WHERE ProcessInstanceId IN :prcsInstnId';
        System.debug('In Start '+Database.getQueryLocator(qryStr));
        return Database.getQueryLocator(qryStr);
        
    }
    /******************************************************************************************************** 
Method Name :   execute
@return     :   void
@parameters :   Database.BatchableContext
Description :   Selects the Recall PI Instance Records
Added By    :   Accenture - NZ - 6/29/2021
Modified By :                               Date:         Changes:None  
**********************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<ProcessInstanceWorkitem> prcsInstList	) {  
        
        System.debug('NZ-->prcsInstList'+prcsInstList);
        Set<Id> prcsInsIdSet = new Set<Id>();
        Set<Id> prStp = new Set<Id>();
        List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();
        
        for(ProcessInstanceWorkitem prcsInst : prcsInstList){
            System.debug('NZ-->prcsInst.ProcessNodeName: '+prcsInst.Id);
            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
            pwr.setAction(ACTION_REMOVED);
            pwr.setWorkItemId(prcsInst.Id);
            pwrList.add(pwr);     	   
        }
        System.debug('NZ-->pwrList: '+pwrList);
        List<Approval.ProcessResult> resultList = Approval.process(pwrList);
        if(resultList != null && resultList.size()>0){
            Integer index = 0;              
            for(Approval.ProcessResult result : resultList){
                if(result.isSuccess()){ 
                    
                }else{
                   
                    logEntryMsg = ERR_STR + pwrList[index]; Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Label.Core_MDF_Activity_Recall_Exception_Origin);
                }
                index++;
            }
        }
        System.debug('NZ-->prcsInstList'+prcsInstList);
        
    }
    
 /******************************************************************************************************** 
Method Name :   finish
@return     :   void
@parameters :   Database.BatchableContext
Description :   Calls the batch for Re submit Activity Records
Added By    :   Accenture - NZ - 6/29/2021
Modified By :                               Date:         Changes:None  
**********************************************************************************************************/
    public void finish(Database.BatchableContext bc) {  
        
           List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
                for(Id pfrId : resubmitPFRId){
                   
                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                    appObj.setObjectId(pfrId);                   
                    appObj.setComments('Record submitted for After The Fact approval');                                   
                    appRequests.add(appObj);                    
                }
                System.debug('resubmitPFRId: '+resubmitPFRId);
        		System.debug('appRequests: '+appRequests);
                if(appRequests != NULL && appRequests.size()> 0){
                    Approval.ProcessResult[] result = Approval.process(appRequests); 
                } 
        
    }
    
    /******************************************************************************************************** 
Method Name :   init
@return     :   void
@parameters :   None
Description :   Fetches PI REcords which are in QUeue with Closed butnot ATF QUeue
Added By    :   Accenture - NZ - 6/30/2021
Modified By :                               Date:         Changes:None  
**********************************************************************************************************/
    public void init(){
        
        for(PartnerFundRequest pfr :[SELECT Id 
                                     FROM PartnerFundRequest 
                                     WHERE Core_MDF_Fund_Request_Status__c = 'Closed' AND
                                     Core_MDF_Activity_Closure_Type__c ='No Internal Approval' AND 
                                     Core_MDF_Program__c = 'Retail Marketing Funds']){                                          
                                        targetObjIdSet.add(pfr.Id);                                          
                                     }
        //targetObjIdSet.add('0RJg000000002QRGAY');
        for(ProcessInstanceNode prst : [SELECT id,ProcessNodeName,ProcessInstanceId,ProcessInstance.TargetObjectId
                                             FROM ProcessInstanceNode
                                             WHERE ProcessInstance.TargetObjectId  IN :targetObjIdSet 
                                                   AND ProcessInstance.Status = :STATUS_PENDING 
                                             	   AND ProcessNodeName != :PROCESS_NODE_ATF]){
        	prcsInstnId.add(prst.ProcessInstanceId);  
            resubmitPFRId.add(prst.ProcessInstance.TargetObjectId);                                         	
        }
        System.debug('NZ-->resubmitPFRId: '+resubmitPFRId);
        System.debug('NZ-->targetObjIdSet: '+targetObjIdSet);
        System.debug('NZ-->prcsInstnId: '+prcsInstnId);     	
        
        
    }
}