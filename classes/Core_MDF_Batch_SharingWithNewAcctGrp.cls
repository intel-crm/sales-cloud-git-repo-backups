/****************************************************************************************************************************************
* Class Name  : Core_MDF_Batch_SharingWithNewAcctGrp 
* Version     : 1.0 
* Created Date: 25-Aug-2020
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture - Pranav       21-Aug-2020          Generic Batch Class to create Share record of Objects with their New account group
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Batch_SharingWithNewAcctGrp implements Database.Batchable<sObject>
{
	list<Account> accountList = new List<Account>();
    Set<Id> programIdsSet = new Set<Id>();
	List<PartnerMarketingBudget> budgetList = new List<PartnerMarketingBudget>();
    // Map of ultimate Acount and its channel program as key and List of group Ids as value
	Map<String, List<Id>> ultimateAcctIdProgramIdToGroupIdsListMap = new Map<String, List<Id>>();
    // Final Map of object Id and List of Group Ids to share with
    Map<Id, List<Id>> objectIdGroupIdListMap = new Map<Id,List<Id>>();
    // Record Type for comarketing Account
    String comarketingAccount = Label.Core_MDF_Co_Marketing_Record_Type_Name;
    // Ultimate Account Id Set
    Set<Id> ultimateAccountIdsSet = new Set<Id>();
    String budgetEscalationType = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Budget_Escalation_Type');//Budget
    List<Core_MDF_Escalation__c> budgetEscalationList = new List<Core_MDF_Escalation__c>();
	Map<Id, List<Id>> escalationIdToGroupIdListMap = new Map<Id,List<Id>>();
    
    public Core_MDF_Batch_SharingWithNewAcctGrp(List<Account> acctList)
    {
		this.accountList = acctList;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) 
    {
        String query = 'SELECT Id, Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Group_Id__c, Core_MDF_Channel_Program__c from account where ID IN: accountList AND Core_MDF_Parent_Fund_Account__r.Core_Account_Record_Type__c =:comarketingAccount AND Core_Account_Record_Type__c =:comarketingAccount AND Core_MDF_Group_Id__c!=null' ;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc,List<Account> accountsList)
    {
        try{
            if(accountsList != NULL && !accountsList.isEmpty())
            {
                // Iterating over the accounts from the query
                for(Account acc : accountsList)
                {
                    // Set of ultimate Account Id
                    ultimateAccountIdsSet.add(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c);
                    // Set of Program Ids of the account
                    programIdsSet.add(acc.Core_MDF_Channel_Program__c);
                    // Check if account's ultimate account and program is not null 
                    if(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c != NULL && acc.Core_MDF_Channel_Program__c != NULL)
                    {
                        // Making Key for the Map as String - Account's ultimate Accounts Id and Channel Program Id
                        String intelAcctIdProgId = String.valueOf(acc.Core_MDF_Parent_Fund_Account__r.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(acc.Core_MDF_Channel_Program__c);
                        // Creating Map of ultimate Account + channel Program as key and list of Group Ids
                        if(!ultimateAcctIdProgramIdToGroupIdsListMap.containsKey(intelAcctIdProgId))
                        {
                            ultimateAcctIdProgramIdToGroupIdsListMap.put(intelAcctIdProgId, new List<ID> {acc.Core_MDF_Group_Id__c});
                        }
                        else
                        {
                            ultimateAcctIdProgramIdToGroupIdsListMap.get(intelAcctIdProgId).add(acc.Core_MDF_Group_Id__c);
                        }
                    }
                }
               
                
                // Calling createBudgetShareRecords me to share budgets with new Account's Groups
                createBudgetShareRecords();
                // Calling createEscalationShareRecords me to share Escalations with new Account's Groups
                createEscalationShareRecords();
            }
        }
        catch(Exception e){         
            Core_MDF_CCP_UtilityClass.logError(e);
        } 
    }
    
    /***************************************************************************************************** 
    Method Name:        createBudgetShareRecords
    @return  :          void
    @parameters:        
    Description:        Share Budget Records with the new accounts groups
    Added By:           Pranav - 25-08-2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/    
    public void createBudgetShareRecords()
    {
        // Iterating over Budget for ultimateAccountIdsSet and programIdsSet            
        for(PartnerMarketingBudget pmb : [Select Id, Core_MDF_Budget_Partner__c, Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c, Core_MDF_Program__c from PartnerMarketingBudget where Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c IN: ultimateAccountIdsSet AND Core_MDF_Program__c IN: programIdsSet])
        {
            
            // ultimate Account and channel program String Key
            String ultimateAcctProgramKey = String.valueOf(pmb.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(pmb.Core_MDF_Program__c);
            if(ultimateAcctProgramKey != NULL && ultimateAcctIdProgramIdToGroupIdsListMap.containsKey(ultimateAcctProgramKey))
            {
                // Final Map of Object Id and List of groups Ids to share with
                objectIdGroupIdListMap.put(pmb.Id, ultimateAcctIdProgramIdToGroupIdsListMap.get(ultimateAcctProgramKey));
            }
        }
        //Call Core_MDF_GenericShareRecordActionClass to create Share records for object records
        if(objectIdGroupIdListMap != NULL && !objectIdGroupIdListMap.isEmpty()){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('PartnerMarketingBudget', objectIdGroupIdListMap, 'Edit', 'Manual');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        
    }
    
    /***************************************************************************************************** 
    Method Name:        createEscalationShareRecords
    @return  :          void
    @parameters:        
    Description:        Share Escalation Records with the new accounts groups
    Added By:           Varun - 25-08-2020
    Modified By:        Date:       Changes: 
    ******************************************************************************************************/    
    public void createEscalationShareRecords()
    {
        //Get budget escalation records and prepare Map of escalation Id to the list of group Ids with which the esc has to be shared
        for(Core_MDF_Escalation__c esc : [SELECT Id, Core_MDF_Escalation_Type_nm__c, Core_MDF_Budget_ID_Number_id__c, 
                                          Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c,
                                          Core_MDF_Channel_Program_id__c
                                          FROM Core_MDF_Escalation__c
                                          WHERE Core_MDF_Escalation_Type_nm__c =: budgetEscalationType AND
                                          Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c 
                                          IN: ultimateAccountIdsSet AND Core_MDF_Channel_Program_id__c IN: programIdsSet]){
                                              escalationIdToGroupIdListMap.put(esc.Id, ultimateAcctIdProgramIdToGroupIdsListMap.get(String.valueOf(esc.Core_MDF_Budget_ID_Number_id__r.Core_MDF_Budget_Partner__r.Core_MDF_CoMarketing_Ultimate_Account__c) + String.valueOf(esc.Core_MDF_Channel_Program_id__c)));
                                          }
        
        //Call Core_MDF_GenericShareRecordActionClass to create Share records for budget escalation records
        if(escalationIdToGroupIdListMap != NULL && !escalationIdToGroupIdListMap.isEmpty()){
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Escalation__c', escalationIdToGroupIdListMap, 'Edit', 'Manual');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        } 
    }
    public void finish(Database.BatchableContext bc){}
}