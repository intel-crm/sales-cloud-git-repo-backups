/************************************************************************************************************************************************************************************
* Class Name  : Core_MDF_CampScheduleFromFlows 
* Version     : 1.0 
* Created Date: 01-11-2022
* Modification Log :
* Developer                     Date                          Description
* --------------------------------------------------------------------------------------------------------------------------------------------------
* Intel - SV				 01-11-2022				  Schedle class for Email trigger / Resubmitting Approval process
****************************************************************************************************************************************/
global class Core_MDF_CampScheduleFromFlows implements Schedulable {
    
   public InitialInputs inputParm;
    
    public Core_MDF_CampScheduleFromFlows(InitialInputs parm){
        inputParm = parm;
    }
    
    global void execute(SchedulableContext SC) {
        if(inputParm.condition == 'IPACommentsUpdate'){
            List <Campaign> campList = new List<Campaign>();
            campList.add(inputParm.camp);            
            Core_MDF_CampaignServiceHandler.updateIpaL1ApproverComments(campList);            
        }        
        if(inputParm.condition == 'ResubmitApprovalProcess' ){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Re-submitting request for approval.');
            req1.setObjectId(inputParm.camp.id);
            req1.setSubmitterId(inputParm.submitterID);             
            // Submit the record to specific process
            req1.setProcessDefinitionNameOrId(inputParm.approvalProcessName);            
            // Submit the approval request for the Campaign
            Approval.ProcessResult result = Approval.process(req1);
        }
            
    }
    
    //Update IPA comments or Resubmit Approval process
    @InvocableMethod(label='IPA comments or Resubmit Approval')
    public static void updateIpaL1Comments(List<initialInputs> processInput) {
        Datetime next = System.now().addSeconds(Integer.valueOf(120));
        String schedule = next.format('ss mm HH dd MM ? yyyy');
        
        system.debug('-schedule-'+schedule);    
        for(initialInputs inputs : processInput){
            Core_MDF_CampScheduleFromFlows SJ= new Core_MDF_CampScheduleFromFlows(inputs); 
            System.schedule('IPA comments or Resubmit Approval'+schedule+inputs.condition + inputs.camp.id, schedule, SJ);
        }
    }
    
/***************************************************************************************************** 
*Class Name    :        Core_MDF_CampScheduleFromFlows
*Description   :        contains all the invocable variables
*Modified By   :        Date:       Changes: 
******************************************************************************************************/
    public class InitialInputs{        
        @InvocableVariable(label = 'camp')
        public Campaign camp;
        
        @InvocableVariable(label = 'condition')
        public string condition;
        
        @InvocableVariable(label = 'approvalProcessName')
        public string approvalProcessName;
        
        @InvocableVariable(label = 'submitterID')
        public string submitterID;
    }
}