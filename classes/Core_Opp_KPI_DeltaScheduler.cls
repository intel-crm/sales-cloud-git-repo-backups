public without sharing class Core_Opp_KPI_DeltaScheduler implements Schedulable { //TWC3123-5376: codescan fix: added without sharing

    public void execute(SchedulableContext sc) {
        Integer batchSize = Integer.valueOf(Label.Core_Opp_KPI_BatchSize);
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch(), batchSize);
    }
}