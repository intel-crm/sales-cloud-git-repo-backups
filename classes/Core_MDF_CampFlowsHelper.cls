/****************************************************************************************************************************************
* Class Name  : Core_MDF_CampFlowsHelper
* Version     : 1.0 
* Created Date: 11-Nov-2022
* Modification Log :
* Developer   SV                  Date         Description
*****************************************************************************************************************************************/

public class Core_MDF_CampFlowsHelper {
    
     /***************************************************************************************************** 
Method Name   :        updateIPAcomments
@return       :        void
@parameters   :        List of Campaign record 
Description   :        update the Approval comments from Approval step to camapign record field
Added By      :        VS 
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    
    public static void updateIPAcomments(List<campaign> camp){
        try{
            system.debug('record details --'+camp);
            If(!camp.isEmpty())
                Core_MDF_CampaignServiceHandler.updateIpaL1ApproverComments(camp);
        }catch (System.DmlException e) {
            Core_MDF_CCP_UtilityClass.logError(e); 
        } 
        
    }
    
     /***************************************************************************************************** 
Method Name   :        reSubmitApprovalProcess
@return       :        void
@parameters   :        List of sObject record , Approval process name , submitter and Comments 
Description   :        submit for Approval process
Added By      :        VS 
Modified By   :        Date:       		Changes: 
******************************************************************************************************/
    Public static void reSubmitApprovalProcess(List<sObject> camp,string approvalProcessName,string submitterID, string comments){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        for (sObject camDetails: camp) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval ');
            req1.setObjectId(camDetails.id);
            req1.setProcessDefinitionNameOrId(approvalProcessName);
            req1.setSubmitterId(approvalProcessName);
            requests.add(req1);
        }
        
        Approval.ProcessResult[] processResults = null;
        try {
            processResults = Approval.process(requests, true);
        }catch (System.DmlException e) {
            Core_MDF_CCP_UtilityClass.logError(e); 
        } 
    }
    
}