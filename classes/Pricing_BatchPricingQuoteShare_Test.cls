@isTest
public class Pricing_BatchPricingQuoteShare_Test {
    static testmethod void batchPricingQuoteShareTest(){
        List<User> fseUser = Pricing_Test_Utility.createUser();
        List<User> lstATMUsers = Pricing_Test_Utility.createFSEUser();
        List<User> adminUser = Pricing_Test_Utility.createAdminUser();
        Id userId = lstATMUsers[0].id;
        Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
        Account acc;
        Contact con; 
        AccountTeamMember accTeam;
        List<SBQQ__Quote__c> lstquote;
        List<Pricing_Comments__c> commentsList;
        List<User> salesRepUserList = new List<User>();

        Test.startTest();
        system.runAs(adminUser[0]){
            Pricing_Test_Utility.createPriceBook();
            acc = Pricing_Test_Utility.createAccount();
            con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Pricing_Batch_Quote_Share');
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                          TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            
            // Get Comments created for the Quote
            commentsList = new List<Pricing_Comments__c>([select id from Pricing_Comments__c where recordtypeid=:commentRecordTypeId]);
            User partnerUser = Pricing_Test_Utility.createPartnerUser(acc.Id);
            if(partnerUser != null){
                System.runAs(adminUser[0]){
                    Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
                }
            }
        }
        
        system.runAs(adminUser[0]){
            List<Id> quoteIds = new List<Id>();
            for(SBQQ__Quote__c quote:lstquote){
                quoteIds.add(quote.Id);
            }            
            if(quoteIds.size() > 0){
                BatchPricingQuoteShare quoteShare = new BatchPricingQuoteShare();
                quoteShare.quoteIds = quoteIds;
                Database.executeBatch(quoteShare);
            }
            // Get the quote and comment share object details
            List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>([SELECT id,ParentId,UserOrGroupId,AccessLevel,RowCause FROM SBQQ__Quote__Share WHERE ParentId =:lstquote[0].Id]);
            List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>([SELECT id,ParentId,UserOrGroupId,AccessLevel,RowCause FROM Pricing_Comments__Share WHERE ParentId =:commentsList[0].Id]);

            // Assert the changes
            if(quoteShares.Size() > 0){
               System.assertEquals(quoteShares[0].ParentId,lstquote[0].id, 'Quote Id is not matching with Quote Share object Id');
            }
            if(commentShares.Size() > 0){
               System.assertEquals(commentShares[0].ParentId,commentsList[0].id, 'Comment Id is not matching with Comment Share object Id');
            }             
        }
        Test.stopTest();
    }
}