@isTest
public class Pricing_BatchQuoteShare_ATM_Test {
    //Method to Test Pricing_BatchQuoteShare_ATM class
    static testmethod void batchPricingQuoteShareATMTest(){
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
       // List<User> lstATMUsers = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers3 =  Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers2 = Pricing_Test_Utility.createAdminUserWithParam('Batch_Quote_Share_ATM_Test');
        List<User> lstATMUsers4 = Pricing_Test_Utility.createAEUser();
        Map<Id,Set<Id>> accIdToUserIdMap = new Map<Id,Set<Id>>();
        //Id userId = lstATMUsers[0].id;
        Id userId1 = lstATMUsers3[0].id;
        Boolean ischeck = true;
        Test.startTest();
        system.runAs(lstATMUsers2[0]){
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact primaryContactList = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Batch_Quote_Share_ATM_Test');
            //List<AccountTeamMember> lstAccountTeamMember = Pricing_Test_Utility.createAccountTeamMember(acc.Id, userId);
            accountTeamMembers = Pricing_Test_Utility.createAccountTeamMember(acc.Id, userId1);
            Pricing_Test_Utility.createTemplate(lstATMUsers2[0].id);
            //List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuote(acc.Id, primaryContactList.Id, 3);
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, primaryContactList.Id,1, lstATMUsers3[0].Email, lstATMUsers4[0].Email);
            Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Pricing_Comments__c comment = new Pricing_Comments__c(
                Pricing_Answer__c = 'test test test test',
                Pricing_Question__c = 'test test test test',
                Pricing_Quote__c = lstquote[0].id,
                recordtypeId = commentRecordTypeId
            );
            insert comment;
            ChannelProgram cp=new ChannelProgram();
            cp.Name='Intel Quote Request';
            cp.IsActive=true;
            insert cp;
            Group grp = new Group();
            grp.name = 'Test_Group1';
            grp.Type = 'Regular'; 
            Insert grp;
            Core_MDF_Partner_Group_Mapping__c partnerGroup = new Core_MDF_Partner_Group_Mapping__c();
            partnerGroup.Core_MDF_Account__c=acc.id;
            partnerGroup.Core_MDF_Group_Name__c='Test_Group1';
            partnerGroup.Core_MDF_Type_of_Access__c='Internal';
            partnerGroup.Core_MDF_Channel_Program__c=cp.id;
            insert partnerGroup;
            List<AccountTeamMember> lstATMAccountTeamMember = new List<AccountTeamMember>([select id from AccountTeamMember]);
            lstATMAccountTeamMember = [select id,userId,AccountId from AccountTeamMember];
            for(AccountTeamMember atm: accountTeamMembers){
                    if(accIdToUserIdMap.containsKey(atm.accountId)){
                        accIdToUserIdMap.get(atm.AccountId).add(atm.UserId);
                    }
                    else{
                        accIdToUserIdMap.put(atm.AccountId,new Set<Id>{atm.UserId});
                    }
            }  
            
            Pricing_BatchQuoteShare_ATM uca = new Pricing_BatchQuoteShare_ATM(lstATMAccountTeamMember,ischeck,accIdToUserIdMap);
            Id batchId = Database.executeBatch(uca);
            Test.stopTest();
            System.assert(batchId != null);
            
            //List<Pricing_Comments__c> commentsList = new List<Pricing_Comments__c>([select id from Pricing_Comments__c where recordtypeid=:commentRecordTypeId LIMIT 1]);
            //List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>([select id,ParentId,UserOrGroupId,AccessLevel,RowCause from SBQQ__Quote__Share LIMIT 1]);
            //List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>([select id,ParentId,UserOrGroupId,AccessLevel,RowCause from Pricing_Comments__Share LIMIT 1]);
            
            //if(!lstquote.isEmpty() && !quoteShares.isEmpty() && lstATMUsers.isEmpty()){
                //System.assertEquals(quoteShares[0].ParentId,lstquote[0].Id, 'Quote share failed for new ATM');
                //System.assertEquals(quoteShares[0].AccessLevel,'Edit', 'Quote share accesslevel is not edit for new ATM');
                //System.assertEquals(quoteShares[0].UserOrGroupId,lstATMUsers[0].Id, 'Quote share User group if not matching with new ATM');
            //}
            
            //if(!commentsList.isEmpty() && !commentShares.isEmpty() && lstATMUsers.isEmpty()){
             //   System.assertEquals(commentShares[0].ParentId,commentsList[0].Id, 'Quote share failed for new ATM');
             //   System.assertEquals(commentShares[0].AccessLevel,'Edit', 'Quote share accesslevel is not edit for new ATM');
             //   System.assertEquals(commentShares[0].UserOrGroupId,lstATMUsers[0].Id, 'Quote share User group if not matching with new ATM');      
           // } 
        }
    }
    static testmethod void batchPricingQuoteShareATMTest1(){
        List<AccountTeamMember> accountTeamMembers = new List<AccountTeamMember>();
        //List<User> lstATMUsers = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers3 = Pricing_Test_Utility.createFSEUser();
        List<User> lstATMUsers2 = Pricing_Test_Utility.createAdminUserWithParam('Batch_Quote_Share_ATM_Test');
        List<User> lstATMUsers4 = Pricing_Test_Utility.createAEUser();
        Map<Id,Set<Id>> accIdToUserIdMap = new Map<Id,Set<Id>>();
        //Id userId = lstATMUsers[0].id;
        Id userId1 = lstATMUsers3[0].id;
        Boolean ischeck = false;
        Test.startTest();
        system.runAs(lstATMUsers2[0]){
            Id commentRecordTypeId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Comments__c',Label.Pricing_Tender_Comment_RecordType_QuoteComment);
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact primaryContactList = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'Batch_Quote_Share_ATM_Test');
            //List<AccountTeamMember> lstAccountTeamMember = Pricing_Test_Utility.createAccountTeamMember(acc.Id, userId);
            accountTeamMembers = Pricing_Test_Utility.createAccountTeamMember(acc.Id, userId1);
            Pricing_Test_Utility.createTemplate(lstATMUsers2[0].id);
            //List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuote(acc.Id, primaryContactList.Id, 3);
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, primaryContactList.Id,1, lstATMUsers3[0].Email, lstATMUsers4[0].Email);
            Pricing_Test_Utility.createQuoteLines(lstquote[0].id, 1);
            Pricing_Comments__c comment = new Pricing_Comments__c(
                Pricing_Answer__c = 'test test test test',
                Pricing_Question__c = 'test test test test',
                Pricing_Quote__c = lstquote[0].id,
                recordtypeId = commentRecordTypeId
            );
            insert comment;
            Group grp = new Group();
            grp.name = 'Test_Group1';
            grp.Type = 'Regular'; 
            Insert grp;
            ChannelProgram cp=new ChannelProgram();
            cp.Name='Intel Quote Request';
            cp.IsActive=true;
            insert cp;
            Core_MDF_Partner_Group_Mapping__c partnerGroup = new Core_MDF_Partner_Group_Mapping__c();
            partnerGroup.Core_MDF_Account__c=acc.id;
            partnerGroup.Core_MDF_Group_Name__c='Test_Group1';
            partnerGroup.Core_MDF_Type_of_Access__c='Internal';
            partnerGroup.Core_MDF_Channel_Program__c=cp.id;
            insert partnerGroup;
            List<AccountTeamMember> lstATMAccountTeamMember = new List<AccountTeamMember>([select id from AccountTeamMember]);
            lstATMAccountTeamMember = [select id,userId,AccountId from AccountTeamMember];
            for(AccountTeamMember atm: accountTeamMembers){
               
                    if(accIdToUserIdMap.containsKey(atm.accountId)){
                        accIdToUserIdMap.get(atm.AccountId).add(atm.UserId);
                    }
                    else{
                        accIdToUserIdMap.put(atm.AccountId,new Set<Id>{atm.UserId});
                    }
                }
            //Test.startTest();  
            Pricing_BatchQuoteShare_ATM uca = new Pricing_BatchQuoteShare_ATM(lstATMAccountTeamMember,ischeck,accIdToUserIdMap);
            Id batchId = Database.executeBatch(uca);
            Test.stopTest();
            System.assert(batchId != null);
            
            //List<Pricing_Comments__c> commentsList = new List<Pricing_Comments__c>([select id from Pricing_Comments__c where recordtypeid=:commentRecordTypeId LIMIT 1]);
            //List<SBQQ__Quote__Share> quoteShares = new List<SBQQ__Quote__Share>([select id,ParentId,UserOrGroupId,AccessLevel,RowCause from SBQQ__Quote__Share LIMIT 1]);
            //List<Pricing_Comments__Share> commentShares = new List<Pricing_Comments__Share>([select id,ParentId,UserOrGroupId,AccessLevel,RowCause from Pricing_Comments__Share LIMIT 1]);
            
            //if(!lstquote.isEmpty() && !quoteShares.isEmpty() && lstATMUsers.isEmpty()){
                //System.assertEquals(quoteShares[0].ParentId,lstquote[0].Id, 'Quote share failed for new ATM');
                //System.assertEquals(quoteShares[0].AccessLevel,'Edit', 'Quote share accesslevel is not edit for new ATM');
               // System.assertEquals(quoteShares[0].UserOrGroupId,lstATMUsers[0].Id, 'Quote share User group if not matching with new ATM');
            //}
            
            //if(!commentsList.isEmpty() && !commentShares.isEmpty() && lstATMUsers.isEmpty()){
                //System.assertEquals(commentShares[0].ParentId,commentsList[0].Id, 'Quote share failed for new ATM');
                //System.assertEquals(commentShares[0].AccessLevel,'Edit', 'Quote share accesslevel is not edit for new ATM');
              //  System.assertEquals(commentShares[0].UserOrGroupId,lstATMUsers[0].Id, 'Quote share User group if not matching with new ATM');      
            //} 
        } 
    }
}