public class Core_MDF_Approve_Record implements Queueable{
    public Set<Id> apprvlId = new Set<Id>();
    public Core_MDF_Approve_Record(Set<Id> apprvlId){
   		this.apprvlId = apprvlId;     
    }
    
    public void execute(QueueableContext context) {
    //public static void approveRecordsInApproval(Set<Id> apprvlId){
        
        
                List<Approval.ProcessWorkitemRequest> pwrList = new List<Approval.ProcessWorkitemRequest>(); 
                for(ProcessInstanceWorkItem piwitm : [SELECT ProcessInstance.TargetObjectId, Id 
                                                  FROM ProcessInstanceWorkItem
                                                  WHERE ProcessInstance.Status = 'Pending' AND
                                                      ProcessInstance.TargetObjectId IN:apprvlId limit 1]){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();                  
                    System.debug('NZ-->: '+piwitm);
                    //req.setAction('Approve');    
                    req.setAction('Removed'); 
                    req.setWorkitemId(piwitm.Id);
                    req.setComments('Record is approved by After The Fact');
                    pwrList.add(req);
                }    
                
                if(pwrList != NULL && pwrList.Size() > 0){
                   List<Approval.ProcessResult> result = Approval.process(pwrList);
                }
        
        		DateTime start = System.Now();
        		while(System.Now().getTime()< start.getTime()+2000){}
        	
        List<Approval.ProcessSubmitRequest> appRequests = new List<Approval.ProcessSubmitRequest> ();
        for(Id apprId:apprvlId){
        	Approval.ProcessSubmitRequest appObj = new Approval.ProcessSubmitRequest();
            appObj.setObjectId(apprId);  
             appObj.setComments('Record submitted by After The Fact');
            appObj.setProcessDefinitionNameOrId('Core_MDF_Activity_Approval_MultiLvl_V5');
              appRequests.add(appObj);
           
        }  
        if (appRequests.size()> 0){
            Approval.ProcessResult[] result = Approval.process(appRequests);
        }
        
    }

}