public class CoreBatchFedCRMShare {
    public static void BatchInsertOppShare(){
    List<OpportunityShare> sharesToInsert  = new List<OpportunityShare>();
    OpportunityShare oppRoleShr;
    Id groupId = [SELECT id FROM Group where DeveloperName  =: 'Core_Fed_CRM_Group'][0].Id;
    List<opportunity> Oppid = [select id from opportunity where Core_Sales_Groups__c like 'Americas US Sales Group' and StageName not in ('Cancelled', 'Lost','Production Win','Design Win', 'Production Cancelled', 'Group Closed', 'Group Cancelled')];
    
    if(Oppid.size()>0)
    {
         system.debug('line 21'+Oppid.size());
             for(Opportunity key : Oppid)
             {
                oppRoleShr = new OpportunityShare();
                oppRoleShr.OpportunityId = key.id; 
                oppRoleShr.UserOrGroupId = groupId;
                oppRoleShr.OpportunityAccessLevel = 'Read'; 
                oppRoleShr.RowCause = 'Manual';  
                sharesToInsert.add(oppRoleShr);
            }
		 Database.SaveResult[] lsr = Database.insert(sharesToInsert,false);
    	}
      }
}