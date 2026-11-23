/****************************************************************************************************************************************
 * Class Name  : Core_MDF_AccountUserUtility
 * Version     : 1.0
 * Created Date: 12-11-2019
 * Modification Log :
 * Developer            Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - Krishna  12/11/2019      Account User Utility
 *****************************************************************************************************************************************/
public class Core_MDF_AccountUserUtility {
    /*****************************************************************************************************
	 Method Name:        createObjectShareRecords
	 @return  :          void
	 @parameters:        String sobjectName, Map<Id, List<Id>> accountIdUserIdListMapCreateBatch, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap
	 Description:        This method is called from Finish of Account User Delete Batch for Starting Account User Create Batch on UPDATE of Account User Record.
	 Added By:           Accenture - KK - 12/11/2019
	 Modified By:        Date:       Changes:
	 ******************************************************************************************************/
    public static void createObjectShareRecords(String sobjectName, Map<Id, List<Id>> accountIdUserIdListMapCreateBatch, Map<Id, Core_MDF_Partner_Node_User_Mapping__c> newPNUMappingMap){    
        switch on sobjectName {
                when 'PartnerFundAllocationShare' {
                    String Createquery = 'SELECT Id, ChannelPartnerId FROM PartnerFundAllocation WHERE ChannelPartnerId IN ';
 
                    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundAllocation', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);
            
                    system.debug('PartnerFundAllocation - batchInstanceId::'+batchInstanceId);
                }
                when 'PartnerFundRequestShare' {
                    String Createquery = 'SELECT Id, ChannelPartnerId FROM PartnerFundRequest WHERE ChannelPartnerId IN ';

                    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundRequest', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);
            
                    system.debug('PartnerFundRequest - batchInstanceId::'+batchInstanceId);
                }
                when 'Core_MDF_Bank__Share' {
                    String Createquery = 'SELECT Core_MDF_Bank__c,Core_MDF_Account__c, Id FROM Core_MDF_Account_Bank_Mapping__c WHERE Core_MDF_Account__c IN ';

                    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Account_Bank_Mapping__c', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);
            
                    system.debug('Core_MDF_Account_Bank_Mapping__c - batchInstanceId::'+batchInstanceId);
                }
                when 'PartnerFundClaimShare' {
                    String Createquery = 'SELECT Id, ChannelPartnerId, Core_MDF_Payment_Id__c FROM PartnerFundClaim WHERE ChannelPartnerId IN ';

                    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('PartnerFundClaim', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);
            
                    system.debug('PartnerFundClaim - batchInstanceId::'+batchInstanceId);
                }
                when 'CaseShare' {
                    String Createquery = 'SELECT Id,AccountId FROM Case WHERE AccountId IN ';

                    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Case', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);
            
                    system.debug('Case - batchInstanceId::'+batchInstanceId);
                }
                when 'Core_MDF_Adjustment_Request__Share' {
                    String Createquery = 'SELECT Id, Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId FROM Core_MDF_Adjustment_Request__c WHERE Core_MDF_Adjustment_Claim_Nbr__r.ChannelPartnerId IN ';

                    Id batchInstanceId = Database.executeBatch(new Core_MDF_CreateBatchShareRecords('Core_MDF_Adjustment_Request__c', accountIdUserIdListMapCreateBatch, Createquery, newPNUMappingMap), 25);
            
                    system.debug('Core_MDF_Adjustment_Request__c - batchInstanceId::'+batchInstanceId);
                }
                when else {}
            }       
     	}
}