public without sharing class Core_OpportunityTakeOwnerController { //TWC3123-5376: code scan fix
    @AuraEnabled
    public static Opportunity ChangeOppoOwner(Id oppoId) {

            Opportunity opp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :oppoId];
            opp.OwnerId = UserInfo.getUserId();
            Update opp;
            Return opp;

    }
}