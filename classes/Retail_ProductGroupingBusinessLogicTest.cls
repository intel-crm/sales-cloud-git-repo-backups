@isTest
public class Retail_ProductGroupingBusinessLogicTest {
	@isTest
    public static void setUpData(){
        //List<Core_CPQ_Product_Group__c> grps = new List<Core_CPQ_Product_Group__c>();
        String name='CustomTestProduct';
        
            Core_CPQ_Product_Group__c tempGrp = new Core_CPQ_Product_Group__c();
            tempGrp.Name=name;
            Database.insert(tempGrp,false);
        	Core_CPQ_Product_Group__c tempGrp1 = new Core_CPQ_Product_Group__c();
            tempGrp1.Name=name.toUpperCase();
            Database.insert(tempGrp1,false);
        
        
       
        
        
    }
}