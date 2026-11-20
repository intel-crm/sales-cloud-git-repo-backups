public with sharing class Core_ContactGEC_Service {

    public static final String Patch_Method = 'PATCH';
    

/*
* Method name  : SendGECInfoTOAGS
* Description  : Method to call from Batch class by passing the Gec Staging Information to send it to AGS
* Return Type  : HttpResponse
* Parameter    : Gec Staging,AGS AccessToken,AGS EndPoint,Contact JSON
*/

    public static HttpResponse SendGECInfoTOAGS(Core_Contact_GEC_Staging__c gec,String ContactJSONRes){
            
        try{
            Map < String , String > mapOfHeaders = new Map < String, String> {
                'Content-Type' => 'application/json' };
            String agsEndPoint = 'callout:SalesCRM_Apigee/m2r/global-export-compliance/v1/identities/' + gec.Core_Contact_ID__c + '?action=' + (gec.Core_GEC_Blocked__c ? 'disable' : 'enable') ;
            Core_RestClient restClient = new Core_RestClient(agsEndPoint, Patch_Method, mapOfHeaders, ContactJSONRes, 120000);
            return restClient.invokeAPI();

        }catch(Exception e){
            return null;
        }  
    }

/*
* Method name  : ContactGECJSON
* Description  : This Method is used to prepare the Contact JSON body to send it to AGS
* Return Type  : None
* Parameter    : String DisableBy,String DisableReason,Boolean GECFlag,String EnterpriseID
*/


    public static String ContactGECJSON(String DisableBy,String DisableReason,Boolean GECFlag,String EnterpriseID){
        //system.debug('$$$$$$GECflag'+GECFlag);
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        if(GECFlag !=null && GECFlag ==true){
            jsonGen.writeFieldName('urn:scim:schemas:extension:inteluser:1.0');
            jsonGen.writeStartObject(); 
            
            if(DisableBy!='' && DisableBy!=null){
                jsonGen.writeStringField('disabledBy',Label.Core_GEC_DisabledBy);
            }
            else{
                jsonGen.writeStringField('disabledBy',Label.Core_GEC_DisabledBy);
            }
            
            if(DisableReason!='' && DisableReason!=null){
                jsonGen.writeStringField('disableReason',Label.Core_GEC_Disabled_Reason);
            }else{
                jsonGen.writeStringField('disableReason',Label.Core_GEC_Disabled_Reason);
            }
            jsonGen.writeEndObject();
        }
        jsonGen.writeStringField('Active',String.valueOf(!GECFlag));
        //jsonGen.writeStringField('Active','false');
        String Urn='['+'urn:scim:schemas:core:1.0,'+'urn:scim:schemas:extension:inteluser:1.0'+']';
        jsonGen.writeStringField('Schemas',Urn);
        if(EnterpriseID!='' && EnterpriseID!=null){
            jsonGen.writeStringField('Id',EnterpriseID);
        }else{
            jsonGen.writeStringField('Id','');
        }    
        jsonGen.writeEndObject();
        String jsonData = jsonGen.getAsString();
        return jsonData;       
        
    }
}