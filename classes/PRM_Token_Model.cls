global class PRM_Token_Model {
    
    public string access_token {set;get;}
    //public string expires_in {set;get;}
    
    public static PRM_Token_Model parse(String json) {
        return (PRM_Token_Model) System.JSON.deserialize(json, PRM_Token_Model.class);
    }    
}