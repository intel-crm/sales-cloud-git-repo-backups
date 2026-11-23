public class Core_IPS_CoveoPageController_New {
	 public String custom_token_groups{get;set;}
    //private final Case cs{get;set;}
    public List<String> customList{get;set;}
    public static Map<String,Object> responseMap1;
    
    public Core_IPS_CoveoPageController_New() {
        try{
        List<User> users = [SELECT ID,Name,Core_WWID__c,Profile.Name from User where Id =:userInfo.getUserId()];
        
        //this.cs = (Case)stdController.getRecord();
        //== Storing in the the customGroup value in String.
        Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CoveoInfoCache');
        String customGroup = (String)sessionPart.get('customGroup');
        
        System.debug((customGroup ==null));
        if(customGroup ==null && users[0].Core_WWID__c !=null){
            System.debug('inside the customGroup null');
            //== API connected call.
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Label.Coveo_Apigee_Authorization);
            request.setMethod('POST');
            request.setHeader('Content-Type','application/x-www-form-urlencoded');
            Map<String,String> body = new Map<String,String>();
            String paylod = 'grant_type=client_credentials&client_id='+ Label.Core_Coveo_clientId +'&'+'client_secret='+ Label.Core_Coveo_clientScret;
            System.debug('=>'+paylod);
            request.setBody(paylod);
            Http http = new Http(); 
            HTTPResponse res = http.send(request);
            
            if(res.getStatusCode() == 200){  
                
                map<string,Object> resultMap = (map<string,Object>)JSON.deserializeUntyped(res.getBody());
                
                String authorizationHeader = 'Bearer ' + (String) resultMap.get('access_token');
                HttpRequest req = new HttpRequest();
                req.setTimeout(120000);
                req.setEndpoint(Label.Core_Coveo_endPoint+users[0].Core_WWID__c+'?includeUserRoles=true');
                req.setMethod('GET');
                req.setHeader(Label.Core_Apigee_Auth, authorizationHeader);
                req.setHeader('Content-Type','application/json');
                
                Http http1 = new Http();
                HTTPResponse response = http1.send(req);
                System.debug('result1='+response.getBody());
                if(response.getStatusCode() == 200){
                    List<Object> resultList;

                    if(!Test.isRunningTest()){
                        resultList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                        responseMap1 = (Map<String,Object>)resultList[0];  
                    }
                    String roles = '';
                    String roles1 = '';
                    List<Object> rolesList = (List<Object>)responseMap1.get('roles');
                    System.debug(rolesList);
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
                    
                    System.debug('roles1===>'+roles1);
                    //==  Store Cache Information
                    Cache.SessionPartition sessionPart1 = Cache.Session.getPartition('local.CoveoInfoCache');
                    sessionPart1.put('customGroup', roles1);
                }
            }   
        }
        }catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_CoveoPageController', 'Case');
        }
    }
}