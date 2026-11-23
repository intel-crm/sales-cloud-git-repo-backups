public with sharing class pricing_ExportQuotes
{

    @AuraEnabled(cacheable=true)
    public static Map<String, List<SBQQ__QuoteLine__c>> getQuoteLineData(Id recordId)
    {
        System.debug('recordID: ' + recordID);
        Map<String, List<SBQQ__QuoteLine__c>> quoteLineItemDataMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        List<SBQQ__QuoteLine__c> quoteLineItemList = [Select Id,Pricing_Quote_Line_Number__c ,Pricing_Status_Nm__c,Pricing_Program_Type_Nm__c from SBQQ__QuoteLine__c where SBQQ__Quote__r.Id =: recordId];
        for(SBQQ__QuoteLine__c quoteLineItem : quoteLineItemList)
        {
            if(quoteLineItemDataMap.keySet().contains(quoteLineItem.Pricing_Program_Type_Nm__c))
            {
                quoteLineItemDataMap.get(quoteLineItem.Pricing_Program_Type_Nm__c).add(quoteLineItem);
            }else {
            
                quoteLineItemDataMap.put(quoteLineItem.Pricing_Program_Type_Nm__c,new List<SBQQ__QuoteLine__c>{quoteLineItem});
            }
        }
        System.debug('quoteLineItemDataMap:=> ' + quoteLineItemDataMap);
        return quoteLineItemDataMap;
    }

    

    // public static void getQuoteLineData(Id quoteId)
    // {


    //     String query = getRecordData(dataCenterFieldSet);
    //     String type = 'Data Center Xeon® CPU';
    //     dataCenterRecords = Database.query(query + ' Where Pricing_Program_Type_Nm__c =:type  AND SBQQ__Quote__r.Id = :quoteId');
    //     System.debug('dataCenterRecords ==>  ' + dataCenterRecords);
    // }

    // public static String getRecordData( List<String> fieldSetList)
    // {
    //     String query = 'SELECT ';
    //     for(String type : fieldSetList)
    //     {
    //         query += getFieldSet(type,'SBQQ__QuoteLine__c'); 
    //     }
    //     query += ' Id FROM ' + 'SBQQ__QuoteLine__c' ;
    //     return query;
    // }

    // public static String getFieldSet(String fieldSetName, String ObjectApiName){
    
    //     String str = '';
    //     List<Schema.FieldSetMember> fieldset = ((SObject)Type.forName(ObjectApiName).newInstance()).getSObjectType().getDescribe().FieldSets.getMap().get(fieldSetName).getFields();
    //     for(Schema.FieldSetMember f : fieldset)
    //     {
    //         str += f.getFieldPath()+ ', ';
    //     }
    //     return str;
    // }
}