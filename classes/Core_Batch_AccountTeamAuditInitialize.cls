global class Core_Batch_AccountTeamAuditInitialize implements Database.Batchable<sObject>,Database.Stateful {
    global Core_Batch_Processing__c batchProcessing;
    global integer count = 0;
    global Integer batchSize = 0;
    Map<String,Core_ACM_Control_Execution__c> mapAcmClassCheckToEol = Core_ACM_Control_Execution__c.getAll();
    global Database.QueryLocator start(Database.BatchableContext BC) {
        batchProcessing = new Core_Batch_Processing__c();
        if(mapAcmClassCheckToEol.containsKey('AccountTeamAuditInitialize') && mapAcmClassCheckToEol.get('AccountTeamAuditInitialize').IsActive__c) {
            Core_Batch_header__c header=AccountTeamBatchHandler.getHeader('Core_Batch_AccountTeamAuditInitialize');
            
            try{
                String query = 'select ID, Core_Account_Team_Audit_Complete__c from Account where Core_Account_Team_Audit_Complete__c = false or Core_Account_Team_Audit_Due_Date__c != null';
                
                batchProcessing.Batch_Header__C = header.id;
                batchProcessing.Core_Email_Distribution_List__c = header.Email_Distribution_List__c;
                batchProcessing.Core_Salesforce_Job_Id__c = BC.getJobId();
                batchProcessing.Core_Batch_Query__c = query;            
                batchProcessing.Core_Object_Name__c = 'Account';
                batchProcessing.Core_Start_Date_Time__c = System.Now();
                insert batchProcessing;
                
                return Database.getQuerylocator(query);
            }catch(Exception e){
                batchProcessing.Core_Exception_Log__c = e.getMessage();
                insert batchProcessing;
                return null;
            }
        }
        else
        {
            
            return Database.getQuerylocator('');    
        }
    }
    global void execute(Database.BatchableContext BC, List<Account> scope) {
         try{
            if(scope.size() > batchSize)
                batchSize = scope.size();
            for(Account acc: scope){
                acc.Core_Account_Team_Audit_Complete__c = true; 
                acc.Core_Account_Team_Audit_Due_Date__c = null;
                count++;
            }
            update scope;
        }
        catch(Exception e){
            batchProcessing.Core_Exception_Log__c = e.getMessage();
            update batchProcessing;
        }
    }
    global void finish(Database.BatchableContext BC) {
        if(mapAcmClassCheckToEol.containsKey('AccountTeamAuditInitialize') && mapAcmClassCheckToEol.get('AccountTeamAuditInitialize').IsActive__c) {
            batchProcessing.Core_Total_Number_of_Records__c = count;
            batchProcessing.Core_End_Date_Time__c = System.Now();
            batchProcessing.Core_Batch_Size__c = batchSize;        
            batchProcessing.Core_Send_Email__c = true;        
            update batchProcessing;
        }
    }
}