trigger Core_MDF_BatchApexErrorEvent_Trigger on BatchApexErrorEvent (after insert) {
    System.debug('Inside trigger');
    new Core_MDF_BatchApexErrorEvent_Handler().run();
}