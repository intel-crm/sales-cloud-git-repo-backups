/**
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 * Class Name      : CRM_AI_Opportunity_Integration
 * Author          : <YourName>
 * Created Date    : Nov 26, 2026
 * Last Modified By: <YourName>
 * Last Modified On: Nov 26, 2026
 * Description     : This class implements for......
 *  
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Nov 26, 2026  │ <YourName>   │ Initial version
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 */

public class CRM_AI_Opportunity_Integration {

	/***********************************************************************************************************
    Method Name:        updateOpportunityAIStatus
    Description:        Update AI Status to 'In Progress'
    @Added By:          Aswin Selvaraj - 26-11-2026
    Modified By:        Date:       Changes:
    ************************************************************************************************************/
    @AuraEnabled
    public static void updateOpportunityAIStatus(List<Id> oppyIds) {
        List<Opportunity> oppyToUpdate = new List<Opportunity>();
    	
        for(Id opporId : oppyIds) {
            if(opporId != null) {
                Opportunity oppRec = new Opportunity(Id = opporId);
                oppRec.CRM_AI_Status__c = 'In Progress';
                oppyToUpdate.add(oppRec);
            }
        }
        
        if(!oppyToUpdate.isEmpty()) {
            Database.SaveResult[] saveResultList= Database.update(oppyToUpdate);
        }
            
      }

}