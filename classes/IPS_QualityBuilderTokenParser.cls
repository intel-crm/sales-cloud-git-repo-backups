/***************************************************************************************************
* @Name IPS_QualityBuilderTokenParser 
* @Description Parser class to parse token generation callout response 
* @Author ANil popcornapps
* @version 1.0
* @Created Date 25/11/2021
***************************************************************************************************/
public class IPS_QualityBuilderTokenParser {
    public String access_token;
    public String token_type;
    public String expires_in;
    public String ext_expires_in;
    // parser method to parse token generation callout's json response
    public static IPS_QualityBuilderTokenParser parse(String json) {
        return (IPS_QualityBuilderTokenParser) System.JSON.deserialize(json, IPS_QualityBuilderTokenParser.class);
    }
}