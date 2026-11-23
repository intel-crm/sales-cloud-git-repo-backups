@isTest
public class Core_Opp_KPI_Helper_Test {
    
    testMethod static void Get_opplistForJSONTest() {
    Test.startTest();
        List<Opportunity> OppList= [select Id from Opportunity   where  CreatedDate > LAST_N_WEEKS:4 ];
        List<String> OppIdList= new List<String>();
         for(Opportunity op: OppList){
               OppIdList.add(op.id);
             
         }                     
              List<Opportunity> oplist = Core_Opp_KPI_Helper.Get_opplistForJSON(OppIdList);
        
    Test.stopTest();     
    }
    
    testMethod static void Get_solutionAreaForJSONTest() {
    Test.startTest();
        
       List<Opportunity> OppList= [select Id from Opportunity   where  CreatedDate > LAST_N_WEEKS:4 ];
        List<String> OppIdList= new List<String>();
         for(Opportunity op: OppList){
               OppIdList.add(op.id);
             
         }                     
              List<Core_Solution_Areas__c> salist = Core_Opp_KPI_Helper.Get_solutionAreaForJSON(OppIdList);
    Test.stopTest();     
    }
    
    testMethod static void Get_PartnerTypesForJSONTest() {
    Test.startTest();
        
		List<Opportunity> OppList= [select Id from Opportunity   where  CreatedDate > LAST_N_WEEKS:4 ];
        List<String> OppIdList= new List<String>();
         for(Opportunity op: OppList){
               OppIdList.add(op.id);
             
         }                     
              List<Opportunity> oplist = Core_Opp_KPI_Helper.Get_PartnerTypesForJSON(OppIdList);
          
    Test.stopTest();     
    }
    
    

}