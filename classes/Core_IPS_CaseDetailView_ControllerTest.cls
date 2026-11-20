@isTest
public class Core_IPS_CaseDetailView_ControllerTest {
    @isTest
    static void   getFieldName(){
        List<string> ListOfProfileNames = new List<string> {'IPS Agent'};
        Map<String,ID> MapOfProfiles = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: ListOfProfileNames]){
            MapOfProfiles.put(prof.name, prof.id);
        }
        List<User> SysAdminUsr = TestUtilities.getListOfUser(1);
        SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  MapOfProfiles.get('IPS Agent');
      System.RunAs(SysAdminUsr[0]){
      Case cs = TestUtilities.getCase();
      insert cs;
      Core_IPS_InlineStatusField__c inlineField = new Core_IPS_InlineStatusField__c();
      inlineField.Name = 'IPS Case Create';
      inlineField.StatusValue__c = 'New,Open';
      inlineField.SubStatusValue__c = 'Investigating,Deferred';
      insert inlineField;
      Core_IPS_CaseDetailView_Controller.getFieldName(cs.Id);
      Core_IPS_CaseDetailView_Controller.getStatus(cs.Id); 
      Core_IPS_CaseDetailView_Controller.getSubStatus(cs.Id, 'Open', 'Deferred');
      Core_IPS_CaseDetailView_Controller.getSubStatus(cs.Id, 'Closed', 'Closed');
      Core_IPS_CaseDetailView_Controller.getSubStatus(cs.Id, 'On Hold', 'GEC Hold');
      Core_IPS_CaseDetailView_Controller.getSubStatus(cs.Id, 'New', '');
      }
    }
}