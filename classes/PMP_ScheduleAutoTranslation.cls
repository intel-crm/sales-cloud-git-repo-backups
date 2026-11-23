global with sharing class PMP_ScheduleAutoTranslation implements Schedulable{
    global void execute(SchedulableContext ctx) {
        boolean isSuccess = false;
        isSuccess = PMP_Locale_Outbound_Msg.InsertOutboundMsg();
    }
}