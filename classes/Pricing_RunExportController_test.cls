@isTest
public class Pricing_RunExportController_test {    
    @isTest(seeAllData=true)
    public static void testRunExport(){
            SBQQ__Quote__c quote = [SELECT Id,Pricing_Quote_Program_Nm__c  from SBQQ__Quote__c where SBQQ__LineItemCount__c > 0 and Pricing_Quote_Program_Nm__c = 'Tender' order by createdDate desc limit 1];
            PermissionSetAssignment usrid = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Pricing_Tender_Partner_Administrator' AND Assignee.isActive = true Limit 1];
            User usr =[Select id from User where id = :usrId.AssigneeId];
        System.runAs(usr){
            Map<String,Map<String,List<List<String>>>> qliTypeToHeaderToQliMap = Pricing_RunExportController.getQLIData(quote.Id);
            System.assert(qliTypeToHeaderToQliMap != null);
        }
    }
}