trigger Sales_BulkHostForLicGen on Sales_Bulk_Host_Process_Lic_Gen__e (after insert) {
     system.debug('PE trigger executed>>');
     //Sales_BulkHostProcessForLicGenUtility.executeLicGeneration(trigger.new); 
}