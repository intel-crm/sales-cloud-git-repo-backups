public without sharing class Core_ACM_Constants {
    public enum Status {
        NEW_STATUS,
        SUCCESS_STATUS,
        FAILED_STATUS,
        IN_PROGRESS_STATUS,
        PENDING_STATUS,
        ACTIVE_STATUS,
        APPROVED_STATUS
    }

    public enum Flag {
        YES,
        NO
    }

    public enum ProcessType {
        LIVE,
        BULK_MODE
    }

    // Registration & agent
    public static final String REGISTRATION_TYPE_INTEL = 'INTEL';
    public static final String CHANGE_AGENT = 'SalesCloud';
    public static final String CHANGE_AGENT_LOGIN_ID = 'MAD\\testuser';

    public static final String MESSAGE_TYPE_ERPM = 'ERPM Contact Entitlement';
    public static final String MESSAGE_TYPE_BLACKBOX = 'Blackbox';
    public static final String SOURCE_ERPM = 'ERPM';
    public static final String SOURCE_ERPM_SET_PROFILES='ERPM_SET_PROFILES';
    //Ganesh Changes
	public static final String SOURCE_AGS = 'AGS';
	public static final String MESSAGE_TYPE_AGS = 'Role 2.0';
	//Ganesh Changes End


    public enum EngagementStatus {
        APPROVED,
        REJECTED
    }

    // Engagement types
    public static final String ENGAGEMENT_TYPE_SEC = 'SEC';

    public enum SubscriptionStatus {
        SUBSCRIBED,
        UNSUBSCRIBED
    }

    // Electronic address types
    public static final String ADDRESS_TYPE_PHONE = 'PHONE';
    public static final String ADDRESS_TYPE_MOBILE = 'MOB';
    public static final String LOCATION_TYPE_HOME = 'HOME';

    // Membership codes
    public static final String MEMBERSHIP_CRM_CLOUD = 'CRM_Cloud_Cntct';

    // Field length limits
    public static final Integer FIRST_NAME_MAX_LENGTH = 60;
    public static final Integer LAST_NAME_MAX_LENGTH = 70;

    // API settings
    public static final String API_CONTENT_TYPE = 'application/json';
    public static final Integer API_TIMEOUT = 30000;
    public static final Integer API_MAX_RETRY = 3;
    public static final Integer API_RETRY_BATCH_SIZE = 10;

    // Class names for logging
    public static final String CLASS_INTEGRATION_QUEUE_SERVICE = 'Core_IntegrationQueueService';
    public static final String CLASS_BATCH_PROCESSOR = 'Core_ACM_ERPMAPIBatchProcessor';

    public static String getFlagValue(Flag flag) {
        if (flag == null) {
            return null;
        }

        switch on flag {
            when YES {
                return 'Y';
            }
            when NO {
                return 'N';
            }
        }
        return null;
    }

    public static String getEngagementStatusValue(EngagementStatus engagementStatus) {
        if (engagementStatus == null) {
            return null;
        }

        switch on engagementStatus {
            when APPROVED {
                return 'ENGSTSAPRD';
            }
            when REJECTED {
                return 'ENGSTSRJTD';
            }
        }
        return null;
    }

    public static String getStatusValue(Status status) {
        if (status == null) {
            return null;
        }

        switch on status {
            when NEW_STATUS {
                return 'New';
            }
            when SUCCESS_STATUS {
                return 'Success';
            }
            when FAILED_STATUS {
                return 'Failed';
            }
            when IN_PROGRESS_STATUS {
                return 'In-Progress';
            }
            when PENDING_STATUS {
                return 'Pending';
            }
            when ACTIVE_STATUS {
                return 'Active';
            }
            when APPROVED_STATUS {
                return 'Approved';
            }
        }
        return null;
    }

    public static String getProcessTypeValue(ProcessType processType) {
        if (processType == null) {
            return null;
        }

        switch on processType {
            when LIVE {
                return 'LIVE';
            }
            when BULK_MODE {
                return 'BULK';
            }
        }
        return null;
    }

    public static String getSubscriptionStatusValue(SubscriptionStatus subscriptionStatus) {
        if (subscriptionStatus == null) {
            return null;
        }

        switch on subscriptionStatus {
            when SUBSCRIBED {
                return 'USER-SUB';
            }
            when UNSUBSCRIBED {
                return 'USER-UNSUB';
            }
        }
        return null;
    }
}