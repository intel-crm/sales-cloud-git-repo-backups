public class Core_SA_ServiceWrapper {
    public static final string SUCCESS='success';
    public static final string FAIL='fail';
    public static final string STATUS='status';
    public static final string CONTENT_TYPE='Content-Type';
    public static final string CONTENT_TYPE_JSON='application/json;charset=UTF-8';
    public static final string API_KEY='API_KEY';
    public static final string FALSE_VALUE='false';   
    public static final Integer TIME_OUT=60000; 
    public static final string METHOD='GET'; 
    
    // Method to call Sales Assist API and get the response
    @AuraEnabled
    public static Core_SA_Top3AssistsDefination getTop3Assists(String cim_id, String user_id) {
		Core_SA_Top3AssistsDefination Top3;
		string input1;
        
		//Set up new HTTP Request
		Http http = new Http();
		HttpRequest request = new HttpRequest();
            
		//Get credentails and end point from named value credentials 
		if((!String.isBlank(cim_id))  && (!String.isBlank(user_id)) ){
			request.setEndpoint('callout:Core_SA_ServiceCredentials' + '/topassist?cim_id='+cim_id+'&user_id='+user_id);
		}
        
        system.debug('End Point: '+ request.getEndpoint());

		request.setMethod(METHOD);
		request.setTimeout(TIME_OUT);
            
		//Get the API-Key value from the custom settings
		Core_SA_API_Key__c apiKey = Core_SA_API_Key__c.getValues(API_KEY); 
		request.setHeader(API_KEY, apiKey.SA_API_KEY__c);
		request.setHeader(CONTENT_TYPE, CONTENT_TYPE_JSON);
                       
        HttpResponse response;
            
		try{
			//publish constructed request to Mulesoft
			response = http.send(request);
			system.debug('response:'+response.getBody());
			
			if (response!=Null && response.getStatusCode() == 200) {
				
				//Parse JSON data
				Top3 = Core_SA_Top3AssistsDefination.parse(response.getBody());
				
				//Print debug messages
				System.debug('show = '+ Top3.show);
				System.debug('count = '+ Top3.total_count);
				System.debug('sizd = '+ Top3.AssistDetails.size());  
				
				//Loop thru the assists collection
				Integer idx = 0;
				for(Core_SA_Top3AssistsDefination.Assist assist : Top3.AssistDetails){
					idx = idx + 1;

					if(assist.L1Val.contains('</>')){
						List<String> res = assist.L1Val.split('</>', 2);
						System.debug(res);
						assist.L1Val = '<a href="' + res[0] + '" class="textUnderline outputLookupLink slds-truncate" target="_blank">' + res[1] + '</a>';
					}

					if(assist.L2Val.contains('</>')){
						List<String> res = assist.L2Val.split('</>', 2);
						System.debug(res);
						assist.L2Val = '<a href="' + res[0] + '" class="textUnderline outputLookupLink slds-truncate" target="_blank">' + res[1] + '</a>';
					}
					
					if(assist.L3Val.contains('</>')){
						List<String> res = assist.L3Val.split('</>', 2);
						System.debug(res);
						assist.L3Val = '<a href="' + res[0] + '" class="textUnderline outputLookupLink slds-truncate" target="_blank">' + res[1] + '</a>';
					}
					
					//Print debug data
					System.debug('Id = '+ assist.assist_id);
					System.debug('name = '+ assist.title);
					System.debug('L1Key = '+ assist.L1Key);
					System.debug('L1Val = '+ assist.L1Val);
					System.debug('L2Key = '+ assist.L2Key);
					System.debug('L2Val = '+ assist.L2Val);
					System.debug('L3Key = '+ assist.L3Key);
					System.debug('L3Val = '+ assist.L3Val);
					System.debug('CIMID = '+ assist.cim_id);
					System.debug('User ID = '+ assist.user_id);
					
					System.debug('---------------------------------------------');
				}				
			}
			//if the status code is not 200, then exception
            else {
                system.debug('Service Unavailable getTop3Assists:'+response.getStatusCode());
                //formulate JSON data
                input1 = '{"AssistDetails":[],"show":false,"total_count":0}';
                
                //Parse JSON data
                Top3 = Core_SA_Top3AssistsDefination.parse(input1);
                
                //Print debug messages                    
                System.debug('---------------------------------------------');
                System.debug('show = '+ Top3.show);
                System.debug('count = '+ Top3.total_count);
                System.debug('sizd = '+ Top3.AssistDetails.size());  
                System.debug('---------------------------------------------');
			}
        }
		catch(Exception e){
			//in case of any exception
			system.debug('SA Service Callout getTop3Assists:'+e.getMessage());
            system.debug('Service Unavailable getTop3Assists:'+response.getStatusCode());
            //formulate JSON data
            input1 = '{"AssistDetails":[],"show":false,"total_count":0}';
            
            //Parse JSON data
            Top3 = Core_SA_Top3AssistsDefination.parse(input1);
            
            //Print debug messages                    
            System.debug('---------------------------------------------');
            System.debug('show = '+ Top3.show);
            System.debug('count = '+ Top3.total_count);
            System.debug('sizd = '+ Top3.AssistDetails.size());  
            System.debug('---------------------------------------------');            
		}
		finally {

		}
		return(Top3);        
    }

    public Core_SA_Top3AssistsDefination Top3 {
        get;
        set;
    }

    // Method to call Sales Assist API and get the response
    @AuraEnabled
    public static Core_SA_UnreadAssistsDefination getNewAssists(String cim_id, String user_id) {
        String input1;
        Core_SA_UnreadAssistsDefination TotalAssists;
        
		//Set up new HTTP Request
		Http http = new Http();
		HttpRequest request = new HttpRequest();
            
		//Get credentails and end point from named value credentials 
		if(cim_id!=null && user_id!=null){
			request.setEndpoint('callout:Core_SA_ServiceCredentials' + '/unreadassist?cim_id='+cim_id+'&user_id='+user_id);
		}
        system.debug('EP:' + request.getEndpoint());
		request.setMethod(METHOD);
		request.setTimeout(TIME_OUT);
            
            
		//Get the API-Key value from the custom settings
		Core_SA_API_Key__c apiKey = Core_SA_API_Key__c.getValues(API_KEY); 
		request.setHeader(API_KEY, apiKey.SA_API_KEY__c);
		request.setHeader(CONTENT_TYPE, CONTENT_TYPE_JSON);
            
            
        HttpResponse response;
            
		try{
			//publish constructed request to Mulesoft
			response = http.send(request);
			system.debug('response:'+response.getBody());
			
			if (response!=Null && response.getStatusCode() == 200) {
        
                //Parse JSON Object
                TotalAssists = Core_SA_UnreadAssistsDefination.parse(response.getBody());
                
                //print debug values
                System.debug('Content = '+ TotalAssists.content);
                System.debug('show = '+ TotalAssists.show);
                //System.debug('NumAssists = '+ TotalAssists);
                System.debug('---------------------------------------------');
            }
			//if the status code is not 200, then exception
			else {
            	//formulate JSON data
            	input1 = '{"content":"You Have 0 Unread Assists!","show":false,"total_count":0}';
           		//Parse JSON data
            	TotalAssists = Core_SA_UnreadAssistsDefination.parse(input1);
				
				if(response!=Null){
					system.debug('SA Service Callout Failed getNewAssists: '+ response.getStatusCode());
				}
			}
        }
		catch(Exception e){
            //formulate JSON data
            input1 = '{"content":"You Have 0 Unread Assists!","show":false,"total_count":0}';
            //Parse JSON data
            TotalAssists = Core_SA_UnreadAssistsDefination.parse(input1);
			//in case of any exception
			system.debug('SA Service Callout getNewAssists Exception: '+ e.getMessage());
		}
		finally {

		}
        // return TotalAssists of Type SAUserAssistsDefination
   		return(TotalAssists);
    }
    
    // In apex class you can get the user information and session Id as written below
    // this method is called SalesAssists Lightning component and Tab
    @AuraEnabled
    public static Core_SA_UserSessionDefination getUserSessionData(String accountId){
        String sessionId = '';
        Core_SA_UserSessionDefination userSession;
        String cimId = '';
		String sid = '';
        
        if(!String.isBlank(accountId))
        {
            //query account object
            Account acct  = [SELECT Core_CIM_ID__c FROM Account  WHERE Id=:accountId LIMIT 1 ];
            //get CIM ID
            cimId = acct.Core_CIM_ID__c;
            System.debug('getUserSessionData cimId: ' + cimId );
        }
        
        //Query User Object to get the user WWID based on the current user ID
        User u = [select Core_WWID__c from user where Id =: UserInfo.getUserId() LIMIT 1];
        
        //system debug messages
        System.debug('getUserSessionData OrgIds: ' + UserInfo.getOrganizationId()+' SessionId:'+UserInfo.getSessionId()  );
        System.debug('getUserSessionData wwid: ' + u.Core_WWID__c +' email:'+ UserInfo.getUserEmail()  );
        
        //get session ID from Visualforce Page named GetSessionIdPage
        if(!Test.isRunningTest()) {
        	PageReference newPage = Page.GetSessionIdPage;
        	String content = newPage.getContent().toString();
        
        	//scrap the VF page content to retrieve sessionID
         	sid = content.substringBetween('<SessionId>', '</SessionId>');
        }
        
        //Build JSON String and Parse
        sessionId ='{"orgId":"'+ UserInfo.getOrganizationId() + '","cimId":"' + cimId  + '","SessionId":"' + sid + '","wwid":"' + u.Core_WWID__c + '","email":"' + UserInfo.getUserEmail() + '"}';
        userSession = Core_SA_UserSessionDefination.parse(sessionId);
        
        //system debug messages
        System.debug('getUserSessionData JSON serialized: ' + JSON.serialize(sessionId));        
        System.debug('getUserSessionData cimId = '+ userSession.cimId);
        System.debug('getUserSessionData orgId = '+ userSession.orgId);
        System.debug('getUserSessionData SessionId = '+ userSession.SessionId);
        System.debug('getUserSessionData wwid = '+ userSession.wwid);
        System.debug('getUserSessionData email = '+ userSession.email);
        System.debug('getUserSessionData userSession = '+ userSession);
        
        System.debug('---------------------------------------------');
         // Return Session Id
        return (userSession);
 	}  
/*
    @AuraEnabled
    public static Core_SA_Top3AssistsDefination getTop3AssistsStatic() {
        //formulate JSON data
        string input1 = '{"total_count":3,"show":true,"AssistDetails":[{"title":"Assists Type 1","assist_id":"123","L1Key":"Contact","L1Val":"moti_akler@amat.com","L2Key":"Visit Date","L2Val":"30 Dec 2019","L3Key":"Product","L3Val":"Intel Xeon Bronze 3104 Processor","cim_id":"10102555","user_id":"1000"},{"title":"Assists Type 2","assist_id":"456","L1Key":"Url","L1Val":"https://www.google.com.</>Link to Google","L2Key":"Date","L2Val":"20 Aug 2019","L3Key":"Product","L3Val":"AMD ryzen 1400","cim_id":"10102555","user_id":"1000"},{"title":"Assists Type 3","assist_id":"789","L1Key":"Purchased Units","L1Val":"1133","L2Key":"Last Purchase Date","L2Val":"22 Sep 2019","L3Key":"Product","L3Val":"Intel SSD 545s Series,","cim_id":"10102555","user_id":"1000"}]}';
        //Parse JSON data
        Core_SA_Top3AssistsDefination Top3 = Core_SA_Top3AssistsDefination.parse(input1);
        
        //Print debug messages
        System.debug('show = '+ Top3.show);
        System.debug('count = '+ Top3.total_count);
        System.debug('sizd = '+ Top3.AssistDetails.size());  
        
        //Loop thru the assists collection
        Integer idx = 0;
        for(Core_SA_Top3AssistsDefination.Assist assist : Top3.AssistDetails){
            idx = idx + 1;

            if(assist.L1Val.contains('</>')){
                List<String> res = assist.L1Val.split('</>', 2);
				System.debug(res);
        		assist.L1Val = '<a href="' + res[0] + '" class="textUnderline outputLookupLink slds-truncate" target="_blank">' + res[1] + '</a>';
    		}

            if(assist.L2Val.contains('</>')){
                List<String> res = assist.L2Val.split('</>', 2);
				System.debug(res);
        		assist.L2Val = '<a href="' + res[0] + '" class="textUnderline outputLookupLink slds-truncate" target="_blank">' + res[1] + '</a>';
    		}
            
            if(assist.L3Val.contains('</>')){
                List<String> res = assist.L3Val.split('</>', 2);
				System.debug(res);
        		assist.L3Val = '<a href="' + res[0] + '" class="textUnderline outputLookupLink slds-truncate" target="_blank">' + res[1] + '</a>';
    		}

            
            //Print debug data
            System.debug('Id = '+ assist.assist_id);
            System.debug('name = '+ assist.title);
            System.debug('L1Key = '+ assist.L1Key);
            System.debug('L1Val = '+ assist.L1Val);
            System.debug('L2Key = '+ assist.L2Key);
            System.debug('L2Val = '+ assist.L2Val);
            System.debug('L3Key = '+ assist.L3Key);
            System.debug('L3Val = '+ assist.L3Val);
            System.debug('CIMID = '+ assist.cim_id);
            System.debug('User ID = '+ assist.user_id);
            
            System.debug('---------------------------------------------');
        }
   		return(Top3);
    }

    // Method to call Sales Assist API and get the response
    @AuraEnabled
    public static Core_SA_UnreadAssistsDefination getNewAssistsStatic() {
        //formulate JSON data
        string input ='{"content":"You Have 31 Unread Assists!", "show":true}';
        System.debug('input = '+ input);
        
		//Parse JSON Object
		Core_SA_UnreadAssistsDefination TotalAssists = Core_SA_UnreadAssistsDefination.parse(input);
        
        //print debug values
        System.debug('Content = '+ TotalAssists.content);
        System.debug('show = '+ TotalAssists.show);
        System.debug('NumAssists = '+ TotalAssists);
        System.debug('---------------------------------------------');
        
        // return TotalAssists of Type SAUserAssistsDefination
   		return(TotalAssists);
    }    

    // Method to get CIM ID related to the Account
    @AuraEnabled
    public static String getAccountCIM(String accountId) {
       	String cimId;

        try
        {
            System.debug('accountId:' + accountId);

            //query account object
        	Account acct  = [SELECT Core_CIM_ID__c FROM Account  WHERE Id=:accountId LIMIT 1 ];
            
            //get CIM ID
            cimId = acct.Core_CIM_ID__c;
            
            System.debug('cimId:' + cimId);
        } 
        catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        return cimId;
    } */
}