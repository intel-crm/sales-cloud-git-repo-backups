public class Pricing_Period_Selector extends fflib_SObjectSelector {

    public static Pricing_Period_Selector newInstance() {
        
        
        return (Pricing_Period_Selector) Pricing_IQR_Application.selector.newInstance(Period.SObjectType);
    }

    public Schema.SObjectType getSObjectType(){
        return Period.sObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return null;
    }
    
    public List<Period> selectbyType(String type){
        return [SELECT FullyQualifiedLabel,FiscalYearSettings.Name,Number FROM Period WHERE FiscalYearSettings.YearType='Custom' and Type =: type and StartDate <= : System.today() order by StartDate desc limit 1];
    }
    
}