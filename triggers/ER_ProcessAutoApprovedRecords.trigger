trigger ER_ProcessAutoApprovedRecords on ProcessAutoApprovedRecords__e (after insert) 
{
     new ER_ProcessAutoApprovedRecordsHandler().run();
    
}