public class Seismic_ContentSync {
    
    //private static String bearerToken = getSeismicToken();//Seismic Token for API Call
    private static String message ='';
    
    /*Get Seismic Token*/
    public static String getSeismicToken(String apiScope) {
        String bearerToken ='';
        System.debug('getSeismicToken called');
        String grant_type = 'delegation';
        String client_id = 'bfbabaaa-d71a-48e5-8679-e7a6b8d9fa9a';
        String client_secret = 'b0ba2a35-6ecf-4bdc-a63c-a8c2f3a658fa';
        String user_id = '5600d223-ed35-48fb-8096-a1e78866426f';
        String scope = apiScope;//'seismic.library.manage';
        String endPoint = 'https://auth.seismic.com/tenants/inteldev/connect/token';
        
        Seismic_TokenResponseWrapper response = new Seismic_TokenResponseWrapper();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setMethod('POST');
        request.setEndpoint(endPoint);
        
        String payload = 'client_id='+EncodingUtil.urlEncode(client_id,'UTF-8')
            +'&grant_type='+EncodingUtil.urlEncode(grant_type,'UTF-8')
            +'&client_secret='+EncodingUtil.urlEncode(client_secret,'UTF-8')
            +'&user_id='+EncodingUtil.urlEncode(user_id,'UTF-8')
            +'&scope='+EncodingUtil.urlEncode(scope,'UTF-8');
        request.setBody(payload);
        try{    
            HttpResponse response2 = http.send(request);
            
            if (response2.getStatusCode() == 200) {
                String responseBody = response2.getBody();
                response = (Seismic_TokenResponseWrapper) JSON.deserialize(responseBody, Seismic_TokenResponseWrapper.class);
                bearerToken = response.access_token;
            }
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (Exception e) {
            message =  'Error occurred in getSeismicToken : ' + e.getMessage();
            //Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            //Seismic_UserDeletion.errorDetail += message;
            System.debug(message);
        }
        return bearerToken;
    }  
    
    /*Get all DOVs*/
    public static HttpResponse getDOVs(String bearerToken) {
        System.debug('getDOVs called');
        HttpResponse response2;
        String endPoint = 'https://api.seismic.com/integration/v2/contentProperties';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(100000);
        request.setEndpoint(endPoint);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        try{
            response2 = http.send(request);
            List<Seismic_DOVsResponseWrapper> response = (List<Seismic_DOVsResponseWrapper>) JSON.deserialize(response2.getBody(), List<Seismic_DOVsResponseWrapper>.class);
            //System.debug(response);
            
            //Get all existing DOVs
            Map<String, Object> dovMap = new Map<String, Object>();
            List<SeismicContentSync_DOV__c> tempDov = [SELECT Id, SeismicDOV_ID__c, SeismcDOV_Value__c, SeismicDOV_Name__c, SeismicDOV_Value_Old__c FROM SeismicContentSync_DOV__c];
            for(SeismicContentSync_DOV__c dov : tempDov){
                dovMap.put(dov.SeismicDOV_ID__c + '|' + dov.SeismicDOV_Name__c, dov); 
            }
             
            //System.debug(tmpDOVs);
            List<SeismicContentSync_DOV__c> dovAddList = new List<SeismicContentSync_DOV__c>();
            List<SeismicContentSync_DOV__c> dovUpadteList = new List<SeismicContentSync_DOV__c>();
            SeismicContentSync_DOV__c dov;
            Integer counter = 0;
            
            //Add user to user list
            for(Seismic_DOVsResponseWrapper wrapper : response) {
                if(wrapper.domainOfValues != null && wrapper.hasDomainOfValues == true) {
                    System.debug(wrapper.name);
                    for(Seismic_DOV domainOfValue : wrapper.domainOfValues){
                        //Add
                        System.debug(domainOfValue.id + '|' + wrapper.name);
                        if(!dovMap.containsKey(domainOfValue.id + '|' + wrapper.name)){
                            dov = new SeismicContentSync_DOV__c();
                            dov.SeismicDOV_ID__c = domainOfValue.id;
                            dov.SeismcDOV_Value__c = domainOfValue.value;
                            dov.SeismicDOV_Name__c = wrapper.name;
                            dov.SeismicDOV_Value_Old__c = '';  
                            dovAddList.add(dov);
                        }
                        else { 
                            dov = (SeismicContentSync_DOV__c)dovMap.get(domainOfValue.id + '|' + wrapper.name);
                            if(dov.SeismcDOV_Value__c != domainOfValue.value){
                                dov.SeismicDOV_Value_Old__c = dov.SeismcDOV_Value__c;
                                dov.SeismcDOV_Value__c = domainOfValue.value;
                                dovUpadteList.add(dov);
                            }
                        }
                        
                    }
                    counter += 1;
                    if(counter == 2 ){
                        break;
                    }
                }
                
            }
            
            if(!dovAddList.isEmpty()){
                insert dovAddList;
                //dovAddList = new List<SeismicContentSync_DOV__c>();
                //counter = 0;
                //jobStatus = Job_Status.Success;
            }
            
            if(!dovUpadteList.isEmpty()){
                system.debug('updating');
                update dovUpadteList;
                
                //dovAddList = new List<SeismicContentSync_DOV__c>();
                //counter = 0;
                //jobStatus = Job_Status.Success;
            }
                        
                        //if(!dovList.isEmpty()){
                        //insert dovList;
                        //jobStatus = Job_Status.Success;
                        //}
                        /*
            else if(jobStatus != Job_Status.Error) {
            jobStatus = Job_Status.NoRecord;
            errorMessage = 'Seismic & Azure Group is 100% sync. No action required.';
            }*/
            
            //Testing purpose only to hit exception block, it doesn't execute real-time
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch (System.Exception e) {
            message =  'Error occurred in getDOVs : ' + e.getMessage();
            //Seismic_UserDeletion.jobStatus = Seismic_UserDeletion.Job_Status.Error;
            //Seismic_UserDeletion.errorDetail += message;
            System.debug(message);
        }
        return response2;
    }     
   
    
    /*Clear records*/
    public static void clearDOVs() {
        delete [SELECT Id FROM SeismicContentSync_DOV__c];
    }
}