global class UCD_ACM_accountSearchModel {
    /**** Request Parameters *****/
    public String Name{get;set;}
    public AddressData Address{get;set;}
    public String Website{get;set;}
    public String BusinessPartyId{get;set;}
    public String CustomerAggregationType{get;set;}
    
    public class AddressData{
        public String Country{get;set;}
    }
    
    
    /*********************** Parsing Request **************************/
    
    public static UCD_ACM_accountSearchModel parseRequestBody(String json){
        UCD_ACM_accountSearchModel requestBody ;
        try{
            requestBody = (UCD_ACM_accountSearchModel) System.JSON.deserialize(json, UCD_ACM_accountSearchModel.class);
            return requestBody ;
        }
        catch(Exception ex){
            return null;
        }
    }
    
    
    /**** Response Parameters *****/
    global class AccountSearchResponse{
        public String Status {set;get;}
        public String Message {set;get;}
        public List<ResponseData> Data {set;get;}
    }
    public class ResponseData{
        public String Name {set;get;}
        public ParentAccount ParentAccount{set;get;}
        public String BusinessPartyId{set;get;}
        public String CustomerProcessEngagement{set;get;}
        public String CustomerAggregationType{set;get;}
        
    }

    public class ParentAccount{
        public String Name {set;get;}
        public String BusinessPartyId{set;get;}
        public String CustomerAggregationType{set;get;}
    }
}