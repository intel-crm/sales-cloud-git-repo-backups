trigger TestEvent on Test_event__e (after insert) {
    BatchDRUtility.updateDrStageAndMappedObject(Trigger.New);  
}