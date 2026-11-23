global without sharing class Core_MDF_Batch_Partnership_Score_Detail implements Database.Batchable<sObject>, Database.Stateful {
    string query='';
    string sendEmailAddress = '';
    string message='';
    global string returnMessage ='';
    private String prevQtr;
    public string program;
    public string accountIds;
    public Boolean notifyRecoveryAdmin=false;
    public Boolean dataProcessed = false;
    public Map<String,String> programToExecutionDateMap;
    public Core_MDF_Batch_Partnership_Score_Detail(String prevQtr) {
        this.prevQtr = prevQtr;
    }
    public Core_MDF_Batch_Partnership_Score_Detail(string pgm, String prevQtr,string accounts) {
        this.program = pgm;
        this.prevQtr = prevQtr;
        this.accountIds = accounts;
    }
    public Core_MDF_Batch_Partnership_Score_Detail(string pgm, String prevQtr,string accounts,Boolean notifyRecoveryAdmin) {
        this.program = pgm;
        this.prevQtr = prevQtr;
        this.accountIds = accounts;
        this.notifyRecoveryAdmin = notifyRecoveryAdmin;
        this.programToExecutionDateMap = programToExecutionDateMap;
    }
  	global Database.queryLocator start(Database.BatchableContext bc)
    {
          String query1 = 'select id,Name,Core_MDF_Program_nm__c,Core_MDF_Channel_Program_Id__c, Core_MDF_Channel_Program_Id__r.Name, Core_MDF_Account_Id__r.Name,Core_MDF_Zone_nm__c,Core_MDF_Quarter_Year_Nm__c,Core_MDF_Partnership_Grade_Nbr__c,Core_MDF_Partnership_Score_Id__c, Core_MDF_Virtual_Corp_Account_Id__c from Core_MDF_Partnership_Score__c where Core_MDF_Zone_nm__c!=null ';
        String query2 = '';
        if(!String.isBlank(program)){
            query2 = 'and Core_MDF_Channel_Program_Id__r.Name =: program ';
        }
        if(!String.isBlank(accountIds)){
            List<Id> accountIdList = accountIds.split(',');
            query2 += 'and Core_MDF_Account_Id__c IN :accountIdList ';
        }
        if(!String.isBlank(prevQtr)){
            query2 += 'and Core_MDF_Quarter_Year_Nm__c=:prevQtr ';
        }
        
         String param = 'Core_MDF_pull_data_from_IAH';
         return Database.getQueryLocator(query1+query2);
        
       
    }
	global void execute(Database.BatchableContext batchableContext, List<Core_MDF_Partnership_Score__c> scope)
    {
        try{
            
       	    Core_MDF_PartnerShipScore_to_Detail.Executedata(scope,program,prevQtr,accountIds);            
               dataProcessed = true;
        }
        catch(Exception ex)
        {
           
            returnMessage += ex.getMessage();
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        sendEmailAddress = Label.Core_MDF_CCP_Support_Email;               
        
        if(sendEmailAddress != null && sendEmailAddress != '')
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {sendEmailAddress};
                mail.setToAddresses(toAddresses);
                mail.setSubject(Label.Core_MDF_SFDC_Environment + ': Salesforce Core_MDF_Batch_Partnership_Score_Detail Insertion child Job ');
                mail.setHtmlBody(returnMessage);
        		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});                
            }
        
        if(notifyRecoveryAdmin && dataProcessed){
            String psTProgramMapStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Recovery_Admin_Program_Mapping');
            List<String> psNameList = new List<String>();
            String intActManagersPrgToPSMappingStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Int_Acc_Mangr_Program_To_PS_Map');
            String psNamesToExcludeForEmailStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PS_To_Exclude_Int_Acc_Man_Email');
            List<String> internalActManagersPSList = new List<String>();
            List<String> psNamesToExcludeForEmail = new List<String>();
            Set<String> programNamesSet = new Set<String>();
            List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
            String quarterAndYear = qtr[1];
            
            if(psNamesToExcludeForEmailStr != null && psNamesToExcludeForEmailStr != ''){
                psNamesToExcludeForEmail = psNamesToExcludeForEmailStr.split(',');
            }
            
            for(string psToProgram : psTProgramMapStr.split(',')){
                List<string> record = psToProgram.split(':');
                psNameList.add(record[0]);
            }
            String pgmToExecDateStr = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Program_Recovery_Date_Mapping');
            Map<String,String> pgmToExecDateMap = new Map<String,String>();
            for(string pgmToExecDate : pgmToExecDateStr.split(',')){
                List<string> record = pgmToExecDate.split(':');
                pgmToExecDateMap.put(record[0],record[1]);
            }
            
            for(String psToProgram : intActManagersPrgToPSMappingStr.split(',')){
                List<string> record = psToProgram.split(':');
                internalActManagersPSList.add(record[0]);
                programNamesSet.add(record[1]);
            }
            List<Core_MDF_Partnership_Score_Detail__c> psdList = [SELECT Id, Core_MDF_Partnership_Score_Id__c, Core_MDF_Partnership_Score_Id__r.Core_MDF_Account_Id__c, Core_MDF_Account_Id__c, Core_MDF_Program_Nm__c, Core_MDF_Node_Account_Id__c, Core_MDF_Node_Account_Id__r.Name, Core_MDF_Partnership_Score_Id__r.Core_MDF_Channel_Program_Id__c
                                                                    FROM Core_MDF_Partnership_Score_Detail__c
                                                                    WHERE Core_MDF_Balance_Amount_Amt__c > 0 AND Core_MDF_Quarter_Year_Nm__c =: quarterAndYear];
            
            Core_MDF_Recovery_Utility.notifyRecoveryAdmin(psNameList, pgmToExecDateMap, psdList);
            Core_MDF_Recovery_Utility.sendRecoveryDashboardNotification(psNameList, prevQtr, psdList);

            if(!Core_MDF_Utility.byPassFeature('Core_MDF_Recovery_AccMngrNotification')){
                Core_MDF_Recovery_Utility.notifyInternalActManagersOnRecoveryDataLoad(internalActManagersPSList, psNamesToExcludeForEmail, pgmToExecDateMap, programNamesSet, psdList, 'RecoveryIntAccMngrNotification', true);
            }
        }
    }  
}