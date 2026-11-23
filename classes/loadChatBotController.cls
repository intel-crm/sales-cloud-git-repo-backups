public with sharing class loadChatBotController {    
	@AuraEnabled(cacheable=true)
    public static string getJWToken(){
    	string jwToken = '';
        string jsonString = '';
        dataWrapper userData = getUserDetails();
        jsonString = generateJSON(userData);
        jwToken = generateJWT(jsonString);
        return jwToken;
    }
    
    public static string generateJSON(dataWrapper data){
    	string json = '';        
        JSONGenerator jsonGen = System.JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('firstName',data.firstName);
        jsonGen.writeStringField('lastName',data.lastName);
        jsonGen.writeStringField('userId',data.userId);
        jsonGen.writeStringField('userType',data.userType);
        jsonGen.writeStringField('uniqueId',data.uniqueId);
        jsonGen.writeEndObject();
        json = jsonGen.getAsString();
        
        return json;
    }
    
    public static string generateJWT(string jsonData){
        String header = '{"alg": "HS256","typ":"jwt"}';
		String payload = jsonData;
		string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));

		Blob key = blob.valueof('secret key provided');
		blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
        return jwt+'.'+base64URLencode(signature);
    }
    
    public static string base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
		//output = output.replaceAll('=','');
        return output;
    }
    
    public static dataWrapper getUserDetails(){        
        dataWrapper userDetails = new dataWrapper();
        return retrieveData(userDetails);
    }
    
    private static dataWrapper retrieveData(dataWrapper obj){
        obj.firstName = UserInfo.getFirstName();
        obj.lastName = UserInfo.getLastName();
        obj.userId = UserInfo.getUserId();
        obj.userType = UserInfo.getUserType();
        obj.uniqueId = obj.userId + string.valueOf(Datetime.now());
        return obj;
    }    
         
    public class dataWrapper{
    	string firstName = '';
        string lastName = '';
        string userId = '';
        string userType = '';
        string uniqueId = '';
    }    
}