public without sharing class UnshareOpptyWithAcc_SalesGroup {
@InvocableMethod( label='Unshare Oppotunities on Account Changes')    
    public static void ShareUnshareOpptyAccChanges(List<id> Accountid){
        System.debug('Line 4: Apex Class is called');
        Set<Id> fedCRMOppid = new Set<Id>();

        //Get the FED CRM Group id
		 Id groupId = [SELECT id FROM Group where DeveloperName  =: 'Core_Fed_CRM_Group'][0].Id;
         List<OpportunityShare> sharesToInsert  = new List<OpportunityShare>();
         OpportunityShare oppRoleShr;
         List<Opportunity> OppidUnshare = [select id from Opportunity where Account.id IN:Accountid and Core_Sales_Groups__c!=:'Americas US Sales Group'];
         List<Opportunity> Oppidshare = [select id from Opportunity where Account.id IN:Accountid and Core_Sales_Groups__c=:'Americas US Sales Group'];
         if (OppidUnshare.size()>0)
         {
          List<OpportunityShare> fedCRMShare = [SELECT Id FROM OpportunityShare WHERE Opportunity.id IN: OppidUnshare and UserOrGroupId =:groupId];
		  Database.DeleteResult[] deleteResults = Database.delete( fedCRMShare, true );  

         }
         if(Oppidshare.size()>0)
         {
             system.debug('line 21'+Oppidshare);
             for(Opportunity key : Oppidshare){
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