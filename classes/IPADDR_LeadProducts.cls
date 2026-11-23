public with sharing class IPADDR_LeadProducts {
    @AuraEnabled(cacheable=true)
    public static List<Product2> searchProducts(String searchKey) {
        return [SELECT Id, Name FROM Product2 WHERE IsActive = TRUE AND Name LIKE :('%' + searchKey + '%') ORDER BY Name LIMIT 25];
    }
    
    @AuraEnabled(cacheable=true)
	public static Id getLeadRecordTypeId(String developerName) {
    	RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'Deal_Registration'];
    	return rt.Id;
	}
}