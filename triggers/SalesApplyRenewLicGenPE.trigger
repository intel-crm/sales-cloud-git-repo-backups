trigger SalesApplyRenewLicGenPE on Sales_Apply_Renew_Lic_Genration__e (after insert) {
    system.debug('trigger called');
   // SalesApplyRenewLicGenPECtrl.executeLicGeneration(trigger.new); 
}