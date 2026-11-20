public with sharing class PRM_ConvertToJSON {
    
    @invocableMethod(label='Get JSON' Description='This action converts and object into json' Category='Other')
    public static List<String> getJSON(List<SObject> sobjects){
        return new List<String>{JSON.serialize(sobjects)};
    }
}