public class ContentVersionTriggerHandler {
    
    public static void createPublicLinkForFile(){
        //ContentVersionTriggerHandler.createPublicLinkForFile();
        // get the content document link
        //Map<Id, ContentDocumentLink> contentDocumentLinkMap = getContentDocumentLinkMap(contentVersionList);
           Set<Id> contentToBeUploaded = new Set<Id>();
       // for(ContentVersion version : contentVersionList){
            //ContentDocumentLink link = contentDocumentLinkMap.get( version.ContentDocumentId );
           // System.debug('***link--->'+link);
           // System.debug('***link-type-->'+link.LinkedEntityId.getSObjectType());
            //if( ( link.LinkedEntityId.getSObjectType() == PMP_Partner_Offering__c.sObjectType) ){
                contentToBeUploaded.add('0698A000001M6gk');
            //}
       // }
        AWSS3PutDriver driverClass = new AWSS3PutDriver(contentToBeUploaded);
        Id jobId = System.enqueueJob(driverClass);
    }
    
    // Get the Content Document Related to Cintent Version so that We can check which object is parent to file
	public static Map<Id, ContentDocumentLink> getContentDocumentLinkMap(List<ContentVersion> contentVersionList){
        Set<String> contentDocumentIdsSet = new Set<String>();
        for(ContentVersion version : contentVersionList){
            contentDocumentIdsSet.add(version.ContentDocumentId);
        }
        Map<Id, ContentDocumentLink> contentDocumentLinkMap = new Map<Id, ContentDocumentLink>();
        for(ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocumentIdsSet]){
            //if(link.LinkedEntityId.getSObjectType() == PMP_Partner_Offering__c.sObjectType){
                contentDocumentLinkMap.put(link.ContentDocumentId, link);
            //}
        }
        return contentDocumentLinkMap;
    }
}