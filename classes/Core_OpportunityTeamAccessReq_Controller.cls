public without sharing class Core_OpportunityTeamAccessReq_Controller { //TWC3123-5376: code scan fix

    public Core_Oppty_Team_Access__c opptyTeamAccObj {get;set;}
    public Opportunity oppty {get;set;}
    public String userId {get;set;}
    
    public Core_OpportunityTeamAccessReq_Controller() {
        oppty = new Opportunity();
        String opptyID = ApexPages.currentPage().getParameters().get('id');
        userID = ApexPages.currentPage().getParameters().get('usr');
        
        if(opptyID != null && opptyID != '') {
            oppty = [SELECT id, Name FROM Opportunity WHERE id = :opptyID LIMIT 1];
        }
        
        opptyTeamAccObj = new Core_Oppty_Team_Access__c();        
    }
    
    public PageReference Save() {
        //Populate Team access request object
        if(oppty != null) {
            opptyTeamAccObj.Opportunity_Name__c = oppty.Id;
        }
        opptyTeamAccObj.User__c = Id.valueOf(userID);
        insert opptyTeamAccObj;
        return new PageReference('/'+opptyTeamAccObj.id);
    }

}