global class PRM_WeChat_Link_Model {
    public String enterpriseId {set;get;}
    public String loginId {set;get;}
    public String email {set;get;}
    public String wechatUnionId {set; get;}
    public Boolean unfollow {set;get;}
    public String status {set;get;}
    public String error {set;get;}
    public String responseTime {set;get;}
    
    public static PRM_WeChat_Link_Model parse(String json) {
        return (PRM_WeChat_Link_Model) System.JSON.deserialize(json, PRM_WeChat_Link_Model.class);
    }
}