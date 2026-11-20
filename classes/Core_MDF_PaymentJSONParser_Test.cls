@IsTest
public class Core_MDF_PaymentJSONParser_Test {
static testMethod void testParse() {
        String json = '['+
        '   {'+
        '       \"Core_MDF_Payment_No_Txt\": \"000001-CCF\",'+
        '       \"Core_MDF_EFT_Nbr\": \"ABCD123123\",'+
        '       \"Core_MDF_Payment_Made_Dt\": \"31-JAN-2019\",'+
        '       \"Core_MDF_Payment_Status_Txt\": \"Paid\"'+
        '   },'+
        '   {'+
        '       \"Core_MDF_Payment_No_Txt\": \"000002-CCF\",'+
        '       \"Core_MDF_EFT_Nbr\": \"ABCD123124\",'+
        '       \"Core_MDF_Payment_Made_Dt\": \"31-JAN-2019\",'+
        '       \"Core_MDF_Payment_Status_Txt\": \"Paid\"'+
        '   }'+
        ']';
        List<Core_MDF_PaymentJSONParser> obj = Core_MDF_PaymentJSONParser.parse(json);
        System.assert(obj != null);
    }
}