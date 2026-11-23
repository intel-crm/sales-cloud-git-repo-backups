@RestResource(urlMapping='/TargetEndPoint/*')
global class SmartPicklistWebService {
     @HttpGet
    global static List<Account> getAccounts(){
        System.debug('GET Method has been called');
        return [Select Name, Phone from Account Limit 10];    
    }
    @HttpPost
    global static string backFillPV(){
        String responseMsg;
        system.debug('Inside backFillPV: ');
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        PicklistManager.PicklistWrapperClass pwcParams = (PicklistManager.PicklistWrapperClass) JSON.deserialize(requestBody, PicklistManager.PicklistWrapperClass.class);
        system.debug('DEVSLS PICKLISTWRAPPER:'+pwcParams);
        PicklistManager.createOrUpdatePLV(pwcParams,true);
        /*PicklistManager.PicklistWrapperClass pwcParams = (PicklistManager.PicklistWrapperClass) JSON.deserialize(serializedWrapper, PicklistManager.PicklistWrapperClass.class);
        system.debug('Inside backFillPV: '+pwcParams);
        Map<boolean,string>  updateRes =PicklistManager.createOrUpdatePLV(pwcParams,false);*/
        return 'Backfill Process Completed';
    }
   
}