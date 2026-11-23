trigger RestrictPendingStatusUpdate on OpportunityLineItem (before update) {
   /*for (OpportunityLineItem oli : Trigger.new) {
       OpportunityLineItem oldOli = Trigger.oldMap.get(oli.Id);

       // Check if status is being changed to "Pending" from "Win Approved"
       if (oldOli.Core_Status__c == 'Win Approved' && oli.Core_Status__c == 'Pending') {
           oli.addError('You are not allowed to manually update Opportunity Line Item status to "Pending" from "Win Approved".');
       }
   }*/
}