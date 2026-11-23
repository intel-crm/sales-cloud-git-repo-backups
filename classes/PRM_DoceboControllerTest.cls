@IsTest
private class PRM_DoceboControllerTest {

    /**
     * Mock handling both callouts
     */
    private class DoceboSuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();

            // Call 1 - Token API
            if(req.getMethod() == 'POST') {

                res.setStatusCode(200);
                res.setBody(
                    '{"access_token":"TEST_TOKEN"}'
                );
                return res;
            }

            // Call 2 - Channel API
            if(req.getMethod() == 'GET') {

                res.setStatusCode(200);

                res.setBody(
                '{' +
                '"data":{' +
                    '"items":[' +
                        '{' +
                            '"id":101,' +
                            '"title":"Course One",' +
                            '"type_id":"course",' +
                            '"rating_option":"enabled",' +
                            '"rating":4.5,' +
                            '"created":"2026-10-14",' +
                            '"is_new":true,' +
                            '"duration":60,' +
                            '"language_label":"English",' +
                            '"hidden":false,' +
                            '"content_type":"elearning",' +
                            '"image_url":"https://test.com/image.png",' +
                            '"show_waiting":false,' +
                            '"uri":"/course1",' +
                            '"other_fields":{' +
                                '"type":"course",' +
                                '"views":10,' +
                                '"is_watched":"false",' +
                                '"status_id":"in_progress",' +
                                '"status_label":"In Progress",' +
                                '"can_enter":true,' +
                                '"can_enter_reason":"",' +
                                '"expiration_date":"",' +
                                '"level":"Beginner",' +
                                '"language":"English",' +
                                '"language_code":"en",' +
                                '"language_label":"English",' +
                                '"quick_course_launch":true' +
                            '},' +
                            '"outdated":{' +
                                '"total_users":50,' +
                                '"already_marked":false' +
                            '},' +
                            '"actions":[{"id":1}]' +
                        '}' +
                    ']' +
                '}' +
                '}'
                );

                return res;
            }

            return null;
        }
    }

    /**
     * User not found mock (404 from first call)
     */
    private class UserNotFoundMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();

            if(req.getMethod() == 'POST') {
                res.setStatusCode(404);
                res.setBody('User not found');
            }

            return res;
        }
    }

    /**
     * Success token but no courses
     */
    private class NoCoursesMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();

            if(req.getMethod() == 'POST') {

                res.setStatusCode(200);
                res.setBody(
                    '{"access_token":"TEST_TOKEN"}'
                );

                return res;
            }

            if(req.getMethod() == 'GET') {

                res.setStatusCode(200);
                res.setBody(
                    '{"data":{"items":[]}}'
                );

                return res;
            }

            return null;
        }
    }

    @IsTest
    static void testGetChannelAssets_Success() {

        Test.setMock(
            HttpCalloutMock.class,
            new DoceboSuccessMock()
        );

        Test.startTest();

        PRM_DoceboController.DoceboResponse response =
            PRM_DoceboController.getChannelAssets();

        Test.stopTest();

        System.assertEquals(true, response.userExists);
        System.assertEquals('SUCCESS', response.status);
        System.assertEquals(1, response.courses.size());

        PRM_DoceboController.CourseWrapper course =
            response.courses[0];

        System.assertEquals('Course One', course.title);
        System.assertEquals(101, course.id);
        System.assertNotEquals(null, course.fullUrl);
    }

    @IsTest
    static void testGetChannelAssets_UserNotFound() {

        Test.setMock(
            HttpCalloutMock.class,
            new UserNotFoundMock()
        );

        Test.startTest();

        PRM_DoceboController.DoceboResponse response =
            PRM_DoceboController.getChannelAssets();

        Test.stopTest();

        System.assertEquals(false, response.userExists);
        System.assertEquals('USER_NOT_FOUND', response.status);
        System.assertEquals(0, response.courses.size());
    }

    @IsTest
    static void testGetChannelAssets_NoCourses() {

        Test.setMock(
            HttpCalloutMock.class,
            new NoCoursesMock()
        );

        Test.startTest();

        PRM_DoceboController.DoceboResponse response =
            PRM_DoceboController.getChannelAssets();

        Test.stopTest();

        System.assertEquals(true, response.userExists);
        System.assertEquals('NO_COURSES', response.status);
        System.assertEquals(0, response.courses.size());
    }
}