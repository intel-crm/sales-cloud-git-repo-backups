public class Pricing_Product_Selector extends fflib_SObjectSelector {

    public static Pricing_Product_Selector newInstance() {
        
        
        return (Pricing_Product_Selector) Pricing_IQR_Application.selector.newInstance(Product2.SObjectType);
    }

    public Schema.SObjectType getSObjectType(){
        return Product2.sObjectType;
    }
    
    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }

    public List<Product2> selectByText(String query){        
        return Database.query(query);
    }
    
}