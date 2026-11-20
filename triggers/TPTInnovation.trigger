trigger TPTInnovation on InnovationTracker__c (before insert, before update, after insert, after update) {
    new TPTInnovationHandler().run();
}