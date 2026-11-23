public class Core_IPS_Project_detail_override_Clone{

public ApexPages.StandardController sc = null;

public Core_IPS_Project_detail_override_Clone(ApexPages.StandardController sc)
{
  this.sc = sc;
}

public PageReference Init()
{
Id profileId = UserInfo.getprofileid();
            String profileName = [Select Id, Name from Profile where Id =: profileId ].Name;
            System.debug('Profile name:'+profileName );
  if(profileName.equals('System Administrator'))
  {
    // Not manager, back to the record
    String theUrl = '/' + sc.GetRecord().Get('Id') + '?nooverride=1';
    system.debug('theUrl'+theUrl );
    return new ApexPages.PageReference(theUrl).SetRedirect(true);
  }
else{
  // Stay on the page
  return null;
  }
}
}