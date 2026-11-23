public class PMP_RichMediaAssetDoc_TriggerHandler {
  /*  
    public void afterInsert(){
        Map<Id, String> richMediaList = new Map<Id,String>();
        
        for(PMP_Rich_Media_Asset_Stage__c stageList :trigger.new){  
    if(String.isEmpty(stageList.Id)){
        continue;
    }
     richMediaList.put(stageList.Id,'stageList');
    }
      Set<Id> idSet = richMediaList.KeySet();
      Map<Id,PMP_Rich_Media_Asset_Stage__c> getURL=new Map<Id,PMP_Rich_Media_Asset_Stage__c>([SELECT Id,PMP_Is_Retrieved_Ind__c, PMP_Document_Download_Path_url__c FROM PMP_Rich_Media_Asset_Stage__c WHERE Id IN:idSet]);
        
    
    Map<Id,String> docIdtoDownloadUrlMap = new Map<Id,String>();
        for (PMP_Rich_Media_Asset_Stage__c s : getURL.values()) {
            if(s.PMP_Is_Retrieved_Ind__c ==true){
                system.debug('value is:'+s.PMP_Is_Retrieved_Ind__c);
      //Populate the Map and List
      if(s.PMP_Document_Download_Path_url__c!=null) {  
        docIdtoDownloadUrlMap.put(s.Id, s.PMP_Document_Download_Path_url__c);  
      }  
        }
        }
    //calling the download utility class to download all the documents
    PMP_RichMediaAssetDocDownload.fetchFileFromExternalUrl(docIdtoDownloadUrlMap);
}
*/
}