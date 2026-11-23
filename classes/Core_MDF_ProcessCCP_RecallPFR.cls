public class Core_MDF_ProcessCCP_RecallPFR implements Queueable{
    
    public List<PartnerFundRequest> pfrlist = new List<PartnerFundRequest>();
    public Map<Id,PartnerFundRequest> oldPfrMap = new Map<Id,PartnerFundRequest>();
    List<Id> recallPFRId = new list<Id>();
    List<ProcessInstanceWorkitem>  piList = new List<ProcessInstanceWorkitem>();        
    Boolean res = false;
    List<Id> pfrsToBeSubmittedForATFApproval = new List<Id>();
    public static Boolean recallRunOnce = true;
    public static String logEntryMsg = '';
    Boolean geoApprover = FeatureManagement.checkPermission('Core_MDF_CCP_Internal_Retail_Marketing_GEO_Approver');

    public Core_MDF_ProcessCCP_RecallPFR(List<PartnerFundRequest> pfrlist, Map<Id,PartnerFundRequest> oldPfrMap){
        
        this.pfrlist = pfrlist;
        this.oldPfrMap = oldPfrMap;
    }
    
    public void execute(QueueableContext context){
        try
        {
            if(recallRunOnce){
                System.debug('pfrList@@'+pfrList);
                System.debug('oldPfrMap@@'+oldPfrMap);
                for(PartnerFundRequest pfr: pfrList)
                {                                       
                    System.debug('old@@'+oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c);
                    System.debug('new@@'+pfr.Core_MDF_Fund_Request_Status__c+oldPfrMap.containsKey(pfr.Id)+oldPfrMap.get(pfr.Id));
                    System.debug('geoApprover@@'+geoApprover);
                    System.debug('pfr.Core_MDF_Start_Date__c@@'+pfr.Core_MDF_Start_Date__c);
                    System.debug('pfr.Core_MDF_PriorValueOfStatus__c@@'+pfr.Core_MDF_PriorValueOfStatus__c);
                    
                    //Check if status has been changed
                    if(oldPfrMap.containsKey(pfr.Id) && oldPfrMap.get(pfr.Id) != NULL){ 
                       //&& oldPfrMap.get(pfr.Id).Core_MDF_Fund_Request_Status__c != pfr.Core_MDF_Fund_Request_Status__c
                           
                           //To recall activities from approval process when closed or cancelled 
                           //pfr.Core_MDF_Fund_Request_Status__c == Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Cancelled_Status') ||
                           if((pfr.Core_MDF_Fund_Request_Status__c == 'Pending Review'||
                                pfr.Core_MDF_Fund_Request_Status__c == 'Pending Approval') && 
                                pfr.Core_MDF_PriorValueOfStatus__c == 'Closed' &&
                                geoApprover && 
                                (pfr.Core_MDF_Start_Date__c >= System.today())){
                                   recallPFRId.add(pfr.Id);    
                               }                           
                       }     
                } 
            }
            
            //Check the size of recallPFRId , remove the Activities from Approval Queue
            System.debug('recallPFRId@@'+recallPFRId);
            if(recallPFRId.size()>0){
                ProcessInstanceWorkitem[] workItems = [SELECT Id
                                                       FROM ProcessInstanceWorkitem 
                                                       WHERE ProcessInstance.TargetObjectId IN :recallPFRId
                                                       AND ProcessInstance.Status = 'Pending'];
                
                List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>();                         
                for(ProcessInstanceWorkitem PIns:workItems){
                    Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                    //pwr.setAction('Removed');
                    pwr.setAction('Reject');
                    pwr.setWorkItemId(PIns.id);
                    pwrList.add(pwr);   
                }
                System.debug('pwrList@@'+pwrList);
                
                Integer index = 0;
                List<Approval.ProcessResult> resultList = Approval.process(pwrList);
                for(Approval.ProcessResult result : resultList){
                    if(result.isSuccess()){
                        res = true;
                        System.debug('res@@'+res);
                    }
                    else{
                        logEntryMsg = 'Approval Error: '+pwrList[index]; Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Recal_Exception_Origin'));
                    }
                    index++;
                }    
            }
            
            //Submit closed and missed internal approval activities for ATF Approval
            if(recallPFRId != NULL && recallPFRId.Size() > 0){
                List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
                for(Id pfrId : recallPFRId){
                    Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
                    appObj.setObjectId(pfrId);
                    appObj.setComments('AFT Record submitted by Geo Lead');
                    appRequests.add(appObj);
                }
                
                if(appRequests != NULL && appRequests.size()> 0){
                    Approval.ProcessResult[] result = Approval.process(appRequests); 
                    System.debug('Success');
                }
            }
        }
        catch(exception ex){
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(ex);Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Activity_Recal_Exception_Origin'));         
        }         
        //return res;
    }//End of execute method
}