public without sharing class CRM_ShareOfWalletController {
    
    
    @AuraEnabled(cacheable=true)
    public static List<CRM_Share_of_Wallet__c> getShareOfWalletData(Id recordId) {
       
                System.debug('Fetching Share of Wallet data for Account Plan ID: ' + recordId);
		if (recordId == null) {throw new AuraHandledException('Error: Record ID is required.');
        }

        
        return [SELECT Id, CRM_Year__c, CRM_Offering__c, CRM_Spend__c, CRM_With__c,CRM_Competitor__c, CRM_Contract_End_Date__c, CRM_Comments__c FROM CRM_Share_of_Wallet__c 
            WHERE CRM_Account_Plan__c = :recordId
            ORDER BY CRM_Year__c DESC
        ];
    }

    @AuraEnabled
    public static void saveShareOfWalletData(List<CRM_Share_of_Wallet__c> sowRecords) {
        try {
            if (!sowRecords.isEmpty()) {
                upsert sowRecords;
            }
        } catch (DmlException e) {throw new AuraHandledException('Error saving data: ' + e.getMessage());
        }
    }
    @AuraEnabled
	public static void deleteShareOfWalletRecord(Id recordId) {
    system.debug('id is '+recordId);
    delete [SELECT Id FROM CRM_Share_of_Wallet__c WHERE id = :recordId];
}
}