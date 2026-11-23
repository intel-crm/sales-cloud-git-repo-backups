@isTest
public class Core_IPS_Case_Save_Controller_Test {
    @isTest
    static void TesthandleSaveCase(){
        String basicInfoJson='{"project":"a2Bo0000000dPFCEA2","projectName":"PCCG Lenovo Corp (Japan)","productvariant":"01to0000004pDy4AAE","productvariantName":"Intel7896Name","Product":"01to0000004pDy4AAE","ProductName":"Intel@Aero","Subject":"Creating a case","CategoryId":"001o0000016QfcfAAC","CategoryName":"Intel Premium","SubCategoryName":"Intel Premium V1","SubCategoryId":"001o0000016QfcfAAC","Language":"English","NickName":"IPS","testQuestion":"Enter Your Product","childQuestion1":"Enter Prod Id","childQuestion2":"Enter Prod Depo","picklistQuestion":"Select Any Question"}';
        String finalformJson='{"subject":"Case Details","description":"This Json Contains Details of the Case","caseType":"Technical","caseseverity":"High","custmerreference":"Portal","endcustomer":"Intel"}';
       Test.startTest();
        try{
            Core_IPS_Case_Save_Controller.handleSaveCase(basicInfoJson,finalformJson);
  
        }catch(exception e){
            
        }
        Test.stopTest();
    }
    

}