trigger PMP_Marketplace_Topic_Trigger on PMP_Marketplace_Topic__c  (before insert,before update,after update, after insert,after Delete) {
    //new PMP_Marketplace_Topic_Handler().run(); //IPA2.0:TWC729-8114 Topics Removal/Event Removal

}