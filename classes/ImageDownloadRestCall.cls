@RestResource(urlMapping='/imageUrlbase64/case/*')
global class ImageDownloadRestCall {
    
    @Httpget
    global static String doget(){
        RestRequest req = RestContext.request;
		String caseId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<Id,List<String>> imageBase64map = new Map<Id,List<String>>();
        List<Case> queriedcaseList =[Select id,casenumber, Core_Issue_Description__c from case where id=:caseId]; // '5003F000007RMzJ' caseId where id='5003F000007RMzJ'
        for(Case caseObj: queriedcaseList){
            if(String.isNOTBlank(caseObj.Core_Issue_Description__c)){
                imageBase64map.put(caseObj.Id,Core_IPS_JSON_Utility.getAllImageURLtoBase64(caseObj.Core_Issue_Description__c));
            }
        }
        return Json.serialize(imageBase64map);
    }
   }