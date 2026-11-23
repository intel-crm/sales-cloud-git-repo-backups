@isTest
public class Core_IntegrationMessageJSONWrapperTest {

    private static Core_IntegrationMessageJSONWrapper createWrapper() {
        Core_IntegrationMessageJSONWrapper wrapper = new Core_IntegrationMessageJSONWrapper();
        Core_IntegrationMessageJSONWrapper.UserProfile userProfile = 
            new Core_IntegrationMessageJSONWrapper.UserProfile();

        wrapper.publishTimeStamp = '2026-08-07T10:00:00Z';
        wrapper.changeAgent = 'TestAgent';
        wrapper.isDeleteIndicator = 'false';

        userProfile.personBasicProfile = new List<Map<String, String>>{
            new Map<String, String>{'firstName' => 'John', 'lastName' => 'Doe'}
        };
        userProfile.electronicAddresses = new List<Map<String, String>>{
            new Map<String, String>{'emailAddress' => 'john.doe@example.com'}
        };
        userProfile.subscriptions = new List<Map<String, String>>{
            new Map<String, String>{'subscriptionType' => 'Newsletter'}
        };
        userProfile.physicalAddresses = new List<Map<String, String>>{
            new Map<String, String>{'street' => '123 Main St', 'city' => 'New York'}
        };
        userProfile.professions = new List<Map<String, String>>{
            new Map<String, String>{'professionType' => 'Engineer'}
        };
        userProfile.engagements = new List<Map<String, String>>{
            new Map<String, String>{'engagementType' => 'Event'}
        };

        wrapper.userProfile = userProfile;
        return wrapper;
    }

    @isTest
    static void testWrapperFields() {
        Core_IntegrationMessageJSONWrapper wrapper = createWrapper();

        System.assertEquals('2026-08-07T10:00:00Z', wrapper.publishTimeStamp);
        System.assertEquals('TestAgent', wrapper.changeAgent);
        System.assertEquals('false', wrapper.isDeleteIndicator);
    }

    @isTest
    static void testUserProfileLists() {
        Core_IntegrationMessageJSONWrapper wrapper = createWrapper();

        System.assertEquals('John', wrapper.userProfile.personBasicProfile[0].get('firstName'));
        System.assertEquals('john.doe@example.com', wrapper.userProfile.electronicAddresses[0].get('emailAddress'));
        System.assertEquals('Newsletter', wrapper.userProfile.subscriptions[0].get('subscriptionType'));
        System.assertEquals('123 Main St', wrapper.userProfile.physicalAddresses[0].get('street'));
        System.assertEquals('Engineer', wrapper.userProfile.professions[0].get('professionType'));
        System.assertEquals('Event', wrapper.userProfile.engagements[0].get('engagementType'));
    }

    @isTest
    static void testJSONSerialization() {
        Core_IntegrationMessageJSONWrapper wrapper = createWrapper();
        String jsonString = JSON.serialize(wrapper);

        Core_IntegrationMessageJSONWrapper deserializedWrapper = 
            (Core_IntegrationMessageJSONWrapper) JSON.deserialize(jsonString, Core_IntegrationMessageJSONWrapper.class);

        System.assertEquals(wrapper.changeAgent, deserializedWrapper.changeAgent);
        System.assertEquals(wrapper.publishTimeStamp, deserializedWrapper.publishTimeStamp);
    }

    @isTest
    static void testNullFields() {
        Core_IntegrationMessageJSONWrapper wrapper = new Core_IntegrationMessageJSONWrapper();

        System.assertEquals(null, wrapper.userProfile);
        System.assertEquals(null, wrapper.publishTimeStamp);
        System.assertEquals(null, wrapper.changeAgent);
        System.assertEquals(null, wrapper.isDeleteIndicator);
    }
}