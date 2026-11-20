/*
 Author: Sai Thotakura
 Onyx Team
 Functionality: Trigger associated with Rich Media Asset Stage object to download the pdf files and attach to it
*/
Trigger PMP_RichMediaAssetDocDownload_Trigger on PMP_Rich_Media_Asset_Stage__c (after insert, after update, before update) {
 new PMP_RichMediaAssetTriggerHandler().run();
}