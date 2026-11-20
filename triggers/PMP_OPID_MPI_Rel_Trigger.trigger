trigger PMP_OPID_MPI_Rel_Trigger on PMP_OPID_MPI_Rel__c (after insert, after update,before insert,before update, before delete) 
{
    
   new PMP_OPID_MPI_Rel_TriggerHandler().run();    
    
}