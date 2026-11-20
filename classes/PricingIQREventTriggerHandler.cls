/**
 * @description       : 
 * @author            : Subhanku
 * @group             : Accenture
 * @last modified on  : 05-02-2024
 * @last modified by  : Sandeep Chamate
**/
public class PricingIQREventTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        List<Pricing_IQR_Event__e> quoteShareList = new List<Pricing_IQR_Event__e>();
        List<Pricing_IQR_Event__e> wonLostQLIntegrationList = new List<Pricing_IQR_Event__e>();
        List<Pricing_IQR_Event__e> wonLostNotifWIPList = new List<Pricing_IQR_Event__e>();
        List<Pricing_IQR_Event__e> sendEmailNotifList = new List<Pricing_IQR_Event__e>();
        List<Pricing_IQR_Event__e> sendEmailNotifToApproverList = new List<Pricing_IQR_Event__e>();
        List<Pricing_IQR_Event__e> reAssignApprovalRequestList = new List<Pricing_IQR_Event__e>();
        List<Pricing_IQR_Event__e> runCalculatorServiceList = new List<Pricing_IQR_Event__e>();
        for(Pricing_IQR_Event__e iqrEventRec: (List<Pricing_IQR_Event__e>)Trigger.new){
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_IQR_Event_Action_Quote_Share){
                quoteShareList.add(iqrEventRec);
            }
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_IQR_Event_Action_Won_Lost_Integration){
                wonLostQLIntegrationList.add(iqrEventRec);
            }
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_IQR_Event_Action_Won_Lost_Notification){
                wonLostNotifWIPList.add(iqrEventRec);
            }
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_Send_EmailNotification_Event){
                sendEmailNotifList.add(iqrEventRec);
            }
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_Send_EmailNotificationToBot_Event){
                sendEmailNotifToApproverList.add(iqrEventRec);
            }
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_Reassign_Approval_Request_Event){
                reAssignApprovalRequestList.add(iqrEventRec);
            }
            if(iqrEventRec.Pricing_IQR_Action_Nm__c == Label.Pricing_Run_CalculatorService_Event){
                runCalculatorServiceList.add(iqrEventRec);
            }
        }
        if(quoteShareList.size() > 0){
            //Method to Share Quote Records
            PricingIQREventBusinessLogic.quoteShare(quoteShareList);
        }
        if(wonLostQLIntegrationList.size() > 0){
            PricingIQREventBusinessLogic.wonLostQuoteLineIntegration(wonLostQLIntegrationList);
        }
        if(wonLostNotifWIPList.size() > 0){
            PricingIQREventBusinessLogic.wonLostNotificationForWriteInProducts(wonLostNotifWIPList);
        }
        if(sendEmailNotifList.size() > 0){
            PricingIQREventBusinessLogic.sendEmailNotification(sendEmailNotifList);
        }
        if(sendEmailNotifToApproverList.size() > 0){
            PricingIQREventBusinessLogic.sendEmailNotificationToApprover(sendEmailNotifToApproverList);
        }
        if(reAssignApprovalRequestList.size() > 0){
            PricingIQREventBusinessLogic.reAssignApprovalRequest(reAssignApprovalRequestList);
        }
        if(runCalculatorServiceList.size() > 0){
            PricingIQREventBusinessLogic.runCalculatorServiceForFI(runCalculatorServiceList);
        }
    }
}