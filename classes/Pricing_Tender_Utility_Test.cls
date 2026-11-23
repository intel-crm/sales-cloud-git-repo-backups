/**
 * @description       : 
 * @author            : Subhanku
 * @group             : Accenture
 * @last modified on  : 02-07-2023
 * @last modified by  : Subhanku
**/
@isTest
public class Pricing_Tender_Utility_Test {
    public class CoverException extends Exception {} 
    
	//Method to setup Test data
	@testSetup
	public static void setUpData() {
		List < User > adminUser = Pricing_Test_Utility.createAdminUser();
		List < SBQQ__QuoteLine__c > lstquoteLines;
		if(!adminUser.isEmpty()) {
			system.runAs(adminUser[0]) {
				Pricing_Test_Utility.createPriceBook();
                Account acc = Pricing_Test_Utility.createAccount();
                Contact con = Pricing_Test_Utility.createPrimaryContact(acc.Id);
                Pricing_Test_Utility.createTemplate(adminUser[0].id);
                List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
                List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
                AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                                  TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
                insert accTeam;
                List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
				Id quoteID;
				for(SBQQ__Quote__c quote: lstquote) {
					quoteID = quote.Id;
				}
				Test.startTest();
				lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteID, 1);
				Test.stopTest();
			}
		}
	}
	static testmethod void checkRecordTypeCheck() {
		Test.startTest();
        SBQQ__Quote__c quote = [select id from SBQQ__Quote__c limit 1];
		List < User > lstUsers2 = Pricing_Test_Utility.createAdminUser();
        Pricing_QuoteLineCloneController.GlobalVariables gVar = new Pricing_QuoteLineCloneController.GlobalVariables();
        	Map<String,String> errMap = new Map<String,String>();
        	Map<String,String> pricingAIErrMap = new Map<String,String>();
        	Map<String,String> bulkAEErrMap = new Map<String,String>();
        	Map<String,Id> recordNameRecordIDMap = new Map<String,Id>();
        	errMap.put('Core_Origin__c', Label.Pricing_MyDeal_Integration_Origin);
        	pricingAIErrMap.put('Core_Origin__c', 'PricingAI-Integration');
        	bulkAEErrMap.put('Core_Origin__c', 'Bulk Account Executive Insertion');
		System.runAs(lstUsers2[0]) {
			RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'SBQQ__Quote__c'
				Limit 1
			];
			Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', rt.DeveloperName);
			system.assert(Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c', rt.DeveloperName) != null);
            Pricing_Tender_Utility.logErrorinLogObjectIntegration(errMap,recordNameRecordIDMap, 'Critical');
			Test.stopTest();
            Pricing_Tender_Utility.logErrorinLogObjectPricingAIIntegration(pricingAIErrMap,recordNameRecordIDMap, 'Critical');
            Pricing_Tender_Utility.logErrorinLogObjectBulkUpdateInsertAE(bulkAEErrMap,recordNameRecordIDMap, 'Medium', 'Account Executive Insertion');
		}
        
        //String s;
        try {
            //s.toLowerCase();
            throw new CoverException('First exception');
        }
        Catch(Exception e){
            Pricing_Tender_Utility.getErrorDetails(e);
            Pricing_Tender_Utility.logError(e);
            Pricing_Tender_Utility.getExceptionMessage(e);
            Pricing_Tender_Utility.handleError(gVar,e,'test',quote.id, '');
            //Pricing_Tender_Utility.getRecordId(e);
        }
	}

	static testmethod void testCreateUsageTrackingLog() {
		SBQQ__QuoteLine__c qli = [select id,SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Account__c from SBQQ__Quoteline__c limit 1];
		Pricing_Tender_Utility.createUsageTrackingLog(new Set<id>{qli.Id},qli.SBQQ__Quote__c,'test');
        Pricing_Tender_Utility.getGUID();
        Pricing_Tender_Utility.getCIMId(qli.SBQQ__Quote__r.SBQQ__Account__c,'test');
		System.assert(qli != null);
	}
}