public with sharing class AccountActivityVisibilityController {

    @AuraEnabled
    public static void updateActivityVisibility(Id accountId) {

        Account acc = [
            SELECT Id, OwnerId
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        Boolean canView =
            acc.OwnerId == UserInfo.getUserId();

        if(!canView){

            canView = [
                SELECT Count()
                FROM AccountTeamMember
                WHERE AccountId = :accountId
                AND UserId = :UserInfo.getUserId()
            ] > 0;
        }

        acc.Core_Can_View_Activity__c = canView;

        update acc;
    }
}