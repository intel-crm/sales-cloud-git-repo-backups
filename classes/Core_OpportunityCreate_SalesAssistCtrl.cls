public without sharing class Core_OpportunityCreate_SalesAssistCtrl { //TWC3123-5376: codescan fix: added without sharing
    
    public String objectName{get;set;}
    public String objectPrefix{get;set;}
    public String recordTypeId{get;set;}
    public String accId{get;set;}
    public String description{get;set;}
    public boolean isLex{get;set;}
    
    public Core_OpportunityCreate_SalesAssistCtrl(){
        recordTypeId = null;
        objectName = ApexPages.currentPage().getParameters().get('ent');
        objectPrefix = Schema.getGlobalDescribe().get(objectName).getDescribe().getKeyPrefix();
        recordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
        accId = ApexPages.currentPage().getParameters().get('accid');
        description = ApexPages.currentPage().getParameters().get('opp14');
        isLex = [select PermissionsLightningExperienceUser from Profile where Id =: UserInfo.getProfileId()].PermissionsLightningExperienceUser;
    }
    
}