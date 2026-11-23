public class Core_A_E_Get_Identity_Details {
    @AuraEnabled(cacheable=true)
    // Pass in the endpoint to be used using the string url
    public static String getIdentityDetails(String searchString) {
        allIdentityDetailsWrapper identityDetails = new allIdentityDetailsWrapper();
        String EnterpriseId = '';
        String searchType = '';
        Map<String, Object> combinedJson = new Map<String, Object>();
        if(searchString.contains('@')){
            searchType = 'Email';
        } else{
            searchType = 'EnterpriseId';
            EnterpriseId = searchString;
        }
        String strAGSResponse = '';
        String strAzureResponse = '';
        String strResStatus = '';
        String AzureUserId = '';
        
        Map<String,id> mapAGSConEntId = new Map<String,id>();
        Map<id,Core_Contact_Entitlement__c> mapidConEnt = new Map<id,Core_Contact_Entitlement__c>();
        Map<String, Object> mapAGSRes = new Map<String, Object>();
        Map<String, Object> mapAzureRes = new Map<String, Object>();
        Set<String> stAGSRoles = new Set<String>();
        List<Core_Contact_Entitlement__c> lstToUpdate = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> lstToInset = new List<Core_Contact_Entitlement__c>();
        Set<String> stAGSToCreate = new Set<String>();
        Set<String> stAGSRolesToGetEnt = new Set<String>();
        Contact sfContact =  new Contact();
        
        List<Core_Contact_Entitlement__c> lstConEnt = new List<Core_Contact_Entitlement__c>();
        Boolean userAvailableInAzure = true;
        
        //Get the list of Entitlements assigned on the contact
        if(searchType == 'Email'){
            sfContact = [SELECT Id, Name, Email, Core_eRPM_Person_Id__c, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c, Core_Enterprise_Id__c, Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,Core_Identity_Status__c, (SELECT Id, Name, Core_Display_Nm__c, Core_Type__c, Core_Category__c, Core_Status__c, Core_Selected__c, Core_Update_Reason__c, Core_Entitlement_B2B_B2C_Indicator__c FROM Contact_Entitlements__r) FROM Contact WHERE Email =: searchString LIMIT 1];
        } else{
            sfContact = [SELECT Id, Name, Email, Core_eRPM_Person_Id__c, Core_ERPM_Integration_Status__c, Core_ERPM_Integration_Message__c, Core_Enterprise_Id__c, Core_AGS_Integration_Status__c, Core_AGS_Integration_Message__c,Core_Identity_Status__c, (SELECT Id, Name, Core_Display_Nm__c, Core_Type__c, Core_Category__c, Core_Status__c, Core_Selected__c, Core_Update_Reason__c, Core_Entitlement_B2B_B2C_Indicator__c FROM Contact_Entitlements__r) FROM Contact WHERE Core_Enterprise_Id__c =: searchString LIMIT 1];
        }
        system.debug('Adding sfContactDetails as: ' + JSON.serialize(sfContact));
        combinedJson.put('sfContactDetails', sfContact);
        //identityDetails.sfContactDetails = JSON.serialize(sfContact);
        
        // Get the user details (User Id) and list of Groups from Azure B2B using User Id
        // Part 1: Get user details from the user's email
        try{
            Http httpAzure = new Http();
            HttpRequest reqAzure = new HttpRequest();
            if(searchType == 'Email'){
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2b/users(mail='+ searchString + ')'); 
            } else{
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2b/users(enterpriseid='+ searchString + ')');
            }
            
            reqAzure.setMethod('GET');
            HttpResponse resAzure = httpAzure.send(reqAzure);
            
            strAzureResponse = resAzure.getBody();
            if(!String.isBlank(strAzureResponse) && strAzureResponse.length() != 2){ // Check if the Azure response is not Blank and its not "[]"
                system.debug('Adding azureB2BIdentityDetails as: ' + strAzureResponse);
                list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAzureResponse);
                mapAzureRes = !objlst.isEmpty() ? (Map<String, Object>)objlst[0] : null;
                combinedJson.put('azureB2BIdentityDetails', mapAzureRes);
                identityDetails.azureB2BIdentityDetails = strAzureResponse;
                if(mapAzureRes != null){
                    AzureUserId = (String)mapAzureRes.get('id');
                    EnterpriseId = (String)mapAzureRes.get('enterpriseId');
                    
                } 
            } else{ //If the response from Azure is Blank or its [], update the flag userAvailableInAzure to false
                userAvailableInAzure = false;
            }
            
            // Part 2: Get user group details from the User Id we got from Part 1 above and add it to the AGS roles set so that
            // further processing can take place as per the AS-IS flow.
            if(AzureUserId != ''){
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2b/users/'+ AzureUserId + '/memberof');  
                reqAzure.setMethod('GET');
                resAzure = httpAzure.send(reqAzure);
                
                strAzureResponse = resAzure.getBody();
                if(!String.isBlank(strAzureResponse)){
                    system.debug('Adding azureB2BMembershipDetails as: ' + strAzureResponse);
                    list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAzureResponse);
                	mapAzureRes = !objlst.isEmpty() ? (Map<String, Object>)objlst[0] : null;
                    combinedJson.put('azureB2BMembershipDetails', mapAzureRes);
                    identityDetails.azureB2BMembershipDetails = strAzureResponse;
                }
            }
        } catch(Exception e){
            identityDetails.azureB2BIdentityDetails = 'Received Azure Exception: ' + e.getMessage();
        }
        
        // Get the user details (User Id) and list of Groups from Azure B2C using User Id
        // Part 1: Get user details from the user's email
        try{
            Http httpAzure = new Http();
            HttpRequest reqAzure = new HttpRequest();
            if(searchType == 'Email'){
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2c/users(mail='+ searchString + ')'); 
            } else{
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2c/users(enterpriseid='+ searchString + ')');
            }
            
            reqAzure.setMethod('GET');
            HttpResponse resAzure = httpAzure.send(reqAzure);
            
            strAzureResponse = resAzure.getBody();
            if(!String.isBlank(strAzureResponse) && strAzureResponse.length() != 2){ // Check if the Azure response is not Blank and its not "[]"
                system.debug('Adding azureB2CIdentityDetails as: ' + strAzureResponse);
                identityDetails.azureB2CIdentityDetails = strAzureResponse;
                list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAzureResponse);
                mapAzureRes = !objlst.isEmpty() ? (Map<String, Object>)objlst[0] : null;
                combinedJson.put('azureB2CIdentityDetails', mapAzureRes);
                if(mapAzureRes != null){
                    AzureUserId = (String)mapAzureRes.get('id');
                    
                } 
            } else{ //If the response from Azure is Blank or its [], update the flag userAvailableInAzure to false
                userAvailableInAzure = false;
            }
            
            // Part 2: Get user group details from the User Id we got from Part 1 above and add it to the AGS roles set so that
            // further processing can take place as per the AS-IS flow.
            if(AzureUserId != ''){
                reqAzure.setEndpoint('callout:Azure_A_E_Get_Groups/iam/azure/v1/b2c/users/'+ AzureUserId + '/memberof');  
                reqAzure.setMethod('GET');
                resAzure = httpAzure.send(reqAzure);
                
                strAzureResponse = resAzure.getBody();
                if(!String.isBlank(strAzureResponse)){
                    system.debug('Adding azureB2CMembershipDetails as: ' + strAzureResponse);
                    list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAzureResponse);
                	mapAzureRes = !objlst.isEmpty() ? (Map<String, Object>)objlst[0] : null;
                    combinedJson.put('azureB2CMembershipDetails', mapAzureRes);
                    identityDetails.azureB2CMembershipDetails = strAzureResponse;
                }
            }
        } catch(Exception e){
            identityDetails.azureB2CIdentityDetails = 'Received Azure Exception: ' + e.getMessage();
        }
        
        // Get the list of Roles from AGS
        if(EnterpriseId != ''){
            Http httpAGS = new Http();
            HttpRequest reqAGS = new HttpRequest();
            reqAGS.setEndpoint('callout:APIGEE_A_E_Get_Roles/m2r/v1/users/roles/'+ EnterpriseId + '?includeUserRoles=true&hostingType=Hybrid');  
            reqAGS.setMethod('GET');
            HttpResponse resAGS = httpAGS.send(reqAGS);
            System.debug('Body from AGS:'+resAGS.getBody());
            strAGSResponse = resAGS.getBody();
            // Process the body got from AGS and add the roles to "stAGSRoles" if they are present
            if(!String.isBlank(strAGSResponse)){
                try{
                    list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAGSResponse);
                    List<String> lstRoles = new List<String>();
                    mapAGSRes = (Map<String, Object>)objlst[0];
                    List<Object> lstAGSRoles = (List<Object>)mapAGSRes.get('roles');
                    String lstAGSRoles1 = lstAGSRoles.isEmpty() ? '' : (String)lstAGSRoles[0];
                    lstRoles = lstAGSRoles1.split(',');
                    for(String obj : lstRoles){
                        stAGSRoles.add(obj.trim()); 
                    }
                    system.debug('Adding agsRoleDetails as: ' + JSON.serialize(stAGSRoles));
                    combinedJson.put('agsRoleDetails', mapAGSRes);
                    identityDetails.agsRoleDetails = JSON.serialize(stAGSRoles);
                } catch (Exception e){
                    Map<String,Object> objMap = (Map<String,Object>)JSON.deserializeUntyped(strAGSResponse);
                    Object errorObj = objMap.get('Errors');
                    List<Object> errorObjList = (List<Object>)errorObj;
                    Map<String,Object> errorMap = (Map<String, Object>)errorObjList[0];
                    String errorDetail = (String)errorMap.get('sourceSystemMessage');
                    String errorServiceCode = (String)errorMap.get('serviceCode');
                    identityDetails.agsRoleDetails = 'Received AGS Exception: ' + errorDetail;
                }
            }
        }   
        system.debug('Returning Response as: ' + combinedJson);
        system.debug('Returning Response String as: ' + JSON.serialize(combinedJson));
        return JSON.serialize(combinedJson);
    }

    public class allIdentityDetailsWrapper {
         @AuraEnabled
    public String sfContactDetails { get; set; }
         @AuraEnabled
    public String agsRoleDetails { get; set; }
         @AuraEnabled
     public String azureB2BIdentityDetails{ get; set; }
         @AuraEnabled
     public String azureB2BMembershipDetails { get; set; }
         @AuraEnabled
      public String azureB2CIdentityDetails { get; set; }
         @AuraEnabled
      public String azureB2CMembershipDetails { get; set; }
       
    }   
}