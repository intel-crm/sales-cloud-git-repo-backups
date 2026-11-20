/****************************************************************************************************************************************
* Trigger Name  : Core_MDF_Claim_Prediction_Subscribe
* Test Class : Core_MDF_Claim_Prediction_Subscribe_Test 
* Version     : 1.0 
* Created Date: 15-06-2020
* Modification Log :
* Developer               Date                          Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel-NK              15/06/2020                    Created Core_MDF_Claim_Prediction_Subscribe - Subscribe trigger for Platform Event
*****************************************************************************************************************************************/


trigger Core_MDF_Claim_Prediction_Subscribe on Core_MDF_Claim_Prediction_Event__e (after insert) {
    
    public static boolean runOnce = true;
    
    public class CustomException extends Exception{}
    List <Core_MDF_Claim_Prediction__c> obj = new List <Core_MDF_Claim_Prediction__c>();
    try{
    
        List<Id> claimIds = new List<Id>();
        Set<Id> cId = new Set<Id>();
        for (Core_MDF_Claim_Prediction_Event__e evt: trigger.new){
            claimIds.add(evt.Core_MDF_PE_ID__c);
            
        } 
        
        Map<Id,Decimal> claimIdtoPICcycleMap = new Map<Id, Decimal>();
        for(Core_MDF_PIC_Review__c claim : [Select id, Core_MDF_Claim_ID_id__c, Core_MDF_CycleNumber_nbr__c from Core_MDF_PIC_Review__c where Core_MDF_Review_Status_nm__c = 'Completed' and Core_MDF_Claim_ID_id__c in : claimIds]){
            claimIdtoPICcycleMap.put(claim.Core_MDF_Claim_ID_id__c,claim.Core_MDF_CycleNumber_nbr__c);
        }
        
        List<Core_MDF_Claim_Prediction__c> cpList = [select id,Core_MDF_Claim_id__c,Core_MDF_Activity_ID__c,Core_MDF_Claim_Id_External_id__c from Core_MDF_Claim_Prediction__c where Core_MDF_Claim_id__c in : claimIds];               
        Map<Id,PartnerFundClaim> claimMap = new Map<Id,PartnerFundClaim>([Select Id, Core_MDF_Brand_Nm__c From PartnerFundClaim where id in :claimIds]);
        for(Core_MDF_Claim_Prediction__c cp:cpList){
            cId.add(cp.Core_MDF_Claim_id__c);
        }               
        for (Core_MDF_Claim_Prediction_Event__e evt: trigger.new)
        {
            if(evt.Core_MDF_PE_ID__c!=NULL && !cId.contains(evt.Core_MDF_PE_ID__c))
                obj.add(new Core_MDF_Claim_Prediction__c(Core_MDF_Claim_id__c=evt.Core_MDF_PE_ID__c,Core_MDF_ClaimBrand_nm__c=claimMap.get(evt.Core_MDF_PE_ID__c).Core_MDF_Brand_Nm__c, Core_MDF_Activity_ID__c=evt.Core_MDF_Activity_ID__c, Core_MDF_Claim_Id_External_id__c = evt.Core_MDF_PE_ID__c,Core_MDF_CycleNumber_Nbr__c = claimIdtoPICcycleMap.get(evt.Core_MDF_PE_ID__c)));
        }
        
        if(runOnce){
            Database.SaveResult[] srListUpdate = Database.update(cpList, false);
            Database.SaveResult[] srListInsert = Database.insert(obj, false);
            runOnce = false;   
            
            // Operation failed, so get all errors
            for (Database.SaveResult srIns : srListInsert) {if (!srIns.isSuccess()) 
            {for(Database.Error err : srIns.getErrors()){Throw new CustomException(err.getMessage());}}}
            for (Database.SaveResult srUpd : srListUpdate) {if (!srUpd.isSuccess()) 
            {for(Database.Error err : srUpd.getErrors()){Throw new CustomException(err.getMessage());}}}
        }
    }	
    catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    
}