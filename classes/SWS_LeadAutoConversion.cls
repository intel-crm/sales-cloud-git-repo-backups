public without sharing class SWS_LeadAutoConversion {
    //@InvocableMethod(label='Auto Convert Lead' description='Converts a lead into an existing contact without creating opportunity or account')
    public static void convertLead(List<LeadConvertRequest> requests) {
        List<Database.LeadConvert> conversions = new List<Database.LeadConvert>();
        
        for (LeadConvertRequest req : requests) {
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(req.leadId);
            lc.setContactId(req.contactId);           
            lc.setDoNotCreateOpportunity(true);      // No Opportunity
          //lc.setOverwriteLeadSource(false);        
            lc.setConvertedStatus('Sales Qualified Lead');      
            
            // Use existing Contact's Account if it exists
            Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :req.contactId LIMIT 1];
            if (c.AccountId != null) {
                lc.setAccountId(c.AccountId);
            } else {
               system.debug('Account ID is empty');
            }
            
            conversions.add(lc);
        }

        List<Database.LeadConvertResult> results = Database.convertLead(conversions, false);
        
        for (Database.LeadConvertResult res : results) {
            if (!res.isSuccess()) {
                for (Database.Error err : res.getErrors()) {
                    System.debug('Lead conversion failed: ' + err.getMessage());
                }
            }
        }
    }

    public class LeadConvertRequest {
        @InvocableVariable(required=true)
        public Id leadId;

        @InvocableVariable(required=true)
        public Id contactId;
    }
}