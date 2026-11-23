public class Core_Account_330_URL 
{
    private Account account;

    // Source var for the iFrame
    public String  accountId    { get; set; }
    public String  accountName  { get; set; }    
    public String  cpmId        { get; set; }
    public String  iframeSource { get; set; }
    
    public List<SelectOption> cpmChoices { get; set; }
    public List<String>       cpmIdList  { get; set; }
        
    public Boolean isAccessAllowed  { get; set; }
    public Boolean isMultipleCpmId  { get; set; }
    public Boolean isNotBlankCpmId  { get; set; }
    public Boolean isStandardOffset { get; set; }

    private Map<String, Core_Account330CustomSettings__c> csMap;

    private Core_Role_Hierarchy_Accessor roleHierarchyAccessor = new Core_Role_Hierarchy_Accessor();

    // Constructor
    public Core_Account_330_URL(ApexPages.StandardController controller) 
    {
        account = (Account)controller.getRecord();
        System.debug('account: ' + account); 

        account = [SELECT Id, Name, Owner.Id, Core_CPM_ID__c, Core_GEO__c 
                   FROM Account 
                   WHERE Id = :account.Id];

        Id userId = UserInfo.getUserId();
        System.debug('#05 userId: ' + userId); 

        isAccessAllowed = accessCheck(userId);    
        if (!isAccessAllowed)       
        {    
            PageReference acctPage  = ApexPages.currentPage();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Access to Account 330 Reports is closely controlled.');
            ApexPages.addMessage(myMsg);                                               
            
            myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact the Account Owner to be added to the Account Team.');
            ApexPages.addMessage(myMsg);             
            
            User userObj = [SELECT UserRole.Name FROM User WHERE Id = :account.Owner.Id LIMIT 1];
            if (userObj != NULL && userObj.UserRole.Name == 'Admin')
            {
                myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Account owner is a Role Hierarchy Admin.  Access by Manager is not possible.');
                ApexPages.addMessage(myMsg);             
            }
                                                          
            return; 
        }
    
        // load the current record
        accountId   = account.Id;
        System.debug('accountId: ' + accountId); 

        accountName = account.Name;
        System.debug('accountName: ' + accountName); 
           
        cpmIdList = new List<String>();                
        cpmId     = account.Core_CPM_ID__c;
        System.debug('cpmId: ' + cpmId); 

        // Check before the split, to avoid a NULL POINTER ERROR
        isNotBlankCpmId = !string.isblank(cpmId);
        if (isNotBlankCpmId == FALSE)
            return;

        cpmIdList = cpmId.split(',');
                
        isMultipleCpmId = (cpmIdList.size() > 1);
        if (isMultipleCpmId)
        {
            cpmId      = cpmIdList[0].trim();
            cpmChoices = new List<SelectOption>();
            for (String cpm : cpmIdList)
                cpmChoices.add(new SelectOption(cpm,cpm));
        }
        else
            cpmId = cpmId.trim();

        // Check after the TRIM too.
        isNotBlankCpmId = !string.isblank(cpmId);
        if (isNotBlankCpmId == FALSE)
            return;

        System.debug('cpmId: ' + cpmId); 
        System.debug('isMultipleCpmId: ' + isMultipleCpmId); 

        csMap = Core_Account330CustomSettings__c.getAll();            
        
        // Default value of the frame source
        loadSalesUnits();
    }

    public Boolean accessCheck(Id userId)
    { 
        if (account == null)
            return false;

        System.debug('#12 account.Owner.Id '     + account.Owner.Id);
        System.debug('#13 UserInfo.getUserId() ' + userId);
    
        if (account.Owner.Id == userId)
            return true;
            
        Core_Account_Accessor accountAccessor = new Core_Account_Accessor();           
        accountAccessor.accountId = account.Id;    
                        
        for (Id teamUserId : accountAccessor.teamUserIds)
            if (teamUserId == userId)
                return true;    
            
        if (Core_Test_Utility.isUserGroupMember(userId, Label.Core_Account_330_Executive_Access))    
            return true;
            
        if (Core_Test_Utility.isUserGroupMember(userId, account330GroupByGEO(account.Core_GEO__c)))    
            return true;
                        
        // Add the Account Owner to the array used for verification . . . just in case
        accountAccessor.teamUserIds.add(account.Owner.Id);

        if (upWardTraversal(accountAccessor.teamUserIds, userId))
            return true;
                        
        return false;    
    }


    public String account330GroupByGEO(String geo)
    {
        Map<String, Core_Account330_GeoAccessGroups__c> accessMap = Core_Account330_GeoAccessGroups__c.getAll();            

        for (Core_Account330_GeoAccessGroups__c setting : accessMap.values())
            if (setting.name == geo)
            {
                System.debug('#63 setting.Core_Group_Name__c: ' + setting.Core_Group_Name__c);
                return setting.Core_Group_Name__c;
            }
        
        return '';
    }


    public Boolean upWardTraversal(Set<Id> leafIds, Id currentUserId)
    {
        System.debug('#10 currentUserId: ' + currentUserId);
        System.debug('#11 leafIds: '  + leafIds);

        roleHierarchyAccessor.userIds = leafIds;
        System.debug('#12 roleHierarchyAccessor.userIds: ' + roleHierarchyAccessor.userIds);


        while (roleHierarchyAccessor.RoleIds.size() > 0) {

            System.debug('#13 roleHierarchyAccessor.RoleIds: '       + roleHierarchyAccessor.RoleIds);
            System.debug('#14 roleHierarchyAccessor.ParentRoleIds: ' + roleHierarchyAccessor.ParentRoleIds);
        
            roleHierarchyAccessor.RoleIds = roleHierarchyAccessor.ParentRoleIds;
            System.debug('#15 roleHierarchyAccessor.RoleIds: '       + roleHierarchyAccessor.RoleIds);
            System.debug('#16 roleHierarchyAccessor.RoleUserIds: '   + roleHierarchyAccessor.RoleUserIds);
                        
            if (roleHierarchyAccessor.RoleUserIds.size() > 0) {        
                for (Id roleUserId : roleHierarchyAccessor.RoleUserIds)
                    if (roleUserId == currentUserId)
                    {
                        System.debug('MANAGER MATCH: ' + roleUserId);
                        return true;
                    }
            }
        }
            
        return false;
    }


    // The method to reload the iframe with another source page
    public PageReference loadSalesUnits() {
        isStandardOffset = true;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('1');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    }

    // The method to reload the iframe with another source page
    public PageReference loadSalesRevenue() {
        isStandardOffset = true;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('2');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    }
    
    // The method to reload the iframe with another source page
    public PageReference loadProductUnits() {
        isStandardOffset = true;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('3');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    }

    // The method to reload the iframe with another source page
    public PageReference loadProductRevenue() {
        isStandardOffset = true;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('4');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    }
    
    // The method to reload the iframe with another source page
    public PageReference loadBrandedUnits() {
        isStandardOffset = true;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('5');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    }

    // The method to reload the iframe with another source page
    public PageReference loadBrandedRevenue() {
        isStandardOffset = true;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('6');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    }
    
    // The method to reload the iframe with another source page
    public PageReference loadMembership() {
        isStandardOffset = false;
        if (isNotBlankCpmId)
        {
            Core_Account330CustomSettings__c cs = csMap.get('7');
            if (cs != null)
                iframeSource = cs.Core_Report_URL__c + cpmId;
        }
        return null;
    } 
}