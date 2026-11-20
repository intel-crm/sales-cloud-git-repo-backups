public class Core_MindsComplianceController {
    Public string Header{get;set;}
    Public string Url{get;set;}
    Public string Guardrail{get;set;}
    Public string nonIntel{get;set;}
    Public string nonIntelUrl{get;set;}
    //Constructor
    public Core_MindsComplianceController(ApexPages.StandardController cont) {
        List<String> strList=Label.Core_Opp_Guardrail_message.split(';');
        if(strList.size() > 4){
            Header = strList[0];
            Url    = strList[1];
            Guardrail = strList[2];
            nonIntel  = strList[3];
            nonIntelUrl  = strList[4];
        }
        else{
            
        }
    }
}