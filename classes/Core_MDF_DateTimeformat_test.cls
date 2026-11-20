@isTest(SeeAllData=false)
public class Core_MDF_DateTimeformat_test {

    	 @isTest static void testGetUserDateFormat(){
             Core_MDF_DateTimeformat.getUserDateTimeFormat();
	     // Unit Test Method should include System.Assert 
        Assert.isNotNull(Core_MDF_DateTimeformat.getUserDateFormat());
         }
    @isTest static void testClientCnst(){
         // Highlight: Unused Local Variable
        // Core_MDF_client_cnst cc = new Core_MDF_client_cnst();
     }
}