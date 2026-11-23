public without sharing class Core_Territory_Members_By_Account 
{
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}

     // add the instance for the variables being passed by id on the url
    private Account account {get;set;}
    
    public List<UserTerritory2Association> items { get; set; }

    public Core_Territory_Members_By_Account(ApexPages.StandardController controller) {
        //initialize the stanrdard controller
        this.controller = controller;
        
        // load the current record
        account = (Account)controller.getRecord();

        items = [SELECT UserId, Territory2Id, RoleInTerritory2
                 FROM UserTerritory2Association 
                 WHERE Territory2Id IN (SELECT Territory2Id
                                        FROM ObjectTerritory2Association
                                        WHERE ObjectId = :account.Id)]; 
    }

}