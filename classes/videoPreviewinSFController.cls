public class videoPreviewinSFController {
//@AuraEnabled is annotation enables LWC to access below apex method
 //(cacheable=true) is for caching the data on client side storage without 
   //waiting for server trips. Which imporves the performance
 @AuraEnabled(cacheable=true)
  public static List<PMP_Company_Resource__c> getAccounts() {
  return [SELECT Id,Name,PMP_Brightcove_VideoPreviewURL__c FROM PMP_Company_Resource__c where PMP_Brightcove_VideoPreviewURL__c!=null and id='a5Q8A000001DDSl'];
  }
}