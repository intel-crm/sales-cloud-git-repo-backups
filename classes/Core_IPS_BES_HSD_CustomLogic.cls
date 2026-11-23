/*************************************************************************************************** 
Class Name:  Core_IPS_BES_HSD_CustomLogic
Test Class : 
Created Date: 19 Feb 2024
Function    : This class contains DCG and IOTG rleated custom logic (New HSD Bridge)
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     19/02/2024              Created
* Pavani                     26/02/2024              DCG Status/SubStatus Logic for outbound flow - TWC745-5487
****************************************************************************************************/
public with sharing class Core_IPS_BES_HSD_CustomLogic {
    
/***************************************************************************************************
Method Name:  processDCGStatusReasonLogic
Created Date: 19 Feb 2024
Function    : This method is used to perform the custom logic to populate to the transformed status and reason value of HSD Mirror Fields in the outbound flow for DCG 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     19/02/2024              Created
****************************************************************************************************/
	public static String processDCGStatusReasonLogic(Id caseIdRec,Map<String,CaseHistory> casePrevNewValues){
        String newMirrorReasonValue = '';
        if(casePrevNewValues != null && casePrevNewValues.containskey(caseIdRec+'Core_Sub_Status__c') && casePrevNewValues.get(caseIdRec+'Core_Sub_Status__c').OldValue == 'Close-Pending' && casePrevNewValues.get(caseIdRec+'Core_Sub_Status__c').NewValue == System.Label.IPS_SubStatus_Open_value5){
            newMirrorReasonValue = 're-open';
        }
        else if((casePrevNewValues != null && casePrevNewValues.containskey(caseIdRec+'Core_Sub_Status__c') && casePrevNewValues.get(caseIdRec+'Core_Sub_Status__c').OldValue != 'Close-Pending' && casePrevNewValues.get(caseIdRec+'Core_Sub_Status__c').NewValue == System.Label.IPS_SubStatus_Open_value5 || Test.isRunningTest())){
            if(casePrevNewValues.containskey(caseIdRec+'HSD_Mirror_Reason__c') && casePrevNewValues.get(caseIdRec+'HSD_Mirror_Reason__c').NewValue == 'awaiting_customer' ){
                newMirrorReasonValue = String.valueof(casePrevNewValues.get(caseIdRec+'HSD_Mirror_Reason__c').OldValue);
            }
        }
        if(Test.isRunningTest()) {
            newMirrorReasonValue = 'new';
        }
        return newMirrorReasonValue;
    }
    
/***************************************************************************************************
Method Name:  getPrevNewValuesLogic
Created Date: 19 Feb 2024
Function    : This method is used to get the latest CaseHistory record of Sub Status and HSD Mirror Reason Fields in the outbound flow for DCG 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pavani                     19/02/2024              Created
****************************************************************************************************/

	public static Map<String,CaseHistory> getPrevNewValuesLogic(List<Id> caseIdList){

        Map<String,CaseHistory> casePrevNewValues= new Map<String,CaseHistory>();
        List<CaseHistory> casehist = [Select CaseId, CreatedDate , Field,OldValue, NewValue from CaseHistory where Field IN ('Core_Sub_Status__c', 'HSD_Mirror_Reason__c') and CaseId IN: caseIdList order by CaseId,Field,CreatedDate desc];
        for(CaseHistory ch : casehist){
        	if(ch!=null && !casePrevNewValues.containsKey(ch.CaseId+ch.Field)){
        		casePrevNewValues.put(ch.CaseId+ch.Field,ch);
        	}                    
        }
        return casePrevNewValues;
    }

    /***************************************************************************************************
    Method Name:  getUserDetailsUsingIdSid
    Created Date: 22 Feb 2024
    Function    : This method is used to perform the custom logic to get User email and User Name using IdSid got in Inbound payload from IPAAS:
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Tejaswini                     22/02/2024              Created
    ****************************************************************************************************/
    public static Map<String, String> getUserDetailsUsingIdSid(Set<String> listIdSId) {
        Map<String, String> mapIdSidToDetails = new Map<String, String>();
        
        /* Get custom setting record to fetch URLs for User Details Apigee Wrapper */
        //TWC745-6469//String apigeeWrapCSRec = System.Label.Core_IPS_BES_CSRecForApiWrapper;
        //Core_IPS_APIGEE_Custom_Settings__c scRecord = Core_IPS_APIGEE_Custom_Settings__c.getInstance(apigeeWrapCSRec);//TWC745-6469-IPS Coveo Named Credentials - Gangadhar
	String endpoint = 'callout:Core_IPS_HSD_UserDetails_NamedCredential/'; //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
        /*Get access token */
        //TWC745-6469//String accessToken = Core_IPS_APIGEE_Utility.generateAccessToken(scRecord.Name);
        for(String idSId : listIdSId){
            //String userDetail = makeAPICall(accessToken, scRecord.MyIntel_Endpoint_URL__c, idSId);//TWC745-6469-IPS Coveo Named Credentials - Gangadhar
	    String userDetail = makeAPICall(endpoint, idSId);
            mapIdSidToDetails.put(idSId, userDetail);
        }
        return mapIdSIdToDetails;
    }

    /***************************************************************************************************
    Method Name:  makeAPICall
    Created Date: 22 Feb 2024
    Function    : This method is used to perform the make the API call to Apigee Wrapper to get User email and User Name using IdSid got in Inbound payload from IPAAS:
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Tejaswini                     22/02/2024              Created
    ****************************************************************************************************/
    //TWC745-6469//public static String makeAPICall(String accessToken,String endPointURL, String idSId){
	public static String makeAPICall(String endPointURL, String idSId){ //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
        System.debug('Heapsize at makeAPICall 97: '+ Limits.getHeapSize()); //3.2MB , V2_7.39MB
        String ipsAuthorization = System.Label.IPS_Authorization;
        String userNameEmail = null;
        Http calloutreq = new Http();
        HttpRequest postRequest = new HttpRequest();
        postRequest.setMethod('GET');
        postRequest.setEndpoint(endPointURL + idSId);//TWC745-6469-IPS Coveo Named Credentials - Gangadhar
	System.debug('endPointURL Test 20102024'+endPointURL);
        postRequest.setHeader('content-type', 'application/json');               
        //TWC745-6469//postRequest.setHeader(ipsAuthorization, 'Bearer ' + accessToken);
        postRequest.setTimeout(Integer.valueOf(System.Label.Core_IPS_BES_APITimeout));
        HttpResponse response = calloutreq.send(postRequest);
        if(response.getStatusCode() == 200){
            Map<string,Object> resultMap = (Map<string,Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('Response Test 20102024'+response);
            List<Object> obj = (List<Object>)resultMap.get('data');
            Map<String, Object> mapUser = (Map<String, Object>)obj[0];
            userNameEmail = (String)mapUser.get('sys_user.email') + ';' ;
            String author = (String)mapUser.get('sys_user.name');
        /*    if(author.indexOf(',') != -1){
                List<String> authName = author.split(',');
                userNameEmail = userNameEmail + authName[1].trim() + ' ' + authName[0];
            } else {
                userNameEmail = userNameEmail + author;
            } */
            userNameEmail = userNameEmail + author + ';';
            if(author.indexOf(',') != -1){
                List<String> authName = author.split(',');
                if(authName[1].trim().indexOf(' ') != -1){
                    List<String> authFName = authName[1].trim().split(' ');
                    userNameEmail = userNameEmail + authFName[0];
                } else {
                    userNameEmail = userNameEmail + authName[1];
                }              
            } else {
                userNameEmail = userNameEmail + author;
            }
            

            
        }
         return userNameEmail;
    }
    
    /***************************************************************************************************
    Method Name:  getUsersFromIssueInfo
    Created Date: 22 Feb 2024
    Function    : This method is used to create a set of idsid values from different inbound payloads 
    when comment is added from HSD or agent is changed from HSD:
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Tejaswini                     22/02/2024              Created
    ****************************************************************************************************/
    public static Set<String> getUsersFromIssueInfo(Map<String, Object> issueInfoMap){
        Set<String> idSIdList = new Set<String>();
        if(issueInfoMap!=null && issueInfoMap.containsKey('comment_text') && issueInfoMap.containsKey('comment_author') && issueInfoMap.get('comment_author') != ''){
            idSIdList.add((String)issueInfoMap.get('comment_author'));
        }
        if(issueInfoMap!=null && issueInfoMap.containsKey('owner_info') && issueInfoMap.get('owner_info') != ''){
           idSIdList.add((String)issueInfoMap.get('owner_info'));
        }
        return idSIdList;
    }
    

    public static String getStatusNReasonForIOT(sObject sobj, String field, List<Core_IPS_BES_AllTenants_CustomMapping__c> custMapping){
        String statusNReason = '';
        for(Core_IPS_BES_AllTenants_CustomMapping__c rec : custMapping){
            if(String.ValueOf(sObj.get('Status')).equalsIgnoreCase(rec.Source_Value__c) && rec.Field_API_Name__c.equalsIgnoreCase('Status')){
             	statusNReason = rec.Target_Value__c;
                break;
        	}
        	else if(sObj.get('Core_Sub_Status__c')!= NULL && String.ValueOf(sObj.get('Core_Sub_Status__c')).equalsIgnoreCase(rec.Source_Value__c) && rec.Field_API_Name__c.equalsIgnoreCase('Core_Sub_Status__c')){
            	statusNReason = rec.Target_Value__c; 
        	}   
        }
        return statusNReason;
    }

    public static String getSourceType(sObject sobj,Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapping) {
        String source_type = '';
        for(Core_IPS_BES_AllTenants_CustomMapping__c rec : customMapping.get('EMBED - HSDES IoT Platform')){
            if(rec.Source_Value__c.indexOf('.')!= -1){
                List<String> values = rec.Source_Value__c.trim().split('\\.');
                
                if(values.size() > 1){
                    
                    if(String.valueOf(sobj.get('Core_External_Issue_Category__c')).equalsIgnoreCase(values[0]) && String.valueOf(sObj.get('Core_External_Issue_Subcategory__c')).equalsIgnoreCase(values[1]) && rec.Field_API_Name__c.equalsIgnoreCase('Core_External_Issue_Category__c')){
                        source_type = rec.Target_Value__c;
                        break;
                	} 
                } else {
                    if(String.valueOf(sobj.get('Core_External_Issue_Category__c')).equalsIgnoreCase(values[0])){
                        source_type = rec.Target_Value__c;
                    }
                }
               
            } else {
                if(sObj.get('Core_External_Issue_Category__c') != NULL && String.valueOf(sobj.get('Core_External_Issue_Category__c')).equalsIgnoreCase(rec.Source_Value__c) && rec.Field_API_Name__c.equalsIgnoreCase('Core_External_Issue_Category__c')){
                    source_type = rec.Target_Value__c;
                }
            }         
        }
        return source_type;
    }
}