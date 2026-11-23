public class Pricing_DocumentSelector extends fflib_SObjectSelector
{
    public static Pricing_DocumentSelector newInstance() {
        return (Pricing_DocumentSelector) Pricing_IQR_Application.selector.newInstance(Document.SObjectType);
    }

    public Schema.SObjectType getSObjectType(){
        return Document.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }

    public List<Document> selectByName(String name){
        return [SELECT Id, Name FROM Document where Name = : name LIMIT 1];
    }
}