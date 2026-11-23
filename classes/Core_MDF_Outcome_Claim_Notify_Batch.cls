global class Core_MDF_Outcome_Claim_Notify_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    global static Database.QueryLocator start(Database.BatchableContext context) {
        String programName = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name');
        String status = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Pending_Acct_Mgr_Clarification');

        String query = 'SELECT Id '
                        + 'FROM PartnerFundClaim '
                        + 'WHERE Core_MDF_Program__c = \'' + programName + '\' ' 
                        + 'AND Core_MDF_Status__c = \'' + status + '\' ' 
                        + 'AND Core_MDF_OutcomeBased_Ind__c = true'; 
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimObj) {
    	system.debug('@@@claimObj'+claimObj);
    	List<Id> claimIds = new List<Id>();
    	for(PartnerFundClaim claim : claimObj) {
            claimIds.add(claim.Id);
    	}
    	try {
        if (claimIds != null && !claimIds.isEmpty()) {
                List<PartnerFundClaimHistory> claimHistoryList = [
                    SELECT PartnerFundClaimId, CreatedDate
                    FROM PartnerFundClaimHistory 
                    WHERE PartnerFundClaimId IN :claimIds 
                    AND Field = 'Core_MDF_Status__c'
                    ORDER BY CreatedDate DESC limit 1
                ];
                Date today = System.today();
                system.debug('@@@today: '+today);
                List<Id> eligibleClaimIds = new List<Id>();
                
                for(PartnerFundClaimHistory history : claimHistoryList) {
                Date createdDateOnly = history.CreatedDate.date();
                system.debug('@@@createdDateOnly: '+createdDateOnly); 
                // Calculate business days difference excluding weekends
                Integer businessDaysDifference = calculateBusinessDaysDifference(today, createdDateOnly);
                system.debug('@@@businessDaysDifference: '+businessDaysDifference);  
                Integer modResult = Math.mod(Math.abs(businessDaysDifference), 5);
                system.debug('@@@modResult: '+modResult);   
                    if(modResult == 0) {
                        eligibleClaimIds.add(history.PartnerFundClaimId); 
                        system.debug('@@@Eligible Claim ID: ' + history.PartnerFundClaimId + ', Days Difference: ' + businessDaysDifference + ', MOD Result: ' + modResult+ ', createdDateOnly: '+createdDateOnly);
                    }
                }
            
            system.debug('@@@eligibleClaimIds (no duplicates): ' + eligibleClaimIds);
            system.debug('@@@Total eligible claims: ' + eligibleClaimIds.size());
            //Core_MDF_PIC_SendEmailToClaimOwner.sendEmailtoClaimOwnerOnResubReqd(claimIds);
        }
        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }
    
    global void finish(Database.BatchableContext context) {

    }
    private Integer calculateBusinessDaysDifference(Date todayDate, Date createdDate) {
    // Base date reference (January 8, 1900 was a Monday)
    Date baseDate = Date.newInstance(1900, 1, 8);
    
    // Calculate total days difference
    Integer totalDaysDifference = todayDate.daysBetween(createdDate);
    
    // Calculate number of weekend days to subtract
    Integer todayWeeksFromBase = Math.floor((todayDate.daysBetween(baseDate)) / 7.0).intValue();
    Integer createdWeeksFromBase = Math.floor((createdDate.daysBetween(baseDate)) / 7.0).intValue();
    Integer weekendDays = 2 * (todayWeeksFromBase - createdWeeksFromBase);
    
    // Get day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
    DateTime todayDateTime = DateTime.newInstance(todayDate, Time.newInstance(0, 0, 0, 0));
    DateTime createdDateTime = DateTime.newInstance(createdDate, Time.newInstance(0, 0, 0, 0));
    
    String todayDayOfWeek = todayDateTime.format('u'); // 1=Monday, 7=Sunday
    String createdDayOfWeek = createdDateTime.format('u');
    
    Integer todayWeekday = Integer.valueOf(todayDayOfWeek);
    Integer createdWeekday = Integer.valueOf(createdDayOfWeek);
    
    // Adjust for weekend days
    // If today is weekend (Saturday=6 or Sunday=7), subtract 1
    if (todayWeekday == 6 || todayWeekday == 7) {
        weekendDays += 1;
    }
    
    // If created date is weekend (Saturday=6 or Sunday=7), add 1
    if (createdWeekday == 6 || createdWeekday == 7) {
        weekendDays -= 1;
    }
    
    // Calculate business days
    Integer businessDays = totalDaysDifference - weekendDays;
    
    return businessDays;
}
}