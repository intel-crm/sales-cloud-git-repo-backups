/****************************************************************************************************************************************
* Class Name  : Seismic_CustomPropertiesResponseWrapper 
* Version     : 1.0 
* Created Date: 05/15/2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		The Apex Seismic_CustomPropertiesResponseWrapper for Seismic API Call 
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/
public class Seismic_CustomPropertiesResponseWrapper {
    @TestVisible public String continuationToken {get; private set;} //": "526306a2-a841-3097-34f5-a36b104c9770",
    @TestVisible public String cursor {get; private set;} //": "Audience L0",
    @TestVisible public String kind {get; private set;} //": "526306a2-a841-3097-34f5-a36b104c9770",
    @TestVisible public Integer count {get; private set;} //": "Audience L0",
    @TestVisible public Integer totalCount {get; private set;} //": "string"
    @TestVisible public List<Seismic_CustomPropertyItem> items  {get; set;}
    
    public class Seismic_CustomPropertyItem {
        @TestVisible public String kind {get; private set;} //CustomProperty
        @TestVisible public String name {get; set;} //"_Do Not Use",
        @TestVisible public String propertyType {get; private set;} //": single-select/ "string"
        @TestVisible public Integer order {get; private set;} //": 0
        @TestVisible public String propertyHint {get; private set;} //": null
        
        @TestVisible public List<Seismic_CustomPropertyDOV> domainOfValues  {get; set;}
        @TestVisible public Seismic_CustomPropertySettings settings  {get; private set;}
        @TestVisible public Seismic_CustomPropertyScopes scopes  {get; private set;}
        @TestVisible public Seismic_CustomPropertyTeamSites teamSites  {get; private set;}
        
        @TestVisible public String lastUpdateUserId {get; private set;}
        @TestVisible public String lastUpdateDateTime {get; private set;}
        @TestVisible public String tenantId {get; private set;}
        @TestVisible public String id {get; private set;}
        @TestVisible public String etag {get; private set;}
        @TestVisible public String timestamp {get; private set;}
        
    } 
    
    public class Seismic_CustomPropertyDOV {
        @TestVisible public String id {get; set;}  //119
        @TestVisible public String value {get; set;}  //0
        @TestVisible public Integer order {get; set;}  //0
    }
    
    public class Seismic_CustomPropertySettings {
        @TestVisible public Boolean showInFilter {get; private set;}
        @TestVisible public Boolean showInDocCenter {get; private set;} 
        @TestVisible public Boolean showInDocCenterFilter {get; private set;}
        @TestVisible public Boolean suggestionsEnabled {get; private set;} 
        @TestVisible public Integer searchFacetOrder {get; private set;}
        @TestVisible public Boolean IsSearchable {get; private set;} 
        @TestVisible public String editability {get; private set;} 
    }
    
    public class Seismic_CustomPropertyScopes {
        public Seismic_CustomPropertyContent content {get; private set;}
    }
    
    public class Seismic_CustomPropertyContent {
        public Boolean isRequiredForPublishing {get; private set;}
    }
    
    public class Seismic_CustomPropertyTeamSites {
         public Seismic_CustomPropertyTeamSite one {get; private set;}
    }
    
     public class Seismic_CustomPropertyTeamSite {
         public Integer order {get; private set;}
         public Boolean isVisibleInDocCenter {get; private set;}
    }
    
    
     /*Get Seismic Token*/
    public static String getSeismicToken() {
        String bearerToken ='';
        System.debug('getSeismicToken called');
        String grant_type = 'delegation';
        String client_id = Seismic_PIMDOVSync.config.get('Seismic_client_id');//'0011a2e8-b493-4ac4-ad8d-78b39b4e788f';
        String client_secret = Seismic_PIMDOVSync.config.get('Seismic_client_secret');//'199d1757-e6b8-47c0-8b0b-8b997644c509';
        String user_id = Seismic_PIMDOVSync.config.get('Seismic_user_id');//'5600d223-ed35-48fb-8096-a1e78866426f';
        String scope = 'seismic.custom_property.manage';
        String endPoint = Seismic_PIMDOVSync.config.get('Seismic_Token_endPoint');//'https://auth.seismic.com/tenants/inteldev/connect/token';
        
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
        }
       catch (Exception e) {
           Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in getSeismicToken', 'Error occurred in getSeismicToken : ' + e.getMessage());
           throw e;
        }
        return bearerToken;
    }  
    
    /*Get all DOVs*/
    public static Seismic_CustomPropertiesResponseWrapper getSeismicCustomProperties(String bearerToken) {
        System.debug('getSeismicCustomProperties called');
        HttpResponse response2;
        Seismic_CustomPropertiesResponseWrapper response;
        String endPoint = Seismic_PIMDOVSync.config.get('Seismic_CustomProperties_endPoint');//'https://api.seismic.com/custom-property/v1/customProperties';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(100000);
        request.setEndpoint(endPoint);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        try{
            response2 = http.send(request);
            response = (Seismic_CustomPropertiesResponseWrapper) JSON.deserialize(response2.getBody(), Seismic_CustomPropertiesResponseWrapper.class);
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in getSeismicCustomProperties', 'Error occurred in getSeismicCustomProperties : ' + e.getMessage());
            throw e;
        }
        
        return response;
    }    
    
    
     /*Get DOV by ID*/
    public static Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem getSeismicCustomProperty(String bearerToken, String propertyId) {
        System.debug('getSeismicCustomProperty called');
        HttpResponse response2;
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem response;
        String endPoint = 'https://api.seismic.com/custom-property/v1/customProperties/'+ propertyId;//2ca39024-9064-367e-bdb5-c485637fcff1
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(100000);
        request.setHeader('Content-Type','application/json');
        request.setEndpoint(endPoint);
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        
        try{
            response2 = http.send(request);
            String jsonString = response2.getBody();
            jsonString = jsonString.replace('"hint":', '"propertyHint":');
            jsonString = jsonString.replace('"1":', '"one":');
            jsonString = jsonString.replace('&#44;', ',');
            response = (Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem) JSON.deserialize(jsonString, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem.class);
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in getSeismicCustomProperty', 'Error occurred in getSeismicCustomProperty : ' + e.getMessage());
            throw e;
        }
        
        return response;
    }    

    
      /*Update DOV*/
    public static Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem updateSeismicCustomProperty(String bearerToken, String propertyId, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem customPropertyItem) {
        System.debug('updateSeismicCustomProperty called');
        
        //Don't execute update if it's a TEST
        if(Seismic_PIMDOVSync.config.get('IsTest') == 'True')
        {
            return customPropertyItem;
        }
        
        HttpResponse response2;
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem response;
        String endPoint = 'https://api.seismic.com/custom-property/v1/customProperties/'+ propertyId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        request.setTimeout(100000);
        request.setEndpoint(endPoint);
        request.setHeader('Content-Type','application/json');
        request.setHeader('Authorization', 'Bearer ' + bearerToken);
        String strBody = JSON.serialize(customPropertyItem);
        strBody = strBody.replace('"one":', '"1":');
        strBody = strBody.replace('"propertyHint":', '"hint":');
        System.debug(strBody);
        request.setBody(strBody);
            
        try{
            response2 = http.send(request);
            response = (Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem) JSON.deserialize(response2.getBody(), Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem.class);
            System.debug(strBody);
            
            //Seismic_PIMDOVSync_Notification.senderrorEmail('Try block strBody', 'updateSeismicCustomProperty-strBody : ' + strBody);
            
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in updateSeismicCustomProperty', 'Error occurred in updateSeismicCustomProperty : ' + e.getMessage());
            throw e;
        }
        
        return response;
    }    

}