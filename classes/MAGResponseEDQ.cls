public with sharing class MAGResponseEDQ{
    @AuraEnabled public List<Edq> edq;
    public class Edq {
        public String question;
        public String selectedValues;
        public String answer;
        public Boolean required;
        public String answerType;
        public Boolean val;
    }

    public static List<MAGResponseEDQ> parse(String json) {
        if(string.isblank(json)){
            return ( new List<MAGResponseEDQ>()); 
        }else{
            return (List<MAGResponseEDQ>) System.JSON.deserialize(json, List<MAGResponseEDQ>.class);
        }           
    }
}