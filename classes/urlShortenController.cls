public class urlShortenController
{
	public string URL
	{
		get;set;
	}
	public string shortenURL;
	public static string nId;
	public static boolean isSetup
	{
		get
		{
			return LinkForce_Settings__c.getInstance() != null && LinkForce_Settings__c.getInstance().Base_URL__c.length() > 0 && LinkForce_Settings__c.getInstance().Default_URL__c.length() > 0;
		}
	}
	public static string URL_BASE
	{
		get
		{
			if(!isSetup)
			{
				return '';
			}
			string url = LinkForce_Settings__c.getInstance().Base_URL__c;
			if(!url.startsWith('http://') && !url.startsWith('https://') && !url.startsWith('mailto:'))
			{
				url = 'http://' + url;
				// Pagereferences seem to have issues with a trailing slash
			}
			if(url.endsWith('/'))
			{
				url = url.substring(0, url.length() - 1);
			}
			return url;
		}
	}
	public static string DEFAULT_URL
	{
		get
		{
			// system.debug('link'+LinkForce_Settings__c.getInstance());
			system.debug('base' + LinkForce_Settings__c.getInstance().Base_URL__c.length());
			//system.debug('default'+LinkForce_Settings__c.getInstance().Default_URL__c.length());
			if(!isSetup)
			{
				return 'http://www.salesforce.com';
			}
			string url = LinkForce_Settings__c.getInstance().Default_URL__c;
			if(!url.startsWith('http://') && !url.startsWith('https://'))
			{
				url = 'http://' + url;
			}
			if(url.endsWith('/'))
			{
				url = url.substring(0, url.length() - 1);
			}
			return url;
		}
	}
		
}