/***************************************************************************************************
Apex Class Name:  Core_IPS_CoveoPageController
    Version     : 1.0
    Created Date: 06 April 2021
    Function    : The is for getting RDC roles from AEM API.
    Used In     : Core_IPS_CoveoCoveoPanel
    Test Class  :
    Modification Log :
     * Developer                    Date                    Description
 * ----------------------------------------------------------------------------
 * Farooq                 06 April 2021              Created
 ****************************************************************************************************/
public with sharing class Core_IPS_CoveoPageController { //Devcase After changes 16102024 //TWC745-6469//-IPS Coveo Named Credentials - Gangadhar
    
    public String custom_token_groups{get;set;}
    private final Case cs{get;set;}
    public List<String> customList{get;set;}
    public static Map<String,Object> responseMap1;
    private String customGroup;
    private List<User> users;
    public Core_IPS_CoveoPageController(ApexPages.StandardController stdController) {
        try{
            this.users = [SELECT ID,Name,Core_WWID__c,Profile.Name from User where Id =:userInfo.getUserId()];
            this.cs = (Case)stdController.getRecord();
            //== Storing in the the customGroup value in String.
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CoveoInfoCache');
            this.customGroup = (String)sessionPart.get('customGroup');
        }catch(Exception e){
             //TWC745-9001 End point url change for IAM webservices to microservices migration - Gagan
             Core_IPS_ExceptionHandling.logEntryWithException(
                e,
                'Core_IPS_CoveoPageController',
                'Case'
            ); 
        }
    }
    /*if(customGroup ==null && users[0].Core_WWID__c !=null){
        //== API connected call.
        //TWC745-6469//HttpRequest request = new HttpRequest();
        //TWC745-6469//request.setEndpoint(Label.Coveo_Apigee_Authorization);
        //TWC745-6469//request.setMethod('POST');
        //TWC745-6469//request.setHeader('Content-Type','application/x-www-form-urlencoded');
        //TWC745-6469//Map<String,String> body = new Map<String,String>();
        //TWC745-6469//String paylod = 'grant_type=client_credentials&client_id='+ Label.Core_Coveo_clientId +'&'+'client_secret='+ Label.Core_Coveo_clientScret;
        //TWC745-6469//request.setBody(paylod);
        //TWC745-6469//Http http = new Http();
        //TWC745-6469//HTTPResponse res = http.send(request);
        //TWC745-6469//System.debug('Named cred test@@@@@@11102024'+paylod);
        //TWC745-6469//if(res.getStatusCode() == 200){
            
            //TWC745-6469//map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(res.getBody());
            
            //TWC745-6469//String authorizationHeader = 'Bearer ' + (String) resultMap.get('access_token');
            String incluserrole = users[0].Core_WWID__c+'?includeUserRoles=true'; //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
            System.debug('Named cred test@@@ user wwid'+users[0].Core_WWID__c);
            System.debug('Named cred test@@@ include user role value'+incluserrole);
            //Map<String, String> urlParameters = new Map<String, String>{'includeUserRoles' => 'true'};
            HttpRequest req = new HttpRequest();
            req.setTimeout(120000);
            //TWC745-6469//req.setEndpoint(Label.Core_Coveo_endPoint+users[0].Core_WWID__c+'?includeUserRoles=true');
            req.setEndpoint('callout:Core_IPS_CoveoNamedCred/'+incluserrole); //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
            //req.setEndpoint(String.format('callout:Core_IPS_CoveoNamedCred/{0}?{1}', new String[]{users[0].Core_WWID__c, 'includeUserRoles=true'}));
                req.setMethod('GET');
                //TWC745-6469//req.setHeader(Label.Core_Apigee_Auth, authorizationHeader);
                req.setHeader('Content-Type','application/json');
                
                Http http1 = new Http();
                HTTPResponse response = http1.send(req);
                if(response.getStatusCode() == 200){
                    List<Object> resultList;
                    System.debug('Named cred test@@@@@@11102024'+response);
                    if(!Test.isRunningTest()){
                        resultList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                        responseMap1 = (Map<String,Object>)resultList[0];
                        System.debug('roleList '+responseMap1);
                    }
                    String roles = '';
                    String roles1 = '';
                    List<Object> rolesList = (List<Object>)responseMap1.get('roles');
                    for (Object role : rolesList) {
                        roles = (String)role;
                    }
                    List<String> allRolesList = roles.split(', ');
                    List<String> finalList = new List<String>();
                    allRolesList.sort();
                    for(Integer i = allRolesList.size()-1; i>=0;i--){
                        finalList.add(allRolesList.get(i));
                    }
                    
                    //== RDC label convertion logic.
                    for(String role: finalList){
                        role = role.trim();
                        if(roles.contains('RDC Privileged User Internal') || roles.contains('RDC Privileged Full')){
                            if(role == 'RDC Privileged User Internal' || role == 'RDC Privileged Full'){
                                role = 'rdc';
                                roles1= roles1 + role +';';
                                roles1 = roles1+'U:'+ users[0].Core_WWID__c+';';
                            }
                            if(role == 'Employee'){
                                role = 'U:DerivedGroup:AllBlueBadge';
                                role = role + ';U:DerivedGroup:AllEmployees';
                                roles1= roles1 + role +';';
                            }
                            else if(role == 'Contingent Worker'){
                                role = 'U:DerivedGroup:AllEmployees';
                                roles1= roles1 + role +';';
                            }
                            
                        }
                    }
                    roles1 = roles1+'U:Public';
                    
                    //==  Store Cache Information
                    Cache.SessionPartition sessionPart1 = Cache.Session.getPartition('local.CoveoInfoCache');
                    sessionPart1.put('customGroup', roles1);
                }
            //TWC745-6469//}
        }
    }catch(Exception e){
        //Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_CoveoPageController', 'Case');
        
        
    }*/
    public void coveoPagePanel(){
        try{
            if(this.customGroup == null && this.users.size() > 0 && this.users[0].Core_WWID__c !=null){
                //== API connected call.
                //TWC745-6469//HttpRequest request = new HttpRequest();
                //TWC745-6469//request.setEndpoint(Label.Coveo_Apigee_Authorization);
                //TWC745-6469//request.setMethod('POST');
                //TWC745-6469//request.setHeader('Content-Type','application/x-www-form-urlencoded');
                //TWC745-6469//Map<String,String> body = new Map<String,String>();
                //TWC745-6469//String paylod = 'grant_type=client_credentials&client_id='+ Label.Core_Coveo_clientId +'&'+'client_secret='+ Label.Core_Coveo_clientScret;
                //TWC745-6469//request.setBody(paylod);
                //TWC745-6469//Http http = new Http();
                //TWC745-6469//HTTPResponse res = http.send(request);
                //TWC745-6469//System.debug('Named cred test@@@@@@11102024'+paylod);
                //TWC745-6469//if(res.getStatusCode() == 200){
                    
                    //TWC745-6469//map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(res.getBody());
                    
                    //TWC745-6469//String authorizationHeader = 'Bearer ' + (String) resultMap.get('access_token');
                    //String incluserrole = users[0].Core_WWID__c+'?includeUserRoles=true'; //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
                     String incluserrole = users[0].Core_WWID__c; //TWC745-9001 End point url change for IAM webservices to microservices migration - Gagan
                    //Map<String, String> urlParameters = new Map<String, String>{'includeUserRoles' => 'true'};
                    HttpRequest req = new HttpRequest();
                    req.setTimeout(120000);
                    //TWC745-6469//req.setEndpoint(Label.Core_Coveo_endPoint+users[0].Core_WWID__c+'?includeUserRoles=true');
                    req.setEndpoint('callout:Core_IPS_CoveoNamedCred/'+incluserrole); //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
                    //req.setEndpoint(String.format('callout:Core_IPS_CoveoNamedCred/{0}?{1}', new String[]{users[0].Core_WWID__c, 'includeUserRoles=true'}));
                        req.setMethod('GET');
                        //TWC745-6469//req.setHeader(Label.Core_Apigee_Auth, authorizationHeader);
                        req.setHeader('Content-Type','application/json');
                        
                        Http http1 = new Http();
                        HTTPResponse response = http1.send(req);
                		system.debug('responseresponse '+response);
                        if(response.getStatusCode() == 200){
                            System.debug('Named cred test@@@@@@11102024'+response);
                            if(!Test.isRunningTest()){
                                List<Object> resultList;
                                resultList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                                responseMap1 = (Map<String,Object>)resultList[0];
                                System.debug('roleList '+responseMap1);
                            } else {
                                List<Object> resultList;
                                resultList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                                responseMap1 = (Map<String,Object>)resultList[0];
                            }
                            String roles = '';
                            String roles1 = '';
                            List<Object> rolesList = (List<Object>)responseMap1.get('roles');
                            system.debug('rolesListrolesList '+rolesList);
                            for (Object role : rolesList) {
                                roles = (String)role;
                            }
                            List<String> allRolesList = roles.split(', ');
                            List<String> finalList = new List<String>();
                            allRolesList.sort();
                            for(Integer i = allRolesList.size()-1; i>=0;i--){
                                finalList.add(allRolesList.get(i));
                            }
                            
                            //== RDC label convertion logic.
                            system.debug('finalListfinalList '+finalList);
                            for(String role: finalList){
                                system.debug('finalListfinalList before'+role);
                                role = role.trim();
                                system.debug('finalListfinalList '+role);
                                if(roles.contains('RDC Privileged User Internal') || roles.contains('RDC Privileged Full')){
                                    if(role == 'RDC Privileged User Internal' || role == 'RDC Privileged Full'){
                                        role = 'rdc';
                                        roles1= roles1 + role +';';
                                        roles1 = roles1+'U:'+ users[0].Core_WWID__c+';';
                                    }
                                    if(role == 'Employee'){
                                        role = 'U:DerivedGroup:AllBlueBadge';
                                        role = role + ';U:DerivedGroup:AllEmployees';
                                        roles1= roles1 + role +';';
                                    }
                                    else if(role == 'Contingent Worker'){
                                        role = 'U:DerivedGroup:AllEmployees';
                                        roles1= roles1 + role +';';
                                    }
                                    
                                }
                            }
                            roles1 = roles1+'U:Public';
                            
                            //==  Store Cache Information
                            Cache.SessionPartition sessionPart1 = Cache.Session.getPartition('local.CoveoInfoCache');
                            sessionPart1.put('customGroup', roles1);
                        }
                        if(Test.isRunningTest()){
                            if(response.getStatusCode() == 500){
                                throw new NullPointerException();
                            }
                        }
                        //TWC745-6469//
                    }
                }
                catch(Exception e){
                    Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_CoveoPageController', 'Case');
                    
                    
                }
            }
        }