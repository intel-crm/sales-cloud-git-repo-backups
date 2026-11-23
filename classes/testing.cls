public class testing {
      
   public static void createTicketOnExcpetion(String OrderNumber , String errorMsg){
	Order order = [SELECT Id, OrderNumber, CreatedById, CreatedBy.Email, AccountId, Account.Name FROM Order WHERE OrderNumber =: OrderNumber LIMIT 1 ];
		Sales_ITL3_Supp3_Support_Ticket__mdt ticket=[ select id,caller_id__c, business_service__c, service_offering__c, short_description__c, impact__c, urgency__c, assignment_group__c from Sales_ITL3_Supp3_Support_Ticket__mdt Limit 1];
		 IncidentInfo IncidentInfoWrapper = new IncidentInfo();
		 IncidentInfoWrapper.caller_id=ticket.caller_id__c;
		 IncidentInfoWrapper.business_service=ticket.business_service__c;
		 IncidentInfoWrapper.service_offering=ticket.service_offering__c;
		 IncidentInfoWrapper.short_description=ticket.short_description__c;
		 IncidentInfoWrapper.description=errorMsg;
		 IncidentInfoWrapper.urgency=ticket.urgency__c;
		 IncidentInfoWrapper.impact=ticket.impact__c;
		 IncidentInfoWrapper.assignment_group=ticket.assignment_group__c;
		 
			//setAccessToken();
            //System.debug('##'+accessToken);
           // Http http = new Http();
            String payLoad = JSON.serialize(IncidentInfoWrapper);
			system.debug('payload'+payLoad);
       
       

  
   }
          public class IncidentInfo{
		 public String caller_id;
		 public String business_service;
		 public String service_offering;
		 public String short_description;
		 public String description;
		 public String urgency;
		 public String impact;
	     public String assignment_group;
		 }
     public class Request {
        @InvocableVariable(
            label = 'Label of my input variable'
            description = 'Tooltip for this input variable'
            required = true
        )
        public string orderNo;

    }
}