public class Core_MDF_PaymentJSONParser {
	public String Core_MDF_Payment_No_Txt;
	public String Core_MDF_EFT_Nbr;
	public String Core_MDF_Payment_Made_Dt;
	public String Core_MDF_Payment_Status_Txt;

	
	public static List<Core_MDF_PaymentJSONParser> parse(String json) {
		return (List<Core_MDF_PaymentJSONParser>) System.JSON.deserialize(json, List<Core_MDF_PaymentJSONParser>.class);
	}
}