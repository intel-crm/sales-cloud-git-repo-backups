public without sharing class Core_ACM_ContactDataProcessor {

    public static Map<String, String> getSoftEngagementCode(Contact contact) {
        Map<String, String> mSoftEngCodes = new Map<String, String>();
        Map<String, String> mEngCodes = new Map<String, String>();
        for (Core_Contact_Entitlement__c cEnt : contact.Contact_Entitlements__r) {
            if (cEnt.Core_Contact_Id__c == contact.Id) {
                if (cEnt.Core_Entitlement_Id__r.Core_IsActive__c) {
                    String engCode = cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Technical_Engagement_Code__c;
                    String action = (cEnt.Core_Selected__c)
                        ? Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.APPROVED)
                        : Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.REJECTED);
                    if (engCode != null && cEnt.Core_Entitlement_Id__r.Core_ERPM_Engagement_Id__r.Core_Engagement_Type__c == Core_ACM_Constants.ENGAGEMENT_TYPE_SEC) {
                        if (!mEngCodes.containsKey(engCode)) {
                            mEngCodes.put(engCode, action);
                        } else {
                            if (mEngCodes.get(engCode).equals(Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.REJECTED))) {
                                mEngCodes.put(engCode, action);
                            }
                        }
                    } else if (engCode != null) {
                        if (!mSoftEngCodes.containsKey(engCode)) {
                            mSoftEngCodes.put(engCode, action);
                        } else {
                            if (mSoftEngCodes.get(engCode).equals(Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.REJECTED))) {
                                mSoftEngCodes.put(engCode, action);
                            }
                        }
                    }
                }
            }
        }
        return mSoftEngCodes;
    }

    public static List<Core_ACM_PayloadWrapper.Subscription> getSubscriptions(Contact contact) {
        List<Core_ACM_PayloadWrapper.Subscription> psnSub = new List<Core_ACM_PayloadWrapper.Subscription>();
        for (PRM_ContactSubscriptionAssociation__c contSub : contact.Contact_Subscription_Associations__r) {
            Core_ACM_PayloadWrapper.Subscription psnSubscription = new Core_ACM_PayloadWrapper.Subscription();
            psnSubscription.SubscriptionCode = contSub.PRM_Partner_Subscription_Id__r.PRM_Subscription_Cd__c;
            psnSubscription.SubscriptionName = contSub.PRM_Partner_Subscription_Id__r.Name;
            if (contact.Core_Do_Not_Contact__c) {
                psnSubscription.SubscriptionStatusCode = Core_ACM_Constants.getSubscriptionStatusValue(Core_ACM_Constants.SubscriptionStatus.UNSUBSCRIBED);
            } else {
                psnSubscription.SubscriptionStatusCode = contSub.PRM_Status_Nm__c == Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.ACTIVE_STATUS)
                    ? Core_ACM_Constants.getSubscriptionStatusValue(Core_ACM_Constants.SubscriptionStatus.SUBSCRIBED)
                    : Core_ACM_Constants.getSubscriptionStatusValue(Core_ACM_Constants.SubscriptionStatus.UNSUBSCRIBED);
            }
            psnSubscription.UnSubscriptionReason = contSub.PRM_Status_Reason_Txt__c;
            psnSub.add(psnSubscription);
        }
        return psnSub;
    }

    public static List<Core_ACM_PayloadWrapper.Membership> getMemberShips(Contact contact, Map<String, String> mSoftEngCodes) {
        List<Core_ACM_PayloadWrapper.Membership> psnMemberships = new List<Core_ACM_PayloadWrapper.Membership>();
        if (contact.Contact_Business_Types__r.Size() > 0 && String.isNotBlank(contact.Core_Enterprise_Id__c)) {
            psnMemberships.add(new Core_ACM_PayloadWrapper.Membership(
                Label.UDE_Standard_Engg_Code,
                (contact.Contact_Business_Types__r[0].Status__c == Core_ACM_Constants.getStatusValue(Core_ACM_Constants.Status.APPROVED_STATUS))
                    ? Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.APPROVED)
                    : Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.REJECTED)
            ));
        }
        psnMemberships.add(new Core_ACM_PayloadWrapper.Membership(
            Core_ACM_Constants.MEMBERSHIP_CRM_CLOUD,
            Core_ACM_Constants.getEngagementStatusValue(Core_ACM_Constants.EngagementStatus.APPROVED)
        ));
        if (mSoftEngCodes.size() > 0) {
            for (String key : mSoftEngCodes.keySet()) {
                psnMemberships.add(new Core_ACM_PayloadWrapper.Membership(key, mSoftEngCodes.get(key)));
            }
        }
        return psnMemberships;
    }
}