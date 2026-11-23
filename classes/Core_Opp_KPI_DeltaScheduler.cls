public class Core_Opp_KPI_DeltaScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Core_Opp_KPIProcessing_DeltaLoad_Batch(), 200);
    }
}