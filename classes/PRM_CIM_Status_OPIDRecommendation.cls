public with sharing class PRM_CIM_Status_OPIDRecommendation {
    @AuraEnabled    
    public static PRM_Value_Exchange_Recommendation__c fetchCIMStatus(Id opidRecId) {
        string accId;
     	system.debug('opidRecId-->'+opidRecId);
        List<PRM_Value_Exchange_Recommendation__c> vxRecommendationLst = [
            SELECT Id, PRM_Account_Id__c 
            FROM PRM_Value_Exchange_Recommendation__c 
            WHERE id=:opidRecId];
        system.debug('vxRecommendationLst-->'+vxRecommendationLst);
            accId=vxRecommendationLst[0].PRM_Account_Id__c;
            system.debug('accId-->'+accId);
            PRM_Value_Exchange_Recommendation__c vxRecomRecord;
        
            HttpRequest req=new HttpRequest();
            req.setMethod('GET');
        //	https://apis-stage.intel.com/m2r/sales-cloud/opid/v1/partners/accounts
            //req.setEndpoint('callout:CIM_OUTBOUND/'+accId);
            req.setEndpoint('https://apis-internal-sandbox.intel.com/customer/v1/priming-and-partner-account-hierarchy-requests?$format=json&SourceSystemId=0018A00000iXcx8QAC');
            Http http=new Http();
            HttpResponse res=http.send(req);
            system.debug(res.getStatusCode());
            System.debug(res.getBody());
            
            if(res.getStatusCode()==200){
                vxRecomRecord=new PRM_Value_Exchange_Recommendation__c();
                vxRecomRecord=(PRM_Value_Exchange_Recommendation__c)JSON.deserialize(res.getBody(),PRM_Value_Exchange_Recommendation__c.Class);
            }
            
        return vxRecomRecord;

    }
    
  
}