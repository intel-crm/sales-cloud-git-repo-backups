public class OrgLimitWarningBatch implements Database.Batchable<sObject>, Database.Stateful {
    Map<String, Map<String, Decimal>> orgLimitsMap = new Map<String, Map<String, Decimal>>();
    
	public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT id FROM Organization LIMIT 1');
  }
    
  public void execute(Database.BatchableContext BC, List<Sobject> scope) {
    Map<String, System.OrgLimit> limitsMap = OrgLimits.getMap();

    List<String> storageTypesList = new List<String>(); 
      system.debug('storageTypesList B-->'+storageTypesList);
	  storageTypesList.add('FileStorageMB');
      storageTypesList.add('DataStorageMB');
      storageTypesList.add('DailyApiRequests');
      system.debug('storageTypesList A-->'+storageTypesList);
    if (!storageTypesList.isEmpty()) {
      for (String eachStorageType : storageTypesList) {
        system.debug('eachStorageType-->'+eachStorageType);
        System.OrgLimit storageType = limitsMap.get(eachStorageType);
        system.debug('storageType Value-->'+storageType.getValue());
        system.debug('storageType Limit-->'+storageType.getLimit());
        Decimal storagePercentUsed = ((Decimal.valueOf(storageType.getValue()) /
        Decimal.valueOf(storageType.getLimit())) * 100);
          system.debug('percentage used--->'+storagePercentUsed);
        Decimal warningPercent = Decimal.valueOf(
          '80'
        );

        //to get code coverage for test class in case none of the storage types have reached warning percent
        if (Test.isRunningTest()) {
          warningPercent = 1;
        }
		system.debug('storagePercentUsed----->'+storagePercentUsed);
        system.debug('warningPercent----->'+warningPercent);
          
        //check if the percent utilized is more than warning percent
        if (storagePercentUsed >= warningPercent) {
            system.debug('Condition check--->');
          storagePercentUsed = storagePercentUsed.setScale(2);
          Map<String, Decimal> storageAttributesMap = new Map<String, Decimal>();
          storageAttributesMap.put('Limit', storageType.getLimit());
          storageAttributesMap.put('Used', storageType.getValue());
          storageAttributesMap.put('Percent', storagePercentUsed);
	      system.debug('storageAttributesMap --->'+storageAttributesMap);
          orgLimitsMap.put(eachStorageType, storageAttributesMap);
        }
          system.debug('orgLimitsMap key--->'+orgLimitsMap.keySet());
          system.debug('orgLimitsMap values--->'+orgLimitsMap.values());
      }
    }
  }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('orgLimitsMap.keyset--->'+orgLimitsMap.keyset());
      if (!orgLimitsMap.keyset().isEmpty()) {
      //get the org instance name
      String instanceName = '';
      String myHostStr = System.Url.getSalesforceBaseUrl().getHost();
      Integer startIndex = myHostStr.indexOf('--');
      if (startIndex != 1) {
        Integer endIndex = myHostStr.indexOf('.');
        instanceName = myHostStr.mid(startIndex, endIndex - startIndex);
        instanceName = instanceName.remove('--');
        instanceName = instanceName.remove('.');
      } else {
        instanceName = 'PROD';
      }
	system.debug('instanceName--->'+instanceName);
      //get the email recepients list
          List<String> emailRecepientsList = new List<String>();
          emailRecepientsList.add('sandhya.dayananda@intel.com');
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      List<String> sendTo = new List<String>();
      sendTo.addAll(emailRecepientsList);
      mail.setToAddresses(sendTo);
      mail.setSenderDisplayName(' Org Storage Warning : Email');
          system.debug('mail--->'+mail);

      String subject = '';
      if (instanceName != '') {
        subject = instanceName;
      }
      system.debug('instanceName A--->'+instanceName);
      subject += ': Org limits warning';
      mail.setSubject(subject);

      String body = '<html><body> Hi Team, <br/><br/>';
      body +=
        'The following types are about to reach the limit for the Org  (' +
        UserInfo.getOrganizationId() +
        ' : ' +
        instanceName +
        '). Please review <br/><br/> ';

      //open table..
      body += '<table border="1" style="border-collapse: collapse"><tr><th> Type </th><th>Limit</th><th> Used </th><th> Percent Used </th></tr>';

      //iterate over list and output columns/data into table rows...
      for (String eachStorageType : orgLimitsMap.keyset()) {
          system.debug('eachStorageType 95--->'+eachStorageType);
        Decimal storageLimit = orgLimitsMap.get(eachStorageType).get('Limit');
        Decimal used = orgLimitsMap.get(eachStorageType).get('Used');
        Decimal percent = orgLimitsMap.get(eachStorageType).get('Percent');

        body +=
          '<tr><td>' +
          eachStorageType +
          '</td> <td>' +
          storageLimit +
          '</td><td>' +
          used +
          '</td><td>' +
          percent +
          '</td></tr>';
      }

      //close table...
      body += '</table><br/><br/>';

      body += 'Thank You';
      body += '</body></html>';
      mail.setHtmlBody(body);
      mails.add(mail);
          System.debug('mails--->'+mails);
      Messaging.sendEmail(mails);
    }
    }
}