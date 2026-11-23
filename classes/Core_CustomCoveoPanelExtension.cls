public without sharing class Core_CustomCoveoPanelExtension {
	public String custom_token_filter{get;set;}
    public String custom_token_groups{get;set;}
    private final Case cs{get;set;}
   
 
    public Core_CustomCoveoPanelExtension(ApexPages.StandardController stdController) {
       if(User.SObjectType.getDescribe().isQueryable()){ 
        List<User> users = [SELECT ID,Name,FederationIdentifier from User where Id =:userInfo.getUserId()];
       
        this.cs = (Case)stdController.getRecord();
           
        if(users.size()!=0 && users!=null){
            custom_token_groups = users[0].FederationIdentifier;
        }
           
       }
    }
}