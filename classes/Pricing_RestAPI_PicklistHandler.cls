/****************************************************************************************************************************************
* Class Name  : Pricing_RestAPI_PicklistHandler 
* Version     : 1.0 
* Created Date: 06 Oct 2020
* Modification Log :
* Developer                 Date                  Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Team: Accenture         06/10/2020              Handler class for Pricing_RestAPI_PickList API
*****************************************************************************************************************************************/
public without sharing class Pricing_RestAPI_PicklistHandler {
    
    private DateTime ENTRY_TIME;
    private String RESTAPI_NAME; 
    private static boolean isValid = true;
    
    //private static Map<String,Schema.SObjectField> sObjFieldMap = new Map<String,Schema.SObjectField>();
    public Pricing_RestAPI_Response response = new Pricing_RestAPI_Response();
    
    public Pricing_RestAPI_PicklistHandler (DateTime currTime, String APIname){
        this.ENTRY_TIME = currTime;
        this.RESTAPI_NAME = APIname;
        //System.debug('Pricing_RestAPI_Handler URI '+RestContext.request.requestURI  );
    }
    
    public Pricing_RestAPI_Response getPicklistValues(){
        user currentUser = [Select Id, ContactId,AccountId from User where Id = :UserInfo.getUserId()];
        try{
            String inputFldLabel =  Pricing_RestAPI_Util.getInputFromURIParam(Integer.valueOf(Label.Pricing_IQR_PicklistUtility_Param_Index));
            String decodedFldNm = String.isEmpty(inputFldLabel)? null : EncodingUtil.urlDecode(inputFldLabel, 'UTF-8');
            if(!String.isEmpty(decodedFldNm)){
                List<PickListEntry> pickListValues = new List<PickListEntry>();
                if(decodedFldNm.toLowerCase().equals(Label.Pricing_IQR_API_EndCustomer.toLowerCase())){
                    pickListValues.addAll(getEndCustomerValues(currentUser));
                }
                else if(decodedFldNm.toLowerCase().equals(Label.Pricing_IQR_API_ConsumptionPlatform.toLowerCase()) || decodedFldNm.toLowerCase().equals(Label.Pricing_IQR_API_ConsumptionSalesGeo.toLowerCase()) || decodedFldNm.toLowerCase().equals(Label.Pricing_IQR_API_ConsumptionSegment.toLowerCase())){
                    pickListValues.addAll(getConsumptionValues(decodedFldNm.toLowerCase().equals(Label.Pricing_IQR_API_ConsumptionPlatform.toLowerCase()) ?'Consumption Platform' 
                                                               : decodedFldNm.toLowerCase().equals(Label.Pricing_IQR_API_ConsumptionSalesGeo.toLowerCase()) ? 'Consumption Sales Geo' 
                                                               : 'Consumption Segment',currentUser));
                }
                else{
                    List<Pricing_Picklist_FieldNames_Mapping__mdt> fldMappingMdt = [SELECT Pricing_FieldAPI_Nm__c,Pricing_ObjectAPI_Pkl__c,Pricing_RecordTypeAPI_Pkl__c
                                                                                    FROM Pricing_Picklist_FieldNames_Mapping__mdt 
                                                                                    WHERE MasterLabel= :decodedFldNm AND Pricing_IsActive_Ind__c=True];
                    if(fldMappingMdt.size() > 0){//check if Metadata is configured for the field
                        if(Schema.getGlobalDescribe().containsKey(fldMappingMdt[0].Pricing_ObjectAPI_Pkl__c)){//Check if the Sobject with the configured name is available in system
                            //Get al fields map from SObject
                            Map<String,Schema.SObjectField> sObjFieldMap = ((SObject)Type.forName(fldMappingMdt[0].Pricing_ObjectAPI_Pkl__c).newInstance()).getSObjectType().getDescribe().fields.getMap();
                            if(sObjFieldMap.containsKey(fldMappingMdt[0].Pricing_FieldAPI_Nm__c)){//Chek if the configured field is available on the SObject
                                
                                //Map<String,Object> recrdTypeMap = (Map<String,Object>) Schema.getGlobalDescribe().get(fldMappingMdt[0].Pricing_ObjectAPI_Pkl__c).getDescribe().getRecordTypeInfosByDeveloperName();
                                Map<String,Object> recrdTypeMap = (Map<String,Object>) ((SObject)Type.forName('Pricing_Picklist_Metadata__c').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
                                //Pricing_Picklist_Metadata__c
                                if(String.isEmpty(fldMappingMdt[0].Pricing_RecordTypeAPI_Pkl__c) || recrdTypeMap.size() ==0 || !recrdTypeMap.containsKey(fldMappingMdt[0].Pricing_RecordTypeAPI_Pkl__c)){
                                    //If record type is not configured OR if worng record type is configured
                                    getValuesWithoutRecordType(pickListValues, sObjFieldMap.get(fldMappingMdt[0].Pricing_FieldAPI_Nm__c).getDescribe().getPicklistValues());
                                }else{
                                    //If right right Object,Field Name and Record Type name is configured
                                    getValuesWithRecordType(pickListValues, fldMappingMdt[0]);                                
                                }
                            }else{
                                //Error - Wrong field name mapped
                                Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                            }
                        }else{
                            //Error Response - Wrong Object name configured
                            //processExp(null,Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011); 
                            Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                            
                        }
                    }else {
                        //Error Response - FiledName mapping not available 
                        Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.MALFORMED_INPUT_9011, response, RESTAPI_NAME, ENTRY_TIME);
                    } 
                }
                if(pickListValues.size()>0){
                    response.successContent = pickListValues; 
                    response.totalRecords = pickListValues.size(); 
                }else{
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }else{
                //Send list of all configured field names as response if FieldName is not passes as input                
                FieldNames fldNames = new FieldNames();
                getAvailableFieldNames(fldNames);   
                if(fldNames.fieldNames.size() > 0){
                    response.successContent = new List<FieldNames>{fldNames}; 
                        response.totalRecords = fldNames.fieldNames.size() ; 
                }else{
                    //No Active field config in Metadata
                    Pricing_RestAPI_Util.processException(null, Pricing_RestAPI_ResponseCodes.NO_DATA_EXCEPTION_9001, response, RESTAPI_NAME, ENTRY_TIME);
                }
            }//End of IF-Else - decodedFldNm empty check 
        }catch(Exception exp){ 
            Pricing_RestAPI_Util.processException(exp, Pricing_RestAPI_ResponseCodes.ERROR_CODE_500, response, RESTAPI_NAME, ENTRY_TIME);            
        }finally {
            if(String.isBlank(response.code)){
                response.code = Pricing_RestAPI_ResponseCodes.SUCCESS_CODE_200; 
            }                
            Pricing_RestAPI_LoggingUtil.logTransaction(ENTRY_TIME, response,currentUser);            
        }
        return response;
    }
    private static List<PickListEntry> getEndCustomerValues(user currentUser){
        String searchTxt = Pricing_RestAPI_Util.getRequestParam('searchText');
        searchTxt = String.isBlank(searchTxt) ? '':'%'+searchTxt+'%';
        String rowsLimit = Pricing_RestAPI_Util.getRequestParam('limit');
        Integer rowsLimitInt = !String.isBlank(rowsLimit) && rowsLimit.isNumeric() ? Integer.valueOf(rowsLimit) : 0;
        String rowsOffset = Pricing_RestAPI_Util.getRequestParam('offset');
        Integer rowsOffsetInt = !String.isBlank(rowsOffset) && rowsOffset.isNumeric() ? Integer.valueOf(rowsOffset) : 0;
        List<PickListEntry> pickListValues = new List<PickListEntry>();
        List<Pricing_UnifiedEndCustomerAccountMapping__c> endCustmrLst = new List<Pricing_UnifiedEndCustomerAccountMapping__c>(String.isBlank(searchTxt) ? [select Id, Name from Pricing_UnifiedEndCustomerAccountMapping__c where Pricing_Active_cb__c = true and (Pricing_Account_Nm__c = :currentUser.AccountId OR Name=:Label.Pricing_IQR_API_WriteInEndCustomer)] :
                                                                                                                              searchTxt.contains(Label.Pricing_IQR_API_WriteInEndCustomer) ? [select Id, Name from Pricing_UnifiedEndCustomerAccountMapping__c where Pricing_Active_cb__c = true  AND Name =: Label.Pricing_IQR_API_WriteInEndCustomer] : [select Id, Name from Pricing_UnifiedEndCustomerAccountMapping__c where Pricing_Active_cb__c = true and Pricing_Account_Nm__c = :currentUser.AccountId AND Name Like :searchTxt]);
        if(rowsOffsetInt >= endCustmrLst.size()){            
            rowsOffsetInt = 0;
        }
        if(rowsLimitInt > 0 && rowsOffsetInt >= 0){
            Integer counter = 0;
            for(Integer start=rowsOffsetInt; counter < rowsLimitInt && start < endCustmrLst.size()  ; start++){
                Pricing_UnifiedEndCustomerAccountMapping__c endCustmr = endCustmrLst.get(start);
                pickListValues.add(new PickListEntry(endCustmr.Name, String.ValueOf(endCustmr.Id)));
                ++counter;
            }
        }else{
            for(Pricing_UnifiedEndCustomerAccountMapping__c endCustmr : endCustmrLst){
                pickListValues.add(new PickListEntry(endCustmr.Name, String.ValueOf(endCustmr.Id)));
            }
            
        }  
        return pickListValues;
    }
    @testVisible
    private static List<PickListEntry> getConsumptionValues(String decodedFldNm,user currentUser){
        String searchTxt = Pricing_RestAPI_Util.getRequestParam('searchText');
        searchTxt = String.isBlank(searchTxt) ? '':'%'+searchTxt+'%';
        String rowsLimit = Pricing_RestAPI_Util.getRequestParam('limit');
        Integer rowsLimitInt = !String.isBlank(rowsLimit) && rowsLimit.isNumeric() ? Integer.valueOf(rowsLimit) : 0;
        String rowsOffset = Pricing_RestAPI_Util.getRequestParam('offset');
        Integer rowsOffsetInt = !String.isBlank(rowsOffset) && rowsOffset.isNumeric() ? Integer.valueOf(rowsOffset) : 0;
        List<PickListEntry> pickListValues = new List<PickListEntry>();
        List<Pricing_ConsumptionAccountMapping__c> consumptionLst = String.isBlank(searchTxt)?[select Id, Name from Pricing_ConsumptionAccountMapping__c where Pricing_Consumption_Type_Nm__c =: decodedFldNm and (Pricing_Account_Nm__c = :currentUser.AccountId ) and Pricing_Active_ind__c = true]:
                                                                                          [select Id, Name from Pricing_ConsumptionAccountMapping__c where Pricing_Consumption_Type_Nm__c =: decodedFldNm and Pricing_Account_Nm__c = :currentUser.AccountId AND Name Like :searchTxt and Pricing_Active_ind__c = true];
	    
        if(rowsOffsetInt >= consumptionLst.size()){            
            rowsOffsetInt = 0;
        }
        if(rowsLimitInt > 0 && rowsOffsetInt >= 0){
            Integer counter = 0;
            for(Integer start=rowsOffsetInt; counter < rowsLimitInt && start < consumptionLst.size()  ; start++){
                Pricing_ConsumptionAccountMapping__c consumption = consumptionLst.get(start);
                pickListValues.add(new PickListEntry(consumption.Name, String.ValueOf(consumption.Name)));
                ++counter;
            }
        }else{
            for(Pricing_ConsumptionAccountMapping__c consumption : consumptionLst){
                pickListValues.add(new PickListEntry(consumption.Name, String.ValueOf(consumption.Name)));
            }
            
        } 
        return pickListValues;
    }
    private static void getValuesWithoutRecordType(List<PickListEntry> pickListValues, List<Schema.PicklistEntry> plEntries){
        for(Schema.PicklistEntry ple: plEntries){
            if(ple.isActive()){
                pickListValues.add(new PickListEntry(ple.getValue(), ple.getValue()));
            }                                  
        }
    }
    private static void getValuesWithRecordType(List<PickListEntry> pickListValues, Pricing_Picklist_FieldNames_Mapping__mdt fldMappingMdt){
        //Pricing_FieldAPI_Nm__c,Pricing_ObjectAPI_Pkl__c,Pricing_RecordTypeAPI_Pkl__c
        List<Pricing_Picklist_Metadata__c> plMdts = [SELECT id,Pricing_Picklist_Item_Label_Txt__c,Pricing_Picklist_Item_Value_Txt__c FROM Pricing_Picklist_Metadata__c 
                                                     WHERE Pricing_Field_API_Nm__c=:fldMappingMdt.Pricing_FieldAPI_Nm__c AND Pricing_Object_API_Nm__c=:fldMappingMdt.Pricing_ObjectAPI_Pkl__c
                                                     AND RecordType.Name=:fldMappingMdt.Pricing_RecordTypeAPI_Pkl__c 
                                                     AND Pricing_IsActive_Ind__c=True ORDER BY Pricing_Picklist_Item_Label_Txt__c ASC];
        if(plMdts.size() > 0){
            for(Pricing_Picklist_Metadata__c plMdt : plMdts){
                pickListValues.add(new PickListEntry(plMdt.Pricing_Picklist_Item_Label_Txt__c,plMdt.Pricing_Picklist_Item_Value_Txt__c));
            }            
        }
    }
    private static void getAvailableFieldNames(FieldNames fldNames){
        fldNames.fieldNames = new List<String>();
        List<Pricing_Picklist_FieldNames_Mapping__mdt> fldMappingMdt = [SELECT MasterLabel FROM Pricing_Picklist_FieldNames_Mapping__mdt 
                                                                        WHERE Pricing_IsActive_Ind__c=True ORDER BY MasterLabel];
        if(fldMappingMdt.size() > 0){
            for(Pricing_Picklist_FieldNames_Mapping__mdt fldMapMdt :fldMappingMdt ){
                fldNames.fieldNames.add(fldMapMdt.MasterLabel); 
            }
        }
    }
    public class PickListEntry implements Pricing_RestAPI_SuccessContent {
        public String label {set;get;}
        public String value {set;get;}
        public PickListEntry(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    public class FieldNames implements Pricing_RestAPI_SuccessContent {
        public List<String> fieldNames {set;get;}
    }
    
}