public class CRM_Batch_OppCalculateBaseCommitRevenue implements Database.Batchable<SObject>
	{
    	public String query;
    	Date startDate;
    	Date endDate;
    	Date fourteenDaysAfterStartDate;

		public CRM_Batch_OppCalculateBaseCommitRevenue()
		{
			startDate = getQuarterStartDate(System.today());
			endDate = getQuarterEndDate(System.today());
			fourteenDaysAfterStartDate = startDate.addDays(14);
            
            system.debug('startDate from batch class--'+startDate);
            system.debug('endDate from batch class--'+endDate);
            system.debug('fourteenDaysAfterStartDate from batch class--'+fourteenDaysAfterStartDate);

			query = 'SELECT Id, Name, CloseDate, StageName, Amount, CRM_Base_Commit_Revenue__c FROM Opportunity ' +
					'WHERE CloseDate >= :startDate AND CloseDate <= :endDate AND StageName IN (\'Qualify\',\'Define\',\'Develop\',\'Design\')';
		}
		
		public Iterable<SObject> start(Database.BatchableContext bc)
		{
			return Database.getQueryLocator(query);
		}
		
		public void execute(Database.BatchableContext bc, List<SObject> scope)
		{
			List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
			for (SObject s : scope)
            {
				Opportunity opp = (Opportunity) s;
				if (System.today() == fourteenDaysAfterStartDate)
                {
					opp.CRM_Base_Commit_Revenue__c = opp.Amount;
					opportunitiesToUpdate.add(opp);
				}
				else if (System.today() == endDate)
                {
					if (opp.CRM_Base_Commit_Revenue__c != null && opp.CRM_Base_Commit_Revenue__c != 0)
                    {
						Decimal percent = (opp.Amount / opp.CRM_Base_Commit_Revenue__c) * 100;
						opp.CRM_Current_To_Base_Commit_Percent__c = percent;
					}
					opportunitiesToUpdate.add(opp);
				}
			}

			if (!opportunitiesToUpdate.isEmpty())
            {
				try
                {
					update opportunitiesToUpdate;
				} 
				catch (DmlException e)
                {
					System.debug('Error updating Opportunities: ' + e.getMessage());
				}
			}
		}
		
		public void finish(Database.BatchableContext bc)
		{
			System.debug('Batch process finished.');
		}
		
		public static Date getQuarterStartDate(Date currentDate)
		{
			Integer quarter = ((currentDate.month() - 1) / 3) + 1;  
            //current month is Jan so (((1-1)/3)+1) = 1 = quarter 1. For Jan/Feb/March - this will return 1 always - Q1.
            //Will calculate accordingly for other months too
			Integer startMonth = (quarter - 1) * 3 + 1;
            //calculate starting month based on qtr no. For June - Qtr is 2 - ((((2-1)*3))+1) = 4 = April - Start month for Qtr
			return Date.newInstance(currentDate.year(), startMonth, 1);
		}
		
		public static Date getQuarterEndDate(Date currentDate)
		{
			Integer quarter = (currentDate.month() - 1) / 3 + 1;
            //current month is Jan so (((1-1)/3)+1) = 1 = quarter 1. For Jan/Feb/March - this will return 1 - Q1.
            //Will calculate accordingly for other months too
			Integer endMonth = quarter * 3;
            //for Jan, endmonth will be 1*3 = 3 = March
			Date endDate = Date.newInstance(currentDate.year(), endMonth, 1).addMonths(1).addDays(-1);
            //to get enddate, it will return (2024,3,1)- 1 March 2024 - addMonths(1) - 1 April - addDays(-1) - 31 March
			return endDate;
		}
	}