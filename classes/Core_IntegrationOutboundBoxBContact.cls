/******************************************************************************************************************************************
* Class Name  : Core_IntegrationOutboundBoxBContact
* Version     : 1.0
*
* Modification Log :
* Developer                Date             Description
* ----------------------------------------------------------------------------
* Pooja Khanna             05/18/2017       Original version
* Aran Wongsaprome          8/22/2017       US71628 Related list of messages under contact
*****************************************************************************************************************************************/
public class Core_IntegrationOutboundBoxBContact {
 
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_PROJECT = 'Entitlement';
    public static final String LOG_ENTRY_SCOPE = 'OutboundContactMessageBoxB';
    public static final String LOG_ENTRY_ERROR = 'error'; 
    public static final String LOG_ENTRY_INFO = 'info';
    public static final String LOG_ENTRY_OBJECT = 'Core_Integration_Outbound_Message__c';
     

    @InvocableMethod(label='Create BoxB Messages' description='Outbound Box B contact messae ')
    public static void CreateOutboundMessae(List<ID> lContactId) {
     
      List<Contact> lcontacts = [
        select Id, Core_Enterprise_Id__c,
          Core_Login_Id__c, AccountId, FirstName, LastName, Email, Phone, MailingCountry, Core_Job_Function__c,
          Core_English_Only_First_Name__c, Core_English_Only_Last_Name__c, Core_Deactivated__c, CreatedDate,
          LastModifiedDate, Account.Core_CIM_ID__c, Account.Name, Core_Contact_B2B_Indicator__c,Core_eRPM_Person_Id__c
        from Contact where Id in :lContactId
      ];
    
      Map<id,Core_Integration_Outbound_Message__c> mapMsg = new Map<id,Core_Integration_Outbound_Message__c>();
      for(Contact c : lcontacts) {
          // Now send the Box B Contact outbound messages based on all that were successful
          mapMsg.put(c.id, createBoxBContactMessage(c));
      }
    
      List<Core_Integration_Outbound_Message__c> outboundMessages = mapMsg.values();
      // Perform DML INSERT for Box B Contact outbound messages
      if (outboundMessages.size() > 0) {
          insert outboundMessages;
          
          // Add contact message entries for each of the messages
          List<Contact_Message__c> ContactMsg = new List<Contact_Message__c>();
          for(Id cid : mapMsg.keySet()) ContactMsg.add(
            new Contact_Message__c(Contact__c = cid, Outbound_Message__c = mapMsg.get(cid).id)
          );
          insert ContactMsg;
      }
    
    }

    public static Core_Integration_Outbound_Message__c createBoxBContactMessage(Contact c) {
        String tags = '';
        // Build up tags for log entry
        if (!String.isBlank(c.Core_eRPM_Person_Id__c))
            tags += addTag(c.Core_eRPM_Person_Id__c);           
        if (!String.isBlank(c.Core_Enterprise_Id__c))
            tags += addTag(c.Core_Enterprise_Id__c);
        if (!String.isBlank(c.Core_Login_Id__c))
            tags += addTag(c.Core_Login_Id__c);           
        if (!String.isBlank(c.Email))
            tags += addTag(c.Email);
        if (!String.isBlank(c.Id))
            tags += addTag(c.Id);
        
        Core_IntegrationUtility.BoxB_ContactWrapper b = new Core_IntegrationUtility.BoxB_ContactWrapper();
        b.CST_ID            = c.Core_Enterprise_Id__c;
        b.INTRNL_LGN_ID     = '';
        b.EXTRN_LGN_ID      = c.Core_Login_Id__c;
        b.ACCT_ID           = c.AccountId;
        b.FRST_NM           = c.FirstName;
        b.LST_NM            = c.LastName;
        b.ENG_FRST_NM       = c.Core_English_Only_First_Name__c;
        b.ENG_LST_NM        = c.Core_English_Only_Last_Name__c;
        b.EMAIL_ADDR_TXT    = c.Email;
        b.PHN_ADDR_TXT      = c.Phone;
        b.EXTRN_ORG_NM      = c.Account.Name;
        b.CTRY_NM           = Core_Entitlement_Outbound_Integrations.getISO2CountryCode(c.MailingCountry);
        b.USR_ACCT_SUSP_DTM = '';
        b.PRI_OCCP_TTL_CD   = c.Core_Job_Function__c;
        b.EBUS_AGT_STS_CD   = (c.Core_Deactivated__c ? 'inactive' : 'active'); // TO DO: Validate this logic with Jordan
        b.CREATE_DT         = c.CreatedDate.date();
        b.CHANGE_DTM        = c.LastModifiedDate;
        b.CIMID             = c.Account.Core_CIM_ID__c;
        b.ACCT_NM           = c.Account.Name;

        String payload = JSON.serialize(b);

        Core_Integration_Outbound_Message__c obm = new Core_Integration_Outbound_Message__c(
            Core_Tags__c = tags, 
            Core_MessageType__c = 'Box B Contact',
            Core_Payload__c = '<![CDATA[' + payload + ']]>');
        return obm;
    }
    
  // Helper method to assist with building our Tags in Log Entries
    private static String addTag(String tagToAdd) {
        return String.isBlank(tagToAdd) ? '' : (tagToAdd + ';');
    }
   }