public without sharing class PRM_IPA_Integration_Scheduler implements Schedulable {
    public void execute(SchedulableContext sc) 
    {        
        Database.executeBatch(new PRM_Batch_IPA_Account_Integration(),Integer.ValueOf(Label.IPA_Int_Batch_Size));
               
        Database.executeBatch(new PRM_Batch_IPA_Contact_Integration(),Integer.ValueOf(Label.IPA_Int_Batch_Size));

    }
}