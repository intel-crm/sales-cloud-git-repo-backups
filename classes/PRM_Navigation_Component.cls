public class PRM_Navigation_Component {
	@AuraEnabled
    public static String getAccountId(String acmId){
        return [select id, PRM_Account_Id__c from PRM_AccountChannelMembership__c where id = :acmId].PRM_Account_Id__c;
    }
}