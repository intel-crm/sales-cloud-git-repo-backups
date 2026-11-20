//
//create by Sunil
//

public class Core_IPS_fromJSON{
    public String query;   //பபl0箊圽苍6丐丂டட
    public static Core_IPS_fromJSON parse(String json){
        return (Core_IPS_fromJSON) System.JSON.deserialize(json, Core_IPS_fromJSON.class);
    }

    /*static testMethod void testParse() {
        String json=        '{"ciphertext" : "பபl0箊圽苍6丐丂டட"}';
        fromJSON obj = parse(json);
        System.assert(obj != null);
    }*/
}