/***********************************************************************************************************************************
* Class Name  : Core_MDF_Batch_UpdateReminderDtOnClaims  
* Version     : 1.0    
* Created Date: 11/2/2021
* Modification Log :
* Developer            Date               Description
* -----------------------------------------------------------------------------------------------------
* Accenture - Pranav      11/2/2021      This batch Updates Payment Admin reminder date on Claim 
*************************************************************************************************************************************/

public class Core_MDF_Batch_UpdateReminderDtOnClaims implements Database.Batchable<sObject>{
    
    List<PartnerFundClaim> claimsList = new List<PartnerFundClaim>();
    // Incoming List of CLaims for which Payment Admin Reminder Date field is to be updated
    public Core_MDF_Batch_UpdateReminderDtOnClaims(List<PartnerFundClaim> claimsList) {
        this.claimsList = claimsList;
    }
    
    public Iterable<sObject> start(Database.BatchableContext bc) {
        return claimsList;
    }
    
    public void execute(Database.BatchableContext bc, List<PartnerFundClaim> claimsList) {
        try{
            
            if(claimsList!=null && claimsList.size()>0){
                List<PartnerFundClaim> claimsToUpdate = new List<PartnerFundClaim>();
                // prepating map for Program region to Payment Admin queue Id configration
                Map<String,Id> progRegionToPayAdmQueue = new Map<String,Id>();
                List<String> allowedprogms = Core_MDF_Configuration__c.getValues('ALLOWED_PRG_FOR_RUS_NOTIF').Core_MDF_Value__c.split(',');
                List<String> allowedRegion = Core_MDF_Configuration__c.getValues('ALLOWED_REGION_FOR_BDH_NOTIF').Core_MDF_Value__c.split(',');
                for(Core_MDF_ProgramGeoGroupMap__mdt pggRec:[SELECT id,Core_MDF_Program__c, Core_MDF_Region__c, Core_MDF_Payment_Admin_Queue_Id__c  FROM Core_MDF_ProgramGeoGroupMap__mdt 
                                                                    WHERE Core_MDF_Program__c IN: allowedprogms
                                                                    AND Core_MDF_Payment_Admin_Queue_Id__c <> null 
                                                                    AND Core_MDF_Region__c IN: allowedRegion]) {
                                                                        if(pggRec.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM){
                                                                            progRegionToPayAdmQueue.put(pggRec.Core_MDF_Program__c, pggRec.Core_MDF_Payment_Admin_Queue_Id__c);
                                                                        } else{
                                                                            progRegionToPayAdmQueue.put(pggRec.Core_MDF_Program__c+'-'+pggRec.Core_MDF_Region__c, pggRec.Core_MDF_Payment_Admin_Queue_Id__c);
                                                                        }
                }
                // Initialise Email Wrapper List
                List<Core_MDF_GenericClassToSendMail.MailParams> reminderEmailWrapList = new List<Core_MDF_GenericClassToSendMail.MailParams>();
           
                Integer numOfDays=3;
                String key;
                //Getting number of days to be added for current datefrom Configuration custom setting
                Core_MDF_Configuration__c  getBusinessDays = Core_MDF_Configuration__c.getValues('ADD_BUS_DAYS_ON_REMINDER_DATE_CLAIM');
                if(getBusinessDays.Core_MDF_Value__c!=null && getBusinessDays.Core_MDF_Value__c.length()>0){
                    numOfDays = Integer.valueOf(getBusinessDays.Core_MDF_Value__c);
                }
                for(PartnerFundClaim pfc :claimsList){
                    //Add next reminder date
                    pfc.Core_MDF_Payment_Admin_Reminder_Date_Dtm__c = Core_MDF_PFC_VAT_ServiceHandler.addBusinessDays(system.today(),numOfDays);
                    claimsToUpdate.add(pfc);
                    key = (pfc.Core_MDF_Program__c == Core_MDF_CCP_ConstantClass.Co_GTM_PROGRAM) ? pfc.Core_MDF_Program__c : (pfc.Core_MDF_Program__c+'-'+pfc.Core_MDF_Region_Cd__c);
                    // checking if Program-region combination is present in Map
                    if(progRegionToPayAdmQueue.containsKey(key)) {
                         Core_MDF_GenericClassToSendMail.MailParams reminderEmailWrap = new Core_MDF_GenericClassToSendMail.MailParams();
                         reminderEmailWrap.groupId = progRegionToPayAdmQueue.get(key);
                         reminderEmailWrap.recordId = pfc.Id;
                         reminderEmailWrap.sendDiff = false;
                         reminderEmailWrap.templateName = Label.Core_MDF_ReminderEmailToPayAdmin;
                         reminderEmailWrapList.add(reminderEmailWrap);
                    }
                }
                //Update Claims            
                if(claimsToUpdate!=null && claimsToUpdate.size()>0){
                    Database.update(claimsToUpdate);
                }
                // code to send email if reminderEmailWrapList is not empty
                if(reminderEmailWrapList != null && reminderEmailWrapList.size()>0) {
                    Core_MDF_GenericClassToSendMail.sendEmailMethod(reminderEmailWrapList);
                }
                
            }           
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }
    
    public void finish(Database.BatchableContext bc){}
}