public class PMP_FetchVideoPreviewController{
    
    @AuraEnabled
    public static String getCompanyResources(){
        List<CompanyResource> resourceList = new List<CompanyResource>();
        for(PMP_Company_Resource__c resource : [SELECT Id, PMP_Company_Id__c,
                                                PMP_BrightCoveVideoId__c, PMP_VideoName__c
                                                FROM PMP_Company_Resource__c
                                                WHERE PMP_Company_Resource_Type_Nm__c = 'Video/mp4']){
                                                    CompanyResource comResource = new CompanyResource();
                                                    comResource.accountId = resource.PMP_Company_Id__c;
                                                    comResource.videoId = resource.PMP_BrightCoveVideoId__c;
                                                    comResource.videoType = 'brightcove';
                                                    comResource.thumbnailUrl = null;
                                                    comResource.title = resource.PMP_VideoName__c;
                                                    resourceList.add(comResource);
                                                }
        return JSON.serialize(resourceList);
    }
    
    public class CompanyResource{
        @AuraEnabled public String accountId;
        @AuraEnabled public String videoId;
        @AuraEnabled public String videoType;
        @AuraEnabled public String thumbnailUrl;
        @AuraEnabled public String title;
        //@AuraEnabled public String imageUrl;
        //@AuraEnabled public String altText;
        
        
    }
}