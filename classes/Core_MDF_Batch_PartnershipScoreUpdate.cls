/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_PartnershipScoreUpdate 
* Version     : 1.0    
* Created Date: 02-22-2022
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Manjula      02/22/2022      This batch Updates Partnership score if it is null
*************************************************************************************************************************************/
public class Core_MDF_Batch_PartnershipScoreUpdate implements Database.Batchable<sobject>{

    public Database.Querylocator start (Database.BatchableContext bContext) {
        String strQuery = '';
        //querying the Partnership Score records
        strQuery = 'SELECT Id, Core_MDF_Partnership_Score_Nbr__c, Core_MDF_Aggregate_Claim_Score_Nbr__c From Core_MDF_Partnership_Score__c WHERE Core_MDF_Partnership_Score_Nbr__c = null';
        return Database.getQueryLocator(strQuery);  
    }
    public void execute (Database.BatchableContext bContext, List<Core_MDF_Partnership_Score__c> partnerScoreList) {
        List<Core_MDF_Partnership_Score__c> scoreToUpdate = new List<Core_MDF_Partnership_Score__c>();
        String logEntryMsg = '';
        try{
            for (Core_MDF_Partnership_Score__c partnerScoreObj: partnerScoreList) {
                if(partnerScoreObj.Core_MDF_Aggregate_Claim_Score_Nbr__c !=null && partnerScoreObj.Core_MDF_Aggregate_Claim_Score_Nbr__c > 0){
                    //populate the score from claim's aggregate score
                    partnerScoreObj.Core_MDF_Partnership_Score_Nbr__c=partnerScoreObj.Core_MDF_Aggregate_Claim_Score_Nbr__c;
                    scoreToUpdate.add(partnerScoreObj);
                }
            }
            if (scoreToUpdate.size()>0 && scoreToUpdate!=null){
                database.update(scoreToUpdate);
            }
        }catch (Exception exce) {
            logEntryMsg = Core_MDF_CCP_UtilityClass.getErrorDetails(exce);
        }
        finally
            {           
                if(logEntryMsg!=Null && logEntryMsg!=''){
                    Core_MDF_CCP_UtilityClass.logErrorinLogObject(logEntryMsg,'Core_MDF_Batch_PartnershipScoreUpdate');
                }
            }
    }
    public void finish(Database.BatchableContext bContext) {
        
    }
}