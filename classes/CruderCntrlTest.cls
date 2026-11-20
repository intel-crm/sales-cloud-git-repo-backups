@isTest
public class CruderCntrlTest {
    static testmethod void create(){ 
        list<case> caselist = new list<case>();
        list<case> caselistEdit = new list<case>();
        list<case> caselistDelete = new list<case>();
        
        
        
        Case CaseRecord = new Case(); 
        CaseRecord.Status = 'New';
        CaseRecord.Origin = 'Web';
        CaseRecord.Priority = 'High';
        CaseRecord.Subject = 'TestSubject';
        CaseRecord.Core_Sub_Status__c = 'Close-Pending';
        CaseRecord.Description = 'TestDescription';
        insert CaseRecord;  
        
        caselist.add(CaseRecord);
        CruderCntrl.InsertSObjects(caselist);
        CaseRecord.Subject = 'test';
        caseRecord.id = CaseRecord.id;
        caselistEdit.add(CaseRecord);
        
        CruderCntrl.UpdateSObjects(caselistEdit);
        CruderCntrl.ReadSObjects('Select id from case limit 1');
        CruderCntrl.DeleteSObjects(caselistEdit);
    }
}