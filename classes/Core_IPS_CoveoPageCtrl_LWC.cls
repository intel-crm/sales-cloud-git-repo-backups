public without sharing class Core_IPS_CoveoPageCtrl_LWC {
    
    public static List<String> customList;
    public static Map<String,Object> responseMap1;
    public static String userEmail;
    public static String customGroup;
    public static Organization org;
    
    public static Core_IPS_Coveo_TokenGenerator__c coveorec = Core_IPS_Coveo_TokenGenerator__c.getInstance('Core_IPS_Coveo'); //TWC745-6469-IPS Named Credentials chnage
    public static String CoveoEndpoint = coveorec.Core_IPS_CoveoEndpoint__c;//TWC745-6469
    @AuraEnabled(cacheable=false)
    public static String generateToken() {
       
        try{ 
            List<User> users = [SELECT ID,Name,Core_WWID__c,Profile.Name,Email from User where Id =:userInfo.getUserId()]; 
            org = [SELECT Id from Organization limit 1][0];
            userEmail = users[0].Email;
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CoveoInfoCache');
            customGroup = (String)sessionPart.get('customGroup');
            if( customGroup ==null && users[0].Core_WWID__c !=null){
 	    generateTokenPart3(users,sessionPart);
            }
            else if(customGroup != null){
                customList = customGroup.split(';');
            }
            else if(users[0].Core_WWID__c == null){
                 userEmail = generateTokenPart4(userEmail);
            }
            String AccessToken = generateTokenPart2();
            return AccessToken;
        }catch(Exception e){
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Core_IPS_CoveoPageController', 'Case');
            return null;
        }
        
       
        
    }
    public static String generateTokenPart2() {
        try{
            //added By Hassan for Authorization issue Fix.
            String ipsAuthorization = System.Label.IPS_Authorization; 
            HttpRequest req = new HttpRequest();
            req.setEndpoint(CoveoEndpoint);
            //req.setEndpoint('https://intelcorporationnonproduction2ybdyblf7.org.coveo.com/rest/search/v2/token?organizationId=orgid');
            req.setMethod('POST');
            String body = '{"pipeline":"IPSSBS","searchHub":"IPSSBS","validFor":86400000,"userGroups":'+JSON.serialize(customList)+', "licenseDefinitionKey": "SFDC","salesforceOrganizationId": "'+org.id+'","v8": true,"userIds":[{"provider":"Email Security Provider","name":"'+userEmail+'","intel":{}}]}';
            req.setBody(body);
            req.setHeader('Content-Type','application/json;charset=UTF-8');
            
            String authorizationHeader = coveorec.Core_IPS_Coveo_Token__c; //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
            req.setHeader(ipsAuthorization, authorizationHeader);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Token accessToken = (Token) System.JSON.deserialize(res.getBody(), Token.Class);
            String str = accessToken.token;
            return accessToken.token;
        }
        catch(Exception e){
            return null;
        }
    }
    
    
    public static void generateTokenPart3(List<User> users ,Cache.SessionPartition sessionPart){ //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
        String roles = '';
        String roles1 = '';

       		    String incluserrole = users[0].Core_WWID__c+'?includeUserRoles=true'; //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
                    
                    HttpRequest req = new HttpRequest();
                    req.setTimeout(120000);
                    
		    req.setEndpoint('callout:Core_IPS_CoveoNamedCred/'+incluserrole); //TWC745-6469-IPS Coveo Named Credentials - Gangadhar
                    req.setMethod('GET');
                    
                    req.setHeader('Content-Type','application/json');
                    
                    Http http1 = new Http();
                    HTTPResponse response = http1.send(req);
                    if(response.getStatusCode() == 200){
                        List<Object> resultList;
                        if(!Test.isRunningTest()){
                            resultList = (List<Object>)JSON.deserializeUntyped(response.getBody());
                            responseMap1 = (Map<String,Object>)resultList[0];  
                        }
                        
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
                         String roles1val= generateTokenPart5(finalList,roles,roles1,users);
                        roles1 = roles1val+'U:Public';
                        
                        //==  Store Cache Information
                        Cache.SessionPartition sessionPart1 = Cache.Session.getPartition('local.CoveoInfoCache');
                        sessionPart1.put('customGroup', roles1);
                        List<String> listOfRoles = roles1.split(';');
                        customList = listOfRoles;
                        sessionPart.remove('customGroup');
                        
                    }
                
    }
    
     public static String generateTokenPart4(String userEmailvalue ){
        List<String> lstOfRole = new List<String>{'U:Public', 'anonymous'};
            customList = lstOfRole;
        if(userEmailvalue == null || userEmailvalue == ''){
            userEmailvalue = 'anonymous';                    
        }
        return userEmailvalue;

    }
    
    public static String generateTokenPart5(list<String> finalList,String roles,String roles1,list<User> users){
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
        return roles1;
   }
    
    public class Token{
        public String token;
    }
    
}