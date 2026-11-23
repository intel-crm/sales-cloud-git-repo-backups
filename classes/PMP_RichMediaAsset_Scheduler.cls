/*
Author: Sai Thotakura
Onyx Team
Create Date: 13th-Dec-2021
Purpose: Scheduling the batch job to run daily
*/
public without sharing class PMP_RichMediaAsset_Scheduler implements Schedulable {
    public void execute (SchedulableContext sc) {
        PMP_RichMediaAsset_Batch btch = new PMP_RichMediaAsset_Batch();
        Database.executeBatch(btch,10);
    }
}