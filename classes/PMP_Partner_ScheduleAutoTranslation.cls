global with sharing class PMP_Partner_ScheduleAutoTranslation implements Schedulable{
    global void execute(SchedulableContext ctx) {
        boolean isSuccess = false;
        isSuccess = PMP_Partner_Locale_Outbound_Msg.insertPartnerOutboundMsg();
         
    }
}