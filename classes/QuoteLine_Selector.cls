//Selector layer classes should all use the inherited sharing keyword so that the caller 
//determines to context it operates in.
//It should also always extend the fflib_SObjectSelector so it can inherit that classes 
//methods and functionality.
//creating an selector class which will contain methods which has the query on the sObject running arround the org.
//it extends the fflib_SObjectSelector which is a class that defines the selector framework.
//it implements IQuoteLineSelector which has the interface of the methods implemented here.
public inherited sharing class QuoteLine_Selector extends fflib_SObjectSelector implements IQuoteLineSelector {
    //In our selector classes constructor we are calling the fflib_SObjectSelector using the super() call
        //and setting out parameters.
     public QuoteLine_Selector() {
         /*This is calling the fflib_SObjectSelector classes constructor and setting 
                  the following booleans:
                  1) If the selector queries should use field sets
                  2) If you would like to enforce CRUD security
                  3) If you would like to enforce FLS
                  4) If you would like to sort selected fields
                */
          super(false,true,true,false);
    }
    
    //method to create instance using the mapping in the application class for the sObject and selector class.
    public static IQuoteLineSelector newInstance(){
        return (IQuoteLineSelector)Application.Selector.newInstance(SBQQ__QuoteLine__c.SObjectType);
    }
    
    //Add the base fields for the object that should just be used in absolutely every 
    //query done by this class
    //suggested to give only the most required fields since it will take up heap storage.
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    //methods which returns the sObject type.
    public Schema.SObjectType getSObjectType() {
        return SBQQ__QuoteLine__c.sObjectType;
    }   
    //custom methods implemented based on the need.    
    public List < SBQQ__QuoteLine__c > selectWithQuoteAndStatusFilter(Id recordId){
        System.debug('Inside selector');
        String query = 'SELECT Id, Name, SBQQ__ProductName__c, Pricing_Other_Product_Nm__c, Pricing_Quote_Line_Number__c, Pricing_Status_Nm__c,Pricing_Integration_Status_Nm__c, Pricing_Error_Messages__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :recordId and Pricing_Status_Nm__c !=\''+Label.Pricing_Tender_QuoteLine_Status_Revised+'\' ORDER BY Pricing_Quote_Line_Number__c ASC';
        return Database.query(query);
    }
    
    // custom method having an dynamic query which is mostly used around the org.
    // it can be called with a list of fields.
    // it will return the value for only the fields passed to it.
    public List < SBQQ__QuoteLine__c > selectWithId(set<Id> recordId,List<String> fields){
        String query = 'SELECT '+String.join(fields,',')+' FROM SBQQ__QuoteLine__c where Id IN :recordId';
        return Database.query(query);
    }
    
    public List< SBQQ__QuoteLine__c> selectWithProductAndUnifiedFilter(set<Id> recordId){
        return [SELECT Id FROM SBQQ__QuoteLine__c where Id IN: recordId
               AND SBQQ__Quote__r.Pricing_IsUnifiedCustomer__c = false 
            AND SBQQ__Product__r.Name !=: Label.Pricing_Write_In_Product];
    }
}