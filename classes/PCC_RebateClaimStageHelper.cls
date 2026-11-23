/****************************************************************************************************
Apex Class Name : PCC_RebateClaimStageHelper
Version         : 1.0 
Created Date    : 06/Jun/2024
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pranjal Rajput                    06/Jun/2024               Created
*****************************************************************************************************/

public class PCC_RebateClaimStageHelper {
    /*************************************************************************************
    * Method Name : updateTPTRecords
    * Description : This method is used to update the TPT Tracker records
    **************************************************************************************/
    public static void updateTPTRecords(List<PCC_Rebate_Claim_Stage__c > newList,map<Id,PCC_Rebate_Claim_Stage__c> oldMap){
        if (!newList.isEmpty()) {
            List<PCC_Rebate_Claim_Stage__c> headerRecords = new List<PCC_Rebate_Claim_Stage__c>();
            Id recTypeParentId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Header').getRecordTypeId();
            for(PCC_Rebate_Claim_Stage__c rec : newList){
                if(rec.RecordTypeId == recTypeParentId){
                    headerRecords.add(rec);
                }
            }
            if (!headerRecords.isEmpty()) {
                    TPT_Tracker.updateTPTTracker(headerRecords, oldMap);
            }
        }
    }
}