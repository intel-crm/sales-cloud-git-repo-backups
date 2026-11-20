@isTest
private class Core_IPS_AccountTeamBatchHandler_Test {
	
    static testmethod void TestAccountTeamBatchHandler() {
        
        Core_Batch_Header__c objBH = new Core_Batch_Header__c(Name='Test');
        insert objBH;
        
        Core_Batch_Processing__c objBP = new Core_Batch_Processing__c(Name='Test Processing', Batch_Header__c=objBH.Id ,Core_Start_Date_Time__c=DateTime.now().addDays(-1));
        insert objBP;
        AccountTeamBatchHandler.getHeader('Test');
        AccountTeamBatchHandler.getLastRunDateTime('Test');
        objBH.Last_Run_Date_Time__c = DateTime.Now().addDays(-1);
        update objBH;
        AccountTeamBatchHandler.getLastRunDateTime('Test');
        
        
    }
    
}